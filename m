Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f198.google.com (mail-qk0-f198.google.com [209.85.220.198])
	by kanga.kvack.org (Postfix) with ESMTP id 0CE8B6B0003
	for <linux-mm@kvack.org>; Thu,  1 Mar 2018 17:17:56 -0500 (EST)
Received: by mail-qk0-f198.google.com with SMTP id v68so5938483qki.13
        for <linux-mm@kvack.org>; Thu, 01 Mar 2018 14:17:56 -0800 (PST)
Received: from mx0a-00082601.pphosted.com (mx0a-00082601.pphosted.com. [67.231.145.42])
        by mx.google.com with ESMTPS id x6si4566775qke.188.2018.03.01.14.17.53
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 01 Mar 2018 14:17:54 -0800 (PST)
From: Roman Gushchin <guro@fb.com>
Subject: [RFC] mm: indirectly reclaimable memory and dcache
Date: Thu, 1 Mar 2018 22:17:13 +0000
Message-ID: <20180301221713.25969-1-guro@fb.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: Roman Gushchin <guro@fb.com>, Andrew Morton <akpm@linux-foundation.org>, Alexander Viro <viro@zeniv.linux.org.uk>, Michal Hocko <mhocko@suse.com>, Johannes Weiner <hannes@cmpxchg.org>, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org, kernel-team@fb.com

I was reported about suspicious growth of unreclaimable slabs
on some machines. I've found that it happens on machines
with low memory pressure, and these unreclaimable slabs
are external names attached to dentries.

External names are allocated using generic kmalloc() function,
so they are accounted as unreclaimable. But they are held
by dentries, which are reclaimable, and they will be reclaimed
under the memory pressure.

In particular, this breaks MemAvailable calculation, as it
doesn't take unreclaimable slabs into account.
This leads to a silly situation, when a machine is almost idle,
has no memory pressure and therefore has a big dentry cache.
And the resulting MemAvailable is too low to start a new workload.

To resolve this issue, a new mm counter is introduced:
NR_INDIRECTLY_RECLAIMABLE_BYTES .
Since it's not possible to count such objects on per-page basis,
let's make the unit obvious (by analogy to NR_KERNEL_STACK_KB).

The counter is increased in dentry allocation path, if an external
name structure is allocated; and it's decreased in dentry freeing
path. I believe, that it's not the only case in the kernel, when
we do have such indirectly reclaimable memory, so I expect more
use cases to be added.

This counter is used to adjust MemAvailable calculations:
indirectly reclaimable memory is considered as available.

To reproduce the problem I've used the following Python script:
  import os

  for iter in range (0, 10000000):
      try:
          name = ("/some_long_name_%d" % iter) + "_" * 220
          os.stat(name)
      except Exception:
          pass

Without this patch:
  $ cat /proc/meminfo | grep MemAvailable
  MemAvailable:    7811688 kB
  $ python indirect.py
  $ cat /proc/meminfo | grep MemAvailable
  MemAvailable:    2753052 kB

With the patch:
  $ cat /proc/meminfo | grep MemAvailable
  MemAvailable:    7809516 kB
  $ python indirect.py
  $ cat /proc/meminfo | grep MemAvailable
  MemAvailable:    7749144 kB

Also, this patch adds a corresponding entry to /proc/vmstat:

  $ cat /proc/vmstat | grep indirect
  nr_indirectly_reclaimable 5117499104

  $ echo 2 > /proc/sys/vm/drop_caches

  $ cat /proc/vmstat | grep indirect
  nr_indirectly_reclaimable 7104

Signed-off-by: Roman Gushchin <guro@fb.com>
Cc: Andrew Morton <akpm@linux-foundation.org>
Cc: Alexander Viro <viro@zeniv.linux.org.uk>
Cc: Michal Hocko <mhocko@suse.com>
Cc: Johannes Weiner <hannes@cmpxchg.org>
Cc: linux-fsdevel@vger.kernel.org
Cc: linux-kernel@vger.kernel.org
Cc: linux-mm@kvack.org
Cc: kernel-team@fb.com
---
 fs/dcache.c            | 29 ++++++++++++++++++++++++-----
 include/linux/mmzone.h |  1 +
 mm/page_alloc.c        |  7 +++++++
 mm/vmstat.c            |  1 +
 4 files changed, 33 insertions(+), 5 deletions(-)

diff --git a/fs/dcache.c b/fs/dcache.c
index 5c7df1df81ff..a0312d73f575 100644
--- a/fs/dcache.c
+++ b/fs/dcache.c
@@ -273,8 +273,16 @@ static void __d_free(struct rcu_head *head)
 static void __d_free_external(struct rcu_head *head)
 {
 	struct dentry *dentry = container_of(head, struct dentry, d_u.d_rcu);
-	kfree(external_name(dentry));
-	kmem_cache_free(dentry_cache, dentry); 
+	struct external_name *name = external_name(dentry);
+	unsigned long bytes;
+
+	bytes = dentry->d_name.len + offsetof(struct external_name, name[1]);
+	mod_node_page_state(page_pgdat(virt_to_page(name)),
+			    NR_INDIRECTLY_RECLAIMABLE_BYTES,
+			    -kmalloc_size(kmalloc_index(bytes)));
+
+	kfree(name);
+	kmem_cache_free(dentry_cache, dentry);
 }
 
 static inline int dname_external(const struct dentry *dentry)
@@ -1598,6 +1606,7 @@ struct dentry *__d_alloc(struct super_block *sb, const struct qstr *name)
 	struct dentry *dentry;
 	char *dname;
 	int err;
+	size_t reclaimable = 0;
 
 	dentry = kmem_cache_alloc(dentry_cache, GFP_KERNEL);
 	if (!dentry)
@@ -1614,9 +1623,11 @@ struct dentry *__d_alloc(struct super_block *sb, const struct qstr *name)
 		name = &slash_name;
 		dname = dentry->d_iname;
 	} else if (name->len > DNAME_INLINE_LEN-1) {
-		size_t size = offsetof(struct external_name, name[1]);
-		struct external_name *p = kmalloc(size + name->len,
-						  GFP_KERNEL_ACCOUNT);
+		struct external_name *p;
+
+		reclaimable = offsetof(struct external_name, name[1]) +
+			name->len;
+		p = kmalloc(reclaimable, GFP_KERNEL_ACCOUNT);
 		if (!p) {
 			kmem_cache_free(dentry_cache, dentry); 
 			return NULL;
@@ -1665,6 +1676,14 @@ struct dentry *__d_alloc(struct super_block *sb, const struct qstr *name)
 		}
 	}
 
+	if (unlikely(reclaimable)) {
+		pg_data_t *pgdat;
+
+		pgdat = page_pgdat(virt_to_page(external_name(dentry)));
+		mod_node_page_state(pgdat, NR_INDIRECTLY_RECLAIMABLE_BYTES,
+				    kmalloc_size(kmalloc_index(reclaimable)));
+	}
+
 	this_cpu_inc(nr_dentry);
 
 	return dentry;
diff --git a/include/linux/mmzone.h b/include/linux/mmzone.h
index 67f2e3c38939..953af0232023 100644
--- a/include/linux/mmzone.h
+++ b/include/linux/mmzone.h
@@ -180,6 +180,7 @@ enum node_stat_item {
 	NR_VMSCAN_IMMEDIATE,	/* Prioritise for reclaim when writeback ends */
 	NR_DIRTIED,		/* page dirtyings since bootup */
 	NR_WRITTEN,		/* page writings since bootup */
+	NR_INDIRECTLY_RECLAIMABLE_BYTES, /* measured in bytes */
 	NR_VM_NODE_STAT_ITEMS
 };
 
diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 76c9688b6a0a..03ff871ad73e 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -4599,6 +4599,13 @@ long si_mem_available(void)
 		     min(global_node_page_state(NR_SLAB_RECLAIMABLE) / 2,
 			 wmark_low);
 
+	/*
+	 * Part of unreclaimable slab which is held by reclaimable object,
+	 * and can be reclaimed under memory pressure.
+	 */
+	available += global_node_page_state(NR_INDIRECTLY_RECLAIMABLE_BYTES) >>
+		PAGE_SHIFT;
+
 	if (available < 0)
 		available = 0;
 	return available;
diff --git a/mm/vmstat.c b/mm/vmstat.c
index 40b2db6db6b1..b6b5684f31fe 100644
--- a/mm/vmstat.c
+++ b/mm/vmstat.c
@@ -1161,6 +1161,7 @@ const char * const vmstat_text[] = {
 	"nr_vmscan_immediate_reclaim",
 	"nr_dirtied",
 	"nr_written",
+	"nr_indirectly_reclaimable",
 
 	/* enum writeback_stat_item counters */
 	"nr_dirty_threshold",
-- 
2.14.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

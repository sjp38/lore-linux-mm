Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f70.google.com (mail-wm0-f70.google.com [74.125.82.70])
	by kanga.kvack.org (Postfix) with ESMTP id 5EE226B0012
	for <linux-mm@kvack.org>; Mon,  5 Mar 2018 08:38:29 -0500 (EST)
Received: by mail-wm0-f70.google.com with SMTP id c142so4637955wmh.4
        for <linux-mm@kvack.org>; Mon, 05 Mar 2018 05:38:29 -0800 (PST)
Received: from mx0a-00082601.pphosted.com (mx0a-00082601.pphosted.com. [67.231.145.42])
        by mx.google.com with ESMTPS id x84si4588209wmg.34.2018.03.05.05.38.27
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 05 Mar 2018 05:38:27 -0800 (PST)
From: Roman Gushchin <guro@fb.com>
Subject: [PATCH 3/3] dcache: account external names as indirectly reclaimable memory
Date: Mon, 5 Mar 2018 13:37:43 +0000
Message-ID: <20180305133743.12746-5-guro@fb.com>
In-Reply-To: <20180305133743.12746-1-guro@fb.com>
References: <20180305133743.12746-1-guro@fb.com>
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

To address the issue, the NR_INDIRECTLY_RECLAIMABLE_BYTES counter
is used to track the amount of memory, consumed by external names.
The counter is increased in the dentry allocation path, if an external
name structure is allocated; and it's decreased in the dentry freeing
path.

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
 fs/dcache.c | 29 ++++++++++++++++++++++++-----
 1 file changed, 24 insertions(+), 5 deletions(-)

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
-- 
2.14.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

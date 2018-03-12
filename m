Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f197.google.com (mail-wr0-f197.google.com [209.85.128.197])
	by kanga.kvack.org (Postfix) with ESMTP id 2ED096B0009
	for <linux-mm@kvack.org>; Mon, 12 Mar 2018 15:42:45 -0400 (EDT)
Received: by mail-wr0-f197.google.com with SMTP id k44so3749418wrc.3
        for <linux-mm@kvack.org>; Mon, 12 Mar 2018 12:42:45 -0700 (PDT)
Received: from mx0a-00082601.pphosted.com (mx0a-00082601.pphosted.com. [67.231.145.42])
        by mx.google.com with ESMTPS id x9si1552364edk.414.2018.03.12.12.42.43
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 12 Mar 2018 12:42:43 -0700 (PDT)
From: Roman Gushchin <guro@fb.com>
Subject: [PATCH] dcache: fix indirectly reclaimable memory accounting for CONFIG_SLOB
Date: Mon, 12 Mar 2018 19:41:40 +0000
Message-ID: <20180312194140.19517-1-guro@fb.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: Roman Gushchin <guro@fb.com>, Andrew Morton <akpm@linux-foundation.org>, Alexander Viro <viro@zeniv.linux.org.uk>, Michal Hocko <mhocko@suse.com>, Johannes Weiner <hannes@cmpxchg.org>, Tony Lindgren <tony@atomide.com>, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org, kernel-team@fb.com

Indirectly reclaimable memory accounting uses
kmalloc_size()/kmalloc_index() functions to estimate
amount of consumed memory. kmalloc_size() always returns 0
and kmalloc_index() is not defined for CONFIG_SLOB,
and so it breaks the build.

Fix this by using ksize() function instead.

Slub:
$ cat /proc/meminfo | grep Avail
MemAvailable:    7857112 kB
$ python indirect.py
$ cat /proc/meminfo | grep Avail
MemAvailable:    7781312 kB

Slob:
$ cat /proc/meminfo | grep Avail
MemAvailable:    7853272 kB
$ python indirect.py
$ cat /proc/meminfo | grep Avail
MemAvailable:    7616644 kB

indirect.py:
  import os

  for iter in range (0, 1000000):
      try:
          name = ("/some_long_name_%d" % iter) + "_" * 220
          os.stat(name)
      except Exception:
          pass

Signed-off-by: Roman Gushchin <guro@fb.com>
Cc: Andrew Morton <akpm@linux-foundation.org>
Cc: Alexander Viro <viro@zeniv.linux.org.uk>
Cc: Michal Hocko <mhocko@suse.com>
Cc: Johannes Weiner <hannes@cmpxchg.org>
Cc: Tony Lindgren <tony@atomide.com>
Cc: linux-fsdevel@vger.kernel.org
Cc: linux-kernel@vger.kernel.org
Cc: linux-mm@kvack.org
Cc: kernel-team@fb.com
---
 fs/dcache.c | 26 ++++++++++----------------
 1 file changed, 10 insertions(+), 16 deletions(-)

diff --git a/fs/dcache.c b/fs/dcache.c
index 135297a2d40e..98826efe22a0 100644
--- a/fs/dcache.c
+++ b/fs/dcache.c
@@ -270,12 +270,10 @@ static void __d_free_external(struct rcu_head *head)
 {
 	struct dentry *dentry = container_of(head, struct dentry, d_u.d_rcu);
 	struct external_name *name = external_name(dentry);
-	unsigned long bytes;
 
-	bytes = dentry->d_name.len + offsetof(struct external_name, name[1]);
 	mod_node_page_state(page_pgdat(virt_to_page(name)),
 			    NR_INDIRECTLY_RECLAIMABLE_BYTES,
-			    -kmalloc_size(kmalloc_index(bytes)));
+			    -ksize(name));
 
 	kfree(name);
 	kmem_cache_free(dentry_cache, dentry);
@@ -1607,10 +1605,10 @@ EXPORT_SYMBOL(d_invalidate);
  
 struct dentry *__d_alloc(struct super_block *sb, const struct qstr *name)
 {
+	struct external_name *ext = NULL;
 	struct dentry *dentry;
 	char *dname;
 	int err;
-	size_t reclaimable = 0;
 
 	dentry = kmem_cache_alloc(dentry_cache, GFP_KERNEL);
 	if (!dentry)
@@ -1627,17 +1625,15 @@ struct dentry *__d_alloc(struct super_block *sb, const struct qstr *name)
 		name = &slash_name;
 		dname = dentry->d_iname;
 	} else if (name->len > DNAME_INLINE_LEN-1) {
-		struct external_name *p;
+		size_t size = offsetof(struct external_name, name[1]);
 
-		reclaimable = offsetof(struct external_name, name[1]) +
-			name->len;
-		p = kmalloc(reclaimable, GFP_KERNEL_ACCOUNT);
-		if (!p) {
+		ext = kmalloc(size + name->len, GFP_KERNEL_ACCOUNT);
+		if (!ext) {
 			kmem_cache_free(dentry_cache, dentry); 
 			return NULL;
 		}
-		atomic_set(&p->u.count, 1);
-		dname = p->name;
+		atomic_set(&ext->u.count, 1);
+		dname = ext->name;
 	} else  {
 		dname = dentry->d_iname;
 	}	
@@ -1676,12 +1672,10 @@ struct dentry *__d_alloc(struct super_block *sb, const struct qstr *name)
 		}
 	}
 
-	if (unlikely(reclaimable)) {
-		pg_data_t *pgdat;
-
-		pgdat = page_pgdat(virt_to_page(external_name(dentry)));
+	if (unlikely(ext)) {
+		pg_data_t *pgdat = page_pgdat(virt_to_page(ext));
 		mod_node_page_state(pgdat, NR_INDIRECTLY_RECLAIMABLE_BYTES,
-				    kmalloc_size(kmalloc_index(reclaimable)));
+				    ksize(ext));
 	}
 
 	this_cpu_inc(nr_dentry);
-- 
2.14.3

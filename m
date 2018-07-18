Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f72.google.com (mail-ed1-f72.google.com [209.85.208.72])
	by kanga.kvack.org (Postfix) with ESMTP id 021D46B000E
	for <linux-mm@kvack.org>; Wed, 18 Jul 2018 09:36:32 -0400 (EDT)
Received: by mail-ed1-f72.google.com with SMTP id l1-v6so1933098edi.11
        for <linux-mm@kvack.org>; Wed, 18 Jul 2018 06:36:31 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id h29-v6si3074672edb.301.2018.07.18.06.36.30
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 18 Jul 2018 06:36:30 -0700 (PDT)
From: Vlastimil Babka <vbabka@suse.cz>
Subject: [PATCH v3 4/7] dcache: allocate external names from reclaimable kmalloc caches
Date: Wed, 18 Jul 2018 15:36:17 +0200
Message-Id: <20180718133620.6205-5-vbabka@suse.cz>
In-Reply-To: <20180718133620.6205-1-vbabka@suse.cz>
References: <20180718133620.6205-1-vbabka@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, linux-api@vger.kernel.org, Roman Gushchin <guro@fb.com>, Michal Hocko <mhocko@kernel.org>, Johannes Weiner <hannes@cmpxchg.org>, Christoph Lameter <cl@linux.com>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Mel Gorman <mgorman@techsingularity.net>, Matthew Wilcox <willy@infradead.org>, Vlastimil Babka <vbabka@suse.cz>

We can use the newly introduced kmalloc-reclaimable-X caches, to allocate
external names in dcache, which will take care of the proper accounting
automatically, and also improve anti-fragmentation page grouping.

This effectively reverts commit f1782c9bc547 ("dcache: account external names
as indirectly reclaimable memory") and instead passes __GFP_RECLAIMABLE to
kmalloc(). The accounting thus moves from NR_INDIRECTLY_RECLAIMABLE_BYTES to
NR_SLAB_RECLAIMABLE, which is also considered in MemAvailable calculation and
overcommit decisions.

Signed-off-by: Vlastimil Babka <vbabka@suse.cz>
---
 fs/dcache.c | 38 +++++++++-----------------------------
 1 file changed, 9 insertions(+), 29 deletions(-)

diff --git a/fs/dcache.c b/fs/dcache.c
index 0e8e5de3c48a..518c9ed8db8c 100644
--- a/fs/dcache.c
+++ b/fs/dcache.c
@@ -257,24 +257,10 @@ static void __d_free(struct rcu_head *head)
 	kmem_cache_free(dentry_cache, dentry); 
 }
 
-static void __d_free_external_name(struct rcu_head *head)
-{
-	struct external_name *name = container_of(head, struct external_name,
-						  u.head);
-
-	mod_node_page_state(page_pgdat(virt_to_page(name)),
-			    NR_INDIRECTLY_RECLAIMABLE_BYTES,
-			    -ksize(name));
-
-	kfree(name);
-}
-
 static void __d_free_external(struct rcu_head *head)
 {
 	struct dentry *dentry = container_of(head, struct dentry, d_u.d_rcu);
-
-	__d_free_external_name(&external_name(dentry)->u.head);
-
+	kfree(external_name(dentry));
 	kmem_cache_free(dentry_cache, dentry);
 }
 
@@ -305,7 +291,7 @@ void release_dentry_name_snapshot(struct name_snapshot *name)
 		struct external_name *p;
 		p = container_of(name->name, struct external_name, name[0]);
 		if (unlikely(atomic_dec_and_test(&p->u.count)))
-			call_rcu(&p->u.head, __d_free_external_name);
+			kfree_rcu(p, u.head);
 	}
 }
 EXPORT_SYMBOL(release_dentry_name_snapshot);
@@ -1608,7 +1594,6 @@ EXPORT_SYMBOL(d_invalidate);
  
 struct dentry *__d_alloc(struct super_block *sb, const struct qstr *name)
 {
-	struct external_name *ext = NULL;
 	struct dentry *dentry;
 	char *dname;
 	int err;
@@ -1629,14 +1614,15 @@ struct dentry *__d_alloc(struct super_block *sb, const struct qstr *name)
 		dname = dentry->d_iname;
 	} else if (name->len > DNAME_INLINE_LEN-1) {
 		size_t size = offsetof(struct external_name, name[1]);
-
-		ext = kmalloc(size + name->len, GFP_KERNEL_ACCOUNT);
-		if (!ext) {
+		struct external_name *p = kmalloc(size + name->len,
+						  GFP_KERNEL_ACCOUNT |
+						  __GFP_RECLAIMABLE);
+		if (!p) {
 			kmem_cache_free(dentry_cache, dentry); 
 			return NULL;
 		}
-		atomic_set(&ext->u.count, 1);
-		dname = ext->name;
+		atomic_set(&p->u.count, 1);
+		dname = p->name;
 	} else  {
 		dname = dentry->d_iname;
 	}	
@@ -1675,12 +1661,6 @@ struct dentry *__d_alloc(struct super_block *sb, const struct qstr *name)
 		}
 	}
 
-	if (unlikely(ext)) {
-		pg_data_t *pgdat = page_pgdat(virt_to_page(ext));
-		mod_node_page_state(pgdat, NR_INDIRECTLY_RECLAIMABLE_BYTES,
-				    ksize(ext));
-	}
-
 	this_cpu_inc(nr_dentry);
 
 	return dentry;
@@ -2761,7 +2741,7 @@ static void copy_name(struct dentry *dentry, struct dentry *target)
 		dentry->d_name.hash_len = target->d_name.hash_len;
 	}
 	if (old_name && likely(atomic_dec_and_test(&old_name->u.count)))
-		call_rcu(&old_name->u.head, __d_free_external_name);
+		kfree_rcu(old_name, u.head);
 }
 
 /*
-- 
2.18.0

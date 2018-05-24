Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f198.google.com (mail-wr0-f198.google.com [209.85.128.198])
	by kanga.kvack.org (Postfix) with ESMTP id 522556B0269
	for <linux-mm@kvack.org>; Thu, 24 May 2018 07:00:25 -0400 (EDT)
Received: by mail-wr0-f198.google.com with SMTP id y9-v6so1027727wrg.22
        for <linux-mm@kvack.org>; Thu, 24 May 2018 04:00:25 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id b10-v6si4308222edf.239.2018.05.24.04.00.23
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 24 May 2018 04:00:24 -0700 (PDT)
From: Vlastimil Babka <vbabka@suse.cz>
Subject: [RFC PATCH 3/5] dcache: allocate external names from reclaimable kmalloc caches
Date: Thu, 24 May 2018 13:00:09 +0200
Message-Id: <20180524110011.1940-4-vbabka@suse.cz>
In-Reply-To: <20180524110011.1940-1-vbabka@suse.cz>
References: <20180524110011.1940-1-vbabka@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: Roman Gushchin <guro@fb.com>, Michal Hocko <mhocko@kernel.org>, Johannes Weiner <hannes@cmpxchg.org>, linux-kernel@vger.kernel.org, linux-api@vger.kernel.org, Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Mel Gorman <mgorman@techsingularity.net>, Vijayanand Jitta <vjitta@codeaurora.org>, Vlastimil Babka <vbabka@suse.cz>

We can use the newly introduced kmalloc-reclaimable-X caches, to allocate
external names in dcache, which will take care of the proper accounting
automatically, and also improve anti-fragmentation page grouping.

This effectively reverts commit f1782c9bc547 ("dcache: account external names
as indirectly reclaimable memory") and instead passes __GFP_RECLAIMABLE to
kmalloc(). The accounting thus moves from NR_INDIRECTLY_RECLAIMABLE_BYTES to
NR_SLAB_RECLAIMABLE, which is also considered in MemAvailable calculation and
overcommit decisions.

This reverts commit f1782c9bc547754f4bd3043fe8cfda53db85f13f.
---
 fs/dcache.c | 40 ++++++++++------------------------------
 1 file changed, 10 insertions(+), 30 deletions(-)

diff --git a/fs/dcache.c b/fs/dcache.c
index c30a8ae46096..3346034d4520 100644
--- a/fs/dcache.c
+++ b/fs/dcache.c
@@ -257,25 +257,11 @@ static void __d_free(struct rcu_head *head)
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
-	kmem_cache_free(dentry_cache, dentry);
+	kfree(external_name(dentry));
+	kmem_cache_free(dentry_cache, dentry); 
 }
 
 static inline int dname_external(const struct dentry *dentry)
@@ -306,7 +292,7 @@ void release_dentry_name_snapshot(struct name_snapshot *name)
 		struct external_name *p;
 		p = container_of(name->name, struct external_name, name[0]);
 		if (unlikely(atomic_dec_and_test(&p->u.count)))
-			call_rcu(&p->u.head, __d_free_external_name);
+			kfree_rcu(p, u.head);
 	}
 }
 EXPORT_SYMBOL(release_dentry_name_snapshot);
@@ -1609,7 +1595,6 @@ EXPORT_SYMBOL(d_invalidate);
  
 struct dentry *__d_alloc(struct super_block *sb, const struct qstr *name)
 {
-	struct external_name *ext = NULL;
 	struct dentry *dentry;
 	char *dname;
 	int err;
@@ -1630,14 +1615,15 @@ struct dentry *__d_alloc(struct super_block *sb, const struct qstr *name)
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
@@ -1676,12 +1662,6 @@ struct dentry *__d_alloc(struct super_block *sb, const struct qstr *name)
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
@@ -2762,7 +2742,7 @@ static void copy_name(struct dentry *dentry, struct dentry *target)
 		dentry->d_name.hash_len = target->d_name.hash_len;
 	}
 	if (old_name && likely(atomic_dec_and_test(&old_name->u.count)))
-		call_rcu(&old_name->u.head, __d_free_external_name);
+		kfree_rcu(old_name, u.head);
 }
 
 /*
-- 
2.17.0

Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ob0-f180.google.com (mail-ob0-f180.google.com [209.85.214.180])
	by kanga.kvack.org (Postfix) with ESMTP id 5A2C2900016
	for <linux-mm@kvack.org>; Thu,  4 Jun 2015 09:14:29 -0400 (EDT)
Received: by obbgp2 with SMTP id gp2so9729136obb.2
        for <linux-mm@kvack.org>; Thu, 04 Jun 2015 06:14:29 -0700 (PDT)
Received: from szxga03-in.huawei.com (szxga03-in.huawei.com. [119.145.14.66])
        by mx.google.com with ESMTPS id c8si1641130oel.39.2015.06.04.06.14.27
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Thu, 04 Jun 2015 06:14:28 -0700 (PDT)
Message-ID: <55704D15.3030309@huawei.com>
Date: Thu, 4 Jun 2015 21:05:25 +0800
From: Xishi Qiu <qiuxishi@huawei.com>
MIME-Version: 1.0
Subject: [RFC PATCH 12/12] mm: let slab/slub/slob use mirrored memory
References: <55704A7E.5030507@huawei.com>
In-Reply-To: <55704A7E.5030507@huawei.com>
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Xishi Qiu <qiuxishi@huawei.com>, Andrew Morton <akpm@linux-foundation.org>, nao.horiguchi@gmail.com, Yinghai Lu <yinghai@kernel.org>, "H. Peter Anvin" <hpa@zytor.com>, Thomas Gleixner <tglx@linutronix.de>, mingo@elte.hu, Xiexiuqi <xiexiuqi@huawei.com>, Hanjun Guo <guohanjun@huawei.com>, "Luck, Tony" <tony.luck@intel.com>
Cc: Linux MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

Add __GFP_MIRROR flag when allocate a new slab.

Signed-off-by: Xishi Qiu <qiuxishi@huawei.com>
---
 mm/slab.c | 3 ++-
 mm/slob.c | 2 +-
 mm/slub.c | 2 +-
 3 files changed, 4 insertions(+), 3 deletions(-)

diff --git a/mm/slab.c b/mm/slab.c
index 7eb38dd..3b3ef22 100644
--- a/mm/slab.c
+++ b/mm/slab.c
@@ -1594,7 +1594,8 @@ static struct page *kmem_getpages(struct kmem_cache *cachep, gfp_t flags,
 	if (memcg_charge_slab(cachep, flags, cachep->gfporder))
 		return NULL;
 
-	page = alloc_pages_exact_node(nodeid, flags | __GFP_NOTRACK, cachep->gfporder);
+	page = alloc_pages_exact_node(nodeid, flags | __GFP_NOTRACK | __GFP_MIRROR,
+					cachep->gfporder);
 	if (!page) {
 		memcg_uncharge_slab(cachep, cachep->gfporder);
 		slab_out_of_memory(cachep, flags, nodeid);
diff --git a/mm/slob.c b/mm/slob.c
index 4765f65..4ff9bde 100644
--- a/mm/slob.c
+++ b/mm/slob.c
@@ -452,7 +452,7 @@ __do_kmalloc_node(size_t size, gfp_t gfp, int node, unsigned long caller)
 
 		if (likely(order))
 			gfp |= __GFP_COMP;
-		ret = slob_new_pages(gfp, order, node);
+		ret = slob_new_pages(gfp | __GFP_MIRROR, order, node);
 
 		trace_kmalloc_node(caller, ret,
 				   size, PAGE_SIZE << order, gfp, node);
diff --git a/mm/slub.c b/mm/slub.c
index 54c0876..1219e33 100644
--- a/mm/slub.c
+++ b/mm/slub.c
@@ -1315,7 +1315,7 @@ static inline struct page *alloc_slab_page(struct kmem_cache *s,
 	struct page *page;
 	int order = oo_order(oo);
 
-	flags |= __GFP_NOTRACK;
+	flags |= __GFP_NOTRACK | __GFP_MIRROR;
 
 	if (memcg_charge_slab(s, flags, order))
 		return NULL;
-- 
2.0.0


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lb0-f179.google.com (mail-lb0-f179.google.com [209.85.217.179])
	by kanga.kvack.org (Postfix) with ESMTP id 517986B00AC
	for <linux-mm@kvack.org>; Wed, 26 Feb 2014 10:05:41 -0500 (EST)
Received: by mail-lb0-f179.google.com with SMTP id p9so461825lbv.38
        for <linux-mm@kvack.org>; Wed, 26 Feb 2014 07:05:40 -0800 (PST)
Received: from relay.parallels.com (relay.parallels.com. [195.214.232.42])
        by mx.google.com with ESMTPS id y6si1849238lal.50.2014.02.26.07.05.39
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 26 Feb 2014 07:05:39 -0800 (PST)
From: Vladimir Davydov <vdavydov@parallels.com>
Subject: [PATCH -mm 08/12] memcg: do not charge kmalloc_large allocations
Date: Wed, 26 Feb 2014 19:05:13 +0400
Message-ID: <b816c769ddd6a50ab39c87878ec2c832c102ef78.1393423762.git.vdavydov@parallels.com>
In-Reply-To: <cover.1393423762.git.vdavydov@parallels.com>
References: <cover.1393423762.git.vdavydov@parallels.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org
Cc: hannes@cmpxchg.org, mhocko@suse.cz, glommer@gmail.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, devel@openvz.org, Christoph Lameter <cl@linux-foundation.org>, Pekka Enberg <penberg@kernel.org>

We don't have a way to track kmalloc_large allocations so that charging
them makes kmemcg reparenting impossible. Since such allocations are
rare and can't be massively triggered from userspace, let's just ignore
them.

Cc: Johannes Weiner <hannes@cmpxchg.org>
Cc: Michal Hocko <mhocko@suse.cz>
Cc: Glauber Costa <glommer@gmail.com>
Cc: Christoph Lameter <cl@linux-foundation.org>
Cc: Pekka Enberg <penberg@kernel.org>
---
 include/linux/slab.h |    2 +-
 mm/slub.c            |    4 ++--
 2 files changed, 3 insertions(+), 3 deletions(-)

diff --git a/include/linux/slab.h b/include/linux/slab.h
index 8091d009cd72..29dbf6f2fd3a 100644
--- a/include/linux/slab.h
+++ b/include/linux/slab.h
@@ -364,7 +364,7 @@ kmalloc_order(size_t size, gfp_t flags, unsigned int order)
 {
 	void *ret;
 
-	flags |= (__GFP_COMP | __GFP_KMEMCG);
+	flags |= __GFP_COMP;
 	ret = (void *) __get_free_pages(flags, order);
 	kmemleak_alloc(ret, size, 1, flags);
 	return ret;
diff --git a/mm/slub.c b/mm/slub.c
index fa995823de60..d8b8659bfa64 100644
--- a/mm/slub.c
+++ b/mm/slub.c
@@ -3332,7 +3332,7 @@ static void *kmalloc_large_node(size_t size, gfp_t flags, int node)
 	struct page *page;
 	void *ptr = NULL;
 
-	flags |= __GFP_COMP | __GFP_NOTRACK | __GFP_KMEMCG;
+	flags |= __GFP_COMP | __GFP_NOTRACK;
 	page = alloc_pages_node(node, flags, get_order(size));
 	if (page)
 		ptr = page_address(page);
@@ -3402,7 +3402,7 @@ void kfree(const void *x)
 	if (unlikely(!PageSlab(page))) {
 		BUG_ON(!PageCompound(page));
 		kfree_hook(x);
-		__free_memcg_kmem_pages(page, compound_order(page));
+		__free_pages(page, compound_order(page));
 		return;
 	}
 	slab_free(page->slab_cache, page, object, _RET_IP_);
-- 
1.7.10.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

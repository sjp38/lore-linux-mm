Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lb0-f172.google.com (mail-lb0-f172.google.com [209.85.217.172])
	by kanga.kvack.org (Postfix) with ESMTP id 872CF82F64
	for <linux-mm@kvack.org>; Sat,  7 Nov 2015 15:07:50 -0500 (EST)
Received: by lbces9 with SMTP id es9so7577203lbc.2
        for <linux-mm@kvack.org>; Sat, 07 Nov 2015 12:07:49 -0800 (PST)
Received: from relay.parallels.com (relay.parallels.com. [195.214.232.42])
        by mx.google.com with ESMTPS id 196si4525044lfa.27.2015.11.07.12.07.49
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sat, 07 Nov 2015 12:07:49 -0800 (PST)
From: Vladimir Davydov <vdavydov@virtuozzo.com>
Subject: [PATCH 4/5] vmalloc: allow to account vmalloc to memcg
Date: Sat, 7 Nov 2015 23:07:08 +0300
Message-ID: <7fe5e6dbb66fa7f0102c012c59ac10c25c6b2da7.1446924358.git.vdavydov@virtuozzo.com>
In-Reply-To: <cover.1446924358.git.vdavydov@virtuozzo.com>
References: <cover.1446924358.git.vdavydov@virtuozzo.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@kernel.org>, Tejun Heo <tj@kernel.org>, Greg Thelen <gthelen@google.com>, linux-mm@kvack.org, cgroups@vger.kernel.org, linux-kernel@vger.kernel.org

This patch makes vmalloc family functions allocate vmalloc area pages
with alloc_kmem_pages so that if __GFP_ACCOUNT is set they will be
accounted to memcg. This is needed, at least, to account alloc_fdmem
allocations.

Signed-off-by: Vladimir Davydov <vdavydov@virtuozzo.com>
---
 mm/vmalloc.c | 6 +++---
 1 file changed, 3 insertions(+), 3 deletions(-)

diff --git a/mm/vmalloc.c b/mm/vmalloc.c
index 9db9ef5e8481..259cfb32b7cf 100644
--- a/mm/vmalloc.c
+++ b/mm/vmalloc.c
@@ -1476,7 +1476,7 @@ static void __vunmap(const void *addr, int deallocate_pages)
 			struct page *page = area->pages[i];
 
 			BUG_ON(!page);
-			__free_page(page);
+			__free_kmem_pages(page, 0);
 		}
 
 		if (area->flags & VM_VPAGES)
@@ -1607,9 +1607,9 @@ static void *__vmalloc_area_node(struct vm_struct *area, gfp_t gfp_mask,
 		struct page *page;
 
 		if (node == NUMA_NO_NODE)
-			page = alloc_page(alloc_mask);
+			page = alloc_kmem_pages(alloc_mask, order);
 		else
-			page = alloc_pages_node(node, alloc_mask, order);
+			page = alloc_kmem_pages_node(node, alloc_mask, order);
 
 		if (unlikely(!page)) {
 			/* Successfully allocated i pages, free them in __vunmap() */
-- 
2.1.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

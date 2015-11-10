Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f42.google.com (mail-pa0-f42.google.com [209.85.220.42])
	by kanga.kvack.org (Postfix) with ESMTP id 9B15E6B0258
	for <linux-mm@kvack.org>; Tue, 10 Nov 2015 13:34:48 -0500 (EST)
Received: by pabfh17 with SMTP id fh17so4468106pab.0
        for <linux-mm@kvack.org>; Tue, 10 Nov 2015 10:34:48 -0800 (PST)
Received: from mx2.parallels.com (mx2.parallels.com. [199.115.105.18])
        by mx.google.com with ESMTPS id fk1si6634525pad.35.2015.11.10.10.34.47
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 10 Nov 2015 10:34:47 -0800 (PST)
From: Vladimir Davydov <vdavydov@virtuozzo.com>
Subject: [PATCH v2 5/6] vmalloc: allow to account vmalloc to memcg
Date: Tue, 10 Nov 2015 21:34:06 +0300
Message-ID: <b02165792beff56fa6a13bc23b9a21df11395aec.1447172835.git.vdavydov@virtuozzo.com>
In-Reply-To: <cover.1447172835.git.vdavydov@virtuozzo.com>
References: <cover.1447172835.git.vdavydov@virtuozzo.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@kernel.org>, Tejun Heo <tj@kernel.org>, Greg Thelen <gthelen@google.com>, Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, linux-mm@kvack.org, cgroups@vger.kernel.org, linux-kernel@vger.kernel.org

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

Return-Path: <linux-kernel-owner@vger.kernel.org>
From: Roman Penyaev <rpenyaev@suse.de>
Subject: [PATCH 2/3] mm/vmalloc: do not call kmemleak_free() on not yet accounted memory
Date: Thu,  3 Jan 2019 15:59:53 +0100
Message-Id: <20190103145954.16942-3-rpenyaev@suse.de>
In-Reply-To: <20190103145954.16942-1-rpenyaev@suse.de>
References: <20190103145954.16942-1-rpenyaev@suse.de>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
Sender: linux-kernel-owner@vger.kernel.org
Cc: Roman Penyaev <rpenyaev@suse.de>, Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@suse.com>, Andrey Ryabinin <aryabinin@virtuozzo.com>, Joe Perches <joe@perches.com>, "Luis R. Rodriguez" <mcgrof@kernel.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

__vmalloc_area_node() calls vfree() on error path, which in turn calls
kmemleak_free(), but area is not yet accounted by kmemleak_vmalloc().

Signed-off-by: Roman Penyaev <rpenyaev@suse.de>
Cc: Andrew Morton <akpm@linux-foundation.org>
Cc: Michal Hocko <mhocko@suse.com>
Cc: Andrey Ryabinin <aryabinin@virtuozzo.com>
Cc: Joe Perches <joe@perches.com>
Cc: "Luis R. Rodriguez" <mcgrof@kernel.org>
Cc: linux-mm@kvack.org
Cc: linux-kernel@vger.kernel.org
---
 mm/vmalloc.c | 16 +++++++++++-----
 1 file changed, 11 insertions(+), 5 deletions(-)

diff --git a/mm/vmalloc.c b/mm/vmalloc.c
index 2cd24186ba84..dc6a62bca503 100644
--- a/mm/vmalloc.c
+++ b/mm/vmalloc.c
@@ -1565,6 +1565,14 @@ void vfree_atomic(const void *addr)
 	__vfree_deferred(addr);
 }
 
+static void __vfree(const void *addr)
+{
+	if (unlikely(in_interrupt()))
+		__vfree_deferred(addr);
+	else
+		__vunmap(addr, 1);
+}
+
 /**
  *	vfree  -  release memory allocated by vmalloc()
  *	@addr:		memory base address
@@ -1591,10 +1599,8 @@ void vfree(const void *addr)
 
 	if (!addr)
 		return;
-	if (unlikely(in_interrupt()))
-		__vfree_deferred(addr);
-	else
-		__vunmap(addr, 1);
+
+	__vfree(addr);
 }
 EXPORT_SYMBOL(vfree);
 
@@ -1709,7 +1715,7 @@ static void *__vmalloc_area_node(struct vm_struct *area, gfp_t gfp_mask,
 	warn_alloc(gfp_mask, NULL,
 			  "vmalloc: allocation failure, allocated %ld of %ld bytes",
 			  (area->nr_pages*PAGE_SIZE), area->size);
-	vfree(area->addr);
+	__vfree(area->addr);
 	return NULL;
 }
 
-- 
2.19.1

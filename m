Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx181.postini.com [74.125.245.181])
	by kanga.kvack.org (Postfix) with SMTP id 2AB616B0068
	for <linux-mm@kvack.org>; Fri, 24 Aug 2012 04:30:19 -0400 (EDT)
From: Hiroshi Doyu <hdoyu@nvidia.com>
Subject: [v3 2/4] ARM: dma-mapping: Refactor out to introduce __in_atomic_pool
Date: Fri, 24 Aug 2012 11:29:03 +0300
Message-ID: <1345796945-21115-3-git-send-email-hdoyu@nvidia.com>
In-Reply-To: <1345796945-21115-1-git-send-email-hdoyu@nvidia.com>
References: <1345796945-21115-1-git-send-email-hdoyu@nvidia.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: m.szyprowski@samsung.com
Cc: Hiroshi Doyu <hdoyu@nvidia.com>, linux-arm-kernel@lists.infradead.org, linaro-mm-sig@lists.linaro.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, kyungmin.park@samsung.com, arnd@arndb.de, linux@arm.linux.org.uk, chunsang.jeong@linaro.org, vdumpa@nvidia.com, konrad.wilk@oracle.com, subashrp@gmail.com, minchan@kernel.org, pullip.cho@samsung.com

Check the given range("start", "size") is included in "atomic_pool" or not.

Signed-off-by: Hiroshi Doyu <hdoyu@nvidia.com>
---
 arch/arm/mm/dma-mapping.c |   25 +++++++++++++++++++------
 1 files changed, 19 insertions(+), 6 deletions(-)

diff --git a/arch/arm/mm/dma-mapping.c b/arch/arm/mm/dma-mapping.c
index b14ee64..508fde1 100644
--- a/arch/arm/mm/dma-mapping.c
+++ b/arch/arm/mm/dma-mapping.c
@@ -501,19 +501,32 @@ static void *__alloc_from_pool(size_t size, struct page **ret_page)
 	return ptr;
 }
 
+static bool __in_atomic_pool(void *start, size_t size)
+{
+	struct dma_pool *pool = &atomic_pool;
+	void *end = start + size;
+	void *pool_start = pool->vaddr;
+	void *pool_end = pool->vaddr + pool->size;
+
+	if (start < pool_start || start > pool_end)
+		return false;
+
+	if (end > pool_end) {
+		WARN(1, "freeing wrong coherent size from pool\n");
+		return false;
+	}
+
+	return true;
+}
+
 static int __free_from_pool(void *start, size_t size)
 {
 	struct dma_pool *pool = &atomic_pool;
 	unsigned long pageno, count;
 	unsigned long flags;
 
-	if (start < pool->vaddr || start > pool->vaddr + pool->size)
-		return 0;
-
-	if (start + size > pool->vaddr + pool->size) {
-		WARN(1, "freeing wrong coherent size from pool\n");
+	if (!__in_atomic_pool(start, size))
 		return 0;
-	}
 
 	pageno = (start - pool->vaddr) >> PAGE_SHIFT;
 	count = size >> PAGE_SHIFT;
-- 
1.7.5.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx156.postini.com [74.125.245.156])
	by kanga.kvack.org (Postfix) with SMTP id 1C93A6B0062
	for <linux-mm@kvack.org>; Tue,  5 Jun 2012 03:15:58 -0400 (EDT)
From: Minchan Kim <minchan@kernel.org>
Subject: [PATCH] [RESEND] ARM: use common utility function in dma
Date: Tue,  5 Jun 2012 16:16:18 +0900
Message-Id: <1338880578-19242-1-git-send-email-minchan@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Russell King <linux@arm.linux.org.uk>
Cc: linux-arm-kernel@lists.infradead.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Minchan Kim <minchan@kernel.org>

mm provides alloc_pages_exact so use it instead of open coded hack.

Cc: Russell King <linux@arm.linux.org.uk>
Signed-off-by: Minchan Kim <minchan@kernel.org>
---
It's against next-20120604.

 arch/arm/mm/dma-mapping.c |   23 +++++------------------
 1 file changed, 5 insertions(+), 18 deletions(-)

diff --git a/arch/arm/mm/dma-mapping.c b/arch/arm/mm/dma-mapping.c
index 106c4c0..86e3084 100644
--- a/arch/arm/mm/dma-mapping.c
+++ b/arch/arm/mm/dma-mapping.c
@@ -184,20 +184,12 @@ static void __dma_clear_buffer(struct page *page, size_t size)
  */
 static struct page *__dma_alloc_buffer(struct device *dev, size_t size, gfp_t gfp)
 {
-	unsigned long order = get_order(size);
-	struct page *page, *p, *e;
-
-	page = alloc_pages(gfp, order);
-	if (!page)
+	struct page *page;
+	void *addr = alloc_pages_exact(size, gfp);
+	if (!addr)
 		return NULL;
 
-	/*
-	 * Now split the huge page and free the excess pages
-	 */
-	split_page(page, order);
-	for (p = page + (size >> PAGE_SHIFT), e = page + (1 << order); p < e; p++)
-		__free_page(p);
-
+	page = virt_to_page(addr);
 	__dma_clear_buffer(page, size);
 
 	return page;
@@ -208,12 +200,7 @@ static struct page *__dma_alloc_buffer(struct device *dev, size_t size, gfp_t gf
  */
 static void __dma_free_buffer(struct page *page, size_t size)
 {
-	struct page *e = page + (size >> PAGE_SHIFT);
-
-	while (page < e) {
-		__free_page(page);
-		page++;
-	}
+	free_pages_exact(page_address(page), size);
 }
 
 #ifdef CONFIG_MMU
-- 
1.7.9.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx173.postini.com [74.125.245.173])
	by kanga.kvack.org (Postfix) with SMTP id 611256B0006
	for <linux-mm@kvack.org>; Tue, 26 Mar 2013 18:33:56 -0400 (EDT)
Received: from localhost (localhost [127.0.0.1])
	by mail.8bytes.org (Postfix) with SMTP id E222512AFA1
	for <linux-mm@kvack.org>; Tue, 26 Mar 2013 23:33:54 +0100 (CET)
From: Joerg Roedel <joro@8bytes.org>
Subject: [PATCH] staging: zsmalloc: Fix link error on ARM
Date: Tue, 26 Mar 2013 23:33:52 +0100
Message-Id: <1364337232-3513-1-git-send-email-joro@8bytes.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Cc: devel@driverdev.osuosl.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Joerg Roedel <joro@8bytes.org>

Testing the arm chromebook config against the upstream
kernel produces a linker error for the zsmalloc module from
staging. The symbol flush_tlb_kernel_range is not available
there. Fix this by removing the reimplementation of
unmap_kernel_range in the zsmalloc module and using the
function directly.

Signed-off-by: Joerg Roedel <joro@8bytes.org>
---
 drivers/staging/zsmalloc/zsmalloc-main.c |    5 +----
 mm/vmalloc.c                             |    1 +
 2 files changed, 2 insertions(+), 4 deletions(-)

diff --git a/drivers/staging/zsmalloc/zsmalloc-main.c b/drivers/staging/zsmalloc/zsmalloc-main.c
index e78d262..324e123 100644
--- a/drivers/staging/zsmalloc/zsmalloc-main.c
+++ b/drivers/staging/zsmalloc/zsmalloc-main.c
@@ -656,11 +656,8 @@ static inline void __zs_unmap_object(struct mapping_area *area,
 				struct page *pages[2], int off, int size)
 {
 	unsigned long addr = (unsigned long)area->vm_addr;
-	unsigned long end = addr + (PAGE_SIZE * 2);
 
-	flush_cache_vunmap(addr, end);
-	unmap_kernel_range_noflush(addr, PAGE_SIZE * 2);
-	flush_tlb_kernel_range(addr, end);
+	unmap_kernel_range(addr, PAGE_SIZE * 2);
 }
 
 #else /* USE_PGTABLE_MAPPING */
diff --git a/mm/vmalloc.c b/mm/vmalloc.c
index 0f751f2..f7cba11 100644
--- a/mm/vmalloc.c
+++ b/mm/vmalloc.c
@@ -1266,6 +1266,7 @@ void unmap_kernel_range(unsigned long addr, unsigned long size)
 	vunmap_page_range(addr, end);
 	flush_tlb_kernel_range(addr, end);
 }
+EXPORT_SYMBOL_GPL(unmap_kernel_range);
 
 int map_vm_area(struct vm_struct *area, pgprot_t prot, struct page ***pages)
 {
-- 
1.7.9.5


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

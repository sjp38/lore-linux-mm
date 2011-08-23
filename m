Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id 2D1166B016A
	for <linux-mm@kvack.org>; Tue, 23 Aug 2011 03:04:53 -0400 (EDT)
From: Sonic Zhang <sonic.adi@gmail.com>
Subject: [PATCH] mm:page.h: Calculate virt_to_page and page_to_virt via predefined macro.
Date: Tue, 23 Aug 2011 14:58:26 +0800
Message-ID: <1314082706-11352-1-git-send-email-sonic.adi@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>
Cc: uclinux-dist-devel@blackfin.uclinux.org, Sonic Zhang <sonic.zhang@analog.com>

From: Sonic Zhang <sonic.zhang@analog.com>

In NOMMU architecture, if physical memory doesn't start from 0, ARCH_PFN_OFFSET is defined
to generate page index in mem_map array. Because virtual address is equal to physical
address, PAGE_OFFSET is always 0. virt_to_page and page_to_virt should not index page by
PAGE_OFFSET directly.

Signed-off-by: Sonic Zhang <sonic.zhang@analog.com>
---
 include/asm-generic/page.h |    5 +++++
 1 files changed, 5 insertions(+), 0 deletions(-)

diff --git a/include/asm-generic/page.h b/include/asm-generic/page.h
index 75fec18..96a1dc3 100644
--- a/include/asm-generic/page.h
+++ b/include/asm-generic/page.h
@@ -79,8 +79,13 @@ extern unsigned long memory_end;
 #define virt_to_pfn(kaddr)	(__pa(kaddr) >> PAGE_SHIFT)
 #define pfn_to_virt(pfn)	__va((pfn) << PAGE_SHIFT)
 
+#if 0
 #define virt_to_page(addr)	(mem_map + (((unsigned long)(addr)-PAGE_OFFSET) >> PAGE_SHIFT))
 #define page_to_virt(page)	((((page) - mem_map) << PAGE_SHIFT) + PAGE_OFFSET)
+#endif
+#define virt_to_page(addr)      pfn_to_page(virt_to_pfn(addr))
+#define page_to_virt(page)      pfn_to_virt(page_to_pfn(page))
+
 
 #ifndef page_to_phys
 #define page_to_phys(page)      ((dma_addr_t)page_to_pfn(page) << PAGE_SHIFT)
-- 
1.7.0.4


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

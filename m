Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with ESMTP id 86F3F8D003A
	for <linux-mm@kvack.org>; Thu, 20 Jan 2011 05:04:08 -0500 (EST)
From: KyongHo Cho <pullip.cho@samsung.com>
Subject: [PATCH] ARM: mm: Regarding section when dealing with meminfo
Date: Thu, 20 Jan 2011 18:45:39 +0900
Message-Id: <1295516739-9839-1-git-send-email-pullip.cho@samsung.com>
Sender: owner-linux-mm@kvack.org
To: linux-arm-kernel@lists.infradead.org, linux-mm@kvack.org
Cc: linux-kernel@vger.kernel.org, linux-samsung-soc@vger.kernel.org, Kukjin Kim <kgene.kim@samsung.com>, Ilho Lee <ilho215.lee@samsung.com>, KeyYoung Park <keyyoung.park@samsung.com>, KyongHo Cho <pullip.cho@samsung.com>
List-ID: <linux-mm.kvack.org>

Sparsemem allows that a bank of memory spans over several adjacent
sections if the start address and the end address of the bank
belong to different sections.
When gathering statictics of physical memory in mem_init() and
show_mem(), this possiblity was not considered.

This patch guarantees that simple increasing the pointer to page
descriptors does not exceed the boundary of a section.

Signed-off-by: KyongHo Cho <pullip.cho@samsung.com>
---
 arch/arm/mm/init.c |   74 +++++++++++++++++++++++++++++++++++----------------
 1 files changed, 51 insertions(+), 23 deletions(-)

diff --git a/arch/arm/mm/init.c b/arch/arm/mm/init.c
index 57c4c5c..6ccecbe 100644
--- a/arch/arm/mm/init.c
+++ b/arch/arm/mm/init.c
@@ -93,24 +93,38 @@ void show_mem(void)
 
 		pfn1 = bank_pfn_start(bank);
 		pfn2 = bank_pfn_end(bank);
-
+#ifndef CONFIG_SPARSEMEM
 		page = pfn_to_page(pfn1);
 		end  = pfn_to_page(pfn2 - 1) + 1;
-
+#else
+		pfn2--;
 		do {
-			total++;
-			if (PageReserved(page))
-				reserved++;
-			else if (PageSwapCache(page))
-				cached++;
-			else if (PageSlab(page))
-				slab++;
-			else if (!page_count(page))
-				free++;
-			else
-				shared += page_count(page) - 1;
-			page++;
-		} while (page < end);
+			page = pfn_to_page(pfn1);
+			if (pfn_to_section_nr(pfn1) < pfn_to_section_nr(pfn2)) {
+				pfn1 += PAGES_PER_SECTION;
+				pfn1 &= PAGE_SECTION_MASK;
+			} else {
+				pfn1 = pfn2;
+			}
+			end = pfn_to_page(pfn1) + 1;
+#endif
+			do {
+				total++;
+				if (PageReserved(page))
+					reserved++;
+				else if (PageSwapCache(page))
+					cached++;
+				else if (PageSlab(page))
+					slab++;
+				else if (!page_count(page))
+					free++;
+				else
+					shared += page_count(page) - 1;
+				page++;
+			} while (page < end);
+#ifdef CONFIG_SPARSEMEM
+		} while (pfn1 < pfn2);
+#endif
 	}
 
 	printk("%d pages of RAM\n", total);
@@ -470,17 +484,31 @@ void __init mem_init(void)
 
 		pfn1 = bank_pfn_start(bank);
 		pfn2 = bank_pfn_end(bank);
-
+#ifndef CONFIG_SPARSEMEM
 		page = pfn_to_page(pfn1);
 		end  = pfn_to_page(pfn2 - 1) + 1;
-
+#else
+		pfn2--;
 		do {
-			if (PageReserved(page))
-				reserved_pages++;
-			else if (!page_count(page))
-				free_pages++;
-			page++;
-		} while (page < end);
+			page = pfn_to_page(pfn1);
+			if (pfn_to_section_nr(pfn1) < pfn_to_section_nr(pfn2)) {
+				pfn1 += PAGES_PER_SECTION;
+				pfn1 &= PAGE_SECTION_MASK;
+			} else {
+				pfn1 = pfn2;
+			}
+			end = pfn_to_page(pfn1) + 1;
+#endif
+			do {
+				if (PageReserved(page))
+					reserved_pages++;
+				else if (!page_count(page))
+					free_pages++;
+				page++;
+			} while (page < end);
+#ifdef CONFIG_SPARSEMEM
+		} while (pfn1 < pfn2);
+#endif
 	}
 
 	/*
-- 
1.6.2.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

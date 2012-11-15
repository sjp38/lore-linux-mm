Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx127.postini.com [74.125.245.127])
	by kanga.kvack.org (Postfix) with SMTP id 382176B006C
	for <linux-mm@kvack.org>; Thu, 15 Nov 2012 16:43:01 -0500 (EST)
From: Will Deacon <will.deacon@arm.com>
Subject: [PATCH] mm: highmem: don't treat PKMAP_ADDR(LAST_PKMAP) as a highmem address
Date: Thu, 15 Nov 2012 21:42:50 +0000
Message-Id: <1353015770-23810-1-git-send-email-will.deacon@arm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: Will Deacon <will.deacon@arm.com>, Mel Gorman <mgorman@suse.de>, Andrew Morton <akpm@linux-foundation.org>

kmap_to_page returns the corresponding struct page for a virtual address
of an arbitrary mapping. This works by checking whether the address
falls in the pkmap region and using the pkmap page tables instead of the
linear mapping if appropriate.

Unfortunately, the bounds checking means that PKMAP_ADDR(LAST_PKMAP) is
incorrectly treated as a highmem address and we can end up walking off
the end of pkmap_page_table and subsequently passing junk to pte_page.

This patch fixes the bound check to stay within the pkmap tables.

Cc: Mel Gorman <mgorman@suse.de>
Cc: Andrew Morton <akpm@linux-foundation.org>
Signed-off-by: Will Deacon <will.deacon@arm.com>
---
 mm/highmem.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/mm/highmem.c b/mm/highmem.c
index d517cd1..2da13a5 100644
--- a/mm/highmem.c
+++ b/mm/highmem.c
@@ -98,7 +98,7 @@ struct page *kmap_to_page(void *vaddr)
 {
 	unsigned long addr = (unsigned long)vaddr;
 
-	if (addr >= PKMAP_ADDR(0) && addr <= PKMAP_ADDR(LAST_PKMAP)) {
+	if (addr >= PKMAP_ADDR(0) && addr < PKMAP_ADDR(LAST_PKMAP)) {
 		int i = (addr - PKMAP_ADDR(0)) >> PAGE_SHIFT;
 		return pte_page(pkmap_page_table[i]);
 	}
-- 
1.7.4.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

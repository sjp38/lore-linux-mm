Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id 043476B00A9
	for <linux-mm@kvack.org>; Wed, 15 Dec 2010 17:28:03 -0500 (EST)
From: Jeremy Fitzhardinge <jeremy@goop.org>
Subject: [PATCH 7/9] vmalloc: use apply_to_page_range_batch() in alloc_vm_area()
Date: Wed, 15 Dec 2010 14:19:53 -0800
Message-Id: <cd5ee25e08c2b503750513b142f39920473f05a6.1292450600.git.jeremy.fitzhardinge@citrix.com>
In-Reply-To: <cover.1292450600.git.jeremy.fitzhardinge@citrix.com>
References: <cover.1292450600.git.jeremy.fitzhardinge@citrix.com>
In-Reply-To: <cover.1292450600.git.jeremy.fitzhardinge@citrix.com>
References: <cover.1292450600.git.jeremy.fitzhardinge@citrix.com>
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Haavard Skinnemoen <hskinnemoen@atmel.com>, Linux-MM <linux-mm@kvack.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Nick Piggin <npiggin@kernel.dk>, Xen-devel <xen-devel@lists.xensource.com>, Jeremy Fitzhardinge <jeremy.fitzhardinge@citrix.com>
List-ID: <linux-mm.kvack.org>

From: Jeremy Fitzhardinge <jeremy.fitzhardinge@citrix.com>

Signed-off-by: Jeremy Fitzhardinge <jeremy.fitzhardinge@citrix.com>
---
 mm/vmalloc.c |    8 ++++----
 1 files changed, 4 insertions(+), 4 deletions(-)

diff --git a/mm/vmalloc.c b/mm/vmalloc.c
index 0e845bb..a1ecf33 100644
--- a/mm/vmalloc.c
+++ b/mm/vmalloc.c
@@ -1991,9 +1991,9 @@ void  __attribute__((weak)) vmalloc_sync_all(void)
 }
 
 
-static int f(pte_t *pte, unsigned long addr, void *data)
+static int f(pte_t *pte, unsigned count, unsigned long addr, void *data)
 {
-	/* apply_to_page_range() does all the hard work. */
+	/* apply_to_page_range_batch() does all the hard work. */
 	return 0;
 }
 
@@ -2022,8 +2022,8 @@ struct vm_struct *alloc_vm_area(size_t size)
 	 * This ensures that page tables are constructed for this region
 	 * of kernel virtual address space and mapped into init_mm.
 	 */
-	if (apply_to_page_range(&init_mm, (unsigned long)area->addr,
-				area->size, f, NULL)) {
+	if (apply_to_page_range_batch(&init_mm, (unsigned long)area->addr,
+				      area->size, f, NULL)) {
 		free_vm_area(area);
 		return NULL;
 	}
-- 
1.7.3.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

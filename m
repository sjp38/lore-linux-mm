Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with ESMTP id A19146B00E8
	for <linux-mm@kvack.org>; Mon, 24 Jan 2011 18:06:23 -0500 (EST)
From: Jeremy Fitzhardinge <jeremy@goop.org>
Subject: [PATCH 1/9] mm: remove unused "token" argument from apply_to_page_range callback.
Date: Mon, 24 Jan 2011 14:55:59 -0800
Message-Id: <81ec0e742ce919124909640039c05baa29b1568a.1295653400.git.jeremy.fitzhardinge@citrix.com>
In-Reply-To: <cover.1295653400.git.jeremy.fitzhardinge@citrix.com>
References: <cover.1295653400.git.jeremy.fitzhardinge@citrix.com>
In-Reply-To: <cover.1295653400.git.jeremy.fitzhardinge@citrix.com>
References: <cover.1295653400.git.jeremy.fitzhardinge@citrix.com>
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Haavard Skinnemoen <hskinnemoen@atmel.com>, Linux-MM <linux-mm@kvack.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Nick Piggin <npiggin@kernel.dk>, Xen-devel <xen-devel@lists.xensource.com>, Jeremy Fitzhardinge <jeremy.fitzhardinge@citrix.com>
List-ID: <linux-mm.kvack.org>

From: Jeremy Fitzhardinge <jeremy.fitzhardinge@citrix.com>

The argument is basically the struct page of the pte_t * passed into
the callback.  But there's no need to pass that, since it can be fairly
easily derived from the pte_t * itself if needed (and no current users
need to do that anyway).

Signed-off-by: Jeremy Fitzhardinge <jeremy.fitzhardinge@citrix.com>
---
 arch/x86/xen/grant-table.c |    6 ++----
 arch/x86/xen/mmu.c         |    3 +--
 include/linux/mm.h         |    3 +--
 mm/memory.c                |    2 +-
 mm/vmalloc.c               |    2 +-
 5 files changed, 6 insertions(+), 10 deletions(-)

diff --git a/arch/x86/xen/grant-table.c b/arch/x86/xen/grant-table.c
index 49ba9b5..5bf892a 100644
--- a/arch/x86/xen/grant-table.c
+++ b/arch/x86/xen/grant-table.c
@@ -44,8 +44,7 @@
 
 #include <asm/pgtable.h>
 
-static int map_pte_fn(pte_t *pte, struct page *pmd_page,
-		      unsigned long addr, void *data)
+static int map_pte_fn(pte_t *pte, unsigned long addr, void *data)
 {
 	unsigned long **frames = (unsigned long **)data;
 
@@ -54,8 +53,7 @@ static int map_pte_fn(pte_t *pte, struct page *pmd_page,
 	return 0;
 }
 
-static int unmap_pte_fn(pte_t *pte, struct page *pmd_page,
-			unsigned long addr, void *data)
+static int unmap_pte_fn(pte_t *pte, unsigned long addr, void *data)
 {
 
 	set_pte_at(&init_mm, addr, pte, __pte(0));
diff --git a/arch/x86/xen/mmu.c b/arch/x86/xen/mmu.c
index 5e92b61..38ba804 100644
--- a/arch/x86/xen/mmu.c
+++ b/arch/x86/xen/mmu.c
@@ -2292,8 +2292,7 @@ struct remap_data {
 	struct mmu_update *mmu_update;
 };
 
-static int remap_area_mfn_pte_fn(pte_t *ptep, pgtable_t token,
-				 unsigned long addr, void *data)
+static int remap_area_mfn_pte_fn(pte_t *ptep, unsigned long addr, void *data)
 {
 	struct remap_data *rmd = data;
 	pte_t pte = pte_mkspecial(pfn_pte(rmd->mfn++, rmd->prot));
diff --git a/include/linux/mm.h b/include/linux/mm.h
index 956a355..bb898ec 100644
--- a/include/linux/mm.h
+++ b/include/linux/mm.h
@@ -1529,8 +1529,7 @@ struct page *follow_page(struct vm_area_struct *, unsigned long address,
 #define FOLL_MLOCK	0x40	/* mark page as mlocked */
 #define FOLL_SPLIT	0x80	/* don't return transhuge pages, split them */
 
-typedef int (*pte_fn_t)(pte_t *pte, pgtable_t token, unsigned long addr,
-			void *data);
+typedef int (*pte_fn_t)(pte_t *pte, unsigned long addr, void *data);
 extern int apply_to_page_range(struct mm_struct *mm, unsigned long address,
 			       unsigned long size, pte_fn_t fn, void *data);
 
diff --git a/mm/memory.c b/mm/memory.c
index 31250fa..740470c 100644
--- a/mm/memory.c
+++ b/mm/memory.c
@@ -2032,7 +2032,7 @@ static int apply_to_pte_range(struct mm_struct *mm, pmd_t *pmd,
 	token = pmd_pgtable(*pmd);
 
 	do {
-		err = fn(pte++, token, addr, data);
+		err = fn(pte++, addr, data);
 		if (err)
 			break;
 	} while (addr += PAGE_SIZE, addr != end);
diff --git a/mm/vmalloc.c b/mm/vmalloc.c
index f9b1667..5ddbdfe 100644
--- a/mm/vmalloc.c
+++ b/mm/vmalloc.c
@@ -2061,7 +2061,7 @@ void  __attribute__((weak)) vmalloc_sync_all(void)
 }
 
 
-static int f(pte_t *pte, pgtable_t table, unsigned long addr, void *data)
+static int f(pte_t *pte, unsigned long addr, void *data)
 {
 	/* apply_to_page_range() does all the hard work. */
 	return 0;
-- 
1.7.3.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

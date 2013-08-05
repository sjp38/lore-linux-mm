Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx198.postini.com [74.125.245.198])
	by kanga.kvack.org (Postfix) with SMTP id 0FCEB6B0031
	for <linux-mm@kvack.org>; Sun,  4 Aug 2013 21:48:40 -0400 (EDT)
Received: from /spool/local
	by e28smtp08.in.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <liwanp@linux.vnet.ibm.com>;
	Mon, 5 Aug 2013 07:08:14 +0530
Received: from d28relay04.in.ibm.com (d28relay04.in.ibm.com [9.184.220.61])
	by d28dlp01.in.ibm.com (Postfix) with ESMTP id 8E77EE0053
	for <linux-mm@kvack.org>; Mon,  5 Aug 2013 07:18:45 +0530 (IST)
Received: from d28av05.in.ibm.com (d28av05.in.ibm.com [9.184.220.67])
	by d28relay04.in.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id r751mS5l39714820
	for <linux-mm@kvack.org>; Mon, 5 Aug 2013 07:18:29 +0530
Received: from d28av05.in.ibm.com (localhost [127.0.0.1])
	by d28av05.in.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id r751mVjg023691
	for <linux-mm@kvack.org>; Mon, 5 Aug 2013 07:18:31 +0530
Date: Mon, 5 Aug 2013 09:48:29 +0800
From: Wanpeng Li <liwanp@linux.vnet.ibm.com>
Subject: Re: [patch 1/2] [PATCH] mm: Save soft-dirty bits on swapped pages
Message-ID: <20130805014829.GA13702@hacker.(null)>
Reply-To: Wanpeng Li <liwanp@linux.vnet.ibm.com>
References: <20130730204154.407090410@gmail.com>
 <20130730204654.844299768@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20130730204654.844299768@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Cyrill Gorcunov <gorcunov@gmail.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, luto@amacapital.net, gorcunov@openvz.org, xemul@parallels.com, akpm@linux-foundation.org, mpm@selenic.com, xiaoguangrong@linux.vnet.ibm.com, mtosatti@redhat.com, kosaki.motohiro@gmail.com, sfr@canb.auug.org.au, peterz@infradead.org, aneesh.kumar@linux.vnet.ibm.com

On Wed, Jul 31, 2013 at 12:41:55AM +0400, Cyrill Gorcunov wrote:
>Andy Lutomirski reported that in case if a page with _PAGE_SOFT_DIRTY
>bit set get swapped out, the bit is getting lost and no longer
>available when pte read back.
>
>To resolve this we introduce _PTE_SWP_SOFT_DIRTY bit which is
>saved in pte entry for the page being swapped out. When such page
>is to be read back from a swap cache we check for bit presence
>and if it's there we clear it and restore the former _PAGE_SOFT_DIRTY
>bit back.
>
>One of the problem was to find a place in pte entry where we can
>save the _PTE_SWP_SOFT_DIRTY bit while page is in swap. The
>_PAGE_PSE was chosen for that, it doesn't intersect with swap
>entry format stored in pte.
>
>Reported-by: Andy Lutomirski <luto@amacapital.net>
>Signed-off-by: Cyrill Gorcunov <gorcunov@openvz.org>
>Cc: Pavel Emelyanov <xemul@parallels.com>
>Cc: Andrew Morton <akpm@linux-foundation.org>
>Cc: Matt Mackall <mpm@selenic.com>
>Cc: Xiao Guangrong <xiaoguangrong@linux.vnet.ibm.com>
>Cc: Marcelo Tosatti <mtosatti@redhat.com>
>Cc: KOSAKI Motohiro <kosaki.motohiro@gmail.com>
>Cc: Stephen Rothwell <sfr@canb.auug.org.au>
>Cc: Peter Zijlstra <peterz@infradead.org>
>Cc: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
>---
> arch/x86/include/asm/pgtable.h       |   15 +++++++++++++++
> arch/x86/include/asm/pgtable_types.h |   13 +++++++++++++
> fs/proc/task_mmu.c                   |   21 +++++++++++++++------
> include/asm-generic/pgtable.h        |   15 +++++++++++++++
> include/linux/swapops.h              |    2 ++
> mm/memory.c                          |    2 ++
> mm/rmap.c                            |    6 +++++-
> mm/swapfile.c                        |   19 +++++++++++++++++--
> 8 files changed, 84 insertions(+), 9 deletions(-)
>
>Index: linux-2.6.git/arch/x86/include/asm/pgtable.h
>===================================================================
>--- linux-2.6.git.orig/arch/x86/include/asm/pgtable.h
>+++ linux-2.6.git/arch/x86/include/asm/pgtable.h
>@@ -314,6 +314,21 @@ static inline pmd_t pmd_mksoft_dirty(pmd
> 	return pmd_set_flags(pmd, _PAGE_SOFT_DIRTY);
> }
>
>+static inline pte_t pte_swp_mksoft_dirty(pte_t pte)
>+{
>+	return pte_set_flags(pte, _PAGE_SWP_SOFT_DIRTY);
>+}
>+
>+static inline int pte_swp_soft_dirty(pte_t pte)
>+{
>+	return pte_flags(pte) & _PAGE_SWP_SOFT_DIRTY;
>+}
>+
>+static inline pte_t pte_swp_clear_soft_dirty(pte_t pte)
>+{
>+	return pte_clear_flags(pte, _PAGE_SWP_SOFT_DIRTY);
>+}
>+
> /*
>  * Mask out unsupported bits in a present pgprot.  Non-present pgprots
>  * can use those bits for other purposes, so leave them be.
>Index: linux-2.6.git/arch/x86/include/asm/pgtable_types.h
>===================================================================
>--- linux-2.6.git.orig/arch/x86/include/asm/pgtable_types.h
>+++ linux-2.6.git/arch/x86/include/asm/pgtable_types.h
>@@ -67,6 +67,19 @@
> #define _PAGE_SOFT_DIRTY	(_AT(pteval_t, 0))
> #endif
>
>+/*
>+ * Tracking soft dirty bit when a page goes to a swap is tricky.
>+ * We need a bit which can be stored in pte _and_ not conflict
>+ * with swap entry format. On x86 bits 6 and 7 are *not* involved
>+ * into swap entry computation, but bit 6 is used for nonlinear
>+ * file mapping, so we borrow bit 7 for soft dirty tracking.
>+ */
>+#ifdef CONFIG_MEM_SOFT_DIRTY
>+#define _PAGE_SWP_SOFT_DIRTY	_PAGE_PSE
>+#else
>+#define _PAGE_SWP_SOFT_DIRTY	(_AT(pteval_t, 0))
>+#endif
>+
> #if defined(CONFIG_X86_64) || defined(CONFIG_X86_PAE)
> #define _PAGE_NX	(_AT(pteval_t, 1) << _PAGE_BIT_NX)
> #else
>Index: linux-2.6.git/fs/proc/task_mmu.c
>===================================================================
>--- linux-2.6.git.orig/fs/proc/task_mmu.c
>+++ linux-2.6.git/fs/proc/task_mmu.c
>@@ -730,8 +730,14 @@ static inline void clear_soft_dirty(stru
> 	 * of how soft-dirty works.
> 	 */
> 	pte_t ptent = *pte;
>-	ptent = pte_wrprotect(ptent);
>-	ptent = pte_clear_flags(ptent, _PAGE_SOFT_DIRTY);
>+
>+	if (pte_present(ptent)) {
>+		ptent = pte_wrprotect(ptent);
>+		ptent = pte_clear_flags(ptent, _PAGE_SOFT_DIRTY);
>+	} else if (is_swap_pte(ptent)) {
>+		ptent = pte_swp_clear_soft_dirty(ptent);
>+	}
>+
> 	set_pte_at(vma->vm_mm, addr, pte, ptent);
> #endif
> }
>@@ -752,14 +758,15 @@ static int clear_refs_pte_range(pmd_t *p
> 	pte = pte_offset_map_lock(vma->vm_mm, pmd, addr, &ptl);
> 	for (; addr != end; pte++, addr += PAGE_SIZE) {
> 		ptent = *pte;
>-		if (!pte_present(ptent))
>-			continue;
>
> 		if (cp->type == CLEAR_REFS_SOFT_DIRTY) {
> 			clear_soft_dirty(vma, addr, pte);
> 			continue;
> 		}
>
>+		if (!pte_present(ptent))
>+			continue;
>+
> 		page = vm_normal_page(vma, addr, ptent);
> 		if (!page)
> 			continue;
>@@ -930,8 +937,10 @@ static void pte_to_pagemap_entry(pagemap
> 		flags = PM_PRESENT;
> 		page = vm_normal_page(vma, addr, pte);
> 	} else if (is_swap_pte(pte)) {
>-		swp_entry_t entry = pte_to_swp_entry(pte);
>-
>+		swp_entry_t entry;
>+		if (pte_swp_soft_dirty(pte))
>+			flags2 |= __PM_SOFT_DIRTY;
>+		entry = pte_to_swp_entry(pte);
> 		frame = swp_type(entry) |
> 			(swp_offset(entry) << MAX_SWAPFILES_SHIFT);
> 		flags = PM_SWAP;
>Index: linux-2.6.git/include/asm-generic/pgtable.h
>===================================================================
>--- linux-2.6.git.orig/include/asm-generic/pgtable.h
>+++ linux-2.6.git/include/asm-generic/pgtable.h
>@@ -417,6 +417,21 @@ static inline pmd_t pmd_mksoft_dirty(pmd
> {
> 	return pmd;
> }
>+
>+static inline pte_t pte_swp_mksoft_dirty(pte_t pte)
>+{
>+	return pte;
>+}
>+
>+static inline int pte_swp_soft_dirty(pte_t pte)
>+{
>+	return 0;
>+}
>+
>+static inline pte_t pte_swp_clear_soft_dirty(pte_t pte)
>+{
>+	return pte;
>+}
> #endif
>
> #ifndef __HAVE_PFNMAP_TRACKING
>Index: linux-2.6.git/include/linux/swapops.h
>===================================================================
>--- linux-2.6.git.orig/include/linux/swapops.h
>+++ linux-2.6.git/include/linux/swapops.h
>@@ -67,6 +67,8 @@ static inline swp_entry_t pte_to_swp_ent
> 	swp_entry_t arch_entry;
>
> 	BUG_ON(pte_file(pte));
>+	if (pte_swp_soft_dirty(pte))
>+		pte = pte_swp_clear_soft_dirty(pte);
> 	arch_entry = __pte_to_swp_entry(pte);
> 	return swp_entry(__swp_type(arch_entry), __swp_offset(arch_entry));
> }
>Index: linux-2.6.git/mm/memory.c
>===================================================================
>--- linux-2.6.git.orig/mm/memory.c
>+++ linux-2.6.git/mm/memory.c
>@@ -3115,6 +3115,8 @@ static int do_swap_page(struct mm_struct
> 		exclusive = 1;
> 	}
> 	flush_icache_page(vma, page);
>+	if (pte_swp_soft_dirty(orig_pte))
>+		pte = pte_mksoft_dirty(pte);

entry = pte_to_swp_entry(orig_pte);
orig_pte's _PTE_SWP_SOFT_DIRTY bit has already been cleared. 

> 	set_pte_at(mm, address, page_table, pte);
> 	if (page == swapcache)
> 		do_page_add_anon_rmap(page, vma, address, exclusive);
>Index: linux-2.6.git/mm/rmap.c
>===================================================================
>--- linux-2.6.git.orig/mm/rmap.c
>+++ linux-2.6.git/mm/rmap.c
>@@ -1236,6 +1236,7 @@ int try_to_unmap_one(struct page *page,
> 			   swp_entry_to_pte(make_hwpoison_entry(page)));
> 	} else if (PageAnon(page)) {
> 		swp_entry_t entry = { .val = page_private(page) };
>+		pte_t swp_pte;
>
> 		if (PageSwapCache(page)) {
> 			/*
>@@ -1264,7 +1265,10 @@ int try_to_unmap_one(struct page *page,
> 			BUG_ON(TTU_ACTION(flags) != TTU_MIGRATION);
> 			entry = make_migration_entry(page, pte_write(pteval));
> 		}
>-		set_pte_at(mm, address, pte, swp_entry_to_pte(entry));
>+		swp_pte = swp_entry_to_pte(entry);
>+		if (pte_soft_dirty(pteval))
>+			swp_pte = pte_swp_mksoft_dirty(swp_pte);
>+		set_pte_at(mm, address, pte, swp_pte);
> 		BUG_ON(pte_file(*pte));
> 	} else if (IS_ENABLED(CONFIG_MIGRATION) &&
> 		   (TTU_ACTION(flags) == TTU_MIGRATION)) {
>Index: linux-2.6.git/mm/swapfile.c
>===================================================================
>--- linux-2.6.git.orig/mm/swapfile.c
>+++ linux-2.6.git/mm/swapfile.c
>@@ -866,6 +866,21 @@ unsigned int count_swap_pages(int type,
> }
> #endif /* CONFIG_HIBERNATION */
>
>+static inline int maybe_same_pte(pte_t pte, pte_t swp_pte)
>+{
>+#ifdef CONFIG_MEM_SOFT_DIRTY
>+	/*
>+	 * When pte keeps soft dirty bit the pte generated
>+	 * from swap entry does not has it, still it's same
>+	 * pte from logical point of view.
>+	 */
>+	pte_t swp_pte_dirty = pte_swp_mksoft_dirty(swp_pte);
>+	return pte_same(pte, swp_pte) || pte_same(pte, swp_pte_dirty);
>+#else
>+	return pte_same(pte, swp_pte);
>+#endif
>+}
>+
> /*
>  * No need to decide whether this PTE shares the swap entry with others,
>  * just let do_wp_page work it out if a write is requested later - to
>@@ -892,7 +907,7 @@ static int unuse_pte(struct vm_area_stru
> 	}
>
> 	pte = pte_offset_map_lock(vma->vm_mm, pmd, addr, &ptl);
>-	if (unlikely(!pte_same(*pte, swp_entry_to_pte(entry)))) {
>+	if (unlikely(!maybe_same_pte(*pte, swp_entry_to_pte(entry)))) {
> 		mem_cgroup_cancel_charge_swapin(memcg);
> 		ret = 0;
> 		goto out;
>@@ -947,7 +962,7 @@ static int unuse_pte_range(struct vm_are
> 		 * swapoff spends a _lot_ of time in this loop!
> 		 * Test inline before going to call unuse_pte.
> 		 */
>-		if (unlikely(pte_same(*pte, swp_pte))) {
>+		if (unlikely(maybe_same_pte(*pte, swp_pte))) {
> 			pte_unmap(pte);
> 			ret = unuse_pte(vma, pmd, addr, entry, page);
> 			if (ret)
>
>--
>To unsubscribe, send a message with 'unsubscribe linux-mm' in
>the body to majordomo@kvack.org.  For more info on Linux MM,
>see: http://www.linux-mm.org/ .
>Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

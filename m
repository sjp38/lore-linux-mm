Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pb0-f46.google.com (mail-pb0-f46.google.com [209.85.160.46])
	by kanga.kvack.org (Postfix) with ESMTP id 5D1C46B0031
	for <linux-mm@kvack.org>; Mon, 14 Oct 2013 04:08:46 -0400 (EDT)
Received: by mail-pb0-f46.google.com with SMTP id rq2so6986426pbb.19
        for <linux-mm@kvack.org>; Mon, 14 Oct 2013 01:08:46 -0700 (PDT)
Date: Mon, 14 Oct 2013 10:12:05 +0300
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: Re: CONFIG_SLUB/USE_SPLIT_PTLOCKS compatibility
Message-ID: <20131014071205.GA23735@shutemov.name>
References: <CAMo8BfKqWPbDCMwCoH6BO6uXyYwr0Z1=AaMJDRLQt66FLb7LAg@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAMo8BfKqWPbDCMwCoH6BO6uXyYwr0Z1=AaMJDRLQt66FLb7LAg@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Max Filippov <jcmvbkbc@gmail.com>
Cc: LKML <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Christoph Lameter <cl@linux-foundation.org>, Pekka Enberg <penberg@kernel.org>, Matt Mackall <mpm@selenic.com>, "David S. Miller" <davem@davemloft.net>

On Mon, Oct 14, 2013 at 01:12:47AM +0400, Max Filippov wrote:
> Hello,
> 
> I'm reliably getting kernel crash on xtensa when CONFIG_SLUB
> is selected and USE_SPLIT_PTLOCKS appears to be true (SMP=y,
> NR_CPUS=4, DEBUG_SPINLOCK=n, DEBUG_LOCK_ALLOC=n).
> This happens because spinlock_t ptl and struct page *first_page overlap
> in the struct page. The following call chain makes allocation of order
> 3 and initializes first_page pointer in its 7 tail pages:
> 
>  do_page_fault
>   handle_mm_fault
>    __pte_alloc
>     kmem_cache_alloc
>      __slab_alloc
>       new_slab
>        __alloc_pages_nodemask
>         get_page_from_freelist
>          prep_compound_page
> 
> Later pte_offset_map_lock is called with one of these tail pages
> overwriting its first_page pointer:
> 
>  do_fork
>   copy_process
>    dup_mm
>     copy_page_range
>      copy_pte_range
>       pte_alloc_map_lock
>        pte_offset_map_lock
> 
> Finally kmem_cache_free is called for that tail page, which calls
> slab_free(s, virt_to_head_page(x),... but virt_to_head_page here
> returns NULL, because the page's first_page pointer was overwritten
> earlier:
> 
> exit_mmap
>  free_pgtables
>   free_pgd_range
>    free_pud_range
>     free_pmd_range
>      free_pte_range
>       pte_free
>        kmem_cache_free
>         slab_free
>          __slab_free
> 
> __slab_free touches NULL struct page, that's it.
> 
> Changing allocator to SLAB or enabling DEBUG_SPINLOCK
> fixes that crash.
> 
> My question is, is CONFIG_SLUB supposed to work with
> USE_SPLIT_PTLOCKS (and if yes what's wrong in my case)?

Sure, CONFIG_SLUB && USE_SPLIT_PTLOCKS works fine. Unless you try use slab
to allocate pagetable.

Note: no other arch allocates PTE page tables from slab.
Some archs (sparc, power) uses slabs to allocate hihger page tables, but
not PTE. [ And these archs will have to avoid slab, if they wants to
support split ptl for PMD tables. ]

I don't see much sense in having separate slab for allocting PAGE_SIZE
objects aligned to PAGE_SIZE. What's wrong with plain buddy allocator?

Completely untested patch to use buddy allocator instead of slub for page
table allocation on xtensa is below. Please, try.

diff --git a/arch/xtensa/include/asm/pgalloc.h b/arch/xtensa/include/asm/pgalloc.h
index b8774f1e21..8e27d4200e 100644
--- a/arch/xtensa/include/asm/pgalloc.h
+++ b/arch/xtensa/include/asm/pgalloc.h
@@ -38,14 +38,16 @@ static inline void pgd_free(struct mm_struct *mm, pgd_t *pgd)
 	free_page((unsigned long)pgd);
 }
 
-/* Use a slab cache for the pte pages (see also sparc64 implementation) */
-
-extern struct kmem_cache *pgtable_cache;
-
 static inline pte_t *pte_alloc_one_kernel(struct mm_struct *mm,
 					 unsigned long address)
 {
-	return kmem_cache_alloc(pgtable_cache, GFP_KERNEL|__GFP_REPEAT);
+	pte_t *ptep;
+
+	ptep = (pte_t *)__get_free_page(GFP_KERNEL|__GFP_REPEAT);
+	if (!ptep)
+		return NULL;
+	for (i = 0; i < 1024; i++, ptep++)
+		pte_clear(NULL, 0, ptep);
 }
 
 static inline pgtable_t pte_alloc_one(struct mm_struct *mm,
@@ -59,7 +61,7 @@ static inline pgtable_t pte_alloc_one(struct mm_struct *mm,
 		return NULL;
 	page = virt_to_page(pte);
 	if (!pgtable_page_ctor(page)) {
-		kmem_cache_free(pgtable_cache, pte);
+		__free_page(page);
 		return NULL;
 	}
 	return page;
@@ -67,13 +69,13 @@ static inline pgtable_t pte_alloc_one(struct mm_struct *mm,
 
 static inline void pte_free_kernel(struct mm_struct *mm, pte_t *pte)
 {
-	kmem_cache_free(pgtable_cache, pte);
+	free_page((unsigned long)pte);
 }
 
 static inline void pte_free(struct mm_struct *mm, pgtable_t pte)
 {
 	pgtable_page_dtor(pte);
-	kmem_cache_free(pgtable_cache, page_address(pte));
+	__free_page(page);
 }
 #define pmd_pgtable(pmd) pmd_page(pmd)
 
diff --git a/arch/xtensa/include/asm/pgtable.h b/arch/xtensa/include/asm/pgtable.h
index 0fdf5d043f..216446295a 100644
--- a/arch/xtensa/include/asm/pgtable.h
+++ b/arch/xtensa/include/asm/pgtable.h
@@ -220,12 +220,11 @@ extern unsigned long empty_zero_page[1024];
 #ifdef CONFIG_MMU
 extern pgd_t swapper_pg_dir[PAGE_SIZE/sizeof(pgd_t)];
 extern void paging_init(void);
-extern void pgtable_cache_init(void);
 #else
 # define swapper_pg_dir NULL
 static inline void paging_init(void) { }
-static inline void pgtable_cache_init(void) { }
 #endif
+static inline void pgtable_cache_init(void) { }
 
 /*
  * The pmd contains the kernel virtual address of the pte page.
diff --git a/arch/xtensa/mm/mmu.c b/arch/xtensa/mm/mmu.c
index a1077570e3..c43771c974 100644
--- a/arch/xtensa/mm/mmu.c
+++ b/arch/xtensa/mm/mmu.c
@@ -50,23 +50,3 @@ void __init init_mmu(void)
 	 */
 	set_ptevaddr_register(PGTABLE_START);
 }
-
-struct kmem_cache *pgtable_cache __read_mostly;
-
-static void pgd_ctor(void *addr)
-{
-	pte_t *ptep = (pte_t *)addr;
-	int i;
-
-	for (i = 0; i < 1024; i++, ptep++)
-		pte_clear(NULL, 0, ptep);
-
-}
-
-void __init pgtable_cache_init(void)
-{
-	pgtable_cache = kmem_cache_create("pgd",
-			PAGE_SIZE, PAGE_SIZE,
-			SLAB_HWCACHE_ALIGN,
-			pgd_ctor);
-}
-- 
 Kirill A. Shutemov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id DD8CB6B0087
	for <linux-mm@kvack.org>; Tue,  7 Dec 2010 16:25:15 -0500 (EST)
Date: Tue, 7 Dec 2010 22:24:02 +0100
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: Re: [PATCH 30 of 66] transparent hugepage core
Message-ID: <20101207212402.GC19131@random.random>
References: <patchbomb.1288798055@v2.random>
 <a7507af3a1dcae5c52a4.1288798085@v2.random>
 <20101118151221.GT8135@csn.ul.ie>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20101118151221.GT8135@csn.ul.ie>
Sender: owner-linux-mm@kvack.org
To: Mel Gorman <mel@csn.ul.ie>
Cc: linux-mm@kvack.org, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, Marcelo Tosatti <mtosatti@redhat.com>, Adam Litke <agl@us.ibm.com>, Avi Kivity <avi@redhat.com>, Hugh Dickins <hugh.dickins@tiscali.co.uk>, Rik van Riel <riel@redhat.com>, Dave Hansen <dave@linux.vnet.ibm.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Ingo Molnar <mingo@elte.hu>, Mike Travis <travis@sgi.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Christoph Lameter <cl@linux-foundation.org>, Chris Wright <chrisw@sous-sol.org>, bpicco@redhat.com, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Balbir Singh <balbir@linux.vnet.ibm.com>, "Michael S. Tsirkin" <mst@redhat.com>, Peter Zijlstra <peterz@infradead.org>, Johannes Weiner <hannes@cmpxchg.org>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, Chris Mason <chris.mason@oracle.com>, Borislav Petkov <bp@alien8.de>
List-ID: <linux-mm.kvack.org>

On Thu, Nov 18, 2010 at 03:12:21PM +0000, Mel Gorman wrote:
> All that seems fine to me. Nits in part that are simply not worth
> calling out. In principal, I Agree With This :)

I didn't understand what is not worth calling out, but I like the end
of your sentence ;).

> > +#define wait_split_huge_page(__anon_vma, __pmd)				\
> > +	do {								\
> > +		pmd_t *____pmd = (__pmd);				\
> > +		spin_unlock_wait(&(__anon_vma)->root->lock);		\
> > +		/*							\
> > +		 * spin_unlock_wait() is just a loop in C and so the	\
> > +		 * CPU can reorder anything around it.			\
> > +		 */							\
> > +		smp_mb();						\
> 
> Just a note as I see nothing wrong with this but that's a good spot. The
> unlock isn't a memory barrier. Out of curiousity, does it really need to be
> a full barrier or would a write barrier have been enough?
> 
> > +		BUG_ON(pmd_trans_splitting(*____pmd) ||			\
> > +		       pmd_trans_huge(*____pmd));			\

spin_unlock reads, the BUG_ON reads, so even if we ignore what happens
before and after wait_split_huge_page(), at most it could be a read
memory barrier. It can't be a write memory barrier as the
spin_unlock_wait would pass it too.

I think it better be a full memory barrier to be sure the writes after
wait_split_huge_page return don't happen before spin_unlock_wait. It's
hard to see how that could happen though.

> > +	} while (0)
> > +#define HPAGE_PMD_ORDER (HPAGE_PMD_SHIFT-PAGE_SHIFT)
> > +#define HPAGE_PMD_NR (1<<HPAGE_PMD_ORDER)
> > +#if HPAGE_PMD_ORDER > MAX_ORDER
> > +#error "hugepages can't be allocated by the buddy allocator"
> > +#endif
> > +
> > +extern unsigned long vma_address(struct page *page, struct vm_area_struct *vma);
> > +static inline int PageTransHuge(struct page *page)
> > +{
> > +	VM_BUG_ON(PageTail(page));
> > +	return PageHead(page);
> > +}
> 
> gfp.h seems an odd place for these. Should the flags go in page-flags.h
> and maybe put vma_address() in internal.h?
> 
> Not a biggie.

Cleaned up thanks.

diff --git a/include/linux/huge_mm.h b/include/linux/huge_mm.h
--- a/include/linux/huge_mm.h
+++ b/include/linux/huge_mm.h
@@ -97,13 +97,6 @@ extern void __split_huge_page_pmd(struct
 #if HPAGE_PMD_ORDER > MAX_ORDER
 #error "hugepages can't be allocated by the buddy allocator"
 #endif
-
-extern unsigned long vma_address(struct page *page, struct vm_area_struct *vma);
-static inline int PageTransHuge(struct page *page)
-{
-	VM_BUG_ON(PageTail(page));
-	return PageHead(page);
-}
 #else /* CONFIG_TRANSPARENT_HUGEPAGE */
 #define HPAGE_PMD_SHIFT ({ BUG(); 0; })
 #define HPAGE_PMD_MASK ({ BUG(); 0; })
@@ -120,7 +113,6 @@ static inline int split_huge_page(struct
 	do { } while (0)
 #define wait_split_huge_page(__anon_vma, __pmd)	\
 	do { } while (0)
-#define PageTransHuge(page) 0
 #endif /* CONFIG_TRANSPARENT_HUGEPAGE */
 
 #endif /* _LINUX_HUGE_MM_H */
diff --git a/include/linux/page-flags.h b/include/linux/page-flags.h
--- a/include/linux/page-flags.h
+++ b/include/linux/page-flags.h
@@ -409,6 +409,19 @@ static inline void ClearPageCompound(str
 
 #endif /* !PAGEFLAGS_EXTENDED */
 
+#ifdef CONFIG_TRANSPARENT_HUGEPAGE
+static inline int PageTransHuge(struct page *page)
+{
+	VM_BUG_ON(PageTail(page));
+	return PageHead(page);
+}
+#else
+static inline int PageTransHuge(struct page *page)
+{
+	return 0;
+}
+#endif
+
 #ifdef CONFIG_MMU
 #define __PG_MLOCKED		(1 << PG_mlocked)
 #else
diff --git a/mm/internal.h b/mm/internal.h
--- a/mm/internal.h
+++ b/mm/internal.h
@@ -134,6 +134,10 @@ static inline void mlock_migrate_page(st
 	}
 }
 
+#ifdef CONFIG_TRANSPARENT_HUGEPAGE
+extern unsigned long vma_address(struct page *page,
+				 struct vm_area_struct *vma);
+#endif
 #else /* !CONFIG_MMU */
 static inline int is_mlocked_vma(struct vm_area_struct *v, struct page *p)
 {

> > diff --git a/include/linux/mm_inline.h b/include/linux/mm_inline.h
> > --- a/include/linux/mm_inline.h
> > +++ b/include/linux/mm_inline.h
> > @@ -20,11 +20,18 @@ static inline int page_is_file_cache(str
> >  }
> >  
> >  static inline void
> > +__add_page_to_lru_list(struct zone *zone, struct page *page, enum lru_list l,
> > +		       struct list_head *head)
> > +{
> > +	list_add(&page->lru, head);
> > +	__inc_zone_state(zone, NR_LRU_BASE + l);
> > +	mem_cgroup_add_lru_list(page, l);
> > +}
> > +
> > +static inline void
> >  add_page_to_lru_list(struct zone *zone, struct page *page, enum lru_list l)
> >  {
> > -	list_add(&page->lru, &zone->lru[l].list);
> > -	__inc_zone_state(zone, NR_LRU_BASE + l);
> > -	mem_cgroup_add_lru_list(page, l);
> > +	__add_page_to_lru_list(zone, page, l, &zone->lru[l].list);
> >  }
> >  
> 
> Do these really need to be in a public header or can they move to
> mm/swap.c?

The above quoted change is a noop as far as the old code is concerned,
and moving it to swap.c would alter the old code. I think list_add and
__mod_zone_page_state is pretty small and fast so probably it's worth
keeping it as inline.

> > +static void prepare_pmd_huge_pte(pgtable_t pgtable,
> > +				 struct mm_struct *mm)
> > +{
> > +	VM_BUG_ON(spin_can_lock(&mm->page_table_lock));
> > +
> 
> assert_spin_locked() ?

Changed.

> > +int handle_pte_fault(struct mm_struct *mm,
> > +		     struct vm_area_struct *vma, unsigned long address,
> > +		     pte_t *pte, pmd_t *pmd, unsigned int flags)
> >  {
> >  	pte_t entry;
> >  	spinlock_t *ptl;
> > @@ -3222,9 +3257,40 @@ int handle_mm_fault(struct mm_struct *mm
> >  	pmd = pmd_alloc(mm, pud, address);
> >  	if (!pmd)
> >  		return VM_FAULT_OOM;
> > -	pte = pte_alloc_map(mm, vma, pmd, address);
> > -	if (!pte)
> > +	if (pmd_none(*pmd) && transparent_hugepage_enabled(vma)) {
> > +		if (!vma->vm_ops)
> > +			return do_huge_pmd_anonymous_page(mm, vma, address,
> > +							  pmd, flags);
> > +	} else {
> > +		pmd_t orig_pmd = *pmd;
> > +		barrier();
> 
> What is this barrier for?

This is to be guaranteed gcc doesn't re-read the *pmd after the
barrier and it instead always read it from orig_pmd variable on the
local kernel stack. gcc doesn't know *pmd can still change from under
us until after we take some lock and the code relies on orig_pmd not
to change after barrier().

> Other than a few minor questions, these seems very similar to what you
> had before. There is a lot going on in this patch but I did not find
> anything wrong.
> 
> Acked-by: Mel Gorman <mel@csn.ul.ie>

Great thanks!
Andrea

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

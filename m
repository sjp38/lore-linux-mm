Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id BE7326B004D
	for <linux-mm@kvack.org>; Thu, 21 May 2009 19:47:12 -0400 (EDT)
Received: from m3.gw.fujitsu.co.jp ([10.0.50.73])
	by fgwmail6.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id n4LNlsrx005067
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Fri, 22 May 2009 08:47:55 +0900
Received: from smail (m3 [127.0.0.1])
	by outgoing.m3.gw.fujitsu.co.jp (Postfix) with ESMTP id A26B645DD7F
	for <linux-mm@kvack.org>; Fri, 22 May 2009 08:47:54 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (s3.gw.fujitsu.co.jp [10.0.50.93])
	by m3.gw.fujitsu.co.jp (Postfix) with ESMTP id 801FD45DD78
	for <linux-mm@kvack.org>; Fri, 22 May 2009 08:47:54 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id 616C11DB803F
	for <linux-mm@kvack.org>; Fri, 22 May 2009 08:47:54 +0900 (JST)
Received: from m107.s.css.fujitsu.com (m107.s.css.fujitsu.com [10.249.87.107])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id 0E8841DB8037
	for <linux-mm@kvack.org>; Fri, 22 May 2009 08:47:54 +0900 (JST)
Date: Fri, 22 May 2009 08:46:22 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [RFC][PATCH 2/2] synchrouns swap freeing without trylock.
Message-Id: <20090522084622.b1791283.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20090521124419.GC1820@cmpxchg.org>
References: <20090521164100.5f6a0b75.kamezawa.hiroyu@jp.fujitsu.com>
	<20090521164346.d188b38f.kamezawa.hiroyu@jp.fujitsu.com>
	<20090521124419.GC1820@cmpxchg.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "nishimura@mxp.nes.nec.co.jp" <nishimura@mxp.nes.nec.co.jp>, "balbir@linux.vnet.ibm.com" <balbir@linux.vnet.ibm.com>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "hugh.dickins@tiscali.co.uk" <hugh.dickins@tiscali.co.uk>
List-ID: <linux-mm.kvack.org>

On Thu, 21 May 2009 14:44:20 +0200
Johannes Weiner <hannes@cmpxchg.org> wrote:

> On Thu, May 21, 2009 at 04:43:46PM +0900, KAMEZAWA Hiroyuki wrote:
> > Index: mmotm-2.6.30-May17/mm/memory.c
> > ===================================================================
> > --- mmotm-2.6.30-May17.orig/mm/memory.c
> > +++ mmotm-2.6.30-May17/mm/memory.c
> > @@ -758,10 +758,84 @@ int copy_page_range(struct mm_struct *ds
> >  	return ret;
> >  }
> >  
> > +
> > +/*
> > + * Because we are under preempt_disable (see tlb_xxx functions), we can't call
> > + * lcok_page() etc..which may sleep. At freeing swap, gatering swp_entry
> > + * which seems of-no-use but has swap cache to this struct and remove them
> > + * in batch. Because the condition to gather swp_entry to this bix is
> > + * - There is no other swap reference. &&
> > + * - There is a swap cache. &&
> > + * - Page table entry was "Not Present"
> > + * The number of entries which is caught in this is very small.
> > + */
> > +#define NR_SWAP_FREE_BATCH		(63)
> > +struct stale_swap_buffer {
> > +	int nr;
> > +	swp_entry_t ents[NR_SWAP_FREE_BATCH];
> > +};
> > +
> > +#ifdef CONFIG_SWAP
> > +static inline void push_swap_ssb(struct stale_swap_buffer *ssb, swp_entry_t ent)
> > +{
> > +	if (!ssb)
> > +		return;
> > +	ssb->ents[ssb->nr++] = ent;
> > +}
> > +
> > +static inline int ssb_full(struct stale_swap_buffer *ssb)
> > +{
> > +	if (!ssb)
> > +		return 0;
> > +	return ssb->nr == NR_SWAP_FREE_BATCH;
> > +}
> > +
> > +static void free_stale_swaps(struct stale_swap_buffer *ssb)
> > +{
> > +	if (!ssb || !ssb->nr)
> > +		return;
> > +	free_swap_batch(ssb->nr, ssb->ents);
> > +	ssb->nr = 0;
> > +}
> 
> Could you name it swapvec analogous to pagevec and make the API
> similar?
> 
sure.

> > +static struct stale_swap_buffer *alloc_ssb(void)
> > +{
> > +	/*
> > +	 * Considering the case zap_xxx can be called as a result of OOM,
> > +	 * gfp_mask here should be GFP_ATOMIC. Even if we fails to allocate,
> > +	 * global LRU can find and remove stale swap caches in such case.
> > +	 */
> > +	return kzalloc(sizeof(struct stale_swap_buffer), GFP_ATOMIC);
> > +}
> > +static inline void free_ssb(struct stale_swap_buffer *ssb)
> > +{
> > +	kfree(ssb);
> > +}
> > +#else
> > +static inline void push_swap_ssb(struct stale_swap_buffer *ssb, swp_entry_t ent)
> > +{
> > +}
> > +static inline int ssb_full(struct stale_swap_buufer *ssb)
> > +{
> > +	return 0;
> > +}
> > +static inline void free_stale_swaps(struct stale_swap_buffer *ssb)
> > +{
> > +}
> > +static inline struct stale_swap_buffer *alloc_ssb(void)
> > +{
> > +	return NULL;
> > +}
> > +static inline void free_ssb(struct stale_swap_buffer *ssb)
> > +{
> > +}
> > +#endif
> > +
> >  static unsigned long zap_pte_range(struct mmu_gather *tlb,
> >  				struct vm_area_struct *vma, pmd_t *pmd,
> >  				unsigned long addr, unsigned long end,
> > -				long *zap_work, struct zap_details *details)
> > +				long *zap_work, struct zap_details *details,
> > +				struct stale_swap_buffer *ssb)
> >  {
> >  	struct mm_struct *mm = tlb->mm;
> >  	pte_t *pte;
> > @@ -837,8 +911,17 @@ static unsigned long zap_pte_range(struc
> >  		if (pte_file(ptent)) {
> >  			if (unlikely(!(vma->vm_flags & VM_NONLINEAR)))
> >  				print_bad_pte(vma, addr, ptent, NULL);
> > -		} else if
> > -		  (unlikely(!free_swap_and_cache(pte_to_swp_entry(ptent))))
> > +		} else if (likely(ssb)) {
> > +			int ret = free_swap_and_check(pte_to_swp_entry(ptent));
> > +			if (unlikely(!ret))
> > +				print_bad_pte(vma, addr, ptent, NULL);
> > +			if (ret == 1) {
> > +				push_swap_ssb(ssb, pte_to_swp_entry(ptent));
> > +				/* need to free swaps ? */
> > +				if (ssb_full(ssb))
> > +					*zap_work = 0;
> 
> if (!swapvec_add(swapvec, pte_to_swp_entry(ptent)))
> 	*zap_work = 0;
> 
> would look more familiar, I think.
> 
sure.

> > @@ -1021,13 +1116,15 @@ unsigned long unmap_vmas(struct mmu_gath
> >  
> >  			tlb_finish_mmu(*tlbp, tlb_start, start);
> >  
> > -			if (need_resched() ||
> > +			if (need_resched() || ssb_full(ssb) ||
> >  				(i_mmap_lock && spin_needbreak(i_mmap_lock))) {
> >  				if (i_mmap_lock) {
> >  					*tlbp = NULL;
> >  					goto out;
> >  				}
> >  				cond_resched();
> > +				/* This call may sleep */
> > +				free_stale_swaps(ssb);
> 
> This checks both !!ssb and !!ssb->number in ssb_full() and in
> free_stale_swaps().  It's not the only place, by the way.
> 
> I think it's better to swap two lines here, doing free_stale_swaps()
> before cond_resched().  Because if we are going to sleep, we might as
> well be waiting for a page lock meanwhile.
> 
ok.

> > @@ -1037,6 +1134,13 @@ unsigned long unmap_vmas(struct mmu_gath
> >  	}
> >  out:
> >  	mmu_notifier_invalidate_range_end(mm, start_addr, end_addr);
> > +	/* there is stale swap cache. We may sleep and release per-cpu.*/
> > +	if (ssb && ssb->nr) {
> > +		tlb_finish_mmu(*tlbp, tlb_start, start);
> > +		free_stale_swaps(ssb);
> > +		*tlbp = tlb_gather_mmu(mm, fullmm);
> > +	}
> > +	free_ssb(ssb);
> >  	return start;	/* which is now the end (or restart) address */
> >  }
> >  
> 
> > Index: mmotm-2.6.30-May17/mm/swapfile.c
> > ===================================================================
> > --- mmotm-2.6.30-May17.orig/mm/swapfile.c
> > +++ mmotm-2.6.30-May17/mm/swapfile.c
> 
> > @@ -618,6 +619,159 @@ int free_swap_and_cache(swp_entry_t entr
> >  	return p != NULL;
> >  }
> >  
> > +/*
> > + * Free the swap entry like above, but
> > + * returns 1 if swap entry has swap cache and ready to be freed.
> > + * returns 2 if swap has other references.
> > + */
> > +int free_swap_and_check(swp_entry_t entry)
> > +{
> > +	struct swap_info_struct *p;
> > +	int ret = 0;
> > +
> > +	if (is_migration_entry(entry))
> > +		return 2;
> > +
> > +	p = swap_info_get(entry);
> > +	if (!p)
> > +		return ret;
> > +	if (swap_entry_free(p, entry, SWAP_MAP) == 1)
> > +		ret = 1;
> > +	else
> > +		ret = 2;
> 
> Wouldn't it be possible to drop the previous patch and in case
> swap_entry_free() returns 1, look up the entry in the page cache to
> see whether the last user is the cache and not a pte?

there is a race at swapin-readahead

   swap_duplicate()
   =>
   add_to_swap_cache().

So, I wrote 1/2.

After reading Hugh's comment, it seems I have to drop this all or rewrite all ;)
Anyway, Thank you for review.

-Kame





--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

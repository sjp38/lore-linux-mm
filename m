Date: Sun, 28 Jan 2007 14:49:33 +0000
From: Christoph Hellwig <hch@infradead.org>
Subject: Re: [PATCH] mm: remove global locks from mm/highmem.c
Message-ID: <20070128144933.GD16552@infradead.org>
References: <1169993494.10987.23.camel@lappy>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1169993494.10987.23.camel@lappy>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Peter Zijlstra <a.p.zijlstra@chello.nl>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, Andrew Morton <akpm@osdl.org>, Ingo Molnar <mingo@elte.hu>
List-ID: <linux-mm.kvack.org>

On Sun, Jan 28, 2007 at 03:11:34PM +0100, Peter Zijlstra wrote:
> Eradicate global locks.
> 
>  - kmap_lock is removed by extensive use of atomic_t, a new flush
>    scheme and modifying set_page_address to only allow NULL<->virt
>    transitions.

What's the point for this?  Extensive atomic_t use is usually much worse
than spinlocks.  A spinlock region is just a single atomic instruction,
as soon as you do more than one atomic_t you tend to make scalability
worse.  Not to mention that atomic_t are much worse when you try to
profile scalability issues.

What benchmark shows a problem with the current locking, and from what
caller?  In doubt we just need to convert that caller to kmap_atomic.


> 
> A count of 0 is an exclusive state acting as an entry lock. This is done
> using inc_not_zero and cmpxchg. The restriction on changing the virtual
> address closes the gap with concurrent additions of the same entry.
> 
>  - pool_lock is removed by using the pkmap index for the
>    page_address_maps.
> 
> By using the pkmap index for the hash entries it is no longer needed to
> keep a free list.
> 
> This patch has been in -rt for a while but should also help regular
> highmem machines with multiple cores/cpus.
> 
> Signed-off-by: Peter Zijlstra <a.p.zijlstra@chello.nl>
> ---
>  include/linux/mm.h |   32 ++-
>  mm/highmem.c       |  433 ++++++++++++++++++++++++++++++-----------------------
>  2 files changed, 276 insertions(+), 189 deletions(-)
> 
> Index: linux/include/linux/mm.h
> ===================================================================
> --- linux.orig/include/linux/mm.h
> +++ linux/include/linux/mm.h
> @@ -543,23 +543,39 @@ static __always_inline void *lowmem_page
>  #endif
>  
>  #if defined(WANT_PAGE_VIRTUAL)
> -#define page_address(page) ((page)->virtual)
> -#define set_page_address(page, address)			\
> -	do {						\
> -		(page)->virtual = (address);		\
> -	} while(0)
> -#define page_address_init()  do { } while(0)
> +/*
> + * wrap page->virtual so it is safe to set/read locklessly
> + */
> +#define page_address(page) \
> +	({ typeof((page)->virtual) v = (page)->virtual; \
> +	 smp_read_barrier_depends(); \
> +	 v; })
> +
> +static inline int set_page_address(struct page *page, void *address)
> +{
> +	if (address)
> +		return cmpxchg(&page->virtual, NULL, address) == NULL;
> +	else {
> +		/*
> +		 * cmpxchg is a bit abused because it is not guaranteed
> +		 * safe wrt direct assignment on all platforms.
> +		 */
> +		void *virt = page->virtual;
> +		return cmpxchg(&page->vitrual, virt, NULL) == virt;
> +	}
> +}
> +void page_address_init(void);
>  #endif
>  
>  #if defined(HASHED_PAGE_VIRTUAL)
>  void *page_address(struct page *page);
> -void set_page_address(struct page *page, void *virtual);
> +int set_page_address(struct page *page, void *virtual);
>  void page_address_init(void);
>  #endif
>  
>  #if !defined(HASHED_PAGE_VIRTUAL) && !defined(WANT_PAGE_VIRTUAL)
>  #define page_address(page) lowmem_page_address(page)
> -#define set_page_address(page, address)  do { } while(0)
> +#define set_page_address(page, address)  (0)
>  #define page_address_init()  do { } while(0)
>  #endif
>  
> Index: linux/mm/highmem.c
> ===================================================================
> --- linux.orig/mm/highmem.c
> +++ linux/mm/highmem.c
> @@ -14,6 +14,11 @@
>   * based on Linus' idea.
>   *
>   * Copyright (C) 1999 Ingo Molnar <mingo@redhat.com>
> + *
> + * Largely rewritten to get rid of all global locks
> + *
> + * Copyright (C) 2006 Red Hat, Inc., Peter Zijlstra <pzijlstr@redhat.com>
> + *
>   */
>  
>  #include <linux/mm.h>
> @@ -27,18 +32,14 @@
>  #include <linux/hash.h>
>  #include <linux/highmem.h>
>  #include <linux/blktrace_api.h>
> +
>  #include <asm/tlbflush.h>
> +#include <asm/pgtable.h>
>  
> -/*
> - * Virtual_count is not a pure "count".
> - *  0 means that it is not mapped, and has not been mapped
> - *    since a TLB flush - it is usable.
> - *  1 means that there are no users, but it has been mapped
> - *    since the last TLB flush - so we can't use it.
> - *  n means that there are (n-1) current users of it.
> - */
>  #ifdef CONFIG_HIGHMEM
>  
> +static int __set_page_address(struct page *page, void *virtual, int pos);
> +
>  unsigned long totalhigh_pages __read_mostly;
>  
>  unsigned int nr_free_highpages (void)
> @@ -52,164 +53,208 @@ unsigned int nr_free_highpages (void)
>  	return pages;
>  }
>  
> -static int pkmap_count[LAST_PKMAP];
> -static unsigned int last_pkmap_nr;
> -static  __cacheline_aligned_in_smp DEFINE_SPINLOCK(kmap_lock);
> +/*
> + * count is not a pure "count".
> + *  0 means its owned exclusively by someone
> + *  1 means its free for use - either mapped or not.
> + *  n means that there are (n-1) current users of it.
> + */
> +static atomic_t pkmap_count[LAST_PKMAP];
> +static atomic_t pkmap_hand;
>  
>  pte_t * pkmap_page_table;
>  
>  static DECLARE_WAIT_QUEUE_HEAD(pkmap_map_wait);
>  
> -static void flush_all_zero_pkmaps(void)
> +/*
> + * Try to free a given kmap slot.
> + *
> + * Returns:
> + *  -1 - in use
> + *   0 - free, no TLB flush needed
> + *   1 - free, needs TLB flush
> + */
> +static int pkmap_try_free(int pos)
>  {
> -	int i;
> -
> -	flush_cache_kmaps();
> +	if (atomic_cmpxchg(&pkmap_count[pos], 1, 0) != 1)
> +		return -1;
>  
> -	for (i = 0; i < LAST_PKMAP; i++) {
> -		struct page *page;
> +	/*
> +	 * TODO: add a young bit to make it CLOCK
> +	 */
> +	if (!pte_none(pkmap_page_table[pos])) {
> +		struct page *page = pte_page(pkmap_page_table[pos]);
> +		unsigned long addr = PKMAP_ADDR(pos);
> +		pte_t *ptep = &pkmap_page_table[pos];
> +
> +		VM_BUG_ON(addr != (unsigned long)page_address(page));
> +
> +		if (!__set_page_address(page, NULL, pos))
> +			BUG();
> +		flush_kernel_dcache_page(page);
> +		pte_clear(&init_mm, addr, ptep);
>  
> -		/*
> -		 * zero means we don't have anything to do,
> -		 * >1 means that it is still in use. Only
> -		 * a count of 1 means that it is free but
> -		 * needs to be unmapped
> -		 */
> -		if (pkmap_count[i] != 1)
> -			continue;
> -		pkmap_count[i] = 0;
> +		return 1;
> +	}
>  
> -		/* sanity check */
> -		BUG_ON(pte_none(pkmap_page_table[i]));
> +	return 0;
> +}
>  
> -		/*
> -		 * Don't need an atomic fetch-and-clear op here;
> -		 * no-one has the page mapped, and cannot get at
> -		 * its virtual address (and hence PTE) without first
> -		 * getting the kmap_lock (which is held here).
> -		 * So no dangers, even with speculative execution.
> -		 */
> -		page = pte_page(pkmap_page_table[i]);
> -		pte_clear(&init_mm, (unsigned long)page_address(page),
> -			  &pkmap_page_table[i]);
> +static inline void pkmap_put(atomic_t *counter)
> +{
> +	switch (atomic_dec_return(counter)) {
> +	case 0:
> +		BUG();
>  
> -		set_page_address(page, NULL);
> +	case 1:
> +		wake_up(&pkmap_map_wait);
>  	}
> -	flush_tlb_kernel_range(PKMAP_ADDR(0), PKMAP_ADDR(LAST_PKMAP));
>  }
>  
> -static inline unsigned long map_new_virtual(struct page *page)
> +#define TLB_BATCH	32
> +
> +static int pkmap_get_free(void)
>  {
> -	unsigned long vaddr;
> -	int count;
> +	int i, pos, flush;
> +	DECLARE_WAITQUEUE(wait, current);
>  
> -start:
> -	count = LAST_PKMAP;
> -	/* Find an empty entry */
> -	for (;;) {
> -		last_pkmap_nr = (last_pkmap_nr + 1) & LAST_PKMAP_MASK;
> -		if (!last_pkmap_nr) {
> -			flush_all_zero_pkmaps();
> -			count = LAST_PKMAP;
> -		}
> -		if (!pkmap_count[last_pkmap_nr])
> -			break;	/* Found a usable entry */
> -		if (--count)
> -			continue;
> +restart:
> +	for (i = 0; i < LAST_PKMAP; i++) {
> +		pos = atomic_inc_return(&pkmap_hand) % LAST_PKMAP;
> +		flush = pkmap_try_free(pos);
> +		if (flush >= 0)
> +			goto got_one;
> +	}
> +
> +	/*
> +	 * wait for somebody else to unmap their entries
> +	 */
> +	__set_current_state(TASK_UNINTERRUPTIBLE);
> +	add_wait_queue(&pkmap_map_wait, &wait);
> +	schedule();
> +	remove_wait_queue(&pkmap_map_wait, &wait);
> +
> +	goto restart;
> +
> +got_one:
> +	if (flush) {
> +#if 0
> +		flush_tlb_kernel_range(PKMAP_ADDR(pos), PKMAP_ADDR(pos+1));
> +#else
> +		int pos2 = (pos + 1) % LAST_PKMAP;
> +		int nr;
> +		int entries[TLB_BATCH];
>  
>  		/*
> -		 * Sleep for somebody else to unmap their entries
> +		 * For those architectures that cannot help but flush the
> +		 * whole TLB, flush some more entries to make it worthwhile.
> +		 * Scan ahead of the hand to minimise search distances.
>  		 */
> -		{
> -			DECLARE_WAITQUEUE(wait, current);
> +		for (i = 0, nr = 0; i < LAST_PKMAP && nr < TLB_BATCH;
> +				i++, pos2 = (pos2 + 1) % LAST_PKMAP) {
>  
> -			__set_current_state(TASK_UNINTERRUPTIBLE);
> -			add_wait_queue(&pkmap_map_wait, &wait);
> -			spin_unlock(&kmap_lock);
> -			schedule();
> -			remove_wait_queue(&pkmap_map_wait, &wait);
> -			spin_lock(&kmap_lock);
> -
> -			/* Somebody else might have mapped it while we slept */
> -			if (page_address(page))
> -				return (unsigned long)page_address(page);
> +			flush = pkmap_try_free(pos2);
> +			if (flush < 0)
> +				continue;
> +
> +			if (!flush) {
> +				atomic_t *counter = &pkmap_count[pos2];
> +				VM_BUG_ON(atomic_read(counter) != 0);
> +				atomic_set(counter, 2);
> +				pkmap_put(counter);
> +			} else
> +				entries[nr++] = pos2;
> +		}
> +		flush_tlb_kernel_range(PKMAP_ADDR(0), PKMAP_ADDR(LAST_PKMAP));
>  
> -			/* Re-start */
> -			goto start;
> +		for (i = 0; i < nr; i++) {
> +			atomic_t *counter = &pkmap_count[entries[i]];
> +			VM_BUG_ON(atomic_read(counter) != 0);
> +			atomic_set(counter, 2);
> +			pkmap_put(counter);
>  		}
> +#endif
>  	}
> -	vaddr = PKMAP_ADDR(last_pkmap_nr);
> -	set_pte_at(&init_mm, vaddr,
> -		   &(pkmap_page_table[last_pkmap_nr]), mk_pte(page, kmap_prot));
> +	return pos;
> +}
> +
> +static unsigned long pkmap_insert(struct page *page)
> +{
> +	int pos = pkmap_get_free();
> +	unsigned long vaddr = PKMAP_ADDR(pos);
> +	pte_t *ptep = &pkmap_page_table[pos];
> +	pte_t entry = mk_pte(page, kmap_prot);
> +	atomic_t *counter = &pkmap_count[pos];
> +
> +	VM_BUG_ON(atomic_read(counter) != 0);
>  
> -	pkmap_count[last_pkmap_nr] = 1;
> -	set_page_address(page, (void *)vaddr);
> +	set_pte_at(&init_mm, vaddr, ptep, entry);
> +	if (unlikely(!__set_page_address(page, (void *)vaddr, pos))) {
> +		/*
> +		 * concurrent pkmap_inserts for this page -
> +		 * the other won the race, release this entry.
> +		 *
> +		 * we can still clear the pte without a tlb flush since
> +		 * it couldn't have been used yet.
> +		 */
> +		pte_clear(&init_mm, vaddr, ptep);
> +		VM_BUG_ON(atomic_read(counter) != 0);
> +		atomic_set(counter, 2);
> +		pkmap_put(counter);
> +		vaddr = 0;
> +	} else
> +		atomic_set(counter, 2);
>  
>  	return vaddr;
>  }
>  
> -void fastcall *kmap_high(struct page *page)
> +fastcall void *kmap_high(struct page *page)
>  {
>  	unsigned long vaddr;
> -
> -	/*
> -	 * For highmem pages, we can't trust "virtual" until
> -	 * after we have the lock.
> -	 *
> -	 * We cannot call this from interrupts, as it may block
> -	 */
> -	spin_lock(&kmap_lock);
> +again:
>  	vaddr = (unsigned long)page_address(page);
> +	if (vaddr) {
> +		atomic_t *counter = &pkmap_count[PKMAP_NR(vaddr)];
> +		if (atomic_inc_not_zero(counter)) {
> +			/*
> +			 * atomic_inc_not_zero implies a (memory) barrier on success
> +			 * so page address will be reloaded.
> +			 */
> +			unsigned long vaddr2 = (unsigned long)page_address(page);
> +			if (likely(vaddr == vaddr2))
> +				return (void *)vaddr;
> +
> +			/*
> +			 * Oops, we got someone else.
> +			 *
> +			 * This can happen if we get preempted after
> +			 * page_address() and before atomic_inc_not_zero()
> +			 * and during that preemption this slot is freed and
> +			 * reused.
> +			 */
> +			pkmap_put(counter);
> +			goto again;
> +		}
> +	}
> +
> +	vaddr = pkmap_insert(page);
>  	if (!vaddr)
> -		vaddr = map_new_virtual(page);
> -	pkmap_count[PKMAP_NR(vaddr)]++;
> -	BUG_ON(pkmap_count[PKMAP_NR(vaddr)] < 2);
> -	spin_unlock(&kmap_lock);
> -	return (void*) vaddr;
> +		goto again;
> +
> +	return (void *)vaddr;
>  }
>  
>  EXPORT_SYMBOL(kmap_high);
>  
> -void fastcall kunmap_high(struct page *page)
> +fastcall void kunmap_high(struct page *page)
>  {
> -	unsigned long vaddr;
> -	unsigned long nr;
> -	int need_wakeup;
> -
> -	spin_lock(&kmap_lock);
> -	vaddr = (unsigned long)page_address(page);
> +	unsigned long vaddr = (unsigned long)page_address(page);
>  	BUG_ON(!vaddr);
> -	nr = PKMAP_NR(vaddr);
> -
> -	/*
> -	 * A count must never go down to zero
> -	 * without a TLB flush!
> -	 */
> -	need_wakeup = 0;
> -	switch (--pkmap_count[nr]) {
> -	case 0:
> -		BUG();
> -	case 1:
> -		/*
> -		 * Avoid an unnecessary wake_up() function call.
> -		 * The common case is pkmap_count[] == 1, but
> -		 * no waiters.
> -		 * The tasks queued in the wait-queue are guarded
> -		 * by both the lock in the wait-queue-head and by
> -		 * the kmap_lock.  As the kmap_lock is held here,
> -		 * no need for the wait-queue-head's lock.  Simply
> -		 * test if the queue is empty.
> -		 */
> -		need_wakeup = waitqueue_active(&pkmap_map_wait);
> -	}
> -	spin_unlock(&kmap_lock);
> -
> -	/* do wake-up, if needed, race-free outside of the spin lock */
> -	if (need_wakeup)
> -		wake_up(&pkmap_map_wait);
> +	pkmap_put(&pkmap_count[PKMAP_NR(vaddr)]);
>  }
>  
>  EXPORT_SYMBOL(kunmap_high);
> +
>  #endif
>  
>  #if defined(HASHED_PAGE_VIRTUAL)
> @@ -217,19 +262,13 @@ EXPORT_SYMBOL(kunmap_high);
>  #define PA_HASH_ORDER	7
>  
>  /*
> - * Describes one page->virtual association
> + * Describes one page->virtual address association.
>   */
> -struct page_address_map {
> +static struct page_address_map {
>  	struct page *page;
>  	void *virtual;
>  	struct list_head list;
> -};
> -
> -/*
> - * page_address_map freelist, allocated from page_address_maps.
> - */
> -static struct list_head page_address_pool;	/* freelist */
> -static spinlock_t pool_lock;			/* protects page_address_pool */
> +} page_address_maps[LAST_PKMAP];
>  
>  /*
>   * Hash table bucket
> @@ -244,91 +283,123 @@ static struct page_address_slot *page_sl
>  	return &page_address_htable[hash_ptr(page, PA_HASH_ORDER)];
>  }
>  
> -void *page_address(struct page *page)
> +static void *__page_address(struct page_address_slot *pas, struct page *page)
>  {
> -	unsigned long flags;
> -	void *ret;
> -	struct page_address_slot *pas;
> -
> -	if (!PageHighMem(page))
> -		return lowmem_page_address(page);
> +	void *ret = NULL;
>  
> -	pas = page_slot(page);
> -	ret = NULL;
> -	spin_lock_irqsave(&pas->lock, flags);
>  	if (!list_empty(&pas->lh)) {
>  		struct page_address_map *pam;
>  
>  		list_for_each_entry(pam, &pas->lh, list) {
>  			if (pam->page == page) {
>  				ret = pam->virtual;
> -				goto done;
> +				break;
>  			}
>  		}
>  	}
> -done:
> +
> +	return ret;
> +}
> +
> +void *page_address(struct page *page)
> +{
> +	unsigned long flags;
> +	void *ret;
> +	struct page_address_slot *pas;
> +
> +	if (!PageHighMem(page))
> +		return lowmem_page_address(page);
> +
> +	pas = page_slot(page);
> +	spin_lock_irqsave(&pas->lock, flags);
> +	ret = __page_address(pas, page);
>  	spin_unlock_irqrestore(&pas->lock, flags);
>  	return ret;
>  }
>  
>  EXPORT_SYMBOL(page_address);
>  
> -void set_page_address(struct page *page, void *virtual)
> +static int __set_page_address(struct page *page, void *virtual, int pos)
>  {
> +	int ret = 0;
>  	unsigned long flags;
>  	struct page_address_slot *pas;
>  	struct page_address_map *pam;
>  
> -	BUG_ON(!PageHighMem(page));
> +	VM_BUG_ON(!PageHighMem(page));
> +	VM_BUG_ON(atomic_read(&pkmap_count[pos]) != 0);
> +	VM_BUG_ON(pos < 0 || pos >= LAST_PKMAP);
>  
>  	pas = page_slot(page);
> -	if (virtual) {		/* Add */
> -		BUG_ON(list_empty(&page_address_pool));
> +	pam = &page_address_maps[pos];
>  
> -		spin_lock_irqsave(&pool_lock, flags);
> -		pam = list_entry(page_address_pool.next,
> -				struct page_address_map, list);
> -		list_del(&pam->list);
> -		spin_unlock_irqrestore(&pool_lock, flags);
> -
> -		pam->page = page;
> -		pam->virtual = virtual;
> -
> -		spin_lock_irqsave(&pas->lock, flags);
> -		list_add_tail(&pam->list, &pas->lh);
> -		spin_unlock_irqrestore(&pas->lock, flags);
> -	} else {		/* Remove */
> -		spin_lock_irqsave(&pas->lock, flags);
> -		list_for_each_entry(pam, &pas->lh, list) {
> -			if (pam->page == page) {
> -				list_del(&pam->list);
> -				spin_unlock_irqrestore(&pas->lock, flags);
> -				spin_lock_irqsave(&pool_lock, flags);
> -				list_add_tail(&pam->list, &page_address_pool);
> -				spin_unlock_irqrestore(&pool_lock, flags);
> -				goto done;
> -			}
> +	spin_lock_irqsave(&pas->lock, flags);
> +	if (virtual) { /* add */
> +		VM_BUG_ON(!list_empty(&pam->list));
> +
> +		if (!__page_address(pas, page)) {
> +			pam->page = page;
> +			pam->virtual = virtual;
> +			list_add_tail(&pam->list, &pas->lh);
> +			ret = 1;
> +		}
> +	} else { /* remove */
> +		if (!list_empty(&pam->list)) {
> +			list_del_init(&pam->list);
> +			ret = 1;
>  		}
> -		spin_unlock_irqrestore(&pas->lock, flags);
>  	}
> -done:
> -	return;
> +	spin_unlock_irqrestore(&pas->lock, flags);
> +
> +	return ret;
>  }
>  
> -static struct page_address_map page_address_maps[LAST_PKMAP];
> +int set_page_address(struct page *page, void *virtual)
> +{
> +	/*
> +	 * set_page_address is not supposed to be called when using
> +	 * hashed virtual addresses.
> +	 */
> +	BUG();
> +	return 0;
> +}
>  
> -void __init page_address_init(void)
> +void __init __page_address_init(void)
>  {
>  	int i;
>  
> -	INIT_LIST_HEAD(&page_address_pool);
>  	for (i = 0; i < ARRAY_SIZE(page_address_maps); i++)
> -		list_add(&page_address_maps[i].list, &page_address_pool);
> +		INIT_LIST_HEAD(&page_address_maps[i].list);
> +
>  	for (i = 0; i < ARRAY_SIZE(page_address_htable); i++) {
>  		INIT_LIST_HEAD(&page_address_htable[i].lh);
>  		spin_lock_init(&page_address_htable[i].lock);
>  	}
> -	spin_lock_init(&pool_lock);
> +}
> +
> +#elif defined (CONFIG_HIGHMEM) /* HASHED_PAGE_VIRTUAL */
> +
> +static int __set_page_address(struct page *page, void *virtual, int pos)
> +{
> +	return set_page_address(page, virtual);
>  }
>  
>  #endif	/* defined(CONFIG_HIGHMEM) && !defined(WANT_PAGE_VIRTUAL) */
> +
> +#if defined(CONFIG_HIGHMEM) || defined(HASHED_PAGE_VIRTUAL)
> +
> +void __init page_address_init(void)
> +{
> +#ifdef CONFIG_HIGHMEM
> +	int i;
> +
> +	for (i = 0; i < ARRAY_SIZE(pkmap_count); i++)
> +		atomic_set(&pkmap_count[i], 1);
> +#endif
> +
> +#ifdef HASHED_PAGE_VIRTUAL
> +	__page_address_init();
> +#endif
> +}
> +
> +#endif
> 
> 
> -
> To unsubscribe from this list: send the line "unsubscribe linux-kernel" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> Please read the FAQ at  http://www.tux.org/lkml/
---end quoted text---

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

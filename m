Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id E75F16B0282
	for <linux-mm@kvack.org>; Fri, 23 Sep 2016 04:47:26 -0400 (EDT)
Received: by mail-pf0-f200.google.com with SMTP id 21so213788439pfy.3
        for <linux-mm@kvack.org>; Fri, 23 Sep 2016 01:47:26 -0700 (PDT)
Received: from mga06.intel.com (mga06.intel.com. [134.134.136.31])
        by mx.google.com with ESMTPS id d86si6932759pfe.90.2016.09.23.01.47.25
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 23 Sep 2016 01:47:26 -0700 (PDT)
From: "Huang\, Ying" <ying.huang@intel.com>
Subject: Re: [PATCH -v3 01/10] mm, swap: Make swap cluster size same of THP size on x86_64
References: <1473266769-2155-1-git-send-email-ying.huang@intel.com>
	<1473266769-2155-2-git-send-email-ying.huang@intel.com>
	<57D0FB10.5010609@linux.vnet.ibm.com>
	<20160919170951.GA1059@cmpxchg.org>
	<87y42n2uth.fsf@yhuang-dev.intel.com>
	<20160922192509.GA6054@cmpxchg.org>
Date: Fri, 23 Sep 2016 16:47:22 +0800
In-Reply-To: <20160922192509.GA6054@cmpxchg.org> (Johannes Weiner's message of
	"Thu, 22 Sep 2016 15:25:09 -0400")
Message-ID: <87oa3ft339.fsf@yhuang-dev.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=ascii
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: "Huang, Ying" <ying.huang@intel.com>, Anshuman Khandual <khandual@linux.vnet.ibm.com>, Andrew Morton <akpm@linux-foundation.org>, tim.c.chen@intel.com, dave.hansen@intel.com, andi.kleen@intel.com, aaron.lu@intel.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Hugh Dickins <hughd@google.com>, Shaohua Li <shli@kernel.org>, Minchan Kim <minchan@kernel.org>, Rik van Riel <riel@redhat.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

Johannes Weiner <hannes@cmpxchg.org> writes:

> Hi Ying,
>
> On Tue, Sep 20, 2016 at 10:01:30AM +0800, Huang, Ying wrote:
>> It appears all patches other than [10/10] in the series is used by the
>> last patch [10/10], directly or indirectly.  And Without [10/10], they
>> don't make much sense.  So you suggest me to use one large patch?
>> Something like below?  Does that help you to review?
>
> I find this version a lot easier to review, thank you.
>
>> As the first step, in this patch, the splitting huge page is
>> delayed from almost the first step of swapping out to after allocating
>> the swap space for the THP and adding the THP into the swap cache.
>> This will reduce lock acquiring/releasing for the locks used for the
>> swap cache management.
>
> I agree that that's a fine goal for this patch series. We can worry
> about 2MB IO submissions later on.
>
>> @@ -503,6 +503,19 @@ config FRONTSWAP
>>  
>>  	  If unsure, say Y to enable frontswap.
>>  
>> +config ARCH_USES_THP_SWAP_CLUSTER
>> +	bool
>> +	default n
>> +
>> +config THP_SWAP_CLUSTER
>> +	bool
>> +	depends on SWAP && TRANSPARENT_HUGEPAGE && ARCH_USES_THP_SWAP_CLUSTER
>> +	default y
>> +	help
>> +	  Use one swap cluster to hold the contents of the THP
>> +	  (Transparent Huge Page) swapped out.  The size of the swap
>> +	  cluster will be same as that of THP.
>
> Making swap space allocation and swapcache handling THP-native is not
> dependent on the architecture, it's generic VM code. Can you please
> just define the cluster size depending on CONFIG_TRANSPARENT_HUGEPAGE?
>
>> @@ -196,7 +196,11 @@ static void discard_swap_cluster(struct
>>  	}
>>  }
>>  
>> +#ifdef CONFIG_THP_SWAP_CLUSTER
>> +#define SWAPFILE_CLUSTER	(HPAGE_SIZE / PAGE_SIZE)
>> +#else
>>  #define SWAPFILE_CLUSTER	256
>> +#endif
>>  #define LATENCY_LIMIT		256
>
> I.e. this?
>
> #ifdef CONFIG_TRANSPARENT_HUGEPAGE
> #define SWAPFILE_CLUSTER	HPAGE_PMD_NR
> #else
> #define SWAPFILE_CLUSTER	256
> #endif

I make the value of SWAPFILE_CLUSTER depends on architecture, because I
don't know whether it is good to change it to enable THP optimization
for some architectures.  For example, in MIPS, the huge page size could
be as large as 1 << (16 + 16 -3 ) == 512M.  I suspect it is reasonable
to make swap cluster so big.  So I think it may be better to let
architecture to determine when to enable THP swap optimization.

>> @@ -18,6 +18,13 @@ struct swap_cgroup {
>>  };
>>  #define SC_PER_PAGE	(PAGE_SIZE/sizeof(struct swap_cgroup))
>>  
>> +struct swap_cgroup_iter {
>> +	struct swap_cgroup_ctrl *ctrl;
>> +	struct swap_cgroup *sc;
>> +	swp_entry_t entry;
>> +	unsigned long flags;
>> +};
>> +
>>  /*
>>   * SwapCgroup implements "lookup" and "exchange" operations.
>>   * In typical usage, this swap_cgroup is accessed via memcg's charge/uncharge
>> @@ -75,6 +82,35 @@ static struct swap_cgroup *lookup_swap_c
>>  	return sc + offset % SC_PER_PAGE;
>>  }
>>  
>> +static void swap_cgroup_iter_init(struct swap_cgroup_iter *iter,
>> +				  swp_entry_t ent)
>> +{
>> +	iter->entry = ent;
>> +	iter->sc = lookup_swap_cgroup(ent, &iter->ctrl);
>> +	spin_lock_irqsave(&iter->ctrl->lock, iter->flags);
>> +}
>> +
>> +static void swap_cgroup_iter_exit(struct swap_cgroup_iter *iter)
>> +{
>> +	spin_unlock_irqrestore(&iter->ctrl->lock, iter->flags);
>> +}
>> +
>> +/*
>> + * swap_cgroup is stored in a kind of discontinuous array.  That is,
>> + * they are continuous in one page, but not across page boundary.  And
>> + * there is one lock for each page.
>> + */
>> +static void swap_cgroup_iter_advance(struct swap_cgroup_iter *iter)
>> +{
>> +	iter->sc++;
>> +	iter->entry.val++;
>> +	if (!(((unsigned long)iter->sc) & PAGE_MASK)) {
>> +		spin_unlock_irqrestore(&iter->ctrl->lock, iter->flags);
>> +		iter->sc = lookup_swap_cgroup(iter->entry, &iter->ctrl);
>> +		spin_lock_irqsave(&iter->ctrl->lock, iter->flags);
>> +	}
>> +}
>> +
>>  /**
>>   * swap_cgroup_cmpxchg - cmpxchg mem_cgroup's id for this swp_entry.
>>   * @ent: swap entry to be cmpxchged
>> @@ -87,45 +123,49 @@ static struct swap_cgroup *lookup_swap_c
>>  unsigned short swap_cgroup_cmpxchg(swp_entry_t ent,
>>  					unsigned short old, unsigned short new)
>>  {
>> -	struct swap_cgroup_ctrl *ctrl;
>> -	struct swap_cgroup *sc;
>> -	unsigned long flags;
>> +	struct swap_cgroup_iter iter;
>>  	unsigned short retval;
>>  
>> -	sc = lookup_swap_cgroup(ent, &ctrl);
>> +	swap_cgroup_iter_init(&iter, ent);
>>  
>> -	spin_lock_irqsave(&ctrl->lock, flags);
>> -	retval = sc->id;
>> +	retval = iter.sc->id;
>>  	if (retval == old)
>> -		sc->id = new;
>> +		iter.sc->id = new;
>>  	else
>>  		retval = 0;
>> -	spin_unlock_irqrestore(&ctrl->lock, flags);
>> +
>> +	swap_cgroup_iter_exit(&iter);
>>  	return retval;
>>  }
>>  
>>  /**
>> - * swap_cgroup_record - record mem_cgroup for this swp_entry.
>> - * @ent: swap entry to be recorded into
>> + * swap_cgroup_record - record mem_cgroup for a set of swap entries
>> + * @ent: the first swap entry to be recorded into
>>   * @id: mem_cgroup to be recorded
>> + * @nr_ents: number of swap entries to be recorded
>>   *
>>   * Returns old value at success, 0 at failure.
>>   * (Of course, old value can be 0.)
>>   */
>> -unsigned short swap_cgroup_record(swp_entry_t ent, unsigned short id)
>> +unsigned short swap_cgroup_record(swp_entry_t ent, unsigned short id,
>> +				  unsigned int nr_ents)
>>  {
>> -	struct swap_cgroup_ctrl *ctrl;
>> -	struct swap_cgroup *sc;
>> +	struct swap_cgroup_iter iter;
>>  	unsigned short old;
>> -	unsigned long flags;
>>  
>> -	sc = lookup_swap_cgroup(ent, &ctrl);
>> +	swap_cgroup_iter_init(&iter, ent);
>>  
>> -	spin_lock_irqsave(&ctrl->lock, flags);
>> -	old = sc->id;
>> -	sc->id = id;
>> -	spin_unlock_irqrestore(&ctrl->lock, flags);
>> +	old = iter.sc->id;
>> +	for (;;) {
>> +		VM_BUG_ON(iter.sc->id != old);
>> +		iter.sc->id = id;
>> +		nr_ents--;
>> +		if (!nr_ents)
>> +			break;
>> +		swap_cgroup_iter_advance(&iter);
>> +	}
>>  
>> +	swap_cgroup_iter_exit(&iter);
>>  	return old;
>>  }
>
> The iterator seems overkill for one real user, and it's undesirable in
> the single-slot access from swap_cgroup_cmpxchg(). How about something
> like the following?
>
> static struct swap_cgroup *lookup_swap_cgroup(struct swap_cgroup_ctrl *ctrl,
> 					      pgoff_t offset)
> {
> 	struct page *page;
>
> 	page = page_address(ctrl->map[offset / SC_PER_PAGE]);
> 	return page + (offset % SC_PER_PAGE);
> }
>
> unsigned short swap_cgroup_cmpxchg(swp_entry_t ent,
> 					unsigned short old, unsigned short new)
> {
> 	struct swap_cgroup_ctrl *ctrl;
> 	struct swap_cgroup *sc;
> 	unsigned long flags;
> 	unsigned short retval;
> 	pgoff_t off = swp_offset(ent);
>
> 	ctrl = &swap_cgroup_ctrl[swp_type(ent)];
> 	sc = lookup_swap_cgroup(ctrl, swp_offset(ent));
>
> 	spin_lock_irqsave(&ctrl->lock, flags);
> 	retval = sc->id;
> 	if (retval == old)
> 		sc->id = new;
> 	else
> 		retval = 0;
> 	spin_unlock_irqrestore(&ctrl->lock, flags);
>
> 	return retval;
> }
>
> unsigned short swap_cgroup_record(swp_entry_t ent, unsigned short id,
> 				  unsigned int nr_entries)
> {
> 	struct swap_cgroup_ctrl *ctrl;
> 	struct swap_cgroup *sc;
> 	unsigned short old;
> 	unsigned long flags;
>
> 	ctrl = &swap_cgroup_ctrl[swp_type(ent)];
> 	sc = lookup_swap_cgroup(ctrl, offset);
> 	end = offset + nr_entries;
>
> 	spin_lock_irqsave(&ctrl->lock, flags);
> 	old = sc->id;
> 	while (offset != end) {
> 		sc->id = id;
> 		offset++;
> 		if (offset % SC_PER_PAGE)
> 			sc++;
> 		else
> 			sc = lookup_swap_cgroup(ctrl, offset);
> 	}
> 	spin_unlock_irqrestore(&ctrl->lock, flags);
>
> 	return old;
> }

Yes.  You are right.  I mis-understood the locking semantics of swap
cgroup before.  Thanks for pointing out that.  I will change it in the
next version.

>> @@ -145,20 +162,66 @@ void __delete_from_swap_cache(struct pag
>>  
>>  	entry.val = page_private(page);
>>  	address_space = swap_address_space(entry);
>> -	radix_tree_delete(&address_space->page_tree, page_private(page));
>> -	set_page_private(page, 0);
>>  	ClearPageSwapCache(page);
>> -	address_space->nrpages--;
>> -	__dec_node_page_state(page, NR_FILE_PAGES);
>> -	INC_CACHE_INFO(del_total);
>> +	for (i = 0; i < nr; i++) {
>> +		struct page *cur_page = page + i;
>> +
>> +		radix_tree_delete(&address_space->page_tree,
>> +				  page_private(cur_page));
>> +		set_page_private(cur_page, 0);
>> +	}
>> +	address_space->nrpages -= nr;
>> +	__mod_node_page_state(page_pgdat(page), NR_FILE_PAGES, -nr);
>> +	ADD_CACHE_INFO(del_total, nr);
>> +}
>> +
>> +#ifdef CONFIG_THP_SWAP_CLUSTER
>> +int add_to_swap_trans_huge(struct page *page, struct list_head *list)
>> +{
>> +	swp_entry_t entry;
>> +	int ret = 0;
>> +
>> +	/* cannot split, which may be needed during swap in, skip it */
>> +	if (!can_split_huge_page(page))
>> +		return -EBUSY;
>> +	/* fallback to split huge page firstly if no PMD map */
>> +	if (!compound_mapcount(page))
>> +		return 0;
>
> The can_split_huge_page() (and maybe also the compound_mapcount())
> optimizations look like they could be split out into separate followup
> patches. They're definitely nice to have, but don't seem necessary to
> make this patch minimally complete.

Yes.  Will change this.

>> @@ -168,11 +231,23 @@ int add_to_swap(struct page *page, struc
>>  	VM_BUG_ON_PAGE(!PageLocked(page), page);
>>  	VM_BUG_ON_PAGE(!PageUptodate(page), page);
>>  
>> +	if (unlikely(PageTransHuge(page))) {
>> +		err = add_to_swap_trans_huge(page, list);
>> +		switch (err) {
>> +		case 1:
>> +			return 1;
>> +		case 0:
>> +			/* fallback to split firstly if return 0 */
>> +			break;
>> +		default:
>> +			return 0;
>> +		}
>> +	}
>>  	entry = get_swap_page();
>>  	if (!entry.val)
>>  		return 0;
>>  
>> -	if (mem_cgroup_try_charge_swap(page, entry)) {
>> +	if (mem_cgroup_try_charge_swap(page, entry, 1)) {
>>  		swapcache_free(entry);
>>  		return 0;
>>  	}
>
> Instead of duplicating the control flow at such a high level -
> add_to_swap() and add_to_swap_trans_huge() are basically identical -
> it's better push down the THP handling as low as possible:
>
> Pass the page to get_swap_page(), and then decide in there whether
> it's THP and you need to allocate a single entry or a cluster.
>
> And mem_cgroup_try_charge_swap() already gets the page. Again, check
> in there how much swap to charge based on the passed page instead of
> passing the same information twice.
>
> Doing that will change the structure of the patch too much to review
> the paths below in their current form. I'll have a closer look in the
> next version.

The original swap code will allocate one swap slot and try to charge the
one swap entry in the swap cgroup for a THP.  We will continue to use
that code path if we failed to allocate a swap cluster for a THP.
Although it is possible to change the original logic to split the THP
before allocating swap slot and charging in the swap cgroup, but I don't
think that should be in this patchset.  And whether it is good to do
that is questionable.

Best Regards,
Huang, Ying

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

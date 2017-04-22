Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f197.google.com (mail-io0-f197.google.com [209.85.223.197])
	by kanga.kvack.org (Postfix) with ESMTP id 9AB57831F3
	for <linux-mm@kvack.org>; Fri, 21 Apr 2017 20:07:17 -0400 (EDT)
Received: by mail-io0-f197.google.com with SMTP id 194so157491359iof.21
        for <linux-mm@kvack.org>; Fri, 21 Apr 2017 17:07:17 -0700 (PDT)
Received: from mga09.intel.com (mga09.intel.com. [134.134.136.24])
        by mx.google.com with ESMTPS id q75si11630885pgq.338.2017.04.21.17.07.16
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 21 Apr 2017 17:07:16 -0700 (PDT)
From: "Huang\, Ying" <ying.huang@intel.com>
Subject: Re: [PATCH -mm -v9 1/3] mm, THP, swap: Delay splitting THP during swap out
References: <20170419070625.19776-1-ying.huang@intel.com>
	<20170419070625.19776-2-ying.huang@intel.com>
	<1492755096.24636.2.camel@gmail.com>
	<20170421140812.GA15918@cmpxchg.org>
Date: Sat, 22 Apr 2017 08:07:12 +0800
In-Reply-To: <20170421140812.GA15918@cmpxchg.org> (Johannes Weiner's message
	of "Fri, 21 Apr 2017 10:08:12 -0400")
Message-ID: <87bmrpe24v.fsf@yhuang-dev.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=ascii
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Balbir Singh <bsingharora@gmail.com>, "Huang, Ying" <ying.huang@intel.com>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Andrea Arcangeli <aarcange@redhat.com>, Ebru Akagunduz <ebru.akagunduz@gmail.com>, Michal Hocko <mhocko@kernel.org>, Tejun Heo <tj@kernel.org>, Hugh Dickins <hughd@google.com>, Shaohua Li <shli@kernel.org>, Minchan Kim <minchan@kernel.org>, Rik van Riel <riel@redhat.com>, cgroups@vger.kernel.org

Johannes Weiner <hannes@cmpxchg.org> writes:

> On Fri, Apr 21, 2017 at 04:11:36PM +1000, Balbir Singh wrote:
>> > In the future of THP swap optimization, some information of the
>> > swapped out THP (such as compound map count) will be recorded in the
>> > swap_cluster_info data structure.
>> > 
>> > The mem cgroup swap accounting functions are enhanced to support
>> > charge or uncharge a swap cluster backing a THP as a whole.
>> 
>> Thanks and in the future it will be good to add stats to indicate
>> the number of THP swapped out for tracking.
>
> Agreed. Huang, can you include stats from your test that show how many
> times we succeed and how many times we fall back to splitting?

Sorry, I don't fully understand your words.  If my understanding were
correct, Balbir is asking some stats in /proc/vmstat.  For now, the
stats we can provide is how many success swap cluster allocations and
swap cache addings, and how many fails for them.  And in the next step
(to split THP after swapping out), we can add stats for how many THP
swapped out (written with 2M IO and reclaimed).  So I suggest to add two
stats, thp_swpout and thp_swpout_fallback in the next step.  What do you
think about that?

>> > With the patch, the swap out throughput improves 11.5% (from about
>> > 3.73GB/s to about 4.16GB/s) in the vm-scalability swap-w-seq test case
>> > with 8 processes.  The test is done on a Xeon E5 v3 system.  The swap
>> > device used is a RAM simulated PMEM (persistent memory) device. 
>> 
>> I am not sure if RAM simulating PMEM is a fair way to test, its just
>> memcpy and no swap out.
>
> It would be good to know exactly what simulating PMEM means. Does it
> add some artificial delay, or is it a simple ramfs that holds a swap
> file?

No artificial delay, just a RAM simulated block device implemented with
memcpy.

> IMO, this patch isn't a pure cycles-optimization anyway in the "reduce
> instructions involved in this path" sense. It's the groundwork to make
> swapping THP-native. So slimming down the cycles is great, but the
> infrastructure work to later do 2MB TLB shootdown and swap with 2MB IO
> holds more weight for me.

Yes.  Performance improvement is not the emphasis of this step, but will
be of the next step.

>> > @@ -326,11 +326,14 @@ PAGEFLAG_FALSE(HighMem)
>> >  #ifdef CONFIG_SWAP
>> >  static __always_inline int PageSwapCache(struct page *page)
>> >  {
>> > +#ifdef CONFIG_THP_SWAP
>> > +	page = compound_head(page);
>> > +#endif
>> 
>> Can we please add a static inline THPSwapPage() that returns page_compound(page)
>> for CONFIG_THP_SWAP and page otherwise?
>
> Where else would it be used?
>
> I think it'd be preferable to leave this #ifdef wart as a reminder
> that we need to revisit this.
>
>> > @@ -5929,25 +5929,26 @@ int mem_cgroup_try_charge_swap(struct page *page, swp_entry_t entry)
>> >  	memcg = mem_cgroup_id_get_online(memcg);
>> >  
>> >  	if (!mem_cgroup_is_root(memcg) &&
>> > -	    !page_counter_try_charge(&memcg->swap, 1, &counter)) {
>> > +	    !page_counter_try_charge(&memcg->swap, nr_pages, &counter)) {
>> >  		mem_cgroup_id_put(memcg);
>> >  		return -ENOMEM;
>> >  	}
>> >  
>> > -	oldid = swap_cgroup_record(entry, mem_cgroup_id(memcg));
>> > +	if (nr_pages > 1)
>> > +		mem_cgroup_id_get_many(memcg, nr_pages - 1);
>> 
>> The nr_pages -1 is not initutive, a comment about mem_cgroup_id_get_online()
>> getting 1 would help.
>
> Agreed. Something like this might help:
>
> 	/* Get references for the tail pages, too */

Good suggestion!  I will add this.

>> > @@ -1066,6 +1155,33 @@ void swapcache_free(swp_entry_t entry)
>> >  	}
>> >  }
>> >  
>> > +#ifdef CONFIG_THP_SWAP
>> > +void swapcache_free_cluster(swp_entry_t entry)
>> > +{
>> > +	unsigned long offset = swp_offset(entry);
>> > +	unsigned long idx = offset / SWAPFILE_CLUSTER;
>> > +	struct swap_cluster_info *ci;
>> > +	struct swap_info_struct *si;
>> > +	unsigned char *map;
>> > +	unsigned int i;
>> > +
>> > +	si = swap_info_get(entry);
>> > +	if (!si)
>> > +		return;
>> > +
>> > +	ci = lock_cluster(si, offset);
>> > +	map = si->swap_map + offset;
>> > +	for (i = 0; i < SWAPFILE_CLUSTER; i++) {
>> > +		VM_BUG_ON(map[i] != SWAP_HAS_CACHE);
>> > +		map[i] = 0;
>> > +	}
>> > +	unlock_cluster(ci);
>> > +	mem_cgroup_uncharge_swap(entry, SWAPFILE_CLUSTER);
>> > +	swap_free_cluster(si, idx);
>> > +	spin_unlock(&si->lock);
>> > +}
>> > +#endif /* CONFIG_THP_SWAP */
>> > +
>> >  static int swp_entry_cmp(const void *ent1, const void *ent2)
>> >  {
>> >  	const swp_entry_t *e1 = ent1, *e2 = ent2;
>> 
>> 
>> This is a massive patch, I presume you've got recommendations to keep it
>> this way?
>
> It used to be split into patches that introduce API and helpers on one
> hand and patches that use these functions on the other hand. That was
> impossible to review, because you had to jump between emails.
>
> If you have ideas about which parts could be split out and be
> stand-alone changes in their own right, I'd be all for that.

Best Regards,
Huang, Ying

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

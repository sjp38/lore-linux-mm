Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f71.google.com (mail-pg0-f71.google.com [74.125.83.71])
	by kanga.kvack.org (Postfix) with ESMTP id 013746B0069
	for <linux-mm@kvack.org>; Thu,  5 Jan 2017 01:32:04 -0500 (EST)
Received: by mail-pg0-f71.google.com with SMTP id 5so1460597831pgi.2
        for <linux-mm@kvack.org>; Wed, 04 Jan 2017 22:32:03 -0800 (PST)
Received: from lgeamrelo12.lge.com (LGEAMRELO12.lge.com. [156.147.23.52])
        by mx.google.com with ESMTP id a12si48245818pgd.80.2017.01.04.22.32.02
        for <linux-mm@kvack.org>;
        Wed, 04 Jan 2017 22:32:03 -0800 (PST)
Date: Thu, 5 Jan 2017 15:32:00 +0900
From: Minchan Kim <minchan@kernel.org>
Subject: Re: [PATCH v4 0/9] mm/swap: Regular page swap optimizations
Message-ID: <20170105063200.GE24371@bbox>
References: <cover.1481317367.git.tim.c.chen@linux.intel.com>
 <20161227074503.GA10616@bbox>
 <8760lujnng.fsf@yhuang-dev.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <8760lujnng.fsf@yhuang-dev.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Huang, Ying" <ying.huang@intel.com>
Cc: Tim Chen <tim.c.chen@linux.intel.com>, Andrew Morton <akpm@linux-foundation.org>, dave.hansen@intel.com, ak@linux.intel.com, aaron.lu@intel.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Hugh Dickins <hughd@google.com>, Shaohua Li <shli@kernel.org>, Rik van Riel <riel@redhat.com>, Andrea Arcangeli <aarcange@redhat.com>, "Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>, Vladimir Davydov <vdavydov.dev@gmail.com>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@kernel.org>, Hillf Danton <hillf.zj@alibaba-inc.com>, Christian Borntraeger <borntraeger@de.ibm.com>, Jonathan Corbet <corbet@lwn.net>, jack@suse.cz

Hi,

On Thu, Jan 05, 2017 at 09:33:55AM +0800, Huang, Ying wrote:
> Hi, Minchan,
> 
> Minchan Kim <minchan@kernel.org> writes:
> [snip]
> >
> > The patchset has used several techniqueus to reduce lock contention, for example,
> > batching alloc/free, fine-grained lock and cluster distribution to avoid cache
> > false-sharing. Each items has different complexity and benefits so could you
> > show the number for each step of pathchset? It would be better to include the
> > nubmer in each description. It helps how the patch is important when we consider
> > complexitiy of the patch.
> 
> Here is the test data.

Thanks!

> 
> We test the vm-scalability swap-w-seq test case with 32 processes on a
> Xeon E5 v3 system.  The swap device used is a RAM simulated PMEM
> (persistent memory) device.  To test the sequential swapping out, the
> test case created 32 processes, which sequentially allocate and write to
> the anonymous pages until the RAM and part of the swap device is used
> up.
> 
> The patchset is rebased on v4.9-rc8.  So the baseline performance is as
> follow,
> 
>   "vmstat.swap.so": 1428002,

What does it mean? vmstat.pswpout?

>   "perf-profile.calltrace.cycles-pp._raw_spin_lock_irq.__add_to_swap_cache.add_to_swap_cache.add_to_swap.shrink_page_list": 13.94,
>   "perf-profile.calltrace.cycles-pp._raw_spin_lock_irqsave.__remove_mapping.shrink_page_list.shrink_inactive_list.shrink_node_memcg": 13.75,
>   "perf-profile.calltrace.cycles-pp._raw_spin_lock.swap_info_get.swapcache_free.__remove_mapping.shrink_page_list": 7.05,
>   "perf-profile.calltrace.cycles-pp._raw_spin_lock.swap_info_get.page_swapcount.try_to_free_swap.swap_writepage": 7.03,
>   "perf-profile.calltrace.cycles-pp._raw_spin_lock.__swap_duplicate.swap_duplicate.try_to_unmap_one.rmap_walk_anon": 7.02,
>   "perf-profile.calltrace.cycles-pp._raw_spin_lock.get_swap_page.add_to_swap.shrink_page_list.shrink_inactive_list": 6.83,
>   "perf-profile.calltrace.cycles-pp._raw_spin_lock.page_check_address_transhuge.page_referenced_one.rmap_walk_anon.rmap_walk": 0.81,

Numbers mean overhead percentage reported by perf?

> 
> >> Patch 1 is a clean up patch.
> >
> > Could it be separated patch?
> >
> >> Patch 2 creates a lock per cluster, this gives us a more fine graind lock
> >>         that can be used for accessing swap_map, and not lock the whole
> >>         swap device
> 
> After patch 2, the result is as follow,
> 
>   "vmstat.swap.so": 1481704,
>   "perf-profile.calltrace.cycles-pp._raw_spin_lock_irq.__add_to_swap_cache.add_to_swap_cache.add_to_swap.shrink_page_list": 27.53,
>   "perf-profile.calltrace.cycles-pp._raw_spin_lock_irqsave.__remove_mapping.shrink_page_list.shrink_inactive_list.shrink_node_memcg": 27.01,
>   "perf-profile.calltrace.cycles-pp._raw_spin_lock.free_pcppages_bulk.drain_pages_zone.drain_pages.drain_local_pages": 1.03,
> 
> The swap out throughput is at the same level, but the lock contention on
> swap_info_struct->lock is eliminated.
> 
> >> Patch 3 splits the swap cache radix tree into 64MB chunks, reducing
> >>         the rate that we have to contende for the radix tree.
> >
> 
> After patch 3,
> 
>   "vmstat.swap.so": 2050097,
>   "perf-profile.calltrace.cycles-pp._raw_spin_lock.get_swap_page.add_to_swap.shrink_page_list.shrink_inactive_list": 43.27,
>   "perf-profile.calltrace.cycles-pp._raw_spin_lock.get_page_from_freelist.__alloc_pages_nodemask.alloc_pages_vma.handle_mm_fault": 4.84,
> 
> The swap out throughput is improved about ~43% compared with baseline.
> The lock contention on swap cache radix tree lock is eliminated.
> swap_info_struct->lock in get_swap_page() becomes the most heavy
> contended lock.

The numbers are great! Please include those into each patchset.
And I ask one more thing I said earlier about patch 2.

""
I hope you make three steps to review easier. You can create some functions like
swap_map_lock and cluster_lock which are wrapper functions just hold swap_lock.
It doesn't change anything performance pov but it clearly shows what kinds of lock
we should use in specific context.

Then, you can introduce more fine-graind lock in next patch and apply it into
those wrapper functions.
 
And last patch, you can adjust cluster distribution to avoid false-sharing.
And the description should include how it's bad in testing so it's worth.
""

It makes review more easier, I believe.

> 
> >
> >> Patch 4 eliminates unnecessary page allocation for read ahead.
> >
> > Could it be separated patch?
> >
> >> Patch 5-9 create a per cpu cache of the swap slots, so we don't have
> >>         to contend on the swap device to get a swap slot or to release
> >>         a swap slot.  And we allocate and release the swap slots
> >>         in batches for better efficiency.
> 
> After patch 9,
> 
>   "vmstat.swap.so": 4170746,
>   "perf-profile.calltrace.cycles-pp._raw_spin_lock.swapcache_free_entries.free_swap_slot.free_swap_and_cache.unmap_page_range": 13.91,
>   "perf-profile.calltrace.cycles-pp._raw_spin_lock.get_page_from_freelist.__alloc_pages_nodemask.alloc_pages_vma.handle_mm_fault": 8.56,
>   "perf-profile.calltrace.cycles-pp._raw_spin_lock.get_page_from_freelist.__alloc_pages_slowpath.__alloc_pages_nodemask.alloc_pages_vma": 2.56,
>   "perf-profile.calltrace.cycles-pp._raw_spin_lock.get_swap_pages.get_swap_page.add_to_swap.shrink_page_list": 2.47,
> 
> The swap out throughput is improved about 192% compared with the
> baseline.  There are still some lock contention for
> swap_info_struct->lock, but the pressure begins to shift to buddy system
> now.
> 
> Best Regards,
> Huang, Ying
> 
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

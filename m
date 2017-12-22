Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f69.google.com (mail-pl0-f69.google.com [209.85.160.69])
	by kanga.kvack.org (Postfix) with ESMTP id 5AE9E6B0038
	for <linux-mm@kvack.org>; Fri, 22 Dec 2017 09:14:49 -0500 (EST)
Received: by mail-pl0-f69.google.com with SMTP id q12so13595958pli.12
        for <linux-mm@kvack.org>; Fri, 22 Dec 2017 06:14:49 -0800 (PST)
Received: from mga09.intel.com (mga09.intel.com. [134.134.136.24])
        by mx.google.com with ESMTPS id s17si15363793pge.556.2017.12.22.06.14.47
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 22 Dec 2017 06:14:48 -0800 (PST)
From: "Huang\, Ying" <ying.huang@intel.com>
Subject: Re: [PATCH -V4 -mm] mm, swap: Fix race between swapoff and some swap operations
References: <20171220012632.26840-1-ying.huang@intel.com>
	<20171221021619.GA27475@bbox> <871sjopllj.fsf@yhuang-dev.intel.com>
	<20171221235813.GA29033@bbox>
Date: Fri, 22 Dec 2017 22:14:43 +0800
In-Reply-To: <20171221235813.GA29033@bbox> (Minchan Kim's message of "Fri, 22
	Dec 2017 08:58:13 +0900")
Message-ID: <87r2rmj1d8.fsf@yhuang-dev.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=ascii
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Hugh Dickins <hughd@google.com>, "Paul
 E . McKenney" <paulmck@linux.vnet.ibm.com>, Johannes Weiner <hannes@cmpxchg.org>, Tim Chen <tim.c.chen@linux.intel.com>, Shaohua Li <shli@fb.com>, Mel Gorman <mgorman@techsingularity.net>, =?utf-8?B?Sg==?= =?utf-8?B?77+9cu+/vW1l?= Glisse <jglisse@redhat.com>, Michal Hocko <mhocko@suse.com>, Andrea Arcangeli <aarcange@redhat.com>, David Rientjes <rientjes@google.com>, Rik van Riel <riel@redhat.com>, Jan Kara <jack@suse.cz>, Dave Jiang <dave.jiang@intel.com>, Aaron Lu <aaron.lu@intel.com>

Minchan Kim <minchan@kernel.org> writes:

> On Thu, Dec 21, 2017 at 03:48:56PM +0800, Huang, Ying wrote:
>> Minchan Kim <minchan@kernel.org> writes:
>> 
>> > On Wed, Dec 20, 2017 at 09:26:32AM +0800, Huang, Ying wrote:
>> >> From: Huang Ying <ying.huang@intel.com>
>> >> 
>> >> When the swapin is performed, after getting the swap entry information
>> >> from the page table, system will swap in the swap entry, without any
>> >> lock held to prevent the swap device from being swapoff.  This may
>> >> cause the race like below,
>> >> 
>> >> CPU 1				CPU 2
>> >> -----				-----
>> >> 				do_swap_page
>> >> 				  swapin_readahead
>> >> 				    __read_swap_cache_async
>> >> swapoff				      swapcache_prepare
>> >>   p->swap_map = NULL		        __swap_duplicate
>> >> 					  p->swap_map[?] /* !!! NULL pointer access */
>> >> 
>> >> Because swapoff is usually done when system shutdown only, the race
>> >> may not hit many people in practice.  But it is still a race need to
>> >> be fixed.
>> >> 
>> >> To fix the race, get_swap_device() is added to check whether the
>> >> specified swap entry is valid in its swap device.  If so, it will keep
>> >> the swap entry valid via preventing the swap device from being
>> >> swapoff, until put_swap_device() is called.
>> >> 
>> >> Because swapoff() is very race code path, to make the normal path runs
>> >> as fast as possible, RCU instead of reference count is used to
>> >> implement get/put_swap_device().  From get_swap_device() to
>> >> put_swap_device(), the RCU read lock is held, so synchronize_rcu() in
>> >> swapoff() will wait until put_swap_device() is called.
>> >> 
>> >> In addition to swap_map, cluster_info, etc. data structure in the
>> >> struct swap_info_struct, the swap cache radix tree will be freed after
>> >> swapoff, so this patch fixes the race between swap cache looking up
>> >> and swapoff too.
>> >> 
>> >> Cc: Hugh Dickins <hughd@google.com>
>> >> Cc: Paul E. McKenney <paulmck@linux.vnet.ibm.com>
>> >> Cc: Minchan Kim <minchan@kernel.org>
>> >> Cc: Johannes Weiner <hannes@cmpxchg.org>
>> >> Cc: Tim Chen <tim.c.chen@linux.intel.com>
>> >> Cc: Shaohua Li <shli@fb.com>
>> >> Cc: Mel Gorman <mgorman@techsingularity.net>
>> >> Cc: "Jrme Glisse" <jglisse@redhat.com>
>> >> Cc: Michal Hocko <mhocko@suse.com>
>> >> Cc: Andrea Arcangeli <aarcange@redhat.com>
>> >> Cc: David Rientjes <rientjes@google.com>
>> >> Cc: Rik van Riel <riel@redhat.com>
>> >> Cc: Jan Kara <jack@suse.cz>
>> >> Cc: Dave Jiang <dave.jiang@intel.com>
>> >> Cc: Aaron Lu <aaron.lu@intel.com>
>> >> Signed-off-by: "Huang, Ying" <ying.huang@intel.com>
>> >> 
>> >> Changelog:
>> >> 
>> >> v4:
>> >> 
>> >> - Use synchronize_rcu() in enable_swap_info() to reduce overhead of
>> >>   normal paths further.
>> >
>> > Hi Huang,
>> 
>> Hi, Minchan,
>> 
>> > This version is much better than old. To me, it's due to not rcu,
>> > srcu, refcount thing but it adds swap device dependency(i.e., get/put)
>> > into every swap related functions so users who don't interested on swap
>> > don't need to care of it. Good.
>> >
>> > The problem is caused by freeing by swap related-data structure
>> > *dynamically* while old swap logic was based on static data
>> > structure(i.e., never freed and the verify it's stale).
>> > So, I reviewed some places where use PageSwapCache and swp_entry_t
>> > which could make access of swap related data structures.
>> >
>> > A example is __isolate_lru_page
>> >
>> > It calls page_mapping to get a address_space.
>> > What happens if the page is on SwapCache and raced with swapoff?
>> > The mapping got could be disappeared by the race. Right?
>> 
>> Yes.  We should think about that.  Considering the file cache pages, the
>> address_space backing the file cache pages may be freed dynamically too.
>> So to use page_mapping() return value for the file cache pages, some
>> kind of locking is needed to guarantee the address_space isn't freed
>> under us.  Page may be locked, or under writeback, or some other locks
>
> I didn't look at the code in detail but I guess every file page should
> be freed before the address space destruction and page_lock/lru_lock makes
> the work safe, I guess. So, it wouldn't be a problem.
>
> However, in case of swapoff, it doesn't remove pages from LRU list
> so there is no lock to prevent the race at this moment. :(

Take a look at file cache pages and file cache address_space freeing
code path.  It appears that similar situation is possible for them too.

The file cache pages will be delete from file cache address_space before
address_space (embedded in inode) is freed.  But they will be deleted
from LRU list only when its refcount dropped to zero, please take a look
at put_page() and release_pages().  While address_space will be freed
after putting reference to all file cache pages.  If someone holds a
reference to a file cache page for quite long time, it is possible for a
file cache page to be in LRU list after the inode/address_space is
freed.

And I found inode/address_space is freed witch call_rcu().  I don't know
whether this is related to page_mapping().

This is just my understanding.

>> need to be held, for example, page table lock, or lru_lock, etc.  For
>> __isolate_lru_page(), lru_lock will be held when it is called.  And we
>> will call synchronize_rcu() between clear PageSwapCache and free swap
>> cache, so the usage of swap cache in __isolate_lru_page() should be
>> safe.  Do you think my analysis makes sense?
>
> I don't understand how synchronize_rcu closes the race with spin_lock.
> Paul might help it.

Per my understanding, spin_lock() will preempt_disable(), so
synchronize_rcu() will wait until spin_unlock() is called.

> Even if we solve it, there is a other problem I spot.
> When I see migrate_vma_pages, it pass mapping to migrate_page which
> accesses mapping->tree_lock unconditionally even though the address_space
> is already gone.

Before migrate_vma_pages() is called, migrate_vma_prepare() is called,
where pages are locked.  So it is safe.

> Hmm, I didn't check all sites where uses PageSwapCache, swp_entry_t
> but gut feeling is it would be not simple.

Yes.  We should check all sites.  Thanks for your help!

Best Regards,
Huang, Ying

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f69.google.com (mail-pg0-f69.google.com [74.125.83.69])
	by kanga.kvack.org (Postfix) with ESMTP id 2C2AA6B0038
	for <linux-mm@kvack.org>; Thu, 21 Dec 2017 18:58:16 -0500 (EST)
Received: by mail-pg0-f69.google.com with SMTP id j7so16562176pgv.20
        for <linux-mm@kvack.org>; Thu, 21 Dec 2017 15:58:16 -0800 (PST)
Received: from lgeamrelo11.lge.com (LGEAMRELO11.lge.com. [156.147.23.51])
        by mx.google.com with ESMTP id k2si15839846pll.11.2017.12.21.15.58.14
        for <linux-mm@kvack.org>;
        Thu, 21 Dec 2017 15:58:14 -0800 (PST)
Date: Fri, 22 Dec 2017 08:58:13 +0900
From: Minchan Kim <minchan@kernel.org>
Subject: Re: [PATCH -V4 -mm] mm, swap: Fix race between swapoff and some swap
 operations
Message-ID: <20171221235813.GA29033@bbox>
References: <20171220012632.26840-1-ying.huang@intel.com>
 <20171221021619.GA27475@bbox>
 <871sjopllj.fsf@yhuang-dev.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <871sjopllj.fsf@yhuang-dev.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Huang, Ying" <ying.huang@intel.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Hugh Dickins <hughd@google.com>, "Paul E . McKenney" <paulmck@linux.vnet.ibm.com>, Johannes Weiner <hannes@cmpxchg.org>, Tim Chen <tim.c.chen@linux.intel.com>, Shaohua Li <shli@fb.com>, Mel Gorman <mgorman@techsingularity.net>, =?utf-8?B?Su+/vXLvv71tZQ==?= Glisse <jglisse@redhat.com>, Michal Hocko <mhocko@suse.com>, Andrea Arcangeli <aarcange@redhat.com>, David Rientjes <rientjes@google.com>, Rik van Riel <riel@redhat.com>, Jan Kara <jack@suse.cz>, Dave Jiang <dave.jiang@intel.com>, Aaron Lu <aaron.lu@intel.com>

On Thu, Dec 21, 2017 at 03:48:56PM +0800, Huang, Ying wrote:
> Minchan Kim <minchan@kernel.org> writes:
> 
> > On Wed, Dec 20, 2017 at 09:26:32AM +0800, Huang, Ying wrote:
> >> From: Huang Ying <ying.huang@intel.com>
> >> 
> >> When the swapin is performed, after getting the swap entry information
> >> from the page table, system will swap in the swap entry, without any
> >> lock held to prevent the swap device from being swapoff.  This may
> >> cause the race like below,
> >> 
> >> CPU 1				CPU 2
> >> -----				-----
> >> 				do_swap_page
> >> 				  swapin_readahead
> >> 				    __read_swap_cache_async
> >> swapoff				      swapcache_prepare
> >>   p->swap_map = NULL		        __swap_duplicate
> >> 					  p->swap_map[?] /* !!! NULL pointer access */
> >> 
> >> Because swapoff is usually done when system shutdown only, the race
> >> may not hit many people in practice.  But it is still a race need to
> >> be fixed.
> >> 
> >> To fix the race, get_swap_device() is added to check whether the
> >> specified swap entry is valid in its swap device.  If so, it will keep
> >> the swap entry valid via preventing the swap device from being
> >> swapoff, until put_swap_device() is called.
> >> 
> >> Because swapoff() is very race code path, to make the normal path runs
> >> as fast as possible, RCU instead of reference count is used to
> >> implement get/put_swap_device().  From get_swap_device() to
> >> put_swap_device(), the RCU read lock is held, so synchronize_rcu() in
> >> swapoff() will wait until put_swap_device() is called.
> >> 
> >> In addition to swap_map, cluster_info, etc. data structure in the
> >> struct swap_info_struct, the swap cache radix tree will be freed after
> >> swapoff, so this patch fixes the race between swap cache looking up
> >> and swapoff too.
> >> 
> >> Cc: Hugh Dickins <hughd@google.com>
> >> Cc: Paul E. McKenney <paulmck@linux.vnet.ibm.com>
> >> Cc: Minchan Kim <minchan@kernel.org>
> >> Cc: Johannes Weiner <hannes@cmpxchg.org>
> >> Cc: Tim Chen <tim.c.chen@linux.intel.com>
> >> Cc: Shaohua Li <shli@fb.com>
> >> Cc: Mel Gorman <mgorman@techsingularity.net>
> >> Cc: "Jrme Glisse" <jglisse@redhat.com>
> >> Cc: Michal Hocko <mhocko@suse.com>
> >> Cc: Andrea Arcangeli <aarcange@redhat.com>
> >> Cc: David Rientjes <rientjes@google.com>
> >> Cc: Rik van Riel <riel@redhat.com>
> >> Cc: Jan Kara <jack@suse.cz>
> >> Cc: Dave Jiang <dave.jiang@intel.com>
> >> Cc: Aaron Lu <aaron.lu@intel.com>
> >> Signed-off-by: "Huang, Ying" <ying.huang@intel.com>
> >> 
> >> Changelog:
> >> 
> >> v4:
> >> 
> >> - Use synchronize_rcu() in enable_swap_info() to reduce overhead of
> >>   normal paths further.
> >
> > Hi Huang,
> 
> Hi, Minchan,
> 
> > This version is much better than old. To me, it's due to not rcu,
> > srcu, refcount thing but it adds swap device dependency(i.e., get/put)
> > into every swap related functions so users who don't interested on swap
> > don't need to care of it. Good.
> >
> > The problem is caused by freeing by swap related-data structure
> > *dynamically* while old swap logic was based on static data
> > structure(i.e., never freed and the verify it's stale).
> > So, I reviewed some places where use PageSwapCache and swp_entry_t
> > which could make access of swap related data structures.
> >
> > A example is __isolate_lru_page
> >
> > It calls page_mapping to get a address_space.
> > What happens if the page is on SwapCache and raced with swapoff?
> > The mapping got could be disappeared by the race. Right?
> 
> Yes.  We should think about that.  Considering the file cache pages, the
> address_space backing the file cache pages may be freed dynamically too.
> So to use page_mapping() return value for the file cache pages, some
> kind of locking is needed to guarantee the address_space isn't freed
> under us.  Page may be locked, or under writeback, or some other locks

I didn't look at the code in detail but I guess every file page should
be freed before the address space destruction and page_lock/lru_lock makes
the work safe, I guess. So, it wouldn't be a problem.

However, in case of swapoff, it doesn't remove pages from LRU list
so there is no lock to prevent the race at this moment. :(

> need to be held, for example, page table lock, or lru_lock, etc.  For
> __isolate_lru_page(), lru_lock will be held when it is called.  And we
> will call synchronize_rcu() between clear PageSwapCache and free swap
> cache, so the usage of swap cache in __isolate_lru_page() should be
> safe.  Do you think my analysis makes sense?

I don't understand how synchronize_rcu closes the race with spin_lock.
Paul might help it.

Even if we solve it, there is a other problem I spot.
When I see migrate_vma_pages, it pass mapping to migrate_page which
accesses mapping->tree_lock unconditionally even though the address_space
is already gone.

Hmm, I didn't check all sites where uses PageSwapCache, swp_entry_t
but gut feeling is it would be not simple.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

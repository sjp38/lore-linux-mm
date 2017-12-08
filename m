Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f71.google.com (mail-pg0-f71.google.com [74.125.83.71])
	by kanga.kvack.org (Postfix) with ESMTP id B527D6B025F
	for <linux-mm@kvack.org>; Fri,  8 Dec 2017 04:10:45 -0500 (EST)
Received: by mail-pg0-f71.google.com with SMTP id t9so7572699pgu.1
        for <linux-mm@kvack.org>; Fri, 08 Dec 2017 01:10:45 -0800 (PST)
Received: from lgeamrelo13.lge.com (LGEAMRELO13.lge.com. [156.147.23.53])
        by mx.google.com with ESMTP id n9si5234648pgf.425.2017.12.08.01.10.43
        for <linux-mm@kvack.org>;
        Fri, 08 Dec 2017 01:10:43 -0800 (PST)
Date: Fri, 8 Dec 2017 18:10:42 +0900
From: Minchan Kim <minchan@kernel.org>
Subject: Re: [PATCH -mm] mm, swap: Fix race between swapoff and some swap
 operations
Message-ID: <20171208091042.GA14472@bbox>
References: <20171207011426.1633-1-ying.huang@intel.com>
 <20171207162937.6a179063a7c92ecac77e44af@linux-foundation.org>
 <20171208014346.GA8915@bbox>
 <87po7pg4jt.fsf@yhuang-dev.intel.com>
 <20171208082644.GA14361@bbox>
 <87k1xxbohp.fsf@yhuang-dev.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <87k1xxbohp.fsf@yhuang-dev.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Huang, Ying" <ying.huang@intel.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Hugh Dickins <hughd@google.com>, Johannes Weiner <hannes@cmpxchg.org>, Tim Chen <tim.c.chen@linux.intel.com>, Shaohua Li <shli@fb.com>, Mel Gorman <mgorman@techsingularity.net>, =?utf-8?B?Su+/vXLvv71tZQ==?= Glisse <jglisse@redhat.com>, Michal Hocko <mhocko@suse.com>, Andrea Arcangeli <aarcange@redhat.com>, David Rientjes <rientjes@google.com>, Rik van Riel <riel@redhat.com>, Jan Kara <jack@suse.cz>, Dave Jiang <dave.jiang@intel.com>, Aaron Lu <aaron.lu@intel.com>

On Fri, Dec 08, 2017 at 04:41:38PM +0800, Huang, Ying wrote:
> Minchan Kim <minchan@kernel.org> writes:
> 
> > On Fri, Dec 08, 2017 at 01:41:10PM +0800, Huang, Ying wrote:
> >> Minchan Kim <minchan@kernel.org> writes:
> >> 
> >> > On Thu, Dec 07, 2017 at 04:29:37PM -0800, Andrew Morton wrote:
> >> >> On Thu,  7 Dec 2017 09:14:26 +0800 "Huang, Ying" <ying.huang@intel.com> wrote:
> >> >> 
> >> >> > When the swapin is performed, after getting the swap entry information
> >> >> > from the page table, the PTL (page table lock) will be released, then
> >> >> > system will go to swap in the swap entry, without any lock held to
> >> >> > prevent the swap device from being swapoff.  This may cause the race
> >> >> > like below,
> >> >> > 
> >> >> > CPU 1				CPU 2
> >> >> > -----				-----
> >> >> > 				do_swap_page
> >> >> > 				  swapin_readahead
> >> >> > 				    __read_swap_cache_async
> >> >> > swapoff				      swapcache_prepare
> >> >> >   p->swap_map = NULL		        __swap_duplicate
> >> >> > 					  p->swap_map[?] /* !!! NULL pointer access */
> >> >> > 
> >> >> > Because swap off is usually done when system shutdown only, the race
> >> >> > may not hit many people in practice.  But it is still a race need to
> >> >> > be fixed.
> >> >> 
> >> >> swapoff is so rare that it's hard to get motivated about any fix which
> >> >> adds overhead to the regular codepaths.
> >> >
> >> > That was my concern, too when I see this patch.
> >> >
> >> >> 
> >> >> Is there something we can do to ensure that all the overhead of this
> >> >> fix is placed into the swapoff side?  stop_machine() may be a bit
> >> >> brutal, but a surprising amount of code uses it.  Any other ideas?
> >> >
> >> > How about this?
> >> >
> >> > I think It's same approach with old where we uses si->lock everywhere
> >> > instead of more fine-grained cluster lock.
> >> >
> >> > The reason I repeated to reset p->max to zero in the loop is to avoid
> >> > using lockdep annotation(maybe, spin_lock_nested(something) to prevent
> >> > false positive.
> >> >
> >> > diff --git a/mm/swapfile.c b/mm/swapfile.c
> >> > index 42fe5653814a..9ce007a42bbc 100644
> >> > --- a/mm/swapfile.c
> >> > +++ b/mm/swapfile.c
> >> > @@ -2644,6 +2644,19 @@ SYSCALL_DEFINE1(swapoff, const char __user *, specialfile)
> >> >  	swap_file = p->swap_file;
> >> >  	old_block_size = p->old_block_size;
> >> >  	p->swap_file = NULL;
> >> > +
> >> > +	if (p->flags & SWP_SOLIDSTATE) {
> >> > +		unsigned long ci, nr_cluster;
> >> > +
> >> > +		nr_cluster = DIV_ROUND_UP(p->max, SWAPFILE_CLUSTER);
> >> > +		for (ci = 0; ci < nr_cluster; ci++) {
> >> > +			struct swap_cluster_info *sci;
> >> > +
> >> > +			sci = lock_cluster(p, ci * SWAPFILE_CLUSTER);
> >> > +			p->max = 0;
> >> > +			unlock_cluster(sci);
> >> > +		}
> >> > +	}
> >> >  	p->max = 0;
> >> >  	swap_map = p->swap_map;
> >> >  	p->swap_map = NULL;
> >> > @@ -3369,10 +3382,10 @@ static int __swap_duplicate(swp_entry_t entry, unsigned char usage)
> >> >  		goto bad_file;
> >> >  	p = swap_info[type];
> >> >  	offset = swp_offset(entry);
> >> > -	if (unlikely(offset >= p->max))
> >> > -		goto out;
> >> >  
> >> >  	ci = lock_cluster_or_swap_info(p, offset);
> >> > +	if (unlikely(offset >= p->max))
> >> > +		goto unlock_out;
> >> >  
> >> >  	count = p->swap_map[offset];
> >> >  
> >> 
> >> Sorry, this doesn't work, because
> >> 
> >> lock_cluster_or_swap_info()
> >> 
> >> Need to read p->cluster_info, which may be freed during swapoff too.
> >> 
> >> 
> >> To reduce the added overhead in regular code path, Maybe we can use SRCU
> >> to implement get_swap_device() and put_swap_device()?  There is only
> >> increment/decrement on CPU local variable in srcu_read_lock/unlock().
> >> Should be acceptable in not so hot swap path?
> >> 
> >> This needs to select CONFIG_SRCU if CONFIG_SWAP is enabled.  But I guess
> >> that should be acceptable too?
> >> 
> >
> > Why do we need srcu here? Is it enough with rcu like below?
> >
> > It might have a bug/room to be optimized about performance/naming.
> > I just wanted to show my intention.
> 
> Yes.  rcu should work too.  But if we use rcu, it may need to be called
> several times to make sure the swap device under us doesn't go away, for
> example, when checking si->max in __swp_swapcount() and

I think it's not a big concern performance pov and benefit is good
abstraction through current locking function so we don't need much churn.

> add_swap_count_continuation().  And I found we need rcu to protect swap
> cache radix tree array too.  So I think it may be better to use one

Could you elaborate it more about swap cache arrary problem?

> calling to srcu_read_lock/unlock() instead of multiple callings to
> rcu_read_lock/unlock().
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

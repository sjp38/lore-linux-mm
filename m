Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f71.google.com (mail-pl0-f71.google.com [209.85.160.71])
	by kanga.kvack.org (Postfix) with ESMTP id 05E1B6B0253
	for <linux-mm@kvack.org>; Wed, 13 Dec 2017 02:16:03 -0500 (EST)
Received: by mail-pl0-f71.google.com with SMTP id 43so585994pla.17
        for <linux-mm@kvack.org>; Tue, 12 Dec 2017 23:16:02 -0800 (PST)
Received: from lgeamrelo13.lge.com (LGEAMRELO13.lge.com. [156.147.23.53])
        by mx.google.com with ESMTP id f66si918302pff.48.2017.12.12.23.16.00
        for <linux-mm@kvack.org>;
        Tue, 12 Dec 2017 23:16:01 -0800 (PST)
Date: Wed, 13 Dec 2017 16:15:56 +0900
From: Minchan Kim <minchan@kernel.org>
Subject: Re: [PATCH -mm] mm, swap: Fix race between swapoff and some swap
 operations
Message-ID: <20171213071556.GA26478@bbox>
References: <20171207011426.1633-1-ying.huang@intel.com>
 <20171207162937.6a179063a7c92ecac77e44af@linux-foundation.org>
 <20171208014346.GA8915@bbox>
 <87po7pg4jt.fsf@yhuang-dev.intel.com>
 <20171208082644.GA14361@bbox>
 <87k1xxbohp.fsf@yhuang-dev.intel.com>
 <20171208091042.GA14472@bbox>
 <87efo5bdtb.fsf@yhuang-dev.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <87efo5bdtb.fsf@yhuang-dev.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Huang, Ying" <ying.huang@intel.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Hugh Dickins <hughd@google.com>, Johannes Weiner <hannes@cmpxchg.org>, Tim Chen <tim.c.chen@linux.intel.com>, Shaohua Li <shli@fb.com>, Mel Gorman <mgorman@techsingularity.net>, =?utf-8?B?Su+/vXLvv71tZQ==?= Glisse <jglisse@redhat.com>, Michal Hocko <mhocko@suse.com>, Andrea Arcangeli <aarcange@redhat.com>, David Rientjes <rientjes@google.com>, Rik van Riel <riel@redhat.com>, Jan Kara <jack@suse.cz>, Dave Jiang <dave.jiang@intel.com>, Aaron Lu <aaron.lu@intel.com>

Hi Huang,
 
Sorry for the late response. I'm in middle of long vacation.

On Fri, Dec 08, 2017 at 08:32:16PM +0800, Huang, Ying wrote:
> Minchan Kim <minchan@kernel.org> writes:
> 
> > On Fri, Dec 08, 2017 at 04:41:38PM +0800, Huang, Ying wrote:
> >> Minchan Kim <minchan@kernel.org> writes:
> >> 
> >> > On Fri, Dec 08, 2017 at 01:41:10PM +0800, Huang, Ying wrote:
> >> >> Minchan Kim <minchan@kernel.org> writes:
> >> >> 
> >> >> > On Thu, Dec 07, 2017 at 04:29:37PM -0800, Andrew Morton wrote:
> >> >> >> On Thu,  7 Dec 2017 09:14:26 +0800 "Huang, Ying" <ying.huang@intel.com> wrote:
> >> >> >> 
> >> >> >> > When the swapin is performed, after getting the swap entry information
> >> >> >> > from the page table, the PTL (page table lock) will be released, then
> >> >> >> > system will go to swap in the swap entry, without any lock held to
> >> >> >> > prevent the swap device from being swapoff.  This may cause the race
> >> >> >> > like below,
> >> >> >> > 
> >> >> >> > CPU 1				CPU 2
> >> >> >> > -----				-----
> >> >> >> > 				do_swap_page
> >> >> >> > 				  swapin_readahead
> >> >> >> > 				    __read_swap_cache_async
> >> >> >> > swapoff				      swapcache_prepare
> >> >> >> >   p->swap_map = NULL		        __swap_duplicate
> >> >> >> > 					  p->swap_map[?] /* !!! NULL pointer access */
> >> >> >> > 
> >> >> >> > Because swap off is usually done when system shutdown only, the race
> >> >> >> > may not hit many people in practice.  But it is still a race need to
> >> >> >> > be fixed.
> >> >> >> 
> >> >> >> swapoff is so rare that it's hard to get motivated about any fix which
> >> >> >> adds overhead to the regular codepaths.
> >> >> >
> >> >> > That was my concern, too when I see this patch.
> >> >> >
> >> >> >> 
> >> >> >> Is there something we can do to ensure that all the overhead of this
> >> >> >> fix is placed into the swapoff side?  stop_machine() may be a bit
> >> >> >> brutal, but a surprising amount of code uses it.  Any other ideas?
> >> >> >
> >> >> > How about this?
> >> >> >
> >> >> > I think It's same approach with old where we uses si->lock everywhere
> >> >> > instead of more fine-grained cluster lock.
> >> >> >
> >> >> > The reason I repeated to reset p->max to zero in the loop is to avoid
> >> >> > using lockdep annotation(maybe, spin_lock_nested(something) to prevent
> >> >> > false positive.
> >> >> >
> >> >> > diff --git a/mm/swapfile.c b/mm/swapfile.c
> >> >> > index 42fe5653814a..9ce007a42bbc 100644
> >> >> > --- a/mm/swapfile.c
> >> >> > +++ b/mm/swapfile.c
> >> >> > @@ -2644,6 +2644,19 @@ SYSCALL_DEFINE1(swapoff, const char __user *, specialfile)
> >> >> >  	swap_file = p->swap_file;
> >> >> >  	old_block_size = p->old_block_size;
> >> >> >  	p->swap_file = NULL;
> >> >> > +
> >> >> > +	if (p->flags & SWP_SOLIDSTATE) {
> >> >> > +		unsigned long ci, nr_cluster;
> >> >> > +
> >> >> > +		nr_cluster = DIV_ROUND_UP(p->max, SWAPFILE_CLUSTER);
> >> >> > +		for (ci = 0; ci < nr_cluster; ci++) {
> >> >> > +			struct swap_cluster_info *sci;
> >> >> > +
> >> >> > +			sci = lock_cluster(p, ci * SWAPFILE_CLUSTER);
> >> >> > +			p->max = 0;
> >> >> > +			unlock_cluster(sci);
> >> >> > +		}
> >> >> > +	}
> >> >> >  	p->max = 0;
> >> >> >  	swap_map = p->swap_map;
> >> >> >  	p->swap_map = NULL;
> >> >> > @@ -3369,10 +3382,10 @@ static int __swap_duplicate(swp_entry_t entry, unsigned char usage)
> >> >> >  		goto bad_file;
> >> >> >  	p = swap_info[type];
> >> >> >  	offset = swp_offset(entry);
> >> >> > -	if (unlikely(offset >= p->max))
> >> >> > -		goto out;
> >> >> >  
> >> >> >  	ci = lock_cluster_or_swap_info(p, offset);
> >> >> > +	if (unlikely(offset >= p->max))
> >> >> > +		goto unlock_out;
> >> >> >  
> >> >> >  	count = p->swap_map[offset];
> >> >> >  
> >> >> 
> >> >> Sorry, this doesn't work, because
> >> >> 
> >> >> lock_cluster_or_swap_info()
> >> >> 
> >> >> Need to read p->cluster_info, which may be freed during swapoff too.
> >> >> 
> >> >> 
> >> >> To reduce the added overhead in regular code path, Maybe we can use SRCU
> >> >> to implement get_swap_device() and put_swap_device()?  There is only
> >> >> increment/decrement on CPU local variable in srcu_read_lock/unlock().
> >> >> Should be acceptable in not so hot swap path?
> >> >> 
> >> >> This needs to select CONFIG_SRCU if CONFIG_SWAP is enabled.  But I guess
> >> >> that should be acceptable too?
> >> >> 
> >> >
> >> > Why do we need srcu here? Is it enough with rcu like below?
> >> >
> >> > It might have a bug/room to be optimized about performance/naming.
> >> > I just wanted to show my intention.
> >> 
> >> Yes.  rcu should work too.  But if we use rcu, it may need to be called
> >> several times to make sure the swap device under us doesn't go away, for
> >> example, when checking si->max in __swp_swapcount() and
> >
> > I think it's not a big concern performance pov and benefit is good
> > abstraction through current locking function so we don't need much churn.
> 
> I think get/put_something() is common practice in Linux kernel to
> prevent something to go away under us.  That makes the programming model
> easier to be understood than checking whether swap entry is valid here
> and there.
> 
> >> add_swap_count_continuation().  And I found we need rcu to protect swap
> >> cache radix tree array too.  So I think it may be better to use one
> >
> > Could you elaborate it more about swap cache arrary problem?
> 
> Like swap_map, cluster_info, swap cache radix tree array for a swap
> device will be freed at the end of swapoff.  So when we look up swap
> cache, we need to make sure the swap cache array is valid firstly too.
> 

Thanks for the clarification.
 
I'm not saying refcount approach you suggested is wrong but just wanted
to find more easier way with just fixing cold path instead of hot path.
To me, the thought came from from logical sense for the maintainance
rather than performan problem.
 
I still need a time to think over it and it would be made after the vacation
so don't want to make you stuck. A thing I want to suggest is that let's
think about maintanaince point of view for solution candidates.
I don't like to put get/put into out of swap code. Instead, let's
encapsulate the locking code into swap functions inside so any user
of swap function doesn't need to know the detail.
 
I think which approach is best for the solution among several
approaches depends on that how the solution makes code simple without
exposing the internal much rather than performance at the moment.

Just my two cents.
Sorry for the vague review. I'm looking forward to seeing new patches.
 
Thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

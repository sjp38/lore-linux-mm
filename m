Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f70.google.com (mail-pg0-f70.google.com [74.125.83.70])
	by kanga.kvack.org (Postfix) with ESMTP id D3C0E6B0033
	for <linux-mm@kvack.org>; Fri,  8 Dec 2017 07:32:23 -0500 (EST)
Received: by mail-pg0-f70.google.com with SMTP id q186so7866831pga.23
        for <linux-mm@kvack.org>; Fri, 08 Dec 2017 04:32:23 -0800 (PST)
Received: from mga07.intel.com (mga07.intel.com. [134.134.136.100])
        by mx.google.com with ESMTPS id r15si5377534pgt.604.2017.12.08.04.32.21
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 08 Dec 2017 04:32:21 -0800 (PST)
From: "Huang\, Ying" <ying.huang@intel.com>
Subject: Re: [PATCH -mm] mm, swap: Fix race between swapoff and some swap operations
References: <20171207011426.1633-1-ying.huang@intel.com>
	<20171207162937.6a179063a7c92ecac77e44af@linux-foundation.org>
	<20171208014346.GA8915@bbox> <87po7pg4jt.fsf@yhuang-dev.intel.com>
	<20171208082644.GA14361@bbox> <87k1xxbohp.fsf@yhuang-dev.intel.com>
	<20171208091042.GA14472@bbox>
Date: Fri, 08 Dec 2017 20:32:16 +0800
In-Reply-To: <20171208091042.GA14472@bbox> (Minchan Kim's message of "Fri, 8
	Dec 2017 18:10:42 +0900")
Message-ID: <87efo5bdtb.fsf@yhuang-dev.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=ascii
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>
Cc: "Huang, Ying" <ying.huang@intel.com>, Andrew Morton <akpm@linux-foundation.org>, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Hugh Dickins <hughd@google.com>, Johannes Weiner <hannes@cmpxchg.org>, Tim Chen <tim.c.chen@linux.intel.com>, Shaohua Li <shli@fb.com>, Mel Gorman <mgorman@techsingularity.net>, =?utf-8?B?Su+/vXLvv71tZQ==?= Glisse <jglisse@redhat.com>, Michal Hocko <mhocko@suse.com>, Andrea Arcangeli <aarcange@redhat.com>, David Rientjes <rientjes@google.com>, Rik van Riel <riel@redhat.com>, Jan Kara <jack@suse.cz>, Dave Jiang <dave.jiang@intel.com>, Aaron Lu <aaron.lu@intel.com>

Minchan Kim <minchan@kernel.org> writes:

> On Fri, Dec 08, 2017 at 04:41:38PM +0800, Huang, Ying wrote:
>> Minchan Kim <minchan@kernel.org> writes:
>> 
>> > On Fri, Dec 08, 2017 at 01:41:10PM +0800, Huang, Ying wrote:
>> >> Minchan Kim <minchan@kernel.org> writes:
>> >> 
>> >> > On Thu, Dec 07, 2017 at 04:29:37PM -0800, Andrew Morton wrote:
>> >> >> On Thu,  7 Dec 2017 09:14:26 +0800 "Huang, Ying" <ying.huang@intel.com> wrote:
>> >> >> 
>> >> >> > When the swapin is performed, after getting the swap entry information
>> >> >> > from the page table, the PTL (page table lock) will be released, then
>> >> >> > system will go to swap in the swap entry, without any lock held to
>> >> >> > prevent the swap device from being swapoff.  This may cause the race
>> >> >> > like below,
>> >> >> > 
>> >> >> > CPU 1				CPU 2
>> >> >> > -----				-----
>> >> >> > 				do_swap_page
>> >> >> > 				  swapin_readahead
>> >> >> > 				    __read_swap_cache_async
>> >> >> > swapoff				      swapcache_prepare
>> >> >> >   p->swap_map = NULL		        __swap_duplicate
>> >> >> > 					  p->swap_map[?] /* !!! NULL pointer access */
>> >> >> > 
>> >> >> > Because swap off is usually done when system shutdown only, the race
>> >> >> > may not hit many people in practice.  But it is still a race need to
>> >> >> > be fixed.
>> >> >> 
>> >> >> swapoff is so rare that it's hard to get motivated about any fix which
>> >> >> adds overhead to the regular codepaths.
>> >> >
>> >> > That was my concern, too when I see this patch.
>> >> >
>> >> >> 
>> >> >> Is there something we can do to ensure that all the overhead of this
>> >> >> fix is placed into the swapoff side?  stop_machine() may be a bit
>> >> >> brutal, but a surprising amount of code uses it.  Any other ideas?
>> >> >
>> >> > How about this?
>> >> >
>> >> > I think It's same approach with old where we uses si->lock everywhere
>> >> > instead of more fine-grained cluster lock.
>> >> >
>> >> > The reason I repeated to reset p->max to zero in the loop is to avoid
>> >> > using lockdep annotation(maybe, spin_lock_nested(something) to prevent
>> >> > false positive.
>> >> >
>> >> > diff --git a/mm/swapfile.c b/mm/swapfile.c
>> >> > index 42fe5653814a..9ce007a42bbc 100644
>> >> > --- a/mm/swapfile.c
>> >> > +++ b/mm/swapfile.c
>> >> > @@ -2644,6 +2644,19 @@ SYSCALL_DEFINE1(swapoff, const char __user *, specialfile)
>> >> >  	swap_file = p->swap_file;
>> >> >  	old_block_size = p->old_block_size;
>> >> >  	p->swap_file = NULL;
>> >> > +
>> >> > +	if (p->flags & SWP_SOLIDSTATE) {
>> >> > +		unsigned long ci, nr_cluster;
>> >> > +
>> >> > +		nr_cluster = DIV_ROUND_UP(p->max, SWAPFILE_CLUSTER);
>> >> > +		for (ci = 0; ci < nr_cluster; ci++) {
>> >> > +			struct swap_cluster_info *sci;
>> >> > +
>> >> > +			sci = lock_cluster(p, ci * SWAPFILE_CLUSTER);
>> >> > +			p->max = 0;
>> >> > +			unlock_cluster(sci);
>> >> > +		}
>> >> > +	}
>> >> >  	p->max = 0;
>> >> >  	swap_map = p->swap_map;
>> >> >  	p->swap_map = NULL;
>> >> > @@ -3369,10 +3382,10 @@ static int __swap_duplicate(swp_entry_t entry, unsigned char usage)
>> >> >  		goto bad_file;
>> >> >  	p = swap_info[type];
>> >> >  	offset = swp_offset(entry);
>> >> > -	if (unlikely(offset >= p->max))
>> >> > -		goto out;
>> >> >  
>> >> >  	ci = lock_cluster_or_swap_info(p, offset);
>> >> > +	if (unlikely(offset >= p->max))
>> >> > +		goto unlock_out;
>> >> >  
>> >> >  	count = p->swap_map[offset];
>> >> >  
>> >> 
>> >> Sorry, this doesn't work, because
>> >> 
>> >> lock_cluster_or_swap_info()
>> >> 
>> >> Need to read p->cluster_info, which may be freed during swapoff too.
>> >> 
>> >> 
>> >> To reduce the added overhead in regular code path, Maybe we can use SRCU
>> >> to implement get_swap_device() and put_swap_device()?  There is only
>> >> increment/decrement on CPU local variable in srcu_read_lock/unlock().
>> >> Should be acceptable in not so hot swap path?
>> >> 
>> >> This needs to select CONFIG_SRCU if CONFIG_SWAP is enabled.  But I guess
>> >> that should be acceptable too?
>> >> 
>> >
>> > Why do we need srcu here? Is it enough with rcu like below?
>> >
>> > It might have a bug/room to be optimized about performance/naming.
>> > I just wanted to show my intention.
>> 
>> Yes.  rcu should work too.  But if we use rcu, it may need to be called
>> several times to make sure the swap device under us doesn't go away, for
>> example, when checking si->max in __swp_swapcount() and
>
> I think it's not a big concern performance pov and benefit is good
> abstraction through current locking function so we don't need much churn.

I think get/put_something() is common practice in Linux kernel to
prevent something to go away under us.  That makes the programming model
easier to be understood than checking whether swap entry is valid here
and there.

>> add_swap_count_continuation().  And I found we need rcu to protect swap
>> cache radix tree array too.  So I think it may be better to use one
>
> Could you elaborate it more about swap cache arrary problem?

Like swap_map, cluster_info, swap cache radix tree array for a swap
device will be freed at the end of swapoff.  So when we look up swap
cache, we need to make sure the swap cache array is valid firstly too.

Best Regards,
Huang, Ying

>> calling to srcu_read_lock/unlock() instead of multiple callings to
>> rcu_read_lock/unlock().
>> 
>> Best Regards,
>> Huang, Ying

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f200.google.com (mail-qt0-f200.google.com [209.85.216.200])
	by kanga.kvack.org (Postfix) with ESMTP id 260916B0038
	for <linux-mm@kvack.org>; Fri, 15 Dec 2017 00:49:34 -0500 (EST)
Received: by mail-qt0-f200.google.com with SMTP id e2so6277220qti.3
        for <linux-mm@kvack.org>; Thu, 14 Dec 2017 21:49:34 -0800 (PST)
Received: from mx0a-001b2d01.pphosted.com (mx0b-001b2d01.pphosted.com. [148.163.158.5])
        by mx.google.com with ESMTPS id b16si5253500qtb.395.2017.12.14.21.49.32
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 14 Dec 2017 21:49:32 -0800 (PST)
Received: from pps.filterd (m0098417.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.21/8.16.0.21) with SMTP id vBF5n1HO112275
	for <linux-mm@kvack.org>; Fri, 15 Dec 2017 00:49:32 -0500
Received: from e11.ny.us.ibm.com (e11.ny.us.ibm.com [129.33.205.201])
	by mx0a-001b2d01.pphosted.com with ESMTP id 2ev7wu1gbf-1
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Fri, 15 Dec 2017 00:49:31 -0500
Received: from localhost
	by e11.ny.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <paulmck@linux.vnet.ibm.com>;
	Fri, 15 Dec 2017 00:49:30 -0500
Date: Thu, 14 Dec 2017 21:49:29 -0800
From: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
Subject: Re: [PATCH -mm -V2] mm, swap: Fix race between swapoff and some swap
 operations
Reply-To: paulmck@linux.vnet.ibm.com
References: <20171214133832.11266-1-ying.huang@intel.com>
 <20171214151718.GS16951@dhcp22.suse.cz>
 <871sjwn5bk.fsf@yhuang-dev.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <871sjwn5bk.fsf@yhuang-dev.intel.com>
Message-Id: <20171215054929.GW7829@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Huang, Ying" <ying.huang@intel.com>
Cc: Michal Hocko <mhocko@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Hugh Dickins <hughd@google.com>, Minchan Kim <minchan@kernel.org>, Johannes Weiner <hannes@cmpxchg.org>, Tim Chen <tim.c.chen@linux.intel.com>, Shaohua Li <shli@fb.com>, Mel Gorman <mgorman@techsingularity.net>, JXrXme Glisse <jglisse@redhat.com>, Andrea Arcangeli <aarcange@redhat.com>, David Rientjes <rientjes@google.com>, Rik van Riel <riel@redhat.com>, Jan Kara <jack@suse.cz>, Dave Jiang <dave.jiang@intel.com>, Aaron Lu <aaron.lu@intel.com>

On Fri, Dec 15, 2017 at 09:33:03AM +0800, Huang, Ying wrote:
> Michal Hocko <mhocko@kernel.org> writes:
> 
> > On Thu 14-12-17 21:38:32, Huang, Ying wrote:
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
> >> Because swap off is usually done when system shutdown only, the race
> >> may not hit many people in practice.  But it is still a race need to
> >> be fixed.
> >> 
> >> To fix the race, get_swap_device() is added to prevent swap device
> >> from being swapoff until put_swap_device() is called.  When
> >> get_swap_device() is called, the caller should have some locks (like
> >> PTL, page lock, or swap_info_struct->lock) held to guarantee the swap
> >> entry is valid, or check the origin of swap entry again to make sure
> >> the swap device hasn't been swapoff already.
> >> 
> >> Because swapoff() is very race code path, to make the normal path runs
> >
> > s@race@rare@ I suppose
> 
> Oops, thanks for pointing this out!
> 
> >> as fast as possible, SRCU instead of reference count is used to
> >> implement get/put_swap_device().  From get_swap_device() to
> >> put_swap_device(), the reader side of SRCU is locked, so
> >> synchronize_srcu() in swapoff() will wait until put_swap_device() is
> >> called.
> >
> > It is quite unfortunate to pull SRCU as a dependency to the core kernel.
> > Different attempts to do this have failed in the past. This one is
> > slightly different though because I would suspect that those tiny
> > systems do not configure swap. But who knows, maybe they do.
> 
> I remember Paul said there is a tiny implementation of SRCU which can
> fit this requirement.
> 
> Hi, Paul, whether my memory is correct?

Yes, if you build with CONFIG_SMP=n, then you will get Tiny SRCU, which
is quite compact.

							Thanx, Paul

> > Anyway, if you are worried about performance then I would expect some
> > numbers to back that worry. So why don't simply start with simpler
> > ref count based and then optimize it later based on some actual numbers.
> 
> My -V1 is based on ref count.  I think the performance difference should
> be not measurable.  The idea is that swapoff() is so rare, so we should
> accelerate normal path as much as possible, even if this will cause slow
> down in swapoff.  If we cannot use SRCU in the end, we may try RCU,
> preempt off (for stop_machine()), etc.
> 
> > Btw. have you considered pcp refcount framework. I would suspect that
> > this would give you close to SRCU performance.
> 
> No.  I think pcp refcount doesn't fit here.  You should hold a initial
> refcount for pcp refcount, it isn't the case here.
> 
> Best Regards,
> Huang, Ying
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

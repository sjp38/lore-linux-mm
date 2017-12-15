Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id 868176B0038
	for <linux-mm@kvack.org>; Thu, 14 Dec 2017 20:33:12 -0500 (EST)
Received: by mail-pf0-f198.google.com with SMTP id m9so6300505pff.0
        for <linux-mm@kvack.org>; Thu, 14 Dec 2017 17:33:12 -0800 (PST)
Received: from mga07.intel.com (mga07.intel.com. [134.134.136.100])
        by mx.google.com with ESMTPS id f19si3963384plr.481.2017.12.14.17.33.11
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 14 Dec 2017 17:33:11 -0800 (PST)
From: "Huang\, Ying" <ying.huang@intel.com>
Subject: Re: [PATCH -mm -V2] mm, swap: Fix race between swapoff and some swap operations
References: <20171214133832.11266-1-ying.huang@intel.com>
	<20171214151718.GS16951@dhcp22.suse.cz>
Date: Fri, 15 Dec 2017 09:33:03 +0800
In-Reply-To: <20171214151718.GS16951@dhcp22.suse.cz> (Michal Hocko's message
	of "Thu, 14 Dec 2017 16:17:18 +0100")
Message-ID: <871sjwn5bk.fsf@yhuang-dev.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=ascii
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Hugh Dickins <hughd@google.com>, Minchan Kim <minchan@kernel.org>, Johannes Weiner <hannes@cmpxchg.org>, Tim Chen <tim.c.chen@linux.intel.com>, Shaohua Li <shli@fb.com>, Mel Gorman <mgorman@techsingularity.net>, Jerome Glisse <jglisse@redhat.com>, Andrea Arcangeli <aarcange@redhat.com>, David Rientjes <rientjes@google.com>, Rik van Riel <riel@redhat.com>, Jan Kara <jack@suse.cz>, Dave Jiang <dave.jiang@intel.com>, Aaron Lu <aaron.lu@intel.com>

Michal Hocko <mhocko@kernel.org> writes:

> On Thu 14-12-17 21:38:32, Huang, Ying wrote:
>> From: Huang Ying <ying.huang@intel.com>
>> 
>> When the swapin is performed, after getting the swap entry information
>> from the page table, system will swap in the swap entry, without any
>> lock held to prevent the swap device from being swapoff.  This may
>> cause the race like below,
>> 
>> CPU 1				CPU 2
>> -----				-----
>> 				do_swap_page
>> 				  swapin_readahead
>> 				    __read_swap_cache_async
>> swapoff				      swapcache_prepare
>>   p->swap_map = NULL		        __swap_duplicate
>> 					  p->swap_map[?] /* !!! NULL pointer access */
>> 
>> Because swap off is usually done when system shutdown only, the race
>> may not hit many people in practice.  But it is still a race need to
>> be fixed.
>> 
>> To fix the race, get_swap_device() is added to prevent swap device
>> from being swapoff until put_swap_device() is called.  When
>> get_swap_device() is called, the caller should have some locks (like
>> PTL, page lock, or swap_info_struct->lock) held to guarantee the swap
>> entry is valid, or check the origin of swap entry again to make sure
>> the swap device hasn't been swapoff already.
>> 
>> Because swapoff() is very race code path, to make the normal path runs
>
> s@race@rare@ I suppose

Oops, thanks for pointing this out!

>> as fast as possible, SRCU instead of reference count is used to
>> implement get/put_swap_device().  From get_swap_device() to
>> put_swap_device(), the reader side of SRCU is locked, so
>> synchronize_srcu() in swapoff() will wait until put_swap_device() is
>> called.
>
> It is quite unfortunate to pull SRCU as a dependency to the core kernel.
> Different attempts to do this have failed in the past. This one is
> slightly different though because I would suspect that those tiny
> systems do not configure swap. But who knows, maybe they do.

I remember Paul said there is a tiny implementation of SRCU which can
fit this requirement.

Hi, Paul, whether my memory is correct?

> Anyway, if you are worried about performance then I would expect some
> numbers to back that worry. So why don't simply start with simpler
> ref count based and then optimize it later based on some actual numbers.

My -V1 is based on ref count.  I think the performance difference should
be not measurable.  The idea is that swapoff() is so rare, so we should
accelerate normal path as much as possible, even if this will cause slow
down in swapoff.  If we cannot use SRCU in the end, we may try RCU,
preempt off (for stop_machine()), etc.

> Btw. have you considered pcp refcount framework. I would suspect that
> this would give you close to SRCU performance.

No.  I think pcp refcount doesn't fit here.  You should hold a initial
refcount for pcp refcount, it isn't the case here.

Best Regards,
Huang, Ying

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

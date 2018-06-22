Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f197.google.com (mail-qk0-f197.google.com [209.85.220.197])
	by kanga.kvack.org (Postfix) with ESMTP id 8054D6B0003
	for <linux-mm@kvack.org>; Thu, 21 Jun 2018 21:17:30 -0400 (EDT)
Received: by mail-qk0-f197.google.com with SMTP id f2-v6so4240269qkm.10
        for <linux-mm@kvack.org>; Thu, 21 Jun 2018 18:17:30 -0700 (PDT)
Received: from mx1.redhat.com (mx3-rdu2.redhat.com. [66.187.233.73])
        by mx.google.com with ESMTPS id b29-v6si122914qkj.363.2018.06.21.18.17.28
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 21 Jun 2018 18:17:29 -0700 (PDT)
Date: Thu, 21 Jun 2018 21:17:24 -0400 (EDT)
From: Mikulas Patocka <mpatocka@redhat.com>
Subject: Re: dm bufio: Reduce dm_bufio_lock contention
In-Reply-To: <20180619104312.GD13685@dhcp22.suse.cz>
Message-ID: <alpine.LRH.2.02.1806191228110.25656@file01.intranet.prod.int.rdu2.redhat.com>
References: <alpine.LRH.2.02.1806131001250.15845@file01.intranet.prod.int.rdu2.redhat.com> <CAN=25QMQiJ7wvfvYvmZnEnrkeb-SA7_hPj+N2RnO8y-aVO8wOQ@mail.gmail.com> <20180614073153.GB9371@dhcp22.suse.cz> <alpine.LRH.2.02.1806141424510.30404@file01.intranet.prod.int.rdu2.redhat.com>
 <20180615073201.GB24039@dhcp22.suse.cz> <alpine.LRH.2.02.1806150724260.15022@file01.intranet.prod.int.rdu2.redhat.com> <20180615115547.GH24039@dhcp22.suse.cz> <alpine.LRH.2.02.1806150832100.26650@file01.intranet.prod.int.rdu2.redhat.com>
 <20180615130925.GI24039@dhcp22.suse.cz> <alpine.LRH.2.02.1806181003560.4201@file01.intranet.prod.int.rdu2.redhat.com> <20180619104312.GD13685@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: jing xia <jing.xia.mail@gmail.com>, Mike Snitzer <snitzer@redhat.com>, agk@redhat.com, dm-devel@redhat.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org



On Tue, 19 Jun 2018, Michal Hocko wrote:

> On Mon 18-06-18 18:11:26, Mikulas Patocka wrote:
> [...]
> > I grepped the kernel for __GFP_NORETRY and triaged them. I found 16 cases 
> > without a fallback - those are bugs that make various functions randomly 
> > return -ENOMEM.
> 
> Well, maybe those are just optimistic attempts to allocate memory and
> have a fallback somewhere else. So I would be careful calling them
> outright bugs. But maybe you are right.

I was trying to find the fallback code when I triaged them and maked as 
"BUG" those cases where I didn't find it. You can search harder and 
perhaps you'll find something that I didn't.

> > Most of the callers provide callback.
> > 
> > There is another strange flag - __GFP_RETRY_MAYFAIL - it provides two 
> > different functions - if the allocation is larger than 
> > PAGE_ALLOC_COSTLY_ORDER, it retries the allocation as if it were smaller. 
> > If the allocations is smaller than PAGE_ALLOC_COSTLY_ORDER, 
> > __GFP_RETRY_MAYFAIL will avoid the oom killer (larger order allocations 
> > don't trigger the oom killer at all).
> 
> Well, the primary purpose of this flag is to provide a consistent
> failure behavior for all requests regardless of the size.
> 
> > So, perhaps __GFP_RETRY_MAYFAIL could be used instead of __GFP_NORETRY in 
> > the cases where the caller wants to avoid trigerring the oom killer (the 
> > problem is that __GFP_NORETRY causes random failure even in no-oom 
> > situations but __GFP_RETRY_MAYFAIL doesn't).
> 
> myabe yes.
> 
> > So my suggestion is - fix these obvious bugs when someone allocates memory 
> > with __GFP_NORETRY without any fallback - and then, __GFP_NORETRY could be 
> > just changed to return NULL instead of sleeping.
> 
> No real objection to fixing wrong __GFP_NORETRY usage. But __GFP_NORETRY
> can sleep. Nothing will really change in that regards.  It does a
> reclaim and that _might_ sleep.
> 
> But seriously, isn't the best way around the throttling issue to use
> PF_LESS_THROTTLE?

Yes - it could be done by setting PF_LESS_THROTTLE. But I think it would 
be better to change it just in one place than to add PF_LESS_THROTTLE to 
every block device driver (because adding it to every block driver results 
in more code).

What about this patch? If __GFP_NORETRY and __GFP_FS is not set (i.e. the 
request comes from a block device driver or a filesystem), we should not 
sleep.

Signed-off-by: Mikulas Patocka <mpatocka@redhat.com>
Cc: stable@vger.kernel.org

Index: linux-2.6/mm/vmscan.c
===================================================================
--- linux-2.6.orig/mm/vmscan.c
+++ linux-2.6/mm/vmscan.c
@@ -2674,6 +2674,7 @@ static bool shrink_node(pg_data_t *pgdat
 		 * the LRU too quickly.
 		 */
 		if (!sc->hibernation_mode && !current_is_kswapd() &&
+		   (sc->gfp_mask & (__GFP_NORETRY | __GFP_FS)) != __GFP_NORETRY &&
 		   current_may_throttle() && pgdat_memcg_congested(pgdat, root))
 			wait_iff_congested(BLK_RW_ASYNC, HZ/10);
 

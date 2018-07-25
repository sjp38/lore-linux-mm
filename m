Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f72.google.com (mail-ed1-f72.google.com [209.85.208.72])
	by kanga.kvack.org (Postfix) with ESMTP id 91B4F6B027A
	for <linux-mm@kvack.org>; Wed, 25 Jul 2018 06:34:18 -0400 (EDT)
Received: by mail-ed1-f72.google.com with SMTP id b9-v6so2816195edn.18
        for <linux-mm@kvack.org>; Wed, 25 Jul 2018 03:34:18 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id d7-v6si6709575edp.133.2018.07.25.03.34.17
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 25 Jul 2018 03:34:17 -0700 (PDT)
Date: Wed, 25 Jul 2018 12:34:16 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: Re: [PATCH] [PATCH] mm: disable preemption before swapcache_free
Message-ID: <20180725103416.GZ28386@dhcp22.suse.cz>
References: <2018072514375722198958@wingtech.com>
 <20180725074009.GU28386@dhcp22.suse.cz>
 <2018072515575576668668@wingtech.com>
 <20180725082100.GV28386@dhcp22.suse.cz>
 <2018072517530727482074@wingtech.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <2018072517530727482074@wingtech.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "zhaowuyun@wingtech.com" <zhaowuyun@wingtech.com>
Cc: mgorman <mgorman@techsingularity.net>, akpm <akpm@linux-foundation.org>, minchan <minchan@kernel.org>, vinmenon <vinmenon@codeaurora.org>, hannes <hannes@cmpxchg.org>, "hillf.zj" <hillf.zj@alibaba-inc.com>, linux-mm <linux-mm@kvack.org>, linux-kernel <linux-kernel@vger.kernel.org>, Hugh Dickins <hughd@google.com>

On Wed 25-07-18 17:53:07, zhaowuyun@wingtech.com wrote:
> >[Please do not top post - thank you]
> >[CC Hugh - the original patch was http://lkml.kernel.org/r/2018072514375722198958@wingtech.com]
> >
> >On Wed 25-07-18 15:57:55, zhaowuyun@wingtech.com wrote:
> >> That is a BUG we found in mm/vmscan.c at KERNEL VERSION 4.9.82
> >
> >The code is quite similar in the current tree as well.
> >
> >> Sumary is TASK A (normal priority) doing __remove_mapping page preempted by TASK B (RT priority) doing __read_swap_cache_async,
> >> the TASK A preempted before swapcache_free, left SWAP_HAS_CACHE flag in the swap cache,
> >> the TASK B which doing __read_swap_cache_async, will not success at swapcache_prepare(entry) because the swap cache was exist, then it will loop forever because it is a RT thread...
> >> the spin lock unlocked before swapcache_free, so disable preemption until swapcache_free executed ...
> >
> >OK, I see your point now. I have missed the lock is dropped before
> >swapcache_free. How can preemption disabling prevent this race to happen
> >while the code is preempted by an IRQ?
> >--
> >Michal Hocko
> >SUSE Labs 
> 
> Hi Michal,
> 
> The action what processes __read_swap_cache_async is on the process context, so I think disable preemption is enough.

So what you are saying is that no IRQ or other non-process contexts will
not loop in __read_swap_cache_async so the live lock is not possible?
-- 
Michal Hocko
SUSE Labs

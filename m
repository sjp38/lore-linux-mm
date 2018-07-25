Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f71.google.com (mail-ed1-f71.google.com [209.85.208.71])
	by kanga.kvack.org (Postfix) with ESMTP id B64186B0279
	for <linux-mm@kvack.org>; Wed, 25 Jul 2018 06:32:08 -0400 (EDT)
Received: by mail-ed1-f71.google.com with SMTP id d18-v6so2949210edp.0
        for <linux-mm@kvack.org>; Wed, 25 Jul 2018 03:32:08 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id 36-v6si134957edn.295.2018.07.25.03.32.06
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 25 Jul 2018 03:32:07 -0700 (PDT)
Date: Wed, 25 Jul 2018 12:32:04 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: Re: [PATCH] [PATCH] mm: disable preemption before swapcache_free
Message-ID: <20180725103204.GY28386@dhcp22.suse.cz>
References: <2018072514375722198958@wingtech.com>
 <20180725074009.GU28386@dhcp22.suse.cz>
 <2018072515575576668668@wingtech.com>
 <20180725082100.GV28386@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180725082100.GV28386@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "zhaowuyun@wingtech.com" <zhaowuyun@wingtech.com>
Cc: mgorman <mgorman@techsingularity.net>, akpm <akpm@linux-foundation.org>, minchan <minchan@kernel.org>, vinmenon <vinmenon@codeaurora.org>, hannes <hannes@cmpxchg.org>, "hillf.zj" <hillf.zj@alibaba-inc.com>, linux-mm <linux-mm@kvack.org>, linux-kernel <linux-kernel@vger.kernel.org>, Hugh Dickins <hughd@google.com>

On Wed 25-07-18 10:21:00, Michal Hocko wrote:
> [Please do not top post - thank you]
> [CC Hugh - the original patch was http://lkml.kernel.org/r/2018072514375722198958@wingtech.com]

now for real

> On Wed 25-07-18 15:57:55, zhaowuyun@wingtech.com wrote:
> > That is a BUG we found in mm/vmscan.c at KERNEL VERSION 4.9.82
> 
> The code is quite similar in the current tree as well.
> 
> > Sumary is TASK A (normal priority) doing __remove_mapping page preempted by TASK B (RT priority) doing __read_swap_cache_async,
> > the TASK A preempted before swapcache_free, left SWAP_HAS_CACHE flag in the swap cache,
> > the TASK B which doing __read_swap_cache_async, will not success at swapcache_prepare(entry) because the swap cache was exist, then it will loop forever because it is a RT thread...
> > the spin lock unlocked before swapcache_free, so disable preemption until swapcache_free executed ...
> 
> OK, I see your point now. I have missed the lock is dropped before
> swapcache_free. How can preemption disabling prevent this race to happen
> while the code is preempted by an IRQ?

-- 
Michal Hocko
SUSE Labs

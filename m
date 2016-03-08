Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f42.google.com (mail-wm0-f42.google.com [74.125.82.42])
	by kanga.kvack.org (Postfix) with ESMTP id 34EF06B0005
	for <linux-mm@kvack.org>; Tue,  8 Mar 2016 07:22:44 -0500 (EST)
Received: by mail-wm0-f42.google.com with SMTP id n186so128863339wmn.1
        for <linux-mm@kvack.org>; Tue, 08 Mar 2016 04:22:44 -0800 (PST)
Received: from mail-wm0-f47.google.com (mail-wm0-f47.google.com. [74.125.82.47])
        by mx.google.com with ESMTPS id s7si4063011wmb.109.2016.03.08.04.22.42
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 08 Mar 2016 04:22:43 -0800 (PST)
Received: by mail-wm0-f47.google.com with SMTP id l68so147470769wml.0
        for <linux-mm@kvack.org>; Tue, 08 Mar 2016 04:22:42 -0800 (PST)
Date: Tue, 8 Mar 2016 13:22:41 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH] mm, oom: protect !costly allocations some more
Message-ID: <20160308122241.GD13542@dhcp22.suse.cz>
References: <20160203132718.GI6757@dhcp22.suse.cz>
 <alpine.LSU.2.11.1602241832160.15564@eggly.anvils>
 <20160225092315.GD17573@dhcp22.suse.cz>
 <20160229210213.GX16930@dhcp22.suse.cz>
 <20160307160838.GB5028@dhcp22.suse.cz>
 <56DE9A68.2010301@suse.cz>
 <20160308094612.GB13542@dhcp22.suse.cz>
 <56DEA0CF.2070902@suse.cz>
 <20160308101016.GC13542@dhcp22.suse.cz>
 <56DEB394.40602@suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <56DEB394.40602@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: Hugh Dickins <hughd@google.com>, Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, Mel Gorman <mgorman@suse.de>, David Rientjes <rientjes@google.com>, Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>, Hillf Danton <hillf.zj@alibaba-inc.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>, Joonsoo Kim <js1304@gmail.com>

On Tue 08-03-16 12:12:20, Vlastimil Babka wrote:
> On 03/08/2016 11:10 AM, Michal Hocko wrote:
> > On Tue 08-03-16 10:52:15, Vlastimil Babka wrote:
> >> On 03/08/2016 10:46 AM, Michal Hocko wrote:
> > [...]
> >>>>> @@ -3294,6 +3289,18 @@ __alloc_pages_slowpath(gfp_t gfp_mask, unsigned int order,
> >>>>>  				 did_some_progress > 0, no_progress_loops))
> >>>>>  		goto retry;
> >>>>>  
> >>>>> +	/*
> >>>>> +	 * !costly allocations are really important and we have to make sure
> >>>>> +	 * the compaction wasn't deferred or didn't bail out early due to locks
> >>>>> +	 * contention before we go OOM.
> >>>>> +	 */
> >>>>> +	if (order && order <= PAGE_ALLOC_COSTLY_ORDER) {
> >>>>> +		if (compact_result <= COMPACT_CONTINUE)
> >>>>
> >>>> Same here.
> >>>> I was going to say that this didn't have effect on Sergey's test, but
> >>>> turns out it did :)
> >>>
> >>> This should work as expected because compact_result is unsigned long
> >>> and so this is the unsigned arithmetic. I can make
> >>> #define COMPACT_NONE            -1UL
> >>>
> >>> to make the intention more obvious if you prefer, though.
> >>
> >> Well, what wasn't obvious to me is actually that here (unlike in the
> >> test above) it was actually intended that COMPACT_NONE doesn't result in
> >> a retry. But it makes sense, otherwise we would retry endlessly if
> >> reclaim couldn't form a higher-order page, right.
> > 
> > Yeah, that was the whole point. An alternative would be moving the test
> > into should_compact_retry(order, compact_result, contended_compaction)
> > which would be CONFIG_COMPACTION specific so we can get rid of the
> > COMPACT_NONE altogether. Something like the following. We would lose the
> > always initialized compact_result but this would matter only for
> > order==0 and we check for that. Even gcc doesn't complain.
> 
> Yeah I like this version better, you can add my Acked-By.

OK, patch updated and I will post it as a reply to the original email.
 
> Thanks.
> 
> > A more important question is whether the criteria I have chosen are
> > reasonable and reasonably independent on the particular implementation
> > of the compaction. I still cannot convince myself about the convergence
> > here. Is it possible that the compaction would keep returning 
> > compact_result <= COMPACT_CONTINUE while not making any progress at all?
> 
> Theoretically, if reclaim/compaction suitability decisions and
> allocation attempts didn't match the watermark checks, including the
> alloc_flags and classzone_idx parameters. Possible scenarios:
> 
> - reclaim thinks compaction has enough to proceed, but compaction thinks
> otherwise and returns COMPACT_SKIPPED
> - compaction thinks it succeeded and returns COMPACT_PARTIAL, but
> allocation attempt fails
> - and perhaps some other combinations

But that might happen right now as well so it wouldn't be a regression,
right?
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

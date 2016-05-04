Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f70.google.com (mail-lf0-f70.google.com [209.85.215.70])
	by kanga.kvack.org (Postfix) with ESMTP id 33B446B007E
	for <linux-mm@kvack.org>; Wed,  4 May 2016 09:56:28 -0400 (EDT)
Received: by mail-lf0-f70.google.com with SMTP id m64so42021430lfd.1
        for <linux-mm@kvack.org>; Wed, 04 May 2016 06:56:28 -0700 (PDT)
Received: from mail-wm0-f66.google.com (mail-wm0-f66.google.com. [74.125.82.66])
        by mx.google.com with ESMTPS id i3si5030787wjp.128.2016.05.04.06.56.26
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 04 May 2016 06:56:27 -0700 (PDT)
Received: by mail-wm0-f66.google.com with SMTP id e201so10430047wme.2
        for <linux-mm@kvack.org>; Wed, 04 May 2016 06:56:26 -0700 (PDT)
Date: Wed, 4 May 2016 15:56:25 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH 01/14] vmscan: consider classzone_idx in compaction_ready
Message-ID: <20160504135625.GK29978@dhcp22.suse.cz>
References: <1461181647-8039-1-git-send-email-mhocko@kernel.org>
 <1461181647-8039-2-git-send-email-mhocko@kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1461181647-8039-2-git-send-email-mhocko@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Linus Torvalds <torvalds@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, Mel Gorman <mgorman@suse.de>, David Rientjes <rientjes@google.com>, Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, Joonsoo Kim <js1304@gmail.com>, Hillf Danton <hillf.zj@alibaba-inc.com>, Vlastimil Babka <vbabka@suse.cz>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>

On Wed 20-04-16 15:47:14, Michal Hocko wrote:
> From: Michal Hocko <mhocko@suse.com>
> 
> while playing with the oom detection rework [1] I have noticed
> that my heavy order-9 (hugetlb) load close to OOM ended up in an
> endless loop where the reclaim hasn't made any progress but
> did_some_progress didn't reflect that and compaction_suitable
> was backing off because no zone is above low wmark + 1 << order.
> 
> It turned out that this is in fact an old standing bug in compaction_ready
> which ignores the requested_highidx and did the watermark check for
> 0 classzone_idx. This succeeds for zone DMA most of the time as the zone
> is mostly unused because of lowmem protection.

so far so good

>  This also means that the
> OOM killer wouldn't be triggered for higher order requests even when
> there is no reclaim progress and we essentially rely on order-0 request
> to find this out. This has been broken in one way or another since
> fe4b1b244bdb ("mm: vmscan: when reclaiming for compaction, ensure there
> are sufficient free pages available") but only since 7335084d446b ("mm:
> vmscan: do not OOM if aborting reclaim to start compaction") we are not
> invoking the OOM killer based on the wrong calculation.

but now that I was looking at the code again I realize I have missed one
important thing:
shrink_zones()
                        if (IS_ENABLED(CONFIG_COMPACTION) &&
                            sc->order > PAGE_ALLOC_COSTLY_ORDER &&
                            zonelist_zone_idx(z) <= requested_highidx &&
                            compaction_ready(zone, sc->order, requested_highidx)) {
                                sc->compaction_ready = true;
                                continue;
                        }

so the whole argument about OOM is bogus because this whole thing is
done only for costly requests.

So the bug has not been that serious before and it started to matter
only after the oom detection rework (especially after patch 13) where we
really need even costly allocations to not lie about the progress.

Andrew, could you update the changelog to the following please?
"
while playing with the oom detection rework [1] I have noticed that my
heavy order-9 (hugetlb) load close to OOM ended up in an endless loop
where the reclaim hasn't made any progress but did_some_progress didn't
reflect that and compaction_suitable was backing off because no zone is
above low wmark + 1 << order.

It turned out that this is in fact an old standing bug in compaction_ready
which ignores the requested_highidx and did the watermark check for
0 classzone_idx. This succeeds for zone DMA most of the time as the zone
is mostly unused because of lowmem protection. As a result costly high
order allocatios always report a successfull progress even when there
was none. This wasn't a problem so far because these allocations usually
fail quite early or retry only few times with __GFP_REPEAT but this will
change after later patch in this series so make sure to not lie about
the progress and propagate requested_highidx down to compaction_ready
and use it for both the watermak check and compaction_suitable to fix
this issue.

[1] http://lkml.kernel.org/r/1459855533-4600-1-git-send-email-mhocko@kernel.org
"

Thanks and sorry for the confusion!
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

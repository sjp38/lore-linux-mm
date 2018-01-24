Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f197.google.com (mail-wr0-f197.google.com [209.85.128.197])
	by kanga.kvack.org (Postfix) with ESMTP id 3FE87800D8
	for <linux-mm@kvack.org>; Wed, 24 Jan 2018 16:12:31 -0500 (EST)
Received: by mail-wr0-f197.google.com with SMTP id y18so3072026wrh.12
        for <linux-mm@kvack.org>; Wed, 24 Jan 2018 13:12:31 -0800 (PST)
Received: from outbound-smtp16.blacknight.com (outbound-smtp16.blacknight.com. [46.22.139.233])
        by mx.google.com with ESMTPS id h10si345648edl.225.2018.01.24.13.12.29
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 24 Jan 2018 13:12:29 -0800 (PST)
Received: from mail.blacknight.com (pemlinmail03.blacknight.ie [81.17.254.16])
	by outbound-smtp16.blacknight.com (Postfix) with ESMTPS id 936DD1C3E38
	for <linux-mm@kvack.org>; Wed, 24 Jan 2018 21:12:29 +0000 (GMT)
Date: Wed, 24 Jan 2018 21:12:29 +0000
From: Mel Gorman <mgorman@techsingularity.net>
Subject: Re: [PATCH 2/2] free_pcppages_bulk: prefetch buddy while not holding
 lock
Message-ID: <20180124211228.3k7tuuji7a7mvyh2@techsingularity.net>
References: <20180124023050.20097-1-aaron.lu@intel.com>
 <20180124023050.20097-2-aaron.lu@intel.com>
 <20180124164344.lca63gjn7mefuiac@techsingularity.net>
 <148a42d8-8306-2f2f-7f7c-86bc118f8ccd@intel.com>
 <20180124181921.vnivr32q72ey7p5i@techsingularity.net>
 <525a20be-dea9-ed54-ca8e-8c4bc5e8a04f@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <525a20be-dea9-ed54-ca8e-8c4bc5e8a04f@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave.hansen@intel.com>
Cc: Aaron Lu <aaron.lu@intel.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Huang Ying <ying.huang@intel.com>, Kemi Wang <kemi.wang@intel.com>, Tim Chen <tim.c.chen@linux.intel.com>, Andi Kleen <ak@linux.intel.com>, Michal Hocko <mhocko@suse.com>, Vlastimil Babka <vbabka@suse.cz>

On Wed, Jan 24, 2018 at 11:23:49AM -0800, Dave Hansen wrote:
> On 01/24/2018 10:19 AM, Mel Gorman wrote:
> >> IOW, I don't think this has the same downsides normally associated with
> >> prefetch() since the data is always used.
> > That doesn't side-step the calculations are done twice in the
> > free_pcppages_bulk path and there is no guarantee that one prefetch
> > in the list of pages being freed will not evict a previous prefetch
> > due to collisions.
> 
> Fair enough.  The description here could probably use some touchups to
> explicitly spell out the downsides.
> 

It would be preferable. As I said, I'm not explicitly NAKing this but it
might push someone else over the edge into an outright ACK. I think patch
1 should go ahead as-is unconditionally as I see no reason to hold that
one back.

I would suggest adding the detail in the changelog that a prefetch will
potentially evict an earlier prefetch from the L1 cache but it is expected
the data would still be preserved in a L2 or L3 cache. Further note that
while there is some additional instruction overhead, it is required that
the data be fetched eventually and it's expected in many cases that cycles
spent early will be offset by reduced memory latency later. Finally note
that actual benefit will be workload/CPU dependant.

Also consider adding a comment above the actual prefetch because it deserves
one otherwise it looks like a fast path is being sprinked with magic dust
from the prefetch fairy.

> I do agree with you that there is no guarantee that this will be
> resident in the cache before use.  In fact, it might be entertaining to
> see if we can show the extra conflicts in the L1 given from this change
> given a large enough PCP batch size.
> 

Well, I wouldn't bother worrying about different PCP batch sizes.  In typical
operations, it's going to be the pcp->batch size. Even if you were dumping
the entire PCP due to a drain, it's still going to be less than many L1
sizes on x86 at least and those drains are usually in the context of a
much larger operation where the overhead of the buddy calculations will
be negligable in comparison.

> But, this isn't just about the L1.  If the results of the prefetch()
> stay in *ANY* cache, then the memory bandwidth impact of this change is
> still zero.  You'll have a lot harder time arguing that we're likely to
> see L2/L3 evictions in this path for our typical PCP batch sizes.
> 

s/lot harder time/impossible without making crap up/

> Do you want to see some analysis for less-frequent PCP frees? 

Actually no I don't. While it would be interesting to see, it's a waste
of your time. Less-frequent PCPs means that the impact of the extra cycles
is *also* marginal and a PCP drain must fetch the data eventually.

> We could
> pretty easily instrument the latency doing normal-ish things to see if
> we can measure a benefit from this rather than a tight-loop micro.

I believe the only realistic scenario where it's going to be detectable
is a network intensive application on very high speed networks where the
cost of the alloc/free paths tends to be more noticable. I suspect anything
else will be so far into the noise that it'll be unnoticable.

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ob0-f197.google.com (mail-ob0-f197.google.com [209.85.214.197])
	by kanga.kvack.org (Postfix) with ESMTP id 954C36B007E
	for <linux-mm@kvack.org>; Wed,  4 May 2016 04:32:11 -0400 (EDT)
Received: by mail-ob0-f197.google.com with SMTP id rd14so91771594obb.3
        for <linux-mm@kvack.org>; Wed, 04 May 2016 01:32:11 -0700 (PDT)
Received: from lgeamrelo11.lge.com (LGEAMRELO11.lge.com. [156.147.23.51])
        by mx.google.com with ESMTP id a140si2836996ioa.39.2016.05.04.01.32.10
        for <linux-mm@kvack.org>;
        Wed, 04 May 2016 01:32:10 -0700 (PDT)
Date: Wed, 4 May 2016 17:32:38 +0900
From: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Subject: Re: [PATCH 0.14] oom detection rework v6
Message-ID: <20160504083238.GA11859@js1304-P5Q-DELUXE>
References: <1461181647-8039-1-git-send-email-mhocko@kernel.org>
 <20160504054502.GA10899@js1304-P5Q-DELUXE>
 <5729AEFB.9060101@suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <5729AEFB.9060101@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: Michal Hocko <mhocko@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, Mel Gorman <mgorman@suse.de>, David Rientjes <rientjes@google.com>, Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, Hillf Danton <hillf.zj@alibaba-inc.com>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>

On Wed, May 04, 2016 at 10:12:43AM +0200, Vlastimil Babka wrote:
> On 05/04/2016 07:45 AM, Joonsoo Kim wrote:
> >I still don't agree with some part of this patchset that deal with
> >!costly order. As you know, there was two regression reports from Hugh
> >and Aaron and you fixed them by ensuring to trigger compaction. I
> >think that these show the problem of this patchset. Previous kernel
> >doesn't need to ensure to trigger compaction and just works fine in
> >any case.
> 
> IIRC previous kernel somehow subtly never OOM'd for !costly orders.

IIRC, it would not OOM in thrashing case. But, it could OOM in other
cases.

> So anything that introduces the possibility of OOM may look like
> regression for some corner case workloads. But I don't think that
> it's OK to not OOM for e.g. kernel stack allocations?

Sorry. Double negation makes me hard to understand since I'm not
native. So, you think that it's OK to OOM for kernel stack allocation?
I think so, too. But, I want not to OOM prematurely.

> >Your series make compaction necessary for all. OOM handling
> >is essential part in MM but compaction isn't. OOM handling should not
> >depend on compaction. I tested my own benchmark without
> >CONFIG_COMPACTION and found that premature OOM happens.
> >
> >I hope that you try to test something without CONFIG_COMPACTION.
> 
> Hmm a valid point, !CONFIG_COMPACTION should be considered. But
> reclaim cannot guarantee forming an order>0 page. But neither does
> OOM. So would you suggest we keep reclaiming without OOM as before,
> to prevent these regressions? Or where to draw the line here?

I suggested that memorizing number of reclaimable pages when entering
allocation slowpath and try to reclaim at least that amount. Thrashing
is effectively prevented in this algorithm and we don't trigger OOM
prematurely.

Thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

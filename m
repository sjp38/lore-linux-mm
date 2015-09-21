Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f178.google.com (mail-wi0-f178.google.com [209.85.212.178])
	by kanga.kvack.org (Postfix) with ESMTP id 9E5E46B0253
	for <linux-mm@kvack.org>; Mon, 21 Sep 2015 06:51:39 -0400 (EDT)
Received: by wicfx3 with SMTP id fx3so139609188wic.1
        for <linux-mm@kvack.org>; Mon, 21 Sep 2015 03:51:39 -0700 (PDT)
Received: from outbound-smtp05.blacknight.com (outbound-smtp05.blacknight.com. [81.17.249.38])
        by mx.google.com with ESMTPS id q18si16214290wik.96.2015.09.21.03.51.38
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Mon, 21 Sep 2015 03:51:38 -0700 (PDT)
Received: from mail.blacknight.com (pemlinmail02.blacknight.ie [81.17.254.11])
	by outbound-smtp05.blacknight.com (Postfix) with ESMTPS id A97729889D
	for <linux-mm@kvack.org>; Mon, 21 Sep 2015 10:51:37 +0000 (UTC)
Date: Mon, 21 Sep 2015 11:51:30 +0100
From: Mel Gorman <mgorman@techsingularity.net>
Subject: Re: [PATCH 11/12] mm, page_alloc: Reserve pageblocks for high-order
 atomic allocations on demand
Message-ID: <20150921105130.GA3068@techsingularity.net>
References: <1440418191-10894-1-git-send-email-mgorman@techsingularity.net>
 <20150824122957.GI12432@techsingularity.net>
 <CAAmzW4O7N8NZVE4DS25a4FROem-pJOEYxAsqEBtPsjWuNSZyrQ@mail.gmail.com>
 <20150909123239.GZ12432@techsingularity.net>
 <20150918063835.GB7769@js1304-P5Q-DELUXE>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20150918063835.GB7769@js1304-P5Q-DELUXE>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, Rik van Riel <riel@redhat.com>, Vlastimil Babka <vbabka@suse.cz>, David Rientjes <rientjes@google.com>, Michal Hocko <mhocko@kernel.org>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On Fri, Sep 18, 2015 at 03:38:35PM +0900, Joonsoo Kim wrote:
> > > And, there is some mismatch that check atomic high-order allocation.
> > > In some place, you checked __GFP_ATOMIC, but some other places,
> > > you checked ALLOC_HARDER. It is better to use unified one.
> > > Introducing helper function may be a good choice.
> > > 
> > 
> > Which cases specifically? In the zone_watermark check, it's because
> > there is no GFP flags in that context. They could be passed in but then
> > every caller needs to be updated accordingly and overall it gains
> > nothing.
> 
> You use __GFP_ATOMIC in rmqueue() to allow highatomic reserve.
> ALLOC_HARDER is used in watermark check and to reserve highatomic
> pageblock after allocation.
> 
> ALLOC_HARDER is set if (__GFP_ATOMIC && !__GFP_NOMEMALLOC) *or*
> (rt_task && !in_interrupt()). So, later case could pass watermark
> check but cannot use HIGHATOMIC reserve. And, it will reserve
> highatomic pageblock. When it try to allocate again, it can't use
> this reserved pageblock due to GFP flags and this could happens
> repeatedly.
> And, first case also has a problem. If user requests memory
> with __GFP_NOMEMALLOC, it's intend doesn't touch reserved mem,
> but, in current patch, it can use highatomic pageblock.
> 
> I'm not sure these causes real trouble but unifying it as much as
> possible is preferable solution.
> 

Ok, that makes sense. Thanks

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

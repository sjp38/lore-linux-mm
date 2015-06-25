Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f170.google.com (mail-wi0-f170.google.com [209.85.212.170])
	by kanga.kvack.org (Postfix) with ESMTP id 265806B0038
	for <linux-mm@kvack.org>; Thu, 25 Jun 2015 14:41:40 -0400 (EDT)
Received: by wicnd19 with SMTP id nd19so172165720wic.1
        for <linux-mm@kvack.org>; Thu, 25 Jun 2015 11:41:39 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id wl7si54147634wjc.206.2015.06.25.11.41.38
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Thu, 25 Jun 2015 11:41:39 -0700 (PDT)
Date: Thu, 25 Jun 2015 19:41:35 +0100
From: Mel Gorman <mgorman@suse.de>
Subject: Re: [RFC PATCH 00/10] redesign compaction algorithm
Message-ID: <20150625184135.GB26927@suse.de>
References: <1435193121-25880-1-git-send-email-iamjoonsoo.kim@lge.com>
 <20150625110314.GJ11809@suse.de>
 <CAAmzW4OnE7A6sxEDFRcp9jbuxkYkJvJw_PH1TBFtS0nZOmrVGg@mail.gmail.com>
 <20150625172550.GA26927@suse.de>
 <CAAmzW4PMWOaAa0bd7xVr5Jz=xVgqMw8G=UFOwhUGuyLL9EFbHA@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <CAAmzW4PMWOaAa0bd7xVr5Jz=xVgqMw8G=UFOwhUGuyLL9EFbHA@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Joonsoo Kim <js1304@gmail.com>
Cc: Joonsoo Kim <iamjoonsoo.kim@lge.com>, Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>, Linux Memory Management List <linux-mm@kvack.org>, Vlastimil Babka <vbabka@suse.cz>, Rik van Riel <riel@redhat.com>, David Rientjes <rientjes@google.com>, Minchan Kim <minchan@kernel.org>

On Fri, Jun 26, 2015 at 03:14:39AM +0900, Joonsoo Kim wrote:
> > It could though. Reclaim/compaction is entered for orders higher than
> > PAGE_ALLOC_COSTLY_ORDER and when scan priority is sufficiently high.
> > That could be adjusted if you have a viable case where orders <
> > PAGE_ALLOC_COSTLY_ORDER must succeed and currently requires excessive
> > reclaim instead of relying on compaction.
> 
> Yes. I saw this problem in real situation. In ARM, order-2 allocation
> is requested
> in fork(), so it should be succeed. But, there is not enough order-2 freepage,
> so reclaim/compaction begins. Compaction fails repeatedly although
> I didn't check exact reason.

That should be identified and repaired prior to reimplementing
compaction because it's important.

> >> >> 3) Compaction capability is highly depends on migratetype of memory,
> >> >> because freepage scanner doesn't scan unmovable pageblock.
> >> >>
> >> >
> >> > For a very good reason. Unmovable allocation requests that fallback to
> >> > other pageblocks are the worst in terms of fragmentation avoidance. The
> >> > more of these events there are, the more the system will decay. If there
> >> > are many of these events then a compaction benchmark may start with high
> >> > success rates but decay over time.
> >> >
> >> > Very broadly speaking, the more the mm_page_alloc_extfrag tracepoint
> >> > triggers with alloc_migratetype == MIGRATE_UNMOVABLE, the faster the
> >> > system is decaying. Having the freepage scanner select unmovable
> >> > pageblocks will trigger this event more frequently.
> >> >
> >> > The unfortunate impact is that selecting unmovable blocks from the free
> >> > csanner will improve compaction success rates for high-order kernel
> >> > allocations early in the lifetime of the system but later fail high-order
> >> > allocation requests as more pageblocks get converted to unmovable. It
> >> > might be ok for kernel allocations but THP will eventually have a 100%
> >> > failure rate.
> >>
> >> I wrote rationale in the patch itself. We already use non-movable pageblock
> >> for migration scanner. It empties non-movable pageblock so number of
> >> freepage on non-movable pageblock will increase. Using non-movable
> >> pageblock for freepage scanner negates this effect so number of freepage
> >> on non-movable pageblock will be balanced. Could you tell me in detail
> >> how freepage scanner select unmovable pageblocks will cause
> >> more fragmentation? Possibly, I don't understand effect of this patch
> >> correctly and need some investigation. :)
> >>
> >
> > The long-term success rate of fragmentation avoidance depends on
> > minimsing the number of UNMOVABLE allocation requests that use a
> > pageblock belonging to another migratetype. Once such a fallback occurs,
> > that pageblock potentially can never be used for a THP allocation again.
> >
> > Lets say there is an unmovable pageblock with 500 free pages in it. If
> > the freepage scanner uses that pageblock and allocates all 500 free
> > pages then the next unmovable allocation request needs a new pageblock.
> > If one is not completely free then it will fallback to using a
> > RECLAIMABLE or MOVABLE pageblock forever contaminating it.
> 
> Yes, I can imagine that situation. But, as I said above, we already use
> non-movable pageblock for migration scanner. While unmovable
> pageblock with 500 free pages fills, some other unmovable pageblock
> with some movable pages will be emptied. Number of freepage
> on non-movable would be maintained so fallback doesn't happen.
> 
> Anyway, it is better to investigate this effect. I will do it and attach
> result on next submission.
> 

Lets say we have X unmovable pageblocks and Y pageblocks overall. If the
migration scanner takes movable pages from X then there is more space for
unmovable allocations without having to increase X -- this is good. If
the free scanner uses the X pageblocks as targets then they can fill. The
next unmovable allocation then falls back to another pageblock and we
either have X+1 unmovable pageblocks (full steal) or a mixed pageblock
(partial steal) that cannot be used for THP. Do this enough times and
X == Y and all THP allocations fail.

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

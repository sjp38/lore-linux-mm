Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f50.google.com (mail-wg0-f50.google.com [74.125.82.50])
	by kanga.kvack.org (Postfix) with ESMTP id 077576B0038
	for <linux-mm@kvack.org>; Fri, 26 Jun 2015 06:22:47 -0400 (EDT)
Received: by wgjx7 with SMTP id x7so11367294wgj.2
        for <linux-mm@kvack.org>; Fri, 26 Jun 2015 03:22:46 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id gs9si2102758wib.31.2015.06.26.03.22.45
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Fri, 26 Jun 2015 03:22:45 -0700 (PDT)
Date: Fri, 26 Jun 2015 11:22:41 +0100
From: Mel Gorman <mgorman@suse.de>
Subject: Re: [RFC PATCH 00/10] redesign compaction algorithm
Message-ID: <20150626102241.GH26927@suse.de>
References: <1435193121-25880-1-git-send-email-iamjoonsoo.kim@lge.com>
 <20150625110314.GJ11809@suse.de>
 <CAAmzW4OnE7A6sxEDFRcp9jbuxkYkJvJw_PH1TBFtS0nZOmrVGg@mail.gmail.com>
 <20150625172550.GA26927@suse.de>
 <CAAmzW4PMWOaAa0bd7xVr5Jz=xVgqMw8G=UFOwhUGuyLL9EFbHA@mail.gmail.com>
 <20150625184135.GB26927@suse.de>
 <CAAmzW4OuArqzavsPY3_3u5OnnO=ZY1HSnUT4Rgoq2ytd+n89xQ@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <CAAmzW4OuArqzavsPY3_3u5OnnO=ZY1HSnUT4Rgoq2ytd+n89xQ@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Joonsoo Kim <js1304@gmail.com>
Cc: Joonsoo Kim <iamjoonsoo.kim@lge.com>, Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>, Linux Memory Management List <linux-mm@kvack.org>, Vlastimil Babka <vbabka@suse.cz>, Rik van Riel <riel@redhat.com>, David Rientjes <rientjes@google.com>, Minchan Kim <minchan@kernel.org>

On Fri, Jun 26, 2015 at 11:07:47AM +0900, Joonsoo Kim wrote:
> >> > The long-term success rate of fragmentation avoidance depends on
> >> > minimsing the number of UNMOVABLE allocation requests that use a
> >> > pageblock belonging to another migratetype. Once such a fallback occurs,
> >> > that pageblock potentially can never be used for a THP allocation again.
> >> >
> >> > Lets say there is an unmovable pageblock with 500 free pages in it. If
> >> > the freepage scanner uses that pageblock and allocates all 500 free
> >> > pages then the next unmovable allocation request needs a new pageblock.
> >> > If one is not completely free then it will fallback to using a
> >> > RECLAIMABLE or MOVABLE pageblock forever contaminating it.
> >>
> >> Yes, I can imagine that situation. But, as I said above, we already use
> >> non-movable pageblock for migration scanner. While unmovable
> >> pageblock with 500 free pages fills, some other unmovable pageblock
> >> with some movable pages will be emptied. Number of freepage
> >> on non-movable would be maintained so fallback doesn't happen.
> >>
> >> Anyway, it is better to investigate this effect. I will do it and attach
> >> result on next submission.
> >>
> >
> > Lets say we have X unmovable pageblocks and Y pageblocks overall. If the
> > migration scanner takes movable pages from X then there is more space for
> > unmovable allocations without having to increase X -- this is good. If
> > the free scanner uses the X pageblocks as targets then they can fill. The
> > next unmovable allocation then falls back to another pageblock and we
> > either have X+1 unmovable pageblocks (full steal) or a mixed pageblock
> > (partial steal) that cannot be used for THP. Do this enough times and
> > X == Y and all THP allocations fail.
> 
> This was similar with my understanding but different conclusion.
> 
> As number of unmovable pageblocks, X, which is filled by movable pages
> due to this compaction change increases, reclaimed/migrated out pages
> from them also increase.

There is no guarantee of that, it's timing sensitive and the kernel sepends
more time copying data in/out of the same pageblocks which is wasteful.

> And, then, further unmovable allocation request
> will use this free space and eventually these pageblocks are totally filled
> by unmovable allocation. Therefore, I guess, in the long-term, increasing X
> is saturated and X == Y will not happen.
> 

The whole reason we avoid migrating to unmovable blocks is because it
did happen and quite quickly.  Do not use unmovable blocks as migration
targets. If high-order kernel allocations are required then some reclaim
is necessary for compaction to work with.

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

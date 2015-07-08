Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f174.google.com (mail-pd0-f174.google.com [209.85.192.174])
	by kanga.kvack.org (Postfix) with ESMTP id 9114C6B0038
	for <linux-mm@kvack.org>; Wed,  8 Jul 2015 04:21:31 -0400 (EDT)
Received: by pdbdz6 with SMTP id dz6so47080045pdb.0
        for <linux-mm@kvack.org>; Wed, 08 Jul 2015 01:21:31 -0700 (PDT)
Received: from lgeamrelo02.lge.com (lgeamrelo02.lge.com. [156.147.1.126])
        by mx.google.com with ESMTP id y5si2845716pas.76.2015.07.08.01.21.29
        for <linux-mm@kvack.org>;
        Wed, 08 Jul 2015 01:21:30 -0700 (PDT)
Date: Wed, 8 Jul 2015 17:24:59 +0900
From: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Subject: Re: [RFC PATCH 00/10] redesign compaction algorithm
Message-ID: <20150708082458.GA17015@js1304-P5Q-DELUXE>
References: <1435193121-25880-1-git-send-email-iamjoonsoo.kim@lge.com>
 <20150625110314.GJ11809@suse.de>
 <CAAmzW4OnE7A6sxEDFRcp9jbuxkYkJvJw_PH1TBFtS0nZOmrVGg@mail.gmail.com>
 <20150625172550.GA26927@suse.de>
 <CAAmzW4PMWOaAa0bd7xVr5Jz=xVgqMw8G=UFOwhUGuyLL9EFbHA@mail.gmail.com>
 <20150625184135.GB26927@suse.de>
 <CAAmzW4OuArqzavsPY3_3u5OnnO=ZY1HSnUT4Rgoq2ytd+n89xQ@mail.gmail.com>
 <20150626102241.GH26927@suse.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20150626102241.GH26927@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>, Linux Memory Management List <linux-mm@kvack.org>, Vlastimil Babka <vbabka@suse.cz>, Rik van Riel <riel@redhat.com>, David Rientjes <rientjes@google.com>, Minchan Kim <minchan@kernel.org>

On Fri, Jun 26, 2015 at 11:22:41AM +0100, Mel Gorman wrote:
> On Fri, Jun 26, 2015 at 11:07:47AM +0900, Joonsoo Kim wrote:
> > >> > The long-term success rate of fragmentation avoidance depends on
> > >> > minimsing the number of UNMOVABLE allocation requests that use a
> > >> > pageblock belonging to another migratetype. Once such a fallback occurs,
> > >> > that pageblock potentially can never be used for a THP allocation again.
> > >> >
> > >> > Lets say there is an unmovable pageblock with 500 free pages in it. If
> > >> > the freepage scanner uses that pageblock and allocates all 500 free
> > >> > pages then the next unmovable allocation request needs a new pageblock.
> > >> > If one is not completely free then it will fallback to using a
> > >> > RECLAIMABLE or MOVABLE pageblock forever contaminating it.
> > >>
> > >> Yes, I can imagine that situation. But, as I said above, we already use
> > >> non-movable pageblock for migration scanner. While unmovable
> > >> pageblock with 500 free pages fills, some other unmovable pageblock
> > >> with some movable pages will be emptied. Number of freepage
> > >> on non-movable would be maintained so fallback doesn't happen.
> > >>
> > >> Anyway, it is better to investigate this effect. I will do it and attach
> > >> result on next submission.
> > >>
> > >
> > > Lets say we have X unmovable pageblocks and Y pageblocks overall. If the
> > > migration scanner takes movable pages from X then there is more space for
> > > unmovable allocations without having to increase X -- this is good. If
> > > the free scanner uses the X pageblocks as targets then they can fill. The
> > > next unmovable allocation then falls back to another pageblock and we
> > > either have X+1 unmovable pageblocks (full steal) or a mixed pageblock
> > > (partial steal) that cannot be used for THP. Do this enough times and
> > > X == Y and all THP allocations fail.
> > 
> > This was similar with my understanding but different conclusion.
> > 
> > As number of unmovable pageblocks, X, which is filled by movable pages
> > due to this compaction change increases, reclaimed/migrated out pages
> > from them also increase.
> 
> There is no guarantee of that, it's timing sensitive and the kernel sepends
> more time copying data in/out of the same pageblocks which is wasteful.
> 
> > And, then, further unmovable allocation request
> > will use this free space and eventually these pageblocks are totally filled
> > by unmovable allocation. Therefore, I guess, in the long-term, increasing X
> > is saturated and X == Y will not happen.
> > 
> 
> The whole reason we avoid migrating to unmovable blocks is because it
> did happen and quite quickly.  Do not use unmovable blocks as migration
> targets. If high-order kernel allocations are required then some reclaim
> is necessary for compaction to work with.

Hello, Mel and Vlastimil.

Sorry for late response. I need some time to get the number and it takes
so long due to bugs on page owner. Before mentioning about this patchset,
I should mention that result of my previous patchset about active
fragmentation avoidance that you have reviewed is wrong. Incorrect result
is caused by page owner bug and correct result shows just slight
improvement rather than dramatical improvment.

https://lkml.org/lkml/2015/4/27/92


Back to our discussion, indeed, you are right. As you expected,
fragmentation increases due to this patch. It's not much but adding
other changes of this patchset accelerates fragmentation more so
it's not tolerable in the end.

Below is number of *non-mixed* pageblock measured by page owner
after running modified stress-highalloc test that repeats test 3 times
without rebooting like as Vlastimil did.

pb[n] means that it is measured after n times runs of stress-highalloc
test without rebooting. They are averaged by 3 runs.

                        base nonmovable redesign revert-nonmovable
pb[1]:DMA32:movable:    1359    1333    1303    1380
pb[1]:Normal:movable:   368     341     356     364

pb[2]:DMA32:movable:    1306    1277    1216    1322
pb[2]:Normal:movable:   359     345     325     349

pb[3]:DMA32:movable:    1265    1240    1179    1276
pb[3]:Normal:movable:   330     330     312     332

Allowing scanning on nonmovable pageblock increases fragmentation so
non-mixed pageblock is reduced by rougly 2~3%. Whole of this patchset
bumps this reduction up to roughly 6%. But, with reverting nonmovable
patch, it get restored and looks better than before.

Nevertheless, still, I'd like to change freepage scanner's behaviour
because there are systems that most of pageblocks are unmovable pageblock.
In this kind of system, without this change, compaction would not
work well as my experiment, build-frag-unmovable, showed, and essential
high-order allocation fails.

I have no idea how to overcome this situation without this kind of change.
If you have such a idea, please let me know.

Here is similar idea to handle this situation without causing more
fragmentation. Changes as following:

1. Freepage scanner just scan only movable pageblocks.
2. If freepage scanner doesn't find any freepage on movable pageblocks
and whole zone range is scanned, freepage scanner start to scan on
non-movable pageblocks.

Here is the result.
                                                new-idea
pb[1]:DMA32:movable:                            1371
pb[1]:Normal:movable:                            384

pb[2]:DMA32:movable:                            1322
pb[2]:Normal:movable:                            372

pb[3]:DMA32:movable:                            1273
pb[3]:Normal:movable:                            358

Result is better than revert-nonmovable case. Although I didn't attach
the whole result, this one is better than revert one in term of success
rate.

Before starting to optimize this idea, I'd like to hear your opinion
about this change.

I think this change is essential because fail on high-order allocation
up to PAGE_COSTLY_ORDER is functional failure and MM should guarantee
it's success. After lumpy recliam is removed, this kind of allocation
unavoidably rely on work of compaction. We can't prevent that movable
pageblocks are turned into unmovable pageblock because it is highly
workload dependant.

Thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

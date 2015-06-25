Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f180.google.com (mail-wi0-f180.google.com [209.85.212.180])
	by kanga.kvack.org (Postfix) with ESMTP id A388C6B006E
	for <linux-mm@kvack.org>; Thu, 25 Jun 2015 13:25:57 -0400 (EDT)
Received: by wiga1 with SMTP id a1so170834067wig.0
        for <linux-mm@kvack.org>; Thu, 25 Jun 2015 10:25:57 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id e1si53864105wjp.38.2015.06.25.10.25.55
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Thu, 25 Jun 2015 10:25:56 -0700 (PDT)
Date: Thu, 25 Jun 2015 18:25:50 +0100
From: Mel Gorman <mgorman@suse.de>
Subject: Re: [RFC PATCH 00/10] redesign compaction algorithm
Message-ID: <20150625172550.GA26927@suse.de>
References: <1435193121-25880-1-git-send-email-iamjoonsoo.kim@lge.com>
 <20150625110314.GJ11809@suse.de>
 <CAAmzW4OnE7A6sxEDFRcp9jbuxkYkJvJw_PH1TBFtS0nZOmrVGg@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <CAAmzW4OnE7A6sxEDFRcp9jbuxkYkJvJw_PH1TBFtS0nZOmrVGg@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Joonsoo Kim <js1304@gmail.com>
Cc: Joonsoo Kim <iamjoonsoo.kim@lge.com>, Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>, Linux Memory Management List <linux-mm@kvack.org>, Vlastimil Babka <vbabka@suse.cz>, Rik van Riel <riel@redhat.com>, David Rientjes <rientjes@google.com>, Minchan Kim <minchan@kernel.org>

On Fri, Jun 26, 2015 at 02:11:17AM +0900, Joonsoo Kim wrote:
> > Global state is required because there can be parallel compaction
> > attempts. The global state requires locking to avoid two parallel
> > compaction attempts selecting the same pageblock for migrating to and
> > from.
> 
> I used skip-bit to prevent selecting same pageblock for migrating to
> and from. If freepage scanner isolates some pages, skip-bit is set
> on that pageblock. Migration scanner checks skip-bit before scanning
> and will avoid to scan that marked pageblock.
> 

That will need locking or migration scanner could start just before the
skip bit is set.

> 
> > This global state then needs to be reset on each compaction cycle. The
> > difficulty then is that there is a potential ping-pong effect. A pageblock
> > that was previously a migration target for the free scanner may become a
> > migration source for the migration scanner. Having the scanners operate
> > in opposite directions and meet in the middle avoided this problem.
> 
> I admit that this patchset causes ping-pong effect between each compaction
> cycle, because skip-bit is reset on each compaction cycle. But, I think that
> we don't need to worry about it. We should make high order page up to
> PAGE_COSTLY_ORDER by any means. If compaction fails, we need to
> reclaim some pages and this would cause file I/O. It is more bad than
> ping-pong effect on compaction.
> 

That's debatable because the assumption is that the compaction will
definitly allow forward progress. Copying pages back and forth without
forward progress will chew CPU. There is a cost with reclaiming to allow
compaction but that's the price to pay if high-order kernel allocations
are required. In the case of THP, we can give up quickly at least.

> > I'm not saying the current design is perfect but it avoids a number of
> > problems that are worth keeping in mind. Regressions in this area will
> > look like higher system CPU time with most of the additional time spent
> > in compaction.
> >
> >> 2) Compaction capability is highly depends on amount of free memory.
> >> If there is 50 MB free memory on 4 GB system, migrate scanner can
> >> migrate 50 MB used pages at maximum and then will meet free scanner.
> >> If compaction can't make enough high order freepages during this
> >> amount of work, compaction would fail. There is no way to escape this
> >> failure situation in current algorithm and it will scan same region and
> >> fail again and again. And then, it goes into compaction deferring logic
> >> and will be deferred for some times.
> >>
> >
> > This is why reclaim/compaction exists. When this situation occurs, the
> > kernel is meant to reclaim some order-0 pages and try again. Initially
> > it was lumpy reclaim that was used but it severely disrupted the system.
> 
> No, current kernel implementation doesn't reclaim pages in this situation.
> Watermark check for order 0 would be passed in this case and reclaim logic
> regards this state as compact_ready and there is no need to reclaim. Even if
> we change it to reclaim some pages in this case, there are usually parallel
> tasks who want to use more memory so free memory size wouldn't increase
> as much as we need and compaction wouldn't succeed.
> 

It could though. Reclaim/compaction is entered for orders higher than
PAGE_ALLOC_COSTLY_ORDER and when scan priority is sufficiently high.
That could be adjusted if you have a viable case where orders <
PAGE_ALLOC_COSTLY_ORDER must succeed and currently requires excessive
reclaim instead of relying on compaction.

> >> 3) Compaction capability is highly depends on migratetype of memory,
> >> because freepage scanner doesn't scan unmovable pageblock.
> >>
> >
> > For a very good reason. Unmovable allocation requests that fallback to
> > other pageblocks are the worst in terms of fragmentation avoidance. The
> > more of these events there are, the more the system will decay. If there
> > are many of these events then a compaction benchmark may start with high
> > success rates but decay over time.
> >
> > Very broadly speaking, the more the mm_page_alloc_extfrag tracepoint
> > triggers with alloc_migratetype == MIGRATE_UNMOVABLE, the faster the
> > system is decaying. Having the freepage scanner select unmovable
> > pageblocks will trigger this event more frequently.
> >
> > The unfortunate impact is that selecting unmovable blocks from the free
> > csanner will improve compaction success rates for high-order kernel
> > allocations early in the lifetime of the system but later fail high-order
> > allocation requests as more pageblocks get converted to unmovable. It
> > might be ok for kernel allocations but THP will eventually have a 100%
> > failure rate.
> 
> I wrote rationale in the patch itself. We already use non-movable pageblock
> for migration scanner. It empties non-movable pageblock so number of
> freepage on non-movable pageblock will increase. Using non-movable
> pageblock for freepage scanner negates this effect so number of freepage
> on non-movable pageblock will be balanced. Could you tell me in detail
> how freepage scanner select unmovable pageblocks will cause
> more fragmentation? Possibly, I don't understand effect of this patch
> correctly and need some investigation. :)
> 

The long-term success rate of fragmentation avoidance depends on
minimsing the number of UNMOVABLE allocation requests that use a
pageblock belonging to another migratetype. Once such a fallback occurs,
that pageblock potentially can never be used for a THP allocation again.

Lets say there is an unmovable pageblock with 500 free pages in it. If
the freepage scanner uses that pageblock and allocates all 500 free
pages then the next unmovable allocation request needs a new pageblock.
If one is not completely free then it will fallback to using a
RECLAIMABLE or MOVABLE pageblock forever contaminating it.

Do that enough times and fragmentation avoidance breaks down.

Your scheme of migrating to UNMOVABLE blocks may allow order-3 allocations
to success as long as there are enough MOVABLE pageblocks to move pages
from but eventually it'll stop working. THP-sized allocations would be the
first to notice. That might not matter on a mobile but it matters elsewhere.

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

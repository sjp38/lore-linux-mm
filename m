Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f42.google.com (mail-pa0-f42.google.com [209.85.220.42])
	by kanga.kvack.org (Postfix) with ESMTP id 3B3536B0038
	for <linux-mm@kvack.org>; Tue, 26 Aug 2014 22:56:35 -0400 (EDT)
Received: by mail-pa0-f42.google.com with SMTP id lf10so25001249pab.29
        for <linux-mm@kvack.org>; Tue, 26 Aug 2014 19:56:34 -0700 (PDT)
Received: from lgeamrelo01.lge.com (lgeamrelo01.lge.com. [156.147.1.125])
        by mx.google.com with ESMTP id jd1si6949721pbb.115.2014.08.26.19.56.32
        for <linux-mm@kvack.org>;
        Tue, 26 Aug 2014 19:56:33 -0700 (PDT)
Date: Wed, 27 Aug 2014 11:57:28 +0900
From: Minchan Kim <minchan@kernel.org>
Subject: Re: [PATCH 0/2] ARM: Remove lowmem limit for default CMA region
Message-ID: <20140827025728.GJ32620@bbox>
References: <1408610714-16204-1-git-send-email-m.szyprowski@samsung.com>
 <20140825012600.GN17372@bbox>
 <53FAED20.60200@samsung.com>
 <20140825081836.GF32620@bbox>
 <53FAF4EE.6060201@samsung.com>
 <20140826024355.GB11319@bbox>
 <53FC7ED0.4040905@samsung.com>
 <20140827003611.GH32620@bbox>
 <20140827014254.GB10198@js1304-P5Q-DELUXE>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
In-Reply-To: <20140827014254.GB10198@js1304-P5Q-DELUXE>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Cc: Marek Szyprowski <m.szyprowski@samsung.com>, linux-arm-kernel@lists.infradead.org, linux-mm@kvack.org, linaro-mm-sig@lists.linaro.org, Russell King - ARM Linux <linux@arm.linux.org.uk>, Michal Nazarewicz <mina86@mina86.com>, Andrew Morton <akpm@linux-foundation.org>, Bartlomiej Zolnierkiewicz <b.zolnierkie@samsung.com>, Kyungmin Park <kyungmin.park@samsung.com>

On Wed, Aug 27, 2014 at 10:42:54AM +0900, Joonsoo Kim wrote:
> On Wed, Aug 27, 2014 at 09:36:11AM +0900, Minchan Kim wrote:
> > Hey Marek,
> > 
> > On Tue, Aug 26, 2014 at 02:34:24PM +0200, Marek Szyprowski wrote:
> > > Hello,
> > > 
> > > On 2014-08-26 04:43, Minchan Kim wrote:
> > > >On Mon, Aug 25, 2014 at 10:33:50AM +0200, Marek Szyprowski wrote:
> > > >>On 2014-08-25 10:18, Minchan Kim wrote:
> > > >>>On Mon, Aug 25, 2014 at 10:00:32AM +0200, Marek Szyprowski wrote:
> > > >>>>On 2014-08-25 03:26, Minchan Kim wrote:
> > > >>>>>On Thu, Aug 21, 2014 at 10:45:12AM +0200, Marek Szyprowski wrote:
> > > >>>>>>Russell King recently noticed that limiting default CMA region only to
> > > >>>>>>low memory on ARM architecture causes serious memory management issues
> > > >>>>>>with machines having a lot of memory (which is mainly available as high
> > > >>>>>>memory). More information can be found the following thread:
> > > >>>>>>http://thread.gmane.org/gmane.linux.ports.arm.kernel/348441/
> > > >>>>>>
> > > >>>>>>Those two patches removes this limit letting kernel to put default CMA
> > > >>>>>>region into high memory when this is possible (there is enough high
> > > >>>>>>memory available and architecture specific DMA limit fits).
> > > >>>>>Agreed. It should be from the beginning because CMA page is effectly
> > > >>>>>pinned if it is anonymous page and system has no swap.
> > > >>>>Nope. Even without swap, anonymous page can be correctly migrated to other
> > > >>>>location. Migration code doesn't depend on presence of swap.
> > > >>>I could be possible only if the zone has freeable page(ie, free pages
> > > >>>+ shrinkable page like page cache). IOW, if the zone is full with
> > > >>>anon pages, it's efffectively pinned.
> > > >>Why? __alloc_contig_migrate_range() uses alloc_migrate_target()
> > > >>function, which
> > > >>can take free page from any zone matching given flags.
> > > >Strictly speaking, it's not any zones. It allows zones which are
> > > >equal or lower with zone of source page.
> > > >
> > > >Pz, look at Russell's case.
> > > >The pgd_alloc is trying to allocate order 2 page on normal zone,
> > > >which is lowest zone so there is no fallback zones to migrate
> > > >anonymous pages in normal zone out and alloc_migrate_target doesn't
> > > >allocate target page from higher zones of source page at the moment.
> > > >That's why I call it as effectively pinned.
> > > 
> > > In Russell's case the issue is related to compaction code. It should still
> > > be able to compact low zone and get some free pages. It is not a case of
> > > alloc_migrate_target. I mentioned this function because I wanted to show
> > > that it is possible to move pages out of that zone in case of doing CMA
> > > alloc and having no swap.
> > > 
> > > >>>>>>This should solve strange OOM issues on systems with lots of RAM
> > > >>>>>>(i.e. >1GiB) and large (>256M) CMA area.
> > > >>>>>I totally agree with the patchset although I didn't review code
> > > >>>>>at all.
> > > >>>>>
> > > >>>>>Another topic:
> > > >>>>>It means it should be a problem still if system has CMA in lowmem
> > > >>>>>by some reason(ex, hardware limit or other purpose of CMA
> > > >>>>>rather than DMA subsystem)?
> > > >>>>>
> > > >>>>>In that case, an idea that just popped in my head is to migrate
> > > >>>>>pages from cma area to highest zone because they are all
> > > >>>>>userspace pages which should be in there but not sure it's worth
> > > >>>>>to implement at this point because how many such cripple platform
> > > >>>>>are.
> > > >>>>>
> > > >>>>>Just for the recording.
> > > >>>>Moving pages between low and high zone is not that easy. If I remember
> > > >>>>correctly you cannot migrate a page from low memory to high zone in
> > > >>>>generic case, although it should be possible to add exception for
> > > >>>>anonymous pages. This will definitely improve poor low memory
> > > >>>>handling in low zone when CMA is enabled.
> > > >>>Yeb, it's possible for anonymous pages but I just wonder it's worth
> > > >>>to add more complexitiy to mm and and you are answering it's worth.
> > > >>>Okay. May I understand your positive feedback means such platform(
> > > >>>ie, DMA works with only lowmem) are still common?
> > > >>There are still some platforms, which have limited DMA capabilities. However
> > > >Thanks for your comment.
> > > >I just wanted to know it's worth before I dive into that but it seems
> > > >I was driving wrong way. See below.
> > > >
> > > >>the ability to move anonymous a page from lowmem to highmem will be
> > > >>a benefit
> > > >>in any case, as low memory is really much more precious.
> > > >Maybe, but in case of this report, even if we move anonymous pages
> > > >into higher zones, the problem(ie, OOM) is still there because
> > > >pgd_alloc wanted high order page in no cma area in normal zone.
> > > >
> > > >The feature which move CMA pages into higher zones would help CMA alloc
> > > >latency if there are lots of free pages in higher zone but no freeable
> > > >page in the zone which source page located in. But it wouldn't help
> > > >this OOM problem.
> > > 
> > > Right. The mentioned OOM problem shows that compaction fails in some cases
> > > for unknown reasons. The question here is weather compaction_alloc()
> > > function is able to get free CMA pages or not. Right now I'm not sure if
> > > it will take pages from the right list or not. This case definitely should
> > > be investigated.
> 
> Hello, Minchan and Marek.
> 
> IIUC, compaction_alloc() can get free CMA pages.
> 
> > 
> > I think it can because suitable_migrate_target and migrate_async_suitable
> > consider CMA. That's why I think the culprit is cmpaction deferring logic
> > and sent a patch to detect it.
> > http://www.spinics.net/lists/kernel/msg1812538.html
> 
> I guess that this problem is related to CMA.
> When direct_compaction begins, compaction logic check whether this
> zone is suitable or not by compaction_suitable(). In this function,
> we check fragmentation_index() and it didn't consider whether free_blocks
> is on CMA or not for free_blocks_suitable. So, in Russell's case, it
> would always return -1000 and then return COMPACT_PARTIAL. After all,
> compaction wouldn't actually happen and allocation request would fail,
> too.

Good catch! Acutally I checked it but I thought COMPACT_PARTIAL will
go with compaction. Brain damaged.


> 
> I should note that there is one more flaw on zone_watermark_ok().
> zone_watermark_ok() doesn't handle > 0 allocation correctly if there
> is free CMA memory so we can easily pass this watermakr check in
> this case.
> 
> I have a plan to fix it, but, it will takes some time. :)

Okay, I am looking forward to seeing that. 
Thanks Joonsoo!

> 
> Thanks.
> 
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

-- 
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

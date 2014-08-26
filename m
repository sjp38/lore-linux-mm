Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f41.google.com (mail-pa0-f41.google.com [209.85.220.41])
	by kanga.kvack.org (Postfix) with ESMTP id 9E6D26B0036
	for <linux-mm@kvack.org>; Mon, 25 Aug 2014 22:43:05 -0400 (EDT)
Received: by mail-pa0-f41.google.com with SMTP id rd3so22192050pab.0
        for <linux-mm@kvack.org>; Mon, 25 Aug 2014 19:43:05 -0700 (PDT)
Received: from lgeamrelo02.lge.com (lgeamrelo02.lge.com. [156.147.1.126])
        by mx.google.com with ESMTP id mi6si656316pab.17.2014.08.25.19.43.03
        for <linux-mm@kvack.org>;
        Mon, 25 Aug 2014 19:43:04 -0700 (PDT)
Date: Tue, 26 Aug 2014 11:43:55 +0900
From: Minchan Kim <minchan@kernel.org>
Subject: Re: [PATCH 0/2] ARM: Remove lowmem limit for default CMA region
Message-ID: <20140826024355.GB11319@bbox>
References: <1408610714-16204-1-git-send-email-m.szyprowski@samsung.com>
 <20140825012600.GN17372@bbox>
 <53FAED20.60200@samsung.com>
 <20140825081836.GF32620@bbox>
 <53FAF4EE.6060201@samsung.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
In-Reply-To: <53FAF4EE.6060201@samsung.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Marek Szyprowski <m.szyprowski@samsung.com>
Cc: linux-arm-kernel@lists.infradead.org, linux-mm@kvack.org, linaro-mm-sig@lists.linaro.org, Russell King - ARM Linux <linux@arm.linux.org.uk>, Michal Nazarewicz <mina86@mina86.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Andrew Morton <akpm@linux-foundation.org>, Bartlomiej Zolnierkiewicz <b.zolnierkie@samsung.com>, Kyungmin Park <kyungmin.park@samsung.com>

Hey Marek,

On Mon, Aug 25, 2014 at 10:33:50AM +0200, Marek Szyprowski wrote:
> Hello,
> 
> On 2014-08-25 10:18, Minchan Kim wrote:
> >On Mon, Aug 25, 2014 at 10:00:32AM +0200, Marek Szyprowski wrote:
> >>On 2014-08-25 03:26, Minchan Kim wrote:
> >>>On Thu, Aug 21, 2014 at 10:45:12AM +0200, Marek Szyprowski wrote:
> >>>>Russell King recently noticed that limiting default CMA region only to
> >>>>low memory on ARM architecture causes serious memory management issues
> >>>>with machines having a lot of memory (which is mainly available as high
> >>>>memory). More information can be found the following thread:
> >>>>http://thread.gmane.org/gmane.linux.ports.arm.kernel/348441/
> >>>>
> >>>>Those two patches removes this limit letting kernel to put default CMA
> >>>>region into high memory when this is possible (there is enough high
> >>>>memory available and architecture specific DMA limit fits).
> >>>Agreed. It should be from the beginning because CMA page is effectly
> >>>pinned if it is anonymous page and system has no swap.
> >>Nope. Even without swap, anonymous page can be correctly migrated to other
> >>location. Migration code doesn't depend on presence of swap.
> >I could be possible only if the zone has freeable page(ie, free pages
> >+ shrinkable page like page cache). IOW, if the zone is full with
> >anon pages, it's efffectively pinned.
> 
> Why? __alloc_contig_migrate_range() uses alloc_migrate_target()
> function, which
> can take free page from any zone matching given flags.

Strictly speaking, it's not any zones. It allows zones which are
equal or lower with zone of source page.

Pz, look at Russell's case.
The pgd_alloc is trying to allocate order 2 page on normal zone,
which is lowest zone so there is no fallback zones to migrate
anonymous pages in normal zone out and alloc_migrate_target doesn't
allocate target page from higher zones of source page at the moment.
That's why I call it as effectively pinned.

> 
> >>>>This should solve strange OOM issues on systems with lots of RAM
> >>>>(i.e. >1GiB) and large (>256M) CMA area.
> >>>I totally agree with the patchset although I didn't review code
> >>>at all.
> >>>
> >>>Another topic:
> >>>It means it should be a problem still if system has CMA in lowmem
> >>>by some reason(ex, hardware limit or other purpose of CMA
> >>>rather than DMA subsystem)?
> >>>
> >>>In that case, an idea that just popped in my head is to migrate
> >>>pages from cma area to highest zone because they are all
> >>>userspace pages which should be in there but not sure it's worth
> >>>to implement at this point because how many such cripple platform
> >>>are.
> >>>
> >>>Just for the recording.
> >>Moving pages between low and high zone is not that easy. If I remember
> >>correctly you cannot migrate a page from low memory to high zone in
> >>generic case, although it should be possible to add exception for
> >>anonymous pages. This will definitely improve poor low memory
> >>handling in low zone when CMA is enabled.
> >Yeb, it's possible for anonymous pages but I just wonder it's worth
> >to add more complexitiy to mm and and you are answering it's worth.
> >Okay. May I understand your positive feedback means such platform(
> >ie, DMA works with only lowmem) are still common?
> 
> There are still some platforms, which have limited DMA capabilities. However

Thanks for your comment.
I just wanted to know it's worth before I dive into that but it seems
I was driving wrong way. See below.

> the ability to move anonymous a page from lowmem to highmem will be
> a benefit
> in any case, as low memory is really much more precious.

Maybe, but in case of this report, even if we move anonymous pages
into higher zones, the problem(ie, OOM) is still there because
pgd_alloc wanted high order page in no cma area in normal zone.

The feature which move CMA pages into higher zones would help CMA alloc
latency if there are lots of free pages in higher zone but no freeable
page in the zone which source page located in. But it wouldn't help
this OOM problem.

> 
> It also doesn't look to be really hard to add this exception for anonymous
> pages from low memory. It will be just a matter of setting __GFP_HIGHMEM
> flag if source page is anonymous page in alloc_migrate_target() function.
> Am i right?

When I read source code, yes, it might work(but not sure I didn't test it)
for anonymous page but as I read report from Russell in detail,
fundamental problem is that why compaction didn't work although it has
lots of free pages in normal zone.

Normal free:159400kB min:3440kB low:4300kB high:5160kB active_anon:54336kB
inactive_anon:2580kB active_file:56kB inactive_file:204kB unevictable:0kB
isolated(anon):0kB isolated(file):0kB present:778240kB managed:740044kB
mlocked:0kB dirty:0kB writeback:0kB mapped:5336kB shmem:5428kB
slab_reclaimable:14420kB slab_unreclaimable:383976kB kernel_stack:2512kB
pagetables:1088kB unstable:0kB bounce:0kB free_cma:150788kB
writeback_tmp:0kB pages_scanned:0 all_unreclaimable? no

As you can see, there are lots of CMA free pages in normal zone and
there are (54M + 2M) anon pages so compaction should migrate 64M anon pages
into CMA area but it didn't.

I think it's primary reason of the problem and moving CMA area into higher zone
by default can hide the problem and it's not a exact solution of this problem.
(But still I support this patch, default CMA area should be higher zones if
possible)

Thesedays, there are some of reports about compaction fail although
there are lots of free pages. I think the report is just one example.

> 
> Best regards
> -- 
> Marek Szyprowski, PhD
> Samsung R&D Institute Poland
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

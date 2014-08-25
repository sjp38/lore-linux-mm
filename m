Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f46.google.com (mail-pa0-f46.google.com [209.85.220.46])
	by kanga.kvack.org (Postfix) with ESMTP id 293CB6B0078
	for <linux-mm@kvack.org>; Mon, 25 Aug 2014 04:17:50 -0400 (EDT)
Received: by mail-pa0-f46.google.com with SMTP id lj1so20372548pab.33
        for <linux-mm@kvack.org>; Mon, 25 Aug 2014 01:17:49 -0700 (PDT)
Received: from lgemrelse7q.lge.com (LGEMRELSE7Q.lge.com. [156.147.1.151])
        by mx.google.com with ESMTP id nl1si52058342pbc.153.2014.08.25.01.17.47
        for <linux-mm@kvack.org>;
        Mon, 25 Aug 2014 01:17:48 -0700 (PDT)
Date: Mon, 25 Aug 2014 17:18:37 +0900
From: Minchan Kim <minchan@kernel.org>
Subject: Re: [PATCH 0/2] ARM: Remove lowmem limit for default CMA region
Message-ID: <20140825081836.GF32620@bbox>
References: <1408610714-16204-1-git-send-email-m.szyprowski@samsung.com>
 <20140825012600.GN17372@bbox>
 <53FAED20.60200@samsung.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
In-Reply-To: <53FAED20.60200@samsung.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Marek Szyprowski <m.szyprowski@samsung.com>
Cc: linux-arm-kernel@lists.infradead.org, linux-mm@kvack.org, linaro-mm-sig@lists.linaro.org, Russell King - ARM Linux <linux@arm.linux.org.uk>, Michal Nazarewicz <mina86@mina86.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Andrew Morton <akpm@linux-foundation.org>, Bartlomiej Zolnierkiewicz <b.zolnierkie@samsung.com>, Kyungmin Park <kyungmin.park@samsung.com>

On Mon, Aug 25, 2014 at 10:00:32AM +0200, Marek Szyprowski wrote:
> Hello,
> 
> On 2014-08-25 03:26, Minchan Kim wrote:
> >Hello,
> >
> >On Thu, Aug 21, 2014 at 10:45:12AM +0200, Marek Szyprowski wrote:
> >>Hello,
> >>
> >>Russell King recently noticed that limiting default CMA region only to
> >>low memory on ARM architecture causes serious memory management issues
> >>with machines having a lot of memory (which is mainly available as high
> >>memory). More information can be found the following thread:
> >>http://thread.gmane.org/gmane.linux.ports.arm.kernel/348441/
> >>
> >>Those two patches removes this limit letting kernel to put default CMA
> >>region into high memory when this is possible (there is enough high
> >>memory available and architecture specific DMA limit fits).
> >Agreed. It should be from the beginning because CMA page is effectly
> >pinned if it is anonymous page and system has no swap.
> 
> Nope. Even without swap, anonymous page can be correctly migrated to other
> location. Migration code doesn't depend on presence of swap.

I could be possible only if the zone has freeable page(ie, free pages
+ shrinkable page like page cache). IOW, if the zone is full with
anon pages, it's efffectively pinned.

> 
> >>This should solve strange OOM issues on systems with lots of RAM
> >>(i.e. >1GiB) and large (>256M) CMA area.
> >I totally agree with the patchset although I didn't review code
> >at all.
> >
> >Another topic:
> >It means it should be a problem still if system has CMA in lowmem
> >by some reason(ex, hardware limit or other purpose of CMA
> >rather than DMA subsystem)?
> >
> >In that case, an idea that just popped in my head is to migrate
> >pages from cma area to highest zone because they are all
> >userspace pages which should be in there but not sure it's worth
> >to implement at this point because how many such cripple platform
> >are.
> >
> >Just for the recording.
> 
> Moving pages between low and high zone is not that easy. If I remember
> correctly you cannot migrate a page from low memory to high zone in
> generic case, although it should be possible to add exception for
> anonymous pages. This will definitely improve poor low memory
> handling in low zone when CMA is enabled.

Yeb, it's possible for anonymous pages but I just wonder it's worth
to add more complexitiy to mm and and you are answering it's worth.
Okay. May I understand your positive feedback means such platform(
ie, DMA works with only lowmem) are still common?

Thanks.

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

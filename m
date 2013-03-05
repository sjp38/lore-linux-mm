Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx199.postini.com [74.125.245.199])
	by kanga.kvack.org (Postfix) with SMTP id CA9056B0002
	for <linux-mm@kvack.org>; Tue,  5 Mar 2013 17:42:21 -0500 (EST)
Received: by mail-ia0-f181.google.com with SMTP id w33so6657804iag.26
        for <linux-mm@kvack.org>; Tue, 05 Mar 2013 14:42:21 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <1362466679-17111-1-git-send-email-m.szyprowski@samsung.com>
References: <1362466679-17111-1-git-send-email-m.szyprowski@samsung.com>
Date: Tue, 5 Mar 2013 23:42:20 +0100
Message-ID: <CAKMK7uFOZu6Oyh-3jPsVfEvNXB8Q1Yj49q9iCnNVdF8cPUvd5Q@mail.gmail.com>
Subject: Re: [RFC/PATCH 0/5] Contiguous Memory Allocator and get_user_pages()
From: Daniel Vetter <daniel.vetter@ffwll.ch>
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Marek Szyprowski <m.szyprowski@samsung.com>
Cc: linux-mm@kvack.org, linaro-mm-sig@lists.linaro.org, linux-kernel@vger.kernel.org, Kyungmin Park <kyungmin.park@samsung.com>, Arnd Bergmann <arnd@arndb.de>, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mel@csn.ul.ie>, Michal Nazarewicz <mina86@mina86.com>, Minchan Kim <minchan@kernel.org>, Bartlomiej Zolnierkiewicz <b.zolnierkie@samsung.com>

On Tue, Mar 5, 2013 at 7:57 AM, Marek Szyprowski
<m.szyprowski@samsung.com> wrote:
> Hello,
>
> Contiguous Memory Allocator is very sensitive about migration failures
> of the individual pages. A single page, which causes permanent migration
> failure can break large conitguous allocations and cause the failure of
> a multimedia device driver.
>
> One of the known issues with migration of CMA pages are the problems of
> migrating the anonymous user pages, for which the others called
> get_user_pages(). This takes a reference to the given user pages to let
> kernel to operate directly on the page content. This is usually used for
> preventing swaping out the page contents and doing direct DMA to/from
> userspace.
>
> To solving this issue requires preventing locking of the pages, which
> are placed in CMA regions, for a long time. Our idea is to migrate
> anonymous page content before locking the page in get_user_pages(). This
> cannot be done automatically, as get_user_pages() interface is used very
> often for various operations, which usually last for a short period of
> time (like for example exec syscall). We have added a new flag
> indicating that the given get_user_space() call will grab pages for a
> long time, thus it is suitable to use the migration workaround in such
> cases.
>
> The proposed extensions is used by V4L2/VideoBuf2
> (drivers/media/v4l2-core/videobuf2-dma-contig.c), but that is not the
> only place which might benefit from it, like any driver which use DMA to
> userspace with get_user_pages(). This one is provided to demonstrate the
> use case.
>
> I would like to hear some comments on the presented approach. What do
> you think about it? Is there a chance to get such workaround merged at
> some point to mainline?

Imo neat trick to make CMA work together with long-term gup'ed
userspace memory in buffer objects, but doesn't really address the
bigger issue that such userspace pinning kills all the nice features
page migration allows. E.g. if your iommu supports huge pages and you
need those to hit some performance targets, but not correctness since
you can fall back to normal pages.

For the userptr support we're playing around with in drm/i915 we've
opted to fix this with the mmu_notifier. That allows us to evict
buffers and unbind the mappings when the vm wants to move a page.
There's still the issue that we can't unbind it right away, but the
usual retry loop for referenced pages in the migration code should
handle that like any other short-lived locked pages for I/O. I see two
issues with that approach though:
- Needs buffer eviction support. No really a problem for drm/i915, a
bit a challenge for v4l ;-)
- The mmu notifiers aren't really designed to keep track of a lot of
tiny ranges in different mms. At least the simplistic approach
currently used in the i915 patches to register a new mmu_notifier for
each buffer object sucks performance wise.

For performance reasons we want to also use get_user_pages_fast, so I
don't think mixing that together with the "please migrate out of CMA"
trick here is a good thing.

Current drm/i915 wip patch is at: https://patchwork.kernel.org/patch/1748601/

Just my 2 cents on this entire issue.

Cheers, Daniel
-- 
Daniel Vetter
Software Engineer, Intel Corporation
+41 (0) 79 365 57 48 - http://blog.ffwll.ch

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx163.postini.com [74.125.245.163])
	by kanga.kvack.org (Postfix) with SMTP id A09DA6B0005
	for <linux-mm@kvack.org>; Wed,  6 Mar 2013 03:47:45 -0500 (EST)
Received: by mail-ve0-f180.google.com with SMTP id jx10so6529974veb.11
        for <linux-mm@kvack.org>; Wed, 06 Mar 2013 00:47:44 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <1362466679-17111-1-git-send-email-m.szyprowski@samsung.com>
References: <1362466679-17111-1-git-send-email-m.szyprowski@samsung.com>
Date: Wed, 6 Mar 2013 17:47:44 +0900
Message-ID: <CAEwNFnBQS+Lem9bNWWngTjOgC5OpF8U=rw8e9zfvZdF8a7iONA@mail.gmail.com>
Subject: Re: [RFC/PATCH 0/5] Contiguous Memory Allocator and get_user_pages()
From: Minchan Kim <minchan@kernel.org>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Marek Szyprowski <m.szyprowski@samsung.com>
Cc: linux-mm@kvack.org, linaro-mm-sig@lists.linaro.org, linux-kernel@vger.kernel.org, Kyungmin Park <kyungmin.park@samsung.com>, Arnd Bergmann <arnd@arndb.de>, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mel@csn.ul.ie>, Michal Nazarewicz <mina86@mina86.com>, Bartlomiej Zolnierkiewicz <b.zolnierkie@samsung.com>

Hello,

On Tue, Mar 5, 2013 at 3:57 PM, Marek Szyprowski
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
>

I discussed similar patch from memory-hotplug guys with Mel.
Look at http://marc.info/?l=linux-mm&m=136014458829566&w=2

The conern is that we ends up forcing using FOLL_DURABLE/GUP_NM for
all drivers and subsystems for making sure CMA/memory-hotplug works
well.

You mentioned driver grab a page for a long time should use
FOLL_DURABLE flag but "for a long time" is very ambiguous. For
example, there is a driver

get_user_pages()
some operation.
put_pages

You can make sure some operation is really fast always?
For example, what if it depends on other event which is normally very
fast but quite slow once a week or try to do dynamic memory allocation
but memory pressure is severe?

For 100% working well, at last we need to change all GUP user with
GUP_NM or your FOLL_DURABLE whatever but the concern Mel pointed out
is it could cause lowmem exhaustion problem.

At the moment, there is other problem against migratoin, which are not
related with your patch. ex, zcache, zram, zswap. Their pages couldn't
be migrated out so I think below Mel's suggestion or some generic
infrastructure can move pinned page is  more proper way to go.

"To guarantee CMA can migrate pages pinned by drivers I think you need
migrate-related callsbacks to unpin, barrier the driver until migration
completes and repin."

Thanks.

-- 
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

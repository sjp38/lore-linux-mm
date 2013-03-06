Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx140.postini.com [74.125.245.140])
	by kanga.kvack.org (Postfix) with SMTP id 36D766B0005
	for <linux-mm@kvack.org>; Wed,  6 Mar 2013 06:54:29 -0500 (EST)
Received: by mail-wg0-f54.google.com with SMTP id fm10so7205362wgb.33
        for <linux-mm@kvack.org>; Wed, 06 Mar 2013 03:54:27 -0800 (PST)
Date: Wed, 6 Mar 2013 12:57:00 +0100
From: Daniel Vetter <daniel@ffwll.ch>
Subject: Re: [RFC/PATCH 0/5] Contiguous Memory Allocator and get_user_pages()
Message-ID: <20130306115700.GN9021@phenom.ffwll.local>
References: <1362466679-17111-1-git-send-email-m.szyprowski@samsung.com>
 <CAEwNFnBQS+Lem9bNWWngTjOgC5OpF8U=rw8e9zfvZdF8a7iONA@mail.gmail.com>
 <51371F04.2050507@samsung.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <51371F04.2050507@samsung.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Marek Szyprowski <m.szyprowski@samsung.com>
Cc: Minchan Kim <minchan@kernel.org>, linux-mm@kvack.org, linaro-mm-sig@lists.linaro.org, linux-kernel@vger.kernel.org, Kyungmin Park <kyungmin.park@samsung.com>, Arnd Bergmann <arnd@arndb.de>, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mel@csn.ul.ie>, Michal Nazarewicz <mina86@mina86.com>, Bartlomiej Zolnierkiewicz <b.zolnierkie@samsung.com>

On Wed, Mar 06, 2013 at 11:48:36AM +0100, Marek Szyprowski wrote:
> Hello,
> 
> On 3/6/2013 9:47 AM, Minchan Kim wrote:
> >Hello,
> >
> >On Tue, Mar 5, 2013 at 3:57 PM, Marek Szyprowski
> ><m.szyprowski@samsung.com> wrote:
> >> Hello,
> >>
> >> Contiguous Memory Allocator is very sensitive about migration failures
> >> of the individual pages. A single page, which causes permanent migration
> >> failure can break large conitguous allocations and cause the failure of
> >> a multimedia device driver.
> >>
> >> One of the known issues with migration of CMA pages are the problems of
> >> migrating the anonymous user pages, for which the others called
> >> get_user_pages(). This takes a reference to the given user pages to let
> >> kernel to operate directly on the page content. This is usually used for
> >> preventing swaping out the page contents and doing direct DMA to/from
> >> userspace.
> >>
> >> To solving this issue requires preventing locking of the pages, which
> >> are placed in CMA regions, for a long time. Our idea is to migrate
> >> anonymous page content before locking the page in get_user_pages(). This
> >> cannot be done automatically, as get_user_pages() interface is used very
> >> often for various operations, which usually last for a short period of
> >> time (like for example exec syscall). We have added a new flag
> >> indicating that the given get_user_space() call will grab pages for a
> >> long time, thus it is suitable to use the migration workaround in such
> >> cases.
> >>
> >> The proposed extensions is used by V4L2/VideoBuf2
> >> (drivers/media/v4l2-core/videobuf2-dma-contig.c), but that is not the
> >> only place which might benefit from it, like any driver which use DMA to
> >> userspace with get_user_pages(). This one is provided to demonstrate the
> >> use case.
> >>
> >> I would like to hear some comments on the presented approach. What do
> >> you think about it? Is there a chance to get such workaround merged at
> >> some point to mainline?
> >>
> >
> >I discussed similar patch from memory-hotplug guys with Mel.
> >Look at http://marc.info/?l=linux-mm&m=136014458829566&w=2
> >
> >The conern is that we ends up forcing using FOLL_DURABLE/GUP_NM for
> >all drivers and subsystems for making sure CMA/memory-hotplug works
> >well.
> >
> >You mentioned driver grab a page for a long time should use
> >FOLL_DURABLE flag but "for a long time" is very ambiguous. For
> >example, there is a driver
> >
> >get_user_pages()
> >some operation.
> >put_pages
> >
> >You can make sure some operation is really fast always?
> 
> Well, in our case (judging from the logs) we observed 2 usage patterns
> for get_user_pages() calls. One group was lots of short time locks, whose
> call stacks originated in various kernel places, the second group was
> device drivers which used get_user_pages() to create a buffer for the
> DMA. Such buffers were used for the whole lifetime of the session to
> the given device, what was equivalent to infinity from the migration/CMA
> point of view. This was however based on the specific use case at out
> target system, that's why I wanted to start the discussion and find
> some generic approach.
> 
> 
> >For example, what if it depends on other event which is normally very
> >fast but quite slow once a week or try to do dynamic memory allocation
> >but memory pressure is severe?
> >
> >For 100% working well, at last we need to change all GUP user with
> >GUP_NM or your FOLL_DURABLE whatever but the concern Mel pointed out
> >is it could cause lowmem exhaustion problem.
> 
> This way we sooner or later end up without any movable pages at all.
> I assume that keeping some temporary references on movable/cma pages
> must be allowed, because otherwise we limit the functionality too much.
> 
> >At the moment, there is other problem against migratoin, which are not
> >related with your patch. ex, zcache, zram, zswap. Their pages couldn't
> >be migrated out so I think below Mel's suggestion or some generic
> >infrastructure can move pinned page is  more proper way to go.
> 
> zcache/zram/zswap (vsmalloc based code) can be also extended to support
> migration. It requires some significant amount of work, but it is really
> doable.
> 
> >"To guarantee CMA can migrate pages pinned by drivers I think you need
> >migrate-related callsbacks to unpin, barrier the driver until migration
> >completes and repin."
> 
> Right, this might improve the migration reliability. Are there any works
> being done in this direction?

See my other mail about how we (ab)use mmu_notifiers in an experimental
drm/i915 patch. I have no idea whether that's the right approach though.
But I'd certainly welcome a generic approach here which works for all
page migration users. And I guess some callback based approach is better
to handle low memory situations, since at least for drm/i915 userptr
backed buffer objects we might want to slurp in the entire available
memory. Or as much as we can get hold off at least. So moving pages to a
safe area before pinning them might not be feasible.
-Daniel
-- 
Daniel Vetter
Software Engineer, Intel Corporation
+41 (0) 79 365 57 48 - http://blog.ffwll.ch

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

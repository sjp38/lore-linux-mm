Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx192.postini.com [74.125.245.192])
	by kanga.kvack.org (Postfix) with SMTP id E31EC6B0002
	for <linux-mm@kvack.org>; Tue,  5 Mar 2013 01:58:26 -0500 (EST)
Received: from epcpsbgm2.samsung.com (epcpsbgm2 [203.254.230.27])
 by mailout2.samsung.com
 (Oracle Communications Messaging Server 7u4-24.01(7.0.4.24.0) 64bit (built Nov
 17 2011)) with ESMTP id <0MJ600DW5E13EZP0@mailout2.samsung.com> for
 linux-mm@kvack.org; Tue, 05 Mar 2013 15:58:25 +0900 (KST)
From: Marek Szyprowski <m.szyprowski@samsung.com>
Subject: [RFC/PATCH 0/5] Contiguous Memory Allocator and get_user_pages()
Date: Tue, 05 Mar 2013 07:57:54 +0100
Message-id: <1362466679-17111-1-git-send-email-m.szyprowski@samsung.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, linaro-mm-sig@lists.linaro.org, linux-kernel@vger.kernel.org
Cc: Marek Szyprowski <m.szyprowski@samsung.com>, Kyungmin Park <kyungmin.park@samsung.com>, Arnd Bergmann <arnd@arndb.de>, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mel@csn.ul.ie>, Michal Nazarewicz <mina86@mina86.com>, Minchan Kim <minchan@kernel.org>, Bartlomiej Zolnierkiewicz <b.zolnierkie@samsung.com>

Hello,

Contiguous Memory Allocator is very sensitive about migration failures
of the individual pages. A single page, which causes permanent migration
failure can break large conitguous allocations and cause the failure of
a multimedia device driver.

One of the known issues with migration of CMA pages are the problems of
migrating the anonymous user pages, for which the others called
get_user_pages(). This takes a reference to the given user pages to let
kernel to operate directly on the page content. This is usually used for
preventing swaping out the page contents and doing direct DMA to/from
userspace.

To solving this issue requires preventing locking of the pages, which
are placed in CMA regions, for a long time. Our idea is to migrate
anonymous page content before locking the page in get_user_pages(). This
cannot be done automatically, as get_user_pages() interface is used very
often for various operations, which usually last for a short period of
time (like for example exec syscall). We have added a new flag
indicating that the given get_user_space() call will grab pages for a
long time, thus it is suitable to use the migration workaround in such
cases.

The proposed extensions is used by V4L2/VideoBuf2
(drivers/media/v4l2-core/videobuf2-dma-contig.c), but that is not the
only place which might benefit from it, like any driver which use DMA to
userspace with get_user_pages(). This one is provided to demonstrate the
use case.

I would like to hear some comments on the presented approach. What do
you think about it? Is there a chance to get such workaround merged at
some point to mainline?

Best regards
Marek Szyprowski
Samsung Poland R&D Center


Patch summary:

Marek Szyprowski (5):
  mm: introduce migrate_replace_page() for migrating page to the given
    target
  mm: get_user_pages: use static inline
  mm: get_user_pages: use NON-MOVABLE pages when FOLL_DURABLE flag is
    set
  mm: get_user_pages: migrate out CMA pages when FOLL_DURABLE flag is
    set
  media: vb2: use FOLL_DURABLE and __get_user_pages() to avoid CMA
    migration issues

 drivers/media/v4l2-core/videobuf2-dma-contig.c |    8 +-
 include/linux/highmem.h                        |   12 ++-
 include/linux/migrate.h                        |    5 +
 include/linux/mm.h                             |   76 ++++++++++++-
 mm/internal.h                                  |   12 +++
 mm/memory.c                                    |  136 +++++++++++-------------
 mm/migrate.c                                   |   59 ++++++++++
 7 files changed, 225 insertions(+), 83 deletions(-)

-- 
1.7.9.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

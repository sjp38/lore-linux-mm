Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx162.postini.com [74.125.245.162])
	by kanga.kvack.org (Postfix) with SMTP id 447E66B0092
	for <linux-mm@kvack.org>; Fri,  4 May 2012 08:41:08 -0400 (EDT)
Received: from euspt2 (mailout2.w1.samsung.com [210.118.77.12])
 by mailout2.w1.samsung.com
 (iPlanet Messaging Server 5.2 Patch 2 (built Jul 14 2004))
 with ESMTP id <0M3I006WE0KCSJ@mailout2.w1.samsung.com> for linux-mm@kvack.org;
 Fri, 04 May 2012 13:41:00 +0100 (BST)
Received: from linux.samsung.com ([106.116.38.10])
 by spt2.w1.samsung.com (iPlanet Messaging Server 5.2 Patch 2 (built Jul 14
 2004)) with ESMTPA id <0M3I00G3A0KG0D@spt2.w1.samsung.com> for
 linux-mm@kvack.org; Fri, 04 May 2012 13:41:04 +0100 (BST)
Date: Fri, 04 May 2012 14:40:41 +0200
From: Bartlomiej Zolnierkiewicz <b.zolnierkie@samsung.com>
Subject: Re: [PATCH v5] mm: compaction: handle incorrect MIGRATE_UNMOVABLE type
 pageblocks
In-reply-to: <20120504110302.GL11435@suse.de>
Message-id: <201205041440.41290.b.zolnierkie@samsung.com>
MIME-version: 1.0
Content-type: Text/Plain; charset=utf-8
Content-transfer-encoding: quoted-printable
References: <201205021047.45188.b.zolnierkie@samsung.com>
 <20120504110302.GL11435@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: linux-mm@kvack.org, Minchan Kim <minchan@kernel.org>, Rik van Riel <riel@redhat.com>, Marek Szyprowski <m.szyprowski@samsung.com>, Kyungmin Park <kyungmin.park@samsung.com>

On Friday 04 May 2012 13:03:02 Mel Gorman wrote:
> On Wed, May 02, 2012 at 10:47:44AM +0200, Bartlomiej Zolnierkiewicz wrote:
> > From: Bartlomiej Zolnierkiewicz <b.zolnierkie@samsung.com>
> > Subject: [PATCH v5] mm: compaction: handle incorrect MIGRATE_UNMOVABLE =
type pageblocks
> >=20
> > When MIGRATE_UNMOVABLE pages are freed from MIGRATE_UNMOVABLE
> > type pageblock (and some MIGRATE_MOVABLE pages are left in it)
> > waiting until an allocation takes ownership of the block may
> > take too long.  The type of the pageblock remains unchanged
> > so the pageblock cannot be used as a migration target during
> > compaction.
> >=20
> > Fix it by:
> >=20
> > * Adding enum compact_mode (COMPACT_ASYNC_[MOVABLE,UNMOVABLE],
> >   and COMPACT_SYNC) and then converting sync field in struct
> >   compact_control to use it.
> >=20
> > * Adding nr_[pageblocks,skipped] fields to struct compact_control
> >   and tracking how many destination pageblocks were scanned during
> >   compaction and how many of them were of MIGRATE_UNMOVABLE type.
> >   If COMPACT_ASYNC_MOVABLE mode compaction ran fully in
> >   try_to_compact_pages() (COMPACT_COMPLETE) it implies that
> >   there is not a suitable page for allocation.  In this case then
> >   check how if there were enough MIGRATE_UNMOVABLE pageblocks to
> >   try a second pass in COMPACT_ASYNC_UNMOVABLE mode.
> >=20
> > * Scanning the MIGRATE_UNMOVABLE pageblocks (during COMPACT_SYNC
> >   and COMPACT_ASYNC_UNMOVABLE compaction modes) and building
> >   a count based on finding PageBuddy pages, page_count(page) =3D=3D 0
> >   or PageLRU pages.  If all pages within the MIGRATE_UNMOVABLE
> >   pageblock are in one of those three sets change the whole
> >   pageblock type to MIGRATE_MOVABLE.
> >=20
> >=20
> > My particular test case (on a ARM EXYNOS4 device with 512 MiB,
> > which means 131072 standard 4KiB pages in 'Normal' zone) is to:
> > - allocate 120000 pages for kernel's usage
> > - free every second page (60000 pages) of memory just allocated
> > - allocate and use 60000 pages from user space
> > - free remaining 60000 pages of kernel memory
> > (now we have fragmented memory occupied mostly by user space pages)
> > - try to allocate 100 order-9 (2048 KiB) pages for kernel's usage
> >=20
> > The results:
> > - with compaction disabled I get 11 successful allocations
> > - with compaction enabled - 14 successful allocations
> > - with this patch I'm able to get all 100 successful allocations
> >=20
> > Cc: Mel Gorman <mgorman@suse.de>
> > Cc: Minchan Kim <minchan@kernel.org>
> > Cc: Rik van Riel <riel@redhat.com>
> > Cc: Marek Szyprowski <m.szyprowski@samsung.com>
> > Signed-off-by: Bartlomiej Zolnierkiewicz <b.zolnierkie@samsung.com>
> > Signed-off-by: Kyungmin Park <kyungmin.park@samsung.com>
>=20
> Minor comments only at this point.
>=20
> > ---
> > v2:
> > - redo the patch basing on review from Mel Gorman
> >   (http://marc.info/?l=3Dlinux-mm&m=3D133519311025444&w=3D2)
> > v3:
> > - apply review comments from Minchan Kim
> >   (http://marc.info/?l=3Dlinux-mm&m=3D133531540308862&w=3D2)
> > v4:
> > - more review comments from Mel
> >   (http://marc.info/?l=3Dlinux-mm&m=3D133545110625042&w=3D2)
> > v5:
> > - even more comments from Mel
> >   (http://marc.info/?l=3Dlinux-mm&m=3D133577669023492&w=3D2)
> > - fix patch description
> >=20
> >  include/linux/compaction.h |   19 +++++++
> >  mm/compaction.c            |  109 ++++++++++++++++++++++++++++++++++++=
+--------
> >  mm/internal.h              |   10 +++-
> >  mm/page_alloc.c            |    8 +--
> >  4 files changed, 124 insertions(+), 22 deletions(-)
> >=20
> > Index: b/include/linux/compaction.h
> > =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
> > --- a/include/linux/compaction.h	2012-05-02 10:39:17.000000000 +0200
> > +++ b/include/linux/compaction.h	2012-05-02 10:40:03.708727714 +0200
> > @@ -1,6 +1,8 @@
> >  #ifndef _LINUX_COMPACTION_H
> >  #define _LINUX_COMPACTION_H
> > =20
> > +#include <linux/node.h>
> > +
>=20
> Why is it necessary to include linux/node.h?

Without it I'm getting:

In file included from mm/internal.h:108,
                 from mm/util.c:10:
include/linux/compaction.h:106: warning: =E2=80=98struct node=E2=80=99 decl=
ared inside parameter list
include/linux/compaction.h:106: warning: its scope is only this definition =
or declaration, which is probably not what you want
include/linux/compaction.h:111: warning: =E2=80=98struct node=E2=80=99 decl=
ared inside parameter list
In file included from mm/internal.h:108,
                 from mm/page_isolation.c:9:
include/linux/compaction.h:106: warning: =E2=80=98struct node=E2=80=99 decl=
ared inside parameter list
include/linux/compaction.h:106: warning: its scope is only this definition =
or declaration, which is probably not what you want
include/linux/compaction.h:111: warning: =E2=80=98struct node=E2=80=99 decl=
ared inside parameter list
In file included from mm/internal.h:108,
                 from mm/mm_init.c:13:
include/linux/compaction.h:106: warning: =E2=80=98struct node=E2=80=99 decl=
ared inside parameter list
include/linux/compaction.h:106: warning: its scope is only this definition =
or declaration, which is probably not what you want
include/linux/compaction.h:111: warning: =E2=80=98struct node=E2=80=99 decl=
ared inside parameter list
In file included from mm/internal.h:108,
                 from mm/bootmem.c:25:
include/linux/compaction.h:106: warning: =E2=80=98struct node=E2=80=99 decl=
ared inside parameter list
include/linux/compaction.h:106: warning: its scope is only this definition =
or declaration, which is probably not what you want
include/linux/compaction.h:111: warning: =E2=80=98struct node=E2=80=99 decl=
ared inside parameter list
In file included from mm/internal.h:108,
                 from mm/sparse.c:13:
include/linux/compaction.h:106: warning: =E2=80=98struct node=E2=80=99 decl=
ared inside parameter list
include/linux/compaction.h:106: warning: its scope is only this definition =
or declaration, which is probably not what you want
include/linux/compaction.h:111: warning: =E2=80=98struct node=E2=80=99 decl=
ared inside parameter list


include/linux/compaction.h:106 is:
static inline int compaction_register_node(struct node *node)

include/linux/compaction.h:111 is:
static inline void compaction_unregister_node(struct node *node)


Best regards,
=2D-
Bartlomiej Zolnierkiewicz
Samsung Poland R&D Center

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

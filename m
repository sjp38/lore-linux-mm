Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx155.postini.com [74.125.245.155])
	by kanga.kvack.org (Postfix) with SMTP id 741316B13F0
	for <linux-mm@kvack.org>; Fri,  3 Feb 2012 04:31:53 -0500 (EST)
MIME-version: 1.0
Content-type: text/plain; charset=utf-8
Received: from euspt2 ([210.118.77.14]) by mailout4.w1.samsung.com
 (Sun Java(tm) System Messaging Server 6.3-8.04 (built Jul 29 2009; 32bit))
 with ESMTP id <0LYT0043B953V430@mailout4.w1.samsung.com> for
 linux-mm@kvack.org; Fri, 03 Feb 2012 09:31:51 +0000 (GMT)
Received: from linux.samsung.com ([106.116.38.10])
 by spt2.w1.samsung.com (iPlanet Messaging Server 5.2 Patch 2 (built Jul 14
 2004)) with ESMTPA id <0LYT00F679537Z@spt2.w1.samsung.com> for
 linux-mm@kvack.org; Fri, 03 Feb 2012 09:31:51 +0000 (GMT)
Date: Fri, 03 Feb 2012 10:31:50 +0100
From: Marek Szyprowski <m.szyprowski@samsung.com>
Subject: RE: [PATCH 02/15] mm: page_alloc: update migrate type of pages on pcp
 when isolating
In-reply-to: <op.v82hjbd13l0zgt@mpn-glaptop>
Message-id: <008101cce256$a85e29f0$f91a7dd0$%szyprowski@samsung.com>
Content-language: pl
Content-transfer-encoding: quoted-printable
References: <1327568457-27734-1-git-send-email-m.szyprowski@samsung.com>
 <1327568457-27734-3-git-send-email-m.szyprowski@samsung.com>
 <20120130111522.GE25268@csn.ul.ie> <op.v8wlu8ws3l0zgt@mpn-glaptop>
 <20120130161447.GU25268@csn.ul.ie>
 <022e01cce034$bc6cf440$3546dcc0$%szyprowski@samsung.com>
 <20120202124729.GA5796@csn.ul.ie> <op.v82hjbd13l0zgt@mpn-glaptop>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: 'Michal Nazarewicz' <mina86@mina86.com>, 'Mel Gorman' <mel@csn.ul.ie>
Cc: linux-kernel@vger.kernel.org, linux-arm-kernel@lists.infradead.org, linux-media@vger.kernel.org, linux-mm@kvack.org, linaro-mm-sig@lists.linaro.org, 'Kyungmin Park' <kyungmin.park@samsung.com>, 'Russell King' <linux@arm.linux.org.uk>, 'Andrew Morton' <akpm@linux-foundation.org>, 'KAMEZAWA Hiroyuki' <kamezawa.hiroyu@jp.fujitsu.com>, 'Daniel Walker' <dwalker@codeaurora.org>, 'Arnd Bergmann' <arnd@arndb.de>, 'Jesse Barker' <jesse.barker@linaro.org>, 'Jonathan Corbet' <corbet@lwn.net>, 'Shariq Hasnain' <shariq.hasnain@linaro.org>, 'Chunsang Jeong' <chunsang.jeong@linaro.org>, 'Dave Hansen' <dave@linux.vnet.ibm.com>, 'Benjamin Gaignard' <benjamin.gaignard@linaro.org>

Hello,

On Thursday, February 02, 2012 8:53 PM Micha=C5=82 Nazarewicz wrote:

> > On Tue, Jan 31, 2012 at 05:23:59PM +0100, Marek Szyprowski wrote:
> >> Pages, which have incorrect migrate type on free finally
> >> causes pageblock migration type change from MIGRATE_CMA to =
MIGRATE_MOVABLE.
>=20
> On Thu, 02 Feb 2012 13:47:29 +0100, Mel Gorman <mel@csn.ul.ie> wrote:
> > I'm not quite seeing this. In free_hot_cold_page(), the pageblock
> > type is checked so the page private should be set to MIGRATE_CMA or
> > MIGRATE_ISOLATE for the CMA area. It's not clear how this can change =
a
> > pageblock to MIGRATE_MOVABLE in error.
>=20
> Here's what I think may happen:
>=20
> When drain_all_pages() is called, __free_one_page() is called for each =
page on
> pcp list with migrate type deducted from page_private() which is =
MIGRATE_CMA.
> This result in the page being put on MIGRATE_CMA freelist even though =
its
> pageblock's migrate type is MIGRATE_ISOLATE.
>=20
> When allocation happens and pcp list is empty, rmqueue_bulk() will get =
executed
> with migratetype argument set to MIGRATE_MOVABLE.  It calls =
__rmqueue() to grab
> some pages and because the page described above is on MIGRATE_CMA =
freelist it
> may be returned back to rmqueue_bulk().
>=20
> But, pageblock's migrate type is not MIGRATE_CMA but MIGRATE_ISOLATE, =
so the
> following code:
>=20
> #ifdef CONFIG_CMA
> 		if (is_pageblock_cma(page))
> 			set_page_private(page, MIGRATE_CMA);
> 		else
> #endif
> 			set_page_private(page, migratetype);
>=20
> will set it's private to MIGRATE_MOVABLE and in the end the page lands =
back
> on MIGRATE_MOVABLE pcp list but this time with page_private =3D=3D =
MIGRATE_MOVABLE
> and not MIGRATE_CMA.
>=20
> One more drain_all_pages() (which may happen since =
alloc_contig_range() calls
> set_migratetype_isolate() for each block) and next =
__rmqueue_fallback() may
> convert the whole pageblock to MIGRATE_MOVABLE.
>=20
> I know, this sounds crazy and improbable, but I couldn't find an =
easier path
> to destruction.  As you pointed, once the page is allocated, =
free_hot_cold_page()
> will do the right thing by reading pageblock's migrate type.
>=20
> Marek is currently experimenting with various patches including the =
following
> change:
>=20
> #ifdef CONFIG_CMA
>                  int mt =3D get_pageblock_migratetype(page);
>                  if (is_migrate_cma(mt) || mt =3D=3D MIGRATE_ISOLATE)
>                          set_page_private(page, mt);
>                  else
> #endif
>                          set_page_private(page, migratetype);
>=20
> As a matter of fact, if __rmqueue() was changed to return migrate type =
of the
> freelist it took page from, we could avoid this =
get_pageblock_migratetype() all
> together.  For now, however, I'd rather not go that way just yet -- =
I'll be happy
> to dig into it once CMA gets merged.

After this and some other changes I'm unable to reproduce that issue. I =
did a whole
night tests and it still works fine, so it looks that it has been =
finally solved.
I will post v20 patchset soon :)

Best regards
--=20
Marek Szyprowski
Samsung Poland R&D Center


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

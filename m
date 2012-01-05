Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx137.postini.com [74.125.245.137])
	by kanga.kvack.org (Postfix) with SMTP id 823A56B005C
	for <linux-mm@kvack.org>; Thu,  5 Jan 2012 14:20:39 -0500 (EST)
Received: from euspt2 (mailout1.w1.samsung.com [210.118.77.11])
 by mailout1.w1.samsung.com
 (iPlanet Messaging Server 5.2 Patch 2 (built Jul 14 2004))
 with ESMTP id <0LXC0005LB2DA4@mailout1.w1.samsung.com> for linux-mm@kvack.org;
 Thu, 05 Jan 2012 19:20:37 +0000 (GMT)
Received: from linux.samsung.com ([106.116.38.10])
 by spt2.w1.samsung.com (iPlanet Messaging Server 5.2 Patch 2 (built Jul 14
 2004)) with ESMTPA id <0LXC000HPB2DBK@spt2.w1.samsung.com> for
 linux-mm@kvack.org; Thu, 05 Jan 2012 19:20:37 +0000 (GMT)
Date: Thu, 05 Jan 2012 20:20:33 +0100
From: Marek Szyprowski <m.szyprowski@samsung.com>
Subject: RE: [PATCH 01/11] mm: page_alloc: set_migratetype_isolate: drain PCP
 prior to isolating
In-reply-to: <op.v7ma4hm33l0zgt@mpn-glaptop>
Message-id: <000601cccbdf$18a87320$49f95960$%szyprowski@samsung.com>
MIME-version: 1.0
Content-type: text/plain; charset=utf-8
Content-language: pl
Content-transfer-encoding: quoted-printable
References: <1325162352-24709-1-git-send-email-m.szyprowski@samsung.com>
 <1325162352-24709-2-git-send-email-m.szyprowski@samsung.com>
 <op.v7ma4hm33l0zgt@mpn-glaptop>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: 'Michal Nazarewicz' <mina86@mina86.com>, linux-kernel@vger.kernel.org, linux-arm-kernel@lists.infradead.org, linux-media@vger.kernel.org, linux-mm@kvack.org, linaro-mm-sig@lists.linaro.org
Cc: 'Kyungmin Park' <kyungmin.park@samsung.com>, 'Russell King' <linux@arm.linux.org.uk>, 'Andrew Morton' <akpm@linux-foundation.org>, 'KAMEZAWA Hiroyuki' <kamezawa.hiroyu@jp.fujitsu.com>, 'Daniel Walker' <dwalker@codeaurora.org>, 'Mel Gorman' <mel@csn.ul.ie>, 'Arnd Bergmann' <arnd@arndb.de>, 'Jesse Barker' <jesse.barker@linaro.org>, 'Jonathan Corbet' <corbet@lwn.net>, 'Shariq Hasnain' <shariq.hasnain@linaro.org>, 'Chunsang Jeong' <chunsang.jeong@linaro.org>, 'Dave Hansen' <dave@linux.vnet.ibm.com>, 'Benjamin Gaignard' <benjamin.gaignard@linaro.org>

Hello,

On Thursday, January 05, 2012 4:40 PM Micha=C5=82 Nazarewicz wrote:

> On Thu, 29 Dec 2011 13:39:02 +0100, Marek Szyprowski =
<m.szyprowski@samsung.com> wrote:
> > From: Michal Nazarewicz <mina86@mina86.com>
> >
> > When set_migratetype_isolate() sets pageblock's migrate type, it =
does
> > not change each page_private data.  This makes sense, as the =
function
> > has no way of knowing what kind of information page_private stores.
> >
> > Unfortunately, if a page is on PCP list, it's page_private indicates
> > its migrate type.  This means, that if a page on PCP list gets
> > isolated, a call to free_pcppages_bulk() will assume it has the old
> > migrate type rather than MIGRATE_ISOLATE.  This means, that a page
> > which should be isolated, will end up on a free list of it's old
> > migrate type.
> >
> > Coincidentally, at the very end, set_migratetype_isolate() calls
> > drain_all_pages() which leads to calling free_pcppages_bulk(), which
> > does the wrong thing.
> >
> > To avoid this situation, this commit moves the draining prior to
> > setting pageblock's migratetype and moving pages from old free list =
to
> > MIGRATETYPE_ISOLATE's free list.
> >
> > Because of spin locks this is a non-trivial change however as both
> > set_migratetype_isolate() and free_pcppages_bulk() grab zone->lock.
> > To solve this problem, this commit renames free_pcppages_bulk() to
> > __free_pcppages_bulk() and changes it so that it no longer grabs
> > zone->lock instead requiring caller to hold it.  This commit later
> > adds a __zone_drain_all_pages() function which works just like
> > drain_all_pages() expects that it drains only pages from a single =
zone
> > and assumes that caller holds zone->lock.
>=20
> As it turns out, with some more testing on SMP systems, this whole =
patch
> turned out to be incorrect.
>=20
> We have been thinking about other approach and, if we were to use =
something
> else then the first patch from CMAv17[1], the best thing we could came =
up
> with was to unconditionally call drain_all_pages() at the beginning of
> set_migratetype_isolate() before the call to spin_lock_irqsave().  It =
has
> a possible race condition but a nightly stress test did have not shown =
any
> problems.
>=20
> Nonetheless, the cleanest, in my opinion, solution is to use the first =
patch
>  from CMAv17 which can be found at [1].
>=20
> So, to sum up: if you intend to test CMAv18, instead of applying this =
first
> patch either use first patch from CMAv17[1] or put an unconditional =
call to
> drain_all_pages() at the beginning of set_migrate_isolate() function.
>=20
> Sorry for the troubles.
>=20
> [1] http://www.spinics.net/lists/arm-kernel/msg148494.html

I've updated our public git repository to include this workaround. You =
can
pull the patches from the following addresses:

git://git.infradead.org/users/kmpark/linux-samsung 3.2-rc7-cma-v18

http://git.infradead.org/users/kmpark/linux-samsung/shortlog/refs/heads/3=
.2-rc7-cma-v18

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

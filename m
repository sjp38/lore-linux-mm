Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx204.postini.com [74.125.245.204])
	by kanga.kvack.org (Postfix) with SMTP id BB18F6B004F
	for <linux-mm@kvack.org>; Fri, 27 Jan 2012 05:53:36 -0500 (EST)
MIME-version: 1.0
Content-type: text/plain; charset=iso-8859-2
Received: from euspt2 ([210.118.77.13]) by mailout3.w1.samsung.com
 (Sun Java(tm) System Messaging Server 6.3-8.04 (built Jul 29 2009; 32bit))
 with ESMTP id <0LYG009TPE9AX030@mailout3.w1.samsung.com> for
 linux-mm@kvack.org; Fri, 27 Jan 2012 10:53:34 +0000 (GMT)
Received: from linux.samsung.com ([106.116.38.10])
 by spt2.w1.samsung.com (iPlanet Messaging Server 5.2 Patch 2 (built Jul 14
 2004)) with ESMTPA id <0LYG00IR4E9AMH@spt2.w1.samsung.com> for
 linux-mm@kvack.org; Fri, 27 Jan 2012 10:53:34 +0000 (GMT)
Date: Fri, 27 Jan 2012 11:53:29 +0100
From: Marek Szyprowski <m.szyprowski@samsung.com>
Subject: RE: [Linaro-mm-sig] [PATCH 12/15] drivers: add Contiguous Memory
 Allocator
In-reply-to: 
 <CADMYwHw1B4RNV_9BqAg_M70da=g69Z3kyo5Cr6izCMwJ9LAtvA@mail.gmail.com>
Message-id: <00de01ccdce1$e7c8a360$b759ea20$%szyprowski@samsung.com>
Content-language: pl
Content-transfer-encoding: quoted-printable
References: <1327568457-27734-1-git-send-email-m.szyprowski@samsung.com>
 <1327568457-27734-13-git-send-email-m.szyprowski@samsung.com>
 <CADMYwHw1B4RNV_9BqAg_M70da=g69Z3kyo5Cr6izCMwJ9LAtvA@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: 'Ohad Ben-Cohen' <ohad@wizery.com>
Cc: linux-kernel@vger.kernel.org, linux-arm-kernel@lists.infradead.org, linux-media@vger.kernel.org, linux-mm@kvack.org, linaro-mm-sig@lists.linaro.org, 'Daniel Walker' <dwalker@codeaurora.org>, 'Russell King' <linux@arm.linux.org.uk>, 'Arnd Bergmann' <arnd@arndb.de>, 'Jonathan Corbet' <corbet@lwn.net>, 'Mel Gorman' <mel@csn.ul.ie>, 'Michal Nazarewicz' <mina86@mina86.com>, 'Dave Hansen' <dave@linux.vnet.ibm.com>, 'Jesse Barker' <jesse.barker@linaro.org>, 'Kyungmin Park' <kyungmin.park@samsung.com>, 'Andrew Morton' <akpm@linux-foundation.org>, 'KAMEZAWA Hiroyuki' <kamezawa.hiroyu@jp.fujitsu.com>

Hi Ohad,

On Friday, January 27, 2012 10:44 AM Ohad Ben-Cohen wrote:

> With v19, I can't seem to allocate big regions anymore (e.g. 101MiB).
> In particular, this seems to fail:
>=20
> On Thu, Jan 26, 2012 at 11:00 AM, Marek Szyprowski
> <m.szyprowski@samsung.com> wrote:
> > +static int cma_activate_area(unsigned long base_pfn, unsigned long =
count)
> > +{
> > + =A0 =A0 =A0 unsigned long pfn =3D base_pfn;
> > + =A0 =A0 =A0 unsigned i =3D count >> pageblock_order;
> > + =A0 =A0 =A0 struct zone *zone;
> > +
> > + =A0 =A0 =A0 WARN_ON_ONCE(!pfn_valid(pfn));
> > + =A0 =A0 =A0 zone =3D page_zone(pfn_to_page(pfn));
> > +
> > + =A0 =A0 =A0 do {
> > + =A0 =A0 =A0 =A0 =A0 =A0 =A0 unsigned j;
> > + =A0 =A0 =A0 =A0 =A0 =A0 =A0 base_pfn =3D pfn;
> > + =A0 =A0 =A0 =A0 =A0 =A0 =A0 for (j =3D pageblock_nr_pages; j; --j, =
pfn++) {
> > + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
WARN_ON_ONCE(!pfn_valid(pfn));
> > + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 if =
(page_zone(pfn_to_page(pfn)) !=3D zone)
> > + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 return =
-EINVAL;
>=20
> The above WARN_ON_ONCE is triggered, and then the conditional is
> asserted (page_zone() retuns a "Movable" zone, whereas zone is
> "Normal") and the function fails.
>=20
> This happens to me on OMAP4 with your 3.3-rc1-cma-v19 branch (and a
> bunch of remoteproc/rpmsg patches).
>=20
> Do big allocations work for you ?

I've tested it with 256MiB on Exynos4 platform. Could you check if the
problem also appears on 3.2-cma-v19 branch (I've uploaded it a few hours
ago) and 3.2-cma-v18? Both are available on our public repo:
git://git.infradead.org/users/kmpark/linux-samsung/

The above code has not been changed since v16, so I'm really surprised=20
that it causes problems. Maybe the memory configuration or layout has=20
been changed in 3.3-rc1 for OMAP4?

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

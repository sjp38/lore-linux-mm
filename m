Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f71.google.com (mail-oi0-f71.google.com [209.85.218.71])
	by kanga.kvack.org (Postfix) with ESMTP id 5D4AC6B000E
	for <linux-mm@kvack.org>; Thu, 19 Jul 2018 05:23:29 -0400 (EDT)
Received: by mail-oi0-f71.google.com with SMTP id p11-v6so6584938oih.17
        for <linux-mm@kvack.org>; Thu, 19 Jul 2018 02:23:29 -0700 (PDT)
Received: from tyo161.gate.nec.co.jp (tyo161.gate.nec.co.jp. [114.179.232.161])
        by mx.google.com with ESMTPS id r206-v6si4008425oib.265.2018.07.19.02.23.27
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 19 Jul 2018 02:23:28 -0700 (PDT)
From: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Subject: Re: [PATCH v2 1/2] mm: fix race on soft-offlining free huge pages
Date: Thu, 19 Jul 2018 09:22:47 +0000
Message-ID: <20180719092247.GB32756@hori1.linux.bs1.fc.nec.co.jp>
References: <1531805552-19547-1-git-send-email-n-horiguchi@ah.jp.nec.com>
 <1531805552-19547-2-git-send-email-n-horiguchi@ah.jp.nec.com>
 <20180717142743.GJ7193@dhcp22.suse.cz>
 <20180718005528.GA12184@hori1.linux.bs1.fc.nec.co.jp>
 <20180718085032.GS7193@dhcp22.suse.cz>
 <20180719061945.GB22154@hori1.linux.bs1.fc.nec.co.jp>
 <20180719071516.GK7193@dhcp22.suse.cz>
 <20180719080804.GA32756@hori1.linux.bs1.fc.nec.co.jp>
 <20180719082743.GN7193@dhcp22.suse.cz>
In-Reply-To: <20180719082743.GN7193@dhcp22.suse.cz>
Content-Language: ja-JP
Content-Type: text/plain; charset="iso-2022-jp"
Content-ID: <6639E86FDB1B77409093923B9A4D5E73@gisp.nec.co.jp>
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, "xishi.qiuxishi@alibaba-inc.com" <xishi.qiuxishi@alibaba-inc.com>, "zy.zhengyi@alibaba-inc.com" <zy.zhengyi@alibaba-inc.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>

On Thu, Jul 19, 2018 at 10:27:43AM +0200, Michal Hocko wrote:
> On Thu 19-07-18 08:08:05, Naoya Horiguchi wrote:
> > On Thu, Jul 19, 2018 at 09:15:16AM +0200, Michal Hocko wrote:
> > > On Thu 19-07-18 06:19:45, Naoya Horiguchi wrote:
> > > > On Wed, Jul 18, 2018 at 10:50:32AM +0200, Michal Hocko wrote:
> [...]
> > > > > Why do we even need HWPoison flag here? Everything can be complet=
ely
> > > > > transparent to the application. It shouldn't fail from what I
> > > > > understood.
> > > >=20
> > > > PageHWPoison flag is used to the 'remove from the allocator' part
> > > > which is like below:
> > > >=20
> > > >   static inline
> > > >   struct page *rmqueue(
> > > >           ...
> > > >           do {
> > > >                   page =3D NULL;
> > > >                   if (alloc_flags & ALLOC_HARDER) {
> > > >                           page =3D __rmqueue_smallest(zone, order, =
MIGRATE_HIGHATOMIC);
> > > >                           if (page)
> > > >                                   trace_mm_page_alloc_zone_locked(p=
age, order, migratetype);
> > > >                   }
> > > >                   if (!page)
> > > >                           page =3D __rmqueue(zone, order, migratety=
pe);
> > > >           } while (page && check_new_pages(page, order));
> > > >=20
> > > > check_new_pages() returns true if the page taken from free list has
> > > > a hwpoison page so that the allocator iterates another round to get
> > > > another page.
> > > >=20
> > > > There's no function that can be called from outside allocator to re=
move
> > > > a page in allocator.  So actual page removal is done at allocation =
time,
> > > > not at error handling time. That's the reason why we need PageHWPoi=
son.
> > >=20
> > > hwpoison is an internal mm functionality so why cannot we simply add =
a
> > > function that would do that?
> >=20
> > That's one possible solution.
>=20
> I would prefer that much more than add an overhead (albeit small) into
> the page allocator directly. HWPoison should be a really rare event so
> why should everybody pay the price? I would much rather see that the
> poison path pays the additional price.

Yes, that's more maintainable.

>=20
> > I know about another downside in current implementation.
> > If a hwpoison page is found during high order page allocation,
> > all 2^order pages (not only hwpoison page) are removed from
> > buddy because of the above quoted code. And these leaked pages
> > are never returned to freelist even with unpoison_memory().
> > If we have a page removal function which properly splits high order
> > free pages into lower order pages, this problem is avoided.
>=20
> Even more reason to move to a new scheme.
>=20
> > OTOH PageHWPoison still has a role to report error to userspace.
> > Without it unpoison_memory() doesn't work.
>=20
> Sure but we do not really need a special page flag for that. We know the
> page is not reachable other than via pfn walkers. If you make the page
> reserved and note the fact it has been poisoned in the past then you can
> emulate the missing functionality.
>=20
> Btw. do we really need unpoisoning functionality? Who is really using
> it, other than some tests?

None, as long as I know.

> How does the memory become OK again?

For hard-offlined in-use pages which are assumed to be pinned,
we clear the PageHWPoison flag and unpin the page to return it to buddy.
For other cases, we simply clear the PageHWPoison flag.
Unless the page is checked by check_new_pages() before unpoison,
the page is reusable.

Sometimes error handling fails and the error page might turn into
unexpected state (like additional refcount/mapcount).
Unpoison just fails on such pages.

> Don't we
> really need to go through physical hotremove & hotadd to clean the
> poison status?

hotremove/hotadd can be a user of unpoison, but I think simply
reinitializing struct pages is easiler.

Thanks,
Naoya Horiguchi=

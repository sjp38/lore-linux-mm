Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f71.google.com (mail-it0-f71.google.com [209.85.214.71])
	by kanga.kvack.org (Postfix) with ESMTP id 370D96B2EC9
	for <linux-mm@kvack.org>; Fri, 24 Aug 2018 04:48:08 -0400 (EDT)
Received: by mail-it0-f71.google.com with SMTP id h5-v6so830085itb.3
        for <linux-mm@kvack.org>; Fri, 24 Aug 2018 01:48:08 -0700 (PDT)
Received: from tyo162.gate.nec.co.jp (tyo162.gate.nec.co.jp. [114.179.232.162])
        by mx.google.com with ESMTPS id x2-v6si2524403ioh.205.2018.08.24.01.48.06
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 24 Aug 2018 01:48:07 -0700 (PDT)
From: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Subject: Re: [PATCH] mm/hugetlb: filter out hugetlb pages if HUGEPAGE
 migration is not supported.
Date: Fri, 24 Aug 2018 08:46:53 +0000
Message-ID: <20180824084652.GA31218@hori1.linux.bs1.fc.nec.co.jp>
References: <20180824063314.21981-1-aneesh.kumar@linux.ibm.com>
 <20180824075815.GA29735@dhcp22.suse.cz>
In-Reply-To: <20180824075815.GA29735@dhcp22.suse.cz>
Content-Language: ja-JP
Content-Type: text/plain; charset="iso-2022-jp"
Content-ID: <D455CDDFDFDC3D49B4F804BCB78999D3@gisp.nec.co.jp>
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Aneesh Kumar K.V" <aneesh.kumar@linux.ibm.com>, Michal Hocko <mhocko@kernel.org>
Cc: "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "mike.kravetz@oracle.com" <mike.kravetz@oracle.com>

On Fri, Aug 24, 2018 at 09:58:15AM +0200, Michal Hocko wrote:
> On Fri 24-08-18 12:03:14, Aneesh Kumar K.V wrote:
> > When scanning for movable pages, filter out Hugetlb pages if hugepage m=
igration
> > is not supported. Without this we hit infinte loop in __offline pages w=
here we
> > do
> > 	pfn =3D scan_movable_pages(start_pfn, end_pfn);
> > 	if (pfn) { /* We have movable pages */
> > 		ret =3D do_migrate_range(pfn, end_pfn);
> > 		goto repeat;
> > 	}
> >=20
> > We do support hugetlb migration ony if the hugetlb pages are at pmd lev=
el. Here
> > we just check for Kernel config. The gigantic page size check is done i=
n
> > page_huge_active.
>=20
> Well, this is a bit misleading. I would say that
>=20
> Fix this by checking hugepage_migration_supported both in has_unmovable_p=
ages
> which is the primary backoff mechanism for page offlining and for
> consistency reasons also into scan_movable_pages because it doesn't make
> any sense to return a pfn to non-migrateable huge page.
>=20
> > Acked-by: Michal Hocko <mhocko@suse.com>
> > Reported-by: Haren Myneni <haren@linux.vnet.ibm.com>
> > CC: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
> > Signed-off-by: Aneesh Kumar K.V <aneesh.kumar@linux.ibm.com>
>=20
> I would add
> Fixes: 72b39cfc4d75 ("mm, memory_hotplug: do not fail offlining too early=
")
>=20
> Not because the bug has been introduced by that commit but rather
> because the issue would be latent before that commit.
>=20
> My Acked-by still holds.

Looks good to me (with Michal's update on description).

Reviewed-by: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>

>=20
> > ---
> >  mm/memory_hotplug.c | 3 ++-
> >  mm/page_alloc.c     | 4 ++++
> >  2 files changed, 6 insertions(+), 1 deletion(-)
> >=20
> > diff --git a/mm/memory_hotplug.c b/mm/memory_hotplug.c
> > index 9eea6e809a4e..38d94b703e9d 100644
> > --- a/mm/memory_hotplug.c
> > +++ b/mm/memory_hotplug.c
> > @@ -1333,7 +1333,8 @@ static unsigned long scan_movable_pages(unsigned =
long start, unsigned long end)
> >  			if (__PageMovable(page))
> >  				return pfn;
> >  			if (PageHuge(page)) {
> > -				if (page_huge_active(page))
> > +				if (hugepage_migration_supported(page_hstate(page)) &&
> > +				    page_huge_active(page))
> >  					return pfn;
> >  				else
> >  					pfn =3D round_up(pfn + 1,
> > diff --git a/mm/page_alloc.c b/mm/page_alloc.c
> > index c677c1506d73..b8d91f59b836 100644
> > --- a/mm/page_alloc.c
> > +++ b/mm/page_alloc.c
> > @@ -7709,6 +7709,10 @@ bool has_unmovable_pages(struct zone *zone, stru=
ct page *page, int count,
> >  		 * handle each tail page individually in migration.
> >  		 */
> >  		if (PageHuge(page)) {
> > +
> > +			if (!hugepage_migration_supported(page_hstate(page)))
> > +				goto unmovable;
> > +
> >  			iter =3D round_up(iter + 1, 1<<compound_order(page)) - 1;
> >  			continue;
> >  		}
> > --=20
> > 2.17.1
>=20
> --=20
> Michal Hocko
> SUSE Labs
> =

Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f177.google.com (mail-pd0-f177.google.com [209.85.192.177])
	by kanga.kvack.org (Postfix) with ESMTP id CC1816B0032
	for <linux-mm@kvack.org>; Tue, 17 Feb 2015 19:28:04 -0500 (EST)
Received: by pdbfl12 with SMTP id fl12so47388821pdb.2
        for <linux-mm@kvack.org>; Tue, 17 Feb 2015 16:28:04 -0800 (PST)
Received: from tyo200.gate.nec.co.jp (TYO200.gate.nec.co.jp. [210.143.35.50])
        by mx.google.com with ESMTPS id zz10si18113304pac.0.2015.02.17.16.28.03
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Tue, 17 Feb 2015 16:28:04 -0800 (PST)
Received: from tyo202.gate.nec.co.jp ([10.7.69.202])
	by tyo200.gate.nec.co.jp (8.13.8/8.13.4) with ESMTP id t1I0S0tJ001448
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=NO)
	for <linux-mm@kvack.org>; Wed, 18 Feb 2015 09:28:01 +0900 (JST)
From: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Subject: Re: [PATCH v2] mm, hugetlb: set PageLRU for in-use/active hugepages
Date: Wed, 18 Feb 2015 00:18:39 +0000
Message-ID: <20150218001824.GB4823@hori1.linux.bs1.fc.nec.co.jp>
References: <1424143299-7557-1-git-send-email-n-horiguchi@ah.jp.nec.com>
 <20150217093153.GA12875@hori1.linux.bs1.fc.nec.co.jp>
 <20150217155744.04db5a98d5a1820240eb2317@linux-foundation.org>
In-Reply-To: <20150217155744.04db5a98d5a1820240eb2317@linux-foundation.org>
Content-Language: ja-JP
Content-Type: text/plain; charset="iso-2022-jp"
Content-ID: <007AF6E634860B44A424245ABECD4D62@gisp.nec.co.jp>
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Hugh Dickins <hughd@google.com>, Michal Hocko <mhocko@suse.cz>, Mel Gorman <mgorman@suse.de>, Johannes Weiner <hannes@cmpxchg.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Naoya Horiguchi <nao.horiguchi@gmail.com>

On Tue, Feb 17, 2015 at 03:57:44PM -0800, Andrew Morton wrote:
> On Tue, 17 Feb 2015 09:32:08 +0000 Naoya Horiguchi <n-horiguchi@ah.jp.nec=
.com> wrote:
>=20
> > Currently we are not safe from concurrent calls of isolate_huge_page(),
> > which can make the victim hugepage in invalid state and results in BUG_=
ON().
> >=20
> > The root problem of this is that we don't have any information on struc=
t page
> > (so easily accessible) about the hugepage's activeness. Note that hugep=
ages'
> > activeness means just being linked to hstate->hugepage_activelist, whic=
h is
> > not the same as normal pages' activeness represented by PageActive flag=
.
> >=20
> > Normal pages are isolated by isolate_lru_page() which prechecks PageLRU=
 before
> > isolation, so let's do similarly for hugetlb. PageLRU is unused on huge=
tlb now,
> > so the change is mostly just inserting Set/ClearPageLRU (no conflict wi=
th
> > current usage.) And the other changes are justified like below:
> > - __put_compound_page() calls __page_cache_release() to do some LRU wor=
ks,
> >   but this is obviously for thps and assumes that hugetlb has always !P=
ageLRU.
> >   This assumption is not true any more, so this patch simply adds if (!=
PageHuge)
> >   to avoid calling __page_cache_release() for hugetlb.
> > - soft_offline_huge_page() now just calls list_move(), but generally ca=
llers
> >   of page migration should use the common routine in isolation, so let'=
s
> >   replace the list_move() with isolate_huge_page() rather than insertin=
g
> >   ClearPageLRU.
> >=20
> > Set/ClearPageLRU should be called within hugetlb_lock, but hugetlb_cow(=
) and
> > hugetlb_no_page() don't do this. This is justified because in these fun=
ction
> > SetPageLRU is called right after the hugepage is allocated and no other=
 thread
> > tries to isolate it.
>=20
> Whoa.
>=20
> So if I'm understanding this correctly, hugepages never have PG_lru set
> and so you are overloading that bit on hugepages to indicate that the
> page is present on hstate->hugepage_activelist?

Right, that's my intention.

> This is somewhat of a big deal and the patch doesn't make it very clear
> at all.  We should
>=20
> - document PG_lru, for both of its identities

OK, I'll do this.

> - consider adding a new PG_hugepage_active(?) flag which has the same
>   value as PG_lru (see how PG_savepinned was done).

I thought of this at first, but didn't do just to avoid complexity for
the first patch. I know this is necessary finally, so I'll do this next.

Maybe I'll name it as PG_hugetlb_active, because just stating "hugepage"
might cause some confusion between hugetlb and thp in the future.

> - create suitable helper functions for the new PG_lru meaning.=20
>   Simply calling PageLRU/SetPageLRU for pages which *aren't on the LRU*
>   is lazy and misleading.  Create a name for the new concept
>   (hugepage_active?) and document it and use it consistently.

OK.

>=20
> > @@ -75,7 +76,8 @@ static void __put_compound_page(struct page *page)
> >  {
> >  	compound_page_dtor *dtor;
> > =20
> > -	__page_cache_release(page);
> > +	if (!PageHuge(page))
> > +		__page_cache_release(page);
> >  	dtor =3D get_compound_page_dtor(page);
> >  	(*dtor)(page);
>=20
> And this needs a good comment - there's no way that a reader can work
> out why this code is here unless he goes dumpster diving in the git
> history.

OK.

Thanks,
Naoya Horiguchi=

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

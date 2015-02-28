Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f42.google.com (mail-pa0-f42.google.com [209.85.220.42])
	by kanga.kvack.org (Postfix) with ESMTP id 558126B0032
	for <linux-mm@kvack.org>; Fri, 27 Feb 2015 21:11:24 -0500 (EST)
Received: by padet14 with SMTP id et14so1244255pad.0
        for <linux-mm@kvack.org>; Fri, 27 Feb 2015 18:11:24 -0800 (PST)
Received: from cnbjrel01.sonyericsson.com (cnbjrel01.sonyericsson.com. [219.141.167.165])
        by mx.google.com with ESMTPS id t4si7768627pda.45.2015.02.27.18.11.22
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Fri, 27 Feb 2015 18:11:23 -0800 (PST)
From: "Wang, Yalin" <Yalin.Wang@sonymobile.com>
Date: Sat, 28 Feb 2015 10:11:13 +0800
Subject: RE: [RFC] mm: change mm_advise_free to clear page dirty
Message-ID: <35FD53F367049845BC99AC72306C23D10458D6173BE0@CNBJMBX05.corpusers.net>
References: <1424765897-27377-1-git-send-email-minchan@kernel.org>
 <20150224154318.GA14939@dhcp22.suse.cz> <20150225000809.GA6468@blaptop>
 <35FD53F367049845BC99AC72306C23D10458D6173BDC@CNBJMBX05.corpusers.net>
 <20150227210233.GA29002@dhcp22.suse.cz>
In-Reply-To: <20150227210233.GA29002@dhcp22.suse.cz>
Content-Language: en-US
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: 'Michal Hocko' <mhocko@suse.cz>
Cc: 'Minchan Kim' <minchan@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Mel Gorman <mgorman@suse.de>, Shaohua Li <shli@kernel.org>

> -----Original Message-----
> From: Michal Hocko [mailto:mstsxfx@gmail.com] On Behalf Of Michal Hocko
> Sent: Saturday, February 28, 2015 5:03 AM
> To: Wang, Yalin
> Cc: 'Minchan Kim'; Andrew Morton; linux-kernel@vger.kernel.org; linux-
> mm@kvack.org; Rik van Riel; Johannes Weiner; Mel Gorman; Shaohua Li
> Subject: Re: [RFC] mm: change mm_advise_free to clear page dirty
>=20
> On Fri 27-02-15 11:37:18, Wang, Yalin wrote:
> > This patch add ClearPageDirty() to clear AnonPage dirty flag,
> > the Anonpage mapcount must be 1, so that this page is only used by
> > the current process, not shared by other process like fork().
> > if not clear page dirty for this anon page, the page will never be
> > treated as freeable.
>=20
> Very well spotted! I haven't noticed that during the review.
>=20
> > Signed-off-by: Yalin Wang <yalin.wang@sonymobile.com>
> > ---
> >  mm/madvise.c | 15 +++++----------
> >  1 file changed, 5 insertions(+), 10 deletions(-)
> >
> > diff --git a/mm/madvise.c b/mm/madvise.c
> > index 6d0fcb8..257925a 100644
> > --- a/mm/madvise.c
> > +++ b/mm/madvise.c
> > @@ -297,22 +297,17 @@ static int madvise_free_pte_range(pmd_t *pmd,
> unsigned long addr,
> >  			continue;
> >
> >  		page =3D vm_normal_page(vma, addr, ptent);
> > -		if (!page)
> > +		if (!page || !PageAnon(page) || !trylock_page(page))
> >  			continue;
>=20
> PageAnon check seems to be redundant because we are not allowing
> MADV_FREE on any !anon private mappings AFAIR.
I only see this check:
/* MADV_FREE works for only anon vma at the moment */
	if (vma->vm_file)
		return -EINVAL;

but for file private map, there are also AnonPage sometimes, do we need cha=
nge
to like this:
	if (vma->vm_flags & VM_SHARED)
		return -EINVAL;
> >
> >  		if (PageSwapCache(page)) {
> > -			if (!trylock_page(page))
> > +			if (!try_to_free_swap(page))
> >  				continue;
>=20
> You need to unlock the page here.
Good spot.

> > -
> > -			if (!try_to_free_swap(page)) {
> > -				unlock_page(page);
> > -				continue;
> > -			}
> > -
> > -			ClearPageDirty(page);
> > -			unlock_page(page);
> >  		}
> >
> > +		if (page_mapcount(page) =3D=3D 1)
> > +			ClearPageDirty(page);
>=20
> Please add a comment about why we need to ClearPageDirty even
> !PageSwapCache. Anon pages are usually not marked dirty AFAIR. The
> reason seem to be racing try_to_free_swap which sets the page that way
> (although I do not seem to remember why are we doing that in the first
> place...)
>=20
Use page_mapcount to judge if a page can be clear dirty flag seems
Not a very good solution, that is because we don't know how many
ptes are share this page, I am thinking if there is some good solution
For shared AnonPage.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

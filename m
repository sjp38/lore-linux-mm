Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ob0-f182.google.com (mail-ob0-f182.google.com [209.85.214.182])
	by kanga.kvack.org (Postfix) with ESMTP id 915196B0071
	for <linux-mm@kvack.org>; Sun,  1 Mar 2015 20:54:27 -0500 (EST)
Received: by mail-ob0-f182.google.com with SMTP id nt9so28057520obb.13
        for <linux-mm@kvack.org>; Sun, 01 Mar 2015 17:54:27 -0800 (PST)
Received: from cnbjrel01.sonyericsson.com (cnbjrel01.sonyericsson.com. [219.141.167.165])
        by mx.google.com with ESMTPS id a10si4355382oel.47.2015.03.01.17.54.25
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Sun, 01 Mar 2015 17:54:26 -0800 (PST)
From: "Wang, Yalin" <Yalin.Wang@sonymobile.com>
Date: Mon, 2 Mar 2015 09:53:59 +0800
Subject: RE: [RFC] mm: change mm_advise_free to clear page dirty
Message-ID: <35FD53F367049845BC99AC72306C23D10458D6173BE2@CNBJMBX05.corpusers.net>
References: <1424765897-27377-1-git-send-email-minchan@kernel.org>
 <20150224154318.GA14939@dhcp22.suse.cz> <20150225000809.GA6468@blaptop>
 <35FD53F367049845BC99AC72306C23D10458D6173BDC@CNBJMBX05.corpusers.net>
 <20150227210233.GA29002@dhcp22.suse.cz>
 <35FD53F367049845BC99AC72306C23D10458D6173BE0@CNBJMBX05.corpusers.net>
 <20150228135555.GB25311@blaptop>
In-Reply-To: <20150228135555.GB25311@blaptop>
Content-Language: en-US
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: 'Minchan Kim' <minchan@kernel.org>
Cc: 'Michal Hocko' <mhocko@suse.cz>, Andrew Morton <akpm@linux-foundation.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Mel Gorman <mgorman@suse.de>, Shaohua Li <shli@kernel.org>

> -----Original Message-----
> From: Minchan Kim [mailto:minchan.kim@gmail.com] On Behalf Of Minchan Kim
> Sent: Saturday, February 28, 2015 9:56 PM
> To: Wang, Yalin
> Cc: 'Michal Hocko'; Andrew Morton; linux-kernel@vger.kernel.org; linux-
> mm@kvack.org; Rik van Riel; Johannes Weiner; Mel Gorman; Shaohua Li
> Subject: Re: [RFC] mm: change mm_advise_free to clear page dirty
>=20
> On Sat, Feb 28, 2015 at 10:11:13AM +0800, Wang, Yalin wrote:
> > > -----Original Message-----
> > > From: Michal Hocko [mailto:mstsxfx@gmail.com] On Behalf Of Michal Hoc=
ko
> > > Sent: Saturday, February 28, 2015 5:03 AM
> > > To: Wang, Yalin
> > > Cc: 'Minchan Kim'; Andrew Morton; linux-kernel@vger.kernel.org; linux=
-
> > > mm@kvack.org; Rik van Riel; Johannes Weiner; Mel Gorman; Shaohua Li
> > > Subject: Re: [RFC] mm: change mm_advise_free to clear page dirty
> > >
> > > On Fri 27-02-15 11:37:18, Wang, Yalin wrote:
> > > > This patch add ClearPageDirty() to clear AnonPage dirty flag,
> > > > the Anonpage mapcount must be 1, so that this page is only used by
> > > > the current process, not shared by other process like fork().
> > > > if not clear page dirty for this anon page, the page will never be
> > > > treated as freeable.
> > >
> > > Very well spotted! I haven't noticed that during the review.
> > >
> > > > Signed-off-by: Yalin Wang <yalin.wang@sonymobile.com>
> > > > ---
> > > >  mm/madvise.c | 15 +++++----------
> > > >  1 file changed, 5 insertions(+), 10 deletions(-)
> > > >
> > > > diff --git a/mm/madvise.c b/mm/madvise.c
> > > > index 6d0fcb8..257925a 100644
> > > > --- a/mm/madvise.c
> > > > +++ b/mm/madvise.c
> > > > @@ -297,22 +297,17 @@ static int madvise_free_pte_range(pmd_t *pmd,
> > > unsigned long addr,
> > > >  			continue;
> > > >
> > > >  		page =3D vm_normal_page(vma, addr, ptent);
> > > > -		if (!page)
> > > > +		if (!page || !PageAnon(page) || !trylock_page(page))
> > > >  			continue;
> > >
> > > PageAnon check seems to be redundant because we are not allowing
> > > MADV_FREE on any !anon private mappings AFAIR.
> > I only see this check:
> > /* MADV_FREE works for only anon vma at the moment */
> > 	if (vma->vm_file)
> > 		return -EINVAL;
> >
> > but for file private map, there are also AnonPage sometimes, do we need
> change
> > to like this:
> > 	if (vma->vm_flags & VM_SHARED)
> > 		return -EINVAL;
>=20
> I couldn't understand your point. In this stage, we intentionally
> disabled madvise_free on file mapped area(AFAIRC, some guys tried
> it long time ago but it had many issues so dropped).
> So, how can file-private mmaped can reach this code?
> Could you elaborate it more about that why we need PageAnon check
> in here?
>=20
I send a new patch:
[RFC V2] mm: change mm_advise_free to clear page dirty
Please have a look at it.
Thanks for your comments!


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

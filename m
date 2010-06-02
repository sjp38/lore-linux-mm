Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id 2E4546B01AC
	for <linux-mm@kvack.org>; Wed,  2 Jun 2010 04:27:56 -0400 (EDT)
Subject: Re: [PATCH 2/5] change direct call of spin_lock(anon_vma->lock) to
 inline function
From: Peter Zijlstra <peterz@infradead.org>
In-Reply-To: <20100601150402.c828b219.akpm@linux-foundation.org>
References: <20100526153819.6e5cec0d@annuminas.surriel.com>
	 <20100526153926.1272945b@annuminas.surriel.com>
	 <20100601150402.c828b219.akpm@linux-foundation.org>
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable
Date: Wed, 02 Jun 2010 10:27:55 +0200
Message-ID: <1275467275.27810.30644.camel@twins>
Mime-Version: 1.0
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Rik van Riel <riel@redhat.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Mel Gorman <mel@csn.ul.ie>, Andrea Arcangeli <aarcange@redhat.com>, Minchan Kim <minchan.kim@gmail.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Lee Schermerhorn <Lee.Schermerhorn@hp.com>
List-ID: <linux-mm.kvack.org>

On Tue, 2010-06-01 at 15:04 -0700, Andrew Morton wrote:
> On Wed, 26 May 2010 15:39:26 -0400
> Rik van Riel <riel@redhat.com> wrote:
>=20
> > @@ -303,10 +303,10 @@ again:
> >  		goto out;
> > =20
> >  	anon_vma =3D (struct anon_vma *) (anon_mapping - PAGE_MAPPING_ANON);
> > -	spin_lock(&anon_vma->lock);
> > +	anon_vma_lock(anon_vma);
> > =20
> >  	if (page_rmapping(page) !=3D anon_vma) {
> > -		spin_unlock(&anon_vma->lock);
> > +		anon_vma_unlock(anon_vma);
> >  		goto again;
> >  	}
> > =20
>=20
> This bit is dependent upon Peter's
> mm-revalidate-anon_vma-in-page_lock_anon_vma.patch (below).  I've been
> twiddling thumbs for weeks awaiting the updated version of that patch
> (hint).

Yeah, drop it, the updated patch is only a comment trying to explain why
the current code is ok.

> Do we think that this patch series is needed in 2.6.35?  If so, why?=20
> And if so I guess we'll need to route around
> mm-revalidate-anon_vma-in-page_lock_anon_vma.patch, or just merge it
> as-is.
>=20

I don't actually think that patch of mine is needed, the reject Rik's
patch generates without it is rather trivial to fix up, if you want I
can send you a fixed up version.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

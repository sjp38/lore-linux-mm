Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id 7AAD76B0169
	for <linux-mm@kvack.org>; Fri,  5 Aug 2011 11:51:46 -0400 (EDT)
Date: Fri, 5 Aug 2011 10:51:42 -0500 (CDT)
From: Christoph Lameter <cl@linux.com>
Subject: Re: kernel BUG at mm/vmscan.c:1114
In-Reply-To: <20110805125542.GW19099@suse.de>
Message-ID: <alpine.DEB.2.00.1108051041580.27518@router.home>
References: <CAJn8CcE20-co4xNOD8c+0jMeABrc1mjmGzju3xT34QwHHHFsUA@mail.gmail.com> <CAJn8CcG-pNbg88+HLB=tRr26_R+A0RxZEWsJQg4iGe4eY2noXA@mail.gmail.com> <20110802002226.3ff0b342.akpm@linux-foundation.org> <CAJn8CcGTwhAaqghqWOYN9mGvRZDzyd9UJbYARz7NGA-7NvFg9Q@mail.gmail.com>
 <20110803085437.GB19099@suse.de> <CAJn8CcGGsdPdaJ7t_RcBmFOGgVLVjAP8Mr40Cv=FknLTNgBUsg@mail.gmail.com> <CAJn8CcE2BRhHO6qiu2JigdYsjc-igedaA_wu8w70YBbisQTgcQ@mail.gmail.com> <20110805091957.GV19099@suse.de> <CAJn8CcH35xhhAwaAouc15H7bYvOe2dYc4LmL+ymX-riaX8p_xg@mail.gmail.com>
 <CAJn8CcEM6sa+s06ouL_eadtWpnsieKBupDeUM5R9gCbad3D6eQ@mail.gmail.com> <20110805125542.GW19099@suse.de>
MIME-Version: 1.0
Content-Type: MULTIPART/MIXED; BOUNDARY="-1463811839-353538231-1312559503=:27518"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: Xiaotian Feng <xtfeng@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel <linux-kernel@vger.kernel.org>, Pekka Enberg <penberg@kernel.org>

  This message is in MIME format.  The first part should be readable text,
  while the remaining parts are likely unreadable without MIME-aware tools.

---1463811839-353538231-1312559503=:27518
Content-Type: TEXT/PLAIN; charset=iso-8859-15
Content-Transfer-Encoding: QUOTED-PRINTABLE

On Fri, 5 Aug 2011, Mel Gorman wrote:

> > > This is interesting, I just change as following:
> > >
> > > diff --git a/mm/slub.c b/mm/slub.c
> > > index eb5a8f9..616b78e 100644
> > > --- a/mm/slub.c
> > > +++ b/mm/slub.c
> > > @@ -2104,8 +2104,9 @@ static void *__slab_alloc(struct kmem_cache *s,
> > > gfp_t gfpflags, int node,
> > > =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0"__slab_alloc"));
> > >
> > > =A0 =A0 =A0 =A0if (unlikely(!object)) {
> > > - =A0 =A0 =A0 =A0 =A0 =A0 =A0 c->page =3D NULL;
> > > + =A0 =A0 =A0 =A0 =A0 =A0 =A0 //c->page =3D NULL;
> > > =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0stat(s, DEACTIVATE_BYPASS);
> > > + =A0 =A0 =A0 =A0 =A0 =A0 =A0 deactivate_slab(s, c);
> > > =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0goto new_slab;
> > > =A0 =A0 =A0 =A0}
> > >
> > > Then my system doesn't print any list corruption warnings and my buil=
d
> > > success then. So this means revert of 03e404af2 could cure this.
> > > I'll do more test next week to see if the list corruption still exist=
, thanks.
> > >
> >
> > Sorry, please ignore it... My system corrupted before I went to leave .=
=2E..
> >
>
> Please continue the bisection in that case and establish for sure if the
> problem is in that series or not. Thanks.

The above fix should not affect anything since a per cpu slab
is not on any partial lists. And since there are no objects remaining in
the slab there is then also no point of putting it back. It wont be on
any lists before and after the action so no list processing is needed.

Hmmm.... There maybe a race with slab_free from a remote processor. I
dont see any problem here since we convert the page from frozen to
nonfrozen in __slab_alloc and __slab_free will ignore the partial list
management if it sees it to be frozen.

Maybe we need some memory barriers here. Right now we are relying on the
cmpxchg_double for sync of the state in the page struct but we also need
the c->page variable to be consistent with that state. But we disable
interrupts in __slab_alloc so there are no races possible with slab_free
only with remote __slab_free invocations which will not touch c->page.




---1463811839-353538231-1312559503=:27518--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

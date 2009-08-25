Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with SMTP id 2369C6B00E4
	for <linux-mm@kvack.org>; Tue, 25 Aug 2009 18:04:40 -0400 (EDT)
Date: Tue, 25 Aug 2009 10:03:30 +0100 (BST)
From: Hugh Dickins <hugh.dickins@tiscali.co.uk>
Subject: Re: [PATCH] mm: make munlock fast when mlock is canceled by sigkill
In-Reply-To: <82e12e5f0908242146uad0f314hcbb02fcc999a1d32@mail.gmail.com>
Message-ID: <Pine.LNX.4.64.0908250947400.2872@sister.anvils>
References: <82e12e5f0908220954p7019fb3dg15f9b99bb7e55a8c@mail.gmail.com>
 <28c262360908231844o3df95b14v15b2d4424465f033@mail.gmail.com>
 <20090824105139.c2ab8403.kamezawa.hiroyu@jp.fujitsu.com>
 <2f11576a0908232113w71676aatf22eb6d431501fd0@mail.gmail.com>
 <82e12e5f0908242146uad0f314hcbb02fcc999a1d32@mail.gmail.com>
MIME-Version: 1.0
Content-Type: MULTIPART/MIXED; BOUNDARY="8323584-1536434056-1251191010=:2872"
Sender: owner-linux-mm@kvack.org
To: Hiroaki Wakabayashi <primulaelatior@gmail.com>
Cc: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Minchan Kim <minchan.kim@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>, linux-mm@kvack.org, Paul Menage <menage@google.com>, Ying Han <yinghan@google.com>, Pekka Enberg <penberg@cs.helsinki.fi>, Lee Schermerhorn <lee.schermerhorn@hp.com>
List-ID: <linux-mm.kvack.org>

  This message is in MIME format.  The first part should be readable text,
  while the remaining parts are likely unreadable without MIME-aware tools.

--8323584-1536434056-1251191010=:2872
Content-Type: TEXT/PLAIN; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE

On Tue, 25 Aug 2009, Hiroaki Wakabayashi wrote:
> Thank you for reviews.
>=20
> >>> > @@ -254,6 +254,7 @@ static inline void
> >>> > mminit_validate_memmodel_limits(unsigned long *start_pfn,
> >>> > =C2=A0#define GUP_FLAGS_FORCE =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0 =C2=A0 =C2=A00x2
> >>> > =C2=A0#define GUP_FLAGS_IGNORE_VMA_PERMISSIONS 0x4
> >>> > =C2=A0#define GUP_FLAGS_IGNORE_SIGKILL =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
0x8
> >>> > +#define GUP_FLAGS_ALLOW_NULL =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 0x10
> >>> >
> >>>
> >>> I am worried about adding new flag whenever we need it.

Indeed!  See my comments below.

> >>> But I think this case makes sense to me.
> >>> In addition, I guess ZERO page can also use this flag.
> >>>
> >>> Kame. What do you think about it?
> >>>
> >> I do welcome this !
> >> Then, I don't have to take care of mlock/munlock in ZERO_PAGE patch.

I _think_ there's nothing to do for it (the page->mapping checks suit
the ZERO_PAGE); but I've not started testing my version, so may soon
be proved wrong.

> >>
> >> And without this patch, munlock() does copy-on-write just for unpinnin=
g memory.
> >> So, this patch shows some right direction, I think.
> >>
> >> One concern is flag name, ALLOW_NULL sounds not very good.
> >>
> >> =C2=A0GUP_FLAGS_NOFAULT ?
> >>
> >> I wonder we can remove a hack of FOLL_ANON for core-dump by this flag,=
 too.

No, the considerations there a different (it can only point to a ZERO_PAGE
where faulting would anyway present a page of zeroes); it should be dealt
with by a coredump-specific flag, rather than sowing confusion elsewhere.
As above, I've done that but not yet tested it.

> >
> > Yeah, GUP_FLAGS_NOFAULT is better.
>=20
> Me too.
> I will change this flag name.
>...=20
> When I try to change __get_user_pages(), I got problem.
> If remove NULLs from pages,
> __mlock_vma_pages_range() cannot know how long __get_user_pages() readed.
> So, I have to get the virtual address of the page from vma and page.
> Because __mlock_vma_pages_range() have to call
> __get_user_pages() many times with different `start' argument.
>=20
> I try to use page_address_in_vma(), but it failed.
> (page_address_in_vma() returned -EFAULT)
> I cannot find way to solve this problem.
> Are there good ideas?
> Please give me some ideas.

I agree that this munlock issue needs to be addressed: it's not just a
matter of speedup, I hit it when testing what happens when mlock takes
you to OOM - which is currently a hanging disaster because munlock'ing
in the exiting OOM-killed process gets stuck trying to fault in all
those pages that couldn't be locked in the first place.

I had intended to fix it by being more careful about splitting/merging
vmas, noting how far the mlock had got, and munlocking just up to there.
However, now that I've got in there, that looks wrong to me, given the
traditional behaviour that mlock does its best, but pretends success
to allow for later instantiation of the pages if necessary.

You ask for ideas.  My main idea is that so far we have added
GUP_FLAGS_IGNORE_VMA_PERMISSIONS (Kosaki-san, what was that about?
                                  we already had the force flag),
GUP_FLAGS_IGNORE_SIGKILL, and now you propose
GUP_FLAGS_NOFAULT, all for the sole use of munlock.

How about GUP_FLAGS_MUNLOCK, or more to the point, GUP_FLAGS_DONT_BE_GUP?
By which I mean, don't all these added flags suggest that almost
everything __get_user_pages() does is unsuited to the munlock case?

My advice (but I sure hate giving advice before I've tried it myself)
is to put __mlock_vma_pages_range() back to handling just the mlock
case, and do your own follow_page() loop in munlock_vma_pages_range().

Hugh
--8323584-1536434056-1251191010=:2872--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

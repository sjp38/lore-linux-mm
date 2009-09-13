Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id 317BC6B004F
	for <linux-mm@kvack.org>; Sun, 13 Sep 2009 11:46:51 -0400 (EDT)
Date: Sun, 13 Sep 2009 16:46:12 +0100 (BST)
From: Hugh Dickins <hugh.dickins@tiscali.co.uk>
Subject: Re: [PATCH 4/8] mm: FOLL_DUMP replace FOLL_ANON
In-Reply-To: <28c262360909090916w12d700b3w7fa8a970f3aba3af@mail.gmail.com>
Message-ID: <Pine.LNX.4.64.0909131636540.22865@sister.anvils>
References: <Pine.LNX.4.64.0909072222070.15424@sister.anvils>
 <Pine.LNX.4.64.0909072233240.15430@sister.anvils>
 <28c262360909090916w12d700b3w7fa8a970f3aba3af@mail.gmail.com>
MIME-Version: 1.0
Content-Type: MULTIPART/MIXED; BOUNDARY="8323584-2139220000-1252856772=:22865"
Sender: owner-linux-mm@kvack.org
To: Minchan Kim <minchan.kim@gmail.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mel@csn.ul.ie>, Jeff Chua <jeff.chua.linux@gmail.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Linus Torvalds <torvalds@linux-foundation.org>, Nick Piggin <npiggin@suse.de>, Rik van Riel <riel@redhat.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

  This message is in MIME format.  The first part should be readable text,
  while the remaining parts are likely unreadable without MIME-aware tools.

--8323584-2139220000-1252856772=:22865
Content-Type: TEXT/PLAIN; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE

On Thu, 10 Sep 2009, Minchan Kim wrote:
> > =C2=A0 =C2=A0 =C2=A0 =C2=A0/*
> > =C2=A0 =C2=A0 =C2=A0 =C2=A0 * When core dumping an enormous anonymous a=
rea that nobody
> > - =C2=A0 =C2=A0 =C2=A0 =C2=A0* has touched so far, we don't want to all=
ocate page tables.
> > + =C2=A0 =C2=A0 =C2=A0 =C2=A0* has touched so far, we don't want to all=
ocate unnecessary pages or
> > + =C2=A0 =C2=A0 =C2=A0 =C2=A0* page tables. =C2=A0Return error instead =
of NULL to skip handle_mm_fault,
> > + =C2=A0 =C2=A0 =C2=A0 =C2=A0* then get_dump_page() will return NULL to=
 leave a hole in the dump.
> > + =C2=A0 =C2=A0 =C2=A0 =C2=A0* But we can only make this optimization w=
here a hole would surely
> > + =C2=A0 =C2=A0 =C2=A0 =C2=A0* be zero-filled if handle_mm_fault() actu=
ally did handle it.
> > =C2=A0 =C2=A0 =C2=A0 =C2=A0 */
> > - =C2=A0 =C2=A0 =C2=A0 if (flags & FOLL_ANON) {
> > - =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 page =3D ZERO_PAGE(0=
);
> > - =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 if (flags & FOLL_GET=
)
> > - =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0 get_page(page);
> > - =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 BUG_ON(flags & FOLL_=
WRITE);
> > - =C2=A0 =C2=A0 =C2=A0 }
> > + =C2=A0 =C2=A0 =C2=A0 if ((flags & FOLL_DUMP) &&
> > + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 (!vma->vm_ops || !vma->vm_ops->fau=
lt))
>=20
> How about adding comment about zero page use?

What kind of comment did you have in mind?
We used to use ZERO_PAGE there, but with this patch we're not using it.
I thought the comment above describes what we're doing well enough.

I may have kept too quiet about ZERO_PAGEs, knowing that a later patch
was going to change the story; but I don't see what needs saying here.

Hugh
--8323584-2139220000-1252856772=:22865--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

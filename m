Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id A4C486B0044
	for <linux-mm@kvack.org>; Mon, 22 Dec 2008 19:45:45 -0500 (EST)
Date: Tue, 23 Dec 2008 00:46:51 +0000 (GMT)
From: Hugh Dickins <hugh@veritas.com>
Subject: Re: [rfc][patch] unlock_page speedup
In-Reply-To: <alpine.LFD.2.00.0812190941120.14014@localhost.localdomain>
Message-ID: <Pine.LNX.4.64.0812230038070.13610@blonde.anvils>
References: <20081219072909.GC26419@wotan.suse.de>
 <20081218233549.cb451bc8.akpm@linux-foundation.org>
 <alpine.LFD.2.00.0812190926000.14014@localhost.localdomain>
 <alpine.LFD.2.00.0812190941120.14014@localhost.localdomain>
MIME-Version: 1.0
Content-Type: MULTIPART/MIXED; BOUNDARY="8323584-973548782-1229993211=:13610"
Sender: owner-linux-mm@kvack.org
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Nick Piggin <npiggin@suse.de>, Linux Memory Management List <linux-mm@kvack.org>, linux-fsdevel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

  This message is in MIME format.  The first part should be readable text,
  while the remaining parts are likely unreadable without MIME-aware tools.

--8323584-973548782-1229993211=:13610
Content-Type: TEXT/PLAIN; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE

On Fri, 19 Dec 2008, Linus Torvalds wrote:
>=20
> That said, I did notice a problem. Namely that while the VM code is good=
=20
> about looking at ->mapping (because it doesn't know whether the page is=
=20
> anonymous or a true mapping), much of the filesystem code is _not_ carefu=
l=20
> about page->mapping, since the filesystem code knows a-priori that the=20
> mapping pointer must be an inode mapping (or we'd not have called it).
>=20
> So filesystems do tend to do things like
>=20
> =09struct inode *inode =3D page->mapping->host;
>=20
> and while the low bit of mapping is magic, those code-paths don't care=20
> because they depend on it being zero.
>=20
> So hiding the lock bit there would involve a lot more work than I na=C3=
=AFvely=20
> expected before looking closer. We'd have to change the name (to=20
> "_mapping", presumably), and make all users use an accessor function to=
=20
> make code like the above do
>=20
> =09struct inode *inode =3D page_mapping(page)->host;
>=20
> or something (we migth want to have a "page_host_inode()" helper to do it=
,=20
> it seems to be the most common reason for accessing "->mapping" that=20
> there is.
>=20
> So it could be done pretty mechanically, but it's still a _big_ change.=
=20
> Maybe not worth it, unless we can really translate it into some other=20
> advantage (ie real simplification of page flag access)

Yes, it's messy, particularly given out-of-tree filesystems.

Perhaps there's somewhere else in the struct page you could keep the
lock bit and get the advantage you're looking for: playing with the
low bits of page->mapping is best left to anon pages.

I did have a patch to keep PG_swapcache there: that got stalled on
dreaming up enough memorable names for variants of page_mapping()
that I turned out to need, then it got buried under other work.

I'll resurrect it in the next month or so; it would be nice to
keep PG_swapbacked there too, but it's not quite as easy since
Rik's split LRU categorizes shmem/tmpfs pages as swapbacked i.e.
that flag applies to anon and also to one particular filesystem.

Hugh
--8323584-973548782-1229993211=:13610--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id B69046B00F5
	for <linux-mm@kvack.org>; Tue, 16 Nov 2010 18:29:03 -0500 (EST)
Received: from hpaq3.eem.corp.google.com (hpaq3.eem.corp.google.com [172.25.149.3])
	by smtp-out.google.com with ESMTP id oAGNSx8u009477
	for <linux-mm@kvack.org>; Tue, 16 Nov 2010 15:28:59 -0800
Received: from pwj4 (pwj4.prod.google.com [10.241.219.68])
	by hpaq3.eem.corp.google.com with ESMTP id oAGNSjLJ014598
	for <linux-mm@kvack.org>; Tue, 16 Nov 2010 15:28:58 -0800
Received: by pwj4 with SMTP id 4so476188pwj.38
        for <linux-mm@kvack.org>; Tue, 16 Nov 2010 15:28:53 -0800 (PST)
Date: Tue, 16 Nov 2010 15:28:45 -0800 (PST)
From: Hugh Dickins <hughd@google.com>
Subject: Re: RFC: reviving mlock isolation dead code
In-Reply-To: <AANLkTin+16yDxGrRfbqw9OPnDDV8OgXr_nbZnXJEHK9w@mail.gmail.com>
Message-ID: <alpine.LSU.2.00.1011161444200.16422@tigran.mtv.corp.google.com>
References: <20101109115540.BC3F.A69D9226@jp.fujitsu.com> <AANLkTinrtXrwgwUXNOaM_AGin2iEMqN2wWciMzJUPUyB@mail.gmail.com> <20101112142038.E002.A69D9226@jp.fujitsu.com> <alpine.LSU.2.00.1011151717130.10920@tigran.mtv.corp.google.com>
 <AANLkTin+16yDxGrRfbqw9OPnDDV8OgXr_nbZnXJEHK9w@mail.gmail.com>
MIME-Version: 1.0
Content-Type: MULTIPART/MIXED; BOUNDARY="380388936-495940446-1289950132=:16422"
Sender: owner-linux-mm@kvack.org
To: Michel Lespinasse <walken@google.com>
Cc: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Peter Zijlstra <peterz@infradead.org>, Nick Piggin <npiggin@kernel.dk>, Arjan van de Ven <arjan@infradead.org>, linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

  This message is in MIME format.  The first part should be readable text,
  while the remaining parts are likely unreadable without MIME-aware tools.

--380388936-495940446-1289950132=:16422
Content-Type: TEXT/PLAIN; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE

On Mon, 15 Nov 2010, Michel Lespinasse wrote:
> On Mon, Nov 15, 2010 at 5:44 PM, Hugh Dickins <hughd@google.com> wrote:
> > On Sun, 14 Nov 2010, KOSAKI Motohiro wrote:
> >> Michel Lespinasse <walken@google.com> wrote:
> >> > ...
> >> > The other mlock related issue I have is that it marks pages as dirty
> >> > (if they are in a writable VMA), and causes writeback to work on the=
m,
> >> > even though the pages have not actually been modified. This looks li=
ke
> >> > it would be solvable with a new get_user_pages flag for mlock use
> >> > (breaking cow etc, but not writing to the pages just yet).
> >>
> >> To be honest, I haven't understand why current code does so. I dislike=
 it too. but
> >> I'm not sure such change is safe or not. I hope another developer comm=
ent you ;-)
> >
> > It's been that way for years, and the primary purpose is to do the COWs
> > in advance, so we won't need to allocate new pages later to the locked
> > area: the pages that may be needed are already locked down.
>=20
> Thanks Hugh for posting your comments. I was aware of Suleiman's
> proposal to always do a READ mode get_user_pages years ago, and I
> could see that we'd need a new flag instead so we can break COW
> without dirtying pages, but I hadn't thought about other issues.
>=20
> > That justifies it for the private mapping case, but what of shared maps=
?
> > There the justification is that the underlying file might be sparse, an=
d
> > we want to allocate blocks upfront for the locked area.
> >
> > Do we? =A0I dislike it also, as you both do. =A0It seems crazy to mark =
a
> > vast number of pages as dirty when they're not.
> >
> > It makes sense to mark pte_dirty when we have a real write fault to a
> > page, to save the mmu from making that pagetable transaction immediatel=
y
> > after; but it does not make sense when the write (if any) may come
> > minutes later - we'll just do a pointless write and clear dirty meanwhi=
le.
>=20
> If we just mlocked the page but did not made it writable (or mark it
> dirty) yet, would we be allowed to skip the page_mkwrite method call ?

Yes, indeed you should skip it in that case.

>=20
> I believe this would be legal:

Yes, I agree that it would be legal.

>=20
> - If/when an actual write comes later on, we'll run through
> do_wp_page() again, and reuse the old page, making it writable and
> dirty from then on. Since this is a shared mapping, we won't have to
> allocate a new page at a that time, so this preserves the mlock
> semantic of having all necessary pages preallocated.
>=20
> - If we skip page_mkwrite(), we can't guarantee that the filesystem
> will have a free block to allocate, but is this actually part of the
> mlock() semantics ? I think not, given that only a few filesystems
> implement page_mkwrite() in the first place. ext4 does, but ext2/3
> does not, for example. So while skipping page_mkwrite() would prevent
> data blocks from being pre-allocated, I don't really see it as
> breaking mlock() ?

Yes, allocating the blocks is not actually part of mlock() semantics.

And a few years ago, there was no ->page_mkwrite(), and the ->nopage()
interface didn't tell the filesystem whether it was read or write fault
(and mlocking a writable vma certainly didn't do synchronous writes back
to disk before the mlock returned success or failure).

It's all a matter of QoS: is it acceptable to make the change, that
a write fault to an mlocked area of a sparse file might now generate
SIGBUS, on a few filesystems which have recently been guaranteeing not?

Personally, I believe that's more acceptable than doing a huge rush of
(almost always) pointless writes at the time of mlock().  But I can
see that others may disagree.

>=20
> > If it does work out, I think you'd need to be passing the flag down to
> > follow_page too: I have a patch or patches to merge the FOLL_flags with
> > the FAULT_FLAGs - Linus wanted that a year ago, and I recently met a
> > need for it with shmem - I'd better accelerate sending those in.
>=20
> The follow_page change is simpler, it might even be sufficient to not
> pass in the FOLL_TOUCH flag I think.

Yes, in fact, is anything required beyond Peter's original simple patch?

There are some tweaks that could be added.  A FAULT_FLAG to let filesystem
know that we're mlocking a writable area, so it could be careful about it?
only useful if some filesystem uses it!  A check on vma_wants_writenotify()
or something like it, so mlock does set pte_write if it's okay e.g. tmpfs?
Second order things, probably don't matter.

Added Ccs of those most likely to agree or disagree with us.

Hugh
--380388936-495940446-1289950132=:16422--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

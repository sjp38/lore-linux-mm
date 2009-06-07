Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id 5FC2D6B004D
	for <linux-mm@kvack.org>; Sun,  7 Jun 2009 11:51:37 -0400 (EDT)
Date: Sun, 7 Jun 2009 17:28:39 +0100 (BST)
From: Hugh Dickins <hugh.dickins@tiscali.co.uk>
Subject: Re: [RFC] remove page_table_lock in anon_vma_prepare
In-Reply-To: <28c262360906070816h765bf4fag9b426199ac0627d@mail.gmail.com>
Message-ID: <Pine.LNX.4.64.0906071651410.17597@sister.anvils>
References: <1244212553-21629-1-git-send-email-minchan.kim@gmail.com>
 <Pine.LNX.4.64.0906051906000.14826@sister.anvils>
 <28c262360906070816h765bf4fag9b426199ac0627d@mail.gmail.com>
MIME-Version: 1.0
Content-Type: MULTIPART/MIXED; BOUNDARY="8323584-1606777726-1244392119=:17597"
Sender: owner-linux-mm@kvack.org
To: Minchan Kim <minchan.kim@gmail.com>
Cc: Hugh Dickins <hugh.dickins@tiscali.co.uk>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Rik van Riel <riel@redhat.com>, Nick Piggin <npiggin@suse.de>
List-ID: <linux-mm.kvack.org>

  This message is in MIME format.  The first part should be readable text,
  while the remaining parts are likely unreadable without MIME-aware tools.

--8323584-1606777726-1244392119=:17597
Content-Type: TEXT/PLAIN; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE

On Mon, 8 Jun 2009, Minchan Kim wrote:
> On Sat, Jun 6, 2009 at 3:26 AM, Hugh Dickins<hugh.dickins@tiscali.co.uk> =
wrote:
> > On Fri, 5 Jun 2009, Minchan Kim wrote:
>=20
> > (As I expect you've noticed, we used not to bother with the spin_lock
> > on anon_vma->lock when we'd freshly allocated the anon_vma, it looks
> > as if it's unnecessary. =C2=A0But in fact Nick and Linus found there's =
a
> > subtle reason why it is necessary even then - hopefully the git log

Actually, Linus put a lot of his git comment into the comment above
anon_vma_prepare(); but it doesn't pin down the case Nick identified
as well as Nick's original mail.

> > explains it, or I could look up the mails if you want, but at this
> > moment the details escape me.
>=20
> Hmm. I didn't follow up that at that time.
>=20
> After you noticed me, I found that.
> commit d9d332e0874f46b91d8ac4604b68ee42b8a7a2c6
> Author: Linus Torvalds <torvalds@linux-foundation.org>
> Date:   Sun Oct 19 10:32:20 2008 -0700
>=20
>     anon_vma_prepare: properly lock even newly allocated entries
>=20
> It's subtle race so I can't digest it fully but I can understand that
> following as.
>=20
> If we don't hold lock at fresh anon_vma, it can be removed and
> reallocated by other threads since other cpu's can find it, free,
> reallocate before first thread which call anon_vma_prepare adds
> anon_vma to list after vma->anon_vma =3D anon_vma
>=20
> I hope my above explanation is right :)

Not really: I don't think there was a risk of it getting freed at
that point, but there was a risk of its list head getting dereferenced
before we'd initialized it.

Here's a link to Nick's 16oct08 linux-mm mail on the subject, then you
can follow the thread from there.  In brief, IIRC, Nick found a race
which he proposed to fix with barriers, but in the end we were all
much happier just taking the anon_vma lock in all cases.

http://marc.info/?l=3Dlinux-mm&m=3D122413030612659&w=3D2

>=20
> > And do we need the page_table_lock even when find_mergeable_anon_vma
> > succeeds? =C2=A0That also looks as if it's unnecessary, but I've the gh=
ost
> > of a memory that it's needed even for that case: I seem to remember
> > that there can be a benign race where find_mergeable_anon_vma called
> > by concurrent threads could actually return different anon_vmas.
> > That also is something I don't want to think too deeply into at
> > this instant, but beg me if you wish!)
>=20
> Unfortunately I can't found this issue mail or changelog.
> Hugh. Could you explain this issue more detail in your convenient time ?

Sure, I remembered it once I went to bed that night, it's an easy one;
wasn't ever discussed on list, just something I'd been aware of.

Remember that anon_vma_prepare() gets called at fault time, when we
have only down_read of mmap_sem, so there may well be concurrent faults.

find_mergeable_anon_vma looks at the vma on either side of our faulting
vma, to see if the neighbouring vma already has an anon_vma, which we'd
be wise to use if that vma could plausibly be merged with our vma later
e.g. mprotect may have temporarily split ours from the next, but another
mprotect may make them mergeable - it would be a pity to be prevented
from merging them just because we'd already attached distinct anon_vmas.

But, as I said, there may well be concurrent faults, on ours and on
neighbouring vmas: so one call to find_mergeable_anon_vma on our vma
may find that the next vma has no anon_vma yet, but the prev has one,
so it returns the prev's anon_vma; but a racing fault on the next
vma immediately gives it an anon_vma, and a racing fault on our vma
finds that, so its find_mergeable_anon_vma returns the next's anon_vma.

So the two faults on our vma could both be in anon_vma_prepare(),
doing the spin_lock(&anon_vma->lock) on find_mergeable_anon_vma's
anon_vma, but those could still be different anon_vmas: but if
both lock the page_table_lock, we can be sure to catch that case.

When I said the race was benign, I meant that it doesn't matter in
such a case which one we choose; but we don't want to choose both!

Hugh
--8323584-1606777726-1244392119=:17597--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

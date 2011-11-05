Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id 3C0C76B006C
	for <linux-mm@kvack.org>; Fri,  4 Nov 2011 22:21:36 -0400 (EDT)
Received: by gyg10 with SMTP id 10so4113126gyg.14
        for <linux-mm@kvack.org>; Fri, 04 Nov 2011 19:21:33 -0700 (PDT)
Date: Fri, 4 Nov 2011 19:21:28 -0700 (PDT)
From: Hugh Dickins <hughd@google.com>
Subject: Re: [PATCH] mremap: enforce rmap src/dst vma ordering in case of
 vma_merge succeeding in copy_vma
In-Reply-To: <CAPQyPG5RgPnN-kVc1Oy+78mAa9vevLiZWCwx2pEkeHKY1t6V1A@mail.gmail.com>
Message-ID: <alpine.LSU.2.00.1111041856530.22199@sister.anvils>
References: <20111031171441.GD3466@redhat.com> <1320082040-1190-1-git-send-email-aarcange@redhat.com> <alpine.LSU.2.00.1111032318290.2058@sister.anvils> <CAPQyPG4DNofTw=rqJXPTbo3w4xGMdPF3SYt3qyQCWXYsDLa08A@mail.gmail.com> <alpine.LSU.2.00.1111041158440.1554@sister.anvils>
 <20111104205440.GP18879@redhat.com> <CAPQyPG5RgPnN-kVc1Oy+78mAa9vevLiZWCwx2pEkeHKY1t6V1A@mail.gmail.com>
MIME-Version: 1.0
Content-Type: MULTIPART/MIXED; BOUNDARY="8323584-1790824662-1320459700=:22199"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Nai Xia <nai.xia@gmail.com>
Cc: Andrea Arcangeli <aarcange@redhat.com>, Mel Gorman <mgorman@suse.de>, Pawel Sikora <pluto@agmk.net>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, jpiszcz@lucidpixels.com, arekm@pld-linux.org, linux-kernel@vger.kernel.org

  This message is in MIME format.  The first part should be readable text,
  while the remaining parts are likely unreadable without MIME-aware tools.

--8323584-1790824662-1320459700=:22199
Content-Type: TEXT/PLAIN; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE

On Sat, 5 Nov 2011, Nai Xia wrote:
> On Sat, Nov 5, 2011 at 4:54 AM, Andrea Arcangeli <aarcange@redhat.com> wr=
ote:
> > On Fri, Nov 04, 2011 at 12:16:03PM -0700, Hugh Dickins wrote:
> >> On Fri, 4 Nov 2011, Nai Xia wrote:
> >> > On Fri, Nov 4, 2011 at 3:31 PM, Hugh Dickins <hughd@google.com> wrot=
e:
> >> > > On Mon, 31 Oct 2011, Andrea Arcangeli wrote:
> >> > >> @@ -2339,7 +2339,15 @@ struct vm_area_struct *copy_vma(struct vm_=
area_struct **vmap,
> >> > >> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0*/
> >> > >> =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (vma_start >=3D new_vma->vm_start =
&&
> >> > >> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 vma_start < new_vma->vm_end)
> >> > >> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 /*
> >> > >> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0* No need to call an=
on_vma_order_tail() in
> >> > >> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0* this case because =
the same PT lock will
> >> > >> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0* serialize the rmap=
_walk against both src
> >> > >> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0* and dst vmas.
> >> > >> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0*/
> >> > >
> >> > > Really? =A0Please convince me: I just do not see what ensures that
> >> > > the same pt lock covers both src and dst areas in this case.
> >> >
> >> > At the first glance that rmap_walk does travel this merged VMA
> >> > once...
> >> > But, Now, Wait...., I am actually really puzzled that this case can =
really
> >> > happen at all, you see that vma_merge() does not break the validness
> >> > between page->index and its VMA. So if this can really happen,
> >> > a page->index should be valid in both areas in a same VMA.
> >> > It's strange to imagine that a PTE is copy inside a _same_ VMA
> >> > and page->index is valid at both old and new places.
> >>
> >> Yes, I think you are right, thank you for elucidating it.
> >>
> >> That was a real case when we wrote copy_vma(), when rmap was using
> >> pte_chains; but once anon_vma came in, and imposed vm_pgoff matching
> >> on anonymous mappings too, it became dead code. =A0With linear vm_pgof=
f
> >> matching, you cannot fit a range in two places within the same vma.
> >> (And even the non-linear case relies upon vm_pgoff defaults.)
> >>
> >> So we could simplify the copy_vma() interface a little now (get rid of
> >> that nasty **vmap): I'm not quite sure whether we ought to do that,
> >> but certainly Andrea's comment there should be updated (if he also
> >> agrees with your analysis).
> >
> > The vmap should only trigger when the prev vma (prev relative to src
> > vma) is extended at the end to make space for the dst range. And by
> > extending it, we filled the hole between the prev vma and "src"
> > vma. So then the prev vma becomes the "src vma" and also the "dst
> > vma". So we can't keep working with the old "vma" pointer after that.
> >
> > I doubt it can be removed without crashing in the above case.
>=20
> Yes, this line itself should not be removed. As I explained,
> pgoff adjustment at the top of the copy_vma() for non-faulted
> vma will lead to this case.

Ah, thank you, that's what I was asking you to point me to, the place
I was missing that recalculates pgoff: at the head of copy_vma() itself.

Yes, if that adjustment remains (no reason why not), then we cannot
remove the *vmap =3D new_vma; but that is the only case that nowadays
can need the *vmap =3D new_vma (agreed?), which does deserve a comment.


> But we do not need to worry
> about the move_page_tables() should after this happens.
> And so no lines need to be added here. But maybe the
> documentation should be changed in your original patch
> to clarify this. Reasoning with PTL locks for this case might
> be somewhat misleading.

Right, there are no ptes there yet, so we're cannot miss any.

>=20
>  Furthermore, the move_page_tables() call following this case
> might better be totally avoided for code readability and it's
> simple to judge with (vma =3D=3D new_vma)
>=20
> Do you agree? :)

Well, it's true that looking at pagetables in this case is just
a waste of time; but personally I'd prefer to add more comment
than special case handling for this.

>=20
> >
> > I thought some more about it and what I missed I think is the
> > anon_vma_merge in vma_adjust. What that anon_vma_merge, rmap_walk will
> > have to complete before we can start moving the ptes. And so rmap_walk
> > when starts again from scratch (after anon_vma_merge run in
> > vma_adjust) will find all ptes even if vma_merge succeeded before.
> >
> > In fact this may also work for fork. Fork will take the anon_vma root
> > lock somehow to queue the child vma in the same_anon_vma. Doing so it
> > will serialize against any running rmap_walk from all other cpus. The
> > ordering has never been an issue for fork anyway, but it would have
> > have been an issue for mremap in case vma_merge succeeded and src_vma
> > !=3D dst_vma, if vma_merge didn't act as a serialization point against
> > rmap_walk (which I realized now).
> >
> > What makes it safe is again taking both PT locks simultanously. So it
> > doesn't matter what rmap_walk searches, as long as the anon_vma_chain
> > list cannot change by the time rmap_walk started.
> >
> > What I thought before was rmap_walk checking vma1 and then vma_merge
> > succeed (where src vma is vma2 and dst vma is vma1, but vma1 is not a
> > new vma queued at the end of same_anon_vma), move_page_tables moves
> > the pte from vma2 to vma1, and then rmap_walk checks vma2. But again
> > vma_merge won't be allowed to complete in the middle of rmap_walk, and
> > so it cannot trigger and we can safely drop the patch. It wasn't
> > immediate to think at the locks taken within vma_adjust sorry.
> >

I found Andrea's "anon_vma_merge" reply very hard to understand; but
it looks like he now accepts that it was mistaken, or on the wrong
track at least...

>=20
> Oh, no, sorry. I think I was trying to clarify in the first reply on
> that thread that
> we all agree that anon_vma chain is 100% stable when doing rmap_walk().
> What is important, I think,  is the relative order of these three events:
> 1.  The time  rmap_walk() scans the src
> 2.  The time rmap_walk() scans the dst
> 3.  The time move_page_tables() move PTE from src vma to dst.

=2E.. after you set us straight again with this.

>=20
> rmap_walk() scans dst( taking dst PTL) ---> move_page_tables() with
> both PTLs ---> rmap_walk() scans src(taking src PTL)
>=20
> will trigger this bug.  The racing is there even if rmap_walk() scans src=
--->dst
> but that racing does not harm. I think Mel explained why it's safe for go=
od
> ordering in his first reply to my post.
>=20
> vma_merge() is only guilty for giving a wrong order of VMAs before
> move_page_tables() and rmap_walk() begin to race, itself does not race
> with rmap_walk().
>=20
> You see, it seems this game might be really puzzling. Indeed, maybe it's =
time
> to fall back on locks instead of playing with racing. Just like the
> good old time,
> our classic OS text book told us that shared variables deserve locks. :-)

That's my preference, yes: this mail thread seems to cry out for that!

Hugh
--8323584-1790824662-1320459700=:22199--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

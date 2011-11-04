Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id E0ABA6B002D
	for <linux-mm@kvack.org>; Fri,  4 Nov 2011 15:16:10 -0400 (EDT)
Received: by ggnh4 with SMTP id h4so3682055ggn.14
        for <linux-mm@kvack.org>; Fri, 04 Nov 2011 12:16:07 -0700 (PDT)
Date: Fri, 4 Nov 2011 12:16:03 -0700 (PDT)
From: Hugh Dickins <hughd@google.com>
Subject: Re: [PATCH] mremap: enforce rmap src/dst vma ordering in case of
 vma_merge succeeding in copy_vma
In-Reply-To: <CAPQyPG4DNofTw=rqJXPTbo3w4xGMdPF3SYt3qyQCWXYsDLa08A@mail.gmail.com>
Message-ID: <alpine.LSU.2.00.1111041158440.1554@sister.anvils>
References: <20111031171441.GD3466@redhat.com> <1320082040-1190-1-git-send-email-aarcange@redhat.com> <alpine.LSU.2.00.1111032318290.2058@sister.anvils> <CAPQyPG4DNofTw=rqJXPTbo3w4xGMdPF3SYt3qyQCWXYsDLa08A@mail.gmail.com>
MIME-Version: 1.0
Content-Type: MULTIPART/MIXED; BOUNDARY="8323584-916335275-1320434175=:1554"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Nai Xia <nai.xia@gmail.com>
Cc: Andrea Arcangeli <aarcange@redhat.com>, Mel Gorman <mgorman@suse.de>, Pawel Sikora <pluto@agmk.net>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, jpiszcz@lucidpixels.com, arekm@pld-linux.org, linux-kernel@vger.kernel.org

  This message is in MIME format.  The first part should be readable text,
  while the remaining parts are likely unreadable without MIME-aware tools.

--8323584-916335275-1320434175=:1554
Content-Type: TEXT/PLAIN; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE

On Fri, 4 Nov 2011, Nai Xia wrote:
> On Fri, Nov 4, 2011 at 3:31 PM, Hugh Dickins <hughd@google.com> wrote:
> > On Mon, 31 Oct 2011, Andrea Arcangeli wrote:
> >> @@ -2339,7 +2339,15 @@ struct vm_area_struct *copy_vma(struct vm_area_=
struct **vmap,
> >> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0*/
> >> =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (vma_start >=3D new_vma->vm_start &&
> >> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 vma_start < new_vma->vm_end)
> >> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 /*
> >> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0* No need to call anon_vm=
a_order_tail() in
> >> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0* this case because the s=
ame PT lock will
> >> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0* serialize the rmap_walk=
 against both src
> >> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0* and dst vmas.
> >> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0*/
> >
> > Really? =A0Please convince me: I just do not see what ensures that
> > the same pt lock covers both src and dst areas in this case.
>=20
> At the first glance that rmap_walk does travel this merged VMA
> once...
> But, Now, Wait...., I am actually really puzzled that this case can reall=
y
> happen at all, you see that vma_merge() does not break the validness
> between page->index and its VMA. So if this can really happen,
> a page->index should be valid in both areas in a same VMA.
> It's strange to imagine that a PTE is copy inside a _same_ VMA
> and page->index is valid at both old and new places.

Yes, I think you are right, thank you for elucidating it.

That was a real case when we wrote copy_vma(), when rmap was using
pte_chains; but once anon_vma came in, and imposed vm_pgoff matching
on anonymous mappings too, it became dead code.  With linear vm_pgoff
matching, you cannot fit a range in two places within the same vma.
(And even the non-linear case relies upon vm_pgoff defaults.)

So we could simplify the copy_vma() interface a little now (get rid of
that nasty **vmap): I'm not quite sure whether we ought to do that,
but certainly Andrea's comment there should be updated (if he also
agrees with your analysis).

>=20
> IMO, the only case that src VMA can be merged by the new
> is that src VMA hasn't been faulted yet and the pgoff
> is recalculated. And if my reasoning is true, this place
> does not need to be worried about.

I don't see a place where "the pgoff is recalculated" (except in
the consistent way when expanding or splitting or merging vma), nor
where vma merge would allow for variable pgoff.  I agree that we
could avoid finalizing vm_pgoff for an anonymous area until its
anon_vma is assigned: were you imagining doing that in future,
or am I overlooking something already there?

Hugh
--8323584-916335275-1320434175=:1554--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

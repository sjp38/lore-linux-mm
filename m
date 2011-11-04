Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id 69EDF6B002D
	for <linux-mm@kvack.org>; Fri,  4 Nov 2011 16:54:51 -0400 (EDT)
Date: Fri, 4 Nov 2011 21:54:40 +0100
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: Re: [PATCH] mremap: enforce rmap src/dst vma ordering in case of
 vma_merge succeeding in copy_vma
Message-ID: <20111104205440.GP18879@redhat.com>
References: <20111031171441.GD3466@redhat.com>
 <1320082040-1190-1-git-send-email-aarcange@redhat.com>
 <alpine.LSU.2.00.1111032318290.2058@sister.anvils>
 <CAPQyPG4DNofTw=rqJXPTbo3w4xGMdPF3SYt3qyQCWXYsDLa08A@mail.gmail.com>
 <alpine.LSU.2.00.1111041158440.1554@sister.anvils>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <alpine.LSU.2.00.1111041158440.1554@sister.anvils>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hugh Dickins <hughd@google.com>
Cc: Nai Xia <nai.xia@gmail.com>, Mel Gorman <mgorman@suse.de>, Pawel Sikora <pluto@agmk.net>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, jpiszcz@lucidpixels.com, arekm@pld-linux.org, linux-kernel@vger.kernel.org

On Fri, Nov 04, 2011 at 12:16:03PM -0700, Hugh Dickins wrote:
> On Fri, 4 Nov 2011, Nai Xia wrote:
> > On Fri, Nov 4, 2011 at 3:31 PM, Hugh Dickins <hughd@google.com> wrote:
> > > On Mon, 31 Oct 2011, Andrea Arcangeli wrote:
> > >> @@ -2339,7 +2339,15 @@ struct vm_area_struct *copy_vma(struct vm_area_struct **vmap,
> > >>                */
> > >>               if (vma_start >= new_vma->vm_start &&
> > >>                   vma_start < new_vma->vm_end)
> > >> +                     /*
> > >> +                      * No need to call anon_vma_order_tail() in
> > >> +                      * this case because the same PT lock will
> > >> +                      * serialize the rmap_walk against both src
> > >> +                      * and dst vmas.
> > >> +                      */
> > >
> > > Really?  Please convince me: I just do not see what ensures that
> > > the same pt lock covers both src and dst areas in this case.
> > 
> > At the first glance that rmap_walk does travel this merged VMA
> > once...
> > But, Now, Wait...., I am actually really puzzled that this case can really
> > happen at all, you see that vma_merge() does not break the validness
> > between page->index and its VMA. So if this can really happen,
> > a page->index should be valid in both areas in a same VMA.
> > It's strange to imagine that a PTE is copy inside a _same_ VMA
> > and page->index is valid at both old and new places.
> 
> Yes, I think you are right, thank you for elucidating it.
> 
> That was a real case when we wrote copy_vma(), when rmap was using
> pte_chains; but once anon_vma came in, and imposed vm_pgoff matching
> on anonymous mappings too, it became dead code.  With linear vm_pgoff
> matching, you cannot fit a range in two places within the same vma.
> (And even the non-linear case relies upon vm_pgoff defaults.)
> 
> So we could simplify the copy_vma() interface a little now (get rid of
> that nasty **vmap): I'm not quite sure whether we ought to do that,
> but certainly Andrea's comment there should be updated (if he also
> agrees with your analysis).

The vmap should only trigger when the prev vma (prev relative to src
vma) is extended at the end to make space for the dst range. And by
extending it, we filled the hole between the prev vma and "src"
vma. So then the prev vma becomes the "src vma" and also the "dst
vma". So we can't keep working with the old "vma" pointer after that.

I doubt it can be removed without crashing in the above case.

I thought some more about it and what I missed I think is the
anon_vma_merge in vma_adjust. What that anon_vma_merge, rmap_walk will
have to complete before we can start moving the ptes. And so rmap_walk
when starts again from scratch (after anon_vma_merge run in
vma_adjust) will find all ptes even if vma_merge succeeded before.

In fact this may also work for fork. Fork will take the anon_vma root
lock somehow to queue the child vma in the same_anon_vma. Doing so it
will serialize against any running rmap_walk from all other cpus. The
ordering has never been an issue for fork anyway, but it would have
have been an issue for mremap in case vma_merge succeeded and src_vma
!= dst_vma, if vma_merge didn't act as a serialization point against
rmap_walk (which I realized now).

What makes it safe is again taking both PT locks simultanously. So it
doesn't matter what rmap_walk searches, as long as the anon_vma_chain
list cannot change by the time rmap_walk started.

What I thought before was rmap_walk checking vma1 and then vma_merge
succeed (where src vma is vma2 and dst vma is vma1, but vma1 is not a
new vma queued at the end of same_anon_vma), move_page_tables moves
the pte from vma2 to vma1, and then rmap_walk checks vma2. But again
vma_merge won't be allowed to complete in the middle of rmap_walk, and
so it cannot trigger and we can safely drop the patch. It wasn't
immediate to think at the locks taken within vma_adjust sorry.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

Date: Mon, 14 Jul 2008 21:37:48 +0100 (BST)
From: Hugh Dickins <hugh@veritas.com>
Subject: Re: [PATCH] - GRU virtual -> physical translation
In-Reply-To: <20080714195018.GD8534@sgi.com>
Message-ID: <Pine.LNX.4.64.0807142057060.22604@blonde.site>
References: <20080709191439.GA7307@sgi.com> <20080711121736.18687570.akpm@linux-foundation.org>
 <20080714145255.GA23173@sgi.com> <20080714092451.2c81a472.akpm@linux-foundation.org>
 <20080714163107.GA936@sgi.com> <20080714195018.GD8534@sgi.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Robin Holt <holt@sgi.com>
Cc: Jack Steiner <steiner@sgi.com>, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Christoph Hellwig <hch@lst.de>, Nick Piggin <nickpiggin@yahoo.com.au>
List-ID: <linux-mm.kvack.org>

On Mon, 14 Jul 2008, Robin Holt wrote:
> On Mon, Jul 14, 2008 at 11:31:07AM -0500, Jack Steiner wrote:
> > On Mon, Jul 14, 2008 at 09:24:51AM -0700, Andrew Morton wrote:
> > > On Mon, 14 Jul 2008 09:52:55 -0500 Jack Steiner <steiner@sgi.com> wrote:
> > > > On Fri, Jul 11, 2008 at 12:17:36PM -0700, Andrew Morton wrote:
> > > > > On Wed, 9 Jul 2008 14:14:39 -0500 Jack Steiner <steiner@sgi.com> wrote:
> > > > > 
> > > > > > Open code the equivalent to follow_page(). This eliminates the
> > > > > > requirement for an EXPORT of follow_page().
> > > > > 
> > > > > I'd prefer to export follow_page() - copying-n-pasting just to avoid
> > > > > exporting the darn thing is silly.
> > > > 
> > > > If follow_page() can be EXPORTed, I think that may make the most sense for
> > > > now.
> > > 
> > > What was Christoph's reason for objecting to the export?
> > 
> > No clue. Just a NACK.
> > 
> > Christoph???
> 
> Maybe I missed part of the discussion, but I thought follow_page() would
> not work because you need this to function in the interrupt context and
> locks would then need to be made irqsave/irqrestore.

Exactly, that seems to have gone missing from the patch explanation.

> This, of course does not in any way answer the question about why
> follow_page() can not be exported.

I can't answer that either, and like Andrew I would have preferred
to export follow_page, but for this locking issue: on the face of it,
you cannot safely pte_offset_map_lock from interrupt context.

But I do now wonder whether it was just my kneejerk reaction on seeing
Jack's comment that it was needed in interrupt context.  After glancing
through the GRU patches, I'm left wondering whether gru_intr is an
asynchronous interrupt - in which case follow_page cannot be used,
and it's not obvious to me that the version in this patch is safe -
or whether it's more akin to a trap, coming in the context of the
current mm, in which case using follow_page may be okay.

I say it's not obvious to me that the version in this patch is safe,
because I was wondering about the local_irq_disable there.  That's
copied from Nick's fast GUP patches, but its function here is less
obvious.  gru_intr already did down_read_trylock(&gts->ts->mmap_sem),
which seems to give more guarantees than Nick relies upon; but is
gts->ts_mm necessarily the same as current->mm or not?

If not, then you don't have quite the TLB flushing guarantees that
Nick relies upon: you won't be sent an IPI to flush TLB if swapping
or truncation suddenly frees the page, which that local_irq_disable
is designed to keep at bay (if I understand fast GUP correctly)
while we get a reference to the page to rescue it from freeing.

In Jack's patch I see no get_page within the irq_disabled area,
so it's not clear to me what the local_irq_disable achieves.
But perhaps the MMU notification mechanism, or the GRU's
"magic hardware", keeps it all safe.

(Personally, I dislike the other patch, adding zap_vma_ptes:
to me it's just minor bloat and obscurity on top of the familiar
zap_page_range; but I may be in a minority of one on that.)

Hugh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

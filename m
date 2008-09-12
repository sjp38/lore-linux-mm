Date: Fri, 12 Sep 2008 16:52:22 +0100 (BST)
From: Hugh Dickins <hugh@veritas.com>
Subject: Re: [RFC PATCH] discarding swap
In-Reply-To: <1221228567.3919.35.camel@macbook.infradead.org>
Message-ID: <Pine.LNX.4.64.0809121631050.5142@blonde.site>
References: <Pine.LNX.4.64.0809092222110.25727@blonde.site>
 <20080910173518.GD20055@kernel.dk>  <Pine.LNX.4.64.0809102015230.16131@blonde.site>
  <1221082117.13621.25.camel@macbook.infradead.org>
 <Pine.LNX.4.64.0809121154430.12812@blonde.site> <1221228567.3919.35.camel@macbook.infradead.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: David Woodhouse <dwmw2@infradead.org>
Cc: Jens Axboe <jens.axboe@oracle.com>, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, 12 Sep 2008, David Woodhouse wrote:
> On Fri, 2008-09-12 at 13:10 +0100, Hugh Dickins wrote:
> > So long as the I/O schedulers guarantee that a WRITE bio submitted
> > to an area already covered by a DISCARD_NOBARRIER bio cannot pass that
> > DISCARD_NOBARRIER - ...
> 
> > That seems a reasonable guarantee to me, and perhaps it's trivially
> > obvious to those who know their I/O schedulers; but I don't, so I'd
> > like to hear such assurance given.
> 
> No, that's the point. the I/O schedulers _don't_ give you that guarantee
> at all. They can treat DISCARD_NOBARRIER just like a write. That's all
> it is, really -- a special kind of WRITE request without any data.

Hmmm.  In that case I'll need to continue with DISCARD_BARRIER,
unless/until I rejig swap allocation to wait for discard completion,
which I've no great desire to do.

Is there any particular reason why DISCARD_NOBARRIER shouldn't be
enhanced to give the intuitive guarantee I suggest?  It is distinct
from a WRITE, I don't see why it has to be treated in the same way
if that's unhelpful to its users.

I expect the answer will be: it could be so enhanced, but we really
don't know if it's worth adding special code for that without the
experience of more users.

> 
> But -- and this came as a bit of a shock to me -- they don't guarantee
> that writes don't cross writes on their queue. If you issue two WRITE
> requests to the same sector, you have to make sure for _yourself_ that
> there is some kind of barrier between them to keep them in the right
> order.

Right, I recall from skimming the linux-fsdevel threads that it
emerged that currently WRITEs are depending on page lock for
that serialization, which cannot apply in the discard case.

So, there's been no need for such a guarantee in the WRITE case;
but it sure would be helpful in the DISCARD case, which has no
pages to lock anyway.

> 
> Does swap do that, when a page on the disk is deallocated and then used
> for something else?

Yes, that's managed through the PageWriteback flag: there are various
places where we'd like to free up swap, but cannot do so because it's
still attached to a cached page with PageWriteback set; in which case
its freeing has to be left until vmscan.c finds PageWriteback cleared,
then removes page from swapcache and frees the swap.

Hugh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

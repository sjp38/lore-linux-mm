Date: Fri, 18 Jan 2008 20:56:32 +0000 (GMT)
From: Hugh Dickins <hugh@veritas.com>
Subject: Re: [patch] #ifdef very expensive debug check in page fault path
In-Reply-To: <20080116161021.c9a52c0f.akpm@linux-foundation.org>
Message-ID: <Pine.LNX.4.64.0801182023350.5249@blonde.site>
References: <1200506488.32116.11.camel@cotte.boeblingen.de.ibm.com>
 <20080116234540.GB29823@wotan.suse.de> <20080116161021.c9a52c0f.akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Nick Piggin <npiggin@suse.de>, Carsten Otte <cotte@de.ibm.com>, Linux Memory Management List <linux-mm@kvack.org>, schwidefsky@de.ibm.com, holger.wolf@de.ibm.com, Linus Torvalds <torvalds@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

On Wed, 16 Jan 2008, Andrew Morton wrote:
> On Thu, 17 Jan 2008 00:45:40 +0100 Nick Piggin <npiggin@suse.de> wrote:
> > 
> > The one actual upside of this code is that if there is pte corruption
> > detected, the failure should be a little more graceful... but there
> > is also lots of pte corruption that could go undetected and cause much
> > worse problems anyway so I don't feel it is something that needs to
> > be turned on in production kernels. It could be a good debugging aid
> > to mm/ or device driver writers though.
> > 
> > Anyway, again I've cc'ed Hugh, because he nacked this same patch a
> > while back. So let's try to get him on board before merging anything.

Thanks, Nick.

> > 
> > If we get an ack, why not send this upstream for 2.6.24? Those s390
> > numbers are pretty insane.
> 
> I intend to merge this into 2.6.24.

And so you have already, commit 9723198c219f3546982cb469e5aed26e68399055

I'm very surprised that's considered suitable material for post-rc8.

We know very well that page tables are almost honeytraps for random
corruption, and we've long adhered to the practice of preceding any
pfn_to_page by a pfn_valid check, to make sure we don't veer off the
end of the mem_map (or whatever), causing our page manipulations to
corrupt unrelated memory with less foreseeable consequences.  That
good practice dates from long before some of the checking got
separated out into vm_normal_page.

That said, perhaps I'm over-reacting: I can remember countless rmap.c
BUGs or Eeeks, and countless Bad page states, and quite a number of
swap_free errors, all usually symptoms of similar corruption; yet
not a single instance of that Bad pte message which Nick was good
enough to add a couple of years back.

Hmm, it's my own memory that's bad: a grep through old mailboxes
does show them; though I've not stopped to look, to see whether
perhaps they can all be argued away on some good grounds.

Well: that patch still gets my Nack, but I guess I'm too late.  If
s390 pagetables are better protected than x86 ones, add an s390 ifdef?

Hugh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

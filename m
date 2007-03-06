Date: Mon, 5 Mar 2007 17:27:37 -0800 (PST)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [rfc][patch 2/2] mm: mlocked pages off LRU
In-Reply-To: <20070306010529.GB23845@wotan.suse.de>
Message-ID: <Pine.LNX.4.64.0703051723240.16842@schroedinger.engr.sgi.com>
References: <20070305161746.GD8128@wotan.suse.de>
 <Pine.LNX.4.64.0703050948040.6620@schroedinger.engr.sgi.com>
 <20070306010529.GB23845@wotan.suse.de>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nick Piggin <npiggin@suse.de>
Cc: Christoph Lameter <clameter@engr.sgi.com>, Linux Memory Management List <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, Christoph Hellwig <hch@infradead.org>
List-ID: <linux-mm.kvack.org>

On Tue, 6 Mar 2007, Nick Piggin wrote:

> > Which breaks page migration for mlocked pages.
> 
> Yeah, the simple way to fix migration is to just clear_page_mlock those
> pages so they'll lazily be mlocked again. However we could probably do
> something fancier like transferring the PG_mlock bit and the mlock_count.

That will also drop the page count.

> > I think there is still some thinking going on about also removing 
> > anonymous pages off the LRU if we are out of swap or have no swap. In 
> > that case we may need page->lru to track these pages so that they can be 
> > fed back to the LRU when swap is added later.
> 
> That's OK: they won't get mlocked if they are not on the LRU (and won't
> get taken off the LRU if they are mlocked).

But we may want to keep them off the LRU.

> > I was a bit hesitant to use an additional ref counter because we are here 
> > overloading a refcounter on a LRU field? I have a bad feeling here. There 
> 
> If we ensure !PageLRU then we can use the lru field. I don't see
> a problem.

Wrong. !PageLRU means that the page may be on some other list. Like the 
vmscan pagelist and the page migration list. You can only be sure that it
is not on those lists if a function took the page off the LRU. If you then 
mark it PageMlocked then you may be sure that the LRU field is free for 
use.

> > Ok you basically keep the first patch of my set. Maybe include that 
> > explicitly ?
> 
> It is a bit different. I don't want to break out as soon as it hits
> an mlocked vma, in order to be able to count up all mlocked vmas and
> set the correct mlock_count.

?? The first patch just adds a new exist code to try_to_unmap.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

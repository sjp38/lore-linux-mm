Date: Tue, 6 Mar 2007 02:44:03 +0100
From: Nick Piggin <npiggin@suse.de>
Subject: Re: [rfc][patch 2/2] mm: mlocked pages off LRU
Message-ID: <20070306014403.GD23845@wotan.suse.de>
References: <20070305161746.GD8128@wotan.suse.de> <Pine.LNX.4.64.0703050948040.6620@schroedinger.engr.sgi.com> <20070306010529.GB23845@wotan.suse.de> <Pine.LNX.4.64.0703051723240.16842@schroedinger.engr.sgi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.64.0703051723240.16842@schroedinger.engr.sgi.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: Christoph Lameter <clameter@engr.sgi.com>, Linux Memory Management List <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, Christoph Hellwig <hch@infradead.org>
List-ID: <linux-mm.kvack.org>

On Mon, Mar 05, 2007 at 05:27:37PM -0800, Christoph Lameter wrote:
> On Tue, 6 Mar 2007, Nick Piggin wrote:
> 
> > > Which breaks page migration for mlocked pages.
> > 
> > Yeah, the simple way to fix migration is to just clear_page_mlock those
> > pages so they'll lazily be mlocked again. However we could probably do
> > something fancier like transferring the PG_mlock bit and the mlock_count.
> 
> That will also drop the page count.

?? You _want_ to drop the page count so that migration will work.

> > > I think there is still some thinking going on about also removing 
> > > anonymous pages off the LRU if we are out of swap or have no swap. In 
> > > that case we may need page->lru to track these pages so that they can be 
> > > fed back to the LRU when swap is added later.
> > 
> > That's OK: they won't get mlocked if they are not on the LRU (and won't
> > get taken off the LRU if they are mlocked).
> 
> But we may want to keep them off the LRU.

They will be. Either by mlock or by the !swap condition.

> > > I was a bit hesitant to use an additional ref counter because we are here 
> > > overloading a refcounter on a LRU field? I have a bad feeling here. There 
> > 
> > If we ensure !PageLRU then we can use the lru field. I don't see
> > a problem.
> 
> Wrong. !PageLRU means that the page may be on some other list. Like the 
> vmscan pagelist and the page migration list. You can only be sure that it
> is not on those lists if a function took the page off the LRU. If you then 
> mark it PageMlocked then you may be sure that the LRU field is free for 
> use.

Bad wording: by "if we ensure !PageLRU" I meant "if we take the page off
the LRU ourselves". Why do you have a bad feeling about this? As you
say, vmscan and page migration do exactly the same thing and it is a
fundamental way that the lru mechanism works.

> > > Ok you basically keep the first patch of my set. Maybe include that 
> > > explicitly ?
> > 
> > It is a bit different. I don't want to break out as soon as it hits
> > an mlocked vma, in order to be able to count up all mlocked vmas and
> > set the correct mlock_count.
> 
> ?? The first patch just adds a new exist code to try_to_unmap.

Well I will probably break my patch out into several bits if/when it
is ready to merge. Not such a big deal at present though.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

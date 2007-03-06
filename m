Date: Tue, 6 Mar 2007 03:13:07 +0100
From: Nick Piggin <npiggin@suse.de>
Subject: Re: [rfc][patch 2/2] mm: mlocked pages off LRU
Message-ID: <20070306021307.GE23845@wotan.suse.de>
References: <20070305161746.GD8128@wotan.suse.de> <Pine.LNX.4.64.0703050948040.6620@schroedinger.engr.sgi.com> <20070306010529.GB23845@wotan.suse.de> <Pine.LNX.4.64.0703051723240.16842@schroedinger.engr.sgi.com> <20070306014403.GD23845@wotan.suse.de> <Pine.LNX.4.64.0703051753070.16964@schroedinger.engr.sgi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.64.0703051753070.16964@schroedinger.engr.sgi.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: Christoph Lameter <clameter@engr.sgi.com>, Linux Memory Management List <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, Christoph Hellwig <hch@infradead.org>
List-ID: <linux-mm.kvack.org>

On Mon, Mar 05, 2007 at 05:55:57PM -0800, Christoph Lameter wrote:
> On Tue, 6 Mar 2007, Nick Piggin wrote:
> 
> > > > > I think there is still some thinking going on about also removing 
> > > > > anonymous pages off the LRU if we are out of swap or have no swap. In 
> > > > > that case we may need page->lru to track these pages so that they can be 
> > > > > fed back to the LRU when swap is added later.
> > > > 
> > > > That's OK: they won't get mlocked if they are not on the LRU (and won't
> > > > get taken off the LRU if they are mlocked).
> > > 
> > > But we may want to keep them off the LRU.
> > 
> > They will be. Either by mlock or by the !swap condition.
> 
> The above is a bit contradictory. Assuming they are taken off the LRU:
> How will they be returned to the LRU?

In what way is it contradictory? If they are mlocked, we put them on the
LRU when they get munlocked. If they are off the LRU due to a !swap condition,
then we put them back on the LRU by whatever mechanism that uses (eg. a
3rd LRU list that we go through much more slowly...).

If they get munlocked and put back on the LRU when there is no swap, then
presumably the !swap condition handling will lazily take care of them.


> > > Wrong. !PageLRU means that the page may be on some other list. Like the 
> > > vmscan pagelist and the page migration list. You can only be sure that it
> > > is not on those lists if a function took the page off the LRU. If you then 
> > > mark it PageMlocked then you may be sure that the LRU field is free for 
> > > use.
> > 
> > Bad wording: by "if we ensure !PageLRU" I meant "if we take the page off
> > the LRU ourselves". Why do you have a bad feeling about this? As you
> > say, vmscan and page migration do exactly the same thing and it is a
> > fundamental way that the lru mechanism works.
> 
> Refcounts are generally there to be updated in a racy way and it seems 
> here that the refcount variable itself can only exist under certain 
> conditions. If you can handle that cleanly then we are okay.

Well it's there in the code. I don't know if you consider my way of
handling it clean or not... It isn't a racy refcount, just a conservative
count of mlocked vmas, which is protected by PG_locked. PG_mlock is also
protected by PG_locked, so it is easy to get the mlock_count when the page
is locked.

I did put a little bit of thought into this ;)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

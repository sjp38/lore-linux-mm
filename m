Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx179.postini.com [74.125.245.179])
	by kanga.kvack.org (Postfix) with SMTP id 067686B0027
	for <linux-mm@kvack.org>; Wed, 27 Mar 2013 15:24:42 -0400 (EDT)
Received: by mail-da0-f44.google.com with SMTP id z20so4243220dae.3
        for <linux-mm@kvack.org>; Wed, 27 Mar 2013 12:24:42 -0700 (PDT)
Date: Wed, 27 Mar 2013 12:24:16 -0700 (PDT)
From: Hugh Dickins <hughd@google.com>
Subject: Re: page eviction from the buddy cache
In-Reply-To: <20130327150743.GC14900@thunk.org>
Message-ID: <alpine.LNX.2.00.1303271135420.29687@eggly.anvils>
References: <51504A40.6020604@ya.ru> <20130327150743.GC14900@thunk.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Theodore Ts'o <tytso@mit.edu>
Cc: Andrew Perepechko <anserper@ya.ru>, linux-ext4@vger.kernel.org, alexey.lyashkov@gmail.com, akpm@linux-foundation.org, linux-mm@kvack.org

[Cc'ing linux-mm: "buddy cache" here is cache of some ext4 metadata]

On Wed, 27 Mar 2013, Theodore Ts'o wrote:
> Hi Andrew,
> 
> Thanks for your analysis!  Since I'm not a mm developer, I'm not sure
> what's the best way to more aggressively mark a page as one that we'd
> really like to keep in the page cache --- whether it's calling
> lru_add_drain(), or calling activate_page(page), etc.
> 
> So I've added Andrew Morton and Hugh Dickens to the cc list as mm
> experts in the hopes they could give us some advice about the best way
> to achieve this goal.  Andrew, Hugh, could you give us some quick
> words of wisdom?

Hardly from me: I'm dissatisfied with answer below, Cc'ed linux-mm.

> 
> Thanks,
> 
> 					- Ted
> On Mon, Mar 25, 2013 at 04:59:44PM +0400, Andrew Perepechko wrote:
> > Hello!
> > 
> > Our recent investigation has found that pages from
> > the buddy cache are evicted too often as compared
> > to the expectation from their usage pattern. This
> > introduces additional reads during large writes under
> > our workload and really hurts overall performance.
> > 
> > ext4 uses find_get_page() and find_or_create_page()
> > to look for buddy cache pages, but these pages don't
> > get a chance to become activated until the following
> > lru_add_drain() call, because mark_page_accessed()
> > does not activate pages which are not PageLRU().
> > 
> > As can be found from a kprobe-based test, these pages
> > are often moved on the inactive LRU as a result of
> > shrink_inactive_list()->lru_add_drain() and immediately
> > evicted.

Not quite like that, I think.

Cache pages are intentionally put on the inactive list initially,
so that streaming I/O does not push out more useful pages: it is
intentional that the first call to mark_page_accessed() merely
marks the page referenced, but does not move it to active LRU.

You're right that the pagevec confuses things here, but I'm
surprised if these pages are "immediately evicted": they won't
be evicted while they remain on a pagevec, and can only be evicted
after reaching the LRU.  And they should be put on the hot end of
the inactive LRU, and only evicted once they reach the cold end.

But maybe you have lots of dirty or otherwise-un-immediately-evictable
data pages in between, so that page reclaim reaches these ones too soon.

IIUC the pages you are discussing here are important metadata pages,
which you would much prefer to retain longer than streaming data.

While I question "immediately evicted", I don't doubt that they
get evicted sooner than you wish: one way or another, they arrive
at the cold end of the inactive LRU too soon.

You would like a way to mark these as more important to retain than
data pages: you would like to put them directly on the active list,
but are frustrated by the pagevec.

> > 
> > From a quick look into linux-2.6.git, the issue seems
> > to exist in the current code as well.
> > 
> > A possible and, perhaps, non-optimal solution would be
> > to call lru_add_drain() each time a buddy cache page
> > is used.

mark_page_accessed() should be enough each time one is actually used,
but yes, it looks like you need more than that when first added to cache.

It appears that at the moment you need to do:

	mark_page_accessed(page);	/* to SetPageReferenced */
	lru_add_drain();		/* to SetPageLRU */
	mark_page_accessed(page);	/* to SetPageActive */

but I agree that we would really prefer a filesystem not to have to
call lru_add_drain().

I quite like the idea of
	mark_page_accessed(page);
	mark_page_accessed(page);
as a sequence to use on important metadata (nicely reminiscent of
"sync; sync;"), but maybe not everybody will agree with me on that!

As currently implemented, a page is put on to a pagevec specific to
the LRU it is destined for, and we cannot change that destination
before it is flushed to that LRU.  But at this moment I cannot see
a fundamental reason why we should not allow PageActive to be set
while in the pagevec, and destination LRU adjusted accordingly.

However, I could easily be missing something (probably some VM_BUG_ONs
at the least); and changing this might uncover unwanted side-effects -
perhaps some code paths which already call mark_page_accessed() twice
in quick succession unintentionally, and would now be given an Active
page when Inactive has actually been more appropriate.

Though I'd like to come back to this, I am very unlikely to find time
for it in the near future: perhaps someone else might take it further.

Hugh

> > 
> > Any other suggestions?
> > 
> > Thank you,
> > Andrew

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

Date: Mon, 29 Jan 2007 20:10:34 +0000 (GMT)
From: Hugh Dickins <hugh@veritas.com>
Subject: Re: [patch] mm: mremap correct rmap accounting
In-Reply-To: <Pine.LNX.4.64.0701291123460.3611@woody.linux-foundation.org>
Message-ID: <Pine.LNX.4.64.0701292002310.16279@blonde.wat.veritas.com>
References: <45B61967.5000302@yahoo.com.au> <Pine.LNX.4.64.0701232041330.2461@blonde.wat.veritas.com>
 <45BD6A7B.7070501@yahoo.com.au> <Pine.LNX.4.64.0701291901550.8996@blonde.wat.veritas.com>
 <Pine.LNX.4.64.0701291123460.3611@woody.linux-foundation.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Nick Piggin <nickpiggin@yahoo.com.au>, Linux Memory Management <linux-mm@kvack.org>, Andrew Morton <akpm@osdl.org>, Ralf Baechle <ralf@linux-mips.org>
List-ID: <linux-mm.kvack.org>

On Mon, 29 Jan 2007, Linus Torvalds wrote:
> On Mon, 29 Jan 2007, Hugh Dickins wrote:
> > On Mon, 29 Jan 2007, Nick Piggin wrote:
> > > 
> > > OK, how's this one?
> > 
> > Grudging okay - so irritating to have to do this!
> 
> I really hate it. Like REALLY REALLY hate it.
> 
> This just seems really stupid.
> 
> How about making the zero-page on MIPS be PageCompound(), and then have 
> all the sub-pages just point to the first page - that's how compound pages 
> work anyway.
> 
> Then the mapcount/refcount is all done on the compound page, and none of 
> these problems occur.

Beautiful idea, an entirely appropriate use of PageCompound().

But it won't quite work as is, since only page_count() is diverted
via PageCompound(): page_mapcount() works on exactly the page given.
So the MIPS ZERO_PAGEs could still hit the page_remove_rmap() BUG.

Agreed that's a surprising divergence: but it's worked fine to date,
and I'm hesitant to change it in a hurry, need to pause to consider
the ramifications.

Hugh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

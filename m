From: Nikita Danilov <Nikita@Namesys.COM>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Message-ID: <16399.42863.159456.646624@laputa.namesys.com>
Date: Thu, 22 Jan 2004 13:35:27 +0300
Subject: Re: [BENCHMARKS] Namesys VM patches improve kbuild
In-Reply-To: <20040121223608.1ea30097.akpm@osdl.org>
References: <400F630F.80205@cyberone.com.au>
	<20040121223608.1ea30097.akpm@osdl.org>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@osdl.org>
Cc: Nick Piggin <piggin@cyberone.com.au>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Andrew Morton writes:
 > Nick Piggin <piggin@cyberone.com.au> wrote:
 > >
 > > Hi,
 > > 
 > > The two namesys patches help kbuild quite a lot here.
 > > http://www.kerneltrap.org/~npiggin/vm/1/
 > > 
 > > The patches can be found at
 > > http://thebsh.namesys.com/snapshots/LATEST/extra/
 > 
 > I played with these back in July.  Had a few stability problems then but
 > yes, they did speed up some workloads a lot.

Yes, there were glaring bugs at that time, and they were fixed. I am
using these patches all the time while stressing/testing reiser4.

 > 
 > 
 > > I don't have much to comment on the patches. They do include
 > > some cleanup stuff which should be broken out.
 > 

I think that shrink_list() is way too big, and too complex. All
pre-writepage checks and ->writepage() call handling itself fits nicely
to being separated into special function.

 > Yup.  <dig, dig>  See below - it's six months old though.
 > 
 > > I don't really understand the dont-rotate-active-list patch:
 > > I don't see why we're losing LRU information because the pages
 > > that go to the head of the active list get their referenced
 > > bits cleared.
 > 
 > Yes, I do think that the "LRU" is a bit of a misnomer - it's very
 > approximate and only really suits simple workloads.  I suspect that once
 > things get hot and heavy the "lru" is only four-deep:
 > unreferenced/inactive, referenced/inactive, unreferenced/active and
 > referenced/active.

Note that during referenced/inactive->unreferenced/active transition
page is moved to the _head_ of the active list.

refill_inactive_zone(), on the other hand, takes cold (not-referenced)
mapped pages from the tail of active list and throws them to the head
too. As a result:

1. time that it takes for a page to migrate from the head to the tail of
the active list varies, because irrelevant cold pages are added to the
head of it. Hence, page_referenced() check at the tail of active list
becomes worse estimation of the page hotness.

2. CPU usage increases, because until reclaim_mapped level of pressure
is reached, unreferenced mapped pages are scanned over and over again.

As an aside: our "lru" is four deep for mapped pages only:
refill_inactive_zone() doesn't take referenced bit on the file system
cache into account, so, actually, until recently when page_referenced()
check was added before calling ->writepage(), file system cache was
using plain FIFO.

Unfortunately simply adding check for TestClearPageReferenced(page) for
not-mapped pages in the refill_inactive_zone() doesn't help, because it
results in active list refusing to shrink at all under file system load.

Nikita.
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>

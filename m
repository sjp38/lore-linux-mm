Content-Type: text/plain;
  charset="iso-8859-1"
From: Daniel Phillips <phillips@arcor.de>
Subject: Re: [PATCH] modified segq for 2.5
Date: Tue, 10 Sep 2002 02:17:20 +0200
References: <Pine.LNX.4.44L.0209091938500.1857-100000@imladris.surriel.com>
In-Reply-To: <Pine.LNX.4.44L.0209091938500.1857-100000@imladris.surriel.com>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
Message-Id: <E17oYiW-0006w5-00@starship>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Rik van Riel <riel@conectiva.com.br>, Andrew Morton <akpm@digeo.com>
Cc: William Lee Irwin III <wli@holomorphy.com>, sfkaplan@cs.amherst.edu, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Tuesday 10 September 2002 00:41, Rik van Riel wrote:
> On Mon, 9 Sep 2002, Andrew Morton wrote:
> > Do we remove the SetPageReferenced() in generic_file_write?
> 
> Good question, I think we'll want to SetPageReferenced() when
> we do a partial write but ClearPageReferenced() when we've
> "written past the end" of the page.

There's no substitute for the real thing: a short delay queue where we treat 
all references as a single reference.  In generic_file_write, a page goes 
onto this list immediately on instantiation.  On exit from the delay queue we 
unconditionally clear the referenced bit and use the rmap list to discard the 
pte referenced bits, then move the page to the inactive list.

>From there, a second reference will rescue the page to the hot end of the 
active list.  Faulted-in pages, including swapped-in pages, mmaped pages and 
zeroed anon pages, take the same path as file IO pages.

A reminder of why we're going to all this effort in the first place: it's to 
distinguish automatically between streaming IO and repeated use of data.  
With the improvements described here, we will additionally be able to detect 
used-once anon pages, which would include execute-once.

Because of readahead, generic_file_read has to work a little differently.  
Ideally, we'd have a time-ordered readahead list and when the readahead 
heuristics accidently get too aggressive, we can cannibalize the future end 
of the list (and pour some cold water on the readahead thingy).  A crude 
approximation of that behavior is just to have a readahead FIFO, and an even 
cruder approximation is to use the inactive list for this purpose.  
Unfortunately, the latter is too crude, because not-yet-used-readahead pages 
have to have a higher priority than just-used pages, otherwise the former 
will be recovered before the latter, which is not what we want.

In any event, each page that passes under the read head of generic_file_read 
goes to the hot end of the delay queue, and from there behaves just like 
other kinds of pages.

Attention has to be paid to balancing the aggressiveness of readahead against 
the refill_inactive scanning rate.  These move in opposite directions in 
response to memory pressure.

One could argue that program text is inherently more valuable than allocated 
data or file cache, in which case it may want its own inactive list, so that 
we can reclaim program text vs other kinds of data at different rates.  The 
relative rates could depend on the relative instantiation rates (which 
includes the faulting rate and the file IO cache page creation rate).  
However, I'd like to see how well the crude presumption of equality works, 
and besides, it's less work that way.  (So ignore this paragraph, please.)

As far as zones go, the route of least resistance is to make both the delay 
queue and the readahead list per-zone, and since that means it's also 
per-node, numa people should like it.

On the testing front, one useful cross-check is to determine whether hot 
spots in code are correctly detected.  After running a while under mixed 
program activity and file IO, we should see that the hot spots as determined 
by a profiler (or cooked by a test program) have in fact moved to the active 
list, while initialization code has been evicted.

All of the above is O(1).

-- 
Daniel
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/

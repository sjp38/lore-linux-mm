Received: from cs.utexas.edu (root@cs.utexas.edu [128.83.139.9])
	by kvack.org (8.8.7/8.8.7) with ESMTP id FAA12729
	for <linux-mm@kvack.org>; Tue, 5 Jan 1999 05:29:08 -0500
Message-Id: <199901051028.EAA10937@disco.cs.utexas.edu>
From: "Paul R. Wilson" <wilson@cs.utexas.edu>
Date: Tue, 5 Jan 1999 04:28:21 -0600
Subject: Re: naive questions, docs, etc.
Sender: owner-linux-mm@kvack.org
To: "Eric W. Biederman" <ebiederm+eric@ccr.net>
Cc: Rik van Riel <riel@humbolt.geo.uu.nl>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

>From eric@meter.ccr.net Tue Jan  5 02:44:30 1999
>To: "Paul R. Wilson" <wilson@cs.utexas.edu>
>Cc: Rik van Riel <riel@humbolt.geo.uu.nl>, linux-mm@kvack.org
>Subject: Re: naive questions, docs, etc.
>References: <199901050031.SAA06940@disco.cs.utexas.edu>
>From: ebiederm+eric@ccr.net (Eric W. Biederman)
>Date: 05 Jan 1999 02:39:53 -0600
>

Eric,

   Thanks for all the comments.  (Colin, too.)

>
>For the basic memory alloctor,  linux mostly implements a classic
>two handed clock algorithm.    The first hand is swap_out which 
>unmaps pages.  The second hand is shrink_mmap.  Which takes pages
>which we are sure no one else is using and puts them in the free page pool.

Is this a classic two-handed algorithm?  I thought that in a two-handed
algorithm, both hands worked over page frames, and bore a particular
relationship to each other.  (Rather than sweeping over different
page orderings entirely, physical vs. virtual.)  I may have my terminology
wrong, though.

>The referenced bit on the on the on a page makes up for any mismatch 
>between swap_out, and shrink_mmap.  Ensuring a page will stay if it
>has been recently referenced, or in the case of newly allocated readahead,
>not be expelled before the readahead is needed. 

I take it you mean the reference bit on the page struct (the PG_referenced
flag.

>This as far as I can tell is the first implementation of true aging
>in linux despite the old ``page aging'' code, that just made it 
>hard to get rid of pages.

(As I understand it, the old code was more like LFU than like LRU,
tending to keep the most-touched pages rather than the most-recently-touched
pages---but with a filter, in that most touches are ignored entirely,
except for once per sweep of the main clock.  This makes it like
"FBR", a weird kind of LFU that filters out the high-frequency touches.
In general that does seem like it would be a bad thing, and having an
aging stage rather than a touch count seems like the right thing.)

In the current scheme, it's not clear to me how much precision the 
PG_referenced bit gives you.  Depending on the positions of both
hands, it seems to me that a page could be touched and immediately
one hand would sweep it, copying the bit to PG_referenced and clearing
it, and then the other hand could come by and clear that.   At the
other extreme, the page could be touched right after the first hand
reaches it, and not be considered by that clock sweep until a
whole cycle goes by;  then the same thing could happen to the bit
in the second (shrink_mmap) clock after the bit is copied from the pte to
PG_referenced.


>The goofy part of implementing default actions inline is probably questionable
>from a design perspective.  However there is no real loss, and further it
>is a technique as branches, and icache misses get progressively more expensive
>compiler writers are contemplating seriously considering.  In truth it is a
>weak of VLIW optimizing.

Is the performance benefit significant, or is it mostly just that the
code hasn't been cleaned up, or a combination of both?

>SysV shm is a wart on the system that was orginally implemented as
>a special case and no one has put in the time to clean it up since.
>I have work underway that will probably do some of that for 2.3 however.

Will that be just making shm segments anonymous regions and doing
mmaps on them, so that their pages are handled by the normal clock
and shrink-mmap?

>One of the really important cases it has been found to optimize for in
>linux is the case of no extra seeks.   The observation is that when reading
>at  a spot on the disk, it is barely more expensive to read/write many pages
>at a time then a single page.  This optimization has been implemented
>in filemap_nopage, swapin_readahead, and swap_out.

I've been following that some, but hadn't gotten to writing about it yet.

I do have some questions about it that relate to my more basic questions
about the swap cache.

Is the swap cache typically large, because pages are evicted to it
aggressively, so that it really acts as a significant aging stage?

Is the swap cache used only for dirty pages, that is, pages that
are dirty when swap_out gets to them?  This would seem to introduce
a bias toward having dirtied pages cached (in swap cache) longer than
clean ones.  So, for example, if you turned up the swap_out clock sweep
speed and grew the swap cache, it would tend to favor user pages over
shared library pages.  Is that right?
--
This is a majordomo managed list.  To unsubscribe, send a message with
the body 'unsubscribe linux-mm me@address' to: majordomo@kvack.org

Received: from haymarket.ed.ac.uk (haymarket.ed.ac.uk [129.215.128.53])
	by kvack.org (8.8.7/8.8.7) with ESMTP id QAA13117
	for <linux-mm@kvack.org>; Fri, 27 Feb 1998 16:43:50 -0500
Date: Fri, 27 Feb 1998 19:41:04 GMT
Message-Id: <199802271941.TAA01151@dax.dcs.ed.ac.uk>
From: "Stephen C. Tweedie" <sct@dcs.ed.ac.uk>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Subject: Re: Fairness in love and swapping
In-Reply-To: <Pine.LNX.3.91.980227003050.6476B-100000@mirkwood.dummy.home>
References: <199802262244.WAA03924@dax.dcs.ed.ac.uk>
	<Pine.LNX.3.91.980227003050.6476B-100000@mirkwood.dummy.home>
Sender: owner-linux-mm@kvack.org
To: Rik van Riel <H.H.vanRiel@fys.ruu.nl>
Cc: "Stephen C. Tweedie" <sct@dcs.ed.ac.uk>, "Dr. Werner Fink" <werner@suse.de>, torvalds@transmeta.com, nahshon@actcom.co.il, alan@lxorguk.ukuu.org.uk, paubert@iram.es, mingo@chiara.csoma.elte.hu, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Hi,

> AFAIK, mapped images aren't part of a proces' RSS, but
> are page-cached (page->inode type of RSS). And swapping
> of those vma's _is_ done in shrink_mmap() in filemap.c.

No, absolutely not.  These pages are certainly present in the page
cache, but they are not swapped out there, and filemap.c never deals
directly with vma scans.  shrink_mmap() refuses to touch any pages which
have a reference count not exactly equal to one, so it avoids memory
mapped pages like the plague.  Memory mapped images are referenced
directly by a process's page tables, so they count against its resident
set size (which is defined as the number of present user-mode pages in
the page tables).

vmscan.c::try_to_swap_out() unhooks these pages from the page tables
when it wants to.  The final swapout of these pages takes place at the
end of that function, where it calls filemap.c::page_unuse(), which
takes care of removing the page from the page cache as soon as the last
reference from the page tables is removed.

> Furthermore, it's quite useful if your read-ahead pages
> stay in memory for a while so you don't read them two
> or even three times before they're actually used.

We never will read more than once --- the pages are still in the page
cache, so whenever we try to swap them in, we can always find the
readahead copy there.  Memory-mapped pages have to be in the page cache
before we are allowed to link them into the page tables, so the pages
are shared by both in the page cache *and* the page tables.  It is the
swapper which is responsible for turfing shared pages.  shrink_mmap()
only ever looks for unshared cache pages and buffers.

> But if I've overlooked something, I'd really like to hear about
> it... A bit of a clue never hurts when coding up new patches :-)

You're welcome. :)

Cheers,
 Stephen.

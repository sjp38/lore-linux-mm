Date: Wed, 3 May 2000 11:17:52 -0700 (PDT)
From: Linus Torvalds <torvalds@transmeta.com>
Subject: Re: Oops in __free_pages_ok (pre7-1) (Long) (backtrace)
In-Reply-To: <200005031731.KAA80944@google.engr.sgi.com>
Message-ID: <Pine.LNX.4.10.10005031110200.6180-100000@penguin.transmeta.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Kanoj Sarcar <kanoj@google.engr.sgi.com>
Cc: Rajagopal Ananthanarayanan <ananth@sgi.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>


On Wed, 3 May 2000, Kanoj Sarcar wrote:
> 
> At no point between the time try_to_swap_out() is running, will is_page_shared()
> wrongly indicate the page is _not shared_, when it is really shared (as you
> say, it is pessimistic). 

Note that this is true only if you assume processor ordering.

With no common locks, a less strictly ordered system (like an alpha) might
see the update of the swap-count _much_ later on the second CPU, so that
is_page_shared() may end up not being pessimistic after all (it could get
the new page count, but the old swap-count, and thinks that the page is
free to be removed from the swap cache).

This is why not having a shared lock looks like a bug to me. Even if that
particular bug might never trigger on an x86.

_Something_ obviously triggers on the x86, though. 

Note that we may be barking up the wrong tree here: it may be a completely
different page mishandling that causes this. For example, one bug in NFS
used to be that it free'd a page that was allocated with "alloc_pages()"
using "free_page()" - which takes the virtual address and only works for
"normal" pages. Now, if you have more than about 960MB of memory and the
allocated page was a highmem page, you may end up freeing the wrong page
due to mixing metaphors, and suddenly the page counts are wrong.

And with the wrong page counts, the BUG() can/will happen only much later,
because a innocent "__free_page()" ends up doing the BUG(), but the real
offender happened earlier.

We fixed one such bug in NFS. Maybe there are more lurking? How much
memory do the machines have that have problems?

		Linus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/

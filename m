Date: Wed, 3 May 2000 01:31:41 -0700 (PDT)
From: Linus Torvalds <torvalds@transmeta.com>
Subject: Re: Oops in __free_pages_ok (pre7-1) (Long) (backtrace)
In-Reply-To: <Pine.LNX.4.10.10005030046480.981-100000@penguin.transmeta.com>
Message-ID: <Pine.LNX.4.10.10005030117500.981-100000@penguin.transmeta.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Kanoj Sarcar <kanoj@google.engr.sgi.com>
Cc: Rajagopal Ananthanarayanan <ananth@sgi.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>


On Wed, 3 May 2000, Linus Torvalds wrote:
> 
> You may be right. The code certainly tries to be careful. However, I don't
> trust "is_page_shared()" at all, _especially_ if there are people around
> who play with the page state without locking the page. 
> 
> If "is_page_shared()" ends up ever getting the wrong value, I suspect we'd
> be screwed. There may be other schenarios..

Kanoj, why couldn't this happen:
 - CPU0 runs swapout
	- finds page which is a swap cache entry
	- does the swap_duplicate()
	- does __free_page() on it without locking it (it wasn't locked
	  before, either)
 - CPU1 runs shrink_mmap
	- finds same page on the LRU list
	- locks it _just_ after CPU0 tested that it was unlocked
	- looks at the page countersand the swap cache counters to see if
	  it was shared ("is_page_shared()").

 - There is _no_ synchronization between the two, as far as I can tell.
   "swap_duplicate()" on CPU0 will get the swap device lock, and
   "is_page_shared()" will run with the page lock held, but there is no
   common locking between the two at all that I can see.

So "is_page_shared()" can be entirely crap. And can tell shrink_mmap()
that the page cache entry can be freed. Now, I have no idea what that will
actually result in, but I bet that we can just get the usage counters off
by one here, and then at some later date we free page that we've already
free'd - and that page may have been re-allocated for something else and
isin the middle of a page-in right now (which is how we end up freeing a
page that is locked).

Or something. The lack of any synchronization looks fishy to me. The page
lock would act as synchronization, but so would the swap device lock.  And
maybe I'm still barking up the wrong tree..

		Linus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/

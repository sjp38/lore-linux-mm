From: kanoj@google.engr.sgi.com (Kanoj Sarcar)
Message-Id: <200005031608.JAA87583@google.engr.sgi.com>
Subject: Re: Oops in __free_pages_ok (pre7-1) (Long) (backtrace)
Date: Wed, 3 May 2000 09:08:53 -0700 (PDT)
In-Reply-To: <Pine.LNX.4.10.10005030117500.981-100000@penguin.transmeta.com> from "Linus Torvalds" at May 03, 2000 01:31:41 AM
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Linus Torvalds <torvalds@transmeta.com>
Cc: Rajagopal Ananthanarayanan <ananth@sgi.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

> 
> 
> On Wed, 3 May 2000, Linus Torvalds wrote:
> > 
> > You may be right. The code certainly tries to be careful. However, I don't
> > trust "is_page_shared()" at all, _especially_ if there are people around
> > who play with the page state without locking the page. 
> > 
> > If "is_page_shared()" ends up ever getting the wrong value, I suspect we'd
> > be screwed. There may be other schenarios..
> 
> Kanoj, why couldn't this happen:
>  - CPU0 runs swapout
> 	- finds page which is a swap cache entry
> 	- does the swap_duplicate()
> 	- does __free_page() on it without locking it (it wasn't locked
> 	  before, either)
>  - CPU1 runs shrink_mmap
> 	- finds same page on the LRU list
> 	- locks it _just_ after CPU0 tested that it was unlocked
> 	- looks at the page countersand the swap cache counters to see if
> 	  it was shared ("is_page_shared()").
> 
>  - There is _no_ synchronization between the two, as far as I can tell.
>    "swap_duplicate()" on CPU0 will get the swap device lock, and
>    "is_page_shared()" will run with the page lock held, but there is no
>    common locking between the two at all that I can see.

FWIW, I think you are looking in the right direction, ie, shrink_mmap
previously used to run with lock_kernel, and not anymore, so there is a 
chance of shrink_mmap racing with try_to_swap_out. I thought about this 
though, but couldn't come up with an example ...

But, your example does not pull thru. Note that before shrink_mmap will
even touch the page, it does a 

                if (!page->buffers && page_count(page) > 1)
                        goto dispose_continue;

The page is question is guaranteed to have page_count(page) > 1, since 
try_to_swap_out has not dropped the user pte reference in your example.

Another thing to note is that shrink_mmap does not do a is_page_shared(),
it just checks for page-reference count to be 0 (the swapentry might have
references from other processes). Else, shrink_mmap will never be able
to free these pages ...

> 
> So "is_page_shared()" can be entirely crap. And can tell shrink_mmap()

Not really ... look at other places that call is_page_shared, they all
hold the pagelock. shrink_mmap does not bother with is_page_shared logic.

What is interesting is that people are reporting PageSwapEntry deletion
seems to fix this ...

Kanoj

> that the page cache entry can be freed. Now, I have no idea what that will
> actually result in, but I bet that we can just get the usage counters off
> by one here, and then at some later date we free page that we've already
> free'd - and that page may have been re-allocated for something else and
> isin the middle of a page-in right now (which is how we end up freeing a
> page that is locked).
> 
> Or something. The lack of any synchronization looks fishy to me. The page
> lock would act as synchronization, but so would the swap device lock.  And
> maybe I'm still barking up the wrong tree..
> 
> 		Linus
> 
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux.eu.org/Linux-MM/
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/

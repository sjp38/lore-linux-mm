From: kanoj@google.engr.sgi.com (Kanoj Sarcar)
Message-Id: <200005031624.JAA53529@google.engr.sgi.com>
Subject: Re: Oops in __free_pages_ok (pre7-1) (Long) (backtrace)
Date: Wed, 3 May 2000 09:24:22 -0700 (PDT)
In-Reply-To: <Pine.LNX.4.10.10005030911200.5951-100000@penguin.transmeta.com> from "Linus Torvalds" at May 03, 2000 09:14:28 AM
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
> On Wed, 3 May 2000, Kanoj Sarcar wrote:
> > > So "is_page_shared()" can be entirely crap. And can tell shrink_mmap()
> > 
> > Not really ... look at other places that call is_page_shared, they all
> > hold the pagelock. shrink_mmap does not bother with is_page_shared logic.
> 
> That wasn't my argument.
> 
> My argument is that yes, the _callers_ of is_page_shared() all hold the
> page lock. No question about that. But the things that is_page_shared()
> actually tests can be modified without holding the page lock, so the page
> lock doesn't actually _protect_ it. See?
>

Give me an example where the page_lock is not actually protecting the
"sharedness" of the page. Note that though the page_count and swap_count
are not themselves protected by page_lock, the "sharedness" could never 
change while you have the page_lock. "Sharedness" being whatever
is_page_shared() returns. Unless you can give me an example ....

Wait a second. I was familiar with is_page_shared() having 

        if (PageSwapCache(page))
                count += swap_count(page) - 2;

and now I see it is

        if (PageSwapCache(page))
                count += swap_count(page) - 2 - !!page->buffers;

Kanoj
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/

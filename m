Date: Mon, 15 May 2000 17:34:13 -0700 (PDT)
From: Linus Torvalds <torvalds@transmeta.com>
Subject: Re: Estrange behaviour of pre9-1
In-Reply-To: <yttu2fzxs4y.fsf@vexeta.dc.fi.udc.es>
Message-ID: <Pine.LNX.4.10.10005151724430.819-100000@penguin.transmeta.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "Juan J. Quintela" <quintela@fi.udc.es>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>


On 16 May 2000, Juan J. Quintela wrote:
> 
> I was discussing with Rik an scheme similar to that. I have found that
> appears that we are trying very hard to get pages without doing any
> writing. I think that we need to _wait_ for the pages if we are really
> low on memory.

That is indeed what my shink_mmap() suggested change does (ie make
"sync_page_buffers()" wait for old locked buffers). 

That, together with each "try_to_free_page()" only trying to free a fairly
small number pf pages, should make it behave fine. I think one of the
reasons Rik's patch had bad performance was that when it started swapping
out, the "free_before_allocate" trap caused it to swap out _a lot_ by
trapping everybody else into freeing stuff too. Even when it might not
have been strictly necessary.

Btw, if you're testing the "wait for locked buffers" case, you should also
remove the "run_task(&tq_disk)" from do_try_to_free_pages(). That
artificially throttles disk performance regardless of whether it is needed
or not. The "wait for locked buffers" version of the code will
automatically cause the tq_disk queue to be emptied when it actually turns
out that yes, we really need to start the thing going. Which is exactly
what we want.


?		  Just now, for pathological examples like mmap002 that
> dirty a lot of memory very fast, I am observing that we made the page
> cache grow until it occupies all the RAM. That is OK when the RAM is
> empty.  But in that moment, if all the pages are dirty, we call
> shrink_mmap, and it will start the async write of all the pages (in
> this case, all our memory).

Yes. This is what kflushd is there for, and this is what "balance_dirty()"
is supposed to avoid. It may not work (and memory mappings are the worst
case, because the system doesn't _know_ that they are dirty until at the
point where it starts looking at the page tables - which is when it's too
late).

In order to truly make this behave more smoothly, we should trap the thing
when it creates a dirty page, which is quite hard the way things are set
up now. Certainly not 2.4.x code.

[ Incidentally, the thing that mmap002 tests is quite rare, so I don't
  think we have to have perfect behaviour, we just shouldn't kill
   processes the way we do now ]

		Linus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/

Date: Thu, 3 Aug 2000 19:05:56 -0300 (BRST)
From: Rik van Riel <riel@conectiva.com.br>
Subject: Re: RFC: design for new VM
In-Reply-To: <Pine.LNX.4.10.10008031316490.6528-100000@penguin.transmeta.com>
Message-ID: <Pine.LNX.4.21.0008031850330.24022-100000@duckman.distro.conectiva>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Linus Torvalds <torvalds@transmeta.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.rutgers.edu
List-ID: <linux-mm.kvack.org>

On Thu, 3 Aug 2000, Linus Torvalds wrote:
> On Thu, 3 Aug 2000, Rik van Riel wrote:
> > 
> > The lists are not at all dependant on where the pages come
> > from. The lists are dependant on the *page age*. This almost
> > sounds like you didn't read my mail... ;(
> 
> I did read the email. And I understand that. And that's exactly
> why I think a single-list is equivalent (because your lists
> basically act simply as "caches" of the page age).

If you add "with statistics about how many pages of age 0 there
are" this is indeed the case.

> > NO. We need different queues so waiting for pages to be flushed
> > to disk doesn't screw up page aging of the other pages (the ones
> > we absolutely do not want to evict from memory yet).
> 
> Go back. Read it. Realize that your "multiple queues" is nothing
> more than "cached information". They do not change _behaviour_
> at all. They only change the amount of CPU-time you need to
> parse it.

If the information is cached somewhere else, then this is indeed
the case. My point is that we need to know how many pages with
page->age==0 we have, so we can know if we need to scan memory
and age more pages or if we should simply wait a bit until the
currently old pages are flushed to disk and ready to be reused.

> Basically, answer me this _simple_ question: what _behavioural_
> differences do you claim multiple queues have? Ignore CPU usage
> for now.
> 
> I'm claiming they are just a cache.
> 
> And you claim that the current MM cannot be balanced, but your
> new one can.

I agree that we could cache the information about how many pages
of different ages and different dirty state we have in memory in
a different way.

We could have one single queue, as you wrote, and a number of
counters. Basically we'd need a counter for the number of old
(age==0) clean pages and one for the old dirty pages.

Then we'd have multiple functions. Kflushd and kupdate would
flush out the old dirty pages, __alloc_pages would walk the
list to reclaim the old clean pages and we'd have a separate
page aging function that only walks the list when we're short
on free + inactive_dirty + inactive_clean pages.

That would give us the same behaviour as the plan I wrote.

What I fail to see is why this would be preferable to a code
base where all the different pages are neatly separated and
we don't have N+1 functions that are all scanning the same
list, special-casing out each other's pages and searching 
the list for their own special pages...

regards,

Rik
--
"What you're running that piece of shit Gnome?!?!"
       -- Miguel de Icaza, UKUUG 2000

http://www.conectiva.com/		http://www.surriel.com/


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/

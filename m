Date: Thu, 3 Aug 2000 11:05:47 -0700 (PDT)
From: Linus Torvalds <torvalds@transmeta.com>
Subject: Re: RFC: design for new VM
In-Reply-To: <Pine.LNX.4.21.0008021212030.16377-100000@duckman.distro.conectiva>
Message-ID: <Pine.LNX.4.10.10008031020440.6384-100000@penguin.transmeta.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Rik van Riel <riel@conectiva.com.br>
Cc: linux-mm@kvack.org, linux-kernel@vger.rutgers.edu
List-ID: <linux-mm.kvack.org>


On Wed, 2 Aug 2000, Rik van Riel wrote:
>
> [Linus: I'd really like to hear some comments from you on this idea]

I am completely and utterly baffled on why you think that the multi-list
approach would help balancing.

Every single indication we have ever had is that balancing gets _harder_
when you have multiple sources of pages, not easier.

As far as I can tell, the only advantage of multiple lists compared to the
current one is to avoid overhead in walking extra pages, no?

And yet you claim that you see no way to fix the current VM behaviour.

This is illogical, and sounds like complete crap to me.

Why don't you just do it with the current scheme (the only thing needed to
be added to the current scheme being the aging, which we've had before),
and prove that the _balancing_ works. If you can prove that the balancing
works but that we spend unnecessary time in scanning the pages, then
you've proven that the basic VM stuff is right, and then the multiple
queues becomes a performance optimization.

Yet you seem to sell the "multiple queues" idea as some fundamental
change. I don't see that. Please explain what makes your ideas so
radically different?

> The design is based around the following ideas:
> - center-balanced page aging, using
>     - multiple lists to balance the aging
>     - a dynamic inactive target to adjust
>       the balance to memory pressure
> - physical page based aging, to avoid the "artifacts"
>   of virtual page scanning
> - separated page aging and dirty page flushing
>     - kupdate flushing "old" data
>     - kflushd syncing out dirty inactive pages
>     - as long as there are enough (dirty) inactive pages,
>       never mess up aging by searching for clean active
>       pages ... even if we have to wait for disk IO to
>       finish
> - very light background aging under all circumstances, to
>   avoid half-hour old referenced bits hanging around

As far as I can tell, the above is _exactly_ equivalent to having one
single list, and multiple "scan-points" on that list. 

A "scan-point" is actually very easy to implement: anybody at all who
needs to scan the list can just include his own "anchor-page": a "struct
page_struct" that is purely local to that particular scanner, and that
nobody else will touch because it has an artificially elevated usage count
(and because there is actually no real page associated with that virtual
"struct page" the page count will obviosly never decrease ;).

Then, each scanner just advances its own anchor-page around the list, and
does whatever it is that the scanner is designed to do on the page it
advances over. So "bdflush" would do

	..
	lock_list();
	struct page *page = advance(&bdflush_entry);
	if (page->buffer) {
		get_page(page);
		unlock_list();
		flush_page(page);
		continue;
	}
	unlock_list();
	..

while the page ager would do

	lock_list();
	struct page *page = advance(&bdflush_entry);
	page->age = page->age >> 1;
	if (PageReferenced(page))
		page->age += PAGE_AGE_REF;
	unlock_list();

etc.. Basically, you can have any number of virtual "clocks" on a single
list.

No radical changes necessary. This is something we can easily add to
2.4.x.

The reason I'm unconvinced about multiple lists is basically:

 - they are inflexible. Each list has a meaning, and a page cannot easily
   be on more than one list. It's really hard to implement overlapping
   meanings: you get exponential expanision of combinations, and everybody
   has to be aware of them.

   For example, imagine that the definition of "dirty" might be different
   for different filesystems.  Imagine that you have a filesystem with its
   own specific "walk the pages to flush out stuff", with special logic
   that is unique to that filesystem ("you cannot write out this page
   until you've done 'Y' or whatever). This is hard to do with your
   approach. It is trivial to do with the single-list approach above.

   More realistic (?) example: starting write-back of pages is very
   different from waiting on locked pages. We may want to have a "dirty
   but not yet started" list, and a "write-out started but not completed"
   locked list. Right now we use the same "clock" for them (the head of
   the LRU queue with some ugly heuristic to decide whether we want to
   wait on anything).

   But we potentially really want to have separate logic for this: we want
   to have a background "start writeout" that goes on all the time, and
   then we want to have a separate "start waiting" clock that uses
   different principles on which point in the list to _wait_ on stuff.

   This is what we used to have in the old buffer.c code (the 2.0 code
   that Alan likes). And it was _horrible_ to have separate lists, because
   in fact pages can be both dirty and locked and they really should have
   been on both lists etc..

 - in contrast, scan-points (withour LRU, but instead working on the basis
   of the age of the page - which is logically equivalent) offer the
   potential for specialized scanners. You could have "statistics
   gathering robots" that you add dynamically. Or you could have
   per-device flush deamons.

   For example, imagine a common problem with floppies: we have a timeout
   for the floppy motor because it's costly to start them up again. And
   they are removable. A perfect floppy driver would notice when it is
   idle, and instead of turning off the motor it might decide to scan for
   dirty pages for the floppy on the (correct) assumption that it would be
   nice to have them all written back instead of turning off the motor and
   making the floppy look idle.

   With a per-device "dirty list" (which you can test out with a page
   scanner implementation to see if it ends up reall yimproving floppy
   behaviour) you could essentially have a guarantee: whenever the floppy
   motor is turned off, the filesystem on that floppy is synced.
   Test implementation: floppy deamon that walks the list and turns off
   the engine only after having walked it without having seen any dirty
   blocks.

   In the end, maybe you realize that you _really_ don't want a dirty list
   at all. You want _multiple_ dirty lists, one per device.

   And that's really my point. I think you're too eager to rewrite things,
   and not interested enough in verifying that it's the right thing. Which
   I think you can do with the current one-list thing easily enough.

 - In the end, even if you don't need the extra flexibility of multiple
   clocks, splitting them up into separate lists doesn't change behaviour,
   it's "only" a CPU time optimization.

   Which may well be worth it, don't get me wrong. But I don't see why you
   tout this as being something radically needed in order to get better VM
   behaviour. Sure, multiple lists avoids the unnecessary walking over
   pages that we don't care about for some particular clock. And they may
   well end up being worth it for that reason. But it's not a very good
   way of doing prototyping of the actual _behaviour_ of the lists.

To make a long story short, I'd rather see a proof-of-concept thing. And I
distrust your notion that "we can't do it with the current setup, we'll
have to implement something radically different". 

Bascially, IF you think that your newly designed VM should work, then you
should be able to prototype and prove it easily enough with the current
one. 

I'm personally of the opinion that people see that page aging etc is hard,
so they try to explain the current failures by claiming that it needs a
completely different approach. And in the end, I don't see what's so
radically different about it - it's just a re-organization. And as far as
I can see it is pretty much logically equivalent to just minor tweaks of
the current one.

(The _big_ change is actually the addition of a proper "age" field. THAT
is conceptually a very different approach to the matter. I agree 100% with
that, and the reason I don't get all that excited about it is just that we
_have_ done page aging before, and we dropped it for probably bad reasons,
and adding it back should not be that big of a deal. Probabl yless than 50
lines of diff).

Read Dilbert about the effectiveness of (and reasons for)  re-
organizations.

		Linus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/

Date: Thu, 3 Aug 2000 15:50:40 -0300 (BRST)
From: Rik van Riel <riel@conectiva.com.br>
Subject: Re: RFC: design for new VM
In-Reply-To: <Pine.LNX.4.10.10008031020440.6384-100000@penguin.transmeta.com>
Message-ID: <Pine.LNX.4.21.0008031512390.24022-100000@duckman.distro.conectiva>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Linus Torvalds <torvalds@transmeta.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.rutgers.edu
List-ID: <linux-mm.kvack.org>

On Thu, 3 Aug 2000, Linus Torvalds wrote:
> On Wed, 2 Aug 2000, Rik van Riel wrote:
> >
> > [Linus: I'd really like to hear some comments from you on this idea]
> 
> I am completely and utterly baffled on why you think that the
> multi-list approach would help balancing.
> 
> Every single indication we have ever had is that balancing gets
> _harder_ when you have multiple sources of pages, not easier.

The lists are not at all dependant on where the pages come
from. The lists are dependant on the *page age*. This almost
sounds like you didn't read my mail... ;(

> As far as I can tell, the only advantage of multiple lists
> compared to the current one is to avoid overhead in walking
> extra pages, no?

NO. We need different queues so waiting for pages to be flushed
to disk doesn't screw up page aging of the other pages (the ones
we absolutely do not want to evict from memory yet).

That the inactive list is split into two lists has nothing to
do with page aging or balancing. We just do that to make it
easier to kick bdflush and to have the information available
we need for eg. write throttling.

> Why don't you just do it with the current scheme (the only thing
> needed to be added to the current scheme being the aging, which
> we've had before), and prove that the _balancing_ works.

In the current scheme we don't have enough information available
to do proper balancing.

> Yet you seem to sell the "multiple queues" idea as some fundamental
> change. I don't see that. Please explain what makes your ideas so
> radically different?

Having multiple queues instantly gives us the information we need
to do balancing. Having just one queue inevitably means we end up
doing page aging while waiting for already old pages to be flushed
to disk and we'll end up evicting the *wrong* pages from memory.

> As far as I can tell, the above is _exactly_ equivalent to
> having one single list, and multiple "scan-points" on that list.

More or less, yes. Except that the scan points still don't give us
the information we need to decide if we need to age more not-old
pages or if we simply have a large amount of dirty old pages and
we need to wait for them to be synced to disk.

> bdflush
> 
> 	..
> 	lock_list();
> 	struct page *page = advance(&bdflush_entry);
> 	if (page->buffer) {
> 		get_page(page);
> 		unlock_list();
> 		flush_page(page);
> 		continue;
> 	}
> 	unlock_list();
> 	..

This is absolute CRAP. Have you read the discussions about the
page->mapping->flush(page) callback?

In 2.5 we'll be dealing with journaling filesystems, filesystems
with delayed allocation (flush on allocate) and various other
things you do not want the VM subsystem to know about.

We want to have 2 lists of dirty pages (that the VM subsystem
knows about) in the system:
- inactive_dirty
- active_writeback  (works like the current bufferhead list)

Kupdate will _ask the filesystem_ (or swap subsystem) if a
certain page could be flushed to disk. If the subsystem called
has opportunities to do IO clustering, it can do so. If the page
is a pinned page of a journaling filesystem and cannot be flushed
yet, the filesystem will not flush it (but flush something else
instead, because it knows there is memory pressure).

> The reason I'm unconvinced about multiple lists is basically:
> 
>  - they are inflexible. Each list has a meaning, and a page cannot easily
>    be on more than one list.

Until you figure out a way for pages to have multiple page ages
at the same time, I don't see how this is relevant.

>    For example, imagine that the definition of "dirty" might be different
>    for different filesystems.  Imagine that you have a filesystem with its
>    own specific "walk the pages to flush out stuff", with special logic
>    that is unique to that filesystem ("you cannot write out this page
>    until you've done 'Y' or whatever). This is hard to do with your
>    approach. It is trivial to do with the single-list approach above.

That has absolutely nothing to do with it. The VM subsystem cares
about _page replacement_. Flushing pages is done by kindly asking
the filesystem if it could flush something (preferably this page).

Littering the VM subystem with filesystem knowledge and having page
replacement fucked up by that is simply not the way to go. At least,
not if you want to have code that can actually be maintained by
anybody. Especially when the dirty bit means something different to
different filesystems ...

>    More realistic (?) example: starting write-back of pages is very
>    different from waiting on locked pages. We may want to have a "dirty
>    but not yet started" list, and a "write-out started but not completed"
>    locked list. Right now we use the same "clock" for them (the head of
>    the LRU queue with some ugly heuristic to decide whether we want to
>    wait on anything).
> 
>    But we potentially really want to have separate logic for this: we want

Gosh, so now you are proposing the multi-queue idea you flamed
into the ground one page up?

>  - in contrast, scan-points (withour LRU, but instead working on the basis
>    of the age of the page - which is logically equivalent) offer the
>    potential for specialized scanners. You could have "statistics
>    gathering robots" that you add dynamically. Or you could have
>    per-device flush deamons.

We could still have those with the multiqueue code. Just have the
per-filesystem flush daemon walk the inactive_dirty and
active_writeback list.

Per-device flush daemons are, unfortunately(?), impossible when
you're dealing with allocate-on-flush filesystems.

> Bascially, IF you think that your newly designed VM should work,
> then you should be able to prototype and prove it easily enough
> with the current one.

The current one doesn't give us the information we need to
balance the different activities (keeping page aging at the
right pace, flushing out old dirty pages, write throttling)
with each other.

If there was any hope that the current VM would be a good
enough basis to work from I would have done that. In fact,
I tried this for the last 6 months and horribly failed.

Other people have also tried (and failed). I'd be surprised
if you could do better, but it sure would be a pleasant
surprise...

> (The _big_ change is actually the addition of a proper "age"
> field. THAT is conceptually a very different approach to the
> matter. I agree 100% with that,

While page aging is a fairly major part, it is certainly NOT
the big issue here...

The big issues are:
- separate page aging and page flushing, so lingering dirty
  pages don't fuck up page aging
- organise the VM in such a way that we actually have the
  information available we need for balancing the different
  VM activities
- abstract away dirty page flushing in such a way that we
  give filesystems (and swap) the opportunity for their own
  optimisations

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

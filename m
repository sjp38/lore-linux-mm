Date: Thu, 6 Jul 2000 12:35:58 +0200 (CEST)
From: Andrea Arcangeli <andrea@suse.de>
Subject: Re: [PATCH] 2.2.17pre7 VM enhancement Re: I/O performance on
 2.4.0-test2
In-Reply-To: <20000629140039.N3473@redhat.com>
Message-ID: <Pine.LNX.4.21.0007061211480.4810-100000@inspiron.random>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "Stephen C. Tweedie" <sct@redhat.com>
Cc: Marcelo Tosatti <marcelo@conectiva.com.br>, Rik van Riel <riel@conectiva.com.br>, Jens Axboe <axboe@suse.de>, Alan Cox <alan@redhat.com>, Derek Martin <derek@cerberus.ne.mediaone.net>, Linux Kernel <linux-kernel@vger.rutgers.edu>, linux-mm@kvack.org, "David S. Miller" <davem@redhat.com>
List-ID: <linux-mm.kvack.org>

On Thu, 29 Jun 2000, Stephen C. Tweedie wrote:

>Rik's multi-queue stuff is the place to start (this is not a
>coincidence --- we spent quite a bit of time talking this through).
>Aging process pages and unmapping them should be considered part of
>the same job.  Removing pages from memory completely is a separate
>job.  I can't emphasise this enough --- this separation just fixes so
>many problems in our current VM that we really, really need it for
>2.4.
>
>Look at how such a separation affects the swap_out problem above.  We
>now have two jobs to do --- the aging code needs to keep a certain
>number of pages freeable on the last-chance list (whatever you happen
>to call it), that number being dependent on current memory pressure.
>That list consists of nothing but unmapped, clean pages.  (A separate
>list for unmapped, dirty pages is probably desirable for completely
>different reasons.)
>
>Do this and there is no longer any confusion in the swapper itself
>about whether a page has become freed or not.  Either a foreground
>call to the swapout code, or a background kswapd loop, can keep
>populating the last chance lists; it doesn't matter, because we
>decouple the concept of swapout from the concept of freeing memory.
>When we actually want to free pages now, we can *always* tell how much
>cheap page reclaim can be done, just by looking at the length of the
>last-chance list. 
>
>We can play all sorts of games with this, easily.  For example, when
>the real free page count gets too low, we can force all normal page
>allocations to be done from the last-chance list instead of the free
>list, allowing only GFP_ATOMIC allocations to use up genuine free
>pages.  That gives us proper flow control for non-atomic memory
>allocations without all of the current races between one process
>freeing a page and then trying to allocate it once try_to_free_page()
>has returned (right now, an interrupt may have gobbled the page in the
>mean time because we use the same list for the pages returned by
>swap_out as for allocations).
>
>I really think we need to forget about tuning the 2.4 VM until we have
>such fundamental structures in place.  Until we have done that hard
>work, we're fine-tuning a system which is ultimately fragile.  Any
>structural changes will make the fine-tuning obsolete, so we need to
>get the changes necessary for a robust VM in _first_, and then do the
>performance fine-tuning.
>
>One obvious consequence of doing this is that we need to separate out
>mechanisms from policy.  With multiple queues in the VM for these
>different jobs --- aging, cleaning, reclaiming --- we can separate out
>the different mechanisms in the VM much more easily, which makes it
>far easier to tune the policy for performance optimisations later on.
>Right now, to do policy tuning we end up playing with core mechanisms
>like the flow control loops all over the place.  Nasty.

I'm not sure what you planned exactly to do (maybe we can talk about this
some time soon) but I'll tell you what I planned to do taking basic idea
to throw-out-swap_out from the very _cool_ DaveM throw-swap_out patch
floating around that's been the _only_ recent VM 2.[34].x patch that I
seen floating around that really excited me (I've not focused all the
details of his patch but I'm pretty sure it's very similar design even if
probably not equal to what I'm trying to do).

In classzone I just have mapped pages out of lru and I have two lists one
for swap_cache and one for page_cache, that is necessary to avoid cache
pollution during swapping and users and all the numbers I received noticed
that (only bad report I got is from hpa and I think the problem was the
suboptimal free_before_allocate fix that I forward ported and merged into
the classzone patch that I sent to Alan for ac22-class, and that I then I
dropped immediatly in ac22-class++. However I didn't had the confirm that
ac22-class++ fixed the bad behaviour with lots of memory and streaming I/O
so I can't exclude the problem is still there. But at least now to fix
that allocator race I developed GFP-race-3 for 2.2.16 that seems to work
fine)

The next step after what we have in classzone is instead of only removing
the mapped pages from the lru_cache (as classzone is just doing), to
_refile_ (not only list_del) the mapped pages in the lru-mapped lru queue.
Then also anonymous and shm pages will be chained in a the same lru-mapped
list (and I just have all the entry points of anonymous memory too from
current classzone, I only need to do the same for shm, but probably in the
first step I will left shm_swap around providing backwards compatibility
to memory with page->map_count left to zero like shm).

Then we'll need a page-to-pte_chain reverse lookup. Once we'll have that
too we'll can remove swap_out and do everything (except dcache/icache
things) in shrink_mmap (I'm sure Dave just throwed swap_out away and I'm
pretty sure he used very similar way). On a longer term also dcache/icache
should be placed in a page based lru that lives at the same level of the
lru_cache lru (or alternatively between lru_cache and lru_mapped).

So basically we'll have these completly different lists:

	lru_swap_cache
	lru_cache
	lru_mapped

The three caches have completly different importance that is implicit by
the semantics of the memory they are queuing. Shrinking swap_cache first
is vital for performance under swap for example (and I can just do that in
recent classzone patches). Shrinking lru_cache first is vital for
performance under streaming I/O but without low on freeable memory
scenario.

We'll only have to walk on the swap cache then fallback in lru_cache and
then fallback in lru_mapped. In normal usage the swap_cache lru will be
empty. (The mapped swap_cache can probably be mixed with the lru_mapped
cache). Then while browsing the lru_mapped list we'll take care of the
accessed bit in the pte by checking all ptes and clearing the accessed bit
from all them and avoiding to free the page if at least one pte have the
accessed bit set. For all the pages in all the lrus the referenced bit
will keep working as now to avoid rolling the lru for each cache-hit.

For the the pages in lru_cache and lru_swap_cache the pte-chain have to be
empty or we'll BUG().

Then we'll also avoid completly the problems we have now with not being
able to do success/non-success in swap_out with clean pages since we'll
free them in one go after clearing the pte from shrink_mmap or we'll
convert them to swap_cache that we'll free later.

Then also invalidate_inode_pages will become trivial since we'll be able
to corretly invalidate also mapped pages and clear their ptes. This also
makes trivial to optimize the msync by simply clearing the dirty bitflag
from all the ptes in the chain of each page ;) and probably some other
actually-nasty thing too.

Very downside of this design is that we'll have to chain the ptes with
potential additional SMP locking and for sure a few more cycles per page
fault and per pte_clearing. The additional work is O(1) at least and it
will be only a ""mere"" lock+unlock plus list_add or list_del. However the
design looks promising to me even if the rework is very intensive
(probably more intensive than Dave's patch).

I usually prefer to talk about things when they're working on my box to
avoid vapourware threads but since I'm often reading about other
vapourware stuff too I'd preferred to describe my so-far-only-vapourware
plan too so you're aware of the other alternative vm works going on and
you can choose to join (or reject) it ;).

Comments?

Andrea

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/

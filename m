Date: Thu, 23 Aug 2007 14:05:09 +0200
From: Andrea Arcangeli <andrea@suse.de>
Subject: Re: [RFC 0/7] Postphone reclaim laundry to write at high water
	marks
Message-ID: <20070823120506.GN13915@v2.random>
References: <20070820215040.937296148@sgi.com> <1187692586.6114.211.camel@twins> <Pine.LNX.4.64.0708211347480.3082@schroedinger.engr.sgi.com> <1187730812.5463.12.camel@lappy> <Pine.LNX.4.64.0708211418120.3267@schroedinger.engr.sgi.com> <46CB5C89.2070807@redhat.com> <Pine.LNX.4.64.0708211521260.5728@schroedinger.engr.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.64.0708211521260.5728@schroedinger.engr.sgi.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: Rik van Riel <riel@redhat.com>, Peter Zijlstra <peterz@infradead.org>, linux-mm@kvack.org, dkegel@google.com, akpm@linux-foundation.org, Nick Piggin <npiggin@suse.de>, ak@suse.de, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Tue, Aug 21, 2007 at 03:32:25PM -0700, Christoph Lameter wrote:
> 1. Like in the earlier patchset allow reentry to reclaim under 
>    PF_MEMALLOC if we are out of all memory.

Can you simply tweak on the may_writepage flag only to achieve the
second pass? We're talking here about a totally non-performance case,
almost impossible to hit in practice unless you do real weird things,
and certainly very unlikely to happen. So I'm unsure what's all that
complexity just to make a regular pass on the lru looking for clean
pages, something may_writepage=0 already does.

Like Andi said at most one may_writepage=0 recursion should be
allowed.

If the PF_MEMALLOC is found empty, I agree entering reclaim a second
time with may_writepage=0 sounds theoretically a good idea (in
practice it should never be necessary). printk must also be printed to
warn the user he was risking to deadlock for real and he has to
increase the min_free_kbytes.

> 2. Do the laundry as here but do not write out laundry directly.
>    Instead move laundry to a new lru style list in the zone structure.
>    This will allow the recursive reclaim to also trigger writeout
>    of pages (what this patchset was supposed to accomplish).

A new lru for this sounds overkill to me, we're talking about deadlock
avoidance, this has absolutely nothing to do with real life 99.9999%
of runtime of all kernels out there.

> 3. Perform writeback only from kswapd. Make other threads
>    wait on kswapd if memory is low, we can wait and writeback still
>    has to progress.

What does buy you to think about other threads? The whole trouble is
that PF_MEMALLOC is global, no matter which thread (pdflush like other
email to Andi or kswapd here) still it'll deadlock the same way. If
your intent is to limit the max number of in-flight writepage that
could be achieved with a sempahore, not by context switching for no
good reason. kswapd is needed for atomic allocations and to pipeline
the VM so that the vm runs more likely asynchronous inside kswapd.

> 4. Then allow reclaim of GFP_ATOMIC allocs (see
>    http://marc.info/?l=linux-kernel&m=118710595617696&w=2). Atomic
>    reclaim can then also put pages onto the zone laundry lists from where
>    it is going to be picked up and written out by kswapd ASAP. This one
>    may be tricky so maybe keep this separate.

That sounds a bit risky, there are latency considerations here to
make, GFP_ATOMIC will run with irq locally disabled and it may hang
for indefinite amount of time (O(N)). So irq latency may break and it
may be better to lose a packet once in a while than to hang
interrupts. If you want to do this you'd probably need to add a new
GFP_ATOMIC_RECLAIM or similar.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

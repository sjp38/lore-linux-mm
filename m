Date: Mon, 25 Sep 2000 03:31:28 +0200
From: Andrea Arcangeli <andrea@suse.de>
Subject: Re: [patch] vmfixes-2.4.0-test9-B2
Message-ID: <20000925033128.A10381@athlon.random>
References: <20000924231240.D5571@athlon.random> <Pine.LNX.4.10.10009241646560.974-100000@penguin.transmeta.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.10.10009241646560.974-100000@penguin.transmeta.com>; from torvalds@transmeta.com on Sun, Sep 24, 2000 at 05:09:40PM -0700
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Linus Torvalds <torvalds@transmeta.com>
Cc: Ingo Molnar <mingo@elte.hu>, Rik van Riel <riel@conectiva.com.br>, Roger Larsson <roger.larsson@norran.net>, MM mailing list <linux-mm@kvack.org>, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Sun, Sep 24, 2000 at 05:09:40PM -0700, Linus Torvalds wrote:
> [..] as with the
> shm_swap() thing this is probably something we do want to fix eventually.

both shm_swap and regular rw_swap_cache have the same deadlock problematic
w.r.t. __GFP_IO. We could do that on a raw device, but if we swap on top of the
filesystem then we could have deadlock problems again.  Really since with the
swapfile blocks are just allocated with ext2 we should not deadlock (but maybe
some other fs have a lock_super in the get_block path anyway). Thus it's safer
not to swapout anything when __GFP_IO is not set.

Also some linux/net/* code is using (or better abusing since __GFP_IO
originally was only meant as a deadlock avoidance thing not a thing
to only shrink the clean cache) GFP_BUFFER to not block (so actually
we would hurt networking too by causing _any_ kind of block in a GFP_BUFFER
allocation).

It would been better to introduce a new flag for allocations that must not
block for latency requirements but that wants still to shrink the clean cache
(instead of finishing the atomic queue). This is trivially fixable grepping
for GFP_BUFFER.

> The icache shrinker probably has similar problems with clear_inode.

Yep. And it sure does blocking I/O because it have to sync the dirty
inodes.

> I suspect that it might be a good idea to try to fix this issue, because
> it will probably keep coming up otherwise. And it's likely to be fairly
> easily debugged, by just making getblk() have some debugging code that
> basically says something like
> 
> 	lock_super()
> 	{
> 		.. do the lock ..
> +		current->super_locked++;
> 	}
> 
> 	unlock_super()
> 	{
> +		if (current->super_locked < 1)
> +			BUG();
> +		current->super_locked--;
> 		.. do the unlock ..
> 	}
> 
> 	getblk()
> 	{
> +		if (current->super_locked)
> +			BUG();
> 		.. do the getblk ..
> 	}

BTW (running offtopic), I collected such information in 2.2.x too (but for
another reason).

	ftp://ftp.us.kernel.org/pub/linux/kernel/people/andrea/patches/v2.2/2.2.18pre9/VM-global-2.2.18pre9-6.bz2

I trapped all the down on the inode semaphore in the same way (I called it
current->fs_locks for both down and superlock).

I'm using such information to know if there's any lock held in the context
of the task to know if I can do I/O or not without risking to deadlock
on any inode semaphore or on any superblock lock.

With that change I could then also use GFP_KERNEL in getblk in 2.2.x (I admit
at first I did that :), but then I preferred to stay on the safe side
for things like loop that _have_ to work in 2.2.x :).

So now we know when we can writepage a dirty MAP_SHARED page in swap_out and we
do it from the task that is trying to allocate memory, so the task that is
trying to allocate memory will block waiting some dirty buffer to be written in
writepage->wakeup_bdflush(1).

In 2.2.x (as we do in 2.4.x) we _need_ to writeout the page ourself from
swapout (not async queueing into kpiod) because kpiod is completly asynchrous
and so without this change GFP was returning, we was allocating memory again,
and we was entering GFP again, all at fast rate.  In the meantime kpiod was
still blocked in mark_buffer_dirty->wakeup_bdflush(1) and then the tasks
allocating memory (who thought to have done some progress because it queued
many pages into kpiod) was getting killed.

Of course then I also killed kpiod since it wasn't necessary anymore and now
MAP_SHARED semgments doesn't kill tasks anymore.

> and just making it a new rule that you cannot call getblk() with any locks
> held.

Yes I see it would certainly trap the deadlock cases.

> (the superblock lock is quite contended right now, and the reason for that

Right (on large fs is going to be quite painful for scalability) and the
BUG would have the benefit of partly solving it.

I'm thinking that dropping the superblock lock completly wouldn't be much more
difficult than this mid stage.  The only cases where we block in critical
sections protected by the superblock lock is in getblk/bread (bread calls
getblk) and ll_rw_block and mark_buffer_dirty.  Once we drop the lock for the
first cases it should not be more difficult to drop it completly.

Not sure if this is the right moment for those changes though, I'm not worried
about ext2 but about the other non-netoworked fses that nobody uses regularly.

Andrea
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/

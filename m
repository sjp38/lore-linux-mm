Date: Thu, 29 Jul 2004 20:58:54 +0100 (BST)
From: Hugh Dickins <hugh@veritas.com>
Subject: Re: Scaling problem with shmem_sb_info->stat_lock
In-Reply-To: <Pine.SGI.4.58.0407281707370.33392@kzerza.americas.sgi.com>
Message-ID: <Pine.LNX.4.44.0407292006290.1096-100000@localhost.localdomain>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Brent Casavant <bcasavan@sgi.com>
Cc: William Lee Irwin III <wli@holomorphy.com>, Andrew Morton <akpm@osdl.org>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, 28 Jul 2004, Brent Casavant wrote:
> 
> With Hugh's fix, the problem has now moved to other areas -- I consider
> the stat_lock issue solved.

Me too, though I haven't passed those changes up the chain yet:
waiting to see what happens in this next round.

I didn't look into Andrew's percpu_counters in any depth:
once I'd come across PERCPU_ENOUGH_ROOM 32768 I concluded that
percpu space is a precious resource that we should resist depleting
per mountpoint; but if ext2/3 use it, I guess tmpfs could as well.
Revisit another time if NULL sbinfo found wanting.

> Now I'm running up against the shmem_inode_info
> lock field.  A per-CPU structure isn't appropriate here because what it's
> mostly protecting is the inode swap entries, and that isn't at all amenable
> to a per-CPU breakdown (i.e. this is real data, not statistics).

Jack Steiner's question was, why is this an issue on 2.6 when it
wasn't on 2.4?  Perhaps better parallelism elsewhere in 2.6 has
shifted contention to here?  Or was it an issue in 2.4 after all?

I keep wondering: why is contention on shmem_inode_info->lock a big
deal for you, but not contention on inode->i_mapping->tree_lock?

Once the shm segment or /dev/zero mapping pages are allocated, info->lock
shouldn't be used at all until you get to swapping - and I hope it's safe
to assume that someone with 512 cpus isn't optimizing for swapping.

It's true that when shmem_getpage is allocating index and data pages,
it dips into and out of info->lock several times: I expect that does
exacerbate the bouncing.  Earlier in the day I was trying to rewrite
it a little to avoid that, for you to investigate if it makes any
difference; but abandoned that once I realized it would mean
memclearing pages inside the lock, something I'd much rather avoid.

> The "obvious" fix is to morph the code so that the swap entries can be
> updated in parallel to eachother and in parallel to the other miscellaneous
> fields in the shmem_inode_info structure.

Why are all these threads allocating to the inode at the same time?

Are they all trying to lock down the same pages?  Or is each trying
to fault in a different page (as your "parallel" above suggests)?

Why doesn't the creator of the shm segment or /dev/zero mapping just
fault in all the pages before handing over to the other threads?

But I may well have entirely the wrong model of what's going on.
Could you provide a small .c testcase to show what it's actually
trying to do when the problem manifests?  I don't have many cpus
to reproduce it on, but it should help to provoke a solution.

And/or profiles.

(Once we've shifted the contention from info->lock to mapping->tree_lock,
it'll be interesting but not conclusive to hear how 2.6.8 compares with
2.6.8-mm: since mm is currently using read/write_lock_irq on tree_lock.)

Thanks,
Hugh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>

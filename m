Date: Thu, 29 Jul 2004 18:00:30 -0700
From: William Lee Irwin III <wli@holomorphy.com>
Subject: Re: Scaling problem with shmem_sb_info->stat_lock
Message-ID: <20040730010030.GY2334@holomorphy.com>
References: <Pine.SGI.4.58.0407281707370.33392@kzerza.americas.sgi.com> <Pine.LNX.4.44.0407292006290.1096-100000@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.44.0407292006290.1096-100000@localhost.localdomain>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Hugh Dickins <hugh@veritas.com>
Cc: Brent Casavant <bcasavan@sgi.com>, Andrew Morton <akpm@osdl.org>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, 28 Jul 2004, Brent Casavant wrote:
>> With Hugh's fix, the problem has now moved to other areas -- I consider
>> the stat_lock issue solved.

On Thu, Jul 29, 2004 at 08:58:54PM +0100, Hugh Dickins wrote:
> Me too, though I haven't passed those changes up the chain yet:
> waiting to see what happens in this next round.
> I didn't look into Andrew's percpu_counters in any depth:
> once I'd come across PERCPU_ENOUGH_ROOM 32768 I concluded that
> percpu space is a precious resource that we should resist depleting
> per mountpoint; but if ext2/3 use it, I guess tmpfs could as well.
> Revisit another time if NULL sbinfo found wanting.

__alloc_percpu() doesn't seem to dip into this space; it rather seems
to use kmem_cache_alloc_node(), which shouldn't be subject to any
limitations beyond the nodes' memory capacities, and PERCPU_ENOUGH_ROOM
seems to be primarily for statically-allocated per_cpu data. This may
very well be the headroom reserved for modules; I've not tracked the
per_cpu internals for a very long time, as what little I had to
contribute there was dropped.


On Wed, 28 Jul 2004, Brent Casavant wrote:
>> Now I'm running up against the shmem_inode_info
>> lock field.  A per-CPU structure isn't appropriate here because what it's
>> mostly protecting is the inode swap entries, and that isn't at all amenable
>> to a per-CPU breakdown (i.e. this is real data, not statistics).

On Thu, Jul 29, 2004 at 08:58:54PM +0100, Hugh Dickins wrote:
> Jack Steiner's question was, why is this an issue on 2.6 when it
> wasn't on 2.4?  Perhaps better parallelism elsewhere in 2.6 has
> shifted contention to here?  Or was it an issue in 2.4 after all?
> I keep wondering: why is contention on shmem_inode_info->lock a big
> deal for you, but not contention on inode->i_mapping->tree_lock?

inode->i_mapping->tree_lock is where I've observed the majority of the
lock contention from operating on tmpfs files in parallel. I still need
to write up the benchmark results for the rwlock in a coherent fashion.
One thing I need to do there to support all this is to discover if the
kernel-intensive workloads on smaller machines actually do find
shmem_inode_info->lock to be an issue after mapping->tree_lock is made
an rwlock, as they appear to suffer from mapping->tree_lock first,
unlike the SGI workloads if these reports are accurate.


On Thu, Jul 29, 2004 at 08:58:54PM +0100, Hugh Dickins wrote:
> Once the shm segment or /dev/zero mapping pages are allocated, info->lock
> shouldn't be used at all until you get to swapping - and I hope it's safe
> to assume that someone with 512 cpus isn't optimizing for swapping.
> It's true that when shmem_getpage is allocating index and data pages,
> it dips into and out of info->lock several times: I expect that does
> exacerbate the bouncing.  Earlier in the day I was trying to rewrite
> it a little to avoid that, for you to investigate if it makes any
> difference; but abandoned that once I realized it would mean
> memclearing pages inside the lock, something I'd much rather avoid.

The workloads I'm running actually do encounter small amounts of
swap IO under higher loads. I'm not terribly concerned with this as
the "fix" that would be used in the field is adding more RAM, and
it's just generally not how those workloads are meant to be run, but
rather only a desperation measure.


On Wed, 28 Jul 2004, Brent Casavant wrote:
>> The "obvious" fix is to morph the code so that the swap entries can be
>> updated in parallel to eachother and in parallel to the other miscellaneous
>> fields in the shmem_inode_info structure.

On Thu, Jul 29, 2004 at 08:58:54PM +0100, Hugh Dickins wrote:
> Why are all these threads allocating to the inode at the same time?
> Are they all trying to lock down the same pages?  Or is each trying
> to fault in a different page (as your "parallel" above suggests)?
> Why doesn't the creator of the shm segment or /dev/zero mapping just
> fault in all the pages before handing over to the other threads?
> But I may well have entirely the wrong model of what's going on.
> Could you provide a small .c testcase to show what it's actually
> trying to do when the problem manifests?  I don't have many cpus
> to reproduce it on, but it should help to provoke a solution.
> And/or profiles.
> (Once we've shifted the contention from info->lock to mapping->tree_lock,
> it'll be interesting but not conclusive to hear how 2.6.8 compares with
> 2.6.8-mm: since mm is currently using read/write_lock_irq on tree_lock.)

If it's a particularly large area, this may be for incremental
initialization so there aren't very long delays during program startup.


-- wli
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>

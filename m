Date: Tue, 13 Jul 2004 15:50:15 -0700
From: William Lee Irwin III <wli@holomorphy.com>
Subject: Re: Scaling problem with shmem_sb_info->stat_lock
Message-ID: <20040713225015.GM21066@holomorphy.com>
References: <Pine.LNX.4.44.0407132113350.8577-100000@localhost.localdomain> <Pine.SGI.4.58.0407131612070.111843@kzerza.americas.sgi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <Pine.SGI.4.58.0407131612070.111843@kzerza.americas.sgi.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Brent Casavant <bcasavan@sgi.com>
Cc: Hugh Dickins <hugh@veritas.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, 13 Jul 2004, Hugh Dickins wrote:
>> Though wli's per-cpu idea was sensible enough, converting to that
>> didn't appeal to me very much.  We only have a limited amount of
>> per-cpu space, I think, but an indefinite number of tmpfs mounts.
>> Might be reasonable to allow per-cpu for 4 or them (the internal
>> one which is troubling you, /dev/shm, /tmp and one other).  Tiresome.

On Tue, Jul 13, 2004 at 04:35:25PM -0500, Brent Casavant wrote:
> Per-CPU has the problem that the CPU on which you did a free_blocks++
> might not be the same one where you do a free_blocks--.  Bleh.
> Maybe using a hash indexed on some tid bits (pun unintended, but funny
> nevertheless) might work?  But of course this suffers from the same
> class of problem as mentioned in the previous paragraph.

This is a non-issue. Full-fledged implementations of per-cpu counters
must be either insensitive to or explicitly handle underflow. There are
several different ways to do this; I think there's one in a kernel
header that's an example of batched spills to and borrows from a global
counter (note that the batches are O(NR_CPUS); important for reducing
the arrival rate).  Another way would be to steal from other cpus
analogous to how the scheduler steals tasks. There's one in the
scheduler I did, rq->nr_uninterruptible, that is insensitive to
underflow; the values are only examined in summation, used for load
average calculations. It makes some sense, too, as sleeping tasks
aren't actually associated with runqueues, and so the per-runqueue
values wouldn't be meaningful.

I guess since that's not how it's being addressed anyway, it's academic.
It may make some kind of theoretical sense for e.g. databases on
similarly large cpu count systems, but in truth machines sensitive to
this issue are just not used for such and would have far worse and more
severe performance problems elsewhere, so again, why bother?


On Tue, 13 Jul 2004, Hugh Dickins wrote:
>> But please don't call the new one SHMEM_NOACCT: ACCT or ACCOUNT refers
>> to the security_vm_enough_memory/vm_unacct_memory stuff throughout,
>> and _that_ accounting does still apply to these /dev/zero files.
>> Hmm, I was about to suggest SHMEM_NOSBINFO,
>> but how about really no sbinfo, just NULL sbinfo?

On Tue, Jul 13, 2004 at 04:35:25PM -0500, Brent Casavant wrote:
> If you'd like me to try that, I sure can.  The only problem is that
> I'm having a devil of a time figuring out where the struct super_block
> comes from for /dev/null -- or heck, if it's even distinct from any
> others.  And the relationship between /dev/null and /dev/shm is still
> quite fuzzy as well.  Oh the joy of being new to a chunk of code...

There is a global "anonymous mount" of tmpfs used to implement e.g.
MAP_SHARED mappings of /dev/zero, SysV shm, etc. This mounted fs is
not associated with any point in the fs namespace. So it's distinct
from all other mounted instances that are e.g. associated with
mountpoints in the fs namespace, and potentially even independent
kern_mount()'d instances, though I know of no others apart from the one
used in shmem.c, and they'd be awkward to arrange (static funcs & vars).
This is just a convenience for setting up unlinked inodes etc. and can
in principle be done without, which would remove even more forms of
global state maintenance.


-- wli
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>

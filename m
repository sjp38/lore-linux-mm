Date: Wed, 28 Jul 2004 17:21:58 -0500
From: Brent Casavant <bcasavan@sgi.com>
Reply-To: Brent Casavant <bcasavan@sgi.com>
Subject: Re: Scaling problem with shmem_sb_info->stat_lock
In-Reply-To: <20040728095925.GQ2334@holomorphy.com>
Message-ID: <Pine.SGI.4.58.0407281707370.33392@kzerza.americas.sgi.com>
References: <Pine.SGI.4.58.0407131449330.111843@kzerza.americas.sgi.com>
 <Pine.LNX.4.44.0407132113350.8577-100000@localhost.localdomain>
 <20040728022625.249c78da.akpm@osdl.org> <20040728095925.GQ2334@holomorphy.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: William Lee Irwin III <wli@holomorphy.com>
Cc: Andrew Morton <akpm@osdl.org>, Hugh Dickins <hugh@veritas.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, 28 Jul 2004, William Lee Irwin III wrote:

> Hugh Dickins <hugh@veritas.com> wrote:
> >> Though wli's per-cpu idea was sensible enough, converting to that
> >>  didn't appeal to me very much.  We only have a limited amount of
> >>  per-cpu space, I think, but an indefinite number of tmpfs mounts.
>
> On Wed, Jul 28, 2004 at 02:26:25AM -0700, Andrew Morton wrote:
> > What's wrong with <linux/percpu_counter.h>?
>
> One issue with using it for the specific cases in question is that the
> maintenance of the statistics is entirely unnecessary for them.

Yeah.  Hugh solved the stat_lock issue by getting rid of the superblock
info for the internal superblock(s?) corresponding to /dev/zero and
System V shared memory.  There was no way to get at that information
anyway, so it wasn't useful to pay to keep it around.

> For the general case it may still make sense to do this. SGI will have
> to comment here, as the workloads I'm involved with are kernel intensive
> enough in other areas and generally run on small enough systems to have
> no visible issues in or around the areas described.

With Hugh's fix, the problem has now moved to other areas -- I consider
the stat_lock issue solved.  Now I'm running up against the shmem_inode_info
lock field.  A per-CPU structure isn't appropriate here because what it's
mostly protecting is the inode swap entries, and that isn't at all amenable
to a per-CPU breakdown (i.e. this is real data, not statistics).

The "obvious" fix is to morph the code so that the swap entries can be
updated in parallel to eachother and in parallel to the other miscellaneous
fields in the shmem_inode_info structure.  But this would be one *nasty*
piece of work to accomplish, much less accomplish cleanly and correctly.
I'm pretty sure my Linux skillset isn't up to the task, though it hasn't
kept me from trying.  On the upside I don't think it would significantly
impact performance on low processor-count systems, if we can manage to
do it at all.

I'm kind of hoping for a fairy godmother to drop in, wave her magic wand,
and say "Here's the quick and easy and obviously correct solution".  But
what're the chances of that :).

Thanks,
Brent

-- 
Brent Casavant             bcasavan@sgi.com        Forget bright-eyed and
Operating System Engineer  http://www.sgi.com/     bushy-tailed; I'm red-
Silicon Graphics, Inc.     44.8562N 93.1355W 860F  eyed and bushy-haired.
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>

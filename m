Date: Tue, 13 Jul 2004 21:41:34 +0100 (BST)
From: Hugh Dickins <hugh@veritas.com>
Subject: Re: Scaling problem with shmem_sb_info->stat_lock
In-Reply-To: <Pine.SGI.4.58.0407131449330.111843@kzerza.americas.sgi.com>
Message-ID: <Pine.LNX.4.44.0407132113350.8577-100000@localhost.localdomain>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Brent Casavant <bcasavan@sgi.com>
Cc: William Lee Irwin III <wli@holomorphy.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, 13 Jul 2004, Brent Casavant wrote:
> On Mon, 12 Jul 2004, Brent Casavant wrote:
> 
> > The complication with this is that we'd either need to redefine
> > i_blocks in the inode structure (somehow I don't see that happening),
> > or move that field up into the shmem_inode_info structure and make
> > the necessary code adjustments.
> 
> Better idea, maybe.
> 
> Jack Steiner suggested to me that we really don't care about accounting
> for i_blocks and free_blocks for /dev/zero mappings (question: Is he
> right?).

I think Jack's right: there's no visible mount point for df or du,
the files come ready-unlinked, nobody has an fd.

Though wli's per-cpu idea was sensible enough, converting to that
didn't appeal to me very much.  We only have a limited amount of
per-cpu space, I think, but an indefinite number of tmpfs mounts.
Might be reasonable to allow per-cpu for 4 or them (the internal
one which is troubling you, /dev/shm, /tmp and one other).  Tiresome.

Jack's perception appeals to me much more
(but, like you, I do wonder if it'll really work out in practice).

> If so, then it seems to me we could turn on a bit in the flags field
> of the shmem_inode_info structure that says "don't bother with bookkeeping
> for me".  We can then test for that flag wherever i_blocks and free_blocks
> are updated, and omit the update if appropriate.  This leaves tmpfs
> working appropriately for its "filesystem" role, and avoids the
> cacheline bouncing problem for its "shared /dev/zero mappings" role.
> 
> Assuming this is correct, I imagine I should just snag the next
> bit in the flags field (bit 0 is SHMEM_PAGEIN (== VM_READ) and
> bit 1 is SHMEM_TRUNCATE (== VM_WRITE), I'd use bit 2 for
> SHMEM_NOACCT (== VM_EXEC)) and run with this idea, right?

Yes, go ahead, though it's getting more and more embarrassing that I
started out reusing VM_ACCOUNT within shmem.c, it should now have its
own set of flags: let me tidy that up once you're done.  (Something
else I should do for your scalability is stop putting everything on
on the shmem_inodes list: that's only needed when pages are on swap.)

But please don't call the new one SHMEM_NOACCT: ACCT or ACCOUNT refers
to the security_vm_enough_memory/vm_unacct_memory stuff throughout,
and _that_ accounting does still apply to these /dev/zero files.

Hmm, I was about to suggest SHMEM_NOSBINFO,
but how about really no sbinfo, just NULL sbinfo?

Hugh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>

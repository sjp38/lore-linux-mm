Date: Tue, 13 Jul 2004 14:56:52 -0500
From: Brent Casavant <bcasavan@sgi.com>
Reply-To: Brent Casavant <bcasavan@sgi.com>
Subject: Re: Scaling problem with shmem_sb_info->stat_lock
In-Reply-To: <Pine.SGI.4.58.0407121724270.111008@kzerza.americas.sgi.com>
Message-ID: <Pine.SGI.4.58.0407131449330.111843@kzerza.americas.sgi.com>
References: <Pine.SGI.4.58.0407121546460.111008@kzerza.americas.sgi.com>
 <20040712215504.GN21066@holomorphy.com> <Pine.SGI.4.58.0407121724270.111008@kzerza.americas.sgi.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: William Lee Irwin III <wli@holomorphy.com>
Cc: hugh@veritas.com, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, 12 Jul 2004, Brent Casavant wrote:

> The complication with this is that we'd either need to redefine
> i_blocks in the inode structure (somehow I don't see that happening),
> or move that field up into the shmem_inode_info structure and make
> the necessary code adjustments.

Better idea, maybe.

Jack Steiner suggested to me that we really don't care about accounting
for i_blocks and free_blocks for /dev/zero mappings (question: Is he
right?).

If so, then it seems to me we could turn on a bit in the flags field
of the shmem_inode_info structure that says "don't bother with bookkeeping
for me".  We can then test for that flag wherever i_blocks and free_blocks
are updated, and omit the update if appropriate.  This leaves tmpfs
working appropriately for its "filesystem" role, and avoids the
cacheline bouncing problem for its "shared /dev/zero mappings" role.

Assuming this is correct, I imagine I should just snag the next
bit in the flags field (bit 0 is SHMEM_PAGEIN (== VM_READ) and
bit 1 is SHMEM_TRUNCATE (== VM_WRITE), I'd use bit 2 for
SHMEM_NOACCT (== VM_EXEC)) and run with this idea, right?

Thoughts?
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

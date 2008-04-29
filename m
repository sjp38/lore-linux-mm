Date: Tue, 29 Apr 2008 20:06:01 +1000
From: David Chinner <dgc@sgi.com>
Subject: correct use of vmtruncate()?
Message-ID: <20080429100601.GO108924158@sgi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-fsdevel <linux-fsdevel@vger.kernel.org>
Cc: linux-mm <linux-mm@kvack.org>, xfs-oss <xfs@oss.sgi.com>
List-ID: <linux-mm.kvack.org>

Folks,

It appears to me that vmtruncate() is not used correctly in
block_write_begin() and friends. The short summary is that it
appears that the usage in these functions implies that vmtruncate()
should cause truncation of blocks on disk but no filesystem
appears to do this, nor does the documentation imply they should.

The longer story now.

For as long as I've worked on XFS we've had intermittent ASSERT
failures when tearing down inodes or doing direct I/O where inodes
have delayed allocation extents still attached to them where they
shouldn't.  Because the ASSERT failure has occurred so long after
the problem and it only happens once every blue moon, it's been
extremely difficult to track down.

Lucky for me, I had my main test box start to fall over the problem
reliably last week. [ I say lucky, because a customer started to
trip over a different symptom of the same problem reliably about a
week before that and I have no idea what changed in my code base
to make it trigger on every run. ]

The problem stems around this piece of the debug trace pulled
from KDB after the system died with an ASSERT:

PAGE INVALIDATE:
ip 0xe0000038805cc600 inode 0xe0000038805bb980 page 0xa07fffffdf8b5180
pgoff 0x0 di_size 0x026b000 isize 0x026b000 offset 0x0320000
delalloc 1 unmapped 0 unwritten 0 pid 2930
^^^^^^^^^^

PAGE RELEASE:
ip 0xe0000038805cc600 inode 0xe0000038805bb980 page 0xa07fffffdf8b5180
pgoff 0x0 di_size 0x026b000 isize 0x026b000 offset 0x0320000
delalloc 0 unmapped 1 unwritten 0 pid 2930
^^^^^^^^^^

When ->invalidate_page is called, we have a delalloc extent on the page,
but by the time ->release_page is called, the delalloc extent is gone.
The code path is:

        ->invalidate_page
          xfs_vm_invalidatepage
            block_invalidatepage
>>>>>         discard_buffer
              try_to_release_page
                ->release_page
                  xfs_vm_releasepage

The key point here is in this code path, discard buffer is called
on all the buffers on the page being invalidated. That is, we do this
to them:

static void discard_buffer(struct buffer_head * bh)
{
        lock_buffer(bh);
        clear_buffer_dirty(bh);
        bh->b_bdev = NULL;
        clear_buffer_mapped(bh);
        clear_buffer_req(bh);
        clear_buffer_new(bh);
        clear_buffer_delay(bh);
        clear_buffer_unwritten(bh);
        unlock_buffer(bh);
}

We *clear* the delalloc state from the page, and hence we lose the
delalloc state before we get to xfs_vm_releasepage(). it also makes
the buffers appear unmapped, so just removing the
clear_buffer_delay(bh) is not sufficient to enable us to know this
is a delalloc buffer without changing other code.

The result is that xfs_vm_releasepage() is unable to convert those
extents to real extents (beyond eof) because it can't tell they
exist by looking at the bufferhead state. Hence if we then extend
the file again later we can trip over these delalloc extents. If
it's buffered I/O, it's ok. If it's inode reclaim, then we ASSERT
fail. If it's direct I/O, we BUG_ON() in __xfs_get_blocks. If it's
hole punching, then we ASSERT fail there. Pain, pain and more pain.

IOWs, the current path through vmtruncate into XFS and releasing the
page does no truncation at all - in fact ->releasepage *allocates*
delayed extents as it's semantics imply that the caller will write
the page out and needs the blocks allocated.

The question I was asking now was "how the hell do we get to
->invalidate_page call with an active extent without having a
matching extent removal operation from the filesystem to clean
up?"

The key to solving the problem came from this ASSERT failure on a very
new inode during a hole punch:

Assertion failed: imap.br_startblock != DELAYSTARTBLOCK, file: fs/xfs/xfs_vnodeops.c, line: 3619
....
 [<a0000001003f7920>] assfail+0x60/0x80
                                sp=e00000381a0dfc40 bsp=e00000381a0d10b8
 [<a0000001003cbdf0>] xfs_zero_remaining_bytes+0x2f0/0x560
                                sp=e00000381a0dfc40 bsp=e00000381a0d1050
 [<a0000001003cc7d0>] xfs_free_file_space+0x770/0xbc0
                                sp=e00000381a0dfc90 bsp=e00000381a0d0fc8
 [<a0000001003d1ac0>] xfs_change_file_space+0x320/0x6a0
                                sp=e00000381a0dfd10 bsp=e00000381a0d0f78
 [<a0000001003e9630>] xfs_ioc_space+0x1b0/0x1e0
                                sp=e00000381a0dfdb0 bsp=e00000381a0d0f30
 [<a0000001003ebff0>] xfs_ioctl+0x6b0/0x1260
                                sp=e00000381a0dfde0 bsp=e00000381a0d0ee0
 [<a0000001003e7db0>] xfs_file_ioctl+0x50/0xe0
                                sp=e00000381a0dfe10 bsp=e00000381a0d0e98
 [<a0000001001805f0>] vfs_ioctl+0x90/0x180
                                sp=e00000381a0dfe10 bsp=e00000381a0d0e58
 [<a000000100181060>] do_vfs_ioctl+0x980/0xa00
                                sp=e00000381a0dfe10 bsp=e00000381a0d0e10
 [<a000000100181140>] sys_ioctl+0x60/0xc0
                                sp=e00000381a0dfe20 bsp=e00000381a0d0d90
....

And the trace:

[1]kdb> xexlist 0xe000003880774e00
inode 0xe000003880774e00 df extents 0xe000003880774e80 nextents 0x1
0: startoff 41 startblock NULLSTARTBLOCK(5) blockcount 1 flag 0
[1]kdb> xrwtrc 0xe000003880774e00
i_rwtrace = 0xe00000381ca8d4a0
WRITE ENTER:
ip 0xe000003880774e00 size 0x00 ptr 0xe00000381a0dfd30 size 1
io offset 0x029a61 ioflags 0x1 new size 0x048fa3 pid 2939

IOMAP WRITE ENTER:
ip 0xe000003880774e00 size 0x00 offset 0x029000 count 0x1000
io new size 0x048fa3 pid=2939

ALLOC MAP:
ip 0xe000003880774e00 size 0x00 offset 0x029000 count 0x1000
bmapi flags 0x2 <write > iomap off 0x0199a35 delta 0x809f2a00 bsize 0x4815a972 bno 0x0
imap off 0x29 count 0x1 block 0xffffffff

IOMAP WRITE ENTER:
ip 0xe000003880774e00 size 0x00 offset 0x02a000 count 0x1000
io new size 0x048fa3 pid=2939

IOMAP WRITE NOSPACE:
ip 0xe000003880774e00 size 0x00 offset 0x02a000 count 0x1000
io new size 0x048fa3 pid=2939

IOMAP WRITE NOSPACE:
ip 0xe000003880774e00 size 0x00 offset 0x02a000 count 0x1000
io new size 0x048fa3 pid=2939

IOMAP WRITE NOSPACE:
ip 0xe000003880774e00 size 0x00 offset 0x02a000 count 0x1000
io new size 0x048fa3 pid=2939

IOMAP WRITE NOSPACE:
ip 0xe000003880774e00 size 0x00 offset 0x02a000 count 0x1000
io new size 0x048fa3 pid=2939

PAGE INVALIDATE:
ip 0xe000003880774e00 inode 0xe000003880767000 page 0xa07fffffdf875a00
pgoff 0x0 di_size 0x00 isize 0x00 offset 0x020000
delalloc 1 unmapped 0 unwritten 0 pid 2939

PAGE RELEASE:
ip 0xe000003880774e00 inode 0xe000003880767000 page 0xa07fffffdf875a00
pgoff 0x0 di_size 0x00 isize 0x00 offset 0x020000
delalloc 0 unmapped 1 unwritten 0 pid 2939

-----

And a strategically placed dump_stack() call showed
invalidate_page() had come from vmtruncate() via
__block_prepare_write().

IOWs, this trace says that xfs_get_blocks() has returned ENOSPC to
__block_prepare_write() after the first buffer on the page has been
set up for delayed allocation. As a result of this write being
beyond the current EOF, block_begin_write() sees this error and
decides to roll back the entire change by truncating the addres
space beyond the old EOF with a call to vmtruncate().

But, as we've already seen, vmtruncate() does not cause removal of
blocks in XFS; only the removal of pages and buffers from the
mapping. IOWs, we've just leaked a delayed allocation extent and
left a landmine that we can step on later.

My understanding  is that XFS is behaving correctly with respect to
->invalidate_page and vmtruncate. Looking at the only relevant hit
on vmtruncate() in the Documentation directory, filesystems/Locking
says:

|         ->truncate() is never called directly - it's a callback, not a
| method. It's called by vmtruncate() - library function normally used by
| ->setattr(). Locking information above applies to that call (i.e. is
| inherited from ->setattr() - vmtruncate() is used when ATTR_SIZE had been
| passed).

This implies that vmtruncate() should only be called from within
filesystems when the size of the inode is being changed. In XFS, the
vmtruncate() call is closely followed by the extent removal
transactions, and they are effectively done as an atomic operation
due to the locks that are held at the time. So AFAICT XFS is doing
the right thing here...

[ Indeed, if vmtruncate() were to do the extent removal at this
point in time, XFS would totally suck at removing large files as it
would need to do a transaction per page as opposed to one every two
extents being removed. ]

Hence it seems to me that calling vmtruncate() directly from any
context other than from with a filesystem whilst a size change is
being executed is incorrect use of vmtruncate(). i.e. all the
*write_begin implementations that are used by filesystems that
support multiple blocks per page are broken because they are relying
on vmtruncate() to remove blocks that are allocated via get_block
callouts before the failure occurred.

The obvious fix for this is that block_write_begin() and
friends should be calling ->setattr to do the truncation and hence
follow normal convention for truncating blocks off an inode.
However, even that appears to have thorns. e.g. in XFS we hold the
iolock exclusively when we call block_write_begin(), but it is not
held in all cases where ->setattr is currently called. Hence calling
->setattr from block_write_begin in this failure case will deadlock
unless we also pass a "nolock" flag as well. XFS already
supports this (e.g. see the XFS fallocate implementation) but no other
filesystem does (some probably don't need to).

Hence I'm not sure what the best way to fix this is. I don't want to
have to duplicate all the generic code just to be able to issue a
correct, non-deadlocking truncate operation. I don't want to have to
commit the hack I already have for ->invalidate page that does:

	xfs_count_page_state(page, &delalloc, ....)
	if (delalloc && !PageUptodate(page)) {
		/*
		 * set up and call xfs_bumapi() to remove the delalloc
		 * extents on this page.
		 */
		.....
	}
	block_invalidatepage(page, offset);

because it has negative performance impact on several different
common workloads and is completely unnecessary except for this
rare error case from block_write_begin(). Since it's impossible to
uniquely identify the case in ->invalidate_page, the above hack
is as good as I can see can be done.

All in all, I'd prefer the ->setattr() with a "ATTR_NO_LOCK" flag
solution as the simplest way to solve this, but maybe there's
something that I've missed. Comments, suggestions are welcome....

Cheers,

Dave.
-- 
Dave Chinner
Principal Engineer
SGI Australian Software Group

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

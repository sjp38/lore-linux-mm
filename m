Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id B0B196B003D
	for <linux-mm@kvack.org>; Tue, 24 Mar 2009 11:22:46 -0400 (EDT)
From: Nick Piggin <nickpiggin@yahoo.com.au>
Subject: Re: ftruncate-mmap: pages are lost after writing to mmaped file.
Date: Wed, 25 Mar 2009 02:35:01 +1100
References: <604427e00903181244w360c5519k9179d5c3e5cd6ab3@mail.gmail.com> <200903241844.22851.nickpiggin@yahoo.com.au> <20090324033204.64f3da9d.akpm@linux-foundation.org>
In-Reply-To: <20090324033204.64f3da9d.akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Message-Id: <200903250235.02816.nickpiggin@yahoo.com.au>
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Jan Kara <jack@suse.cz>, "Martin J. Bligh" <mbligh@mbligh.org>, linux-ext4@vger.kernel.org, Ying Han <yinghan@google.com>, Linus Torvalds <torvalds@linux-foundation.org>, linux-kernel <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, guichaz@gmail.com, Alex Khesin <alexk@google.com>, Mike Waychison <mikew@google.com>, Rohit Seth <rohitseth@google.com>, Peter Zijlstra <a.p.zijlstra@chello.nl>
List-ID: <linux-mm.kvack.org>

On Tuesday 24 March 2009 21:32:04 Andrew Morton wrote:
> On Tue, 24 Mar 2009 18:44:21 +1100 Nick Piggin <nickpiggin@yahoo.com.au> 
wrote:
> > On Friday 20 March 2009 03:46:39 Jan Kara wrote:
> > > On Fri 20-03-09 02:48:21, Nick Piggin wrote:
> > > > Holding mapping->private_lock over the __set_page_dirty should
> > > > fix it, although I guess you'd want to release it before calling
> > > > __mark_inode_dirty so as not to put inode_lock under there. I
> > > > have a patch for this if it sounds reasonable.
> > >
> > >   Yes, that seems to be a bug - the function actually looked suspitious
> > > to me yesterday but I somehow convinced myself that it's fine. Probably
> > > because fsx-linux is single-threaded.
> >
> > After a whole lot of chasing my own tail in the VM and buffer layers,
> > I think it is a problem in ext2 (and I haven't been able to reproduce
> > with ext3 yet, which might lend weight to that, although as we have
> > seen, it is very timing dependent).
> >
> > That would be slightly unfortunate because we still have Jan's ext3
> > problem, and also another reported problem of corruption on ext3 (on
> > brd driver).
> >
> > Anyway, when I have reproduced the problem with the test case, the
> > "lost" writes are all reported to be holes. Unfortunately, that doesn't
> > point straight to the filesystem, because ext2 allocates blocks in this
> > case at writeout time, so if dirty bits are getting lost, then it would
> > be normal to see holes.
> >
> > I then put in a whole lot of extra infrastructure to track metadata about
> > each struct page (when it was last written out, when it last had the
> > number of writable ptes reach 0, when the dirty bits were last cleared
> > etc). And none of the normal asertions were triggering: eg. when any page
> > is removed from pagecache (except truncates), it has always had all its
> > buffers written out *after* all ptes were made readonly or unmapped. Lots
> > of other tests and crap like that.
> >
> > So I tried what I should have done to start with and did an e2fsck after
> > seeing corruption. Yes, it comes up with errors.
>
> Do you recall what the errors were?

OK, after running several tests in parallel and having 3 of them
blow up, I unmounted the fs (so error-case files are still intact).

# e2fsck -fn /dev/ram0
e2fsck 1.41.3 (12-Oct-2008)
Pass 1: Checking inodes, blocks, and sizes
Inode 16, i_blocks is 131594, should be 131566.  Fix? no

Inode 18, i_blocks is 131588, should be 131576.  Fix? no

Inode 21, i_blocks is 131594, should be 131552.  Fix? no

Pass 2: Checking directory structure
Pass 3: Checking directory connectivity
Pass 4: Checking reference counts
Pass 5: Checking group summary information
Block bitmap differences:  -(628209--628220) -628231 -628233 -(638751--638755) 
-638765 -(646271--646295) -(646301--646304) -647609 -(651501--651505) -651509 
-(651719--651726) -(651732--651733) -(665666--665670)
Fix? no


/dev/ram0: ********** WARNING: Filesystem still has errors **********

/dev/ram0: 21/229376 files (4.8% non-contiguous), 407105/3670016 blocks

ino 16, 18, 21 of course are the files with errors.


inode 18 is the simplest case with just one hole, so let's look at that:

#hexdump file9
0000000 ffff ffff ffff ffff ffff ffff ffff ffff
*
3c8c000 0000 0000 0000 0000 0000 0000 0000 0000
*
3c8d400 ffff ffff ffff ffff ffff ffff ffff ffff
*
4000000


Let's take a look at our hole then:

#./bmap file9  // bmap is modified to print hex offsets
[... lots of stuff ...]
3c82000-3c82c00: 26fd0400-26fd1000 (1000)
3c83000-3c83c00: 26fd3400-26fd4000 (1000)
3c84000-3c84c00: 26fc9c00-26fca800 (1000)
3c85000-3c85c00: 26fcc400-26fcd000 (1000)
3c86000-3c86c00: 26fcf400-26fd0000 (1000)
3c87000-3c87c00: 26fd2400-26fd3000 (1000)
3c88000-3c88c00: 26fd5400-26fd6000 (1000)
3c89000-3c8bc00: 26fd7400-26fda000 (3000)
3c8c000-3c8c000: 0-0 (400)
3c8c400-3c8c400: 0-0 (400)
3c8c800-3c8c800: 0-0 (400)
3c8cc00-3c8cc00: 0-0 (400)
3c8d000-3c8d000: 0-0 (400)
3c8d400-3c8dc00: 26fcb800-26fcc000 (c00)
3c8e000-3c8ec00: 26fce400-26fcf000 (1000)
3c8f000-3c8fc00: 26fd1400-26fd2000 (1000)
3c90000-3c99c00: 27924400-2792e000 (a000)
3c9a000-3c9ac00: 2792f000-2792fc00 (1000)
3c9b000-3c9bc00: 27931000-27931c00 (1000)
3c9c000-3c9cc00: 27933000-27933c00 (1000)
3c9d000-3c9dc00: 27935000-27935c00 (1000)
3c9e000-3c9ec00: 27938000-27938c00 (1000)
3c9f000-3c9fc00: 2793a000-2793ac00 (1000)
[... lots more stuff ...]

3.5G filesystem image bzip2s down to 500K if anybody wants it I
can send it privately.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

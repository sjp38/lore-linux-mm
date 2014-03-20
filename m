Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pb0-f53.google.com (mail-pb0-f53.google.com [209.85.160.53])
	by kanga.kvack.org (Postfix) with ESMTP id D10216B025C
	for <linux-mm@kvack.org>; Thu, 20 Mar 2014 19:55:17 -0400 (EDT)
Received: by mail-pb0-f53.google.com with SMTP id rp16so1639185pbb.26
        for <linux-mm@kvack.org>; Thu, 20 Mar 2014 16:55:17 -0700 (PDT)
Received: from ipmail06.adl6.internode.on.net (ipmail06.adl6.internode.on.net. [2001:44b8:8060:ff02:300:1:6:6])
        by mx.google.com with ESMTP id vu10si2391548pbc.482.2014.03.20.16.55.15
        for <linux-mm@kvack.org>;
        Thu, 20 Mar 2014 16:55:16 -0700 (PDT)
Date: Fri, 21 Mar 2014 10:55:08 +1100
From: Dave Chinner <david@fromorbit.com>
Subject: Re: [PATCH v6 07/22] Replace the XIP page fault handler with the DAX
 page fault handler
Message-ID: <20140320235508.GO7072@dastard>
References: <1393337918-28265-1-git-send-email-matthew.r.wilcox@intel.com>
 <1393337918-28265-8-git-send-email-matthew.r.wilcox@intel.com>
 <1393609771.6784.83.camel@misato.fc.hp.com>
 <20140228202031.GB12820@linux.intel.com>
 <20140302233027.GR30131@dastard>
 <alpine.OSX.2.00.1403031549110.34680@scrumpy>
 <20140304005624.GB6851@dastard>
 <20140320193844.GB5705@linux.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20140320193844.GB5705@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Matthew Wilcox <willy@linux.intel.com>
Cc: Ross Zwisler <ross.zwisler@linux.intel.com>, Toshi Kani <toshi.kani@hp.com>, Matthew Wilcox <matthew.r.wilcox@intel.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org

On Thu, Mar 20, 2014 at 03:38:44PM -0400, Matthew Wilcox wrote:
> On Tue, Mar 04, 2014 at 11:56:25AM +1100, Dave Chinner wrote:
> > > get_block_t is used by the VFS to ask filesystem to translate logical
> > > blocks within a file to sectors on a block device.
> > > 
> > > typedef int (get_block_t)(struct inode *inode, sector_t iblock,
> > >                         struct buffer_head *bh_result, int create);
> > > 
> > > get_block() must not be called simultaneously with the create flag set
> > > for overlapping extents *** or is/was this a bug in ext2? ***
> > 
> > Why not? The filesystem is responsible for serialising such requests
> > internally, or if it can't handle them preventing them from
> > occurring. XFS has allowed this to occur with concurrent overlapping
> > direct IO writes for a long time. In the situations where we need
> > serialisation to avoid data corruption (e.g. overlapping sub-block
> > IO), we serialise at the IO syscall context (i.e at a much higher
> > layer).
> 
> I'm basing this on this commit:
> 
> commit 14bac5acfdb6a40be64acc042c6db73f1a68f6a4
> Author: Nick Piggin <npiggin@suse.de>
> Date:   Wed Aug 20 14:09:20 2008 -0700
> 
>     mm: xip/ext2 fix block allocation race
>     
>     XIP can call into get_xip_mem concurrently with the same file,offset with
>     create=1.  This usually maps down to get_block, which expects the page
>     lock to prevent such a situation.  This causes ext2 to explode for one
>     reason or another.
>     
>     Serialise those calls for the moment.  For common usages today, I suspect
>     get_xip_mem rarely is called to create new blocks.  In future as XIP
>     technologies evolve we might need to look at which operations require
>     scalability, and rework the locking to suit.
> 
> Now, specifically for DAX, reads and writes are serialised by DIO_LOCKING,
> just like direct I/O.

No, filesystems don't necessarily use DIO_LOCKING for direct IO.
That's the whole point of having the flag - so filesystems can use
their own, more efficient serialisation for getblocks calls.  XFS
does it via the internal XFS inode i_ilock, others do it via the
i_alloc_sem, and so on.

Indeed, XFS has extremely good DIO scalability because it uses
shared locks where ever possible inside getblocks - it only takes an
exclusive lock if allocation is actually required - and hence
concurrent lookups don't serialise unless a modification is
required...

> *currently*, simultaneous pagefaults are not
> serialised against each other at all (or reads/writes), which means we
> can call get_block() with create=1 simultaneously for the same block.
> For a variety of reasons (scalability, fix a subtle race), I'm going to
> implement an equivalent to the page lock for pages of DAX memory, so in
> the future the DAX code will also not call into get_block in parallel.

Which is going to be a major scalability issue. You need to allow
concurrent calls into getblock...

> So what should the document say here?  It sounds like it's similar to
> the iblock beyond i_size below; that the filesystem and the VFS should
> cooperate to ensure that it only happens if the filesystem can make
> it work.

"Filesystems are responsible for ensuring coherency w.r.t.
concurrent access to their block mapping routines"

> > > Despite the iblock argument having type sector_t, iblock is actually
> > > in units of the file block size, not in units of 512-byte sectors.
> > > iblock must not extend beyond i_size. *** um, looks like xfs permits
> > > this ... ? ***
> > 
> > Of course.  There is nothing that prevents filesystems from mapping
> > and allocating blocks beyond EOF if they can do so sanely, and
> > nothign that prevents getblocks from letting them do so. Callers
> > need to handle the situation appropriately, either by doing their
> > own EOF checks or by leaving it up to the filesystems to do the
> > right thing. Buffered IO does the former, direct IO does the latter.
> > 
> > The code in question in __xfs_get_blocks:
> > 
> >         if (!create && direct && offset >= i_size_read(inode))
> > 	                return 0;
> > 
> > This is because XFS does direct IO differently to everyone else.  It
> > doesn't update the inode size until after IO completion (see
> > xfs_end_io_direct_write()), and hence it has to be able to allocate
> > and map blocks beyond EOF.
> > 
> > i.e. only direct IO reads are disallowed if the requested mapping is
> > beyond EOF. Buffered reads beyond EOF don't get here, but direct IO
> > does.
> 
> So how can we document this?  'iblock must not be beyond i_size unless
> it's allowed to be'?  'iblock may only be beyond end of file for direct
> I/O'?

"filesystems must reject attempts to map a range beyond EOF if
create is not set".

> > > b_size to indicate the length of the hole.  It may also opt to leave
> > > bh_result untouched as described above.  If the block corresponds to
> > > a hole, bh_result *may* be unmodified, but the VFS can optimise some
> > > operations if the filesystem reports the length of the hole as described
> > > below. *** or is this a bug in ext4? ***
> > 
> > mpage_readpages() remaps the hole on every block, so regardless of
> > the size of the hole getblocks returns it will do the right thing.
> 
> Yes, this is true, but it could be more efficient if it could rely on
> get_block to return an accurate length of the hole.

Sure. But do_mpage_readpage() needs an aenema. It's a complex mess
that relies on block_read_full_page() and bufferhead based IO to
sort out the crap it gets confused about.

As it is, I suspect that this is all going to be academic. I'm in
the process of ripping bufferhead support out of XFS and adding a
new iomapping interface so that we don't have to carry bufferheads
around on pages anymore. As such, I'll have to re-implement whatever
you do with DAX to support bufferhead enabled filesystems....

> > > If bh_result describes an extent which has data in the pagecache, but
> > > that data has not yet had space allocated on the media (due to delayed
> > > allocation), BH_Mapped, BH_Uptodate and BH_Delay will be set.  b_blocknr
> > > is not set.
> > 
> > b_blocknr is undefined. filesystems can set it to whatever they
> > want; they will interpret it correctly when they see BH_Delay on the
> > buffer.
> 
> Thanks, I'll fix that.
> 
> > Again, BH_Uptodate is used here by XFS to prevent
> > __block_write_begin() from issuing IO on delalloc buffers that have
> > no data in them yet. That's specific to the filesystem
> > implementation (as XFS uses __block_write_begin), so this is
> > actually a requirement of __block_write_begin() for being used with
> > delalloc buffers, not a requirement of the getblocks interface.
> 
> So ... "BH_Mapped and BH_Delay will be set.  BH_Uptodate may be set.
> b_blocknr may be used by the filesystem for its own purpose."

The only indication that a buffer contains a delayed allocation map
is BH_Delay. What the filesystem sets in other flags is determined
by the filesystem implementation, not the getblock API. e.g. it
looks like ext4 always sets buffer_new() on a delalloc block, but
XFs only ever sets it on the getblocks call that allocates the
delalloc block. i.e. the use of many of these flags is filesystem
implementation specific, so you can't actually say that the getblock
API has fixed definitions for these combinations of flags.

> > > The filesystem may choose to set b_private.  Other fields in buffer_head
> > > are legacy buffer-cache uses and will not be modified by get_block.
> > 
> > Precisely why we should be moving this interface to a structure like
> > this:
> > 
> > struct iomap {
> > 	sector_t	blocknr;
> > 	sector_t	length;
> > 	void		*fsprivate;
> > 	unsigned int	state;
> > };
> > 
> > That is used specifically for returning block maps and directing
> > allocation, rather than something that conflates mapping, allocation
> > and data initialisation all into the one interface...
> 
> You missed:
> 	struct block_device *bdev;

Sure - it's in the structures I'm using. ;)

> And I agree, but documentation of the current get_block interface is
> not the place to launch into a polemic on how things ought to be.  It's
> reasonable to point out infelicities ... which I do in a few places :-)

Saying how things are broken and ought to be is the first step
towards fixing a mess. XFS is definitely going to be moving away
from this current mess so we can support block size > page size  and
mulit-page writes without major changes needed to either the
filesystem or the page cache.  Moving away from bufferheads and the
getblock interface is a necessary part of that change...

Cheers,

Dave.

-- 
Dave Chinner
david@fromorbit.com

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

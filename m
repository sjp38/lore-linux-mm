Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f177.google.com (mail-pd0-f177.google.com [209.85.192.177])
	by kanga.kvack.org (Postfix) with ESMTP id D533F6B0145
	for <linux-mm@kvack.org>; Thu, 20 Mar 2014 15:38:48 -0400 (EDT)
Received: by mail-pd0-f177.google.com with SMTP id y10so1347884pdj.22
        for <linux-mm@kvack.org>; Thu, 20 Mar 2014 12:38:48 -0700 (PDT)
Received: from mga09.intel.com (mga09.intel.com. [134.134.136.24])
        by mx.google.com with ESMTP id bp1si2099786pbb.135.2014.03.20.12.38.47
        for <linux-mm@kvack.org>;
        Thu, 20 Mar 2014 12:38:47 -0700 (PDT)
Date: Thu, 20 Mar 2014 15:38:44 -0400
From: Matthew Wilcox <willy@linux.intel.com>
Subject: Re: [PATCH v6 07/22] Replace the XIP page fault handler with the DAX
 page fault handler
Message-ID: <20140320193844.GB5705@linux.intel.com>
References: <1393337918-28265-1-git-send-email-matthew.r.wilcox@intel.com>
 <1393337918-28265-8-git-send-email-matthew.r.wilcox@intel.com>
 <1393609771.6784.83.camel@misato.fc.hp.com>
 <20140228202031.GB12820@linux.intel.com>
 <20140302233027.GR30131@dastard>
 <alpine.OSX.2.00.1403031549110.34680@scrumpy>
 <20140304005624.GB6851@dastard>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20140304005624.GB6851@dastard>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Chinner <david@fromorbit.com>
Cc: Ross Zwisler <ross.zwisler@linux.intel.com>, Toshi Kani <toshi.kani@hp.com>, Matthew Wilcox <matthew.r.wilcox@intel.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org

On Tue, Mar 04, 2014 at 11:56:25AM +1100, Dave Chinner wrote:
> > get_block_t is used by the VFS to ask filesystem to translate logical
> > blocks within a file to sectors on a block device.
> > 
> > typedef int (get_block_t)(struct inode *inode, sector_t iblock,
> >                         struct buffer_head *bh_result, int create);
> > 
> > get_block() must not be called simultaneously with the create flag set
> > for overlapping extents *** or is/was this a bug in ext2? ***
> 
> Why not? The filesystem is responsible for serialising such requests
> internally, or if it can't handle them preventing them from
> occurring. XFS has allowed this to occur with concurrent overlapping
> direct IO writes for a long time. In the situations where we need
> serialisation to avoid data corruption (e.g. overlapping sub-block
> IO), we serialise at the IO syscall context (i.e at a much higher
> layer).

I'm basing this on this commit:

commit 14bac5acfdb6a40be64acc042c6db73f1a68f6a4
Author: Nick Piggin <npiggin@suse.de>
Date:   Wed Aug 20 14:09:20 2008 -0700

    mm: xip/ext2 fix block allocation race
    
    XIP can call into get_xip_mem concurrently with the same file,offset with
    create=1.  This usually maps down to get_block, which expects the page
    lock to prevent such a situation.  This causes ext2 to explode for one
    reason or another.
    
    Serialise those calls for the moment.  For common usages today, I suspect
    get_xip_mem rarely is called to create new blocks.  In future as XIP
    technologies evolve we might need to look at which operations require
    scalability, and rework the locking to suit.

Now, specifically for DAX, reads and writes are serialised by DIO_LOCKING,
just like direct I/O.  *currently*, simultaneous pagefaults are not
serialised against each other at all (or reads/writes), which means we
can call get_block() with create=1 simultaneously for the same block.
For a variety of reasons (scalability, fix a subtle race), I'm going to
implement an equivalent to the page lock for pages of DAX memory, so in
the future the DAX code will also not call into get_block in parallel.

So what should the document say here?  It sounds like it's similar to
the iblock beyond i_size below; that the filesystem and the VFS should
cooperate to ensure that it only happens if the filesystem can make
it work.

> > Despite the iblock argument having type sector_t, iblock is actually
> > in units of the file block size, not in units of 512-byte sectors.
> > iblock must not extend beyond i_size. *** um, looks like xfs permits
> > this ... ? ***
> 
> Of course.  There is nothing that prevents filesystems from mapping
> and allocating blocks beyond EOF if they can do so sanely, and
> nothign that prevents getblocks from letting them do so. Callers
> need to handle the situation appropriately, either by doing their
> own EOF checks or by leaving it up to the filesystems to do the
> right thing. Buffered IO does the former, direct IO does the latter.
> 
> The code in question in __xfs_get_blocks:
> 
>         if (!create && direct && offset >= i_size_read(inode))
> 	                return 0;
> 
> This is because XFS does direct IO differently to everyone else.  It
> doesn't update the inode size until after IO completion (see
> xfs_end_io_direct_write()), and hence it has to be able to allocate
> and map blocks beyond EOF.
> 
> i.e. only direct IO reads are disallowed if the requested mapping is
> beyond EOF. Buffered reads beyond EOF don't get here, but direct IO
> does.

So how can we document this?  'iblock must not be beyond i_size unless
it's allowed to be'?  'iblock may only be beyond end of file for direct
I/O'?

> > If bh_result describes an extent that is allocated, then BH_Mapped will
> > be set, and b_bdev and b_blocknr will be set to indicate the physical
> > location on the media. 
> 
> Definition is wrong. If bh_result has a physical mapping that the
> *filesystem understands* and can reuse later, then BH_Mapped will be
> set.

Ah, yes, fair point.

> > If the
> > filesystem knows that the extent is read into memory (eg because it
> > decided to populate the page cache as part of its get_block operation),
> > it should set BH_Uptodate.
> 
> I think your terminology is wrong their - it is not valid to
> *populate* the page cache during a get_blocks call. page cache
> population occurs before *calls* get_blocks to map a page to a
> block.  On read (mpage_readpages) the page is attached the page to
> the "map_bh". This allows getblocks to initialise the contents of
> the buffer being mapped during the getblocks call, and tell the
> callee that they need to map_buffer_to_page() to correctly update
> the state of the buffers on the page to reflect the state
> returned.
> 
> So, it's not *populating* the page cache at all - the page cache is
> already populated - it's *initialising data* in the page.

Ah!  I misunderstood this comment:

                        /*
                         * get_block() might have updated the buffer
                         * synchronously
                         */
                        if (buffer_uptodate(bh))
                                continue;

I'll fix the text.

> Note that the behaviour on write can be different. For example,
> __block_write_begin() uses the page uptodate and BH_Uptodate to
> determine if it needs to read in data from disk (i.e. a RMW cycle).
> Some filesystems will set BH_Uptodate despite not having
> instantiated data into the blocks because the block is not
> instantiated on disk (BH_delay) or contains zeros (BH_Unwritten) and
> higher layers will zero the buffer data appropriately....
> 
> > If bh_result describes a hole, the filesystem should clear BH_Mapped and
> > set BH_Uptodate.
> 
> This is describing create = 0 behaviour (create = 1 means
> allocation is required, and so that's going to return something
> different).

Sure, but this whole section is describing the state of the returned
buffer.  I agree that you're not going to get a bh_result that describes
a hole when you pass in create=1.

> in the read case, BH_Uptodate should only be set if the filesystem
> initialised the data to zero. Otherwise the data is not uptodate,
> and the caller needs to zero the hole. Indeed, XFS never sets
> BH_Uptodate on a hole mapping because it needs the caller to zero
> the data....

Aha, good to know, thanks!

> > It will not set b_bdev or b_blocknr, but it should set
> > b_size to indicate the length of the hole.  It may also opt to leave
> > bh_result untouched as described above.  If the block corresponds to
> > a hole, bh_result *may* be unmodified, but the VFS can optimise some
> > operations if the filesystem reports the length of the hole as described
> > below. *** or is this a bug in ext4? ***
> 
> mpage_readpages() remaps the hole on every block, so regardless of
> the size of the hole getblocks returns it will do the right thing.

Yes, this is true, but it could be more efficient if it could rely on
get_block to return an accurate length of the hole.

> > If bh_result describes an extent which has data in the pagecache, but
> > that data has not yet had space allocated on the media (due to delayed
> > allocation), BH_Mapped, BH_Uptodate and BH_Delay will be set.  b_blocknr
> > is not set.
> 
> b_blocknr is undefined. filesystems can set it to whatever they
> want; they will interpret it correctly when they see BH_Delay on the
> buffer.

Thanks, I'll fix that.

> Again, BH_Uptodate is used here by XFS to prevent
> __block_write_begin() from issuing IO on delalloc buffers that have
> no data in them yet. That's specific to the filesystem
> implementation (as XFS uses __block_write_begin), so this is
> actually a requirement of __block_write_begin() for being used with
> delalloc buffers, not a requirement of the getblocks interface.

So ... "BH_Mapped and BH_Delay will be set.  BH_Uptodate may be set.
b_blocknr may be used by the filesystem for its own purpose."

> > If bh_result describes an extent which is reserved for data which has not
> > yet been written, BH_Unwritten is set, b_bdev and b_blocknr are set.
> 
> And if the getblocks call zeroed the data, BH_Uptodate shoul dbe
> set, too.
> 
> > Other flags that may be set include BH_New (to indicate that the buffer
> > was newly allocated and may need to be initialised), and BH_Boundary (to
> > indicate a physical discontinuity after this extent).
> 
> BH_New deserved more description than that. Yes, it is used to
> indicate a newly allocated block, but you'll note that they require
> special handling *everywhere*. The common processing is to clear
> underlying block device aliases and invalidate metadata mappings,
> but it is also used to zero the regions of new buffers that aren't
> getting data written to and to inform error handling to zero regions
> that are still marked new when an error is detected.
> 
> In fact, because of this data initialisation and handling of errors,
> XFS also sets BH_new on unwritten extents and any buffer that maps
> beyond EOF so that the callers initialise them to contain zeros
> appropriately.
> 
> > The filesystem may choose to set b_private.  Other fields in buffer_head
> > are legacy buffer-cache uses and will not be modified by get_block.
> 
> Precisely why we should be moving this interface to a structure like
> this:
> 
> struct iomap {
> 	sector_t	blocknr;
> 	sector_t	length;
> 	void		*fsprivate;
> 	unsigned int	state;
> };
> 
> That is used specifically for returning block maps and directing
> allocation, rather than something that conflates mapping, allocation
> and data initialisation all into the one interface...

You missed:
	struct block_device *bdev;

And I agree, but documentation of the current get_block interface is
not the place to launch into a polemic on how things ought to be.  It's
reasonable to point out infelicities ... which I do in a few places :-)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

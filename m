Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f46.google.com (mail-pa0-f46.google.com [209.85.220.46])
	by kanga.kvack.org (Postfix) with ESMTP id 49C206B0039
	for <linux-mm@kvack.org>; Mon,  3 Mar 2014 19:56:48 -0500 (EST)
Received: by mail-pa0-f46.google.com with SMTP id kp14so4399194pab.19
        for <linux-mm@kvack.org>; Mon, 03 Mar 2014 16:56:47 -0800 (PST)
Received: from ipmail05.adl6.internode.on.net (ipmail05.adl6.internode.on.net. [2001:44b8:8060:ff02:300:1:6:5])
        by mx.google.com with ESMTP id wl10si12250056pab.346.2014.03.03.16.56.45
        for <linux-mm@kvack.org>;
        Mon, 03 Mar 2014 16:56:47 -0800 (PST)
Date: Tue, 4 Mar 2014 11:56:25 +1100
From: Dave Chinner <david@fromorbit.com>
Subject: Re: [PATCH v6 07/22] Replace the XIP page fault handler with the DAX
 page fault handler
Message-ID: <20140304005624.GB6851@dastard>
References: <1393337918-28265-1-git-send-email-matthew.r.wilcox@intel.com>
 <1393337918-28265-8-git-send-email-matthew.r.wilcox@intel.com>
 <1393609771.6784.83.camel@misato.fc.hp.com>
 <20140228202031.GB12820@linux.intel.com>
 <20140302233027.GR30131@dastard>
 <alpine.OSX.2.00.1403031549110.34680@scrumpy>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.OSX.2.00.1403031549110.34680@scrumpy>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ross Zwisler <ross.zwisler@linux.intel.com>
Cc: Matthew Wilcox <willy@linux.intel.com>, Toshi Kani <toshi.kani@hp.com>, Matthew Wilcox <matthew.r.wilcox@intel.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org

On Mon, Mar 03, 2014 at 04:07:35PM -0700, Ross Zwisler wrote:
> On Mon, 3 Mar 2014, Dave Chinner wrote:
> > On Fri, Feb 28, 2014 at 03:20:31PM -0500, Matthew Wilcox wrote:
> > > On Fri, Feb 28, 2014 at 10:49:31AM -0700, Toshi Kani wrote:
> > > > The original code,
> > > > xip_file_fault(), jumps to found: and calls vm_insert_mixed() when
> > > > get_xip_mem(,,0,,) succeeded.  If get_xip_mem() returns -ENODATA, it
> > > > calls either get_xip_mem(,,1,,) or xip_sparse_page().  In this new
> > > > function, it looks to me that get_block(,,,0) returns 0 for both cases
> > > > (success and -ENODATA previously), which are dealt in the same way.  Is
> > > > that right?  If so, is there any reason for the change?
> > > 
> > > Yes, get_xip_mem() returned -ENODATA for a hole.  That was a suboptimal
> > > interface because filesystems are actually capable of returning more
> > > information than that, eg how long the hole is (ext4 *doesn't*, but I
> > > consider that to be a bug).
> > > 
> > > I don't get to decide what the get_block() interface looks like.  It's the
> > > standard way that the VFS calls back into the filesystem and has been
> > > around for probably close to twenty years at this point.  I'm still trying
> > > to understand exactly what the contract is for get_blocks() ... I have
> > > a document that I'm working on to try to explain it, but it's tough going!
> > > 
> > > > Also, isn't it
> > > > possible to call get_block(,,,1) even if get_block(,,,0) found a block?
> > > 
> > > The code in question looks like this:
> > > 
> > >         error = get_block(inode, block, &bh, 0);
> > >         if (error || bh.b_size < PAGE_SIZE)
> > >                 goto sigbus;
> > > 
> > >         if (!buffer_written(&bh) && !vmf->cow_page) {
> > >                 if (vmf->flags & FAULT_FLAG_WRITE) {
> > >                         error = get_block(inode, block, &bh, 1);
> > > 
> > > where buffer_written is defined as:
> > >         return buffer_mapped(bh) && !buffer_unwritten(bh);
> > > 
> > > Doing some boolean algebra, that's:
> > > 
> > > 	if (!buffer_mapped || buffer_unwritten)
> > > 
> > > In either case, we want to tell the filesystem that we're writing to
> > > this block.  At least, that's my current understanding of the get_block()
> > > interface.  I'm open to correction here!
> > 
> > I've got a rewritten version on this that doesn't require two calls
> > to get_block() that I wrote while prototyping the XFS code. It also
> > fixes all the misunderstandings about what get_block() actually does
> > and returns so it works correctly with XFS.
> > 
> > I need to port it forward to your new patch set (hopefully later
> > this week), so don't spend too much time trying to work out exactly
> > what this code needs to do...
> 
> Here is a writeup from Matthew Wilcox describing the get_block() interface.
> 
> He sent this to me before Dave sent out the latest mail in this thread. :)
> 
> Corrections and updates are very welcome.
> 
> - Ross
> 
> ================
> 
> get_block_t is used by the VFS to ask filesystem to translate logical
> blocks within a file to sectors on a block device.
> 
> typedef int (get_block_t)(struct inode *inode, sector_t iblock,
>                         struct buffer_head *bh_result, int create);
> 
> get_block() must not be called simultaneously with the create flag set
> for overlapping extents *** or is/was this a bug in ext2? ***

Why not? The filesystem is responsible for serialising such requests
internally, or if it can't handle them preventing them from
occurring. XFS has allowed this to occur with concurrent overlapping
direct IO writes for a long time. In the situations where we need
serialisation to avoid data corruption (e.g. overlapping sub-block
IO), we serialise at the IO syscall context (i.e at a much higher
layer).

> Despite the iblock argument having type sector_t, iblock is actually
> in units of the file block size, not in units of 512-byte sectors.
> iblock must not extend beyond i_size. *** um, looks like xfs permits
> this ... ? ***

Of course.  There is nothing that prevents filesystems from mapping
and allocating blocks beyond EOF if they can do so sanely, and
nothign that prevents getblocks from letting them do so. Callers
need to handle the situation appropriately, either by doing their
own EOF checks or by leaving it up to the filesystems to do the
right thing. Buffered IO does the former, direct IO does the latter.

The code in question in __xfs_get_blocks:

        if (!create && direct && offset >= i_size_read(inode))
	                return 0;

This is because XFS does direct IO differently to everyone else.  It
doesn't update the inode size until after IO completion (see
xfs_end_io_direct_write()), and hence it has to be able to allocate
and map blocks beyond EOF.

i.e. only direct IO reads are disallowed if the requested mapping is
beyond EOF. Buffered reads beyond EOF don't get here, but direct IO
does.

> If there is no current mapping from the block to the media, one will be
> created if 'create' is set to 1.  'create' should not be set to a value
> other than '0' or '1'.

*nod*

Though the patch set I referred to created a third value ;)

> On entry, bh_result should have b_size set to the number of bytes that the
> caller is interested in and b_state initialised to zero.  b_size should
> be a multiple of the file block size.  On exit, bh_result describes a
> physically contiguous extent starting at iblock.  b_size will not be
> increased by get_block, but it may be decreased if the filesystem extent
> is shorter than the extent requested.

*nod*

> If bh_result describes an extent that is allocated, then BH_Mapped will
> be set, and b_bdev and b_blocknr will be set to indicate the physical
> location on the media. 

Definition is wrong. If bh_result has a physical mapping that the
*filesystem understands* and can reuse later, then BH_Mapped will be
set.

> The filesystem may wish to use map_bh() in order
> to set BH_Mapped and initialise b_bdev, b_blocknr and b_size.

That's fine.

> If the
> filesystem knows that the extent is read into memory (eg because it
> decided to populate the page cache as part of its get_block operation),
> it should set BH_Uptodate.

I think your terminology is wrong their - it is not valid to
*populate* the page cache during a get_blocks call. page cache
population occurs before *calls* get_blocks to map a page to a
block.  On read (mpage_readpages) the page is attached the page to
the "map_bh". This allows getblocks to initialise the contents of
the buffer being mapped during the getblocks call, and tell the
callee that they need to map_buffer_to_page() to correctly update
the state of the buffers on the page to reflect the state
returned.

So, it's not *populating* the page cache at all - the page cache is
already populated - it's *initialising data* in the page.

Note that the behaviour on write can be different. For example,
__block_write_begin() uses the page uptodate and BH_Uptodate to
determine if it needs to read in data from disk (i.e. a RMW cycle).
Some filesystems will set BH_Uptodate despite not having
instantiated data into the blocks because the block is not
instantiated on disk (BH_delay) or contains zeros (BH_Unwritten) and
higher layers will zero the buffer data appropriately....

> If bh_result describes a hole, the filesystem should clear BH_Mapped and
> set BH_Uptodate.

This is describing create = 0 behaviour (create = 1 means
allocation is required, and so that's going to return something
different).

in the read case, BH_Uptodate should only be set if the filesystem
initialised the data to zero. Otherwise the data is not uptodate,
and the caller needs to zero the hole. Indeed, XFS never sets
BH_Uptodate on a hole mapping because it needs the caller to zero
the data....

> It will not set b_bdev or b_blocknr, but it should set
> b_size to indicate the length of the hole.  It may also opt to leave
> bh_result untouched as described above.  If the block corresponds to
> a hole, bh_result *may* be unmodified, but the VFS can optimise some
> operations if the filesystem reports the length of the hole as described
> below. *** or is this a bug in ext4? ***

mpage_readpages() remaps the hole on every block, so regardless of
the size of the hole getblocks returns it will do the right thing.

> If bh_result describes an extent which has data in the pagecache, but
> that data has not yet had space allocated on the media (due to delayed
> allocation), BH_Mapped, BH_Uptodate and BH_Delay will be set.  b_blocknr
> is not set.

b_blocknr is undefined. filesystems can set it to whatever they
want; they will interpret it correctly when they see BH_Delay on the
buffer.

Again, BH_Uptodate is used here by XFS to prevent
__block_write_begin() from issuing IO on delalloc buffers that have
no data in them yet. That's specific to the filesystem
implementation (as XFS uses __block_write_begin), so this is
actually a requirement of __block_write_begin() for being used with
delalloc buffers, not a requirement of the getblocks interface.

> If bh_result describes an extent which is reserved for data which has not
> yet been written, BH_Unwritten is set, b_bdev and b_blocknr are set.

And if the getblocks call zeroed the data, BH_Uptodate shoul dbe
set, too.

> Other flags that may be set include BH_New (to indicate that the buffer
> was newly allocated and may need to be initialised), and BH_Boundary (to
> indicate a physical discontinuity after this extent).

BH_New deserved more description than that. Yes, it is used to
indicate a newly allocated block, but you'll note that they require
special handling *everywhere*. The common processing is to clear
underlying block device aliases and invalidate metadata mappings,
but it is also used to zero the regions of new buffers that aren't
getting data written to and to inform error handling to zero regions
that are still marked new when an error is detected.

In fact, because of this data initialisation and handling of errors,
XFS also sets BH_new on unwritten extents and any buffer that maps
beyond EOF so that the callers initialise them to contain zeros
appropriately.

> The filesystem may choose to set b_private.  Other fields in buffer_head
> are legacy buffer-cache uses and will not be modified by get_block.

Precisely why we should be moving this interface to a structure like
this:

struct iomap {
	sector_t	blocknr;
	sector_t	length;
	void		*fsprivate;
	unsigned int	state;
};

That is used specifically for returning block maps and directing
allocation, rather than something that conflates mapping, allocation
and data initialisation all into the one interface...

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

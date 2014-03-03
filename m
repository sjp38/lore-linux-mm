Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pb0-f49.google.com (mail-pb0-f49.google.com [209.85.160.49])
	by kanga.kvack.org (Postfix) with ESMTP id E97E06B0037
	for <linux-mm@kvack.org>; Mon,  3 Mar 2014 18:07:19 -0500 (EST)
Received: by mail-pb0-f49.google.com with SMTP id jt11so4314495pbb.8
        for <linux-mm@kvack.org>; Mon, 03 Mar 2014 15:07:19 -0800 (PST)
Received: from mga09.intel.com (mga09.intel.com. [134.134.136.24])
        by mx.google.com with ESMTP id zt8si12104629pbc.45.2014.03.03.15.07.18
        for <linux-mm@kvack.org>;
        Mon, 03 Mar 2014 15:07:18 -0800 (PST)
Date: Mon, 3 Mar 2014 16:07:35 -0700 (MST)
From: Ross Zwisler <ross.zwisler@linux.intel.com>
Subject: Re: [PATCH v6 07/22] Replace the XIP page fault handler with the
 DAX page fault handler
In-Reply-To: <20140302233027.GR30131@dastard>
Message-ID: <alpine.OSX.2.00.1403031549110.34680@scrumpy>
References: <1393337918-28265-1-git-send-email-matthew.r.wilcox@intel.com> <1393337918-28265-8-git-send-email-matthew.r.wilcox@intel.com> <1393609771.6784.83.camel@misato.fc.hp.com> <20140228202031.GB12820@linux.intel.com> <20140302233027.GR30131@dastard>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Chinner <david@fromorbit.com>
Cc: Matthew Wilcox <willy@linux.intel.com>, Toshi Kani <toshi.kani@hp.com>, Matthew Wilcox <matthew.r.wilcox@intel.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org

On Mon, 3 Mar 2014, Dave Chinner wrote:
> On Fri, Feb 28, 2014 at 03:20:31PM -0500, Matthew Wilcox wrote:
> > On Fri, Feb 28, 2014 at 10:49:31AM -0700, Toshi Kani wrote:
> > > The original code,
> > > xip_file_fault(), jumps to found: and calls vm_insert_mixed() when
> > > get_xip_mem(,,0,,) succeeded.  If get_xip_mem() returns -ENODATA, it
> > > calls either get_xip_mem(,,1,,) or xip_sparse_page().  In this new
> > > function, it looks to me that get_block(,,,0) returns 0 for both cases
> > > (success and -ENODATA previously), which are dealt in the same way.  Is
> > > that right?  If so, is there any reason for the change?
> > 
> > Yes, get_xip_mem() returned -ENODATA for a hole.  That was a suboptimal
> > interface because filesystems are actually capable of returning more
> > information than that, eg how long the hole is (ext4 *doesn't*, but I
> > consider that to be a bug).
> > 
> > I don't get to decide what the get_block() interface looks like.  It's the
> > standard way that the VFS calls back into the filesystem and has been
> > around for probably close to twenty years at this point.  I'm still trying
> > to understand exactly what the contract is for get_blocks() ... I have
> > a document that I'm working on to try to explain it, but it's tough going!
> > 
> > > Also, isn't it
> > > possible to call get_block(,,,1) even if get_block(,,,0) found a block?
> > 
> > The code in question looks like this:
> > 
> >         error = get_block(inode, block, &bh, 0);
> >         if (error || bh.b_size < PAGE_SIZE)
> >                 goto sigbus;
> > 
> >         if (!buffer_written(&bh) && !vmf->cow_page) {
> >                 if (vmf->flags & FAULT_FLAG_WRITE) {
> >                         error = get_block(inode, block, &bh, 1);
> > 
> > where buffer_written is defined as:
> >         return buffer_mapped(bh) && !buffer_unwritten(bh);
> > 
> > Doing some boolean algebra, that's:
> > 
> > 	if (!buffer_mapped || buffer_unwritten)
> > 
> > In either case, we want to tell the filesystem that we're writing to
> > this block.  At least, that's my current understanding of the get_block()
> > interface.  I'm open to correction here!
> 
> I've got a rewritten version on this that doesn't require two calls
> to get_block() that I wrote while prototyping the XFS code. It also
> fixes all the misunderstandings about what get_block() actually does
> and returns so it works correctly with XFS.
> 
> I need to port it forward to your new patch set (hopefully later
> this week), so don't spend too much time trying to work out exactly
> what this code needs to do...

Here is a writeup from Matthew Wilcox describing the get_block() interface.

He sent this to me before Dave sent out the latest mail in this thread. :)

Corrections and updates are very welcome.

- Ross

================

get_block_t is used by the VFS to ask filesystem to translate logical
blocks within a file to sectors on a block device.

typedef int (get_block_t)(struct inode *inode, sector_t iblock,
                        struct buffer_head *bh_result, int create);

get_block() must not be called simultaneously with the create flag set
for overlapping extents *** or is/was this a bug in ext2? ***

Despite the iblock argument having type sector_t, iblock is actually
in units of the file block size, not in units of 512-byte sectors.
iblock must not extend beyond i_size. *** um, looks like xfs permits
this ... ? ***

If there is no current mapping from the block to the media, one will be
created if 'create' is set to 1.  'create' should not be set to a value
other than '0' or '1'.

On entry, bh_result should have b_size set to the number of bytes that the
caller is interested in and b_state initialised to zero.  b_size should
be a multiple of the file block size.  On exit, bh_result describes a
physically contiguous extent starting at iblock.  b_size will not be
increased by get_block, but it may be decreased if the filesystem extent
is shorter than the extent requested.

If bh_result describes an extent that is allocated, then BH_Mapped will
be set, and b_bdev and b_blocknr will be set to indicate the physical
location on the media.  The filesystem may wish to use map_bh() in order
to set BH_Mapped and initialise b_bdev, b_blocknr and b_size.  If the
filesystem knows that the extent is read into memory (eg because it
decided to populate the page cache as part of its get_block operation),
it should set BH_Uptodate.

If bh_result describes a hole, the filesystem should clear BH_Mapped and
set BH_Uptodate.  It will not set b_bdev or b_blocknr, but it should set
b_size to indicate the length of the hole.  It may also opt to leave
bh_result untouched as described above.  If the block corresponds to
a hole, bh_result *may* be unmodified, but the VFS can optimise some
operations if the filesystem reports the length of the hole as described
below. *** or is this a bug in ext4? ***

If bh_result describes an extent which has data in the pagecache, but
that data has not yet had space allocated on the media (due to delayed
allocation), BH_Mapped, BH_Uptodate and BH_Delay will be set.  b_blocknr
is not set.

If bh_result describes an extent which is reserved for data which has not
yet been written, BH_Unwritten is set, b_bdev and b_blocknr are set.

Other flags that may be set include BH_New (to indicate that the buffer
was newly allocated and may need to be initialised), and BH_Boundary (to
indicate a physical discontinuity after this extent).

The filesystem may choose to set b_private.  Other fields in buffer_head
are legacy buffer-cache uses and will not be modified by get_block.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

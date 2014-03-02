Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f41.google.com (mail-pa0-f41.google.com [209.85.220.41])
	by kanga.kvack.org (Postfix) with ESMTP id B7C1F6B0035
	for <linux-mm@kvack.org>; Sun,  2 Mar 2014 18:30:32 -0500 (EST)
Received: by mail-pa0-f41.google.com with SMTP id hz1so311336pad.14
        for <linux-mm@kvack.org>; Sun, 02 Mar 2014 15:30:32 -0800 (PST)
Received: from ipmail06.adl6.internode.on.net (ipmail06.adl6.internode.on.net. [2001:44b8:8060:ff02:300:1:6:6])
        by mx.google.com with ESMTP id zt8si8576743pbc.105.2014.03.02.15.30.30
        for <linux-mm@kvack.org>;
        Sun, 02 Mar 2014 15:30:31 -0800 (PST)
Date: Mon, 3 Mar 2014 10:30:27 +1100
From: Dave Chinner <david@fromorbit.com>
Subject: Re: [PATCH v6 07/22] Replace the XIP page fault handler with the DAX
 page fault handler
Message-ID: <20140302233027.GR30131@dastard>
References: <1393337918-28265-1-git-send-email-matthew.r.wilcox@intel.com>
 <1393337918-28265-8-git-send-email-matthew.r.wilcox@intel.com>
 <1393609771.6784.83.camel@misato.fc.hp.com>
 <20140228202031.GB12820@linux.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20140228202031.GB12820@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Matthew Wilcox <willy@linux.intel.com>
Cc: Toshi Kani <toshi.kani@hp.com>, Matthew Wilcox <matthew.r.wilcox@intel.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org

On Fri, Feb 28, 2014 at 03:20:31PM -0500, Matthew Wilcox wrote:
> On Fri, Feb 28, 2014 at 10:49:31AM -0700, Toshi Kani wrote:
> > On Tue, 2014-02-25 at 09:18 -0500, Matthew Wilcox wrote:
> > > Instead of calling aops->get_xip_mem from the fault handler, the
> > > filesystem passes a get_block_t that is used to find the appropriate
> > > blocks.
> >  :
> > > +static int do_dax_fault(struct vm_area_struct *vma, struct vm_fault *vmf,
> > > +			get_block_t get_block)
> > > +{
> > > +	struct file *file = vma->vm_file;
> > > +	struct inode *inode = file_inode(file);
> > > +	struct address_space *mapping = file->f_mapping;
> > > +	struct buffer_head bh;
> > > +	unsigned long vaddr = (unsigned long)vmf->virtual_address;
> > > +	sector_t block;
> > > +	pgoff_t size;
> > > +	unsigned long pfn;
> > > +	int error;
> > > +
> > > +	size = (i_size_read(inode) + PAGE_SIZE - 1) >> PAGE_SHIFT;
> > > +	if (vmf->pgoff >= size)
> > > +		return VM_FAULT_SIGBUS;
> > > +
> > > +	memset(&bh, 0, sizeof(bh));
> > > +	block = (sector_t)vmf->pgoff << (PAGE_SHIFT - inode->i_blkbits);
> > > +	bh.b_size = PAGE_SIZE;
> > > +	error = get_block(inode, block, &bh, 0);
> > > +	if (error || bh.b_size < PAGE_SIZE)
> > > +		return VM_FAULT_SIGBUS;
> > 
> > I am learning the code and have some questions.
> 
> Hi Toshi,
> 
> Glad to see you're looking at it.  Let me try to help ...
> 
> > The original code,
> > xip_file_fault(), jumps to found: and calls vm_insert_mixed() when
> > get_xip_mem(,,0,,) succeeded.  If get_xip_mem() returns -ENODATA, it
> > calls either get_xip_mem(,,1,,) or xip_sparse_page().  In this new
> > function, it looks to me that get_block(,,,0) returns 0 for both cases
> > (success and -ENODATA previously), which are dealt in the same way.  Is
> > that right?  If so, is there any reason for the change?
> 
> Yes, get_xip_mem() returned -ENODATA for a hole.  That was a suboptimal
> interface because filesystems are actually capable of returning more
> information than that, eg how long the hole is (ext4 *doesn't*, but I
> consider that to be a bug).
> 
> I don't get to decide what the get_block() interface looks like.  It's the
> standard way that the VFS calls back into the filesystem and has been
> around for probably close to twenty years at this point.  I'm still trying
> to understand exactly what the contract is for get_blocks() ... I have
> a document that I'm working on to try to explain it, but it's tough going!
> 
> > Also, isn't it
> > possible to call get_block(,,,1) even if get_block(,,,0) found a block?
> 
> The code in question looks like this:
> 
>         error = get_block(inode, block, &bh, 0);
>         if (error || bh.b_size < PAGE_SIZE)
>                 goto sigbus;
> 
>         if (!buffer_written(&bh) && !vmf->cow_page) {
>                 if (vmf->flags & FAULT_FLAG_WRITE) {
>                         error = get_block(inode, block, &bh, 1);
> 
> where buffer_written is defined as:
>         return buffer_mapped(bh) && !buffer_unwritten(bh);
> 
> Doing some boolean algebra, that's:
> 
> 	if (!buffer_mapped || buffer_unwritten)
> 
> In either case, we want to tell the filesystem that we're writing to
> this block.  At least, that's my current understanding of the get_block()
> interface.  I'm open to correction here!

I've got a rewritten version on this that doesn't require two calls
to get_block() that I wrote while prototyping the XFS code. It also
fixes all the misunderstandings about what get_block() actually does
and returns so it works correctly with XFS.

I need to port it forward to your new patch set (hopefully later
this week), so don't spend too much time trying to work out exactly
what this code needs to do...

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

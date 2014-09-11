Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f175.google.com (mail-pd0-f175.google.com [209.85.192.175])
	by kanga.kvack.org (Postfix) with ESMTP id 17AE86B0035
	for <linux-mm@kvack.org>; Wed, 10 Sep 2014 23:10:17 -0400 (EDT)
Received: by mail-pd0-f175.google.com with SMTP id z10so12403967pdj.34
        for <linux-mm@kvack.org>; Wed, 10 Sep 2014 20:10:16 -0700 (PDT)
Received: from ipmail04.adl6.internode.on.net (ipmail04.adl6.internode.on.net. [150.101.137.141])
        by mx.google.com with ESMTP id nw11si30234804pab.104.2014.09.10.20.10.14
        for <linux-mm@kvack.org>;
        Wed, 10 Sep 2014 20:10:15 -0700 (PDT)
Date: Thu, 11 Sep 2014 13:09:26 +1000
From: Dave Chinner <david@fromorbit.com>
Subject: Re: [PATCH v10 09/21] Replace the XIP page fault handler with the
 DAX page fault handler
Message-ID: <20140911030926.GO20518@dastard>
References: <cover.1409110741.git.matthew.r.wilcox@intel.com>
 <4d71d7a13bec3acf703e26bf6b0c7da21a71ebe0.1409110741.git.matthew.r.wilcox@intel.com>
 <20140903074724.GE20473@dastard>
 <20140910152337.GF27730@localhost.localdomain>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20140910152337.GF27730@localhost.localdomain>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Matthew Wilcox <willy@linux.intel.com>
Cc: Matthew Wilcox <matthew.r.wilcox@intel.com>, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Wed, Sep 10, 2014 at 11:23:37AM -0400, Matthew Wilcox wrote:
> On Wed, Sep 03, 2014 at 05:47:24PM +1000, Dave Chinner wrote:
> > > +	error = get_block(inode, block, &bh, 0);
> > > +	if (!error && (bh.b_size < PAGE_SIZE))
> > > +		error = -EIO;
> > > +	if (error)
> > > +		goto unlock_page;
> > 
> > page fault into unwritten region, returns buffer_unwritten(bh) ==
> > true. Hence buffer_written(bh) is false, and we take this branch:
> > 
> > > +	if (!buffer_written(&bh) && !vmf->cow_page) {
> > > +		if (vmf->flags & FAULT_FLAG_WRITE) {
> > > +			error = get_block(inode, block, &bh, 1);
> > 
> > Exactly what are you expecting to happen here? We don't do
> > allocation because there are already unwritten blocks over this
> > extent, and so bh will be unchanged when returning. i.e. it will
> > still be mapping an unwritten extent.
> 
> I was expecting calling get_block() on an unwritten extent to convert it
> to a written extent.  Your suggestion below of using b_end_io() to do that
> is a better idea.
> 
> So this should be:
> 
> 	if (!buffer_mapped(&bh) && !vmf->cow_page) {
> 
> ... right?

Yes, that is the conclusion I reached as well. ;)

> > dax: add IO completion callback for page faults
> > 
> > From: Dave Chinner <dchinner@redhat.com>
> > 
> > When a page fault drops into a hole, it needs to allocate an extent.
> > Filesystems may allocate unwritten extents so that the underlying
> > contents are not exposed until data is written to the extent. In
> > that case, we need an io completion callback to run once the blocks
> > have been zeroed to indicate that it is safe for the filesystem to
> > mark those blocks written without exposing stale data in the event
> > of a crash.
> > 
> > Signed-off-by: Dave Chinner <dchinner@redhat.com>
> > ---
> >  fs/dax.c | 7 ++++++-
> >  1 file changed, 6 insertions(+), 1 deletion(-)
> > 
> > diff --git a/fs/dax.c b/fs/dax.c
> > index 96c4fed..387ca78 100644
> > --- a/fs/dax.c
> > +++ b/fs/dax.c
> > @@ -306,6 +306,7 @@ static int do_dax_fault(struct vm_area_struct *vma, struct vm_fault *vmf,
> >  	memset(&bh, 0, sizeof(bh));
> >  	block = (sector_t)vmf->pgoff << (PAGE_SHIFT - blkbits);
> >  	bh.b_size = PAGE_SIZE;
> > +	bh.b_end_io = NULL;
> 
> Given the above memset, I don't think we need to explicitly set b_end_io
> to NULL.

I missed that ;)

> >   repeat:
> >  	page = find_get_page(mapping, vmf->pgoff);
> > @@ -364,8 +365,12 @@ static int do_dax_fault(struct vm_area_struct *vma, struct vm_fault *vmf,
> >  		return VM_FAULT_LOCKED;
> >  	}
> >  
> > -	if (buffer_unwritten(&bh) || buffer_new(&bh))
> > +	if (buffer_unwritten(&bh) || buffer_new(&bh)) {
> > +		/* XXX: errors zeroing the blocks are propagated how? */
> >  		dax_clear_blocks(inode, bh.b_blocknr, bh.b_size);
> 
> That's a great question.  I think we need to segfault here.

I suspect there are other cases where we need to do similar "trigger
segv" error handling rather than ignoring errors altogether...

> 
> > +		if (bh.b_end_io)
> > +			bh.b_end_io(&bh, 1);
> > +	}
> 
> I think ext4 is going to need to set b_end_io too.  Right now, it uses the
> dio_iodone_t to convert unwritten extents to written extents, but we don't
> have (and I don't think we should have) a kiocb for page faults.

Yes, ext4 is going to need this as well. After I got XFS running
without problems, I then went back and ran xfstests on ext4 and it
failed many of the tests that do operations into unwritten regions.

> So, if it's OK with you, I'm going to fold this patch into version 11 and
> add your Reviewed-by to it.

Fold it in, I'll review the result ;)

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

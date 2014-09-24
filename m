Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f169.google.com (mail-pd0-f169.google.com [209.85.192.169])
	by kanga.kvack.org (Postfix) with ESMTP id EB7466B0036
	for <linux-mm@kvack.org>; Wed, 24 Sep 2014 11:43:12 -0400 (EDT)
Received: by mail-pd0-f169.google.com with SMTP id fp1so4681330pdb.0
        for <linux-mm@kvack.org>; Wed, 24 Sep 2014 08:43:12 -0700 (PDT)
Received: from mga01.intel.com (mga01.intel.com. [192.55.52.88])
        by mx.google.com with ESMTP id h4si26993138pat.27.2014.09.24.08.43.11
        for <linux-mm@kvack.org>;
        Wed, 24 Sep 2014 08:43:11 -0700 (PDT)
Date: Wed, 24 Sep 2014 11:43:07 -0400
From: Matthew Wilcox <willy@linux.intel.com>
Subject: Re: [PATCH v10 09/21] Replace the XIP page fault handler with the
 DAX page fault handler
Message-ID: <20140924154307.GO27730@localhost.localdomain>
References: <cover.1409110741.git.matthew.r.wilcox@intel.com>
 <4d71d7a13bec3acf703e26bf6b0c7da21a71ebe0.1409110741.git.matthew.r.wilcox@intel.com>
 <20140903074724.GE20473@dastard>
 <20140910152337.GF27730@localhost.localdomain>
 <20140911030926.GO20518@dastard>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20140911030926.GO20518@dastard>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Chinner <david@fromorbit.com>
Cc: Matthew Wilcox <willy@linux.intel.com>, Matthew Wilcox <matthew.r.wilcox@intel.com>, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Thu, Sep 11, 2014 at 01:09:26PM +1000, Dave Chinner wrote:
> On Wed, Sep 10, 2014 at 11:23:37AM -0400, Matthew Wilcox wrote:
> > On Wed, Sep 03, 2014 at 05:47:24PM +1000, Dave Chinner wrote:
> > > > +	error = get_block(inode, block, &bh, 0);
> > > > +	if (!error && (bh.b_size < PAGE_SIZE))
> > > > +		error = -EIO;
> > > > +	if (error)
> > > > +		goto unlock_page;
> > > 
> > > page fault into unwritten region, returns buffer_unwritten(bh) ==
> > > true. Hence buffer_written(bh) is false, and we take this branch:
> > > 
> > > > +	if (!buffer_written(&bh) && !vmf->cow_page) {
> > > > +		if (vmf->flags & FAULT_FLAG_WRITE) {
> > > > +			error = get_block(inode, block, &bh, 1);
> > > 
> > > Exactly what are you expecting to happen here? We don't do
> > > allocation because there are already unwritten blocks over this
> > > extent, and so bh will be unchanged when returning. i.e. it will
> > > still be mapping an unwritten extent.
> > 
> > I was expecting calling get_block() on an unwritten extent to convert it
> > to a written extent.  Your suggestion below of using b_end_io() to do that
> > is a better idea.
> > 
> > So this should be:
> > 
> > 	if (!buffer_mapped(&bh) && !vmf->cow_page) {
> > 
> > ... right?
> 
> Yes, that is the conclusion I reached as well. ;)

Now I know why I was expecting get_block() on an unwritten extent to
convert it to a written extent.  That's the way ext4 behaves!

[  236.660772] got bh ffffffffa06e3bd0 1000
[  236.660814] got bh for write ffffffffa06e3bd0 60
[  236.660821] calling end_io ffffffffa06e3bd0 60

(1000 is BH_Unwritten, 60 is BH_Mapped | BH_New)

The code producing this output:

        error = get_block(inode, block, &bh, 0);
printk("got bh %p %lx\n", bh.b_end_io, bh.b_state);
        if (!error && (bh.b_size < PAGE_SIZE))
                error = -EIO;
        if (error)
                goto unlock_page;

        if (!buffer_mapped(&bh) && !vmf->cow_page) {
                if (vmf->flags & FAULT_FLAG_WRITE) {
                        error = get_block(inode, block, &bh, 1);
printk("got bh for write %p %lx\n", bh.b_end_io, bh.b_state);

# xfs_io -f -c "truncate 20k" -c "fiemap -v" -c "falloc 0 20k" -c "fiemap -v" -c "mmap -w 0 20k" -c "fiemap -v" -c "mwrite 4k 4k" -c "fiemap -v" /mnt/ram0/b
/mnt/ram0/b:
/mnt/ram0/b:
 EXT: FILE-OFFSET      BLOCK-RANGE      TOTAL FLAGS
   0: [0..39]:         263176..263215      40 0x801
/mnt/ram0/b:
 EXT: FILE-OFFSET      BLOCK-RANGE      TOTAL FLAGS
   0: [0..39]:         263176..263215      40 0x801
/mnt/ram0/b:
 EXT: FILE-OFFSET      BLOCK-RANGE      TOTAL FLAGS
   0: [0..39]:         263176..263215      40   0x1

Actually, this looks wrong ... ext4 should only have converted one block
of the extent to written, not all of it.  I think that means ext4 is
exposing stale data :-(  I'll keep digging.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

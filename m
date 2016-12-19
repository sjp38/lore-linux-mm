Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f69.google.com (mail-pg0-f69.google.com [74.125.83.69])
	by kanga.kvack.org (Postfix) with ESMTP id 7F4AF6B02BF
	for <linux-mm@kvack.org>; Mon, 19 Dec 2016 16:17:16 -0500 (EST)
Received: by mail-pg0-f69.google.com with SMTP id 5so237221107pgi.2
        for <linux-mm@kvack.org>; Mon, 19 Dec 2016 13:17:16 -0800 (PST)
Received: from ipmail06.adl6.internode.on.net (ipmail06.adl6.internode.on.net. [150.101.137.145])
        by mx.google.com with ESMTP id q2si11173723pgd.298.2016.12.19.13.17.14
        for <linux-mm@kvack.org>;
        Mon, 19 Dec 2016 13:17:15 -0800 (PST)
Date: Tue, 20 Dec 2016 08:17:11 +1100
From: Dave Chinner <david@fromorbit.com>
Subject: Re: [PATCH v4 1/3] dax: masking off __GFP_FS in fs DAX handlers
Message-ID: <20161219211711.GD4219@dastard>
References: <148184524161.184728.14005697153880489871.stgit@djiang5-desk3.ch.intel.com>
 <20161216010730.GY4219@dastard>
 <20161216161916.GA2410@linux.intel.com>
 <20161216220450.GZ4219@dastard>
 <20161219195302.GI17598@quack2.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20161219195302.GI17598@quack2.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jan Kara <jack@suse.cz>
Cc: Ross Zwisler <ross.zwisler@linux.intel.com>, Dave Jiang <dave.jiang@intel.com>, akpm@linux-foundation.org, linux-nvdimm@lists.01.org, hch@lst.de, linux-mm@kvack.org, tytso@mit.edu, dan.j.williams@intel.com, mhocko@suse.com

On Mon, Dec 19, 2016 at 08:53:02PM +0100, Jan Kara wrote:
> On Sat 17-12-16 09:04:50, Dave Chinner wrote:
> > On Fri, Dec 16, 2016 at 09:19:16AM -0700, Ross Zwisler wrote:
> > > On Fri, Dec 16, 2016 at 12:07:30PM +1100, Dave Chinner wrote:
> > > > On Thu, Dec 15, 2016 at 04:40:41PM -0700, Dave Jiang wrote:
> > > > > The caller into dax needs to clear __GFP_FS mask bit since it's
> > > > > responsible for acquiring locks / transactions that blocks __GFP_FS
> > > > > allocation.  The caller will restore the original mask when dax function
> > > > > returns.
> > > > 
> > > > What's the allocation problem you're working around here? Can you
> > > > please describe the call chain that is the problem?
> > > > 
> > > > >  	xfs_ilock(XFS_I(inode), XFS_MMAPLOCK_SHARED);
> > > > >  
> > > > >  	if (IS_DAX(inode)) {
> > > > > +		gfp_t old_gfp = vmf->gfp_mask;
> > > > > +
> > > > > +		vmf->gfp_mask &= ~__GFP_FS;
> > > > >  		ret = dax_iomap_fault(vma, vmf, &xfs_iomap_ops);
> > > > > +		vmf->gfp_mask = old_gfp;
> > > > 
> > > > I really have to say that I hate code that clears and restores flags
> > > > without any explanation of why the code needs to play flag tricks. I
> > > > take one look at the XFS fault handling code and ask myself now "why
> > > > the hell do we need to clear those flags?" Especially as the other
> > > > paths into generic fault handlers /don't/ require us to do this.
> > > > What does DAX do that require us to treat memory allocation contexts
> > > > differently to the filemap_fault() path?
> > > 
> > > This was done in response to Jan Kara's concern:
> > > 
> > >   The gfp_mask that propagates from __do_fault() or do_page_mkwrite() is fine
> > >   because at that point it is correct. But once we grab filesystem locks which
> > >   are not reclaim safe, we should update vmf->gfp_mask we pass further down
> > >   into DAX code to not contain __GFP_FS (that's a bug we apparently have
> > >   there). And inside DAX code, we definitely are not generally safe to add
> > >   __GFP_FS to mapping_gfp_mask(). Maybe we'd be better off propagating struct
> > >   vm_fault into this function, using passed gfp_mask there and make sure
> > >   callers update gfp_mask as appropriate.
> > > 
> > > https://lkml.org/lkml/2016/10/4/37
> > > 
> > > IIUC I think the concern is that, for example, in xfs_filemap_page_mkwrite()
> > > we take a read lock on the struct inode.i_rwsem before we call
> > > dax_iomap_fault().
> > 
> > That, my friends, is exactly the problem that mapping_gfp_mask() is
> > meant to solve. This:
> > 
> > > > > +	vmf.gfp_mask = mapping_gfp_mask(mapping) | __GFP_FS |  __GFP_IO;
> > 
> > Is just so wrong it's not funny.
> 
> You mean like in mm/memory.c: __get_fault_gfp_mask()?
> 
> Which was introduced by commit c20cd45eb017 "mm: allow GFP_{FS,IO} for
> page_cache_read page cache allocation" by Michal (added to CC) and you were
> even on CC ;).

Sure, I was on the cc list, but that doesn't mean I /liked/ the
patch. It also doesn't mean I had the time or patience to argue
whether it was the right way to address whatever whacky OOM/reclaim
deficiency was being reported....

Oh, and this is a write fault, not a read fault. There's a big
difference in filesystem behaviour between those two types of
faults, so what might be fine for a page cache read (i.e. no
transactions) isn't necessarily correct for a write operation...

> The code here was replicating __get_fault_gfp_mask() and in fact the idea
> of the cleanup is to get rid of this code and take whatever is in
> vmf.gfp_mask and mask off __GFP_FS in the filesystem if it deems it is
> needed (e.g. ext4 really needs this as inode reclaim is depending on being
> able to force a transaction commit).

And so now we add a flag to the fault that the filesystem says not
to add to mapping masks, and now the filesystem has to mask off
thati flag /again/ because it's mapping gfp mask guidelines are
essentially being ignored.

Remind me again why we even have the mapping gfp_mask if we just
ignore it like this?

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

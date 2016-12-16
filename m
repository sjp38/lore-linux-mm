Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id F0EF46B0260
	for <linux-mm@kvack.org>; Fri, 16 Dec 2016 17:05:24 -0500 (EST)
Received: by mail-pf0-f198.google.com with SMTP id c4so141719608pfb.7
        for <linux-mm@kvack.org>; Fri, 16 Dec 2016 14:05:24 -0800 (PST)
Received: from ipmail07.adl2.internode.on.net (ipmail07.adl2.internode.on.net. [150.101.137.131])
        by mx.google.com with ESMTP id q21si9531904pgg.333.2016.12.16.14.05.22
        for <linux-mm@kvack.org>;
        Fri, 16 Dec 2016 14:05:24 -0800 (PST)
Date: Sat, 17 Dec 2016 09:04:50 +1100
From: Dave Chinner <david@fromorbit.com>
Subject: Re: [PATCH v4 1/3] dax: masking off __GFP_FS in fs DAX handlers
Message-ID: <20161216220450.GZ4219@dastard>
References: <148184524161.184728.14005697153880489871.stgit@djiang5-desk3.ch.intel.com>
 <20161216010730.GY4219@dastard>
 <20161216161916.GA2410@linux.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20161216161916.GA2410@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ross Zwisler <ross.zwisler@linux.intel.com>
Cc: Dave Jiang <dave.jiang@intel.com>, akpm@linux-foundation.org, jack@suse.cz, linux-nvdimm@lists.01.org, hch@lst.de, linux-mm@kvack.org, tytso@mit.edu, dan.j.williams@intel.com

On Fri, Dec 16, 2016 at 09:19:16AM -0700, Ross Zwisler wrote:
> On Fri, Dec 16, 2016 at 12:07:30PM +1100, Dave Chinner wrote:
> > On Thu, Dec 15, 2016 at 04:40:41PM -0700, Dave Jiang wrote:
> > > The caller into dax needs to clear __GFP_FS mask bit since it's
> > > responsible for acquiring locks / transactions that blocks __GFP_FS
> > > allocation.  The caller will restore the original mask when dax function
> > > returns.
> > 
> > What's the allocation problem you're working around here? Can you
> > please describe the call chain that is the problem?
> > 
> > >  	xfs_ilock(XFS_I(inode), XFS_MMAPLOCK_SHARED);
> > >  
> > >  	if (IS_DAX(inode)) {
> > > +		gfp_t old_gfp = vmf->gfp_mask;
> > > +
> > > +		vmf->gfp_mask &= ~__GFP_FS;
> > >  		ret = dax_iomap_fault(vma, vmf, &xfs_iomap_ops);
> > > +		vmf->gfp_mask = old_gfp;
> > 
> > I really have to say that I hate code that clears and restores flags
> > without any explanation of why the code needs to play flag tricks. I
> > take one look at the XFS fault handling code and ask myself now "why
> > the hell do we need to clear those flags?" Especially as the other
> > paths into generic fault handlers /don't/ require us to do this.
> > What does DAX do that require us to treat memory allocation contexts
> > differently to the filemap_fault() path?
> 
> This was done in response to Jan Kara's concern:
> 
>   The gfp_mask that propagates from __do_fault() or do_page_mkwrite() is fine
>   because at that point it is correct. But once we grab filesystem locks which
>   are not reclaim safe, we should update vmf->gfp_mask we pass further down
>   into DAX code to not contain __GFP_FS (that's a bug we apparently have
>   there). And inside DAX code, we definitely are not generally safe to add
>   __GFP_FS to mapping_gfp_mask(). Maybe we'd be better off propagating struct
>   vm_fault into this function, using passed gfp_mask there and make sure
>   callers update gfp_mask as appropriate.
> 
> https://lkml.org/lkml/2016/10/4/37
> 
> IIUC I think the concern is that, for example, in xfs_filemap_page_mkwrite()
> we take a read lock on the struct inode.i_rwsem before we call
> dax_iomap_fault().

That, my friends, is exactly the problem that mapping_gfp_mask() is
meant to solve. This:

> > > +	vmf.gfp_mask = mapping_gfp_mask(mapping) | __GFP_FS |  __GFP_IO;

Is just so wrong it's not funny.

The whole point of mapping_gfp_mask() is to remove flags from the
gfp_mask used to do mapping+page cache related allocations that the
mapping->host considers dangerous when the host may be holding locks.
This includes mapping tree allocations, and anything else required
to set up a new entry in the mapping during IO path operations. That
includes page fault operations...

e.g. in xfs_setup_inode():

        /*
         * Ensure all page cache allocations are done from GFP_NOFS context to
         * prevent direct reclaim recursion back into the filesystem and blowing
         * stacks or deadlocking.
         */
        gfp_mask = mapping_gfp_mask(inode->i_mapping);
        mapping_set_gfp_mask(inode->i_mapping, (gfp_mask & ~(__GFP_FS)));

i.e. XFS considers it invalid to use GFP_FS at all for mapping
allocations in the io path, because we *know* that we hold
filesystems locks over those allocations.

> dax_iomap_fault() then calls find_or_create_page(), etc. with the
> vfm->gfp_mask we were given.

Yup. Precisely why we should be using mapping_gfp_mask() as it was
intended for vmf.gfp_mask....

> I believe the concern is that if that memory allocation tries to do FS
> operations to free memory because __GFP_FS is part of the gfp mask, then we
> could end up deadlocking because we are already holding FS locks.

Which is a problem with the filesystem mapping mask setup, not a
reason to sprinkle random gfpmask clear/set pairs around the code.
i.e. For DAX inodes, the mapping mask should clear __GFP_FS as XFS
does above, and the mapping_gfp_mask() should be used unadulterated
by the DAX page fault code....

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

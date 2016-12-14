Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wj0-f198.google.com (mail-wj0-f198.google.com [209.85.210.198])
	by kanga.kvack.org (Postfix) with ESMTP id EA18C6B0038
	for <linux-mm@kvack.org>; Wed, 14 Dec 2016 04:57:25 -0500 (EST)
Received: by mail-wj0-f198.google.com with SMTP id he10so5543075wjc.6
        for <linux-mm@kvack.org>; Wed, 14 Dec 2016 01:57:25 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id fh2si53511693wjb.52.2016.12.14.01.57.24
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 14 Dec 2016 01:57:24 -0800 (PST)
Date: Wed, 14 Dec 2016 10:57:19 +0100
From: Jan Kara <jack@suse.cz>
Subject: Re: [PATCH 1/2] mm, dax: make pmd_fault() and friends to be the same
 as fault()
Message-ID: <20161214095719.GA18624@quack2.suse.cz>
References: <148123286127.108913.2695398781030517780.stgit@djiang5-desk3.ch.intel.com>
 <20161213121535.GI15362@quack2.suse.cz>
 <e41d16fb-672d-1d61-b60d-6fd3a2201e41@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <e41d16fb-672d-1d61-b60d-6fd3a2201e41@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Jiang <dave.jiang@intel.com>
Cc: Jan Kara <jack@suse.cz>, akpm@linux-foundation.org, linux-nvdimm@lists.01.org, david@fromorbit.com, linux-mm@kvack.org, ross.zwisler@linux.intel.com, dan.j.williams@intel.com, hch@lst.de

On Tue 13-12-16 11:29:54, Dave Jiang wrote:
> 
> 
> On 12/13/2016 05:15 AM, Jan Kara wrote:
> > On Thu 08-12-16 14:34:21, Dave Jiang wrote:
> >> Instead of passing in multiple parameters in the pmd_fault() handler,
> >> a vmf can be passed in just like a fault() handler. This will simplify
> >> code and remove the need for the actual pmd fault handlers to allocate a
> >> vmf. Related functions are also modified to do the same.
> >>
> >> Signed-off-by: Dave Jiang <dave.jiang@intel.com>
> >> Reviewed-by: Ross Zwisler <ross.zwisler@linux.intel.com>
> > 
> > I like the idea however see below:
> > 
> >> @@ -1377,21 +1376,20 @@ int dax_iomap_pmd_fault(struct vm_area_struct *vma, unsigned long address,
> >>  	if (iomap.offset + iomap.length < pos + PMD_SIZE)
> >>  		goto unlock_entry;
> >>  
> >> -	vmf.pgoff = pgoff;
> >> -	vmf.flags = flags;
> >> -	vmf.gfp_mask = mapping_gfp_mask(mapping) | __GFP_IO;
> >> +	vmf->pgoff = pgoff;
> >> +	vmf->gfp_mask = mapping_gfp_mask(mapping) | __GFP_IO;
> > 
> > But now it's really unexpected that you change pgoff and gfp_mask because
> > that will propagate back to the caller and if we return VM_FAULT_FALLBACK
> > we may fault in wrong PTE because of this. So dax_iomap_pmd_fault() should
> > not modify the passed gfp_mask, just make its callers clear __GFP_FS from
> > it because *they* are responsible for acquiring locks / transactions that
> > block __GFP_FS allocations. They are also responsible for restoring
> > original gfp_mask once dax_iomap_pmd_fault() returns.
> 
> Ok will fix.
> 
> > 
> > dax_iomap_pmd_fault() needs to modify pgoff however it must restore it to
> > the original value before it returns.
> 
> Need clarification here. Do you mean "If" dax_iomap_pmd_fault() needs to
> modify.... and right now it doesn't appear to need to modify pgoff so
> nothing needs to be done? Thanks.

How come? I can see:

	pgoff = linear_page_index(vma, pmd_addr);

a few lines above - we need to modify pgoff to contain huge page aligned
file index instead of only page aligned...

								Honza
-- 
Jan Kara <jack@suse.com>
SUSE Labs, CR

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

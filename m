Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f72.google.com (mail-wm0-f72.google.com [74.125.82.72])
	by kanga.kvack.org (Postfix) with ESMTP id 1ADE66B0038
	for <linux-mm@kvack.org>; Tue,  4 Oct 2016 01:56:03 -0400 (EDT)
Received: by mail-wm0-f72.google.com with SMTP id b201so63038717wmb.2
        for <linux-mm@kvack.org>; Mon, 03 Oct 2016 22:56:03 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id qq3si2439178wjc.45.2016.10.03.22.56.01
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Mon, 03 Oct 2016 22:56:01 -0700 (PDT)
Date: Tue, 4 Oct 2016 07:55:57 +0200
From: Jan Kara <jack@suse.cz>
Subject: Re: [PATCH v4 10/12] dax: add struct iomap based DAX PMD support
Message-ID: <20161004055557.GB17515@quack2.suse.cz>
References: <1475189370-31634-1-git-send-email-ross.zwisler@linux.intel.com>
 <1475189370-31634-11-git-send-email-ross.zwisler@linux.intel.com>
 <20161003105949.GP6457@quack2.suse.cz>
 <20161003210557.GA28177@linux.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20161003210557.GA28177@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ross Zwisler <ross.zwisler@linux.intel.com>
Cc: Jan Kara <jack@suse.cz>, linux-kernel@vger.kernel.org, Theodore Ts'o <tytso@mit.edu>, Alexander Viro <viro@zeniv.linux.org.uk>, Andreas Dilger <adilger.kernel@dilger.ca>, Andrew Morton <akpm@linux-foundation.org>, Christoph Hellwig <hch@lst.de>, Dan Williams <dan.j.williams@intel.com>, Dave Chinner <david@fromorbit.com>, Jan Kara <jack@suse.com>, Matthew Wilcox <mawilcox@microsoft.com>, linux-ext4@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, linux-nvdimm@lists.01.org, linux-xfs@vger.kernel.org

On Mon 03-10-16 15:05:57, Ross Zwisler wrote:
> > > @@ -623,22 +672,30 @@ static void *dax_insert_mapping_entry(struct address_space *mapping,
> > >  		error = radix_tree_preload(vmf->gfp_mask & ~__GFP_HIGHMEM);
> > >  		if (error)
> > >  			return ERR_PTR(error);
> > > +	} else if ((unsigned long)entry & RADIX_DAX_HZP && !hzp) {
> > > +		/* replacing huge zero page with PMD block mapping */
> > > +		unmap_mapping_range(mapping,
> > > +			(vmf->pgoff << PAGE_SHIFT) & PMD_MASK, PMD_SIZE, 0);
> > >  	}
> > >  
> > >  	spin_lock_irq(&mapping->tree_lock);
> > > -	new_entry = (void *)((unsigned long)RADIX_DAX_ENTRY(sector, false) |
> > > -		       RADIX_DAX_ENTRY_LOCK);
> > > +	if (hzp)
> > > +		new_entry = RADIX_DAX_HZP_ENTRY();
> > > +	else
> > > +		new_entry = RADIX_DAX_ENTRY(sector, new_type);
> > > +
> > >  	if (hole_fill) {
> > >  		__delete_from_page_cache(entry, NULL);
> > >  		/* Drop pagecache reference */
> > >  		put_page(entry);
> > > -		error = radix_tree_insert(page_tree, index, new_entry);
> > > +		error = __radix_tree_insert(page_tree, index,
> > > +				RADIX_DAX_ORDER(new_type), new_entry);
> > >  		if (error) {
> > >  			new_entry = ERR_PTR(error);
> > >  			goto unlock;
> > >  		}
> > >  		mapping->nrexceptional++;
> > > -	} else {
> > > +	} else if ((unsigned long)entry & (RADIX_DAX_HZP|RADIX_DAX_EMPTY)) {
> > >  		void **slot;
> > >  		void *ret;
> > 
> > Hum, I somewhat dislike how PTE and PMD paths differ here. But it's OK for
> > now I guess. Long term we might be better off to do away with zero pages
> > for PTEs as well and use exceptional entry and a single zero page like you
> > do for PMD. Because the special cases these zero pages cause are a
> > headache.
> 
> I've been thinking about this as well, and I do think we'd be better off with
> a single zero page for PTEs, as we have with PMDs.  It'd reduce the special
> casing in the DAX code, and it'd also ensure that we don't waste a bunch of
> time and memory creating read-only zero pages to service reads from holes.
> 
> I'll look into adding this for v5.

Well, this would clash with the dirty bit cleaning series I have. So I'd
prefer to put this on a todo list and address it once existing series are
integrated...

> > > +	if (error)
> > > +		goto fallback;
> > > +	if (iomap.offset + iomap.length < pos + PMD_SIZE)
> > > +		goto fallback;
> > > +
> > > +	vmf.pgoff = pgoff;
> > > +	vmf.flags = flags;
> > > +	vmf.gfp_mask = mapping_gfp_mask(mapping) | __GFP_FS | __GFP_IO;
> > 
> > I don't think you want __GFP_FS here - we have already gone through the
> > filesystem's pmd_fault() handler which called dax_iomap_pmd_fault() and
> > thus we hold various fs locks, freeze protection, ...
> 
> I copied this from __get_fault_gfp_mask() in mm/memory.c.  That function is
> used by do_page_mkwrite() and __do_fault(), and we eventually get this
> vmf->gfp_mask in the PTE fault code.  With the code as it is we get the same
> vmf->gfp_mask in both dax_iomap_fault() and dax_iomap_pmd_fault().  It seems
> like they should remain consistent - is it wrong to have __GFP_FS in
> dax_iomap_fault()?

The gfp_mask that propagates from __do_fault() or do_page_mkwrite() is fine
because at that point it is correct. But once we grab filesystem locks
which are not reclaim safe, we should update vmf->gfp_mask we pass further
down into DAX code to not contain __GFP_FS (that's a bug we apparently have
there). And inside DAX code, we definitely are not generally safe to add
__GFP_FS to mapping_gfp_mask(). Maybe we'd be better off propagating struct
vm_fault into this function, using passed gfp_mask there and make sure
callers update gfp_mask as appropriate.

								Honza
-- 
Jan Kara <jack@suse.com>
SUSE Labs, CR

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

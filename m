Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id 619C0831F4
	for <linux-mm@kvack.org>; Mon, 22 May 2017 15:43:21 -0400 (EDT)
Received: by mail-pf0-f199.google.com with SMTP id e7so132694365pfk.9
        for <linux-mm@kvack.org>; Mon, 22 May 2017 12:43:21 -0700 (PDT)
Received: from mga04.intel.com (mga04.intel.com. [192.55.52.120])
        by mx.google.com with ESMTPS id s68si18211571pfg.108.2017.05.22.12.43.20
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 22 May 2017 12:43:20 -0700 (PDT)
Date: Mon, 22 May 2017 13:43:18 -0600
From: Ross Zwisler <ross.zwisler@linux.intel.com>
Subject: Re: [PATCH 2/2] dax: Fix race between colliding PMD & PTE entries
Message-ID: <20170522194318.GA27118@linux.intel.com>
References: <20170517171639.14501-1-ross.zwisler@linux.intel.com>
 <20170517171639.14501-2-ross.zwisler@linux.intel.com>
 <20170522144457.GE25118@quack2.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170522144457.GE25118@quack2.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jan Kara <jack@suse.cz>
Cc: Ross Zwisler <ross.zwisler@linux.intel.com>, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, "Darrick J. Wong" <darrick.wong@oracle.com>, Alexander Viro <viro@zeniv.linux.org.uk>, Christoph Hellwig <hch@lst.de>, Dan Williams <dan.j.williams@intel.com>, Dave Hansen <dave.hansen@intel.com>, Matthew Wilcox <mawilcox@microsoft.com>, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, linux-nvdimm@lists.01.org, "Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>, Pawel Lebioda <pawel.lebioda@intel.com>, Dave Jiang <dave.jiang@intel.com>, Xiong Zhou <xzhou@redhat.com>, Eryu Guan <eguan@redhat.com>, stable@vger.kernel.org

On Mon, May 22, 2017 at 04:44:57PM +0200, Jan Kara wrote:
> On Wed 17-05-17 11:16:39, Ross Zwisler wrote:
> > We currently have two related PMD vs PTE races in the DAX code.  These can
> > both be easily triggered by having two threads reading and writing
> > simultaneously to the same private mapping, with the key being that private
> > mapping reads can be handled with PMDs but private mapping writes are
> > always handled with PTEs so that we can COW.
> > 
> > Here is the first race:
> > 
> > CPU 0					CPU 1
> > 
> > (private mapping write)
> > __handle_mm_fault()
> >   create_huge_pmd() - FALLBACK
> >   handle_pte_fault()
> >     passes check for pmd_devmap()
> > 
> > 					(private mapping read)
> > 					__handle_mm_fault()
> > 					  create_huge_pmd()
> > 					    dax_iomap_pmd_fault() inserts PMD
> > 
> >     dax_iomap_pte_fault() does a PTE fault, but we already have a DAX PMD
> >     			  installed in our page tables at this spot.
> > 
> > Here's the second race:
> > 
> > CPU 0					CPU 1
> > 
> > (private mapping write)
> > __handle_mm_fault()
> >   create_huge_pmd() - FALLBACK
> > 					(private mapping read)
> > 					__handle_mm_fault()
> > 					  passes check for pmd_none()
> > 					  create_huge_pmd()
> > 
> >   handle_pte_fault()
> >     dax_iomap_pte_fault() inserts PTE
> > 					    dax_iomap_pmd_fault() inserts PMD,
> > 					       but we already have a PTE at
> > 					       this spot.
> > 
> > The core of the issue is that while there is isolation between faults to
> > the same range in the DAX fault handlers via our DAX entry locking, there
> > is no isolation between faults in the code in mm/memory.c.  This means for
> > instance that this code in __handle_mm_fault() can run:
> > 
> > 	if (pmd_none(*vmf.pmd) && transparent_hugepage_enabled(vma)) {
> > 		ret = create_huge_pmd(&vmf);
> > 
> > But by the time we actually get to run the fault handler called by
> > create_huge_pmd(), the PMD is no longer pmd_none() because a racing PTE
> > fault has installed a normal PMD here as a parent.  This is the cause of
> > the 2nd race.  The first race is similar - there is the following check in
> > handle_pte_fault():
> > 
> > 	} else {
> > 		/* See comment in pte_alloc_one_map() */
> > 		if (pmd_devmap(*vmf->pmd) || pmd_trans_unstable(vmf->pmd))
> > 			return 0;
> > 
> > So if a pmd_devmap() PMD (a DAX PMD) has been installed at vmf->pmd, we
> > will bail and retry the fault.  This is correct, but there is nothing
> > preventing the PMD from being installed after this check but before we
> > actually get to the DAX PTE fault handlers.
> > 
> > In my testing these races result in the following types of errors:
> > 
> >  BUG: Bad rss-counter state mm:ffff8800a817d280 idx:1 val:1
> >  BUG: non-zero nr_ptes on freeing mm: 15
> > 
> > Fix this issue by having the DAX fault handlers verify that it is safe to
> > continue their fault after they have taken an entry lock to block other
> > racing faults.
> > 
> > Signed-off-by: Ross Zwisler <ross.zwisler@linux.intel.com>
> > Reported-by: Pawel Lebioda <pawel.lebioda@intel.com>
> > Cc: stable@vger.kernel.org
> > 
> > ---
> > 
> > I've written a new xfstest for this race, which I will send in response to
> > this patch series.  This series has also survived an xfstest run without
> > any new issues.
> > 
> > ---
> >  fs/dax.c | 18 ++++++++++++++++++
> >  1 file changed, 18 insertions(+)
> > 
> > diff --git a/fs/dax.c b/fs/dax.c
> > index c22eaf1..3cc02d1 100644
> > --- a/fs/dax.c
> > +++ b/fs/dax.c
> > @@ -1155,6 +1155,15 @@ static int dax_iomap_pte_fault(struct vm_fault *vmf,
> >  	}
> >  
> >  	/*
> > +	 * It is possible, particularly with mixed reads & writes to private
> > +	 * mappings, that we have raced with a PMD fault that overlaps with
> > +	 * the PTE we need to set up.  Now that we have a locked mapping entry
> > +	 * we can safely unmap the huge PMD so that we can install our PTE in
> > +	 * our page tables.
> > +	 */
> > +	split_huge_pmd(vmf->vma, vmf->pmd, vmf->address);
> > +
> 
> Can we just check the PMD and if is isn't as we want it, bail out and retry
> the fault? IMHO it will be more obvious that way (and also more in line
> like these races are handled for the classical THP). Otherwise the patch
> looks good to me.

Yep, that works as well.  I'll do this for v2.

Thanks for the review.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

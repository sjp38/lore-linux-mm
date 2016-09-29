Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id D54426B0038
	for <linux-mm@kvack.org>; Thu, 29 Sep 2016 14:20:23 -0400 (EDT)
Received: by mail-pf0-f200.google.com with SMTP id n24so166660866pfb.0
        for <linux-mm@kvack.org>; Thu, 29 Sep 2016 11:20:23 -0700 (PDT)
Received: from mga06.intel.com (mga06.intel.com. [134.134.136.31])
        by mx.google.com with ESMTPS id oq7si15339582pac.220.2016.09.29.11.20.22
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 29 Sep 2016 11:20:23 -0700 (PDT)
Date: Thu, 29 Sep 2016 12:20:21 -0600
From: Ross Zwisler <ross.zwisler@linux.intel.com>
Subject: Re: [PATCH v3 09/11] dax: add struct iomap based DAX PMD support
Message-ID: <20160929182021.GA20307@linux.intel.com>
References: <1475009282-9818-1-git-send-email-ross.zwisler@linux.intel.com>
 <1475009282-9818-10-git-send-email-ross.zwisler@linux.intel.com>
 <20160927221424.GE27872@dastard>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20160927221424.GE27872@dastard>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Chinner <david@fromorbit.com>
Cc: Ross Zwisler <ross.zwisler@linux.intel.com>, linux-kernel@vger.kernel.org, Theodore Ts'o <tytso@mit.edu>, Alexander Viro <viro@zeniv.linux.org.uk>, Andreas Dilger <adilger.kernel@dilger.ca>, Andrew Morton <akpm@linux-foundation.org>, Christoph Hellwig <hch@lst.de>, Dan Williams <dan.j.williams@intel.com>, Jan Kara <jack@suse.com>, Matthew Wilcox <mawilcox@microsoft.com>, linux-ext4@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, linux-nvdimm@lists.01.org, linux-xfs@vger.kernel.org

On Wed, Sep 28, 2016 at 08:14:24AM +1000, Dave Chinner wrote:
> On Tue, Sep 27, 2016 at 02:48:00PM -0600, Ross Zwisler wrote:
> > DAX PMDs have been disabled since Jan Kara introduced DAX radix tree based
> > locking.  This patch allows DAX PMDs to participate in the DAX radix tree
> > based locking scheme so that they can be re-enabled using the new struct
> > iomap based fault handlers.
> > 
> > There are currently three types of DAX 4k entries: 4k zero pages, 4k DAX
> > mappings that have an associated block allocation, and 4k DAX empty
> > entries.  The empty entries exist to provide locking for the duration of a
> > given page fault.
> > 
> > This patch adds three equivalent 2MiB DAX entries: Huge Zero Page (HZP)
> > entries, PMD DAX entries that have associated block allocations, and 2 MiB
> > DAX empty entries.
> > 
> > Unlike the 4k case where we insert a struct page* into the radix tree for
> > 4k zero pages, for HZP we insert a DAX exceptional entry with the new
> > RADIX_DAX_HZP flag set.  This is because we use a single 2 MiB zero page in
> > every 2MiB hole mapping, and it doesn't make sense to have that same struct
> > page* with multiple entries in multiple trees.  This would cause contention
> > on the single page lock for the one Huge Zero Page, and it would break the
> > page->index and page->mapping associations that are assumed to be valid in
> > many other places in the kernel.
> > 
> > One difficult use case is when one thread is trying to use 4k entries in
> > radix tree for a given offset, and another thread is using 2 MiB entries
> > for that same offset.  The current code handles this by making the 2 MiB
> > user fall back to 4k entries for most cases.  This was done because it is
> > the simplest solution, and because the use of 2MiB pages is already
> > opportunistic.
> > 
> > If we were to try to upgrade from 4k pages to 2MiB pages for a given range,
> > we run into the problem of how we lock out 4k page faults for the entire
> > 2MiB range while we clean out the radix tree so we can insert the 2MiB
> > entry.  We can solve this problem if we need to, but I think that the cases
> > where both 2MiB entries and 4K entries are being used for the same range
> > will be rare enough and the gain small enough that it probably won't be
> > worth the complexity.
> > 
> > Signed-off-by: Ross Zwisler <ross.zwisler@linux.intel.com>
> ....
> > +#if defined(CONFIG_TRANSPARENT_HUGEPAGE)
> > +/*
> > + * The 'colour' (ie low bits) within a PMD of a page offset.  This comes up
> > + * more often than one might expect in the below functions.
> > + */
> > +#define PG_PMD_COLOUR	((PMD_SIZE >> PAGE_SHIFT) - 1)
> > +
> > +static void __dax_pmd_dbg(struct iomap *iomap, unsigned long address,
> > +		const char *reason, const char *fn)
> > +{
> > +	if (iomap) {
> > +		char bname[BDEVNAME_SIZE];
> > +
> > +		bdevname(iomap->bdev, bname);
> > +		pr_debug("%s: %s addr %lx dev %s type %#x blkno %ld "
> > +			"offset %lld length %lld fallback: %s\n", fn,
> > +			current->comm, address, bname, iomap->type,
> > +			iomap->blkno, iomap->offset, iomap->length, reason);
> > +	} else {
> > +		pr_debug("%s: %s addr: %lx fallback: %s\n", fn,
> > +			current->comm, address, reason);
> > +	}
> > +}
> 
> Yuck! Tracepoints for debugging information like this, please, not
> printk awfulness.

I was just recreating the debugging scheme used in the old PMD code.
I'll check out tracepoints.

> > +
> > +#define dax_pmd_dbg(bh, address, reason) \
> > +	__dax_pmd_dbg(bh, address, reason, __func__)
> > +
> > +static int iomap_pmd_insert_mapping(struct vm_area_struct *vma, pmd_t *pmd,
> > +		struct vm_fault *vmf, unsigned long address,
> > +		struct iomap *iomap, loff_t pos, bool write, void **entryp)
> 
> Please put a "dax" in the function name. grepping, cscope, etc are
> much easier when static function names are namespaced properly.

Yea, namespacing for static functions is a bit hit and miss, especially in the
dax code.  (see buffer_written(), to_sector(), slot_locked(), etc.)  Poking
around in the XFS code, though, it looks like everything starts with "xfs_".
I'll add the leading "dax_".

> > +{
> > +	struct address_space *mapping = vma->vm_file->f_mapping;
> > +	struct block_device *bdev = iomap->bdev;
> > +	struct blk_dax_ctl dax = {
> > +		.sector = iomap_dax_sector(iomap, pos),
> > +		.size = PMD_SIZE,
> > +	};
> > +	long length = dax_map_atomic(bdev, &dax);
> > +	void *ret;
> > +
> > +	if (length < 0) {
> > +		dax_pmd_dbg(iomap, address, "dax-error fallback");
> > +		return VM_FAULT_FALLBACK;
> > +	}
> 
> Fails to unmap. 

This is the failure case for dax_map_atomic() failing, so we don't have a
mapping to unmap at this point.

> Please use an goto based error stack. And
> tracepoints make this much neater:
> 
> 	trace_dax_pmd_insert_mapping(iomap, address, &dax, length);
> 	if (length < 0)
> 		goto unmap_fallback;
> 	if (length < PMD_SIZE)
> 		goto unmap_fallback;
> 	.....
> 
> 	trace_dax_pmd_insert_mapping_done(iomap, address, &dax, length);
> 	return vmf_insert_pfn_pmd(vma, address, pmd, dax.pfn, write);
> 
> unmap_fallback:
> 	dax_unmap_atomic(bdev, &dax);
> fallback:
> 	trace_dax_pmd_insert_fallback(iomap, address, &dax, length);
> 	return VM_FAULT_FALLBACK;
> }
> 
> i.e. we don't need need all those debug printks to tell us what
> failed - the first tracepoint tells use everything about the context
> we are about to check, and the last tracepoint tells us whether we
> are falling back or about to try mapping a PMD.
> 
> If you really need custom printk output for debugging, then use
> trace_printk() so that it shows up in the trace output along with
> all the trace points....
> 
> Same goes for all the other pr_debug() cals in this code - they need
> to go and be replaced with tracepoints.

Cool, I'll look into making this simpler.

> > +int iomap_dax_pmd_fault(struct vm_area_struct *vma, unsigned long address,
> > +		pmd_t *pmd, unsigned int flags, struct iomap_ops *ops)
> 
> dax_iomap_pmd_fault() - dax_ is the namespace prefix for the code in
> fs/dax.c, not iomap_...

I was just trying to be consistent with Christoph's dax iomap code.  :)  I'll
change both his and my functions to be properly namespaced as 'dax_iomap_'

> > +{
> > +	struct address_space *mapping = vma->vm_file->f_mapping;
> > +	unsigned long pmd_addr = address & PMD_MASK;
> > +	bool write = flags & FAULT_FLAG_WRITE;
> > +	struct inode *inode = mapping->host;
> > +	struct iomap iomap = { 0 };
> > +	int error, result = 0;
> > +	pgoff_t size, pgoff;
> > +	struct vm_fault vmf;
> > +	void *entry;
> > +	loff_t pos;
> > +
> > +	/* dax pmd mappings require pfn_t_devmap() */
> > +	if (!IS_ENABLED(CONFIG_FS_DAX_PMD))
> > +		return VM_FAULT_FALLBACK;
> 
> So we build all this stuff in, even if CONFIG_FS_DAX_PMD=n?
> Shouldn't we just have a simple function that returns
> VM_FAULT_FALLBACK when CONFIG_FS_DAX_PMD=n?

Well, not really.  If CONFIG_FS_DAX_PMD isn't defined the compiler notices
that we have an unconditional return and optimizes out the rest of the
function.  It effectively becomes a sub that does an unconditional "return
VM_FAULT_FALLBACK;".

Here is the generated code for iomap_dax_pmd_fault() when CONFIG_FS_DAX_PMD
isn't defined:

0000000000000000 <iomap_dax_pmd_fault>:
       0:       e8 00 00 00 00          callq  5 <iomap_dax_pmd_fault+0x5>
       5:       55                      push   %rbp
       6:       b8 00 08 00 00          mov    $0x800,%eax
       b:       48 89 e5                mov    %rsp,%rbp
       e:       5d                      pop    %rbp
       f:       c3                      retq

Where the 0x800 in there is VM_FAULT_FALLBACK.

However, I already need to make a stub for the PMD fault handler in dax.h for
configs where CONFIG_TRANSPARENT_HUGEPAGE isn't defined.  This stub is just:

#if defined(CONFIG_TRANSPARENT_HUGEPAGE)
int iomap_dax_pmd_fault(struct vm_area_struct *vma, unsigned long address,
		pmd_t *pmd, unsigned int flags, struct iomap_ops *ops);
#else
static inline int iomap_dax_pmd_fault(struct vm_area_struct *vma,
		unsigned long address, pmd_t *pmd, unsigned int flags,
		struct iomap_ops *ops)
{
	return VM_FAULT_FALLBACK;
}
#endif

It's probably more readable if we just use this stub if CONFIG_FS_DAX_PMD isn't
defined.  I'll fix this for v4.

Thank you for the review!

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

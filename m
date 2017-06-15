Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f70.google.com (mail-wm0-f70.google.com [74.125.82.70])
	by kanga.kvack.org (Postfix) with ESMTP id 619536B0292
	for <linux-mm@kvack.org>; Thu, 15 Jun 2017 10:59:02 -0400 (EDT)
Received: by mail-wm0-f70.google.com with SMTP id f90so227365wmh.10
        for <linux-mm@kvack.org>; Thu, 15 Jun 2017 07:59:02 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id f3si357819wmf.25.2017.06.15.07.58.57
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 15 Jun 2017 07:58:58 -0700 (PDT)
Date: Thu, 15 Jun 2017 16:58:56 +0200
From: Jan Kara <jack@suse.cz>
Subject: Re: [PATCH v2 3/3] dax: use common 4k zero page for dax mmap reads
Message-ID: <20170615145856.GO1764@quack2.suse.cz>
References: <20170614172211.19820-1-ross.zwisler@linux.intel.com>
 <20170614172211.19820-4-ross.zwisler@linux.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170614172211.19820-4-ross.zwisler@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ross Zwisler <ross.zwisler@linux.intel.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, "Darrick J. Wong" <darrick.wong@oracle.com>, Theodore Ts'o <tytso@mit.edu>, Alexander Viro <viro@zeniv.linux.org.uk>, Andreas Dilger <adilger.kernel@dilger.ca>, Christoph Hellwig <hch@lst.de>, Dan Williams <dan.j.williams@intel.com>, Dave Hansen <dave.hansen@intel.com>, Ingo Molnar <mingo@redhat.com>, Jan Kara <jack@suse.cz>, Jonathan Corbet <corbet@lwn.net>, Matthew Wilcox <mawilcox@microsoft.com>, Steven Rostedt <rostedt@goodmis.org>, linux-doc@vger.kernel.org, linux-ext4@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, linux-nvdimm@lists.01.org, linux-xfs@vger.kernel.org

On Wed 14-06-17 11:22:11, Ross Zwisler wrote:
> When servicing mmap() reads from file holes the current DAX code allocates
> a page cache page of all zeroes and places the struct page pointer in the
> mapping->page_tree radix tree.  This has two major drawbacks:
> 
> 1) It consumes memory unnecessarily.  For every 4k page that is read via a
> DAX mmap() over a hole, we allocate a new page cache page.  This means that
> if you read 1GiB worth of pages, you end up using 1GiB of zeroed memory.
> This is easily visible by looking at the overall memory consumption of the
> system or by looking at /proc/[pid]/smaps:
> 
> 	7f62e72b3000-7f63272b3000 rw-s 00000000 103:00 12   /root/dax/data
> 	Size:            1048576 kB
> 	Rss:             1048576 kB
> 	Pss:             1048576 kB
> 	Shared_Clean:          0 kB
> 	Shared_Dirty:          0 kB
> 	Private_Clean:   1048576 kB
> 	Private_Dirty:         0 kB
> 	Referenced:      1048576 kB
> 	Anonymous:             0 kB
> 	LazyFree:              0 kB
> 	AnonHugePages:         0 kB
> 	ShmemPmdMapped:        0 kB
> 	Shared_Hugetlb:        0 kB
> 	Private_Hugetlb:       0 kB
> 	Swap:                  0 kB
> 	SwapPss:               0 kB
> 	KernelPageSize:        4 kB
> 	MMUPageSize:           4 kB
> 	Locked:                0 kB
> 
> 2) The fact that we had to check for both DAX exceptional entries and for
> page cache pages in the radix tree made the DAX code more complex.
> 
> Solve these issues by following the lead of the DAX PMD code and using a
> common 4k zero page instead.  As with the PMD code we will now insert a DAX
> exceptional entry into the radix tree instead of a struct page pointer
> which allows us to remove all the special casing in the DAX code.
> 
> Note that we do still pretty aggressively check for regular pages in the
> DAX radix tree, especially where we take action based on the bits set in
> the page.  If we ever find a regular page in our radix tree now that most
> likely means that someone besides DAX is inserting pages (which has
> happened lots of times in the past), and we want to find that out early and
> fail loudly.
> 
> This solution also removes the extra memory consumption.  Here is that same
> /proc/[pid]/smaps after 1GiB of reading from a hole with the new code:
> 
> 	7f2054a74000-7f2094a74000 rw-s 00000000 103:00 12   /root/dax/data
> 	Size:            1048576 kB
> 	Rss:                   0 kB
> 	Pss:                   0 kB
> 	Shared_Clean:          0 kB
> 	Shared_Dirty:          0 kB
> 	Private_Clean:         0 kB
> 	Private_Dirty:         0 kB
> 	Referenced:            0 kB
> 	Anonymous:             0 kB
> 	LazyFree:              0 kB
> 	AnonHugePages:         0 kB
> 	ShmemPmdMapped:        0 kB
> 	Shared_Hugetlb:        0 kB
> 	Private_Hugetlb:       0 kB
> 	Swap:                  0 kB
> 	SwapPss:               0 kB
> 	KernelPageSize:        4 kB
> 	MMUPageSize:           4 kB
> 	Locked:                0 kB
> 
> Overall system memory consumption is similarly improved.
> 
> Another major change is that we remove dax_pfn_mkwrite() from our fault
> flow, and instead rely on the page fault itself to make the PTE dirty and
> writeable.  The following description from the patch adding the
> vm_insert_mixed_mkwrite() call explains this a little more:
> 
> ***
>   To be able to use the common 4k zero page in DAX we need to have our PTE
>   fault path look more like our PMD fault path where a PTE entry can be
>   marked as dirty and writeable as it is first inserted, rather than
>   waiting for a follow-up dax_pfn_mkwrite() => finish_mkwrite_fault() call.
> 
>   Right now we can rely on having a dax_pfn_mkwrite() call because we can
>   distinguish between these two cases in do_wp_page():
> 
>       case 1: 4k zero page => writable DAX storage
>       case 2: read-only DAX storage => writeable DAX storage
> 
>   This distinction is made by via vm_normal_page().  vm_normal_page()
>   returns false for the common 4k zero page, though, just as it does for
>   DAX ptes.  Instead of special casing the DAX + 4k zero page case, we will
>   simplify our DAX PTE page fault sequence so that it matches our DAX PMD
>   sequence, and get rid of dax_pfn_mkwrite() completely.
> 
>   This means that insert_pfn() needs to follow the lead of insert_pfn_pmd()
>   and allow us to pass in a 'mkwrite' flag.  If 'mkwrite' is set
>   insert_pfn() will do the work that was previously done by wp_page_reuse()
>   as part of the dax_pfn_mkwrite() call path.
> ***

This looks generally fine. Just two small comments below.

> @@ -216,17 +217,6 @@ static void dax_unlock_mapping_entry(struct address_space *mapping,
>  	dax_wake_mapping_entry_waiter(mapping, index, entry, false);
>  }
>  
> -static void put_locked_mapping_entry(struct address_space *mapping,
> -				     pgoff_t index, void *entry)
> -{
> -	if (!radix_tree_exceptional_entry(entry)) {
> -		unlock_page(entry);
> -		put_page(entry);
> -	} else {
> -		dax_unlock_mapping_entry(mapping, index);
> -	}
> -}
> -

The naming becomes asymetric with this. So I'd prefer keeping
put_locked_mapping_entry() as a trivial wrapper around
dax_unlock_mapping_entry() unless we can craft more sensible naming / API
for entry grabbing (and that would be a separate patch anyway).

> -static int dax_load_hole(struct address_space *mapping, void **entry,
> +static int dax_load_hole(struct address_space *mapping, void *entry,
>  			 struct vm_fault *vmf)
>  {
>  	struct inode *inode = mapping->host;
> -	struct page *page;
> -	int ret;
> -
> -	/* Hole page already exists? Return it...  */
> -	if (!radix_tree_exceptional_entry(*entry)) {
> -		page = *entry;
> -		goto finish_fault;
> -	}
> +	unsigned long vaddr = vmf->address;
> +	int ret = VM_FAULT_NOPAGE;
> +	struct page *zero_page;
> +	void *entry2;
>  
> -	/* This will replace locked radix tree entry with a hole page */
> -	page = find_or_create_page(mapping, vmf->pgoff,
> -				   vmf->gfp_mask | __GFP_ZERO);

With this gone, you can also remove the special DAX handling from
mm/filemap.c: page_cache_tree_insert() and remove from dax.h
dax_wake_mapping_entry_waiter(), dax_radix_locked_entry() and RADIX_DAX
definitions. Yay! As a separate patch please.

								Honza
-- 
Jan Kara <jack@suse.com>
SUSE Labs, CR

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

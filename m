Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f178.google.com (mail-pf0-f178.google.com [209.85.192.178])
	by kanga.kvack.org (Postfix) with ESMTP id 1261B6B0005
	for <linux-mm@kvack.org>; Wed,  6 Apr 2016 12:50:55 -0400 (EDT)
Received: by mail-pf0-f178.google.com with SMTP id c20so37231682pfc.1
        for <linux-mm@kvack.org>; Wed, 06 Apr 2016 09:50:55 -0700 (PDT)
Received: from mga14.intel.com (mga14.intel.com. [192.55.52.115])
        by mx.google.com with ESMTP id c7si5661542pat.49.2016.04.06.09.50.53
        for <linux-mm@kvack.org>;
        Wed, 06 Apr 2016 09:50:54 -0700 (PDT)
Date: Wed, 6 Apr 2016 12:50:27 -0400
From: Matthew Wilcox <willy@linux.intel.com>
Subject: Re: [PATCH] x86 get_unmapped_area: Add PMD alignment for DAX PMD mmap
Message-ID: <20160406165027.GA2781@linux.intel.com>
References: <1459951089-14911-1-git-send-email-toshi.kani@hpe.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1459951089-14911-1-git-send-email-toshi.kani@hpe.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Toshi Kani <toshi.kani@hpe.com>
Cc: mingo@kernel.org, bp@suse.de, hpa@zytor.com, tglx@linutronix.de, dan.j.williams@intel.com, kirill.shutemov@linux.intel.com, linux-mm@kvack.org, x86@kernel.org, linux-nvdimm@lists.01.org, linux-kernel@vger.kernel.org

On Wed, Apr 06, 2016 at 07:58:09AM -0600, Toshi Kani wrote:
> When CONFIG_FS_DAX_PMD is set, DAX supports mmap() using PMD page
> size.  This feature relies on both mmap virtual address and FS
> block data (i.e. physical address) to be aligned by the PMD page
> size.  Users can use mkfs options to specify FS to align block
> allocations.  However, aligning mmap() address requires application
> changes to mmap() calls, such as:
> 
>  -  /* let the kernel to assign a mmap addr */
>  -  mptr = mmap(NULL, fsize, PROT_READ|PROT_WRITE, FLAGS, fd, 0);
> 
>  +  /* 1. obtain a PMD-aligned virtual address */
>  +  ret = posix_memalign(&mptr, PMD_SIZE, fsize);
>  +  if (!ret)
>  +    free(mptr);  /* 2. release the virt addr */
>  +
>  +  /* 3. then pass the PMD-aligned virt addr to mmap() */
>  +  mptr = mmap(mptr, fsize, PROT_READ|PROT_WRITE, FLAGS, fd, 0);
> 
> These changes add unnecessary dependency to DAX and PMD page size
> into application code.  The kernel should assign a mmap address
> appropriate for the operation.

I question the need for this patch.  Choosing an appropriate base address
is the least of the changes needed for an application to take advantage of
DAX.  The NVML chooses appropriate addresses and gets a properly aligned
address without any kernel code.

> Change arch_get_unmapped_area() and arch_get_unmapped_area_topdown()
> to request PMD_SIZE alignment when the request is for a DAX file and
> its mapping range is large enough for using a PMD page.

I think this is the wrong place for it, if we decide that this is the
right thing to do.  The filesystem has a get_unmapped_area() which
should be used instead.

> @@ -157,6 +157,13 @@ arch_get_unmapped_area(struct file *filp, unsigned long addr,
>  		info.align_mask = get_align_mask();
>  		info.align_offset += get_align_bits();
>  	}
> +	if (filp && IS_ENABLED(CONFIG_FS_DAX_PMD) && IS_DAX(file_inode(filp))) {

And there's never a need for the IS_ENABLED.  IS_DAX() compiles to '0' if
CONFIG_FS_DAX is disabled.

And where would this end?  Would you also change this code to look for
1GB entries if CONFIG_FS_DAX_PUD is enabled?  Far better to have this
in the individual filesystem (probably calling a common helper in the DAX code).

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

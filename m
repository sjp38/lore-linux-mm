Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f169.google.com (mail-ig0-f169.google.com [209.85.213.169])
	by kanga.kvack.org (Postfix) with ESMTP id 832356B0005
	for <linux-mm@kvack.org>; Wed,  6 Apr 2016 13:52:57 -0400 (EDT)
Received: by mail-ig0-f169.google.com with SMTP id gy3so84039432igb.0
        for <linux-mm@kvack.org>; Wed, 06 Apr 2016 10:52:57 -0700 (PDT)
Received: from g1t5425.austin.hp.com (g1t5425.austin.hp.com. [15.216.225.55])
        by mx.google.com with ESMTPS id g79si4005604ioe.130.2016.04.06.10.52.56
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 06 Apr 2016 10:52:57 -0700 (PDT)
Message-ID: <1459964672.20338.41.camel@hpe.com>
Subject: Re: [PATCH] x86 get_unmapped_area: Add PMD alignment for DAX PMD
 mmap
From: Toshi Kani <toshi.kani@hpe.com>
Date: Wed, 06 Apr 2016 11:44:32 -0600
In-Reply-To: <20160406165027.GA2781@linux.intel.com>
References: <1459951089-14911-1-git-send-email-toshi.kani@hpe.com>
	 <20160406165027.GA2781@linux.intel.com>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Matthew Wilcox <willy@linux.intel.com>
Cc: mingo@kernel.org, bp@suse.de, hpa@zytor.com, tglx@linutronix.de, dan.j.williams@intel.com, kirill.shutemov@linux.intel.com, linux-mm@kvack.org, x86@kernel.org, linux-nvdimm@lists.01.org, linux-kernel@vger.kernel.org

On Wed, 2016-04-06 at 12:50 -0400, Matthew Wilcox wrote:
> On Wed, Apr 06, 2016 at 07:58:09AM -0600, Toshi Kani wrote:
> > 
> > When CONFIG_FS_DAX_PMD is set, DAX supports mmap() using PMD page
> > size.A A This feature relies on both mmap virtual address and FS
> > block data (i.e. physical address) to be aligned by the PMD page
> > size.A A Users can use mkfs options to specify FS to align block
> > allocations.A A However, aligning mmap() address requires application
> > changes to mmap() calls, such as:
> > 
> > A -A A /* let the kernel to assign a mmap addr */
> > A -A A mptr = mmap(NULL, fsize, PROT_READ|PROT_WRITE, FLAGS, fd, 0);
> > 
> > A +A A /* 1. obtain a PMD-aligned virtual address */
> > A +A A ret = posix_memalign(&mptr, PMD_SIZE, fsize);
> > A +A A if (!ret)
> > A +A A A A free(mptr);A A /* 2. release the virt addr */
> > A +
> > A +A A /* 3. then pass the PMD-aligned virt addr to mmap() */
> > A +A A mptr = mmap(mptr, fsize, PROT_READ|PROT_WRITE, FLAGS, fd, 0);
> > 
> > These changes add unnecessary dependency to DAX and PMD page size
> > into application code.A A The kernel should assign a mmap address
> > appropriate for the operation.
>
> I question the need for this patch.A A Choosing an appropriate base address
> is the least of the changes needed for an application to take advantage
> of DAX.A A 

An application also needs to make sure that a given range [base -
base+size] is free in VMA. A The above example uses posix_memalign() to find
such a range, which in turn calls mmap() with size as (fsize + PMD_SIZE) in
this case.

> The NVML chooses appropriate addresses and gets a properly aligned
> address without any kernel code.

An application like NVML can continue to specify a specific address to
mmap(). A Most existing applications, however, do not specify an address to
mmap(). A With this patch, specifying an address will remain optional.

> > Change arch_get_unmapped_area() and arch_get_unmapped_area_topdown()
> > to request PMD_SIZE alignment when the request is for a DAX file and
> > its mapping range is large enough for using a PMD page.
>
> I think this is the wrong place for it, if we decide that this is the
> right thing to do.A A The filesystem has a get_unmapped_area() which
> should be used instead.

Yes, I considered adding a filesystem entry point, but decided going this
way because:
A -A arch_get_unmapped_area() andA arch_get_unmapped_area_topdown() are arch-
specific code. A Therefore, this filesystem entry point will need arch-
specific implementation.A 
A - There is nothing filesystem specific about requesting PMD alignment.

> > 
> > @@ -157,6 +157,13 @@ arch_get_unmapped_area(struct file *filp, unsigned
> > long addr,
> > A 		info.align_mask = get_align_mask();
> > A 		info.align_offset += get_align_bits();
> > A 	}
> > +	if (filp && IS_ENABLED(CONFIG_FS_DAX_PMD) &&
> > IS_DAX(file_inode(filp))) {
>
> And there's never a need for the IS_ENABLED.A A IS_DAX() compiles to '0' if
> CONFIG_FS_DAX is disabled.

CONFIG_FS_DAX_PMD can be disabled while CONFIG_FS_DAX is enabled.

> And where would this end?A A Would you also change this code to look for
> 1GB entries if CONFIG_FS_DAX_PUD is enabled?A A Far better to have this
> in the individual filesystem (probably calling a common helper in the DAX
> code).

Yes, it can be easily extended to support PUD. A This avoids another round
of application changes to align with the PUD size.

If the PUD support turns out to be filesystem specific, we may need a
capability bit in addition to CONFIG_FS_DAX_PUD.

Thanks,
-Toshi

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

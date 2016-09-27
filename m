Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f200.google.com (mail-io0-f200.google.com [209.85.223.200])
	by kanga.kvack.org (Postfix) with ESMTP id 8DE696B0267
	for <linux-mm@kvack.org>; Tue, 27 Sep 2016 17:47:36 -0400 (EDT)
Received: by mail-io0-f200.google.com with SMTP id 82so65704951ioh.1
        for <linux-mm@kvack.org>; Tue, 27 Sep 2016 14:47:36 -0700 (PDT)
Received: from ipmail06.adl6.internode.on.net (ipmail06.adl6.internode.on.net. [150.101.137.145])
        by mx.google.com with ESMTP id b32si5652027ioj.212.2016.09.27.14.47.35
        for <linux-mm@kvack.org>;
        Tue, 27 Sep 2016 14:47:36 -0700 (PDT)
Date: Wed, 28 Sep 2016 07:47:20 +1000
From: Dave Chinner <david@fromorbit.com>
Subject: Re: [PATCH v3 04/11] ext2: remove support for DAX PMD faults
Message-ID: <20160927214720.GD27872@dastard>
References: <1475009282-9818-1-git-send-email-ross.zwisler@linux.intel.com>
 <1475009282-9818-5-git-send-email-ross.zwisler@linux.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1475009282-9818-5-git-send-email-ross.zwisler@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ross Zwisler <ross.zwisler@linux.intel.com>
Cc: linux-kernel@vger.kernel.org, Theodore Ts'o <tytso@mit.edu>, Alexander Viro <viro@zeniv.linux.org.uk>, Andreas Dilger <adilger.kernel@dilger.ca>, Andrew Morton <akpm@linux-foundation.org>, Christoph Hellwig <hch@lst.de>, Dan Williams <dan.j.williams@intel.com>, Jan Kara <jack@suse.com>, Matthew Wilcox <mawilcox@microsoft.com>, linux-ext4@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, linux-nvdimm@lists.01.org, linux-xfs@vger.kernel.org

On Tue, Sep 27, 2016 at 02:47:55PM -0600, Ross Zwisler wrote:
> DAX PMD support was added via the following commit:
> 
> commit e7b1ea2ad658 ("ext2: huge page fault support")
> 
> I believe this path to be untested as ext2 doesn't reliably provide block
> allocations that are aligned to 2MiB.  In my testing I've been unable to
> get ext2 to actually fault in a PMD.  It always fails with a "pfn
> unaligned" message because the sector returned by ext2_get_block() isn't
> aligned.
> 
> I've tried various settings for the "stride" and "stripe_width" extended
> options to mkfs.ext2, without any luck.
> 
> Since we can't reliably get PMDs, remove support so that we don't have an
> untested code path that we may someday traverse when we happen to get an
> aligned block allocation.  This should also make 4k DAX faults in ext2 a
> bit faster since they will no longer have to call the PMD fault handler
> only to get a response of VM_FAULT_FALLBACK.
> 
> Signed-off-by: Ross Zwisler <ross.zwisler@linux.intel.com>
....
> @@ -154,7 +133,6 @@ static int ext2_dax_pfn_mkwrite(struct vm_area_struct *vma,
>  
>  static const struct vm_operations_struct ext2_dax_vm_ops = {
>  	.fault		= ext2_dax_fault,
> -	.pmd_fault	= ext2_dax_pmd_fault,
>  	.page_mkwrite	= ext2_dax_fault,
>  	.pfn_mkwrite	= ext2_dax_pfn_mkwrite,
>  };

Would it be better to put a comment mentioning this here? So as the
years go by, this reminds people not to bother trying to implement
it?

/*
 * .pmd_fault is not supported for DAX because allocation in ext2
 * cannot be reliably aligned to huge page sizes and so pmd faults
 * will always fail and fail back to regular faults.
 */

-- 
Dave Chinner
david@fromorbit.com

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

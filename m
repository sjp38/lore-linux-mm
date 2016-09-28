Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f71.google.com (mail-pa0-f71.google.com [209.85.220.71])
	by kanga.kvack.org (Postfix) with ESMTP id 2D82828025A
	for <linux-mm@kvack.org>; Wed, 28 Sep 2016 14:46:48 -0400 (EDT)
Received: by mail-pa0-f71.google.com with SMTP id fu14so97801077pad.0
        for <linux-mm@kvack.org>; Wed, 28 Sep 2016 11:46:48 -0700 (PDT)
Received: from mga07.intel.com (mga07.intel.com. [134.134.136.100])
        by mx.google.com with ESMTPS id ba4si9705727pab.253.2016.09.28.11.46.45
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 28 Sep 2016 11:46:46 -0700 (PDT)
Date: Wed, 28 Sep 2016 12:46:43 -0600
From: Ross Zwisler <ross.zwisler@linux.intel.com>
Subject: Re: [PATCH v3 04/11] ext2: remove support for DAX PMD faults
Message-ID: <20160928184643.GA16000@linux.intel.com>
References: <1475009282-9818-1-git-send-email-ross.zwisler@linux.intel.com>
 <1475009282-9818-5-git-send-email-ross.zwisler@linux.intel.com>
 <20160927214720.GD27872@dastard>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20160927214720.GD27872@dastard>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Chinner <david@fromorbit.com>
Cc: Ross Zwisler <ross.zwisler@linux.intel.com>, linux-kernel@vger.kernel.org, Theodore Ts'o <tytso@mit.edu>, Alexander Viro <viro@zeniv.linux.org.uk>, Andreas Dilger <adilger.kernel@dilger.ca>, Andrew Morton <akpm@linux-foundation.org>, Christoph Hellwig <hch@lst.de>, Dan Williams <dan.j.williams@intel.com>, Jan Kara <jack@suse.com>, Matthew Wilcox <mawilcox@microsoft.com>, linux-ext4@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, linux-nvdimm@lists.01.org, linux-xfs@vger.kernel.org

On Wed, Sep 28, 2016 at 07:47:20AM +1000, Dave Chinner wrote:
> On Tue, Sep 27, 2016 at 02:47:55PM -0600, Ross Zwisler wrote:
> > DAX PMD support was added via the following commit:
> > 
> > commit e7b1ea2ad658 ("ext2: huge page fault support")
> > 
> > I believe this path to be untested as ext2 doesn't reliably provide block
> > allocations that are aligned to 2MiB.  In my testing I've been unable to
> > get ext2 to actually fault in a PMD.  It always fails with a "pfn
> > unaligned" message because the sector returned by ext2_get_block() isn't
> > aligned.
> > 
> > I've tried various settings for the "stride" and "stripe_width" extended
> > options to mkfs.ext2, without any luck.
> > 
> > Since we can't reliably get PMDs, remove support so that we don't have an
> > untested code path that we may someday traverse when we happen to get an
> > aligned block allocation.  This should also make 4k DAX faults in ext2 a
> > bit faster since they will no longer have to call the PMD fault handler
> > only to get a response of VM_FAULT_FALLBACK.
> > 
> > Signed-off-by: Ross Zwisler <ross.zwisler@linux.intel.com>
> ....
> > @@ -154,7 +133,6 @@ static int ext2_dax_pfn_mkwrite(struct vm_area_struct *vma,
> >  
> >  static const struct vm_operations_struct ext2_dax_vm_ops = {
> >  	.fault		= ext2_dax_fault,
> > -	.pmd_fault	= ext2_dax_pmd_fault,
> >  	.page_mkwrite	= ext2_dax_fault,
> >  	.pfn_mkwrite	= ext2_dax_pfn_mkwrite,
> >  };
> 
> Would it be better to put a comment mentioning this here? So as the
> years go by, this reminds people not to bother trying to implement
> it?
> 
> /*
>  * .pmd_fault is not supported for DAX because allocation in ext2
>  * cannot be reliably aligned to huge page sizes and so pmd faults
>  * will always fail and fail back to regular faults.
>  */

Sure, this seems like a good idea.  I'll add it, thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

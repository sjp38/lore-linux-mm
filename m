Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f197.google.com (mail-qk0-f197.google.com [209.85.220.197])
	by kanga.kvack.org (Postfix) with ESMTP id CD5B46B007E
	for <linux-mm@kvack.org>; Fri, 15 Apr 2016 10:55:46 -0400 (EDT)
Received: by mail-qk0-f197.google.com with SMTP id x7so153431076qkd.2
        for <linux-mm@kvack.org>; Fri, 15 Apr 2016 07:55:46 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id k33si19823587qkh.127.2016.04.15.07.55.45
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 15 Apr 2016 07:55:46 -0700 (PDT)
From: Jeff Moyer <jmoyer@redhat.com>
Subject: Re: [PATCH v2 2/5] dax: fallback from pmd to pte on error
References: <1459303190-20072-1-git-send-email-vishal.l.verma@intel.com>
	<1459303190-20072-3-git-send-email-vishal.l.verma@intel.com>
Date: Fri, 15 Apr 2016 10:55:43 -0400
In-Reply-To: <1459303190-20072-3-git-send-email-vishal.l.verma@intel.com>
	(Vishal Verma's message of "Tue, 29 Mar 2016 19:59:47 -0600")
Message-ID: <x497ffy7wgg.fsf@segfault.boston.devel.redhat.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vishal Verma <vishal.l.verma@intel.com>
Cc: linux-nvdimm@ml01.01.org, Jens Axboe <axboe@fb.com>, Jan Kara <jack@suse.cz>, Andrew Morton <akpm@linux-foundation.org>, Christoph Hellwig <hch@infradead.org>, Dave Chinner <david@fromorbit.com>, linux-kernel@vger.kernel.org, xfs@oss.sgi.com, linux-block@vger.kernel.org, linux-mm@kvack.org, Matthew Wilcox <matthew.r.wilcox@intel.com>, linux-fsdevel@vger.kernel.org, linux-ext4@vger.kernel.org, Al Viro <viro@zeniv.linux.org.uk>

Vishal Verma <vishal.l.verma@intel.com> writes:

> From: Dan Williams <dan.j.williams@intel.com>
>
> In preparation for consulting a badblocks list in pmem_direct_access(),
> teach dax_pmd_fault() to fallback rather than fail immediately upon
> encountering an error.  The thought being that reducing the span of the
> dax request may avoid the error region.
>
> Signed-off-by: Dan Williams <dan.j.williams@intel.com>

Reviewed-by: Jeff Moyer <jmoyer@redhat.com>

> ---
>  fs/dax.c | 4 ++--
>  1 file changed, 2 insertions(+), 2 deletions(-)
>
> diff --git a/fs/dax.c b/fs/dax.c
> index 90322eb..ec6417b 100644
> --- a/fs/dax.c
> +++ b/fs/dax.c
> @@ -945,8 +945,8 @@ int __dax_pmd_fault(struct vm_area_struct *vma, unsigned long address,
>  		long length = dax_map_atomic(bdev, &dax);
>  
>  		if (length < 0) {
> -			result = VM_FAULT_SIGBUS;
> -			goto out;
> +			dax_pmd_dbg(&bh, address, "dax-error fallback");
> +			goto fallback;
>  		}
>  		if (length < PMD_SIZE) {
>  			dax_pmd_dbg(&bh, address, "dax-length too small");

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

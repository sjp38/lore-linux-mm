Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f177.google.com (mail-wi0-f177.google.com [209.85.212.177])
	by kanga.kvack.org (Postfix) with ESMTP id 5EB506B0254
	for <linux-mm@kvack.org>; Tue,  1 Sep 2015 06:54:30 -0400 (EDT)
Received: by wibz8 with SMTP id z8so27740853wib.1
        for <linux-mm@kvack.org>; Tue, 01 Sep 2015 03:54:30 -0700 (PDT)
Received: from mail-wi0-f171.google.com (mail-wi0-f171.google.com. [209.85.212.171])
        by mx.google.com with ESMTPS id li14si2521538wic.1.2015.09.01.03.54.28
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 01 Sep 2015 03:54:29 -0700 (PDT)
Received: by wicfx3 with SMTP id fx3so7971723wic.0
        for <linux-mm@kvack.org>; Tue, 01 Sep 2015 03:54:28 -0700 (PDT)
Message-ID: <55E583E2.9000200@plexistor.com>
Date: Tue, 01 Sep 2015 13:54:26 +0300
From: Boaz Harrosh <boaz@plexistor.com>
MIME-Version: 1.0
Subject: Re: [PATCH] mm, dax: VMA with vm_ops->pfn_mkwrite wants to be write-notified
References: <1441102961-68041-1-git-send-email-kirill.shutemov@linux.intel.com>
In-Reply-To: <1441102961-68041-1-git-send-email-kirill.shutemov@linux.intel.com>
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Andrew Morton <akpm@linux-foundation.org>, Matthew Wilcox <matthew.r.wilcox@intel.com>
Cc: linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org, linux-nvdimm@lists.01.org, Yigal Korman <yigal@plexistor.com>, Jan Kara <jack@suse.cz>, Dave Chinner <david@fromorbit.com>

On 09/01/2015 01:22 PM, Kirill A. Shutemov wrote:
> For VM_PFNMAP and VM_MIXEDMAP we use vm_ops->pfn_mkwrite instead of
> vm_ops->page_mkwrite to notify abort write access. This means we want
> vma->vm_page_prot to be write-protected if the VMA provides this vm_ops.
> 

Hi Kirill

I will test with this right away and ACK on this.

Hmm so are you saying we might be missing some buffer modifications right now.

What would be a theoretical scenario that will cause these missed events?
I would like to put a test in our test rigs that should fail today and this
patch fixes.

[In our system every modified pmem block is also RDMAed to a remote
 pmem for HA, a missed modification will make the two copies unsynced]

Thanks for catching this
Boaz

> Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
> Cc: Yigal Korman <yigal@plexistor.com>
> Cc: Boaz Harrosh <boaz@plexistor.com>
> Cc: Matthew Wilcox <matthew.r.wilcox@intel.com>
> Cc: Jan Kara <jack@suse.cz>
> Cc: Dave Chinner <david@fromorbit.com>
> ---
>  mm/mmap.c | 3 ++-
>  1 file changed, 2 insertions(+), 1 deletion(-)
> 
> diff --git a/mm/mmap.c b/mm/mmap.c
> index df6d5f07035b..3f78bceefe5a 100644
> --- a/mm/mmap.c
> +++ b/mm/mmap.c
> @@ -1498,7 +1498,8 @@ int vma_wants_writenotify(struct vm_area_struct *vma)
>  		return 0;
>  
>  	/* The backer wishes to know when pages are first written to? */
> -	if (vma->vm_ops && vma->vm_ops->page_mkwrite)
> +	if (vma->vm_ops &&
> +			(vma->vm_ops->page_mkwrite || vma->vm_ops->pfn_mkwrite))
>  		return 1;
>  
>  	/* The open routine did something to the protections that pgprot_modify
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

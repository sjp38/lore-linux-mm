Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf1-f199.google.com (mail-pf1-f199.google.com [209.85.210.199])
	by kanga.kvack.org (Postfix) with ESMTP id 1D27C6B000D
	for <linux-mm@kvack.org>; Thu, 18 Oct 2018 23:36:18 -0400 (EDT)
Received: by mail-pf1-f199.google.com with SMTP id l1-v6so30961599pfb.7
        for <linux-mm@kvack.org>; Thu, 18 Oct 2018 20:36:18 -0700 (PDT)
Received: from ipmailnode02.adl6.internode.on.net (ipmailnode02.adl6.internode.on.net. [150.101.137.148])
        by mx.google.com with ESMTP id e11-v6si22969333pgi.139.2018.10.18.20.36.16
        for <linux-mm@kvack.org>;
        Thu, 18 Oct 2018 20:36:17 -0700 (PDT)
Date: Fri, 19 Oct 2018 14:36:12 +1100
From: Dave Chinner <david@fromorbit.com>
Subject: Re: [PATCH 6/7] mm: allow ->page_mkwrite to do retries
Message-ID: <20181019033612.GL18822@dastard>
References: <20181018202318.9131-1-josef@toxicpanda.com>
 <20181018202318.9131-7-josef@toxicpanda.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20181018202318.9131-7-josef@toxicpanda.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Josef Bacik <josef@toxicpanda.com>
Cc: kernel-team@fb.com, hannes@cmpxchg.org, linux-kernel@vger.kernel.org, tj@kernel.org, akpm@linux-foundation.org, linux-fsdevel@vger.kernel.org, linux-btrfs@vger.kernel.org, riel@fb.com, linux-mm@kvack.org

On Thu, Oct 18, 2018 at 04:23:17PM -0400, Josef Bacik wrote:
> Before we didn't set the retry flag on our vm_fault.  We want to allow
> file systems to drop the mmap_sem if they so choose, so set this flag
> and deal with VM_FAULT_RETRY appropriately.
> 
> Signed-off-by: Josef Bacik <josef@toxicpanda.com>
> ---
>  mm/memory.c | 10 +++++++---
>  1 file changed, 7 insertions(+), 3 deletions(-)
> 
> diff --git a/mm/memory.c b/mm/memory.c
> index 433075f722ea..c5e81edd94f9 100644
> --- a/mm/memory.c
> +++ b/mm/memory.c
> @@ -2384,11 +2384,13 @@ static vm_fault_t do_page_mkwrite(struct vm_fault *vmf)
>  	unsigned int old_flags = vmf->flags;
>  
>  	vmf->flags = FAULT_FLAG_WRITE|FAULT_FLAG_MKWRITE;
> +	vmf->flags |= old_flags & FAULT_FLAG_ALLOW_RETRY;
>  
>  	ret = vmf->vma->vm_ops->page_mkwrite(vmf);
>  	/* Restore original flags so that caller is not surprised */
>  	vmf->flags = old_flags;


> -	if (unlikely(ret & (VM_FAULT_ERROR | VM_FAULT_NOPAGE)))
> +	if (unlikely(ret & (VM_FAULT_ERROR | VM_FAULT_NOPAGE |
> +			    VM_FAULT_RETRY)))

Mess.

#define __FAIL_FLAGS	(VM_FAULT_ERROR | VM_FAULT_NOPAGE | VM_FAULT_RETRY)
	if (ret & __FAIL_FLAGS)

Should kill the unlikely() at the same time.

-Dave.
-- 
Dave Chinner
david@fromorbit.com

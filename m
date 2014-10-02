Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ob0-f169.google.com (mail-ob0-f169.google.com [209.85.214.169])
	by kanga.kvack.org (Postfix) with ESMTP id EBB876B006E
	for <linux-mm@kvack.org>; Thu,  2 Oct 2014 15:43:17 -0400 (EDT)
Received: by mail-ob0-f169.google.com with SMTP id m8so2867127obr.14
        for <linux-mm@kvack.org>; Thu, 02 Oct 2014 12:43:17 -0700 (PDT)
Received: from mail-oi0-x232.google.com (mail-oi0-x232.google.com [2607:f8b0:4003:c06::232])
        by mx.google.com with ESMTPS id zl1si3804456obc.11.2014.10.02.12.43.16
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Thu, 02 Oct 2014 12:43:16 -0700 (PDT)
Received: by mail-oi0-f50.google.com with SMTP id i138so2357374oig.37
        for <linux-mm@kvack.org>; Thu, 02 Oct 2014 12:43:16 -0700 (PDT)
Date: Thu, 2 Oct 2014 12:41:30 -0700 (PDT)
From: Hugh Dickins <hughd@google.com>
Subject: Re: [PATCH] mm: mempolicy: Skip inaccessible VMAs when setting
 MPOL_MF_LAZY
In-Reply-To: <20141002191703.GN17501@suse.de>
Message-ID: <alpine.LSU.2.11.1410021233280.7589@eggly.anvils>
References: <20141002191703.GN17501@suse.de>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>, Peter Zijlstra <peterz@infradead.org>, Hugh Dickins <hughd@google.com>, Linux Kernel <linux-kernel@vger.kernel.org>, linux-mm@kvack.org

On Thu, 2 Oct 2014, Mel Gorman wrote:

> PROT_NUMA VMAs are skipped to avoid problems distinguishing between
> present, prot_none and special entries. MPOL_MF_LAZY is not visible from
> userspace since commit a720094ded8c ("mm: mempolicy: Hide MPOL_NOOP and
> MPOL_MF_LAZY from userspace for now") but it should still skip VMAs the
> same way task_numa_work does.
> 
> Signed-off-by: Mel Gorman <mgorman@suse.de>
> Acked-by: Rik van Riel <riel@redhat.com>

Acked-by: Hugh Dickins <hughd@google.com>

Yes, this is much the same as the patch I wrote for Linus two days ago,
then discovered that we don't need until MPOL_MF_LAZY gets brought back
into MPOL_MF_VALID.  (As a bonus, my patch did also remove the currently
bogus paragraph of comment above change_prot_numa(); and I would prefer a
code comment to make clear that we never exercise this path at present.) 

> ---
>  mm/mempolicy.c | 4 +++-
>  1 file changed, 3 insertions(+), 1 deletion(-)
> 
> diff --git a/mm/mempolicy.c b/mm/mempolicy.c
> index 8f5330d..a5877ce 100644
> --- a/mm/mempolicy.c
> +++ b/mm/mempolicy.c
> @@ -683,7 +683,9 @@ queue_pages_range(struct mm_struct *mm, unsigned long start, unsigned long end,
>  		}
>  
>  		if (flags & MPOL_MF_LAZY) {
> -			change_prot_numa(vma, start, endvma);
> +			/* Similar to task_numa_work, skip inaccessible VMAs */
> +			if (vma->vm_flags & (VM_READ | VM_EXEC | VM_WRITE))
> +				change_prot_numa(vma, start, endvma);
>  			goto next;
>  		}
>  

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

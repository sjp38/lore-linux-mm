Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f52.google.com (mail-wg0-f52.google.com [74.125.82.52])
	by kanga.kvack.org (Postfix) with ESMTP id CD0306B0069
	for <linux-mm@kvack.org>; Thu,  2 Oct 2014 15:59:12 -0400 (EDT)
Received: by mail-wg0-f52.google.com with SMTP id a1so4132238wgh.11
        for <linux-mm@kvack.org>; Thu, 02 Oct 2014 12:59:12 -0700 (PDT)
Received: from casper.infradead.org (casper.infradead.org. [2001:770:15f::2])
        by mx.google.com with ESMTPS id el5si2349069wib.22.2014.10.02.12.59.10
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 02 Oct 2014 12:59:10 -0700 (PDT)
Date: Thu, 2 Oct 2014 21:59:03 +0200
From: Peter Zijlstra <peterz@infradead.org>
Subject: Re: [PATCH] mm: mempolicy: Skip inaccessible VMAs when setting
 MPOL_MF_LAZY
Message-ID: <20141002195903.GE10583@worktop.programming.kicks-ass.net>
References: <20141002191703.GN17501@suse.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20141002191703.GN17501@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>, Hugh Dickins <hughd@google.com>, Linux Kernel <linux-kernel@vger.kernel.org>, linux-mm@kvack.org

On Thu, Oct 02, 2014 at 08:17:03PM +0100, Mel Gorman wrote:
> PROT_NUMA VMAs are skipped to avoid problems distinguishing between
> present, prot_none and special entries. MPOL_MF_LAZY is not visible from
> userspace since commit a720094ded8c ("mm: mempolicy: Hide MPOL_NOOP and
> MPOL_MF_LAZY from userspace for now") but it should still skip VMAs the
> same way task_numa_work does.
> 
> Signed-off-by: Mel Gorman <mgorman@suse.de>
> Acked-by: Rik van Riel <riel@redhat.com>

Acked-by: Peter Zijlstra <peterz@infradead.org>

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

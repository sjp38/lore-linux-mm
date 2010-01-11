Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with SMTP id 2663F6B0078
	for <linux-mm@kvack.org>; Mon, 11 Jan 2010 18:40:59 -0500 (EST)
Date: Mon, 11 Jan 2010 23:40:47 +0000 (GMT)
From: Hugh Dickins <hugh.dickins@tiscali.co.uk>
Subject: Re: [PATCH -mmotm-2010-01-06-14-34] Count minor fault in break_ksm
In-Reply-To: <20100111114607.1d8cd1e0.minchan.kim@barrios-desktop>
Message-ID: <alpine.LSU.2.00.1001112334250.7893@sister.anvils>
References: <20100111114607.1d8cd1e0.minchan.kim@barrios-desktop>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Minchan Kim <minchan.kim@gmail.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Izik Eidus <ieidus@redhat.com>, linux-mm <linux-mm@kvack.org>, lkml <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

On Mon, 11 Jan 2010, Minchan Kim wrote:

> We have counted task's maj/min fault after handle_mm_fault.
> break_ksm misses that.
> 
> I wanted to check by VM_FAULT_ERROR. 
> But now break_ksm doesn't handle HWPOISON error. 

Sorry, no, I just don't see a good reason to add this.
Imagine it this way: these aren't really faults, KSM simply
happens to be using "handle_mm_fault" to achieve what it needs.

(And, of course, if we did add something like this, I'd be
disagreeing with you about which tsk's min_flt to increment.)

Hugh

> 
> Signed-off-by: Minchan Kim <minchan.kim@gmail.com>
> CC: Hugh Dickins <hugh.dickins@tiscali.co.uk>
> CC: Izik Eidus <ieidus@redhat.com>
> ---
>  mm/ksm.c |    6 +++++-
>  1 files changed, 5 insertions(+), 1 deletions(-)
> 
> diff --git a/mm/ksm.c b/mm/ksm.c
> index 56a0da1..3a1fda4 100644
> --- a/mm/ksm.c
> +++ b/mm/ksm.c
> @@ -367,9 +367,13 @@ static int break_ksm(struct vm_area_struct *vma, unsigned long addr)
>  		page = follow_page(vma, addr, FOLL_GET);
>  		if (!page)
>  			break;
> -		if (PageKsm(page))
> +		if (PageKsm(page)) {
>  			ret = handle_mm_fault(vma->vm_mm, vma, addr,
>  							FAULT_FLAG_WRITE);
> +			if (!(ret & (VM_FAULT_SIGBUS | VM_FAULT_OOM)
> +					|| current->flags & PF_KTHREAD))
> +				current->min_flt++;
> +		}
>  		else
>  			ret = VM_FAULT_WRITE;
>  		put_page(page);
> -- 
> 1.5.6.3
> 
> 
> 
> -- 
> Kind regards,
> Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

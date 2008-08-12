Subject: Re: [RFC PATCH for -mm 4/5] fix mlock return value at munmap race
From: Lee Schermerhorn <Lee.Schermerhorn@hp.com>
In-Reply-To: <20080811160642.9462.KOSAKI.MOTOHIRO@jp.fujitsu.com>
References: <20080811151313.9456.KOSAKI.MOTOHIRO@jp.fujitsu.com>
	 <20080811160642.9462.KOSAKI.MOTOHIRO@jp.fujitsu.com>
Content-Type: text/plain
Date: Tue, 12 Aug 2008 16:19:09 -0400
Message-Id: <1218572349.6360.126.camel@lts-notebook>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: linux-mm <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>
List-ID: <linux-mm.kvack.org>

On Mon, 2008-08-11 at 16:07 +0900, KOSAKI Motohiro wrote:
> Now, We call downgrade_write(&mm->mmap_sem) at begin of mlock.
> It increase mlock scalability.
> 
> But if mlock and munmap conflict happend, We can find vma gone.
> At that time, kernel should return ENOMEM because mlock after munmap return ENOMEM.
> (in addition, EAGAIN indicate "please try again", but mlock() called again cause error again)
> 
> This problem is theoretical issue.
> I can't reproduce that vma gone on my box, but fixes is better.

OK.

Reviewed-by:  Lee Schermerhorn <lee.schermerhorn@hp.com>

> 
> 
> Signed-off-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
> 
> ---
>  mm/mlock.c |    4 ++--
>  1 file changed, 2 insertions(+), 2 deletions(-)
> 
> Index: b/mm/mlock.c
> ===================================================================
> --- a/mm/mlock.c
> +++ b/mm/mlock.c
> @@ -296,7 +296,7 @@ int mlock_vma_pages_range(struct vm_area
>  		vma = find_vma(mm, start);
>  		/* non-NULL vma must contain @start, but need to check @end */
>  		if (!vma ||  end > vma->vm_end)
> -			return -EAGAIN;
> +			return -ENOMEM;
>  		return error;
>  	}
>  
> @@ -410,7 +410,7 @@ success:
>  		*prev = find_vma(mm, start);
>  		/* non-NULL *prev must contain @start, but need to check @end */
>  		if (!(*prev) || end > (*prev)->vm_end)
> -			ret = -EAGAIN;
> +			ret = -ENOMEM;
>  	} else {
>  		/*
>  		 * TODO:  for unlocking, pages will already be resident, so
> 
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

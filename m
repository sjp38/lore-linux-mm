Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with ESMTP id 3D21E6B004F
	for <linux-mm@kvack.org>; Wed,  9 Sep 2009 12:25:45 -0400 (EDT)
Date: Wed, 9 Sep 2009 18:25:50 +0200
From: Nick Piggin <npiggin@suse.de>
Subject: Re: [PATCH] add vma->ops check before do_nonlinear_fault()
Message-ID: <20090909162550.GG6034@wotan.suse.de>
References: <1252513094-8731-1-git-send-email-BollLiu@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1252513094-8731-1-git-send-email-BollLiu@gmail.com>
Sender: owner-linux-mm@kvack.org
To: Boll Liu <bollliu@gmail.com>
Cc: akpm@linux-foundation.org, linux-mm@kvack.org, kamezawa.hiroyu@jp.fujitsu.com
List-ID: <linux-mm.kvack.org>

On Thu, Sep 10, 2009 at 12:18:14AM +0800, Boll Liu wrote:
> Function do_nonlinear_fault() will also call vma->vm_ops->fault().
> So add vma->ops and vma->vm_ops->fault check the same as before
> calling do_nonlinear_fault().

I don't think we'd ever install a pte_file entry there for a
filesystem that cannot handle it (ie. does not have a ->fault).
So I don't think this is needed.

> 
> Signed-off-by: Boll Liu <BollLiu@gmail.com>
> ---
>  mm/memory.c |   10 +++++++---
>  1 files changed, 7 insertions(+), 3 deletions(-)
> 
> diff --git a/mm/memory.c b/mm/memory.c
> index aede2ce..86ebdd6 100644
> --- a/mm/memory.c
> +++ b/mm/memory.c
> @@ -2921,9 +2921,13 @@ static inline int handle_pte_fault(struct mm_struct *mm,
>  			return do_anonymous_page(mm, vma, address,
>  						 pte, pmd, flags);
>  		}
> -		if (pte_file(entry))
> -			return do_nonlinear_fault(mm, vma, address,
> -					pte, pmd, flags, entry);
> +		if (pte_file(entry)) {
> +			if (vma->vm_ops) {
> +				if (likely(vma->vm_ops->fault))
> +					return do_nonlinear_fault(mm, vma, address,
> +						pte, pmd, flags, entry);
> +			}
> +		}
>  		return do_swap_page(mm, vma, address,
>  					pte, pmd, flags, entry);
>  	}
> -- 
> 1.5.6.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx195.postini.com [74.125.245.195])
	by kanga.kvack.org (Postfix) with SMTP id 1351A6B0068
	for <linux-mm@kvack.org>; Thu,  9 Aug 2012 21:27:23 -0400 (EDT)
Received: by ggnf4 with SMTP id f4so1348442ggn.14
        for <linux-mm@kvack.org>; Thu, 09 Aug 2012 18:27:22 -0700 (PDT)
Date: Thu, 9 Aug 2012 18:26:34 -0700 (PDT)
From: Hugh Dickins <hughd@google.com>
Subject: Re: [patch] mmap: feed back correct prev vma when finding vma
In-Reply-To: <CAJd=RBAjGaOXfQQ_NX+ax6=tJJ0eg7EXCFHz3rdvSR3j1K3qHA@mail.gmail.com>
Message-ID: <alpine.LSU.2.00.1208091816240.9631@eggly.anvils>
References: <CAJd=RBAjGaOXfQQ_NX+ax6=tJJ0eg7EXCFHz3rdvSR3j1K3qHA@mail.gmail.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hillf Danton <dhillf@gmail.com>
Cc: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Mikulas Patocka <mpatocka@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>

On Thu, 9 Aug 2012, Hillf Danton wrote:
> After walking rb tree, if vma is determined, prev vma has to be determined
> based on vma; and rb_prev should be considered only if no vma determined.

Why?  Because you think more code is better code?  I disagree.

If you have seen a bug here, please tell how to reproduce it.

I have not heard of a bug here: I think you're saying, if the rbtree
were inconsistent with the vma list, then you think it would be a good
idea to believe the vma list instead of the rbtree where there's a choice.

But the rbtree had better not be inconsistent with the vma list.

Hugh

> 
> Signed-off-by: Hillf Danton <dhillf@gmail.com>
> ---
> 
> --- a/mm/mmap.c	Fri Aug  3 07:38:10 2012
> +++ b/mm/mmap.c	Mon Aug  6 20:10:18 2012
> @@ -385,9 +385,13 @@ find_vma_prepare(struct mm_struct *mm, u
>  		}
>  	}
> 
> -	*pprev = NULL;
> -	if (rb_prev)
> -		*pprev = rb_entry(rb_prev, struct vm_area_struct, vm_rb);
> +	if (vma) {
> +		*pprev = vma->vm_prev;
> +	} else {
> +		*pprev = NULL;
> +		if (rb_prev)
> +			*pprev = rb_entry(rb_prev, struct vm_area_struct, vm_rb);
> +	}
>  	*rb_link = __rb_link;
>  	*rb_parent = __rb_parent;
>  	return vma;
> --

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

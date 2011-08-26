Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta8.messagelabs.com (mail6.bemta8.messagelabs.com [216.82.243.55])
	by kanga.kvack.org (Postfix) with ESMTP id D78416B016A
	for <linux-mm@kvack.org>; Fri, 26 Aug 2011 17:23:33 -0400 (EDT)
Date: Fri, 26 Aug 2011 14:23:28 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH] mm/mempolicy.c: fix pgoff in mbind vma merge
Message-Id: <20110826142328.ab4726cb.akpm@linux-foundation.org>
In-Reply-To: <14efb4b829a69f8c13d65de60a4508c0bbb0a5f5.1312212325.git.caspar@casparzhang.com>
References: <14efb4b829a69f8c13d65de60a4508c0bbb0a5f5.1312212325.git.caspar@casparzhang.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Caspar Zhang <caspar@casparzhang.com>
Cc: linux-mm <linux-mm@kvack.org>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, LKML <linux-kernel@vger.kernel.org>

On Mon,  1 Aug 2011 23:28:55 +0800
Caspar Zhang <caspar@casparzhang.com> wrote:

> commit 9d8cebd4bcd7c3878462fdfda34bbcdeb4df7ef4 didn't real fix the
> mbind vma merge problem due to wrong pgoff value passing to vma_merge(),
> which made vma_merge() always return NULL.
> 
> Re-tested the patched kernel with the reproducer provided in commit
> 9d8cebd, got correct result like below:
> 
> addr = 0x7ffa5aaa2000
> [snip]
> 7ffa5aaa2000-7ffa5aaa6000 rw-p 00000000 00:00 0
> 7fffd556f000-7fffd5584000 rw-p 00000000 00:00 0                          [stack]
> 

Please also describe the output before the patch is applied, and tell
us what you believe is wrong with it?

> --- a/mm/mempolicy.c
> +++ b/mm/mempolicy.c
> @@ -636,7 +636,6 @@ static int mbind_range(struct mm_struct *mm, unsigned long start,
>  	struct vm_area_struct *prev;
>  	struct vm_area_struct *vma;
>  	int err = 0;
> -	pgoff_t pgoff;
>  	unsigned long vmstart;
>  	unsigned long vmend;
>  
> @@ -649,9 +648,9 @@ static int mbind_range(struct mm_struct *mm, unsigned long start,
>  		vmstart = max(start, vma->vm_start);
>  		vmend   = min(end, vma->vm_end);
>  
> -		pgoff = vma->vm_pgoff + ((start - vma->vm_start) >> PAGE_SHIFT);
>  		prev = vma_merge(mm, prev, vmstart, vmend, vma->vm_flags,
> -				  vma->anon_vma, vma->vm_file, pgoff, new_pol);
> +				  vma->anon_vma, vma->vm_file, vma->vm_pgoff,
> +				  new_pol);
>  		if (prev) {
>  			vma = prev;
>  			next = vma->vm_next;
> -- 
> 1.7.6

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

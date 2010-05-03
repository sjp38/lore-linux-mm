Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with ESMTP id 7631D6007B8
	for <linux-mm@kvack.org>; Mon,  3 May 2010 12:55:23 -0400 (EDT)
Received: from f199130.upc-f.chello.nl ([80.56.199.130] helo=dyad.programming.kicks-ass.net)
	by bombadil.infradead.org with esmtpsa (Exim 4.69 #1 (Red Hat Linux))
	id 1O8yvS-0005Jx-Ox
	for linux-mm@kvack.org; Mon, 03 May 2010 16:55:23 +0000
Subject: Re: [PATCH 1/2] mm: Take all anon_vma locks in anon_vma_lock
From: Peter Zijlstra <peterz@infradead.org>
In-Reply-To: <20100503121847.7997d280@annuminas.surriel.com>
References: <20100503121743.653e5ecc@annuminas.surriel.com>
	 <20100503121847.7997d280@annuminas.surriel.com>
Content-Type: text/plain; charset="UTF-8"
Date: Mon, 03 May 2010 18:55:12 +0200
Message-ID: <1272905712.1642.150.camel@laptop>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Rik van Riel <riel@redhat.com>
Cc: akpm@linux-foundation.org, torvalds@linux-foundation.org, Mel Gorman <mel@csn.ul.ie>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Minchan Kim <minchan.kim@gmail.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Andrea Arcangeli <aarcange@redhat.com>, Christoph Lameter <cl@linux.com>
List-ID: <linux-mm.kvack.org>

On Mon, 2010-05-03 at 12:18 -0400, Rik van Riel wrote:
> From: Rik van Riel <riel@redhat.com>
> 
> Both the page migration code and the transparent hugepage patches expect
> 100% reliable rmap lookups and use page_lock_anon_vma(page) to prevent
> races with mmap, munmap, expand_stack, etc.
> 
> Specifically, try_to_unmap indirectly calls vma_address, which uses the
> difference between vma->vm_start and vma->vm_pgoff, which can race when a
> stack is expanded downwards.  VMA splitting and merging present similar
> issues.
> 
> With the new anon_vma code, one VMA can be attached to multiple anon_vmas,
> however mmap, munmap, expand_stack and others only took one anon_vma->lock.
> This patch changes things so we take the anon_vma locks for all of the
> anon_vmas attached to a VMA in the code that try_to_unmap would otherwise
> race against: mmap, munmap, expand_stack, etc. 
> 
> Unfortunately, this leads to a lock ordering conflict with the page_table_lock,
> which protected the "same_vma" list in the anon_vma_chain.  Replacing that
> lock with a new lock (mm->anon_vma_chain_lock), which is taken higher up in
> the mm locking hierarchy, solves that issue.  This changes the locking rules
> for the "same_vma" list to be either mm->mmap_sem for write, or mm->mmap_sem
> for read plus the new mm->anon_vma_chain lock.  This limits the place where
> the new lock is taken to 2 locations - anon_vma_prepare and expand_downwards.
> 
> Document the locking rules for the same_vma list in the anon_vma_chain and
> remove the anon_vma_lock call from expand_upwards, which does not need it.

> diff --git a/mm/mmap.c b/mm/mmap.c
> index 456ec6f..81850fc 100644
> --- a/mm/mmap.c
> +++ b/mm/mmap.c

> @@ -1705,12 +1707,11 @@ int expand_upwards(struct vm_area_struct *vma, unsigned long address)
>  		return -EFAULT;
>  
>  	/*
> -	 * We must make sure the anon_vma is allocated
> -	 * so that the anon_vma locking is not a noop.
> +	 * Unlike expand_downwards, we do not need to take the anon_vma lock,
> +	 * because we leave vma->vm_start and vma->pgoff untouched. 
> +	 * This means rmap lookups of pages inside this VMA stay valid
> +	 * throughout the stack expansion.
>  	 */
> -	if (unlikely(anon_vma_prepare(vma)))
> -		return -ENOMEM;
> -	anon_vma_lock(vma);
>  
>  	/*
>  	 * vma->vm_start/vm_end cannot change under us because the caller
> @@ -1721,7 +1722,6 @@ int expand_upwards(struct vm_area_struct *vma, unsigned long address)
>  	if (address < PAGE_ALIGN(address+4))
>  		address = PAGE_ALIGN(address+4);
>  	else {
> -		anon_vma_unlock(vma);
>  		return -ENOMEM;
>  	}
>  	error = 0;
> @@ -1737,7 +1737,6 @@ int expand_upwards(struct vm_area_struct *vma, unsigned long address)
>  		if (!error)
>  			vma->vm_end = address;
>  	}
> -	anon_vma_unlock(vma);
>  	return error;
>  }
>  #endif /* CONFIG_STACK_GROWSUP || CONFIG_IA64 */


This does leave me worrying about concurrent faults poking at
vma->vm_end without synchronization.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

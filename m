Date: Fri, 15 Feb 2008 19:37:36 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [patch 3/6] mmu_notifier: invalidate_page callbacks
Message-Id: <20080215193736.9d6e7da3.akpm@linux-foundation.org>
In-Reply-To: <20080215064932.918191502@sgi.com>
References: <20080215064859.384203497@sgi.com>
	<20080215064932.918191502@sgi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: Andrea Arcangeli <andrea@qumranet.com>, Robin Holt <holt@sgi.com>, Avi Kivity <avi@qumranet.com>, Izik Eidus <izike@qumranet.com>, kvm-devel@lists.sourceforge.net, Peter Zijlstra <a.p.zijlstra@chello.nl>, general@lists.openfabrics.org, Steve Wise <swise@opengridcomputing.com>, Roland Dreier <rdreier@cisco.com>, Kanoj Sarcar <kanojsarcar@yahoo.com>, steiner@sgi.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, daniel.blueman@quadrics.com
List-ID: <linux-mm.kvack.org>

On Thu, 14 Feb 2008 22:49:02 -0800 Christoph Lameter <clameter@sgi.com> wrote:

> Two callbacks to remove individual pages as done in rmap code
> 
> 	invalidate_page()
> 
> Called from the inner loop of rmap walks to invalidate pages.
> 
> 	age_page()
> 
> Called for the determination of the page referenced status.
> 
> If we do not care about page referenced status then an age_page callback
> may be be omitted. PageLock and pte lock are held when either of the
> functions is called.

The age_page mystery shallows.

It would be useful to have some rationale somewhere in the patchset for the
existence of this callback.

>  #include <asm/tlbflush.h>
>  
> @@ -287,7 +288,8 @@ static int page_referenced_one(struct pa
>  	if (vma->vm_flags & VM_LOCKED) {
>  		referenced++;
>  		*mapcount = 1;	/* break early from loop */
> -	} else if (ptep_clear_flush_young(vma, address, pte))
> +	} else if (ptep_clear_flush_young(vma, address, pte) |
> +		   mmu_notifier_age_page(mm, address))
>  		referenced++;

The "|" is obviously deliberate.  But no explanation is provided telling us
why we still call the callback if ptep_clear_flush_young() said the page
was recently referenced.  People who read your code will want to understand
this.

>  	/* Pretend the page is referenced if the task has the
> @@ -455,6 +457,7 @@ static int page_mkclean_one(struct page 
>  
>  		flush_cache_page(vma, address, pte_pfn(*pte));
>  		entry = ptep_clear_flush(vma, address, pte);
> +		mmu_notifier(invalidate_page, mm, address);

I just don't see how ths can be done if the callee has another thread in
the middle of establishing IO against this region of memory. 
->invalidate_page() _has_ to be able to block.  Confused.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

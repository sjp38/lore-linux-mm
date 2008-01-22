Date: Mon, 21 Jan 2008 18:16:46 -0800 (PST)
From: Linus Torvalds <torvalds@linux-foundation.org>
Subject: Re: [PATCH -v7 2/2] Update ctime and mtime for memory-mapped files
In-Reply-To: <12009619584168-git-send-email-salikhmetov@gmail.com>
Message-ID: <alpine.LFD.1.00.0801211805220.2957@woody.linux-foundation.org>
References: <12009619562023-git-send-email-salikhmetov@gmail.com> <12009619584168-git-send-email-salikhmetov@gmail.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Anton Salikhmetov <salikhmetov@gmail.com>
Cc: linux-mm@kvack.org, jakob@unthought.net, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, valdis.kletnieks@vt.edu, riel@redhat.com, ksm@42.dk, staubach@redhat.com, jesper.juhl@gmail.com, a.p.zijlstra@chello.nl, Andrew Morton <akpm@linux-foundation.org>, protasnb@gmail.com, miklos@szeredi.hu, r.e.wolff@bitwizard.nl, hidave.darkstar@gmail.com, hch@infradead.org
List-ID: <linux-mm.kvack.org>


On Tue, 22 Jan 2008, Anton Salikhmetov wrote:
>  
>  /*
> + * Scan the PTEs for pages belonging to the VMA and mark them read-only.
> + * It will force a pagefault on the next write access.
> + */
> +static void vma_wrprotect(struct vm_area_struct *vma)
> +{
> +	unsigned long addr;
> +
> +	for (addr = vma->vm_start; addr < vma->vm_end; addr += PAGE_SIZE) {
> +		spinlock_t *ptl;
> +		pgd_t *pgd = pgd_offset(vma->vm_mm, addr);
> +		pud_t *pud = pud_offset(pgd, addr);
> +		pmd_t *pmd = pmd_offset(pud, addr);
> +		pte_t *pte = pte_offset_map_lock(vma->vm_mm, pmd, addr, &ptl);

This is extremely expensive over bigger areas, especially sparsely mapped 
ones (it does all the lookups for all four levels over and over and over 
again for eachg page).

I think Peter Zijlstra posted a version that uses the regular kind of 
nested loop (with inline functions to keep the thing nice and clean), 
which gets rid of that.

[ The sad/funny part is that this is all how we *used* to do msync(), back 
  in the days: we're literally going back to the "pre-cleanup" logic. See 
  commit 204ec841fbea3e5138168edbc3a76d46747cc987: "mm: msync() cleanup" 
  for details ]

Quite frankly, I really think you might be better off just doing a

	git revert 204ec841fbea3e5138168edbc3a76d46747cc987

and working from there! I just checked, and it still reverts cleanly, and 
you'd end up with a nice code-base that (a) has gotten years of testing 
and (b) already has the looping-over-the-pagetables code.

			Linus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

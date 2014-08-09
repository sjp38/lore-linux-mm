Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f178.google.com (mail-pd0-f178.google.com [209.85.192.178])
	by kanga.kvack.org (Postfix) with ESMTP id 36F356B0036
	for <linux-mm@kvack.org>; Sat,  9 Aug 2014 19:03:29 -0400 (EDT)
Received: by mail-pd0-f178.google.com with SMTP id w10so8845885pde.9
        for <linux-mm@kvack.org>; Sat, 09 Aug 2014 16:03:28 -0700 (PDT)
Received: from mail-pa0-x22c.google.com (mail-pa0-x22c.google.com [2607:f8b0:400e:c03::22c])
        by mx.google.com with ESMTPS id bs4si9292320pbc.34.2014.08.09.16.03.27
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Sat, 09 Aug 2014 16:03:27 -0700 (PDT)
Received: by mail-pa0-f44.google.com with SMTP id eu11so9160274pac.3
        for <linux-mm@kvack.org>; Sat, 09 Aug 2014 16:03:27 -0700 (PDT)
Date: Sat, 9 Aug 2014 16:01:39 -0700 (PDT)
From: Hugh Dickins <hughd@google.com>
Subject: Re: [PATCH v2 1/3] mm/hugetlb: take refcount under page table lock
 in follow_huge_pmd()
In-Reply-To: <1406914663-8631-1-git-send-email-n-horiguchi@ah.jp.nec.com>
Message-ID: <alpine.LSU.2.11.1408091600040.15311@eggly.anvils>
References: <1406914663-8631-1-git-send-email-n-horiguchi@ah.jp.nec.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Hugh Dickins <hughd@google.com>, David Rientjes <rientjes@google.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Naoya Horiguchi <nao.horiguchi@gmail.com>

On Fri, 1 Aug 2014, Naoya Horiguchi wrote:

> We have a race condition between move_pages() and freeing hugepages,
> where move_pages() calls follow_page(FOLL_GET) for hugepages internally
> and tries to get its refcount without preventing concurrent freeing.
> This race crashes the kernel, so this patch fixes it by moving FOLL_GET
> code for hugepages into follow_huge_pmd() with taking the page table lock.
> 
> This patch passes the following test. And libhugetlbfs test shows no
> regression.
> 
>   $ cat movepages.c
>   #include <stdio.h>
>   #include <stdlib.h>
>   #include <numaif.h>
> 
>   #define ADDR_INPUT      0x700000000000UL
>   #define HPS             0x200000
>   #define PS              0x1000
> 
>   int main(int argc, char *argv[]) {
>           int i;
>           int nr_hp = strtol(argv[1], NULL, 0);
>           int nr_p  = nr_hp * HPS / PS;
>           int ret;
>           void **addrs;
>           int *status;
>           int *nodes;
>           pid_t pid;
> 
>           pid = strtol(argv[2], NULL, 0);
>           addrs  = malloc(sizeof(char *) * nr_p + 1);
>           status = malloc(sizeof(char *) * nr_p + 1);
>           nodes  = malloc(sizeof(char *) * nr_p + 1);
> 
>           while (1) {
>                   for (i = 0; i < nr_p; i++) {
>                           addrs[i] = (void *)ADDR_INPUT + i * PS;
>                           nodes[i] = 1;
>                           status[i] = 0;
>                   }
>                   ret = numa_move_pages(pid, nr_p, addrs, nodes, status,
>                                         MPOL_MF_MOVE_ALL);
>                   if (ret == -1)
>                           err("move_pages");
> 
>                   for (i = 0; i < nr_p; i++) {
>                           addrs[i] = (void *)ADDR_INPUT + i * PS;
>                           nodes[i] = 0;
>                           status[i] = 0;
>                   }
>                   ret = numa_move_pages(pid, nr_p, addrs, nodes, status,
>                                         MPOL_MF_MOVE_ALL);
>                   if (ret == -1)
>                           err("move_pages");
>           }
>           return 0;
>   }
> 
>   $ cat hugepage.c
>   #include <stdio.h>
>   #include <sys/mman.h>
>   #include <string.h>
> 
>   #define ADDR_INPUT      0x700000000000UL
>   #define HPS             0x200000
> 
>   int main(int argc, char *argv[]) {
>           int nr_hp = strtol(argv[1], NULL, 0);
>           char *p;
> 
>           while (1) {
>                   p = mmap((void *)ADDR_INPUT, nr_hp * HPS, PROT_READ | PROT_WRITE,
>                            MAP_PRIVATE | MAP_ANONYMOUS | MAP_HUGETLB, -1, 0);
>                   if (p != (void *)ADDR_INPUT) {
>                           perror("mmap");
>                           break;
>                   }
>                   memset(p, 0, nr_hp * HPS);
>                   munmap(p, nr_hp * HPS);
>           }
>   }
> 
>   $ sysctl vm.nr_hugepages=40
>   $ ./hugepage 10 &
>   $ ./movepages 10 $(pgrep -f hugepage)
> 
> Note for stable inclusion:
>   This patch fixes e632a938d914 ("mm: migrate: add hugepage migration code
>   to move_pages()"), so is applicable to -stable kernels which includes it.
> 
> ChangeLog v2:
> - introduce follow_huge_pmd_lock() to do locking in arch-independent code.
> 
> Signed-off-by: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
> Cc: <stable@vger.kernel.org>  # [3.12+]
> ---
>  include/linux/hugetlb.h |  3 +++
>  mm/gup.c                | 17 ++---------------
>  mm/hugetlb.c            | 27 +++++++++++++++++++++++++++
>  3 files changed, 32 insertions(+), 15 deletions(-)
> 
> diff --git mmotm-2014-07-22-15-58.orig/include/linux/hugetlb.h mmotm-2014-07-22-15-58/include/linux/hugetlb.h
> index 41272bcf73f8..194834853d6f 100644
> --- mmotm-2014-07-22-15-58.orig/include/linux/hugetlb.h
> +++ mmotm-2014-07-22-15-58/include/linux/hugetlb.h
> @@ -101,6 +101,8 @@ struct page *follow_huge_pmd(struct mm_struct *mm, unsigned long address,
>  				pmd_t *pmd, int write);
>  struct page *follow_huge_pud(struct mm_struct *mm, unsigned long address,
>  				pud_t *pud, int write);
> +struct page *follow_huge_pmd_lock(struct vm_area_struct *vma,
> +				unsigned long address, pmd_t *pmd, int flags);
>  int pmd_huge(pmd_t pmd);
>  int pud_huge(pud_t pmd);
>  unsigned long hugetlb_change_protection(struct vm_area_struct *vma,
> @@ -134,6 +136,7 @@ static inline void hugetlb_show_meminfo(void)
>  }
>  #define follow_huge_pmd(mm, addr, pmd, write)	NULL
>  #define follow_huge_pud(mm, addr, pud, write)	NULL
> +#define follow_huge_pmd_lock(vma, addr, pmd, flags)	NULL
>  #define prepare_hugepage_range(file, addr, len)	(-EINVAL)
>  #define pmd_huge(x)	0
>  #define pud_huge(x)	0
> diff --git mmotm-2014-07-22-15-58.orig/mm/gup.c mmotm-2014-07-22-15-58/mm/gup.c
> index 91d044b1600d..e4bd59efe686 100644
> --- mmotm-2014-07-22-15-58.orig/mm/gup.c
> +++ mmotm-2014-07-22-15-58/mm/gup.c
> @@ -174,21 +174,8 @@ struct page *follow_page_mask(struct vm_area_struct *vma,
>  	pmd = pmd_offset(pud, address);
>  	if (pmd_none(*pmd))
>  		return no_page_table(vma, flags);
> -	if (pmd_huge(*pmd) && vma->vm_flags & VM_HUGETLB) {
> -		page = follow_huge_pmd(mm, address, pmd, flags & FOLL_WRITE);
> -		if (flags & FOLL_GET) {
> -			/*
> -			 * Refcount on tail pages are not well-defined and
> -			 * shouldn't be taken. The caller should handle a NULL
> -			 * return when trying to follow tail pages.
> -			 */
> -			if (PageHead(page))
> -				get_page(page);
> -			else
> -				page = NULL;
> -		}
> -		return page;
> -	}
> +	if (pmd_huge(*pmd) && vma->vm_flags & VM_HUGETLB)
> +		return follow_huge_pmd_lock(vma, address, pmd, flags);

Yes, that's good (except I don't like the _lock name).

>  	if ((flags & FOLL_NUMA) && pmd_numa(*pmd))
>  		return no_page_table(vma, flags);
>  	if (pmd_trans_huge(*pmd)) {
> diff --git mmotm-2014-07-22-15-58.orig/mm/hugetlb.c mmotm-2014-07-22-15-58/mm/hugetlb.c
> index 7263c770e9b3..4437896cd6ed 100644
> --- mmotm-2014-07-22-15-58.orig/mm/hugetlb.c
> +++ mmotm-2014-07-22-15-58/mm/hugetlb.c
> @@ -3687,6 +3687,33 @@ follow_huge_pud(struct mm_struct *mm, unsigned long address,
>  
>  #endif /* CONFIG_ARCH_WANT_GENERAL_HUGETLB */
>  
> +struct page *follow_huge_pmd_lock(struct vm_area_struct *vma,
> +				unsigned long address, pmd_t *pmd, int flags)
> +{
> +	struct page *page;
> +	spinlock_t *ptl;
> +
> +	if (flags & FOLL_GET)
> +		ptl = huge_pte_lock(hstate_vma(vma), vma->vm_mm, (pte_t *)pmd);
> +

But this is not good enough, I'm afraid.

> +	page = follow_huge_pmd(vma->vm_mm, address, pmd, flags & FOLL_WRITE);
> +
> +	if (flags & FOLL_GET) {
> +		/*
> +		 * Refcount on tail pages are not well-defined and
> +		 * shouldn't be taken. The caller should handle a NULL
> +		 * return when trying to follow tail pages.
> +		 */
> +		if (PageHead(page))
> +			get_page(page);
> +		else
> +			page = NULL;
> +		spin_unlock(ptl);
> +	}
> +
> +	return page;
> +}
> +
>  #ifdef CONFIG_MEMORY_FAILURE
>  
>  /* Should be called in hugetlb_lock */
> -- 
> 1.9.3

Thanks a lot for remembering this, but it's not enough, I think.

It is an improvement over the current code (except for the annoying new
level, and its confusing name follow_huge_pmd_lock); but I don't want to
keep on coming back, repeatedly sending new corrections to four or more
releases of -stable.  Please let's get it right and be done with it.

I see two problems with the above, but perhaps I'm mistaken.

One is hugetlb_vmtruncate(): follow_huge_pmd_lock() is only called
when we have observed pmd_huge(*pmd), fine, but how can we assume
that pmd_huge(*pmd) still after getting the necessary huge_pte_lock?
Truncation could have changed that *pmd to none, and then pte_page()
will supply an incorrect (but non-NULL) address.

(I observe the follow_huge_pmd()s all doing an "if (page)" after
their pte_page(), but when I checked at the time of the original
follow_huge_addr() problem, I could not find any architecture with
a pte_page() returning NULL for an invalid entry - pte_page() is
a simple blind translation in every architecture, I believe, but
please check.)

Two is x86-32 PAE (and perhaps some other architectures), in which
the pmd entry spans two machine words, loaded independently.  It's a
very narrow race window, but we cannot safely access the whole *pmd
without locking: we might pick up two mismatched halves.  Take a look
at pte_unmap_same() in mm/memory.c, it's handling that issue on ptes.

So, if I follow my distaste for the intermediate follow_huge_pmd_lock
level (and in patch 4/3 you are already changing all the declarations,
so no need to be deterred by that task), I think what we need is:

struct page *
follow_huge_pmd(struct vm_area_struct *vma, unsigned long address,
		pmd_t *pmd, unsigned int flags)
{
	struct page *page;
	spinlock_t *ptl;

	ptl = huge_pte_lock(hstate_vma(vma), vma->vm_mm, (pte_t *)pmd);

	if (!pmd_huge(*pmd)) {
		page = NULL;
		goto out;
	}

	page = pte_page(*(pte_t *)pmd) + ((address & ~PMD_MASK) >> PAGE_SHIFT);

	if (flags & FOLL_GET) {
		/*
		 * Refcount on tail pages are not well-defined and
		 * shouldn't be taken. The caller should handle a NULL
		 * return when trying to follow tail pages.
		 */
		if (PageHead(page))
			get_page(page);
		else
			page = NULL;
	}
out:
	spin_unlock(ptl);
	return page;
}

Yes, there are many !FOLL_GET cases which could use an ACCESS_ONCE(*pmd)
and avoid taking the lock; but follow_page_pte() is content to take its
lock in all cases, so I don't see any need to avoid it in this much less
common case.

And it looks to me as if this follow_huge_pmd() would be good for every
hugetlb architecture (but I may especially be wrong on that, having
compiled it for none but x86_64).  On some architectures, the ones which
currently present just a stub follow_huge_pmd(), the optimizer should
eliminate everything after the !pmd_huge test, and we won't be calling
it on those anyway.  On mips s390 and tile, I think the above represents
what they're currently doing, despite some saying HPAGE_MASK in place of
PMD_MASK, and having that funny "if (page)" condition after pte_page().

Please check carefully: I think the above follow_huge_pmd() can sit in
mm/hugetlb.c, for use on all architectures; and the variants be deleted;
and I think that would be an improvement.

I'm not sure what should happen to follow_huge_pud() if we go this way.
There's a good argument for adapting it in exactly the same way, but
that may not appeal to those wanting to remove the never used argument.

And, please, let's go just a little further, while we are having to
think of these issues.  Isn't what we're doing here much the same as
we need to do to follow_huge_addr(), to fix the May 28th issues which
led you to disable hugetlb migration on all but x86_64?

I'm not arguing to re-enable hugetlb migration on those architectures
which you cannot test, no, you did the right thing to leave that to
them.  But could we please update follow_huge_addr() (in a separate
patch) to make it consistent with this follow_huge_pmd(), so that at
least you can tell maintainers that you believe it is working now?

Uh oh.  I thought I had finished writing about this patch, but just
realized more.  Above you can see that I've faithfully copied your
"Refcount on tail pages are not well-defined" comment and !PageHead
NULL.  But that's nonsense, isn't it?  Refcount on tail pages is and
must be well-defined, and that's been handled in follow_hugetlb_page()
for, well, at least ten years.

But note the "Some archs" comment in follow_hugetlb_page(): I have
not followed it up, and it may prove to be irrelevant here; but it
suggests that in general some additional care might be needed for
the get_page()s - or perhaps they should now be get_page_folls()?

I guess the "not well-defined" comment was your guess as to why I had
put in the BUG_ON(flags & FOLL_GET)s: no, they were because nobody
required huge FOLL_GET at that time, and that case lacked the locking
which you are now supplying.

Hugh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

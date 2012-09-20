Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx187.postini.com [74.125.245.187])
	by kanga.kvack.org (Postfix) with SMTP id 4FD206B0044
	for <linux-mm@kvack.org>; Thu, 20 Sep 2012 00:01:52 -0400 (EDT)
Received: by qcsd16 with SMTP id d16so1663287qcs.14
        for <linux-mm@kvack.org>; Wed, 19 Sep 2012 21:01:51 -0700 (PDT)
Date: Wed, 19 Sep 2012 21:01:12 -0700 (PDT)
From: Hugh Dickins <hughd@google.com>
Subject: Re: [patch for-3.6] mm, thp: fix mapped pages avoiding unevictable
 list on mlock
In-Reply-To: <alpine.DEB.2.00.1209191818490.7879@chino.kir.corp.google.com>
Message-ID: <alpine.LSU.2.00.1209192021270.28543@eggly.anvils>
References: <alpine.DEB.2.00.1209191818490.7879@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Johannes Weiner <hannes@cmpxchg.org>, Michel Lespinasse <walken@google.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, stable@vger.kernel.org

On Wed, 18 Sep 2012, David Rientjes wrote:

> When a transparent hugepage is mapped and it is included in an mlock()
> range, follow_page() incorrectly avoids setting the page's mlock bit and
> moving it to the unevictable lru.
> 
> This is evident if you try to mlock(), munlock(), and then mlock() a 
> range again.  Currently:
> 
> 	#define MAP_SIZE	(4 << 30)	/* 4GB */
> 
> 	void *ptr = mmap(NULL, MAP_SIZE, PROT_READ | PROT_WRITE,
> 			 MAP_PRIVATE | MAP_ANONYMOUS, 0, 0);
> 	mlock(ptr, MAP_SIZE);
> 
> 		$ grep -E "Unevictable|Inactive\(anon" /proc/meminfo
> 		Inactive(anon):     6304 kB
> 		Unevictable:     4213924 kB
> 
> 	munlock(ptr, MAP_SIZE);
> 
> 		Inactive(anon):  4186252 kB
> 		Unevictable:       19652 kB
> 
> 	mlock(ptr, MAP_SIZE);
> 
> 		Inactive(anon):  4198556 kB
> 		Unevictable:       21684 kB
> 
> Notice that less than 2MB was added to the unevictable list; this is
> because these pages in the range are not transparent hugepages since the
> 4GB range was allocated with mmap() and has no specific alignment.  If
> posix_memalign() were used instead, unevictable would not have grown at
> all on the second mlock().
> 
> The fix is to call mlock_vma_page() so that the mlock bit is set and the
> page is added to the unevictable list.  With this patch:
> 
> 	mlock(ptr, MAP_SIZE);
> 
> 		Inactive(anon):     4056 kB
> 		Unevictable:     4213940 kB
> 
> 	munlock(ptr, MAP_SIZE);
> 
> 		Inactive(anon):  4198268 kB
> 		Unevictable:       19636 kB
> 
> 	mlock(ptr, MAP_SIZE);
> 
> 		Inactive(anon):     4008 kB
> 		Unevictable:     4213940 kB
> 
> Cc: stable@vger.kernel.org [v2.6.38+]
> Signed-off-by: David Rientjes <rientjes@google.com>

Good catch, and the patch looks right to me, as far as it goes:
but does it go far enough?

I hesitate because it looks as if the NR_MLOCK zone page state is
maintained (with incs and decs) in ignorance of THP; so although
you will be correcting the Unevictable kB with your mlock_vma_page(),
the Mlocked kB just above it in /proc/meminfo would still be wrong?

And this is all a matter of the numbers shown in /proc/meminfo,
isn't it?  Hmm, and some list balancing ratios, I suppose.  I mean,
these pages are effectively locked in memory, aren't they, even
without being properly counted?  When page reclaim comes to evict them,
it will find them in a VM_LOCKED area and then move to unevictable.  Ah,
but probably after splitting the THP: it would be nice to avoid that.

I suppose I'm not sure whether this is material for late-3.6:
surely it's not a fix for a recent regression?

> ---
>  include/linux/huge_mm.h |    2 +-
>  mm/huge_memory.c        |   11 ++++++++++-
>  mm/memory.c             |    2 +-
>  3 files changed, 12 insertions(+), 3 deletions(-)
> 
> diff --git a/include/linux/huge_mm.h b/include/linux/huge_mm.h
> --- a/include/linux/huge_mm.h
> +++ b/include/linux/huge_mm.h
> @@ -12,7 +12,7 @@ extern int do_huge_pmd_wp_page(struct mm_struct *mm, struct vm_area_struct *vma,
>  			       unsigned long address, pmd_t *pmd,
>  			       pmd_t orig_pmd);
>  extern pgtable_t get_pmd_huge_pte(struct mm_struct *mm);
> -extern struct page *follow_trans_huge_pmd(struct mm_struct *mm,
> +extern struct page *follow_trans_huge_pmd(struct vm_area_struct *vma,
>  					  unsigned long addr,
>  					  pmd_t *pmd,
>  					  unsigned int flags);
> diff --git a/mm/huge_memory.c b/mm/huge_memory.c
> --- a/mm/huge_memory.c
> +++ b/mm/huge_memory.c
> @@ -997,11 +997,12 @@ out:
>  	return ret;
>  }
>  
> -struct page *follow_trans_huge_pmd(struct mm_struct *mm,
> +struct page *follow_trans_huge_pmd(struct vm_area_struct *vma,
>  				   unsigned long addr,
>  				   pmd_t *pmd,
>  				   unsigned int flags)
>  {
> +	struct mm_struct *mm = vma->vm_mm;
>  	struct page *page = NULL;
>  
>  	assert_spin_locked(&mm->page_table_lock);
> @@ -1024,6 +1025,14 @@ struct page *follow_trans_huge_pmd(struct mm_struct *mm,
>  		_pmd = pmd_mkyoung(pmd_mkdirty(*pmd));
>  		set_pmd_at(mm, addr & HPAGE_PMD_MASK, pmd, _pmd);
>  	}
> +	if ((flags & FOLL_MLOCK) && (vma->vm_flags & VM_LOCKED)) {
> +		if (page->mapping && trylock_page(page)) {
> +			lru_add_drain();
> +			if (page->mapping)

Amusingly, in another thread (for mmotm), Hannes and I were discussing
this very code block that you have copied from follow_page(), and we
concluded that this page->mapping check is not necessary.  But you're
absolutely right to copy it as is, then I can come and remove it later.

Hugh

> +				mlock_vma_page(page);
> +			unlock_page(page);
> +		}
> +	}
>  	page += (addr & ~HPAGE_PMD_MASK) >> PAGE_SHIFT;
>  	VM_BUG_ON(!PageCompound(page));
>  	if (flags & FOLL_GET)
> diff --git a/mm/memory.c b/mm/memory.c
> --- a/mm/memory.c
> +++ b/mm/memory.c
> @@ -1521,7 +1521,7 @@ struct page *follow_page(struct vm_area_struct *vma, unsigned long address,
>  				spin_unlock(&mm->page_table_lock);
>  				wait_split_huge_page(vma->anon_vma, pmd);
>  			} else {
> -				page = follow_trans_huge_pmd(mm, address,
> +				page = follow_trans_huge_pmd(vma, address,
>  							     pmd, flags);
>  				spin_unlock(&mm->page_table_lock);
>  				goto out;

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

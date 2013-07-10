Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx133.postini.com [74.125.245.133])
	by kanga.kvack.org (Postfix) with SMTP id 4543A6B0034
	for <linux-mm@kvack.org>; Tue,  9 Jul 2013 20:54:17 -0400 (EDT)
Received: by mail-pa0-f54.google.com with SMTP id kx10so6128226pab.41
        for <linux-mm@kvack.org>; Tue, 09 Jul 2013 17:54:16 -0700 (PDT)
Date: Tue, 9 Jul 2013 17:54:26 -0700 (PDT)
From: Hugh Dickins <hughd@google.com>
Subject: Re: PageDirty check in mk_pte for s390
In-Reply-To: <20130703104134.4e901aea@mschwide>
Message-ID: <alpine.LNX.2.00.1307091727160.7227@eggly.anvils>
References: <20130703104134.4e901aea@mschwide>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Martin Schwidefsky <schwidefsky@de.ibm.com>
Cc: linux-mm@kvack.org, linux-s390@vger.kernel.org

Hi Martin,

Sorry for being so slow to respond: just back from vacation,
and masses of mail to go through.

On Wed, 3 Jul 2013, Martin Schwidefsky wrote:

> Hi Hugh,
> 
> I still have the patch below in my patch heap. Should I just go ahead and
> add it to my s390-tree or do you prefer to take care of it yourself ?

I didn't realize that you had taken that in.  Mel had acked your original
patch, I raised this concern, but nobody agreed or disagreed with me
(and you didn't persuade rmk to join you in __ARCH_WANT_PTE_WRITE_DIRTY).

When I saw your original go to linux-next, then to Linus, I had to ask
myself how much I still cared about it, given everything else going on.

I decided that I didn't care enough to spend time on it, so just let it
drop; and find myself still feeling that way.  I still don't like your
PageDirty buried in mk_pte, and fear we may cause s390 unforeseen trouble
in future because of it; but now that it is upstream, I'm inclined to let
it rest until a problem is demonstrated - it can't hurt anyone but s390.

If you feel differently, and think it is better with the patch below (I
didn't realize that I had persuaded you), then by all means send it in
to Linus.  As you know, I personally prefer an explicit CONFIG_S390, but
clearly you disagree with me on that, and I wouldn't be surprised if
Linus and everyone else share your view.

Thanks for caring!
Hugh

> 
> --
> Subject: [PATCH] s390/mm: move PageDirty check from mk_pte to common code
> 
> Hugh Dickins commented on the software dirty bit implementation and he
> does not like the fact that mk_pte uses PageDirty under the covers.
> His suggestion is to move the PageDirty check into the __do_fault
> function.
> 
> Signed-off-by: Martin Schwidefsky <schwidefsky@de.ibm.com>
> ---
>  arch/s390/include/asm/pgtable.h |  9 +++------
>  mm/memory.c                     | 12 ++++++++++++
>  2 files changed, 15 insertions(+), 6 deletions(-)
> 
> diff --git a/arch/s390/include/asm/pgtable.h b/arch/s390/include/asm/pgtable.h
> index 68e6168..d56dc6d 100644
> --- a/arch/s390/include/asm/pgtable.h
> +++ b/arch/s390/include/asm/pgtable.h
> @@ -1260,13 +1260,8 @@ static inline pte_t mk_pte_phys(unsigned long physpage, pgprot_t pgprot)
>  static inline pte_t mk_pte(struct page *page, pgprot_t pgprot)
>  {
>  	unsigned long physpage = page_to_phys(page);
> -	pte_t __pte = mk_pte_phys(physpage, pgprot);
>  
> -	if ((pte_val(__pte) & _PAGE_SWW) && PageDirty(page)) {
> -		pte_val(__pte) |= _PAGE_SWC;
> -		pte_val(__pte) &= ~_PAGE_RO;
> -	}
> -	return __pte;
> +	return mk_pte_phys(physpage, pgprot);
>  }
>  
>  #define pgd_index(address) (((address) >> PGDIR_SHIFT) & (PTRS_PER_PGD-1))
> @@ -1599,6 +1594,8 @@ extern int s390_enable_sie(void);
>  static inline void pgtable_cache_init(void) { }
>  static inline void check_pgt_cache(void) { }
>  
> +#define __ARCH_WANT_PTE_WRITE_DIRTY
> +
>  #include <asm-generic/pgtable.h>
>  
>  #endif /* _S390_PAGE_H */
> diff --git a/mm/memory.c b/mm/memory.c
> index 1207cef..765d5f2 100644
> --- a/mm/memory.c
> +++ b/mm/memory.c
> @@ -3417,6 +3417,18 @@ static int __do_fault(struct mm_struct *mm, struct vm_area_struct *vma,
>  				dirty_page = page;
>  				get_page(dirty_page);
>  			}
> +#ifdef __ARCH_WANT_PTE_WRITE_DIRTY
> +			/*
> +			 * Architectures that use software dirty bits may
> +			 * want to set the dirty bit in the pte if the pte
> +			 * is writable and the PageDirty bit is set for the
> +			 * page. This avoids unnecessary protection faults
> +			 * for writable mappings which do not use
> +			 * mapping_cap_account_dirty, e.g. tmpfs and shmem.
> +			 */
> +			else if (pte_write(entry) && PageDirty(page))
> +				entry = pte_mkdirty(entry);
> +#endif
>  		}
>  		set_pte_at(mm, address, page_table, entry);
>  
> -- 
> blue skies,
>    Martin.
> 
> "Reality continues to ruin my life." - Calvin.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

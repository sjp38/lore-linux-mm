Date: Mon, 25 Apr 2005 20:37:39 -0700
From: Andrew Morton <akpm@osdl.org>
Subject: Re: [PATCH]: VM 2/8 rmap.c cleanup
Message-Id: <20050425203739.5f653204.akpm@osdl.org>
In-Reply-To: <16994.40538.327768.911229@gargle.gargle.HOWL>
References: <16994.40538.327768.911229@gargle.gargle.HOWL>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nikita Danilov <nikita@clusterfs.com>
Cc: linux-mm@kvack.org, AKPM@osdl.org
List-ID: <linux-mm.kvack.org>

Nikita Danilov <nikita@clusterfs.com> wrote:
>
> mm/rmap.c:page_referenced_one() and mm/rmap.c:try_to_unmap_one() contain
>  identical code that
> 
>   - takes mm->page_table_lock;
> 
>   - drills through page tables;
> 
>   - checks that correct pte is reached.
> 
>  Coalesce this into page_check_address()
> 
> ...
>   /*
>  + * Check that @page is mapped at @address into @mm.
>  + *
>  + * On success returns with mapped pte and locked mm->page_table_lock.
>  + */
>  +static pte_t *page_check_address(struct page *page, struct mm_struct *mm,
>  +					unsigned long address)
>  +{
>  +	pgd_t *pgd;
>  +	pud_t *pud;
>  +	pmd_t *pmd;
>  +	pte_t *pte;
>  +
>  +	/*
>  +	 * We need the page_table_lock to protect us from page faults,
>  +	 * munmap, fork, etc...
>  +	 */
>  +	spin_lock(&mm->page_table_lock);
>  +	pgd = pgd_offset(mm, address);
>  +	if (likely(pgd_present(*pgd))) {
>  +		pud = pud_offset(pgd, address);
>  +		if (likely(pud_present(*pud))) {
>  +			pmd = pmd_offset(pud, address);
>  +			if (likely(pmd_present(*pmd))) {
>  +				pte = pte_offset_map(pmd, address);
>  +				if (likely(pte_present(*pte) &&
>  +					   page_to_pfn(page) == pte_pfn(*pte)))
>  +					return pte;
>  +				pte_unmap(pte);
>  +			}
>  +		}
>  +	}
>  +	spin_unlock(&mm->page_table_lock);
>  +	return ERR_PTR(-ENOENT);
>  +}

Can we not simply return NULL in the failure case?
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>

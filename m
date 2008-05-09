Message-ID: <48246815.9070607@goop.org>
Date: Fri, 09 May 2008 16:04:53 +0100
From: Jeremy Fitzhardinge <jeremy@goop.org>
MIME-Version: 1.0
Subject: Re: [RFC/PATCH 2/2] MM: Make Page Tables Relocatable --relcoation
 code
References: <20080509135107.28D11DCA63@localhost>
In-Reply-To: <20080509135107.28D11DCA63@localhost>
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Ross Biro <rossb@google.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Ross Biro wrote:
> +void update_new_page_and_free(struct mm_struct *mm, struct page *old_page)
> +{
> +
> +	int type;
> +
> +	/* Currently we only worry about cpu bits in ptes. */
> +	if (old_page->page_table_type == PAGE_TABLE_PTE) {
> +		struct page *new_page = old_page->migrated_page;
> +		spinlock_t *ptl;
> +		pte_t *old;
> +		pte_t *new;
> +		int i;
> +#ifdef __pte_lockptr
> +		ptl = __pte_lockptr(new_page);
> +#else
> +		ptl = &mm->page_table_lock;
> +#endif
> +		spin_lock(ptl);
> +		old = (pte_t *)kmap_atomic(old_page, KM_PTE0);
> +		new = (pte_t *)kmap_atomic(new_page, KM_PTE1);
> +		for (i = 0; i < PTRS_PER_PTE; i++)
> +			arch_copy_cpu_bits_pte(old, new);
>   

old++, new++?

> +
> +		kunmap_atomic(new_page, KM_PTE1);
> +		kunmap_atomic(old_page, KM_PTE0);
> +		new_page->migrated_page = NULL;
> +		spin_unlock(ptl);
> +	}
> +
> +	old_page->migrated_page = NULL;
> +	type = old_page->page_table_type;
> +	reset_page_mapcount(old_page);
> +
> +	free_page_table_page(mm, old_page, type);
> +}

    J

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

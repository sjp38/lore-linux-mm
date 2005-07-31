Date: Sun, 31 Jul 2005 06:39:43 -0500
From: Robin Holt <holt@sgi.com>
Subject: Re: get_user_pages() with write=1 and force=1 gets read-only pages.
Message-ID: <20050731113943.GD2254@lnx-holt.americas.sgi.com>
References: <20050730205319.GA1233@lnx-holt.americas.sgi.com> <Pine.LNX.4.61.0507302255390.5143@goblin.wat.veritas.com> <42EC2ED6.2070700@yahoo.com.au> <20050731105234.GA2254@lnx-holt.americas.sgi.com> <42ECB0EC.4000808@yahoo.com.au> <20050731113059.GC2254@lnx-holt.americas.sgi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20050731113059.GC2254@lnx-holt.americas.sgi.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Robin Holt <holt@sgi.com>
Cc: Nick Piggin <nickpiggin@yahoo.com.au>, Hugh Dickins <hugh@veritas.com>, Roland McGrath <roland@redhat.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

After actually thinking, I realize the do_anonymous_page path changes
are pointless.  Please ignore those.

Thanks,
Robin
> Index: linux/mm/memory.c
> ===================================================================
> --- linux.orig/mm/memory.c	2005-07-31 05:39:24.161826311 -0500
> +++ linux/mm/memory.c	2005-07-31 06:26:33.687274327 -0500
> @@ -1768,17 +1768,17 @@ do_anonymous_page(struct mm_struct *mm, 
>  		spin_lock(&mm->page_table_lock);
>  		page_table = pte_offset_map(pmd, addr);
>  
> +		entry = maybe_mkwrite(pte_mkdirty(mk_pte(page,
> +						vma->vm_page_prot)), vma);
>  		if (!pte_none(*page_table)) {
> +			if (!pte_same(*page_table, entry))
> +				ret = VM_FAULT_RACE;
>  			pte_unmap(page_table);
>  			page_cache_release(page);
>  			spin_unlock(&mm->page_table_lock);
> -			ret = VM_FAULT_RACE;
>  			goto out;
>  		}
>  		inc_mm_counter(mm, rss);
> -		entry = maybe_mkwrite(pte_mkdirty(mk_pte(page,
> -							 vma->vm_page_prot)),
> -				      vma);
>  		lru_cache_add_active(page);
>  		SetPageReferenced(page);
>  		page_add_anon_rmap(page, vma, addr);
> @@ -1879,6 +1879,10 @@ retry:
>  	}
>  	page_table = pte_offset_map(pmd, address);
>  
> +	entry = mk_pte(new_page, vma->vm_page_prot);
> +	if (write_access)
> +		entry = maybe_mkwrite(pte_mkdirty(entry), vma);
> +
>  	/*
>  	 * This silly early PAGE_DIRTY setting removes a race
>  	 * due to the bad i386 page protection. But it's valid
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

Date: Thu, 7 Aug 2003 18:37:44 -0700
From: Andrew Morton <akpm@osdl.org>
Subject: Re: [RFC] prefault optimization
Message-Id: <20030807183744.5eb19ba9.akpm@osdl.org>
In-Reply-To: <3F32ECE0.1000102@us.ibm.com>
References: <3F32ECE0.1000102@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Adam Litke <agl@us.ibm.com>
Cc: linux-mm@kvack.org, mbligh@aracnet.com
List-ID: <linux-mm.kvack.org>

Adam Litke <agl@us.ibm.com> wrote:
>
> This patch attempts to reduce page fault overhead for mmap'd files.  All 
> pages in the page cache that will be managed by the current vma are 
> instantiated in the page table.  This boots, but some applications fail 
> (eg. make).  I am probably missing a corner case somewhere.  Let me know 
> what you think.

Well it's simple enough.

I'd like to see it using find_get_pages() though.

And find a way to hold the pte page's atomic kmap across the whole pte page
(or at least a find_get_pages' chunk worth) rather than dropping and
reacquiring it all the time.

Perhaps it can use install_page() as well, rather than open-coding it?


> +		pte = pte_offset_map(pmd, address);
> +		if(pte_none(*pte)) { /* don't touch instantiated ptes */
> +			new_page = find_get_page(mapping, offset);
> +			if(!new_page)
> +				continue;
> +			
> +			/* This code taken directly from do_no_page() */
> +			pte_chain = pte_chain_alloc(GFP_KERNEL);

Cannot do a sleeping allocation while holding the atomic kmap from
pte_offset_map().  

> +			++mm->rss;
> +			flush_icache_page(vma, new_page);
> +			entry = mk_pte(new_page, vma->vm_page_prot);
> +			set_pte(pte, entry);
> +			pte_chain = page_add_rmap(new_page, pte, pte_chain);
> +			pte_unmap(page_table);
> +			update_mmu_cache(vma, address, *pte);
> +			pte_chain_free(pte_chain);
> +		}

		else
			pte_unmap(pte);



And the pte_chain handling can be optimised:

	struct pte_chain *pte_chain = NULL;

	...
	for ( ... ) {
		if (pte_chain == NULL)
			pte_chain = pte_chain_alloc();
		...
		pte_chain = page_add_rmap(page, pte_chain);
	}
	...
	pte_chain_free(pte_chain);


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>

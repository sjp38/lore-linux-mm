Subject: Re: [patch 2/2]: introduce fast_gup
From: Peter Zijlstra <peterz@infradead.org>
In-Reply-To: <20080328030023.GC8083@wotan.suse.de>
References: <20080328025455.GA8083@wotan.suse.de>
	 <20080328030023.GC8083@wotan.suse.de>
Content-Type: text/plain
Date: Tue, 22 Apr 2008 11:42:36 +0200
Message-Id: <1208857356.7115.218.camel@twins>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nick Piggin <npiggin@suse.de>
Cc: Andrew Morton <akpm@linux-foundation.org>, shaggy@austin.ibm.com, axboe@kernel.dk, linux-mm@kvack.org, linux-arch@vger.kernel.org, torvalds@linux-foundation.org
List-ID: <linux-mm.kvack.org>

On Fri, 2008-03-28 at 04:00 +0100, Nick Piggin wrote:

> +static noinline int gup_pte_range(pmd_t pmd, unsigned long addr,
> +		unsigned long end, int write, struct page **pages, int *nr)
> +{
> +	unsigned long mask, result;
> +	pte_t *ptep;
> +
> +	result = _PAGE_PRESENT|_PAGE_USER;
> +	if (write)
> +		result |= _PAGE_RW;
> +	mask = result | _PAGE_SPECIAL;
> +
> +	ptep = pte_offset_map(&pmd, addr);
> +	do {
> +		/*
> +		 * XXX: careful. On 3-level 32-bit, the pte is 64 bits, and
> +		 * we need to make sure we load the low word first, then the
> +		 * high. This means _PAGE_PRESENT should be clear if the high
> +		 * word was not valid. Currently, the C compiler can issue
> +		 * the loads in any order, and I don't know of a wrapper
> +		 * function that will do this properly, so it is broken on
> +		 * 32-bit 3-level for the moment.
> +		 */
> +		pte_t pte = *ptep;
> +		struct page *page;
> +
> +		if ((pte_val(pte) & mask) != result)
> +			return 0;

This return path fails to unmap the pmd.

> +		VM_BUG_ON(!pfn_valid(pte_pfn(pte)));
> +		page = pte_page(pte);
> +		get_page(page);
> +		pages[*nr] = page;
> +		(*nr)++;
> +
> +	} while (ptep++, addr += PAGE_SIZE, addr != end);
> +	pte_unmap(ptep - 1);
> +
> +	return 1;
> +}


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

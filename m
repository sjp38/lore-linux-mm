Subject: Re: [PATCH] mm: MADV_WILLNEED implementation for anonymous memory
From: Matt Mackall <mpm@selenic.com>
In-Reply-To: <1201714139.28547.237.camel@lappy>
References: <1201714139.28547.237.camel@lappy>
Content-Type: text/plain
Date: Wed, 30 Jan 2008 12:15:59 -0600
Message-Id: <1201716959.4037.17.camel@cinder.waste.org>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Peter Zijlstra <a.p.zijlstra@chello.nl>
Cc: Andrew Morton <akpm@linux-foundation.org>, Hugh Dickins <hugh@veritas.com>, linux-kernel <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Nick Piggin <npiggin@suse.de>, riel <riel@redhat.com>, Lennart Poettering <mztabzr@0pointer.de>
List-ID: <linux-mm.kvack.org>

On Wed, 2008-01-30 at 18:28 +0100, Peter Zijlstra wrote:
> Subject: mm: MADV_WILLNEED implementation for anonymous memory
> 
> Implement MADV_WILLNEED for anonymous pages by walking the page tables and
> starting asynchonous swap cache reads for all encountered swap pages.
> 
> Doing so required a modification to the page table walking library functions.
> Previously ->pte_entry() could be called while holding a kmap_atomic, to
> overcome this problem the pte walker is changed to copy batches of the pmd
> and iterate them.

That's a pretty reasonable approach. My original approach was to buffer
a page worth of PTEs with all the attendant malloc annoyances. Then
Andrew and I came up with another fix a bit ago by effectively doing a
batch of size 1: mapping and immediately unmapping per PTE. That's
basically a no-op on !HIGHPTE but could potentially be expensive in the
HIGHPTE case. Your approach might be a good complexity/performance
middle ground.

Unfortunately, I think we only implemented our fix in one of the
relevant places: the /proc/pid/pagemap code hooks a callback at the pte
table level and then does its own walk across the table. Perhaps I
should refactor this so that it hooks in at the pte entry level of the
walker instead.

> +/*
> + * Much of the complication here is to work around CONFIG_HIGHPTE which needs
> + * to kmap the pmd. So copy batches of ptes from the pmd and iterate over
> + * those.
> + */
> +#define WALK_BATCH_SIZE	32
> +
>  static int walk_pte_range(pmd_t *pmd, unsigned long addr, unsigned long end,
>  			  const struct mm_walk *walk, void *private)
>  {
>  	pte_t *pte;
> +	pte_t ptes[WALK_BATCH_SIZE];
> +	unsigned long start;
> +	unsigned int i;
>  	int err = 0;
>  
> -	pte = pte_offset_map(pmd, addr);
>  	do {
> -		err = walk->pte_entry(pte, addr, addr + PAGE_SIZE, private);
> -		if (err)
> -		       break;
> -	} while (pte++, addr += PAGE_SIZE, addr != end);
> +		start = addr;
>  
> -	pte_unmap(pte);
> +		pte = pte_offset_map(pmd, addr);
> +		for (i = 0; i < WALK_BATCH_SIZE && addr != end;
> +				i++, pte++, addr += PAGE_SIZE)
> +			ptes[i] = *pte;

Looks like this could be:

		for (i = 0; i < WALK_BATCH_SIZE && addr + i * PAGE_SIZE != end; i++)
			ptes[i] = pte[i];

> +		pte_unmap(pte);
> +
> +		for (i = 0, pte = ptes, addr = start;
> +				i < WALK_BATCH_SIZE && addr != end;
> +				i++, pte++, addr += PAGE_SIZE) {
> +			err = walk->pte_entry(pte, addr, addr + PAGE_SIZE,
> +					private);
		for (i = 0; i < WALK_BATCH_SIZE && addr != end;
			i++, addr+= PAGE_SIZE) {
			err = walk->pte_entry(ptes[i], addr, addr + PAGE_SIZE,
				private);

And we can ditch start.

Also, one wonders if setting batch size to 1 will then convince the
compiler to collapse this into a more trivial loop in the !HIGHPTE case.

-- 
Mathematics is the supreme nostalgia of our time.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

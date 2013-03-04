Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx111.postini.com [74.125.245.111])
	by kanga.kvack.org (Postfix) with SMTP id 06DEE6B0002
	for <linux-mm@kvack.org>; Sun,  3 Mar 2013 23:59:31 -0500 (EST)
Date: Mon, 4 Mar 2013 15:58:53 +1100
From: Paul Mackerras <paulus@samba.org>
Subject: Re: [PATCH -V1 06/24] powerpc: Reduce PTE table memory wastage
Message-ID: <20130304045853.GB27523@drongo>
References: <1361865914-13911-1-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
 <1361865914-13911-7-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1361865914-13911-7-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
Cc: benh@kernel.crashing.org, linuxppc-dev@lists.ozlabs.org, linux-mm@kvack.org

On Tue, Feb 26, 2013 at 01:34:56PM +0530, Aneesh Kumar K.V wrote:
> From: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
> 
> We allocate one page for the last level of linux page table. With THP and
> large page size of 16MB, that would mean we are be wasting large part
> of that page. To map 16MB area, we only need a PTE space of 2K with 64K
> page size. This patch reduce the space wastage by sharing the page
> allocated for the last level of linux page table with multiple pmd
> entries. We call these smaller chunks PTE page fragments and allocated
> page, PTE page. We use the page->_mapcount as bitmap to indicate which
> PTE fragments are free.
> 
> page->_mapcount is divided into two halves. The upper half is used for
> tracking the freed page framents in the RCU grace period.
> 
> In order to support systems which doesn't have 64K HPTE support, we also
> add another 2K to PTE page fragment. The second half of the PTE fragments
> is used for storing slot and secondary bit information of an HPTE. With this
> we now have a 4K PTE fragment.
> 
> Signed-off-by: Aneesh Kumar K.V <aneesh.kumar@linux.vnet.ibm.com>

This one has taken me hours to review.  Perhaps it's partly because of
the way that diff has matched things up, but it's difficult to see
what's moved where, what's common code that is now the 4k page case,
etc.  For example, pmd_alloc_one() and pmd_free() are unchanged, but
the diff shows them as removed in one place and added in another.

The other general comment I have is that it's not really clear when a
page will be on the mm->context.pgtable_list and when it won't.  I
would like to see an invariant that says something like "the page is
on the pgtable_list if and only if (page->_mapcount & FRAG_MASK) is
neither 0 nor FRAG_MASK".  But that doesn't seem to be the case
exactly, and I can't see any consistent rule, which makes me think
there are going to be bugs in corner cases.

Consider, for example, the case where a page has two fragments still
in use, and one of them gets queued up by RCU for freeing via a call
to page_table_free_rcu, and then the other one gets freed through
page_table_free().  Neither the call to page_table_free_rcu nor the
call to page_table_free will take the page off the list AFAICS, and
then __page_table_free_rcu() will free the page while it's still on
the pgtable_list.

More specific comments below...

> -static inline void pgtable_free(void *table, unsigned index_size)
> -{
> -	if (!index_size)
> -		free_page((unsigned long)table);
> -	else {
> -		BUG_ON(index_size > MAX_PGTABLE_INDEX_SIZE);
> -		kmem_cache_free(PGT_CACHE(index_size), table);
> -	}
> -}

This is still used in the UP case, both for 4k and 64k, and UP configs
now fail to build.

>  static inline void pte_free_kernel(struct mm_struct *mm, pte_t *pte)
>  {
>  	free_page((unsigned long)pte);
> @@ -156,7 +118,12 @@ static inline void __tlb_remove_table(void *_table)
>  	void *table = (void *)((unsigned long)_table & ~MAX_PGTABLE_INDEX_SIZE);
>  	unsigned shift = (unsigned long)_table & MAX_PGTABLE_INDEX_SIZE;
>  
> -	pgtable_free(table, shift);
> +	if (!shift)
> +		free_page((unsigned long)table);
> +	else {
> +		BUG_ON(shift > MAX_PGTABLE_INDEX_SIZE);
> +		kmem_cache_free(PGT_CACHE(shift), table);
> +	}

Any particular reason for open-coding pgtable_free() here?

> +/*
> + * we support 15 fragments per PTE page. This is limited by how many
> + * bits we can pack in page->_mapcount. We use the first half for
> + * tracking the usage for rcu page table free.
> + */
> +#define FRAG_MASK_BITS	15
> +#define FRAG_MASK ((1 << FRAG_MASK_BITS) - 1)

Atomic_t variables are 32-bit, so you really should be able to make
FRAG_MASK_BITS be 16 and avoid wasting the last fragment of each page.

Paul.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

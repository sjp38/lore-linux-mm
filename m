Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx183.postini.com [74.125.245.183])
	by kanga.kvack.org (Postfix) with SMTP id 37F9F6B0366
	for <linux-mm@kvack.org>; Mon, 25 Jun 2012 12:03:25 -0400 (EDT)
Date: Mon, 25 Jun 2012 18:03:22 +0200
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [PATCH 1/5] mm/sparse: check size of struct mm_section
Message-ID: <20120625160322.GE19810@tiehlicka.suse.cz>
References: <1340466776-4976-1-git-send-email-shangw@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1340466776-4976-1-git-send-email-shangw@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Gavin Shan <shangw@linux.vnet.ibm.com>
Cc: linux-mm@kvack.org, rientjes@google.com, hannes@cmpxchg.org, akpm@linux-foundation.org

On Sat 23-06-12 23:52:52, Gavin Shan wrote:
> Platforms like PPC might need two level mem_section for SPARSEMEM
> with enabled CONFIG_SPARSEMEM_EXTREME. On the other hand, the
> memory section descriptor might be allocated from bootmem allocator
> with PAGE_SIZE alignment. In order to fully utilize the memory chunk
> allocated from bootmem allocator, it'd better to assure memory
> sector descriptor won't run across the boundary (PAGE_SIZE).

Why? The memory is continuous, right?

> 
> The patch introduces the check on size of "struct mm_section" to
> assure that.
> 
> Signed-off-by: Gavin Shan <shangw@linux.vnet.ibm.com>
> ---
>  mm/sparse.c |    9 +++++++++
>  1 file changed, 9 insertions(+)
> 
> diff --git a/mm/sparse.c b/mm/sparse.c
> index 6a4bf91..afd0998 100644
> --- a/mm/sparse.c
> +++ b/mm/sparse.c
> @@ -63,6 +63,15 @@ static struct mem_section noinline __init_refok *sparse_index_alloc(int nid)
>  	unsigned long array_size = SECTIONS_PER_ROOT *
>  				   sizeof(struct mem_section);
>  
> +	/*
> +	 * The root memory section descriptor might be allocated
> +	 * from bootmem, which has minimal memory chunk requirement
> +	 * of page. In order to fully utilize the memory, the sparse
> +	 * memory section descriptor shouldn't run across the boundary
> +	 * that bootmem allocator has.
> +	 */
> +	BUILD_BUG_ON(PAGE_SIZE % sizeof(struct mem_section));
> +
>  	if (slab_is_available()) {
>  		if (node_state(nid, N_HIGH_MEMORY))
>  			section = kmalloc_node(array_size, GFP_KERNEL, nid);
> -- 
> 1.7.9.5
> 
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

-- 
Michal Hocko
SUSE Labs
SUSE LINUX s.r.o.
Lihovarska 1060/12
190 00 Praha 9    
Czech Republic

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

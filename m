Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx189.postini.com [74.125.245.189])
	by kanga.kvack.org (Postfix) with SMTP id D95546B0361
	for <linux-mm@kvack.org>; Mon, 25 Jun 2012 11:30:38 -0400 (EDT)
Date: Mon, 25 Jun 2012 17:30:35 +0200
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [PATCH 2/5] mm/sparse: optimize sparse_index_alloc
Message-ID: <20120625153035.GB19810@tiehlicka.suse.cz>
References: <1340466776-4976-1-git-send-email-shangw@linux.vnet.ibm.com>
 <1340466776-4976-2-git-send-email-shangw@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1340466776-4976-2-git-send-email-shangw@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Gavin Shan <shangw@linux.vnet.ibm.com>
Cc: linux-mm@kvack.org, rientjes@google.com, hannes@cmpxchg.org, akpm@linux-foundation.org

On Sat 23-06-12 23:52:53, Gavin Shan wrote:
> With CONFIG_SPARSEMEM_EXTREME, the two level of memory section
> descriptors are allocated from slab or bootmem. When allocating
> from slab, let slab allocator to clear the memory chunk. However,
> the memory chunk from bootmem allocator, we have to clear that
> explicitly.

I am sorry but I do not see how this optimize the current code. What is
the difference between slab doing memset and doing it explicitly for all
cases?

> 
> Signed-off-by: Gavin Shan <shangw@linux.vnet.ibm.com>
> ---
>  mm/sparse.c |   12 ++++++------
>  1 file changed, 6 insertions(+), 6 deletions(-)
> 
> diff --git a/mm/sparse.c b/mm/sparse.c
> index afd0998..ce50c8b 100644
> --- a/mm/sparse.c
> +++ b/mm/sparse.c
> @@ -74,14 +74,14 @@ static struct mem_section noinline __init_refok *sparse_index_alloc(int nid)
>  
>  	if (slab_is_available()) {
>  		if (node_state(nid, N_HIGH_MEMORY))
> -			section = kmalloc_node(array_size, GFP_KERNEL, nid);
> +			section = kzalloc_node(array_size, GFP_KERNEL, nid);
>  		else
> -			section = kmalloc(array_size, GFP_KERNEL);
> -	} else
> +			section = kzalloc(array_size, GFP_KERNEL);
> +	} else {
>  		section = alloc_bootmem_node(NODE_DATA(nid), array_size);
> -
> -	if (section)
> -		memset(section, 0, array_size);
> +		if (section)
> +			memset(section, 0, array_size);
> +	}
>  
>  	return section;
>  }
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

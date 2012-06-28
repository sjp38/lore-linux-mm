Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx131.postini.com [74.125.245.131])
	by kanga.kvack.org (Postfix) with SMTP id A616D6B005C
	for <linux-mm@kvack.org>; Thu, 28 Jun 2012 08:52:45 -0400 (EDT)
Date: Thu, 28 Jun 2012 14:52:43 +0200
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [PATCH v2 1/3] mm/sparse: optimize sparse_index_alloc
Message-ID: <20120628125243.GB16042@tiehlicka.suse.cz>
References: <1340814968-2948-1-git-send-email-shangw@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1340814968-2948-1-git-send-email-shangw@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Gavin Shan <shangw@linux.vnet.ibm.com>
Cc: linux-mm@kvack.org, dave@linux.vnet.ibm.com, rientjes@google.com, hannes@cmpxchg.org, akpm@linux-foundation.org

On Thu 28-06-12 00:36:06, Gavin Shan wrote:
> With CONFIG_SPARSEMEM_EXTREME, the two level of memory section
> descriptors are allocated from slab or bootmem. When allocating
> from slab, let slab/bootmem allocator to clear the memory chunk.
> We needn't clear that explicitly.
> 
> Signed-off-by: Gavin Shan <shangw@linux.vnet.ibm.com>
> Reviewed-by: Michal Hocko <mhocko@suse.cz>

Well, I don't remember to give my r-b but now you have it official
(please do not do that in future)
Reviewed-by: Michal Hocko <mhocko@suse.cz>

> ---
>  mm/sparse.c |   10 ++++------
>  1 file changed, 4 insertions(+), 6 deletions(-)
> 
> diff --git a/mm/sparse.c b/mm/sparse.c
> index 6a4bf91..781fa04 100644
> --- a/mm/sparse.c
> +++ b/mm/sparse.c
> @@ -65,14 +65,12 @@ static struct mem_section noinline __init_refok *sparse_index_alloc(int nid)
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
> +	}
>  
>  	return section;
>  }
> -- 
> 1.7.9.5
> 

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

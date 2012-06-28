Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx150.postini.com [74.125.245.150])
	by kanga.kvack.org (Postfix) with SMTP id 8AE356B0087
	for <linux-mm@kvack.org>; Thu, 28 Jun 2012 08:57:46 -0400 (EDT)
Date: Thu, 28 Jun 2012 14:57:42 +0200
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [PATCH v2 2/3] mm/sparse: fix possible memory leak
Message-ID: <20120628125742.GC16042@tiehlicka.suse.cz>
References: <1340814968-2948-1-git-send-email-shangw@linux.vnet.ibm.com>
 <1340814968-2948-2-git-send-email-shangw@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1340814968-2948-2-git-send-email-shangw@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Gavin Shan <shangw@linux.vnet.ibm.com>
Cc: linux-mm@kvack.org, dave@linux.vnet.ibm.com, rientjes@google.com, hannes@cmpxchg.org, akpm@linux-foundation.org

On Thu 28-06-12 00:36:07, Gavin Shan wrote:
> With CONFIG_SPARSEMEM_EXTREME, the root memory section descriptors
> are allocated by slab or bootmem allocator. Also, the descriptors
> might have been allocated and initialized during the hotplug path.
> However, the memory chunk allocated in current implementation wouldn't
> be put into the available pool if that has been allocated. The situation
> will lead to memory leak.
> 
> Signed-off-by: Gavin Shan <shangw@linux.vnet.ibm.com>
> Reviewed-by: Michal Hocko <mhocko@suse.cz>

And again!
To quote my answers to this patch in previous run:
"
I am not saying the bug is not real. It is just that the changelog
doesn's say how the bug is hit, who is affected and when it has been
introduced. These is essential for stable.
"

Does this sound like Reviewed-by? Hell no!

This changelog btw. doesn't say this either!

> ---
>  mm/sparse.c |   19 +++++++++++++++++++
>  1 file changed, 19 insertions(+)
> 
> diff --git a/mm/sparse.c b/mm/sparse.c
> index 781fa04..a803599 100644
> --- a/mm/sparse.c
> +++ b/mm/sparse.c
> @@ -75,6 +75,22 @@ static struct mem_section noinline __init_refok *sparse_index_alloc(int nid)
>  	return section;
>  }
>  
> +static void noinline __init_refok sparse_index_free(struct mem_section *section,
> +						    int nid)
> +{
> +	unsigned long size = SECTIONS_PER_ROOT *
> +			     sizeof(struct mem_section);
> +
> +	if (!section)
> +		return;
> +
> +	if (slab_is_available())
> +		kfree(section);
> +	else
> +		free_bootmem_node(NODE_DATA(nid),
> +			virt_to_phys(section), size);
> +}
> +
>  static int __meminit sparse_index_init(unsigned long section_nr, int nid)
>  {
>  	static DEFINE_SPINLOCK(index_init_lock);
> @@ -102,6 +118,9 @@ static int __meminit sparse_index_init(unsigned long section_nr, int nid)
>  	mem_section[root] = section;
>  out:
>  	spin_unlock(&index_init_lock);
> +	if (ret)
> +		sparse_index_free(section, nid);
> +
>  	return ret;
>  }
>  #else /* !SPARSEMEM_EXTREME */
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

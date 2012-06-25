Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx175.postini.com [74.125.245.175])
	by kanga.kvack.org (Postfix) with SMTP id 804946B0365
	for <linux-mm@kvack.org>; Mon, 25 Jun 2012 11:48:53 -0400 (EDT)
Date: Mon, 25 Jun 2012 17:48:51 +0200
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [PATCH 3/5] mm/sparse: fix possible memory leak
Message-ID: <20120625154851.GD19810@tiehlicka.suse.cz>
References: <1340466776-4976-1-git-send-email-shangw@linux.vnet.ibm.com>
 <1340466776-4976-3-git-send-email-shangw@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1340466776-4976-3-git-send-email-shangw@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Gavin Shan <shangw@linux.vnet.ibm.com>
Cc: linux-mm@kvack.org, rientjes@google.com, hannes@cmpxchg.org, akpm@linux-foundation.org

On Sat 23-06-12 23:52:54, Gavin Shan wrote:
> With CONFIG_SPARSEMEM_EXTREME, the root memory section descriptors
> are allocated by slab or bootmem allocator. Also, the descriptors
> might have been allocated and initialized by others. However, the
> memory chunk allocated in current implementation wouldn't be put
> into the available pool if others have allocated memory chunk for
> that.

Who is others? I assume that we can race in hotplug because other than
that this is an early initialization code. How can others race?

> The patch introduces addtional function sparse_index_free() to
> deallocate the memory chunk if the root memory section descriptor
> has been initialized by others.

The fix itself looks correct but I do not see how this happens...

> Signed-off-by: Gavin Shan <shangw@linux.vnet.ibm.com>
> ---
>  mm/sparse.c |   19 +++++++++++++++++++
>  1 file changed, 19 insertions(+)
> 
> diff --git a/mm/sparse.c b/mm/sparse.c
> index ce50c8b..bae8f2d 100644
> --- a/mm/sparse.c
> +++ b/mm/sparse.c
> @@ -86,6 +86,22 @@ static struct mem_section noinline __init_refok *sparse_index_alloc(int nid)
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
> @@ -113,6 +129,9 @@ static int __meminit sparse_index_init(unsigned long section_nr, int nid)
>  	mem_section[root] = section;
>  out:
>  	spin_unlock(&index_init_lock);
> +	if (ret == -EEXIST)
> +		sparse_index_free(section, nid);

Maybe a generic if (ret) would be more appropriate.

> +
>  	return ret;
>  }
>  #else /* !SPARSEMEM_EXTREME */
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

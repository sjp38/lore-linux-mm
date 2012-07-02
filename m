Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx200.postini.com [74.125.245.200])
	by kanga.kvack.org (Postfix) with SMTP id 5BADC6B0062
	for <linux-mm@kvack.org>; Mon,  2 Jul 2012 05:43:34 -0400 (EDT)
Date: Mon, 2 Jul 2012 11:43:31 +0200
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [PATCH v3 2/3] mm/sparse: fix possible memory leak
Message-ID: <20120702094331.GC8050@tiehlicka.suse.cz>
References: <1341221337-4826-1-git-send-email-shangw@linux.vnet.ibm.com>
 <1341221337-4826-2-git-send-email-shangw@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1341221337-4826-2-git-send-email-shangw@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Gavin Shan <shangw@linux.vnet.ibm.com>
Cc: linux-mm@kvack.org, dave@linux.vnet.ibm.com, rientjes@google.com, akpm@linux-foundation.org

On Mon 02-07-12 17:28:56, Gavin Shan wrote:
> sparse_index_init() is designed to be safe if two copies of it race.  It
> uses "index_init_lock" to ensure that, even in the case of a race, only
> one CPU will manage to do:
> 
> 	mem_section[root] = section;
> 
> However, in the case where two copies of sparse_index_init() _do_ race,
> the one that loses the race will leak the "section" that
> sparse_index_alloc() allocated for it.  This patch fixes that leak.

I would still like to hear how we can possibly race in this code path.
I've thought that memory onlining is done from a single CPU.

> 
> Signed-off-by: Gavin Shan <shangw@linux.vnet.ibm.com>
> ---
>  mm/sparse.c |   17 +++++++++++++++++
>  1 file changed, 17 insertions(+)
> 
> diff --git a/mm/sparse.c b/mm/sparse.c
> index 781fa04..a6984d9 100644
> --- a/mm/sparse.c
> +++ b/mm/sparse.c
> @@ -75,6 +75,20 @@ static struct mem_section noinline __init_refok *sparse_index_alloc(int nid)
>  	return section;
>  }
>  
> +static inline void __meminit sparse_index_free(struct mem_section *section)
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
> +		free_bootmem(virt_to_phys(section), size);
> +}
> +
>  static int __meminit sparse_index_init(unsigned long section_nr, int nid)
>  {
>  	static DEFINE_SPINLOCK(index_init_lock);
> @@ -102,6 +116,9 @@ static int __meminit sparse_index_init(unsigned long section_nr, int nid)
>  	mem_section[root] = section;
>  out:
>  	spin_unlock(&index_init_lock);
> +	if (ret)
> +		sparse_index_free(section);
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

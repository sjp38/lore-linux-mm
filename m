Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx172.postini.com [74.125.245.172])
	by kanga.kvack.org (Postfix) with SMTP id 74E626B0062
	for <linux-mm@kvack.org>; Mon,  2 Jul 2012 07:04:30 -0400 (EDT)
Received: by pbbrp2 with SMTP id rp2so9079990pbb.14
        for <linux-mm@kvack.org>; Mon, 02 Jul 2012 04:04:29 -0700 (PDT)
Date: Mon, 2 Jul 2012 04:04:28 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH v3 2/3] mm/sparse: fix possible memory leak
In-Reply-To: <1341221337-4826-2-git-send-email-shangw@linux.vnet.ibm.com>
Message-ID: <alpine.DEB.2.00.1207020404120.14758@chino.kir.corp.google.com>
References: <1341221337-4826-1-git-send-email-shangw@linux.vnet.ibm.com> <1341221337-4826-2-git-send-email-shangw@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Gavin Shan <shangw@linux.vnet.ibm.com>
Cc: linux-mm@kvack.org, dave@linux.vnet.ibm.com, mhocko@suse.cz, akpm@linux-foundation.org

On Mon, 2 Jul 2012, Gavin Shan wrote:

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

Eek, does that work?

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

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

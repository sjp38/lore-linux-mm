Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx169.postini.com [74.125.245.169])
	by kanga.kvack.org (Postfix) with SMTP id 4BDD86B009C
	for <linux-mm@kvack.org>; Wed, 27 Jun 2012 18:07:43 -0400 (EDT)
Received: by pbbrp2 with SMTP id rp2so2626063pbb.14
        for <linux-mm@kvack.org>; Wed, 27 Jun 2012 15:07:42 -0700 (PDT)
Date: Wed, 27 Jun 2012 15:07:40 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH v2 2/3] mm/sparse: fix possible memory leak
In-Reply-To: <1340814968-2948-2-git-send-email-shangw@linux.vnet.ibm.com>
Message-ID: <alpine.DEB.2.00.1206271501240.22985@chino.kir.corp.google.com>
References: <1340814968-2948-1-git-send-email-shangw@linux.vnet.ibm.com> <1340814968-2948-2-git-send-email-shangw@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Gavin Shan <shangw@linux.vnet.ibm.com>
Cc: linux-mm@kvack.org, mhocko@suse.cz, dave@linux.vnet.ibm.com, hannes@cmpxchg.org, akpm@linux-foundation.org

On Thu, 28 Jun 2012, Gavin Shan wrote:

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

noinline is unecessary, this is only referenced from sparse_index_init() 
and it's perfectly legimitate to inline.  Also, this should be __meminit 
and not __init.

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

Did you check what happens here if !node_state(nid, N_HIGH_MEMORY)?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

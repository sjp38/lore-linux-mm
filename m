Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f200.google.com (mail-qk0-f200.google.com [209.85.220.200])
	by kanga.kvack.org (Postfix) with ESMTP id 059DA6B000D
	for <linux-mm@kvack.org>; Tue, 14 Aug 2018 05:39:39 -0400 (EDT)
Received: by mail-qk0-f200.google.com with SMTP id o18-v6so19635151qko.21
        for <linux-mm@kvack.org>; Tue, 14 Aug 2018 02:39:38 -0700 (PDT)
Received: from mx1.redhat.com (mx3-rdu2.redhat.com. [66.187.233.73])
        by mx.google.com with ESMTPS id o184-v6si3892220qkc.288.2018.08.14.02.39.37
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 14 Aug 2018 02:39:37 -0700 (PDT)
Subject: Re: [PATCH v2 3/3] mm/memory_hotplug: Refactor
 unregister_mem_sect_under_nodes
References: <20180813154639.19454-1-osalvador@techadventures.net>
 <20180813154639.19454-4-osalvador@techadventures.net>
From: David Hildenbrand <david@redhat.com>
Message-ID: <24b69c72-0ebd-476d-1c47-9c64c24b831f@redhat.com>
Date: Tue, 14 Aug 2018 11:39:34 +0200
MIME-Version: 1.0
In-Reply-To: <20180813154639.19454-4-osalvador@techadventures.net>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: osalvador@techadventures.net, akpm@linux-foundation.org
Cc: mhocko@suse.com, dan.j.williams@intel.com, jglisse@redhat.com, rafael@kernel.org, yasu.isimatu@gmail.com, logang@deltatee.com, dave.jiang@intel.com, Jonathan.Cameron@huawei.com, vbabka@suse.cz, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Oscar Salvador <osalvador@suse.de>

On 13.08.2018 17:46, osalvador@techadventures.net wrote:
> From: Oscar Salvador <osalvador@suse.de>
> 
> unregister_mem_sect_under_nodes() tries to allocate a nodemask_t
> in order to check whithin the loop which nodes have already been unlinked,
> so we do not repeat the operation on them.
> 
> NODEMASK_ALLOC calls kmalloc() if NODES_SHIFT > 8, otherwise
> it just declares a nodemask_t variable whithin the stack.
> 
> Since kamlloc() can fail, we actually check whether NODEMASK_ALLOC failed or
> not, and we return -ENOMEM accordingly.
> remove_memory_section() does not check for the return value though.
> 
> The problem with this is that if we return -ENOMEM, it means that
> unregister_mem_sect_under_nodes will not be able to remove the symlinks,
> but since we do not check the return value, we go ahead and we call unregister_memory(),
> which will remove all the mem_blks directories.
> 
> This will leave us with dangled symlinks.
> 
> The easiest way to overcome this is to fallback by calling sysfs_remove_link()
> unconditionally in case NODEMASK_ALLOC failed.
> This means that we will call sysfs_remove_link on nodes that have been already unlinked,
> but nothing wrong happens as sysfs_remove_link() backs off somewhere down the chain in case
> the link has already been removed.
> 
> I think that this is better than
> 
> a) dangled symlinks
> b) having to recovery from such error in remove_memory_section
> 
> Since from now on we will not need to take care about return values, we can make the function void.
> 
> While at it, we can also drop the node_online() check, as a node can only be
> offline if all the memory/cpus associated with it have been removed.

I would prefer splitting this change out into a separate patch.

> 
> As we have a safe fallback, one thing that could also be done is to add __GFP_NORETRY
> in the flags when calling NODEMASK_ALLOC, so we do not retry.
> 
> Signed-off-by: Oscar Salvador <osalvador@suse.de>
> ---
>  drivers/base/node.c  | 26 +++++++++++++++-----------
>  include/linux/node.h |  5 ++---
>  2 files changed, 17 insertions(+), 14 deletions(-)
> 
> diff --git a/drivers/base/node.c b/drivers/base/node.c
> index dd3bdab230b2..0a3ca62687ea 100644
> --- a/drivers/base/node.c
> +++ b/drivers/base/node.c
> @@ -449,35 +449,39 @@ int register_mem_sect_under_node(struct memory_block *mem_blk, void *arg)
>  }
>  
>  /* unregister memory section under all nodes that it spans */
> -int unregister_mem_sect_under_nodes(struct memory_block *mem_blk,
> +void unregister_mem_sect_under_nodes(struct memory_block *mem_blk,
>  				    unsigned long phys_index)
>  {
>  	NODEMASK_ALLOC(nodemask_t, unlinked_nodes, GFP_KERNEL);
>  	unsigned long pfn, sect_start_pfn, sect_end_pfn;
>  
> -	if (!unlinked_nodes)
> -		return -ENOMEM;
> -	nodes_clear(*unlinked_nodes);
> +	if (unlinked_nodes)
> +		nodes_clear(*unlinked_nodes);
>  
>  	sect_start_pfn = section_nr_to_pfn(phys_index);
>  	sect_end_pfn = sect_start_pfn + PAGES_PER_SECTION - 1;
>  	for (pfn = sect_start_pfn; pfn <= sect_end_pfn; pfn++) {
> -		int nid;
> +		int nid = get_nid_for_pfn(pfn);;
>  
> -		nid = get_nid_for_pfn(pfn);
>  		if (nid < 0)
>  			continue;
> -		if (!node_online(nid))
> -			continue;
> -		if (node_test_and_set(nid, *unlinked_nodes))
> +		/*
> +		 * It is possible that NODEMASK_ALLOC fails due to memory pressure.
> +		 * If that happens, we fallback to call sysfs_remove_link unconditionally.
> +		 * Nothing wrong will happen as sysfs_remove_link will back off
> +		 * somewhere down the chain in case the link has already been removed.
> +		 */
> +		if (unlinked_nodes && node_test_and_set(nid, *unlinked_nodes))
>  			continue;
> +
>  		sysfs_remove_link(&node_devices[nid]->dev.kobj,
>  			 kobject_name(&mem_blk->dev.kobj));
>  		sysfs_remove_link(&mem_blk->dev.kobj,
>  			 kobject_name(&node_devices[nid]->dev.kobj));
>  	}
> -	NODEMASK_FREE(unlinked_nodes);
> -	return 0;
> +
> +	if (unlinked_nodes)
> +		NODEMASK_FREE(unlinked_nodes);

NODEMASK_FEEE/kfree can deal with NULL pointers.

>  }
>  
>  int link_mem_sections(int nid, unsigned long start_pfn, unsigned long end_pfn)
> diff --git a/include/linux/node.h b/include/linux/node.h
> index 257bb3d6d014..1203378e596a 100644
> --- a/include/linux/node.h
> +++ b/include/linux/node.h
> @@ -72,7 +72,7 @@ extern int register_cpu_under_node(unsigned int cpu, unsigned int nid);
>  extern int unregister_cpu_under_node(unsigned int cpu, unsigned int nid);
>  extern int register_mem_sect_under_node(struct memory_block *mem_blk,
>  						void *arg);
> -extern int unregister_mem_sect_under_nodes(struct memory_block *mem_blk,
> +extern void unregister_mem_sect_under_nodes(struct memory_block *mem_blk,
>  					   unsigned long phys_index);
>  
>  #ifdef CONFIG_HUGETLBFS
> @@ -105,10 +105,9 @@ static inline int register_mem_sect_under_node(struct memory_block *mem_blk,
>  {
>  	return 0;
>  }
> -static inline int unregister_mem_sect_under_nodes(struct memory_block *mem_blk,
> +static inline void unregister_mem_sect_under_nodes(struct memory_block *mem_blk,
>  						  unsigned long phys_index)
>  {
> -	return 0;
>  }
>  
>  static inline void register_hugetlbfs_with_node(node_registration_func_t reg,
> 


-- 

Thanks,

David / dhildenb

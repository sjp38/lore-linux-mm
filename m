Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f200.google.com (mail-qt0-f200.google.com [209.85.216.200])
	by kanga.kvack.org (Postfix) with ESMTP id 627DB6B0691
	for <linux-mm@kvack.org>; Fri, 17 Aug 2018 05:49:55 -0400 (EDT)
Received: by mail-qt0-f200.google.com with SMTP id d25-v6so5828591qtp.10
        for <linux-mm@kvack.org>; Fri, 17 Aug 2018 02:49:55 -0700 (PDT)
Received: from mx1.redhat.com (mx3-rdu2.redhat.com. [66.187.233.73])
        by mx.google.com with ESMTPS id 35-v6si612765qkz.103.2018.08.17.02.49.54
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 17 Aug 2018 02:49:54 -0700 (PDT)
Subject: Re: [PATCH v4 3/4] mm/memory_hotplug: Define nodemask_t as a stack
 variable
References: <20180817090017.17610-1-osalvador@techadventures.net>
 <20180817090017.17610-4-osalvador@techadventures.net>
From: David Hildenbrand <david@redhat.com>
Message-ID: <db489359-09cb-2ccc-34d1-b6d3c58bb1fb@redhat.com>
Date: Fri, 17 Aug 2018 11:49:51 +0200
MIME-Version: 1.0
In-Reply-To: <20180817090017.17610-4-osalvador@techadventures.net>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Oscar Salvador <osalvador@techadventures.net>, akpm@linux-foundation.org
Cc: mhocko@suse.com, vbabka@suse.cz, dan.j.williams@intel.com, yasu.isimatu@gmail.com, jonathan.cameron@huawei.com, Pavel.Tatashin@microsoft.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Oscar Salvador <osalvador@suse.de>

On 17.08.2018 11:00, Oscar Salvador wrote:
> From: Oscar Salvador <osalvador@suse.de>
> 
> Currently, unregister_mem_sect_under_nodes() tries to allocate a nodemask_t
> in order to check whithin the loop which nodes have already been unlinked,
> so we do not repeat the operation on them.
> 
> NODEMASK_ALLOC calls kmalloc() if NODES_SHIFT > 8, otherwise
> it just declares a nodemask_t variable whithin the stack.
> 
> Since kmalloc() can fail, we actually check whether NODEMASK_ALLOC failed
> or not, and we return -ENOMEM accordingly.
> remove_memory_section() does not check for the return value though.
> It is pretty rare that such a tiny allocation can fail, but if it does,
> we will be left with dangled symlinks under /sys/devices/system/node/,
> since the mem_blk's directories will be removed no matter what
> unregister_mem_sect_under_nodes() returns.
> 
> One way to solve this is to check whether unlinked_nodes is NULL or not.
> In the case it is not, we can just use it as before, but if it is NULL,
> we can just skip the node_test_and_set check, and call sysfs_remove_link()
> unconditionally.
> This is harmless as sysfs_remove_link() backs off somewhere down the chain
> in case the link has already been removed.
> This method was presented in v3 of the path [1].
> 
> But since the maximum number of nodes we can have is 1024,
> when NODES_SHIFT = 10, that gives us a nodemask_t of 128 bytes.
> Although everything depends on how deep the stack is, I think we can afford
> to define the nodemask_t variable whithin the stack.
> 
> That simplifies the code, and we do not need to worry about untested error
> code paths.
> 
> If we see that this causes troubles with the stack, we can always return to [1].
> 
> [1] https://patchwork.kernel.org/patch/10566673/
> 
> Signed-off-by: Oscar Salvador <osalvador@suse.de>
> ---
>  drivers/base/node.c  | 16 ++++++----------
>  include/linux/node.h |  5 ++---
>  2 files changed, 8 insertions(+), 13 deletions(-)
> 
> diff --git a/drivers/base/node.c b/drivers/base/node.c
> index dd3bdab230b2..6b8c9b4537c9 100644
> --- a/drivers/base/node.c
> +++ b/drivers/base/node.c
> @@ -449,35 +449,31 @@ int register_mem_sect_under_node(struct memory_block *mem_blk, void *arg)
>  }
>  
>  /* unregister memory section under all nodes that it spans */
> -int unregister_mem_sect_under_nodes(struct memory_block *mem_blk,
> +void unregister_mem_sect_under_nodes(struct memory_block *mem_blk,
>  				    unsigned long phys_index)

I am a friend of fixing up alignment of other parameters.

>  {
> -	NODEMASK_ALLOC(nodemask_t, unlinked_nodes, GFP_KERNEL);
> +	nodemask_t unlinked_nodes;
>  	unsigned long pfn, sect_start_pfn, sect_end_pfn;
>  
> -	if (!unlinked_nodes)
> -		return -ENOMEM;
> -	nodes_clear(*unlinked_nodes);
> +	nodes_clear(unlinked_nodes);
>  
>  	sect_start_pfn = section_nr_to_pfn(phys_index);
>  	sect_end_pfn = sect_start_pfn + PAGES_PER_SECTION - 1;
>  	for (pfn = sect_start_pfn; pfn <= sect_end_pfn; pfn++) {
> -		int nid;
> +		int nid = get_nid_for_pfn(pfn);
>  
> -		nid = get_nid_for_pfn(pfn);
>  		if (nid < 0)
>  			continue;
>  		if (!node_online(nid))
>  			continue;
> -		if (node_test_and_set(nid, *unlinked_nodes))
> +		if (node_test_and_set(nid, unlinked_nodes))
>  			continue;
> +
>  		sysfs_remove_link(&node_devices[nid]->dev.kobj,
>  			 kobject_name(&mem_blk->dev.kobj));
>  		sysfs_remove_link(&mem_blk->dev.kobj,
>  			 kobject_name(&node_devices[nid]->dev.kobj));
>  	}
> -	NODEMASK_FREE(unlinked_nodes);
> -	return 0;
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

dito

>  
>  #ifdef CONFIG_HUGETLBFS
> @@ -105,10 +105,9 @@ static inline int register_mem_sect_under_node(struct memory_block *mem_blk,
>  {
>  	return 0;
>  }
> -static inline int unregister_mem_sect_under_nodes(struct memory_block *mem_blk,
> +static inline void unregister_mem_sect_under_nodes(struct memory_block *mem_blk,
>  						  unsigned long phys_index)

dito

>  {
> -	return 0;
>  }
>  
>  static inline void register_hugetlbfs_with_node(node_registration_func_t reg,
> 

We'll find out if we have enough stack :) But this is definitely simpler.

-- 

Thanks,

David / dhildenb

Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f72.google.com (mail-wm0-f72.google.com [74.125.82.72])
	by kanga.kvack.org (Postfix) with ESMTP id BB0686B0005
	for <linux-mm@kvack.org>; Mon, 19 Feb 2018 08:37:30 -0500 (EST)
Received: by mail-wm0-f72.google.com with SMTP id e74so4820820wmg.0
        for <linux-mm@kvack.org>; Mon, 19 Feb 2018 05:37:30 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id i63si6444187wmh.194.2018.02.19.05.37.29
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Mon, 19 Feb 2018 05:37:29 -0800 (PST)
Date: Mon, 19 Feb 2018 14:37:28 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [v4 5/6] mm/memory_hotplug: don't read nid from struct page
 during hotplug
Message-ID: <20180219133728.GL21134@dhcp22.suse.cz>
References: <20180215165920.8570-1-pasha.tatashin@oracle.com>
 <20180215165920.8570-6-pasha.tatashin@oracle.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180215165920.8570-6-pasha.tatashin@oracle.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Pavel Tatashin <pasha.tatashin@oracle.com>
Cc: steven.sistare@oracle.com, daniel.m.jordan@oracle.com, akpm@linux-foundation.org, mgorman@techsingularity.net, linux-mm@kvack.org, linux-kernel@vger.kernel.org, gregkh@linuxfoundation.org, vbabka@suse.cz, bharata@linux.vnet.ibm.com, tglx@linutronix.de, mingo@redhat.com, hpa@zytor.com, x86@kernel.org, dan.j.williams@intel.com, kirill.shutemov@linux.intel.com, bhe@redhat.com

On Thu 15-02-18 11:59:19, Pavel Tatashin wrote:
> During memory hotplugging the probe routine will leave struct pages
> uninitialized, the same as it is currently done during boot. Therefore, we
> do not want to access the inside of struct pages before
> __init_single_page() is called during onlining.
> 
> Because during hotplug we know that pages in one memory block belong to
> the same numa node, we can skip the checking. We should keep checking for
> the boot case.

This could be more specific. What about the following:
"
register_mem_sect_under_node is careful to check the node id of each
pfn in the memblock range to handle configurations with interleaving
nodes. This is not really needed for the memory hotplug because hotadded
ranges are bound to a single NUMA node. We simply cannot handle interleaving
NUMA nodes in the same memblock currently and there are no signs that
anybody would want anything like that in future. That would require much
more refactoring.

This is a preparatory patch for later patches.
"
> 
> Signed-off-by: Pavel Tatashin <pasha.tatashin@oracle.com>

Other than that this looks sane to me. register_mem_sect_under_node
could see some more improvements on top. E.g. do we really have to crawl
each pfn and try to recreate the sysfs machinery just to realize that we
already have one for the current memblock?

Acked-by: Michal Hocko <mhocko@suse.com

> ---
>  drivers/base/memory.c |  2 +-
>  drivers/base/node.c   | 22 +++++++++++++++-------
>  include/linux/node.h  |  4 ++--
>  3 files changed, 18 insertions(+), 10 deletions(-)
> 
> diff --git a/drivers/base/memory.c b/drivers/base/memory.c
> index deb3f029b451..a14fb0cd424a 100644
> --- a/drivers/base/memory.c
> +++ b/drivers/base/memory.c
> @@ -731,7 +731,7 @@ int register_new_memory(int nid, struct mem_section *section)
>  	}
>  
>  	if (mem->section_count == sections_per_block)
> -		ret = register_mem_sect_under_node(mem, nid);
> +		ret = register_mem_sect_under_node(mem, nid, false);
>  out:
>  	mutex_unlock(&mem_sysfs_mutex);
>  	return ret;
> diff --git a/drivers/base/node.c b/drivers/base/node.c
> index ee090ab9171c..d7cfc8d8a5c5 100644
> --- a/drivers/base/node.c
> +++ b/drivers/base/node.c
> @@ -397,7 +397,8 @@ static int __ref get_nid_for_pfn(unsigned long pfn)
>  }
>  
>  /* register memory section under specified node if it spans that node */
> -int register_mem_sect_under_node(struct memory_block *mem_blk, int nid)
> +int register_mem_sect_under_node(struct memory_block *mem_blk, int nid,
> +				 bool check_nid)
>  {
>  	int ret;
>  	unsigned long pfn, sect_start_pfn, sect_end_pfn;
> @@ -423,11 +424,18 @@ int register_mem_sect_under_node(struct memory_block *mem_blk, int nid)
>  			continue;
>  		}
>  
> -		page_nid = get_nid_for_pfn(pfn);
> -		if (page_nid < 0)
> -			continue;
> -		if (page_nid != nid)
> -			continue;
> +		/*
> +		 * We need to check if page belongs to nid only for the boot
> +		 * case, during hotplug we know that all pages in the memory
> +		 * block belong to the same node.
> +		 */
> +		if (check_nid) {
> +			page_nid = get_nid_for_pfn(pfn);
> +			if (page_nid < 0)
> +				continue;
> +			if (page_nid != nid)
> +				continue;
> +		}
>  		ret = sysfs_create_link_nowarn(&node_devices[nid]->dev.kobj,
>  					&mem_blk->dev.kobj,
>  					kobject_name(&mem_blk->dev.kobj));
> @@ -502,7 +510,7 @@ int link_mem_sections(int nid, unsigned long start_pfn, unsigned long nr_pages)
>  
>  		mem_blk = find_memory_block_hinted(mem_sect, mem_blk);
>  
> -		ret = register_mem_sect_under_node(mem_blk, nid);
> +		ret = register_mem_sect_under_node(mem_blk, nid, true);
>  		if (!err)
>  			err = ret;
>  
> diff --git a/include/linux/node.h b/include/linux/node.h
> index 4ece0fee0ffc..41f171861dcc 100644
> --- a/include/linux/node.h
> +++ b/include/linux/node.h
> @@ -67,7 +67,7 @@ extern void unregister_one_node(int nid);
>  extern int register_cpu_under_node(unsigned int cpu, unsigned int nid);
>  extern int unregister_cpu_under_node(unsigned int cpu, unsigned int nid);
>  extern int register_mem_sect_under_node(struct memory_block *mem_blk,
> -						int nid);
> +						int nid, bool check_nid);
>  extern int unregister_mem_sect_under_nodes(struct memory_block *mem_blk,
>  					   unsigned long phys_index);
>  
> @@ -97,7 +97,7 @@ static inline int unregister_cpu_under_node(unsigned int cpu, unsigned int nid)
>  	return 0;
>  }
>  static inline int register_mem_sect_under_node(struct memory_block *mem_blk,
> -							int nid)
> +							int nid, bool check_nid)
>  {
>  	return 0;
>  }
> -- 
> 2.16.1
> 

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

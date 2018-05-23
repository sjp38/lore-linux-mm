Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f71.google.com (mail-pg0-f71.google.com [74.125.83.71])
	by kanga.kvack.org (Postfix) with ESMTP id 50FB66B0008
	for <linux-mm@kvack.org>; Wed, 23 May 2018 10:17:37 -0400 (EDT)
Received: by mail-pg0-f71.google.com with SMTP id t11-v6so6781110pgn.9
        for <linux-mm@kvack.org>; Wed, 23 May 2018 07:17:37 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id w73-v6si19089774pfd.19.2018.05.23.07.17.35
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 23 May 2018 07:17:36 -0700 (PDT)
Date: Wed, 23 May 2018 16:17:33 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH] mm/memory_hotplug: Fix leftover use of struct page
 during hotplug
Message-ID: <20180523141733.GS20441@dhcp22.suse.cz>
References: <20180504085311.1240-1-Jonathan.Cameron@huawei.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180504085311.1240-1-Jonathan.Cameron@huawei.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jonathan Cameron <Jonathan.Cameron@huawei.com>
Cc: linux-mm <linux-mm@kvack.org>, linuxarm@huawei.com, Pavel Tatashin <pasha.tatashin@oracle.com>, Andrew Morton <akpm@linux-foundation.org>

On Fri 04-05-18 09:53:11, Jonathan Cameron wrote:
> The case of a new numa node got missed in avoiding using
> the node info from page_struct during hotplug.  In this
> path we have a call to register_mem_sect_under_node (which allows
> us to specify it is hotplug so don't change the node),
> via link_mem_sections which unfortunately does not.
> 
> Fix is to pass check_nid through link_mem_sections as well and
> disable it in the new numa node path.
> 
> Note the bug only 'sometimes' manifests depending on what happens to
> be in the struct page structures - there are lots of them and it only
> needs to match one of them.
> 
> Fixes: fc44f7f9231a ("mm/memory_hotplug: don't read nid from struct page during hotplug")
> Signed-off-by: Jonathan Cameron <Jonathan.Cameron@huawei.com>

I believe the proper fix is to refactor the sysfs code because it is
just ridiculous. But this should work good enough as the stop gap

Acked-by: Michal Hocko <mhocko@suse.com>

> ---
>  drivers/base/node.c  | 5 +++--
>  include/linux/node.h | 8 +++++---
>  mm/memory_hotplug.c  | 2 +-
>  3 files changed, 9 insertions(+), 6 deletions(-)
> 
> diff --git a/drivers/base/node.c b/drivers/base/node.c
> index 7a3a580821e0..a5e821d09656 100644
> --- a/drivers/base/node.c
> +++ b/drivers/base/node.c
> @@ -490,7 +490,8 @@ int unregister_mem_sect_under_nodes(struct memory_block *mem_blk,
>  	return 0;
>  }
>  
> -int link_mem_sections(int nid, unsigned long start_pfn, unsigned long nr_pages)
> +int link_mem_sections(int nid, unsigned long start_pfn, unsigned long nr_pages,
> +		      bool check_nid)
>  {
>  	unsigned long end_pfn = start_pfn + nr_pages;
>  	unsigned long pfn;
> @@ -514,7 +515,7 @@ int link_mem_sections(int nid, unsigned long start_pfn, unsigned long nr_pages)
>  
>  		mem_blk = find_memory_block_hinted(mem_sect, mem_blk);
>  
> -		ret = register_mem_sect_under_node(mem_blk, nid, true);
> +		ret = register_mem_sect_under_node(mem_blk, nid, check_nid);
>  		if (!err)
>  			err = ret;
>  
> diff --git a/include/linux/node.h b/include/linux/node.h
> index 41f171861dcc..6d336e38d155 100644
> --- a/include/linux/node.h
> +++ b/include/linux/node.h
> @@ -32,9 +32,11 @@ extern struct node *node_devices[];
>  typedef  void (*node_registration_func_t)(struct node *);
>  
>  #if defined(CONFIG_MEMORY_HOTPLUG_SPARSE) && defined(CONFIG_NUMA)
> -extern int link_mem_sections(int nid, unsigned long start_pfn, unsigned long nr_pages);
> +extern int link_mem_sections(int nid, unsigned long start_pfn,
> +			     unsigned long nr_pages, bool check_nid);
>  #else
> -static inline int link_mem_sections(int nid, unsigned long start_pfn, unsigned long nr_pages)
> +static inline int link_mem_sections(int nid, unsigned long start_pfn,
> +				    unsigned long nr_pages, bool check_nid)
>  {
>  	return 0;
>  }
> @@ -57,7 +59,7 @@ static inline int register_one_node(int nid)
>  		if (error)
>  			return error;
>  		/* link memory sections under this node */
> -		error = link_mem_sections(nid, pgdat->node_start_pfn, pgdat->node_spanned_pages);
> +		error = link_mem_sections(nid, pgdat->node_start_pfn, pgdat->node_spanned_pages, true);
>  	}
>  
>  	return error;
> diff --git a/mm/memory_hotplug.c b/mm/memory_hotplug.c
> index f74826cdceea..25982467800b 100644
> --- a/mm/memory_hotplug.c
> +++ b/mm/memory_hotplug.c
> @@ -1158,7 +1158,7 @@ int __ref add_memory_resource(int nid, struct resource *res, bool online)
>  		 * nodes have to go through register_node.
>  		 * TODO clean up this mess.
>  		 */
> -		ret = link_mem_sections(nid, start_pfn, nr_pages);
> +		ret = link_mem_sections(nid, start_pfn, nr_pages, false);
>  register_fail:
>  		/*
>  		 * If sysfs file of new node can't create, cpu on the node
> -- 
> 2.16.2
> 

-- 
Michal Hocko
SUSE Labs

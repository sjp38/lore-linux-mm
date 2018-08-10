Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f72.google.com (mail-pl0-f72.google.com [209.85.160.72])
	by kanga.kvack.org (Postfix) with ESMTP id 17EF36B0003
	for <linux-mm@kvack.org>; Fri, 10 Aug 2018 18:37:31 -0400 (EDT)
Received: by mail-pl0-f72.google.com with SMTP id 90-v6so6602911pla.18
        for <linux-mm@kvack.org>; Fri, 10 Aug 2018 15:37:31 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id u29-v6si10859187pga.29.2018.08.10.15.37.29
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 10 Aug 2018 15:37:29 -0700 (PDT)
Date: Fri, 10 Aug 2018 15:37:27 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH 3/3] mm/memory_hotplug: Cleanup
 unregister_mem_sect_under_nodes
Message-Id: <20180810153727.c9ae4aab518f1b84e04c999a@linux-foundation.org>
In-Reply-To: <20180810152931.23004-4-osalvador@techadventures.net>
References: <20180810152931.23004-1-osalvador@techadventures.net>
	<20180810152931.23004-4-osalvador@techadventures.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: osalvador@techadventures.net
Cc: mhocko@suse.com, vbabka@suse.cz, dan.j.williams@intel.com, yasu.isimatu@gmail.com, jonathan.cameron@huawei.com, david@redhat.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Oscar Salvador <osalvador@suse.de>

On Fri, 10 Aug 2018 17:29:31 +0200 osalvador@techadventures.net wrote:

> From: Oscar Salvador <osalvador@suse.de>
> 
> With the assumption that the relationship between
> memory_block <-> node is 1:1, we can refactor this function a bit.
> 
> This assumption is being taken from register_mem_sect_under_node()
> code.
> 
> register_mem_sect_under_node() takes the mem_blk's nid, and compares it
> to the pfn's nid we are checking.
> If they match, we go ahead and link both objects.
> Once done, we just return.
> 
> So, the relationship between memory_block <-> node seems to stand.
> 
> Currently, unregister_mem_sect_under_nodes() defines a nodemask_t
> which is being checked in the loop to see if we have already unliked certain node.

"unlinked a certain node"

> But since a memory_block can only belong to a node, we can drop the nodemask

"to a single node"?

> and the check within the loop.
> 
> If we find a match between the mem_block->nid and the nid of the
> pfn we are checking, we unlink the objects and return, as unlink the objects

"unlinking"

> once is enough.
> 
> --- a/drivers/base/node.c
> +++ b/drivers/base/node.c
> @@ -448,35 +448,27 @@ int register_mem_sect_under_node(struct memory_block *mem_blk, void *arg)
>  	return 0;
>  }
>  
> -/* unregister memory section under all nodes that it spans */
> +/* unregister memory section from the node it belongs to */
>  int unregister_mem_sect_under_nodes(struct memory_block *mem_blk,
>  				    unsigned long phys_index)
>  {
> -	NODEMASK_ALLOC(nodemask_t, unlinked_nodes, GFP_KERNEL);
>  	unsigned long pfn, sect_start_pfn, sect_end_pfn;
> -
> -	if (!unlinked_nodes)
> -		return -ENOMEM;
> -	nodes_clear(*unlinked_nodes);
> +	int nid = mem_blk->nid;
>  
>  	sect_start_pfn = section_nr_to_pfn(phys_index);
>  	sect_end_pfn = sect_start_pfn + PAGES_PER_SECTION - 1;
>  	for (pfn = sect_start_pfn; pfn <= sect_end_pfn; pfn++) {
> -		int nid;
> +		int page_nid = get_nid_for_pfn(pfn);
>  
> -		nid = get_nid_for_pfn(pfn);
> -		if (nid < 0)
> -			continue;
> -		if (!node_online(nid))
> -			continue;
> -		if (node_test_and_set(nid, *unlinked_nodes))
> -			continue;
> -		sysfs_remove_link(&node_devices[nid]->dev.kobj,
> -			 kobject_name(&mem_blk->dev.kobj));
> -		sysfs_remove_link(&mem_blk->dev.kobj,
> -			 kobject_name(&node_devices[nid]->dev.kobj));
> +		if (page_nid >= 0 && page_nid == nid) {
> +			sysfs_remove_link(&node_devices[nid]->dev.kobj,
> +				 kobject_name(&mem_blk->dev.kobj));
> +			sysfs_remove_link(&mem_blk->dev.kobj,
> +				 kobject_name(&node_devices[nid]->dev.kobj));
> +			break;
> +		}
>  	}
> -	NODEMASK_FREE(unlinked_nodes);
> +
>  	return 0;
>  }

I guess so.  But the node_online() check was silently removed?

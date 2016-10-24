Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f70.google.com (mail-pa0-f70.google.com [209.85.220.70])
	by kanga.kvack.org (Postfix) with ESMTP id 2D8A16B0260
	for <linux-mm@kvack.org>; Mon, 24 Oct 2016 13:16:33 -0400 (EDT)
Received: by mail-pa0-f70.google.com with SMTP id fl2so2026835pad.7
        for <linux-mm@kvack.org>; Mon, 24 Oct 2016 10:16:33 -0700 (PDT)
Received: from mga06.intel.com (mga06.intel.com. [134.134.136.31])
        by mx.google.com with ESMTPS id x67si16370709pfb.20.2016.10.24.10.16.32
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 24 Oct 2016 10:16:32 -0700 (PDT)
Subject: Re: [RFC 3/8] mm: Isolate coherent device memory nodes from HugeTLB
 allocation paths
References: <1477283517-2504-1-git-send-email-khandual@linux.vnet.ibm.com>
 <1477283517-2504-4-git-send-email-khandual@linux.vnet.ibm.com>
From: Dave Hansen <dave.hansen@intel.com>
Message-ID: <580E41F0.20601@intel.com>
Date: Mon, 24 Oct 2016 10:16:32 -0700
MIME-Version: 1.0
In-Reply-To: <1477283517-2504-4-git-send-email-khandual@linux.vnet.ibm.com>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Anshuman Khandual <khandual@linux.vnet.ibm.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
Cc: mhocko@suse.com, js1304@gmail.com, vbabka@suse.cz, mgorman@suse.de, minchan@kernel.org, akpm@linux-foundation.org, aneesh.kumar@linux.vnet.ibm.com, bsingharora@gmail.com

On 10/23/2016 09:31 PM, Anshuman Khandual wrote:
> This change is part of the isolation requiring coherent device memory nodes
> implementation.
> 
> Isolation seeking coherent device memory node requires allocation isolation
> from implicit memory allocations from user space. Towards that effect, the
> memory should not be used for generic HugeTLB page pool allocations. This
> modifies relevant functions to skip all coherent memory nodes present on
> the system during allocation, freeing and auditing for HugeTLB pages.

This seems really fragile.  You had to hit, what, 18 call sites?  What
are the odds that this is going to stay working?

> @@ -2666,6 +2688,10 @@ static void __init hugetlb_register_all_nodes(void)
>  
>  	for_each_node_state(nid, N_MEMORY) {
>  		struct node *node = node_devices[nid];
> +
> +		if (isolated_cdm_node(nid))
> +			continue;
> +
>  		if (node->dev.id == nid)
>  			hugetlb_register_node(node);
>  	}

This looks to be completely kneecapping hugetlbfs on these cdm nodes.
Is that really what you want?

> @@ -2819,8 +2845,12 @@ static unsigned int cpuset_mems_nr(unsigned int *array)
>  	int node;
>  	unsigned int nr = 0;
>  
> -	for_each_node_mask(node, cpuset_current_mems_allowed)
> +	for_each_node_mask(node, cpuset_current_mems_allowed) {
> +		if (isolated_cdm_node(node))
> +			continue;
> +
>  		nr += array[node];
> +	}
>  
>  	return nr;
>  }
> @@ -2940,7 +2970,10 @@ void hugetlb_show_meminfo(void)
>  	if (!hugepages_supported())
>  		return;
>  
> -	for_each_node_state(nid, N_MEMORY)
> +	for_each_node_state(nid, N_MEMORY) {
> +		if (isolated_cdm_node(nid))
> +			continue;
> +
>  		for_each_hstate(h)
>  			pr_info("Node %d hugepages_total=%u hugepages_free=%u hugepages_surp=%u hugepages_size=%lukB\n",
>  				nid,
> @@ -2948,6 +2981,7 @@ void hugetlb_show_meminfo(void)
>  				h->free_huge_pages_node[nid],
>  				h->surplus_huge_pages_node[nid],
>  				1UL << (huge_page_order(h) + PAGE_SHIFT - 10));
> +	}
>  }

Your patch description talks about removing *implicit* memory
allocations.  But, this removes even the ability to gather *stats* about
huge pages sitting on one of these nodes.  That's a lot more drastic
than just changing implicit policies.

Is that patch description accurate?

It looks to me like you just went through all the for_each_node*() loops
in hugetlb.c and hacked your node check into them indiscriminately.
This totally removes the ability to *do* hugetlb on this nodes.

Isn't there some simpler way to do all this, like maybe changing the
root cpuset to disallow allocations to these nodes?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

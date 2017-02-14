Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f198.google.com (mail-wr0-f198.google.com [209.85.128.198])
	by kanga.kvack.org (Postfix) with ESMTP id 9578D6B0389
	for <linux-mm@kvack.org>; Tue, 14 Feb 2017 03:28:18 -0500 (EST)
Received: by mail-wr0-f198.google.com with SMTP id i10so43382051wrb.0
        for <linux-mm@kvack.org>; Tue, 14 Feb 2017 00:28:18 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id o67si201370wme.163.2017.02.14.00.28.17
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 14 Feb 2017 00:28:17 -0800 (PST)
Subject: Re: [PATCH V2 3/3] mm: Enable Buddy allocation isolation for CDM
 nodes
References: <20170210100640.26927-1-khandual@linux.vnet.ibm.com>
 <20170210100640.26927-4-khandual@linux.vnet.ibm.com>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <44bbca4e-af5a-805c-c74b-28e684026611@suse.cz>
Date: Tue, 14 Feb 2017 09:28:14 +0100
MIME-Version: 1.0
In-Reply-To: <20170210100640.26927-4-khandual@linux.vnet.ibm.com>
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Anshuman Khandual <khandual@linux.vnet.ibm.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
Cc: mhocko@suse.com, mgorman@suse.de, minchan@kernel.org, aneesh.kumar@linux.vnet.ibm.com, bsingharora@gmail.com, srikar@linux.vnet.ibm.com, haren@linux.vnet.ibm.com, jglisse@redhat.com, dave.hansen@intel.com, dan.j.williams@intel.com

On 02/10/2017 11:06 AM, Anshuman Khandual wrote:
> This implements allocation isolation for CDM nodes in buddy allocator by
> discarding CDM memory zones all the time except in the cases where the gfp
> flag has got __GFP_THISNODE or the nodemask contains CDM nodes in cases
> where it is non NULL (explicit allocation request in the kernel or user
> process MPOL_BIND policy based requests).
> 
> Signed-off-by: Anshuman Khandual <khandual@linux.vnet.ibm.com>
> ---
>  mm/page_alloc.c | 16 ++++++++++++++++
>  1 file changed, 16 insertions(+)
> 
> diff --git a/mm/page_alloc.c b/mm/page_alloc.c
> index 84d61bb..392c24a 100644
> --- a/mm/page_alloc.c
> +++ b/mm/page_alloc.c
> @@ -64,6 +64,7 @@
>  #include <linux/page_owner.h>
>  #include <linux/kthread.h>
>  #include <linux/memcontrol.h>
> +#include <linux/node.h>
>  
>  #include <asm/sections.h>
>  #include <asm/tlbflush.h>
> @@ -2908,6 +2909,21 @@ get_page_from_freelist(gfp_t gfp_mask, unsigned int order, int alloc_flags,
>  		struct page *page;
>  		unsigned long mark;
>  
> +		/*
> +		 * CDM nodes get skipped if the requested gfp flag
> +		 * does not have __GFP_THISNODE set or the nodemask
> +		 * does not have any CDM nodes in case the nodemask
> +		 * is non NULL (explicit allocation requests from
> +		 * kernel or user process MPOL_BIND policy which has
> +		 * CDM nodes).
> +		 */
> +		if (is_cdm_node(zone->zone_pgdat->node_id)) {
> +			if (!(gfp_mask & __GFP_THISNODE)) {
> +				if (!ac->nodemask)
> +					continue;
> +			}
> +		}

With the current cpuset implementation, this will have a subtle corner
case when allocating from a cpuset that allows the cdm node, and there
is no (task or vma) mempolicy applied for the allocation. In the fast
path (__alloc_pages_nodemask()) we'll set ac->nodemask to
current->mems_allowed, so your code will wrongly assume that this
ac->nodemask is a policy that allows the CDM node. Probably not what you
want?

This might change if we decide to fix the cpuset vs mempolicy issues [1]
so your input on that topic with your recent experience with all the
alternative CDM isolation implementations would be useful. Thanks.

[1] http://www.spinics.net/lists/linux-mm/msg121760.html

>  		if (cpusets_enabled() &&
>  			(alloc_flags & ALLOC_CPUSET) &&
>  			!__cpuset_zone_allowed(zone, gfp_mask))
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f175.google.com (mail-wi0-f175.google.com [209.85.212.175])
	by kanga.kvack.org (Postfix) with ESMTP id 282316B0038
	for <linux-mm@kvack.org>; Thu, 20 Aug 2015 10:14:39 -0400 (EDT)
Received: by wijp15 with SMTP id p15so17434827wij.0
        for <linux-mm@kvack.org>; Thu, 20 Aug 2015 07:14:38 -0700 (PDT)
Received: from mail-wi0-f169.google.com (mail-wi0-f169.google.com. [209.85.212.169])
        by mx.google.com with ESMTPS id i1si9339889wij.108.2015.08.20.07.14.36
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 20 Aug 2015 07:14:37 -0700 (PDT)
Received: by wijp15 with SMTP id p15so17434044wij.0
        for <linux-mm@kvack.org>; Thu, 20 Aug 2015 07:14:36 -0700 (PDT)
Date: Thu, 20 Aug 2015 16:14:35 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH 2/3] mm: unify checks in alloc_pages_node() and
 __alloc_pages_node()
Message-ID: <20150820141434.GD4632@dhcp22.suse.cz>
References: <1440071002-19085-1-git-send-email-vbabka@suse.cz>
 <1440071002-19085-2-git-send-email-vbabka@suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1440071002-19085-2-git-send-email-vbabka@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Mel Gorman <mgorman@suse.de>, David Rientjes <rientjes@google.com>, Greg Thelen <gthelen@google.com>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Johannes Weiner <hannes@cmpxchg.org>, linux-ia64@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, cbe-oss-dev@lists.ozlabs.org, kvm@vger.kernel.org

On Thu 20-08-15 13:43:21, Vlastimil Babka wrote:
> Perform the same debug checks in alloc_pages_node() as are done in
> __alloc_pages_node(), by making the former function a wrapper of the latter
> one.
> 
> In addition to better diagnostics in DEBUG_VM builds for situations which
> have been already fatal (e.g. out-of-bounds node id), there are two visible
> changes for potential existing buggy callers of alloc_pages_node():
> 
> - calling alloc_pages_node() with any negative nid (e.g. due to arithmetic
>   overflow) was treated as passing NUMA_NO_NODE and fallback to local node was
>   applied. This will now be fatal.

OK, this is sensible

> - calling alloc_pages_node() with an offline node will now be checked for
>   DEBUG_VM builds. Since it's not fatal if the node has been previously online,
>   and this patch may expose some existing buggy callers, change the VM_BUG_ON
>   in __alloc_pages_node() to VM_WARN_ON.

Yes, bugging on just because we race with memory hotplug or use
stale node number is not appropriate because the fallback is
straightforward. A warning should help to identify and fix those place.

> 
> Signed-off-by: Vlastimil Babka <vbabka@suse.cz>
> Acked-by: David Rientjes <rientjes@google.com>
> Acked-by: Johannes Weiner <hannes@cmpxchg.org>
> Acked-by: Christoph Lameter <cl@linux.com>
> ---
>  include/linux/gfp.h | 10 +++++-----
>  1 file changed, 5 insertions(+), 5 deletions(-)
> 
> diff --git a/include/linux/gfp.h b/include/linux/gfp.h
> index d2c142b..4a12cae2 100644
> --- a/include/linux/gfp.h
> +++ b/include/linux/gfp.h
> @@ -310,23 +310,23 @@ __alloc_pages(gfp_t gfp_mask, unsigned int order,
>  static inline struct page *
>  __alloc_pages_node(int nid, gfp_t gfp_mask, unsigned int order)
>  {
> -	VM_BUG_ON(nid < 0 || nid >= MAX_NUMNODES || !node_online(nid));
> +	VM_BUG_ON(nid < 0 || nid >= MAX_NUMNODES);
> +	VM_WARN_ON(!node_online(nid));
>  
>  	return __alloc_pages(gfp_mask, order, node_zonelist(nid, gfp_mask));
>  }
>  
>  /*
>   * Allocate pages, preferring the node given as nid. When nid == NUMA_NO_NODE,
> - * prefer the current CPU's node.
> + * prefer the current CPU's node. Otherwise node must be valid and online.
>   */
>  static inline struct page *alloc_pages_node(int nid, gfp_t gfp_mask,
>  						unsigned int order)
>  {
> -	/* Unknown node is current node */
> -	if (nid < 0)
> +	if (nid == NUMA_NO_NODE)
>  		nid = numa_node_id();
>  
> -	return __alloc_pages(gfp_mask, order, node_zonelist(nid, gfp_mask));
> +	return __alloc_pages_node(nid, gfp_mask, order);
>  }
>  
>  #ifdef CONFIG_NUMA
> -- 
> 2.5.0
> 
> --
> To unsubscribe from this list: send the line "unsubscribe linux-kernel" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> Please read the FAQ at  http://www.tux.org/lkml/

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

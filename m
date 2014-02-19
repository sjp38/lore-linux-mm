Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qg0-f48.google.com (mail-qg0-f48.google.com [209.85.192.48])
	by kanga.kvack.org (Postfix) with ESMTP id 025E86B0035
	for <linux-mm@kvack.org>; Wed, 19 Feb 2014 18:32:47 -0500 (EST)
Received: by mail-qg0-f48.google.com with SMTP id a108so2258771qge.7
        for <linux-mm@kvack.org>; Wed, 19 Feb 2014 15:32:47 -0800 (PST)
Received: from e9.ny.us.ibm.com (e9.ny.us.ibm.com. [32.97.182.139])
        by mx.google.com with ESMTPS id a3si1503833qam.26.2014.02.19.15.32.47
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Wed, 19 Feb 2014 15:32:47 -0800 (PST)
Received: from /spool/local
	by e9.ny.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <nacc@linux.vnet.ibm.com>;
	Wed, 19 Feb 2014 18:32:46 -0500
Received: from b01cxnp23033.gho.pok.ibm.com (b01cxnp23033.gho.pok.ibm.com [9.57.198.28])
	by d01dlp03.pok.ibm.com (Postfix) with ESMTP id 9D9B6C90042
	for <linux-mm@kvack.org>; Wed, 19 Feb 2014 18:32:40 -0500 (EST)
Received: from d01av02.pok.ibm.com (d01av02.pok.ibm.com [9.56.224.216])
	by b01cxnp23033.gho.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id s1JNWhrU8389074
	for <linux-mm@kvack.org>; Wed, 19 Feb 2014 23:32:43 GMT
Received: from d01av02.pok.ibm.com (localhost [127.0.0.1])
	by d01av02.pok.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id s1JNWh9n004875
	for <linux-mm@kvack.org>; Wed, 19 Feb 2014 18:32:43 -0500
Date: Wed, 19 Feb 2014 15:32:37 -0800
From: Nishanth Aravamudan <nacc@linux.vnet.ibm.com>
Subject: Re: [PATCH 1/3] mm: return NUMA_NO_NODE in local_memory_node if
 zonelists are not setup
Message-ID: <20140219233237.GF413@linux.vnet.ibm.com>
References: <20140219231641.GA413@linux.vnet.ibm.com>
 <20140219231714.GB413@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20140219231714.GB413@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.cz>, Mel Gorman <mgorman@suse.de>, linux-mm@kvack.org, Christoph Lameter <cl@linux.com>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Ben Herrenschmidt <benh@kernel.crashing.org>, Anton Blanchard <anton@samba.org>, linuxppc-dev@lists.ozlabs.org, akpm@linux-foundation.org

[ Grr, sorry for not including you originally Andrew, if this ends up
being ok with others, it will probably need to go through your tree. ]

On 19.02.2014 [15:17:14 -0800], Nishanth Aravamudan wrote:
> We can call local_memory_node() before the zonelists are setup. In that
> case, first_zones_zonelist() will not set zone and the reference to
> zone->node will Oops. Catch this case, and, since we presumably running
> very early, just return that any node will do.
> 
> Signed-off-by: Nishanth Aravamudan <nacc@linux.vnet.ibm.com>
> Cc: Andrew Morton <akpm@linux-foundation.org>
> Cc: Michal Hocko <mhocko@suse.cz>
> Cc: Mel Gorman <mgorman@suse.de>
> Cc: linux-mm@kvack.org
> Cc: linux-kernel@vger.kernel.org
> Cc: Christoph Lameter <cl@linux.com>
> Cc: David Rientjes <rientjes@google.com>
> Cc: Joonsoo Kim <iamjoonsoo.kim@lge.com>
> Cc: Ben Herrenschmidt <benh@kernel.crashing.org>
> Cc: Anton Blanchard <anton@samba.org>
> 
> diff --git a/mm/page_alloc.c b/mm/page_alloc.c
> index e3758a0..5de4337 100644
> --- a/mm/page_alloc.c
> +++ b/mm/page_alloc.c
> @@ -3650,6 +3650,8 @@ int local_memory_node(int node)
>  				   gfp_zone(GFP_KERNEL),
>  				   NULL,
>  				   &zone);
> +	if (!zone)
> +		return NUMA_NO_NODE;
>  	return zone->node;
>  }
>  #endif

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

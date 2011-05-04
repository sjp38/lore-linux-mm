Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with ESMTP id A13FA6B0011
	for <linux-mm@kvack.org>; Wed,  4 May 2011 15:17:31 -0400 (EDT)
Received: from wpaz37.hot.corp.google.com (wpaz37.hot.corp.google.com [172.24.198.101])
	by smtp-out.google.com with ESMTP id p44JHPu8020012
	for <linux-mm@kvack.org>; Wed, 4 May 2011 12:17:26 -0700
Received: from pwj5 (pwj5.prod.google.com [10.241.219.69])
	by wpaz37.hot.corp.google.com with ESMTP id p44JHNof009230
	(version=TLSv1/SSLv3 cipher=RC4-SHA bits=128 verify=NOT)
	for <linux-mm@kvack.org>; Wed, 4 May 2011 12:17:24 -0700
Received: by pwj5 with SMTP id 5so827761pwj.12
        for <linux-mm@kvack.org>; Wed, 04 May 2011 12:17:23 -0700 (PDT)
Date: Wed, 4 May 2011 12:17:22 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH] Allocate memory cgroup structures in local nodes
In-Reply-To: <1304533058-18228-1-git-send-email-andi@firstfloor.org>
Message-ID: <alpine.DEB.2.00.1105041213310.22426@chino.kir.corp.google.com>
References: <1304533058-18228-1-git-send-email-andi@firstfloor.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andi Kleen <andi@firstfloor.org>
Cc: akpm@linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Andi Kleen <ak@linux.intel.com>, Michal Hocko <mhocko@suse.cz>, Dave Hansen <dave@linux.vnet.ibm.com>, Balbir Singh <balbir@in.ibm.com>, Johannes Weiner <hannes@cmpxchg.org>

On Wed, 4 May 2011, Andi Kleen wrote:

> From: Andi Kleen <ak@linux.intel.com>
> 
> [Andrew: since this is a regression and a very simple fix
> could you still consider it for .39? Thanks]
> 

Before that's considered, the order of the arguments to 
alloc_pages_exact_node() needs to be fixed.

> dde79e005a769 added a regression that the memory cgroup data structures
> all end up in node 0 because the first attempt at allocating them
> would not pass in a node hint. Since the initialization runs on CPU #0
> it would all end up node 0. This is a problem on large memory systems,
> where node 0 would lose a lot of memory.
> 
> Change the alloc_pages_exact to alloc_pages_exact_node. This will
> still fall back to other nodes if not enough memory is available.
> 

The vmalloc_node() calls ensure that the nid is actually set in 
N_HIGH_MEMORY and fails otherwise (we don't fallback to using vmalloc()), 
so it looks like the failures for alloc_pages_exact_node() and 
vmalloc_node() would be different?  Why do we want to fallback for one and 
not the other?

> [RED-PEN: right now it would fall back first before trying
> vmalloc_node. Probably not the best strategy ... But I left it like
> that for now.]
> 
> Reported-by: Doug Nelson
> CC: Michal Hocko <mhocko@suse.cz>
> Cc: Dave Hansen <dave@linux.vnet.ibm.com>
> Cc: Balbir Singh <balbir@in.ibm.com>
> Cc: Johannes Weiner <hannes@cmpxchg.org>
> Signed-off-by: Andi Kleen <ak@linux.intel.com>
> ---
>  mm/page_cgroup.c |    2 +-
>  1 files changed, 1 insertions(+), 1 deletions(-)
> 
> diff --git a/mm/page_cgroup.c b/mm/page_cgroup.c
> index 9905501..1f4e20f 100644
> --- a/mm/page_cgroup.c
> +++ b/mm/page_cgroup.c
> @@ -134,7 +134,7 @@ static void *__init_refok alloc_page_cgroup(size_t size, int nid)
>  {
>  	void *addr = NULL;
>  
> -	addr = alloc_pages_exact(size, GFP_KERNEL | __GFP_NOWARN);
> +	addr = alloc_pages_exact_node(nid, size, GFP_KERNEL | __GFP_NOWARN);
>  	if (addr)
>  		return addr;
>  

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

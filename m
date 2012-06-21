Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx205.postini.com [74.125.245.205])
	by kanga.kvack.org (Postfix) with SMTP id 12E926B004D
	for <linux-mm@kvack.org>; Wed, 20 Jun 2012 21:19:42 -0400 (EDT)
Received: by pbbrp2 with SMTP id rp2so1752067pbb.14
        for <linux-mm@kvack.org>; Wed, 20 Jun 2012 18:19:41 -0700 (PDT)
Date: Wed, 20 Jun 2012 18:19:38 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH] mm/buddy: get the allownodes for dump at once
In-Reply-To: <1339662910-25774-1-git-send-email-shangw@linux.vnet.ibm.com>
Message-ID: <alpine.DEB.2.00.1206201815100.3702@chino.kir.corp.google.com>
References: <1339662910-25774-1-git-send-email-shangw@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Gavin Shan <shangw@linux.vnet.ibm.com>
Cc: linux-mm@kvack.org, minchan@kernel.org, mgorman@suse.de, akpm@linux-foundation.org

On Thu, 14 Jun 2012, Gavin Shan wrote:

> diff --git a/mm/page_alloc.c b/mm/page_alloc.c
> index 7892f84..211004e 100644
> --- a/mm/page_alloc.c
> +++ b/mm/page_alloc.c
> @@ -2765,11 +2765,19 @@ out:
>   */
>  void show_free_areas(unsigned int filter)
>  {
> -	int cpu;
> +	int nid, cpu;
> +	nodemask_t allownodes;
>  	struct zone *zone;
>  

I saw this added to the -mm tree today, but it has to be nacked with 
apologies for not seeing the patch on the mailing list earlier.

show_free_areas() is called by the oom killer, so we know two things: it 
can be called potentially very deep in the callchain and current is out of 
memory.  Both are killers for this patch since you're allocating 
nodemask_t on the stack here which could cause an overflow and because you 
can't easily fix that case with NODEMASK_ALLOC() since it allocates slab 
with GFP_KERNEL when we we're oom, which would simply suppress vital 
meminfo from being shown.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

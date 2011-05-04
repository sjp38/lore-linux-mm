Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id C579A6B0011
	for <linux-mm@kvack.org>; Wed,  4 May 2011 17:39:01 -0400 (EDT)
Date: Wed, 4 May 2011 23:38:50 +0200
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [PATCH] Allocate memory cgroup structures in local nodes v2
Message-ID: <20110504213850.GA16685@cmpxchg.org>
References: <1304540783-8247-1-git-send-email-andi@firstfloor.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1304540783-8247-1-git-send-email-andi@firstfloor.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andi Kleen <andi@firstfloor.org>
Cc: akpm@linux-foundation.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Andi Kleen <ak@linux.intel.com>, rientjes@google.com, Michal Hocko <mhocko@suse.cz>, Dave Hansen <dave@linux.vnet.ibm.com>, Balbir Singh <balbir@in.ibm.com>

On Wed, May 04, 2011 at 01:26:23PM -0700, Andi Kleen wrote:
> diff --git a/mm/page_cgroup.c b/mm/page_cgroup.c
> index 9905501..a362215 100644
> --- a/mm/page_cgroup.c
> +++ b/mm/page_cgroup.c
> @@ -134,7 +134,7 @@ static void *__init_refok alloc_page_cgroup(size_t size, int nid)
>  {
>  	void *addr = NULL;
>  
> -	addr = alloc_pages_exact(size, GFP_KERNEL | __GFP_NOWARN);
> +	addr = alloc_pages_exact_node(nid, GFP_KERNEL | __GFP_NOWARN, size);

alloc_pages_exact_node is not the 'specify node as well'-version of
alloc_pages_exact, it refers to 'exact node'.  Thus the
free_pages_exact call is no longer the right counter-part.

alloc_pages_exact_node takes an order, not a size argument.

alloc_pages_exact_node returns a pointer to the struct page, not to
the allocated memory, like all other alloc_pages* functions with the
exception of alloc_pages_exact.

I don't think any of those mistakes even triggers a compiler warning.
Wow.  This API is so thoroughly fscked beyond belief that I think the
only way to top this is to have one of the functions invert the bits
of its return value depending on the parity of the uptime counter.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

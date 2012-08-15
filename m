Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx152.postini.com [74.125.245.152])
	by kanga.kvack.org (Postfix) with SMTP id 68F8E6B006E
	for <linux-mm@kvack.org>; Wed, 15 Aug 2012 05:24:10 -0400 (EDT)
Date: Wed, 15 Aug 2012 11:24:05 +0200
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [PATCH v2 07/11] mm: Allocate kernel pages to the right memcg
Message-ID: <20120815092404.GA23985@dhcp22.suse.cz>
References: <1344517279-30646-1-git-send-email-glommer@parallels.com>
 <1344517279-30646-8-git-send-email-glommer@parallels.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1344517279-30646-8-git-send-email-glommer@parallels.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Glauber Costa <glommer@parallels.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, cgroups@vger.kernel.org, devel@openvz.org, Johannes Weiner <hannes@cmpxchg.org>, Andrew Morton <akpm@linux-foundation.org>, kamezawa.hiroyu@jp.fujitsu.com, Christoph Lameter <cl@linux.com>, David Rientjes <rientjes@google.com>, Pekka Enberg <penberg@kernel.org>, Pekka Enberg <penberg@cs.helsinki.fi>, Suleiman Souhlal <suleiman@google.com>

On Thu 09-08-12 17:01:15, Glauber Costa wrote:
[...]
> diff --git a/mm/page_alloc.c b/mm/page_alloc.c
> index b956cec..da341dc 100644
> --- a/mm/page_alloc.c
> +++ b/mm/page_alloc.c
> @@ -2532,6 +2532,7 @@ __alloc_pages_nodemask(gfp_t gfp_mask, unsigned int order,
>  	struct page *page = NULL;
>  	int migratetype = allocflags_to_migratetype(gfp_mask);
>  	unsigned int cpuset_mems_cookie;
> +	void *handle = NULL;
>  
>  	gfp_mask &= gfp_allowed_mask;
>  
> @@ -2543,6 +2544,13 @@ __alloc_pages_nodemask(gfp_t gfp_mask, unsigned int order,
>  		return NULL;
>  
>  	/*
> +	 * Will only have any effect when __GFP_KMEMCG is set.
> +	 * This is verified in the (always inline) callee
> +	 */
> +	if (!memcg_kmem_new_page(gfp_mask, &handle, order))
> +		return NULL;

When the previous patch introduced this function I thought the handle
obfuscantion is to prevent from spreading struct mem_cgroup inside the
page allocator but memcg_kmem_commit_page uses the type directly. So why
that obfuscation? Even handle as a name sounds unnecessarily confusing.
I would go with struct mem_cgroup **memcgp or even return the pointer on
success or NULL otherwise.

[...]
> +EXPORT_SYMBOL(__free_accounted_pages);

Why exported?

Btw. this is called from call_rcu context but it itself calls call_rcu
down the chain in mem_cgroup_put. Is it safe?

[...]
> +EXPORT_SYMBOL(free_accounted_pages);

here again
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

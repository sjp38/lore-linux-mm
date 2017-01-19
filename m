Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wj0-f197.google.com (mail-wj0-f197.google.com [209.85.210.197])
	by kanga.kvack.org (Postfix) with ESMTP id 2840E6B0069
	for <linux-mm@kvack.org>; Thu, 19 Jan 2017 02:29:49 -0500 (EST)
Received: by mail-wj0-f197.google.com with SMTP id ez4so6756607wjd.2
        for <linux-mm@kvack.org>; Wed, 18 Jan 2017 23:29:49 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id v6si14310633wmv.50.2017.01.18.23.29.47
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 18 Jan 2017 23:29:47 -0800 (PST)
Subject: Re: [patch -mm] mm, page_alloc: warn_alloc nodemask is NULL when
 cpusets are disabled
References: <alpine.DEB.2.10.1701181347320.142399@chino.kir.corp.google.com>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <279f10c2-3eaa-c641-094f-3070db67d84f@suse.cz>
Date: Thu, 19 Jan 2017 08:29:45 +0100
MIME-Version: 1.0
In-Reply-To: <alpine.DEB.2.10.1701181347320.142399@chino.kir.corp.google.com>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>, Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@kernel.org>
Cc: Johannes Weiner <hannes@cmpxchg.org>, Mel Gorman <mgorman@suse.de>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>

On 01/18/2017 10:51 PM, David Rientjes wrote:
> The patch "mm, page_alloc: warn_alloc print nodemask" implicitly sets the 
> allocation nodemask to cpuset_current_mems_allowed when there is no 
> effective mempolicy.  cpuset_current_mems_allowed is only effective when 
> cpusets are enabled, which is also printed by warn_alloc(), so setting 
> the nodemask to cpuset_current_mems_allowed is redundant and prevents 
> debugging issues where ac->nodemask is not set properly in the page 
> allocator.
> 
> This provides better debugging output since 
> cpuset_print_current_mems_allowed() is already provided.
> 
> Signed-off-by: David Rientjes <rientjes@google.com>

Yes, with my current cpuset vs mempolicy debugging experience, this is
more useful (except how both nodemask and mems_allowed can change under
us, so what we print here is not necessarily the same that what
get_page_from_freelist() has seen, but that's another thing...).

But I would suggest you change the oom killer's dump_header() the same
way than warn_alloc().

Thanks,
Vlastimil

> ---
>  mm/page_alloc.c | 10 +++++++---
>  1 file changed, 7 insertions(+), 3 deletions(-)
> 
> diff --git a/mm/page_alloc.c b/mm/page_alloc.c
> --- a/mm/page_alloc.c
> +++ b/mm/page_alloc.c
> @@ -3037,7 +3037,6 @@ void warn_alloc(gfp_t gfp_mask, nodemask_t *nodemask, const char *fmt, ...)
>  	va_list args;
>  	static DEFINE_RATELIMIT_STATE(nopage_rs, DEFAULT_RATELIMIT_INTERVAL,
>  				      DEFAULT_RATELIMIT_BURST);
> -	nodemask_t *nm = (nodemask) ? nodemask : &cpuset_current_mems_allowed;
>  
>  	if ((gfp_mask & __GFP_NOWARN) || !__ratelimit(&nopage_rs) ||
>  	    debug_guardpage_minorder() > 0)
> @@ -3051,11 +3050,16 @@ void warn_alloc(gfp_t gfp_mask, nodemask_t *nodemask, const char *fmt, ...)
>  	pr_cont("%pV", &vaf);
>  	va_end(args);
>  
> -	pr_cont(", mode:%#x(%pGg), nodemask=%*pbl\n", gfp_mask, &gfp_mask, nodemask_pr_args(nm));
> +	pr_cont(", mode:%#x(%pGg), nodemask=", gfp_mask, &gfp_mask);
> +	if (nodemask)
> +		pr_cont("%*pbl\n", nodemask_pr_args(nodemask));
> +	else
> +		pr_cont("(null)\n");
> +
>  	cpuset_print_current_mems_allowed();
>  
>  	dump_stack();
> -	warn_alloc_show_mem(gfp_mask, nm);
> +	warn_alloc_show_mem(gfp_mask, nodemask);
>  }
>  
>  static inline struct page *
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

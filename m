Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f199.google.com (mail-io0-f199.google.com [209.85.223.199])
	by kanga.kvack.org (Postfix) with ESMTP id 1479228024B
	for <linux-mm@kvack.org>; Fri, 23 Sep 2016 10:36:32 -0400 (EDT)
Received: by mail-io0-f199.google.com with SMTP id 92so61939527iom.3
        for <linux-mm@kvack.org>; Fri, 23 Sep 2016 07:36:32 -0700 (PDT)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [2001:e42:101:1:202:181:97:72])
        by mx.google.com with ESMTPS id r124si4717795itg.109.2016.09.23.07.36.31
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Fri, 23 Sep 2016 07:36:31 -0700 (PDT)
Subject: Re: [PATCH] mm: warn about allocations which stall for too long
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
References: <20160923081555.14645-1-mhocko@kernel.org>
In-Reply-To: <20160923081555.14645-1-mhocko@kernel.org>
Message-Id: <201609232336.FIH57364.FOVHtMFQLFSJOO@I-love.SAKURA.ne.jp>
Date: Fri, 23 Sep 2016 23:36:22 +0900
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: mhocko@kernel.org, linux-mm@kvack.org
Cc: akpm@linux-foundation.org, hannes@cmpxchg.org, mgorman@suse.de, linux-kernel@vger.kernel.org, mhocko@suse.com

Michal Hocko wrote:
> @@ -3659,6 +3661,15 @@ __alloc_pages_slowpath(gfp_t gfp_mask, unsigned int order,
>  	else
>  		no_progress_loops++;
>  
> +	/* Make sure we know about allocations which stall for too long */
> +	if (!(gfp_mask & __GFP_NOWARN) && time_after(jiffies, alloc_start + stall_timeout)) {

Should we check !__GFP_NOWARN ? I think __GFP_NOWARN is likely used with
__GFP_NORETRY, and __GFP_NORETRY is already checked by now.

I think printing warning regardless of __GFP_NOWARN is better because
this check is similar to hungtask warning.

> +		pr_warn("%s: page alloction stalls for %ums: order:%u mode:%#x(%pGg)\n",
> +				current->comm, jiffies_to_msecs(jiffies-alloc_start),
> +				order, gfp_mask, &gfp_mask);
> +		stall_timeout += 10 * HZ;
> +		dump_stack();

Can we move this pr_warn() + dump_stack() to a separate function like

static void __warn_memalloc_stall(unsigned int order, gfp_t gfp_mask, unsigned long alloc_start)
{
	pr_warn("%s: page alloction stalls for %ums: order:%u mode:%#x(%pGg)\n",
		current->comm, jiffies_to_msecs(jiffies-alloc_start),
		order, gfp_mask, &gfp_mask);
	dump_stack();
}

in order to allow SystemTap scripts to perform additional actions by name (e.g.

# stap -g -e 'probe kernel.function("__warn_memalloc_stall").return { panic(); }

) rather than by line number, and surround __warn_memalloc_stall() call with
mutex in order to serialize warning messages because it is possible that
multiple allocation requests are stalling?

> +	}
> +
>  	if (should_reclaim_retry(gfp_mask, order, ac, alloc_flags,
>  				 did_some_progress > 0, no_progress_loops))
>  		goto retry;
> -- 
> 2.9.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

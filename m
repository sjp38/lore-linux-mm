Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f198.google.com (mail-wr0-f198.google.com [209.85.128.198])
	by kanga.kvack.org (Postfix) with ESMTP id C54B16B04B6
	for <linux-mm@kvack.org>; Mon, 10 Jul 2017 12:06:17 -0400 (EDT)
Received: by mail-wr0-f198.google.com with SMTP id r103so25528561wrb.0
        for <linux-mm@kvack.org>; Mon, 10 Jul 2017 09:06:17 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id w3si6856660wmb.191.2017.07.10.09.06.16
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Mon, 10 Jul 2017 09:06:16 -0700 (PDT)
Subject: Re: [RFC v1 1/2] mm/page_alloc: Prevent OOM killer from triggering if
 requested
References: <20170709224911.13030-1-joelaf@google.com>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <0e5503df-1b6b-67d3-1117-4da1eb21a862@suse.cz>
Date: Mon, 10 Jul 2017 18:05:27 +0200
MIME-Version: 1.0
In-Reply-To: <20170709224911.13030-1-joelaf@google.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Joel Fernandes <joelaf@google.com>, linux-kernel@vger.kernel.org
Cc: Alexander Duyck <alexander.h.duyck@intel.com>, Mel Gorman <mgorman@suse.de>, Hao Lee <haolee.swjtu@gmail.com>, Vladimir Davydov <vdavydov.dev@gmail.com>, Johannes Weiner <hannes@cmpxchg.org>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Steven Rostedt <rostedt@goodmis.org>, linux-mm@kvack.org, Michal Hocko <mhocko@kernel.org>

[+CC Michal Hocko]

On 07/10/2017 12:49 AM, Joel Fernandes wrote:
> Certain allocation paths such as the ftrace ring buffer allocator
> want to try hard to allocate but not trigger OOM killer and de-stabilize
> the system. Currently the ring buffer uses __GFP_NO_RETRY to prevent
> the OOM killer from triggering situation however this has an issue.
> Its possible the system is in a state where:
> a) retrying can make the allocation succeed.
> b) there's plenty of memory available in the page cache to satisfy
>    the request and just retrying is needed. Even though direct reclaim
>    makes progress, it still couldn't find free page from the free list.
> 
> This patch adds a new GFP flag (__GFP_DONTOOM) to handle the situation
> where we want the retry behavior but still want to bail out before going
> to OOM killer if retries couldn't satisfy the allocation.

Michal recently turned __GFP_REPEAT into __GFP_RETRY_MAYFAIL [1][2]
which I think does exactly what you want. Try hard as long as
reclaim/compaction makes progress, but fail the allocation instead of
triggering OOM killer. Can you check it out? It's in mmotm/linux-next.

[1]
http://www.ozlabs.org/~akpm/mmotm/broken-out/mm-tree-wide-replace-__gfp_repeat-by-__gfp_retry_mayfail-with-more-useful-semantic.patch
[2] http://lkml.kernel.org/r/20170623085345.11304-3-mhocko@kernel.org

> Cc: Alexander Duyck <alexander.h.duyck@intel.com>
> Cc: Mel Gorman <mgorman@suse.de>
> Cc: Hao Lee <haolee.swjtu@gmail.com>
> Cc: Vladimir Davydov <vdavydov.dev@gmail.com>
> Cc: Johannes Weiner <hannes@cmpxchg.org>
> Cc: Joonsoo Kim <iamjoonsoo.kim@lge.com>
> Cc: Steven Rostedt <rostedt@goodmis.org>
> Cc: linux-mm@kvack.org
> Cc: linux-kernel@vger.kernel.org
> Signed-off-by: Joel Fernandes <joelaf@google.com>
> ---
>  include/linux/gfp.h | 6 +++++-
>  mm/page_alloc.c     | 7 +++++++
>  2 files changed, 12 insertions(+), 1 deletion(-)
> 
> diff --git a/include/linux/gfp.h b/include/linux/gfp.h
> index 4c6656f1fee7..beaabd110008 100644
> --- a/include/linux/gfp.h
> +++ b/include/linux/gfp.h
> @@ -40,6 +40,7 @@ struct vm_area_struct;
>  #define ___GFP_DIRECT_RECLAIM	0x400000u
>  #define ___GFP_WRITE		0x800000u
>  #define ___GFP_KSWAPD_RECLAIM	0x1000000u
> +#define ___GFP_DONTOOM		0x2000000u
>  #ifdef CONFIG_LOCKDEP
>  #define ___GFP_NOLOCKDEP	0x2000000u
>  #else
> @@ -149,6 +150,8 @@ struct vm_area_struct;
>   *   return NULL when direct reclaim and memory compaction have failed to allow
>   *   the allocation to succeed.  The OOM killer is not called with the current
>   *   implementation.
> + *
> + * __GFP_DONTOOM: The VM implementation must not OOM if retries have exhausted.
>   */
>  #define __GFP_IO	((__force gfp_t)___GFP_IO)
>  #define __GFP_FS	((__force gfp_t)___GFP_FS)
> @@ -158,6 +161,7 @@ struct vm_area_struct;
>  #define __GFP_REPEAT	((__force gfp_t)___GFP_REPEAT)
>  #define __GFP_NOFAIL	((__force gfp_t)___GFP_NOFAIL)
>  #define __GFP_NORETRY	((__force gfp_t)___GFP_NORETRY)
> +#define __GFP_DONTOOM	((__force gfp_t)___GFP_DONTOOM)
>  
>  /*
>   * Action modifiers
> @@ -188,7 +192,7 @@ struct vm_area_struct;
>  #define __GFP_NOLOCKDEP ((__force gfp_t)___GFP_NOLOCKDEP)
>  
>  /* Room for N __GFP_FOO bits */
> -#define __GFP_BITS_SHIFT (25 + IS_ENABLED(CONFIG_LOCKDEP))
> +#define __GFP_BITS_SHIFT (26 + IS_ENABLED(CONFIG_LOCKDEP))
>  #define __GFP_BITS_MASK ((__force gfp_t)((1 << __GFP_BITS_SHIFT) - 1))
>  
>  /*
> diff --git a/mm/page_alloc.c b/mm/page_alloc.c
> index bd65b60939b6..970a5c380bb6 100644
> --- a/mm/page_alloc.c
> +++ b/mm/page_alloc.c
> @@ -3908,6 +3908,13 @@ __alloc_pages_slowpath(gfp_t gfp_mask, unsigned int order,
>  	if (check_retry_cpuset(cpuset_mems_cookie, ac))
>  		goto retry_cpuset;
>  
> +	/*
> +	 * Its possible that retries failed but we still don't want OOM
> +	 * killer to trigger and can just try again later.
> +	 */
> +	if (gfp_mask & __GFP_DONTOOM)
> +		goto nopage;
> +
>  	/* Reclaim has failed us, start killing things */
>  	page = __alloc_pages_may_oom(gfp_mask, order, ac, &did_some_progress);
>  	if (page)
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

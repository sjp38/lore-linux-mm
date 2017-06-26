Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f198.google.com (mail-wr0-f198.google.com [209.85.128.198])
	by kanga.kvack.org (Postfix) with ESMTP id 400856B02C3
	for <linux-mm@kvack.org>; Mon, 26 Jun 2017 07:53:16 -0400 (EDT)
Received: by mail-wr0-f198.google.com with SMTP id x23so28528318wrb.6
        for <linux-mm@kvack.org>; Mon, 26 Jun 2017 04:53:16 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id k90si9797487wmc.87.2017.06.26.04.53.14
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Mon, 26 Jun 2017 04:53:14 -0700 (PDT)
Subject: Re: [PATCH 2/6] mm, tree wide: replace __GFP_REPEAT by
 __GFP_RETRY_MAYFAIL with more useful semantic
References: <20170623085345.11304-1-mhocko@kernel.org>
 <20170623085345.11304-3-mhocko@kernel.org>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <ada868d0-077a-f3a9-7a0e-78a594834999@suse.cz>
Date: Mon, 26 Jun 2017 13:53:13 +0200
MIME-Version: 1.0
In-Reply-To: <20170623085345.11304-3-mhocko@kernel.org>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>, Andrew Morton <akpm@linux-foundation.org>
Cc: Johannes Weiner <hannes@cmpxchg.org>, Mel Gorman <mgorman@suse.de>, NeilBrown <neilb@suse.com>, LKML <linux-kernel@vger.kernel.org>, linux-mm@kvack.org, Michal Hocko <mhocko@suse.com>

On 06/23/2017 10:53 AM, Michal Hocko wrote:
...

> diff --git a/include/linux/gfp.h b/include/linux/gfp.h
> index 4c6656f1fee7..6be1f836b69e 100644
> --- a/include/linux/gfp.h
> +++ b/include/linux/gfp.h
> @@ -25,7 +25,7 @@ struct vm_area_struct;
>  #define ___GFP_FS		0x80u
>  #define ___GFP_COLD		0x100u
>  #define ___GFP_NOWARN		0x200u
> -#define ___GFP_REPEAT		0x400u
> +#define ___GFP_RETRY_MAYFAIL		0x400u
>  #define ___GFP_NOFAIL		0x800u
>  #define ___GFP_NORETRY		0x1000u
>  #define ___GFP_MEMALLOC		0x2000u
> @@ -136,26 +136,55 @@ struct vm_area_struct;
>   *
>   * __GFP_RECLAIM is shorthand to allow/forbid both direct and kswapd reclaim.
>   *
> - * __GFP_REPEAT: Try hard to allocate the memory, but the allocation attempt
> - *   _might_ fail.  This depends upon the particular VM implementation.
> + * The default allocator behavior depends on the request size. We have a concept
> + * of so called costly allocations (with order > PAGE_ALLOC_COSTLY_ORDER).
> + * !costly allocations are too essential to fail so they are implicitly
> + * non-failing (with some exceptions like OOM victims might fail) by default while
> + * costly requests try to be not disruptive and back off even without invoking
> + * the OOM killer. The following three modifiers might be used to override some of
> + * these implicit rules
> + *
> + * __GFP_NORETRY: The VM implementation will try only very lightweight
> + *   memory direct reclaim to get some memory under memory pressure (thus
> + *   it can sleep). It will avoid disruptive actions like OOM killer. The
> + *   caller must handle the failure which is quite likely to happen under
> + *   heavy memory pressure. The flag is suitable when failure can easily be
> + *   handled at small cost, such as reduced throughput
> + *
> + * __GFP_RETRY_MAYFAIL: The VM implementation will retry memory reclaim
> + *   procedures that have previously failed if there is some indication
> + *   that progress has been made else where.  It can wait for other
> + *   tasks to attempt high level approaches to freeing memory such as
> + *   compaction (which removes fragmentation) and page-out.
> + *   There is still a definite limit to the number of retries, but it is
> + *   a larger limit than with __GFP_NORERY.

Also, __GFP_NORETRY ^ (for grep purposes).

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

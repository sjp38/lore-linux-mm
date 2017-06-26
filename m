Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f198.google.com (mail-wr0-f198.google.com [209.85.128.198])
	by kanga.kvack.org (Postfix) with ESMTP id BB0F56B0292
	for <linux-mm@kvack.org>; Mon, 26 Jun 2017 07:45:22 -0400 (EDT)
Received: by mail-wr0-f198.google.com with SMTP id z45so28459627wrb.13
        for <linux-mm@kvack.org>; Mon, 26 Jun 2017 04:45:22 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id e14si12262666wra.236.2017.06.26.04.45.20
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Mon, 26 Jun 2017 04:45:20 -0700 (PDT)
Subject: Re: [PATCH 2/6] mm, tree wide: replace __GFP_REPEAT by
 __GFP_RETRY_MAYFAIL with more useful semantic
References: <20170623085345.11304-1-mhocko@kernel.org>
 <20170623085345.11304-3-mhocko@kernel.org>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <db63b720-b7aa-1bd0-dde8-d324dfaa9c9b@suse.cz>
Date: Mon, 26 Jun 2017 13:45:19 +0200
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
> From: Michal Hocko <mhocko@suse.com>
> 
> __GFP_REPEAT was designed to allow retry-but-eventually-fail semantic to
> the page allocator. This has been true but only for allocations requests
> larger than PAGE_ALLOC_COSTLY_ORDER. It has been always ignored for
> smaller sizes. This is a bit unfortunate because there is no way to
> express the same semantic for those requests and they are considered too
> important to fail so they might end up looping in the page allocator for
> ever, similarly to GFP_NOFAIL requests.
> 
> Now that the whole tree has been cleaned up and accidental or misled
> usage of __GFP_REPEAT flag has been removed for !costly requests we can
> give the original flag a better name and more importantly a more useful
> semantic. Let's rename it to __GFP_RETRY_MAYFAIL which tells the user that
> the allocator would try really hard but there is no promise of a
> success. This will work independent of the order and overrides the
> default allocator behavior. Page allocator users have several levels of
> guarantee vs. cost options (take GFP_KERNEL as an example)
> - GFP_KERNEL & ~__GFP_RECLAIM - optimistic allocation without _any_
>   attempt to free memory at all. The most light weight mode which even
>   doesn't kick the background reclaim. Should be used carefully because
>   it might deplete the memory and the next user might hit the more
>   aggressive reclaim
> - GFP_KERNEL & ~__GFP_DIRECT_RECLAIM (or GFP_NOWAIT)- optimistic
>   allocation without any attempt to free memory from the current context
>   but can wake kswapd to reclaim memory if the zone is below the low
>   watermark. Can be used from either atomic contexts or when the request
>   is a performance optimization and there is another fallback for a slow
>   path.
> - (GFP_KERNEL|__GFP_HIGH) & ~__GFP_DIRECT_RECLAIM (aka GFP_ATOMIC) - non
>   sleeping allocation with an expensive fallback so it can access some
>   portion of memory reserves. Usually used from interrupt/bh context with
>   an expensive slow path fallback.
> - GFP_KERNEL - both background and direct reclaim are allowed and the
>   _default_ page allocator behavior is used. That means that !costly
>   allocation requests are basically nofail (unless the requesting task
>   is killed by the OOM killer)

Should we explicitly point out that failure must be handled? After lots
of talking about "too small to fail", people might get the wrong impression.

> and costly will fail early rather than
>   cause disruptive reclaim.
> - GFP_KERNEL | __GFP_NORETRY - overrides the default allocator behavior and
>   all allocation requests fail early rather than cause disruptive
>   reclaim (one round of reclaim in this implementation). The OOM killer
>   is not invoked.
> - GFP_KERNEL | __GFP_RETRY_MAYFAIL - overrides the default allocator behavior
>   and all allocation requests try really hard. The request will fail if the
>   reclaim cannot make any progress. The OOM killer won't be triggered.
> - GFP_KERNEL | __GFP_NOFAIL - overrides the default allocator behavior
>   and all allocation requests will loop endlessly until they
>   succeed. This might be really dangerous especially for larger orders.
> 
> Existing users of __GFP_REPEAT are changed to __GFP_RETRY_MAYFAIL because
> they already had their semantic. No new users are added.
> __alloc_pages_slowpath is changed to bail out for __GFP_RETRY_MAYFAIL if
> there is no progress and we have already passed the OOM point. This
> means that all the reclaim opportunities have been exhausted except the
> most disruptive one (the OOM killer) and a user defined fallback
> behavior is more sensible than keep retrying in the page allocator.
> 
> Changes since RFC
> - udpate documentation wording as per Neil Brown
> 
> Signed-off-by: Michal Hocko <mhocko@suse.com>

Acked-by: Vlastimil Babka <vbabka@suse.cz>

Some more minor comments below:

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

Seems like one tab too many, the end result is off:
(sigh, tabs are not only error prone, but also we make less money due to
them, I heard)

#define ___GFP_NOWARN           0x200u
#define ___GFP_RETRY_MAYFAIL            0x400u
#define ___GFP_NOFAIL           0x800u


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

Again, emphasize need for error handling?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

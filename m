Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f69.google.com (mail-lf0-f69.google.com [209.85.215.69])
	by kanga.kvack.org (Postfix) with ESMTP id B6FC16B0005
	for <linux-mm@kvack.org>; Thu, 12 May 2016 08:48:26 -0400 (EDT)
Received: by mail-lf0-f69.google.com with SMTP id m64so53413583lfd.1
        for <linux-mm@kvack.org>; Thu, 12 May 2016 05:48:26 -0700 (PDT)
Received: from mail-wm0-f67.google.com (mail-wm0-f67.google.com. [74.125.82.67])
        by mx.google.com with ESMTPS id b83si45505916wme.3.2016.05.12.05.48.25
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 12 May 2016 05:48:25 -0700 (PDT)
Received: by mail-wm0-f67.google.com with SMTP id e201so15923794wme.2
        for <linux-mm@kvack.org>; Thu, 12 May 2016 05:48:25 -0700 (PDT)
Date: Thu, 12 May 2016 14:48:24 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [RFC 03/13] mm, page_alloc: don't retry initial attempt in
 slowpath
Message-ID: <20160512124823.GI4200@dhcp22.suse.cz>
References: <1462865763-22084-1-git-send-email-vbabka@suse.cz>
 <1462865763-22084-4-git-send-email-vbabka@suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1462865763-22084-4-git-send-email-vbabka@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Rik van Riel <riel@redhat.com>, David Rientjes <rientjes@google.com>, Mel Gorman <mgorman@techsingularity.net>, Johannes Weiner <hannes@cmpxchg.org>, Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>, linux-kernel@vger.kernel.org, Linus Torvalds <torvalds@linux-foundation.org>

On Tue 10-05-16 09:35:53, Vlastimil Babka wrote:
> After __alloc_pages_slowpath() sets up new alloc_flags and wakes up kswapd, it
> first tries get_page_from_freelist() with the new alloc_flags, as it may
> succeed e.g. due to using min watermark instead of low watermark. This attempt
> does not have to be retried on each loop, since direct reclaim, direct
> compaction and oom call get_page_from_freelist() themselves.
> 
> This patch therefore moves the initial attempt above the retry label. The
> ALLOC_NO_WATERMARKS attempt is kept under retry label as it's special and
> should be retried after each loop.

Yes this makes code both more clear and more logical

> Kswapd wakeups are also done on each retry
> to be safe from potential races resulting in kswapd going to sleep while a
> process (that may not be able to reclaim by itself) is still looping.

I am not sure this is really necessary but it shouldn't be harmful. The
comment clarifies the duplicity so we are not risking "cleanups to
remove duplicated code" I guess.

> Signed-off-by: Vlastimil Babka <vbabka@suse.cz>

Acked-by: Michal Hocko <mhocko@suse.com>

> ---
>  mm/page_alloc.c | 11 +++++++++--
>  1 file changed, 9 insertions(+), 2 deletions(-)
> 
> diff --git a/mm/page_alloc.c b/mm/page_alloc.c
> index 91fbf6f95403..7249949d65ca 100644
> --- a/mm/page_alloc.c
> +++ b/mm/page_alloc.c
> @@ -3586,16 +3586,23 @@ __alloc_pages_slowpath(gfp_t gfp_mask, unsigned int order,
>  	 */
>  	alloc_flags = gfp_to_alloc_flags(gfp_mask);
>  
> -retry:
>  	if (gfp_mask & __GFP_KSWAPD_RECLAIM)
>  		wake_all_kswapds(order, ac);
>  
> -	/* This is the last chance, in general, before the goto nopage. */
> +	/*
> +	 * The adjusted alloc_flags might result in immediate success, so try
> +	 * that first
> +	 */
>  	page = get_page_from_freelist(gfp_mask, order,
>  				alloc_flags & ~ALLOC_NO_WATERMARKS, ac);
>  	if (page)
>  		goto got_pg;
>  
> +retry:
> +	/* Ensure kswapd doesn't accidentaly go to sleep as long as we loop */
> +	if (gfp_mask & __GFP_KSWAPD_RECLAIM)
> +		wake_all_kswapds(order, ac);
> +
>  	/* Allocate without watermarks if the context allows */
>  	if (alloc_flags & ALLOC_NO_WATERMARKS) {
>  		/*
> -- 
> 2.8.2
> 
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

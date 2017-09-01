Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f199.google.com (mail-wr0-f199.google.com [209.85.128.199])
	by kanga.kvack.org (Postfix) with ESMTP id 4655E6B025F
	for <linux-mm@kvack.org>; Fri,  1 Sep 2017 10:28:49 -0400 (EDT)
Received: by mail-wr0-f199.google.com with SMTP id y21so580592wrd.3
        for <linux-mm@kvack.org>; Fri, 01 Sep 2017 07:28:49 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id z203si165877wmg.179.2017.09.01.07.28.47
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Fri, 01 Sep 2017 07:28:47 -0700 (PDT)
Date: Fri, 1 Sep 2017 16:28:45 +0200
From: Michal Hocko <mhocko@suse.com>
Subject: Re: [PATCH] mm,page_alloc: apply gfp_allowed_mask before the first
 allocation attempt.
Message-ID: <20170901142845.nqcn2na4vy6giyhm@dhcp22.suse.cz>
References: <1504275091-4427-1-git-send-email-penguin-kernel@I-love.SAKURA.ne.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1504275091-4427-1-git-send-email-penguin-kernel@I-love.SAKURA.ne.jp>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Cc: akpm@linux-foundation.org, linux-mm@kvack.org, David Rientjes <rientjes@google.com>, Vlastimil Babka <vbabka@suse.cz>, Hillf Danton <hillf.zj@alibaba-inc.com>, Jesper Dangaard Brouer <brouer@redhat.com>, Mel Gorman <mgorman@techsingularity.net>

On Fri 01-09-17 23:11:31, Tetsuo Handa wrote:
> We are by error initializing alloc_flags before gfp_allowed_mask is
> applied. Apply gfp_allowed_mask before initializing alloc_flags so that
> the first allocation attempt uses correct flags.

It would be worth noting that this will not matter in most cases,
actually when only the node reclaim is enabled we can misbehave because
NOFS request for PM paths would be ignored.

> Fixes: 9cd7555875bb09da ("mm, page_alloc: split alloc_pages_nodemask()")

AFAICS this patch hasn't changed the logic and it was broken since
83d4ca8148fd ("mm, page_alloc: move __GFP_HARDWALL modifications out of
the fastpath")

> Signed-off-by: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
> Cc: Mel Gorman <mgorman@techsingularity.net>
> Cc: Hillf Danton <hillf.zj@alibaba-inc.com>
> Cc: Vlastimil Babka <vbabka@suse.cz>
> Cc: Jesper Dangaard Brouer <brouer@redhat.com>

Other than that this looks correct to me. 
Acked-by: Michal Hocko <mhocko@suse.com>

I wish we can finally get rid of gfp_allowed_mask. I have it on my todo
list but never got to it.

Thanks!

> ---
>  mm/page_alloc.c | 3 ++-
>  1 file changed, 2 insertions(+), 1 deletion(-)
> 
> diff --git a/mm/page_alloc.c b/mm/page_alloc.c
> index 6dbc49e..a123dee 100644
> --- a/mm/page_alloc.c
> +++ b/mm/page_alloc.c
> @@ -4179,10 +4179,11 @@ struct page *
>  {
>  	struct page *page;
>  	unsigned int alloc_flags = ALLOC_WMARK_LOW;
> -	gfp_t alloc_mask = gfp_mask; /* The gfp_t that was actually used for allocation */
> +	gfp_t alloc_mask; /* The gfp_t that was actually used for allocation */
>  	struct alloc_context ac = { };
>  
>  	gfp_mask &= gfp_allowed_mask;
> +	alloc_mask = gfp_mask;
>  	if (!prepare_alloc_pages(gfp_mask, order, preferred_nid, nodemask, &ac, &alloc_mask, &alloc_flags))
>  		return NULL;
>  
> -- 
> 1.8.3.1
> 

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

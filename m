Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f52.google.com (mail-wm0-f52.google.com [74.125.82.52])
	by kanga.kvack.org (Postfix) with ESMTP id 51F686B0255
	for <linux-mm@kvack.org>; Sun, 22 Nov 2015 07:55:34 -0500 (EST)
Received: by wmec201 with SMTP id c201so73474348wme.1
        for <linux-mm@kvack.org>; Sun, 22 Nov 2015 04:55:33 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id q133si12563727wmb.22.2015.11.22.04.55.32
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Sun, 22 Nov 2015 04:55:32 -0800 (PST)
Subject: Re: [PATCH] mm, oom: Give __GFP_NOFAIL allocations access to memory
 reserves
References: <1447249697-13380-1-git-send-email-mhocko@kernel.org>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <5651BB43.8030102@suse.cz>
Date: Sun, 22 Nov 2015 13:55:31 +0100
MIME-Version: 1.0
In-Reply-To: <1447249697-13380-1-git-send-email-mhocko@kernel.org>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: mhocko@kernel.org, Andrew Morton <akpm@linux-foundation.org>
Cc: Johannes Weiner <hannes@cmpxchg.org>, Andrea Arcangeli <aarcange@redhat.com>, Mel Gorman <mgorman@suse.de>, David Rientjes <rientjes@google.com>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>, Michal Hocko <mhocko@suse.com>

On 11.11.2015 14:48, mhocko@kernel.org wrote:
>  mm/page_alloc.c | 10 +++++++++-
>  1 file changed, 9 insertions(+), 1 deletion(-)
> 
> diff --git a/mm/page_alloc.c b/mm/page_alloc.c
> index 8034909faad2..d30bce9d7ac8 100644
> --- a/mm/page_alloc.c
> +++ b/mm/page_alloc.c
> @@ -2766,8 +2766,16 @@ __alloc_pages_may_oom(gfp_t gfp_mask, unsigned int order,
>  			goto out;
>  	}
>  	/* Exhausted what can be done so it's blamo time */
> -	if (out_of_memory(&oc) || WARN_ON_ONCE(gfp_mask & __GFP_NOFAIL))
> +	if (out_of_memory(&oc) || WARN_ON_ONCE(gfp_mask & __GFP_NOFAIL)) {
>  		*did_some_progress = 1;
> +
> +		if (gfp_mask & __GFP_NOFAIL) {
> +			page = get_page_from_freelist(gfp_mask, order,
> +					ALLOC_NO_WATERMARKS|ALLOC_CPUSET, ac);
> +			WARN_ONCE(!page, "Unable to fullfil gfp_nofail allocation."
> +				    " Consider increasing min_free_kbytes.\n");

It seems redundant to me to keep the WARN_ON_ONCE also above in the if () part?
Also s/gfp_nofail/GFP_NOFAIL/ for consistency?

Hm and probably out of scope of your patch, but I understand the WARN_ONCE
(WARN_ON_ONCE) to be _ONCE just to prevent a flood from a single task looping
here. But for distinct tasks and potentially far away in time, wouldn't we want
to see all the warnings? Would that be feasible to implement?

> +		}
> +	}
>  out:
>  	mutex_unlock(&oom_lock);
>  	return page;
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

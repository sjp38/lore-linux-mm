Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f51.google.com (mail-wm0-f51.google.com [74.125.82.51])
	by kanga.kvack.org (Postfix) with ESMTP id 19BF86B0253
	for <linux-mm@kvack.org>; Thu, 25 Feb 2016 06:36:15 -0500 (EST)
Received: by mail-wm0-f51.google.com with SMTP id g62so27894685wme.0
        for <linux-mm@kvack.org>; Thu, 25 Feb 2016 03:36:15 -0800 (PST)
Received: from mail-wm0-f42.google.com (mail-wm0-f42.google.com. [74.125.82.42])
        by mx.google.com with ESMTPS id b2si9268476wjy.233.2016.02.25.03.36.13
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 25 Feb 2016 03:36:14 -0800 (PST)
Received: by mail-wm0-f42.google.com with SMTP id g62so24259121wme.1
        for <linux-mm@kvack.org>; Thu, 25 Feb 2016 03:36:13 -0800 (PST)
Subject: Re: [PATCH] mm: remove __GFP_NOFAIL is deprecated comment
References: <1456397002-27172-1-git-send-email-mhocko@kernel.org>
From: Nikolay Borisov <kernel@kyup.com>
Message-ID: <56CEE72B.5040009@kyup.com>
Date: Thu, 25 Feb 2016 13:36:11 +0200
MIME-Version: 1.0
In-Reply-To: <1456397002-27172-1-git-send-email-mhocko@kernel.org>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>, Andrew Morton <akpm@linux-foundation.org>
Cc: David Rientjes <rientjes@google.com>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>, Michal Hocko <mhocko@suse.com>



On 02/25/2016 12:43 PM, Michal Hocko wrote:
> From: Michal Hocko <mhocko@suse.com>
> 
> 647757197cd3 ("mm: clarify __GFP_NOFAIL deprecation status") was
> incomplete and didn't remove the comment about __GFP_NOFAIL being
> deprecated in buffered_rmqueue. Let's get rid of this leftover
> but keep the WARN_ON_ONCE for order > 1 because we should really
> discourage from using __GFP_NOFAIL with higher order allocations
> because those are just too subtle.
> 
> Signed-off-by: Michal Hocko <mhocko@suse.com>
> ---
> Hi,
> this popped out when discussing another patch http://lkml.kernel.org/r/56CEC568.6080809@kyup.com
> so I think it is worth removing the comment.
> 
>  mm/page_alloc.c | 18 +++++-------------
>  1 file changed, 5 insertions(+), 13 deletions(-)
> 
> diff --git a/mm/page_alloc.c b/mm/page_alloc.c
> index 1993894b4219..109d975a7172 100644
> --- a/mm/page_alloc.c
> +++ b/mm/page_alloc.c
> @@ -2347,19 +2347,11 @@ struct page *buffered_rmqueue(struct zone *preferred_zone,
>  		list_del(&page->lru);
>  		pcp->count--;
>  	} else {
> -		if (unlikely(gfp_flags & __GFP_NOFAIL)) {
> -			/*
> -			 * __GFP_NOFAIL is not to be used in new code.
> -			 *
> -			 * All __GFP_NOFAIL callers should be fixed so that they
> -			 * properly detect and handle allocation failures.
> -			 *
> -			 * We most definitely don't want callers attempting to
> -			 * allocate greater than order-1 page units with
> -			 * __GFP_NOFAIL.
> -			 */
> -			WARN_ON_ONCE(order > 1);
> -		}
> +		/*
> +		 * We most definitely don't want callers attempting to
> +		 * allocate greater than order-1 page units with __GFP_NOFAIL.
> +		 */
> +		WARN_ON_ONCE(unlikely(gfp_flags & __GFP_NOFAIL) && (order > 1));

WARN_ON_ONCE already includes an unlikely in its definition:
http://lxr.free-electrons.com/source/include/asm-generic/bug.h#L109

>  		spin_lock_irqsave(&zone->lock, flags);
>  
>  		page = NULL;
> 


Reviewed-by: Nikolay Borisov <kernel@kyup.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

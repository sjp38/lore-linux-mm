Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f54.google.com (mail-pa0-f54.google.com [209.85.220.54])
	by kanga.kvack.org (Postfix) with ESMTP id D3E1C6B0038
	for <linux-mm@kvack.org>; Wed, 25 Nov 2015 05:59:21 -0500 (EST)
Received: by pacej9 with SMTP id ej9so54343764pac.2
        for <linux-mm@kvack.org>; Wed, 25 Nov 2015 02:59:21 -0800 (PST)
Received: from mail-pa0-x233.google.com (mail-pa0-x233.google.com. [2607:f8b0:400e:c03::233])
        by mx.google.com with ESMTPS id w13si467036pas.108.2015.11.25.02.59.21
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 25 Nov 2015 02:59:21 -0800 (PST)
Received: by pabfh17 with SMTP id fh17so56051183pab.0
        for <linux-mm@kvack.org>; Wed, 25 Nov 2015 02:59:21 -0800 (PST)
Date: Wed, 25 Nov 2015 02:59:19 -0800 (PST)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH 2/2] mm: warn about ALLOC_NO_WATERMARKS request
 failures
In-Reply-To: <1448448054-804-3-git-send-email-mhocko@kernel.org>
Message-ID: <alpine.DEB.2.10.1511250251490.32374@chino.kir.corp.google.com>
References: <1448448054-804-1-git-send-email-mhocko@kernel.org> <1448448054-804-3-git-send-email-mhocko@kernel.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, Johannes Weiner <hannes@cmpxchg.org>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>, Michal Hocko <mhocko@suse.com>

On Wed, 25 Nov 2015, Michal Hocko wrote:

> From: Michal Hocko <mhocko@suse.com>
> 
> ALLOC_NO_WATERMARKS requests can dive into memory reserves without any
> restriction. They are used only in the case of emergency to allow
> forward memory reclaim progress assuming the caller should return the
> memory in a short time (e.g. {__GFP,PF}_MEMALLOC requests or OOM victim
> on the way to exit or __GFP_NOFAIL requests hitting OOM). There is no
> guarantee such request succeed because memory reserves might get
> depleted as well. This might be either a result of a bug where memory
> reserves are abused or a result of a too optimistic configuration of
> memory reserves.
> 
> This patch makes sure that the administrator gets a warning when these
> requests fail with a hint that min_free_kbytes might be used to increase
> the amount of memory reserves. The warning might also help us check
> whether the issue is caused by a buggy user or the configuration. To
> prevent from flooding the logs the warning is on off but we allow it to
> trigger again after min_free_kbytes was updated. Something really bad is
> clearly going on if the warning hits even after multiple updates of
> min_free_kbytes.
> 
> Signed-off-by: Michal Hocko <mhocko@suse.com>
> ---
>  mm/page_alloc.c | 12 ++++++++++++
>  1 file changed, 12 insertions(+)
> 
> diff --git a/mm/page_alloc.c b/mm/page_alloc.c
> index 70db11c27046..6a05d771cb08 100644
> --- a/mm/page_alloc.c
> +++ b/mm/page_alloc.c
> @@ -240,6 +240,8 @@ compound_page_dtor * const compound_page_dtors[] = {
>  #endif
>  };
>  
> +/* warn about depleted watermarks */
> +static bool warn_alloc_no_wmarks;
>  int min_free_kbytes = 1024;
>  int user_min_free_kbytes = -1;
>  
> @@ -2642,6 +2644,13 @@ get_page_from_freelist(gfp_t gfp_mask, unsigned int order, int alloc_flags,
>  	if (zonelist_rescan)
>  		goto zonelist_scan;
>  
> +	/* WARN only once unless min_free_kbytes is updated */
> +	if (warn_alloc_no_wmarks && (alloc_flags & ALLOC_NO_WATERMARKS)) {
> +		warn_alloc_no_wmarks = 0;
> +		WARN(1, "Memory reserves are depleted for order:%d, mode:0x%x."
> +			" You might consider increasing min_free_kbytes\n",
> +			order, gfp_mask);
> +	}
>  	return NULL;
>  }
>  

Doesn't this warn for high-order allocations prior to the first call to 
direct compaction whereas min_free_kbytes may be irrelevant?  Providing 
the order is good, but there's no indication when min_free_kbytes may be 
helpful from this warning.  WARN() isn't even going to show the state of 
memory.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

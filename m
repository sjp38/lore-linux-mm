Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f50.google.com (mail-wm0-f50.google.com [74.125.82.50])
	by kanga.kvack.org (Postfix) with ESMTP id CFC716B0038
	for <linux-mm@kvack.org>; Wed, 25 Nov 2015 09:33:57 -0500 (EST)
Received: by wmvv187 with SMTP id v187so259902502wmv.1
        for <linux-mm@kvack.org>; Wed, 25 Nov 2015 06:33:57 -0800 (PST)
Received: from mail-wm0-f49.google.com (mail-wm0-f49.google.com. [74.125.82.49])
        by mx.google.com with ESMTPS id rx8si32858253wjb.204.2015.11.25.06.33.56
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 25 Nov 2015 06:33:56 -0800 (PST)
Received: by wmuu63 with SMTP id u63so140457187wmu.0
        for <linux-mm@kvack.org>; Wed, 25 Nov 2015 06:33:56 -0800 (PST)
Date: Wed, 25 Nov 2015 15:33:55 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH v2 8/9] mm, page_alloc: print symbolic gfp_flags on
 allocation failure
Message-ID: <20151125143355.GK27283@dhcp22.suse.cz>
References: <1448368581-6923-1-git-send-email-vbabka@suse.cz>
 <1448368581-6923-9-git-send-email-vbabka@suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1448368581-6923-9-git-send-email-vbabka@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Minchan Kim <minchan@kernel.org>, Sasha Levin <sasha.levin@oracle.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Mel Gorman <mgorman@suse.de>

On Tue 24-11-15 13:36:20, Vlastimil Babka wrote:
> It would be useful to translate gfp_flags into string representation when
> printing in case of an allocation failure, especially as the flags have been
> undergoing some changes recently and the script ./scripts/gfp-translate needs
> a matching source version to be accurate.
> 
> Example output:
> 
> stapio: page allocation failure: order:9, mode:0x2080020(GFP_ATOMIC)

I like this _very much_

> Signed-off-by: Vlastimil Babka <vbabka@suse.cz>

If this can be done with a printk formatter it would be even nicer but
this is good enough for the OOM purpose.

Acked-by: Michal Hocko <mhocko@suse.com>

> ---
>  mm/page_alloc.c | 4 ++--
>  1 file changed, 2 insertions(+), 2 deletions(-)
> 
> diff --git a/mm/page_alloc.c b/mm/page_alloc.c
> index f806a1a..80349ac 100644
> --- a/mm/page_alloc.c
> +++ b/mm/page_alloc.c
> @@ -2711,9 +2711,9 @@ void warn_alloc_failed(gfp_t gfp_mask, unsigned int order, const char *fmt, ...)
>  		va_end(args);
>  	}
>  
> -	pr_warn("%s: page allocation failure: order:%u, mode:0x%x\n",
> +	pr_warn("%s: page allocation failure: order:%u, mode:0x%x",
>  		current->comm, order, gfp_mask);
> -
> +	dump_gfpflag_names(gfp_mask);
>  	dump_stack();
>  	if (!should_suppress_show_mem())
>  		show_mem(filter);
> -- 
> 2.6.3

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

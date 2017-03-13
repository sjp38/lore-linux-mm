Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f199.google.com (mail-wr0-f199.google.com [209.85.128.199])
	by kanga.kvack.org (Postfix) with ESMTP id 03E476B0389
	for <linux-mm@kvack.org>; Mon, 13 Mar 2017 08:03:24 -0400 (EDT)
Received: by mail-wr0-f199.google.com with SMTP id u48so43490235wrc.0
        for <linux-mm@kvack.org>; Mon, 13 Mar 2017 05:03:23 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id r10si10621683wmg.86.2017.03.13.05.03.22
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Mon, 13 Mar 2017 05:03:22 -0700 (PDT)
Date: Mon, 13 Mar 2017 13:03:21 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH] mm: don't warn when vmalloc() fails due to a fatal signal
Message-ID: <20170313120320.GN31518@dhcp22.suse.cz>
References: <20170313114425.72724-1-dvyukov@google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170313114425.72724-1-dvyukov@google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dmitry Vyukov <dvyukov@google.com>
Cc: aryabinin@virtuozzo.com, kirill.shutemov@linux.intel.com, akpm@linux-foundation.org, linux-mm@kvack.org

On Mon 13-03-17 12:44:25, Dmitry Vyukov wrote:
> When vmalloc() fails it prints a very lengthy message with all the
> details about memory consumption assuming that it happened due to OOM.
> However, vmalloc() can also fail due to fatal signal pending.
> In such case the message is quite confusing because it suggests that
> it is OOM but the numbers suggest otherwise. The messages can also
> pollute console considerably.
> 
> Don't warn when vmalloc() fails due to fatal signal pending.
> 
> Signed-off-by: Dmitry Vyukov <dvyukov@google.com>
> Cc: linux-mm@kvack.org

Acked-by: Michal Hocko <mhocko@suse.com>

> ---
>  mm/vmalloc.c | 3 ++-
>  1 file changed, 2 insertions(+), 1 deletion(-)
> 
> diff --git a/mm/vmalloc.c b/mm/vmalloc.c
> index edf15f49831e..68eb0028004b 100644
> --- a/mm/vmalloc.c
> +++ b/mm/vmalloc.c
> @@ -1683,7 +1683,7 @@ static void *__vmalloc_area_node(struct vm_struct *area, gfp_t gfp_mask,
>  
>  		if (fatal_signal_pending(current)) {
>  			area->nr_pages = i;
> -			goto fail;
> +			goto fail_no_warn;
>  		}
>  
>  		if (node == NUMA_NO_NODE)
> @@ -1709,6 +1709,7 @@ static void *__vmalloc_area_node(struct vm_struct *area, gfp_t gfp_mask,
>  	warn_alloc(gfp_mask, NULL,
>  			  "vmalloc: allocation failure, allocated %ld of %ld bytes",
>  			  (area->nr_pages*PAGE_SIZE), area->size);
> +fail_no_warn:
>  	vfree(area->addr);
>  	return NULL;
>  }
> -- 
> 2.12.0.246.ga2ecc84866-goog

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

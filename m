Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f198.google.com (mail-wr0-f198.google.com [209.85.128.198])
	by kanga.kvack.org (Postfix) with ESMTP id 02958831F4
	for <linux-mm@kvack.org>; Thu, 18 May 2017 10:09:33 -0400 (EDT)
Received: by mail-wr0-f198.google.com with SMTP id g12so9523489wrg.15
        for <linux-mm@kvack.org>; Thu, 18 May 2017 07:09:32 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id e36si5109871eda.29.2017.05.18.07.09.31
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 18 May 2017 07:09:31 -0700 (PDT)
Subject: Re: [PATCH] mm: clarify why we want kmalloc before falling backto
 vmallock
References: <20170517080932.21423-1-mhocko@kernel.org>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <9e50d756-4fed-3617-ab93-8298d7e0231b@suse.cz>
Date: Thu, 18 May 2017 16:08:58 +0200
MIME-Version: 1.0
In-Reply-To: <20170517080932.21423-1-mhocko@kernel.org>
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>, Andrew Morton <akpm@linux-foundation.org>
Cc: Chris Wilson <chris@chris-wilson.co.uk>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>, Michal Hocko <mhocko@suse.com>

On 05/17/2017 10:09 AM, Michal Hocko wrote:
> From: Michal Hocko <mhocko@suse.com>
> 
> While converting drm_[cm]alloc* helpers to kvmalloc* variants Chris
> Wilson has wondered why we want to try kmalloc before vmalloc fallback
> even for larger allocations requests. Let's clarify that one larger
> physically contiguous block is less likely to fragment memory than many
> scattered pages which can prevent more large blocks from being created.
> 
> Suggested-by: Chris Wilson <chris@chris-wilson.co.uk>
> Signed-off-by: Michal Hocko <mhocko@suse.com>

Acked-by: Vlastimil Babka <vbabka@suse.cz>

> ---
>  mm/util.c | 5 ++++-
>  1 file changed, 4 insertions(+), 1 deletion(-)
> 
> diff --git a/mm/util.c b/mm/util.c
> index 464df3489903..87499f8119f2 100644
> --- a/mm/util.c
> +++ b/mm/util.c
> @@ -357,7 +357,10 @@ void *kvmalloc_node(size_t size, gfp_t flags, int node)
>  	WARN_ON_ONCE((flags & GFP_KERNEL) != GFP_KERNEL);
>  
>  	/*
> -	 * Make sure that larger requests are not too disruptive - no OOM
> +	 * We want to attempt a large physically contiguous block first because
> +	 * it is less likely to fragment multiple larger blocks and therefore
> +	 * contribute to a long term fragmentation less than vmalloc fallback.
> +	 * However make sure that larger requests are not too disruptive - no OOM
>  	 * killer and no allocation failure warnings as we have a fallback
>  	 */
>  	if (size > PAGE_SIZE) {
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

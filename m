Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id C4A43280753
	for <linux-mm@kvack.org>; Fri, 19 May 2017 20:47:00 -0400 (EDT)
Received: by mail-pf0-f199.google.com with SMTP id a66so67868895pfl.6
        for <linux-mm@kvack.org>; Fri, 19 May 2017 17:47:00 -0700 (PDT)
Received: from hqemgate16.nvidia.com (hqemgate16.nvidia.com. [216.228.121.65])
        by mx.google.com with ESMTPS id v14si9806620plk.134.2017.05.19.17.46.59
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 19 May 2017 17:46:59 -0700 (PDT)
Subject: Re: [PATCH] mm: clarify why we want kmalloc before falling backto
 vmallock
References: <20170517080932.21423-1-mhocko@kernel.org>
From: John Hubbard <jhubbard@nvidia.com>
Message-ID: <d6121d8b-8d0f-88da-cd67-e9123bb96454@nvidia.com>
Date: Fri, 19 May 2017 17:46:58 -0700
MIME-Version: 1.0
In-Reply-To: <20170517080932.21423-1-mhocko@kernel.org>
Content-Type: text/plain; charset="utf-8"; format=flowed
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>, Andrew Morton <akpm@linux-foundation.org>
Cc: Chris Wilson <chris@chris-wilson.co.uk>, Vlastimil Babka <vbabka@suse.cz>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>, Michal Hocko <mhocko@suse.com>

On 05/17/2017 01:09 AM, Michal Hocko wrote:
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
> ---
>   mm/util.c | 5 ++++-
>   1 file changed, 4 insertions(+), 1 deletion(-)
> 
> diff --git a/mm/util.c b/mm/util.c
> index 464df3489903..87499f8119f2 100644
> --- a/mm/util.c
> +++ b/mm/util.c
> @@ -357,7 +357,10 @@ void *kvmalloc_node(size_t size, gfp_t flags, int node)
>   	WARN_ON_ONCE((flags & GFP_KERNEL) != GFP_KERNEL);
>   
>   	/*
> -	 * Make sure that larger requests are not too disruptive - no OOM
> +	 * We want to attempt a large physically contiguous block first because
> +	 * it is less likely to fragment multiple larger blocks and therefore
> +	 * contribute to a long term fragmentation less than vmalloc fallback.
> +	 * However make sure that larger requests are not too disruptive - no OOM
>   	 * killer and no allocation failure warnings as we have a fallback
>   	 */

Thanks for adding this, it's great to have. Here's a slightly polished version of your words, if you 
like:

	/*
	 * We want to attempt a large physically contiguous block first because
	 * it is less likely to fragment multiple larger blocks. This approach
	 * therefore contributes less to long term fragmentation than a vmalloc
	 * fallback would. However, make sure that larger requests are not too
	 * disruptive: no OOM killer and no allocation failure warnings, as we
	 * have a fallback.
	 */

thanks,
john h

>   	if (size > PAGE_SIZE) {
> -- 
> 2.11.0
> 
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

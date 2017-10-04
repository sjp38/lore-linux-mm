Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f199.google.com (mail-qk0-f199.google.com [209.85.220.199])
	by kanga.kvack.org (Postfix) with ESMTP id C75566B0266
	for <linux-mm@kvack.org>; Wed,  4 Oct 2017 17:30:49 -0400 (EDT)
Received: by mail-qk0-f199.google.com with SMTP id b124so12907022qke.1
        for <linux-mm@kvack.org>; Wed, 04 Oct 2017 14:30:49 -0700 (PDT)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id q16sor1016460qtb.99.2017.10.04.14.30.48
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 04 Oct 2017 14:30:49 -0700 (PDT)
Subject: Re: [PATCH] cma: Take __GFP_NOWARN into account in cma_alloc()
References: <20171004125447.15195-1-boris.brezillon@free-electrons.com>
From: Laura Abbott <labbott@redhat.com>
Message-ID: <9b826ce7-9e4e-4e47-3fc0-e9c511ed93fc@redhat.com>
Date: Wed, 4 Oct 2017 14:30:45 -0700
MIME-Version: 1.0
In-Reply-To: <20171004125447.15195-1-boris.brezillon@free-electrons.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Boris Brezillon <boris.brezillon@free-electrons.com>, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>
Cc: Jaewon Kim <jaewon31.kim@samsung.com>, David Airlie <airlied@linux.ie>, Daniel Vetter <daniel@ffwll.ch>, dri-devel@lists.freedesktop.org, Eric Anholt <eric@anholt.net>

On 10/04/2017 05:54 AM, Boris Brezillon wrote:
> cma_alloc() unconditionally prints an INFO message when the CMA
> allocation fails. Make this message conditional on the non-presence of
> __GFP_NOWARN in gfp_mask.
> 
> Signed-off-by: Boris Brezillon <boris.brezillon@free-electrons.com>

Acked-by: Laura Abbott <labbott@redhat.com>

> ---
> Hello,
> 
> This patch aims at removing INFO messages that are displayed when the
> VC4 driver tries to allocate buffer objects. From the driver perspective
> an allocation failure is acceptable, and the driver can possibly do
> something to make following allocation succeed (like flushing the VC4
> internal cache).
> 
> Also, I don't understand why this message is only an INFO message, and
> not a WARN (pr_warn()). Please let me know if you have good reasons to
> keep it as an unconditional pr_info().
> 
> Thanks,
> 
> Boris
> ---
>  mm/cma.c | 2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
> 
> diff --git a/mm/cma.c b/mm/cma.c
> index c0da318c020e..022e52bd8370 100644
> --- a/mm/cma.c
> +++ b/mm/cma.c
> @@ -460,7 +460,7 @@ struct page *cma_alloc(struct cma *cma, size_t count, unsigned int align,
>  
>  	trace_cma_alloc(pfn, page, count, align);
>  
> -	if (ret) {
> +	if (ret && !(gfp_mask & __GFP_NOWARN)) {
>  		pr_info("%s: alloc failed, req-size: %zu pages, ret: %d\n",
>  			__func__, count, ret);
>  		cma_debug_show_areas(cma);
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

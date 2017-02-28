Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f198.google.com (mail-wr0-f198.google.com [209.85.128.198])
	by kanga.kvack.org (Postfix) with ESMTP id A4CA66B038F
	for <linux-mm@kvack.org>; Tue, 28 Feb 2017 04:01:14 -0500 (EST)
Received: by mail-wr0-f198.google.com with SMTP id 73so2655738wrb.1
        for <linux-mm@kvack.org>; Tue, 28 Feb 2017 01:01:14 -0800 (PST)
Received: from mail-wr0-x244.google.com (mail-wr0-x244.google.com. [2a00:1450:400c:c0c::244])
        by mx.google.com with ESMTPS id v202si7936890wmv.158.2017.02.28.01.01.13
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 28 Feb 2017 01:01:13 -0800 (PST)
Received: by mail-wr0-x244.google.com with SMTP id l37so742324wrc.3
        for <linux-mm@kvack.org>; Tue, 28 Feb 2017 01:01:13 -0800 (PST)
Date: Tue, 28 Feb 2017 10:01:10 +0100
From: Daniel Vetter <daniel@ffwll.ch>
Subject: Re: [PATCH RESEND] drm/via: use get_user_pages_unlocked()
Message-ID: <20170228090110.m4pxtjlbgaft7oet@phenom.ffwll.local>
References: <20170227215008.21457-1-lstoakes@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170227215008.21457-1-lstoakes@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Lorenzo Stoakes <lstoakes@gmail.com>
Cc: Daniel Vetter <daniel@ffwll.ch>, linux-kernel@vger.kernel.org, dri-devel@lists.freedesktop.org, linux-mm@kvack.org

On Mon, Feb 27, 2017 at 09:50:08PM +0000, Lorenzo Stoakes wrote:
> Moving from get_user_pages() to get_user_pages_unlocked() simplifies the code
> and takes advantage of VM_FAULT_RETRY functionality when faulting in pages.
> 
> Signed-off-by: Lorenzo Stoakes <lstoakes@gmail.com>

Queued for 4.12, thanks for the patch.
-Daniel

> ---
>  drivers/gpu/drm/via/via_dmablit.c | 10 +++-------
>  1 file changed, 3 insertions(+), 7 deletions(-)
> 
> diff --git a/drivers/gpu/drm/via/via_dmablit.c b/drivers/gpu/drm/via/via_dmablit.c
> index 1a3ad769f8c8..98aae9809249 100644
> --- a/drivers/gpu/drm/via/via_dmablit.c
> +++ b/drivers/gpu/drm/via/via_dmablit.c
> @@ -238,13 +238,9 @@ via_lock_all_dma_pages(drm_via_sg_info_t *vsg,  drm_via_dmablit_t *xfer)
>  	vsg->pages = vzalloc(sizeof(struct page *) * vsg->num_pages);
>  	if (NULL == vsg->pages)
>  		return -ENOMEM;
> -	down_read(&current->mm->mmap_sem);
> -	ret = get_user_pages((unsigned long)xfer->mem_addr,
> -			     vsg->num_pages,
> -			     (vsg->direction == DMA_FROM_DEVICE) ? FOLL_WRITE : 0,
> -			     vsg->pages, NULL);
> -
> -	up_read(&current->mm->mmap_sem);
> +	ret = get_user_pages_unlocked((unsigned long)xfer->mem_addr,
> +			vsg->num_pages, vsg->pages,
> +			(vsg->direction == DMA_FROM_DEVICE) ? FOLL_WRITE : 0);
>  	if (ret != vsg->num_pages) {
>  		if (ret < 0)
>  			return ret;
> -- 
> 2.11.1
> 

-- 
Daniel Vetter
Software Engineer, Intel Corporation
http://blog.ffwll.ch

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

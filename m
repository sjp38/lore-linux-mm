Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f41.google.com (mail-wg0-f41.google.com [74.125.82.41])
	by kanga.kvack.org (Postfix) with ESMTP id 4633E6B0038
	for <linux-mm@kvack.org>; Wed,  6 May 2015 06:47:38 -0400 (EDT)
Received: by wgin8 with SMTP id n8so7011347wgi.0
        for <linux-mm@kvack.org>; Wed, 06 May 2015 03:47:37 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id eq3si32244506wjd.142.2015.05.06.03.47.36
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Wed, 06 May 2015 03:47:36 -0700 (PDT)
Message-ID: <5549F147.3050800@suse.cz>
Date: Wed, 06 May 2015 12:47:35 +0200
From: Vlastimil Babka <vbabka@suse.cz>
MIME-Version: 1.0
Subject: Re: [PATCH 9/9] drm/exynos: Convert g2d_userptr_get_dma_addr() to
 use get_vaddr_frames()
References: <1430897296-5469-1-git-send-email-jack@suse.cz> <1430897296-5469-10-git-send-email-jack@suse.cz>
In-Reply-To: <1430897296-5469-10-git-send-email-jack@suse.cz>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jan Kara <jack@suse.cz>, linux-mm@kvack.org
Cc: linux-media@vger.kernel.org, Hans Verkuil <hverkuil@xs4all.nl>, dri-devel@lists.freedesktop.org, Pawel Osciak <pawel@osciak.com>, Mauro Carvalho Chehab <mchehab@osg.samsung.com>, mgorman@suse.de, Marek Szyprowski <m.szyprowski@samsung.com>, linux-samsung-soc@vger.kernel.org

On 05/06/2015 09:28 AM, Jan Kara wrote:
> Convert g2d_userptr_get_dma_addr() to pin pages using get_vaddr_frames().
> This removes the knowledge about vmas and mmap_sem locking from exynos
> driver. Also it fixes a problem that the function has been mapping user
> provided address without holding mmap_sem.
>
> Signed-off-by: Jan Kara <jack@suse.cz>
> ---
>   drivers/gpu/drm/exynos/exynos_drm_g2d.c | 89 ++++++++++--------------------
>   drivers/gpu/drm/exynos/exynos_drm_gem.c | 97 ---------------------------------
>   2 files changed, 29 insertions(+), 157 deletions(-)
>
> diff --git a/drivers/gpu/drm/exynos/exynos_drm_g2d.c b/drivers/gpu/drm/exynos/exynos_drm_g2d.c
> index 81a250830808..265519c0fe2d 100644
> --- a/drivers/gpu/drm/exynos/exynos_drm_g2d.c
> +++ b/drivers/gpu/drm/exynos/exynos_drm_g2d.c
...
> @@ -456,65 +458,37 @@ static dma_addr_t *g2d_userptr_get_dma_addr(struct drm_device *drm_dev,
>   		return ERR_PTR(-ENOMEM);
>
>   	atomic_set(&g2d_userptr->refcount, 1);
> +	g2d_userptr->size = size;
>
>   	start = userptr & PAGE_MASK;
>   	offset = userptr & ~PAGE_MASK;
>   	end = PAGE_ALIGN(userptr + size);
>   	npages = (end - start) >> PAGE_SHIFT;
> -	g2d_userptr->npages = npages;
> -
> -	pages = drm_calloc_large(npages, sizeof(struct page *));
> -	if (!pages) {
> -		DRM_ERROR("failed to allocate pages.\n");
> -		ret = -ENOMEM;
> +	vec = g2d_userptr->vec = frame_vector_create(npages);
> +	if (!vec)
>   		goto err_free;
> -	}
>
> -	down_read(&current->mm->mmap_sem);
> -	vma = find_vma(current->mm, userptr);
> -	if (!vma) {
> -		up_read(&current->mm->mmap_sem);
> -		DRM_ERROR("failed to get vm region.\n");
> +	ret = get_vaddr_frames(start, npages, 1, 1, vec);

Use true instead of 1.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

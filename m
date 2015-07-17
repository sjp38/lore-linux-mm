Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f171.google.com (mail-wi0-f171.google.com [209.85.212.171])
	by kanga.kvack.org (Postfix) with ESMTP id CE1F36B025D
	for <linux-mm@kvack.org>; Fri, 17 Jul 2015 06:32:15 -0400 (EDT)
Received: by wibud3 with SMTP id ud3so35888839wib.1
        for <linux-mm@kvack.org>; Fri, 17 Jul 2015 03:32:15 -0700 (PDT)
Received: from lb3-smtp-cloud6.xs4all.net (lb3-smtp-cloud6.xs4all.net. [194.109.24.31])
        by mx.google.com with ESMTPS id bn5si18823778wjb.37.2015.07.17.03.32.13
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Fri, 17 Jul 2015 03:32:14 -0700 (PDT)
Message-ID: <55A8D96F.5000704@xs4all.nl>
Date: Fri, 17 Jul 2015 12:31:11 +0200
From: Hans Verkuil <hverkuil@xs4all.nl>
MIME-Version: 1.0
Subject: Re: [PATCH 9/9] drm/exynos: Convert g2d_userptr_get_dma_addr() to
 use get_vaddr_frames()
References: <1436799351-21975-1-git-send-email-jack@suse.com> <1436799351-21975-10-git-send-email-jack@suse.com> <55A8D700.9080203@xs4all.nl> <55A8D903.2080102@samsung.com>
In-Reply-To: <55A8D903.2080102@samsung.com>
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Inki Dae <inki.dae@samsung.com>, Jan Kara <jack@suse.com>
Cc: linux-media@vger.kernel.org, Mauro Carvalho Chehab <mchehab@osg.samsung.com>, linux-samsung-soc@vger.kernel.org, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Jan Kara <jack@suse.cz>, Marek Szyprowski <m.szyprowski@samsung.com>

On 07/17/2015 12:29 PM, Inki Dae wrote:
> On 2015e?? 07i?? 17i? 1/4  19:20, Hans Verkuil wrote:
>> On 07/13/2015 04:55 PM, Jan Kara wrote:
>>> From: Jan Kara <jack@suse.cz>
>>>
>>> Convert g2d_userptr_get_dma_addr() to pin pages using get_vaddr_frames().
>>> This removes the knowledge about vmas and mmap_sem locking from exynos
>>> driver. Also it fixes a problem that the function has been mapping user
>>> provided address without holding mmap_sem.
>>
>> I'd like to see an Ack from one of the exynos drm driver maintainers before
>> I merge this.
>>
>> Inki, Marek?
> 
> I already gave Ack but it seems that Jan missed it while updating.
> 
> Anyway,
> Acked-by: Inki Dae <inki.dae@samsung.com>

Thanks!

BTW, I didn't see your earlier Ack either. Was it posted to the linux-media list as well?
It didn't turn up there.

Regards,

	Hans

> 
> Thanks,
> Inki Dae
> 
>>
>> Regards,
>>
>> 	Hans
>>
>>>
>>> Signed-off-by: Jan Kara <jack@suse.cz>
>>> ---
>>>  drivers/gpu/drm/exynos/Kconfig          |  1 +
>>>  drivers/gpu/drm/exynos/exynos_drm_g2d.c | 91 ++++++++++---------------------
>>>  drivers/gpu/drm/exynos/exynos_drm_gem.c | 97 ---------------------------------
>>>  3 files changed, 30 insertions(+), 159 deletions(-)
>>>
>>> diff --git a/drivers/gpu/drm/exynos/Kconfig b/drivers/gpu/drm/exynos/Kconfig
>>> index 43003c4ad80b..b364562dc6c1 100644
>>> --- a/drivers/gpu/drm/exynos/Kconfig
>>> +++ b/drivers/gpu/drm/exynos/Kconfig
>>> @@ -77,6 +77,7 @@ config DRM_EXYNOS_VIDI
>>>  config DRM_EXYNOS_G2D
>>>  	bool "Exynos DRM G2D"
>>>  	depends on DRM_EXYNOS && !VIDEO_SAMSUNG_S5P_G2D
>>> +	select FRAME_VECTOR
>>>  	help
>>>  	  Choose this option if you want to use Exynos G2D for DRM.
>>>  
>>> diff --git a/drivers/gpu/drm/exynos/exynos_drm_g2d.c b/drivers/gpu/drm/exynos/exynos_drm_g2d.c
>>> index 81a250830808..1d8d9a508373 100644
>>> --- a/drivers/gpu/drm/exynos/exynos_drm_g2d.c
>>> +++ b/drivers/gpu/drm/exynos/exynos_drm_g2d.c
>>> @@ -190,10 +190,8 @@ struct g2d_cmdlist_userptr {
>>>  	dma_addr_t		dma_addr;
>>>  	unsigned long		userptr;
>>>  	unsigned long		size;
>>> -	struct page		**pages;
>>> -	unsigned int		npages;
>>> +	struct frame_vector	*vec;
>>>  	struct sg_table		*sgt;
>>> -	struct vm_area_struct	*vma;
>>>  	atomic_t		refcount;
>>>  	bool			in_pool;
>>>  	bool			out_of_list;
>>> @@ -363,6 +361,7 @@ static void g2d_userptr_put_dma_addr(struct drm_device *drm_dev,
>>>  {
>>>  	struct g2d_cmdlist_userptr *g2d_userptr =
>>>  					(struct g2d_cmdlist_userptr *)obj;
>>> +	struct page **pages;
>>>  
>>>  	if (!obj)
>>>  		return;
>>> @@ -382,19 +381,21 @@ out:
>>>  	exynos_gem_unmap_sgt_from_dma(drm_dev, g2d_userptr->sgt,
>>>  					DMA_BIDIRECTIONAL);
>>>  
>>> -	exynos_gem_put_pages_to_userptr(g2d_userptr->pages,
>>> -					g2d_userptr->npages,
>>> -					g2d_userptr->vma);
>>> +	pages = frame_vector_pages(g2d_userptr->vec);
>>> +	if (!IS_ERR(pages)) {
>>> +		int i;
>>>  
>>> -	exynos_gem_put_vma(g2d_userptr->vma);
>>> +		for (i = 0; i < frame_vector_count(g2d_userptr->vec); i++)
>>> +			set_page_dirty_lock(pages[i]);
>>> +	}
>>> +	put_vaddr_frames(g2d_userptr->vec);
>>> +	frame_vector_destroy(g2d_userptr->vec);
>>>  
>>>  	if (!g2d_userptr->out_of_list)
>>>  		list_del_init(&g2d_userptr->list);
>>>  
>>>  	sg_free_table(g2d_userptr->sgt);
>>>  	kfree(g2d_userptr->sgt);
>>> -
>>> -	drm_free_large(g2d_userptr->pages);
>>>  	kfree(g2d_userptr);
>>>  }
>>>  
>>> @@ -408,9 +409,7 @@ static dma_addr_t *g2d_userptr_get_dma_addr(struct drm_device *drm_dev,
>>>  	struct exynos_drm_g2d_private *g2d_priv = file_priv->g2d_priv;
>>>  	struct g2d_cmdlist_userptr *g2d_userptr;
>>>  	struct g2d_data *g2d;
>>> -	struct page **pages;
>>>  	struct sg_table	*sgt;
>>> -	struct vm_area_struct *vma;
>>>  	unsigned long start, end;
>>>  	unsigned int npages, offset;
>>>  	int ret;
>>> @@ -456,65 +455,38 @@ static dma_addr_t *g2d_userptr_get_dma_addr(struct drm_device *drm_dev,
>>>  		return ERR_PTR(-ENOMEM);
>>>  
>>>  	atomic_set(&g2d_userptr->refcount, 1);
>>> +	g2d_userptr->size = size;
>>>  
>>>  	start = userptr & PAGE_MASK;
>>>  	offset = userptr & ~PAGE_MASK;
>>>  	end = PAGE_ALIGN(userptr + size);
>>>  	npages = (end - start) >> PAGE_SHIFT;
>>> -	g2d_userptr->npages = npages;
>>> -
>>> -	pages = drm_calloc_large(npages, sizeof(struct page *));
>>> -	if (!pages) {
>>> -		DRM_ERROR("failed to allocate pages.\n");
>>> -		ret = -ENOMEM;
>>> +	g2d_userptr->vec = frame_vector_create(npages);
>>> +	if (!g2d_userptr->vec)
>>>  		goto err_free;
>>> -	}
>>>  
>>> -	down_read(&current->mm->mmap_sem);
>>> -	vma = find_vma(current->mm, userptr);
>>> -	if (!vma) {
>>> -		up_read(&current->mm->mmap_sem);
>>> -		DRM_ERROR("failed to get vm region.\n");
>>> +	ret = get_vaddr_frames(start, npages, true, true, g2d_userptr->vec);
>>> +	if (ret != npages) {
>>> +		DRM_ERROR("failed to get user pages from userptr.\n");
>>> +		if (ret < 0)
>>> +			goto err_destroy_framevec;
>>>  		ret = -EFAULT;
>>> -		goto err_free_pages;
>>> +		goto err_put_framevec;
>>>  	}
>>> -
>>> -	if (vma->vm_end < userptr + size) {
>>> -		up_read(&current->mm->mmap_sem);
>>> -		DRM_ERROR("vma is too small.\n");
>>> +	if (frame_vector_to_pages(g2d_userptr->vec) < 0) {
>>>  		ret = -EFAULT;
>>> -		goto err_free_pages;
>>> +		goto err_put_framevec;
>>>  	}
>>>  
>>> -	g2d_userptr->vma = exynos_gem_get_vma(vma);
>>> -	if (!g2d_userptr->vma) {
>>> -		up_read(&current->mm->mmap_sem);
>>> -		DRM_ERROR("failed to copy vma.\n");
>>> -		ret = -ENOMEM;
>>> -		goto err_free_pages;
>>> -	}
>>> -
>>> -	g2d_userptr->size = size;
>>> -
>>> -	ret = exynos_gem_get_pages_from_userptr(start & PAGE_MASK,
>>> -						npages, pages, vma);
>>> -	if (ret < 0) {
>>> -		up_read(&current->mm->mmap_sem);
>>> -		DRM_ERROR("failed to get user pages from userptr.\n");
>>> -		goto err_put_vma;
>>> -	}
>>> -
>>> -	up_read(&current->mm->mmap_sem);
>>> -	g2d_userptr->pages = pages;
>>> -
>>>  	sgt = kzalloc(sizeof(*sgt), GFP_KERNEL);
>>>  	if (!sgt) {
>>>  		ret = -ENOMEM;
>>> -		goto err_free_userptr;
>>> +		goto err_put_framevec;
>>>  	}
>>>  
>>> -	ret = sg_alloc_table_from_pages(sgt, pages, npages, offset,
>>> -					size, GFP_KERNEL);
>>> +	ret = sg_alloc_table_from_pages(sgt,
>>> +					frame_vector_pages(g2d_userptr->vec),
>>> +					npages, offset, size, GFP_KERNEL);
>>>  	if (ret < 0) {
>>>  		DRM_ERROR("failed to get sgt from pages.\n");
>>>  		goto err_free_sgt;
>>> @@ -549,16 +521,11 @@ err_sg_free_table:
>>>  err_free_sgt:
>>>  	kfree(sgt);
>>>  
>>> -err_free_userptr:
>>> -	exynos_gem_put_pages_to_userptr(g2d_userptr->pages,
>>> -					g2d_userptr->npages,
>>> -					g2d_userptr->vma);
>>> -
>>> -err_put_vma:
>>> -	exynos_gem_put_vma(g2d_userptr->vma);
>>> +err_put_framevec:
>>> +	put_vaddr_frames(g2d_userptr->vec);
>>>  
>>> -err_free_pages:
>>> -	drm_free_large(pages);
>>> +err_destroy_framevec:
>>> +	frame_vector_destroy(g2d_userptr->vec);
>>>  
>>>  err_free:
>>>  	kfree(g2d_userptr);
>>> diff --git a/drivers/gpu/drm/exynos/exynos_drm_gem.c b/drivers/gpu/drm/exynos/exynos_drm_gem.c
>>> index 0d5b9698d384..47068ae44ced 100644
>>> --- a/drivers/gpu/drm/exynos/exynos_drm_gem.c
>>> +++ b/drivers/gpu/drm/exynos/exynos_drm_gem.c
>>> @@ -378,103 +378,6 @@ int exynos_drm_gem_get_ioctl(struct drm_device *dev, void *data,
>>>  	return 0;
>>>  }
>>>  
>>> -struct vm_area_struct *exynos_gem_get_vma(struct vm_area_struct *vma)
>>> -{
>>> -	struct vm_area_struct *vma_copy;
>>> -
>>> -	vma_copy = kmalloc(sizeof(*vma_copy), GFP_KERNEL);
>>> -	if (!vma_copy)
>>> -		return NULL;
>>> -
>>> -	if (vma->vm_ops && vma->vm_ops->open)
>>> -		vma->vm_ops->open(vma);
>>> -
>>> -	if (vma->vm_file)
>>> -		get_file(vma->vm_file);
>>> -
>>> -	memcpy(vma_copy, vma, sizeof(*vma));
>>> -
>>> -	vma_copy->vm_mm = NULL;
>>> -	vma_copy->vm_next = NULL;
>>> -	vma_copy->vm_prev = NULL;
>>> -
>>> -	return vma_copy;
>>> -}
>>> -
>>> -void exynos_gem_put_vma(struct vm_area_struct *vma)
>>> -{
>>> -	if (!vma)
>>> -		return;
>>> -
>>> -	if (vma->vm_ops && vma->vm_ops->close)
>>> -		vma->vm_ops->close(vma);
>>> -
>>> -	if (vma->vm_file)
>>> -		fput(vma->vm_file);
>>> -
>>> -	kfree(vma);
>>> -}
>>> -
>>> -int exynos_gem_get_pages_from_userptr(unsigned long start,
>>> -						unsigned int npages,
>>> -						struct page **pages,
>>> -						struct vm_area_struct *vma)
>>> -{
>>> -	int get_npages;
>>> -
>>> -	/* the memory region mmaped with VM_PFNMAP. */
>>> -	if (vma_is_io(vma)) {
>>> -		unsigned int i;
>>> -
>>> -		for (i = 0; i < npages; ++i, start += PAGE_SIZE) {
>>> -			unsigned long pfn;
>>> -			int ret = follow_pfn(vma, start, &pfn);
>>> -			if (ret)
>>> -				return ret;
>>> -
>>> -			pages[i] = pfn_to_page(pfn);
>>> -		}
>>> -
>>> -		if (i != npages) {
>>> -			DRM_ERROR("failed to get user_pages.\n");
>>> -			return -EINVAL;
>>> -		}
>>> -
>>> -		return 0;
>>> -	}
>>> -
>>> -	get_npages = get_user_pages(current, current->mm, start,
>>> -					npages, 1, 1, pages, NULL);
>>> -	get_npages = max(get_npages, 0);
>>> -	if (get_npages != npages) {
>>> -		DRM_ERROR("failed to get user_pages.\n");
>>> -		while (get_npages)
>>> -			put_page(pages[--get_npages]);
>>> -		return -EFAULT;
>>> -	}
>>> -
>>> -	return 0;
>>> -}
>>> -
>>> -void exynos_gem_put_pages_to_userptr(struct page **pages,
>>> -					unsigned int npages,
>>> -					struct vm_area_struct *vma)
>>> -{
>>> -	if (!vma_is_io(vma)) {
>>> -		unsigned int i;
>>> -
>>> -		for (i = 0; i < npages; i++) {
>>> -			set_page_dirty_lock(pages[i]);
>>> -
>>> -			/*
>>> -			 * undo the reference we took when populating
>>> -			 * the table.
>>> -			 */
>>> -			put_page(pages[i]);
>>> -		}
>>> -	}
>>> -}
>>> -
>>>  int exynos_gem_map_sgt_with_dma(struct drm_device *drm_dev,
>>>  				struct sg_table *sgt,
>>>  				enum dma_data_direction dir)
>>>
>>
>> --
>> To unsubscribe from this list: send the line "unsubscribe linux-samsung-soc" in
>> the body of a message to majordomo@vger.kernel.org
>> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>>
> 
> --
> To unsubscribe from this list: send the line "unsubscribe linux-media" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

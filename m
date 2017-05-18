Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f70.google.com (mail-wm0-f70.google.com [74.125.82.70])
	by kanga.kvack.org (Postfix) with ESMTP id 56E4F831F4
	for <linux-mm@kvack.org>; Thu, 18 May 2017 04:23:33 -0400 (EDT)
Received: by mail-wm0-f70.google.com with SMTP id 196so7500713wmk.9
        for <linux-mm@kvack.org>; Thu, 18 May 2017 01:23:33 -0700 (PDT)
Received: from pegasos-out.vodafone.de (pegasos-out.vodafone.de. [80.84.1.38])
        by mx.google.com with ESMTP id 63si5244372ede.43.2017.05.18.01.23.31
        for <linux-mm@kvack.org>;
        Thu, 18 May 2017 01:23:31 -0700 (PDT)
Subject: Re: [PATCH 2/2 -v2] drm: drop drm_[cm]alloc* helpers
References: <20170517065509.18659-1-mhocko@kernel.org>
 <20170517065509.18659-2-mhocko@kernel.org>
 <20170517122312.GK18247@dhcp22.suse.cz>
From: =?UTF-8?Q?Christian_K=c3=b6nig?= <deathsimple@vodafone.de>
Message-ID: <ccf8b461-5fb6-eb58-4b28-54a1e2a7e93c@vodafone.de>
Date: Thu, 18 May 2017 10:16:38 +0200
MIME-Version: 1.0
In-Reply-To: <20170517122312.GK18247@dhcp22.suse.cz>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 8bit
Content-Language: en-US
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>, dri-devel@lists.freedesktop.org
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, Daniel Vetter <daniel.vetter@intel.com>

Am 17.05.2017 um 14:23 schrieb Michal Hocko:
> As it turned out my allyesconfig on x86_64 wasn't sufficient and 0day
> build machinery found a failure on arm architecture. It was clearly a
> typo. Now I have pushed this to my build battery with cross arch
> compilers and it passes so there shouldn't more surprises hopefully.
> Here is the v2.
> ---
>  From 4a00b3ade5ca4514f7affd8de6f7119c8d5c5a86 Mon Sep 17 00:00:00 2001
> From: Michal Hocko <mhocko@suse.com>
> Date: Tue, 16 May 2017 11:00:47 +0200
> Subject: [PATCH -v2] drm: drop drm_[cm]alloc* helpers
>
> Now that drm_[cm]alloc* helpers are simple one line wrappers around
> kvmalloc_array and drm_free_large is just kvfree alias we can drop
> them and replace by their native forms.
>
> This shouldn't introduce any functional change.
>
> Changes since v1
> - fix typo in drivers/gpu//drm/etnaviv/etnaviv_gem.c - noticed by 0day
>    build robot
>
> Suggested-by: Daniel Vetter <daniel@ffwll.ch>
> Signed-off-by: Michal Hocko <mhocko@suse.com>

Acked-by: Christian KA?nig <christian.koenig@amd.com>

> ---
>   drivers/gpu/drm/amd/amdgpu/amdgpu_bo_list.c        | 16 +++----
>   drivers/gpu/drm/amd/amdgpu/amdgpu_cs.c             | 19 ++++----
>   drivers/gpu/drm/amd/amdgpu/amdgpu_vm.c             |  7 +--
>   drivers/gpu/drm/drm_gem.c                          |  6 +--
>   drivers/gpu/drm/etnaviv/etnaviv_gem.c              | 12 ++---
>   drivers/gpu/drm/etnaviv/etnaviv_gem_prime.c        |  4 +-
>   drivers/gpu/drm/etnaviv/etnaviv_gem_submit.c       | 12 ++---
>   drivers/gpu/drm/exynos/exynos_drm_gem.c            | 11 +++--
>   drivers/gpu/drm/i915/i915_debugfs.c                |  4 +-
>   drivers/gpu/drm/i915/i915_gem.c                    |  4 +-
>   drivers/gpu/drm/i915/i915_gem_execbuffer.c         | 34 +++++++-------
>   drivers/gpu/drm/i915/i915_gem_gtt.c                |  6 +--
>   drivers/gpu/drm/i915/i915_gem_userptr.c            |  8 ++--
>   drivers/gpu/drm/i915/selftests/intel_breadcrumbs.c | 12 ++---
>   drivers/gpu/drm/msm/msm_gem.c                      | 10 ++--
>   drivers/gpu/drm/radeon/radeon_cs.c                 | 11 +++--
>   drivers/gpu/drm/radeon/radeon_gem.c                |  2 +-
>   drivers/gpu/drm/radeon/radeon_ring.c               |  4 +-
>   drivers/gpu/drm/radeon/radeon_vm.c                 |  4 +-
>   drivers/gpu/drm/ttm/ttm_tt.c                       | 13 +++---
>   drivers/gpu/drm/udl/udl_dmabuf.c                   |  2 +-
>   drivers/gpu/drm/udl/udl_gem.c                      |  2 +-
>   drivers/gpu/drm/vc4/vc4_gem.c                      | 15 +++---
>   drivers/gpu/drm/virtio/virtgpu_ioctl.c             | 27 +++++------
>   include/drm/drmP.h                                 |  1 -
>   include/drm/drm_mem_util.h                         | 53 ----------------------
>   26 files changed, 126 insertions(+), 173 deletions(-)
>   delete mode 100644 include/drm/drm_mem_util.h
>
> diff --git a/drivers/gpu/drm/amd/amdgpu/amdgpu_bo_list.c b/drivers/gpu/drm/amd/amdgpu/amdgpu_bo_list.c
> index a6649874e6ce..9f0247cdda5e 100644
> --- a/drivers/gpu/drm/amd/amdgpu/amdgpu_bo_list.c
> +++ b/drivers/gpu/drm/amd/amdgpu/amdgpu_bo_list.c
> @@ -96,7 +96,7 @@ static int amdgpu_bo_list_set(struct amdgpu_device *adev,
>   	int r;
>   	unsigned long total_size = 0;
>   
> -	array = drm_malloc_ab(num_entries, sizeof(struct amdgpu_bo_list_entry));
> +	array = kvmalloc_array(num_entries, sizeof(struct amdgpu_bo_list_entry), GFP_KERNEL);
>   	if (!array)
>   		return -ENOMEM;
>   	memset(array, 0, num_entries * sizeof(struct amdgpu_bo_list_entry));
> @@ -148,7 +148,7 @@ static int amdgpu_bo_list_set(struct amdgpu_device *adev,
>   	for (i = 0; i < list->num_entries; ++i)
>   		amdgpu_bo_unref(&list->array[i].robj);
>   
> -	drm_free_large(list->array);
> +	kvfree(list->array);
>   
>   	list->gds_obj = gds_obj;
>   	list->gws_obj = gws_obj;
> @@ -163,7 +163,7 @@ static int amdgpu_bo_list_set(struct amdgpu_device *adev,
>   error_free:
>   	while (i--)
>   		amdgpu_bo_unref(&array[i].robj);
> -	drm_free_large(array);
> +	kvfree(array);
>   	return r;
>   }
>   
> @@ -224,7 +224,7 @@ void amdgpu_bo_list_free(struct amdgpu_bo_list *list)
>   		amdgpu_bo_unref(&list->array[i].robj);
>   
>   	mutex_destroy(&list->lock);
> -	drm_free_large(list->array);
> +	kvfree(list->array);
>   	kfree(list);
>   }
>   
> @@ -244,8 +244,8 @@ int amdgpu_bo_list_ioctl(struct drm_device *dev, void *data,
>   
>   	int r;
>   
> -	info = drm_malloc_ab(args->in.bo_number,
> -			     sizeof(struct drm_amdgpu_bo_list_entry));
> +	info = kvmalloc_array(args->in.bo_number,
> +			     sizeof(struct drm_amdgpu_bo_list_entry), GFP_KERNEL);
>   	if (!info)
>   		return -ENOMEM;
>   
> @@ -311,11 +311,11 @@ int amdgpu_bo_list_ioctl(struct drm_device *dev, void *data,
>   
>   	memset(args, 0, sizeof(*args));
>   	args->out.list_handle = handle;
> -	drm_free_large(info);
> +	kvfree(info);
>   
>   	return 0;
>   
>   error_free:
> -	drm_free_large(info);
> +	kvfree(info);
>   	return r;
>   }
> diff --git a/drivers/gpu/drm/amd/amdgpu/amdgpu_cs.c b/drivers/gpu/drm/amd/amdgpu/amdgpu_cs.c
> index 4e6b9501ab0a..5b3e0f63a115 100644
> --- a/drivers/gpu/drm/amd/amdgpu/amdgpu_cs.c
> +++ b/drivers/gpu/drm/amd/amdgpu/amdgpu_cs.c
> @@ -194,7 +194,7 @@ int amdgpu_cs_parser_init(struct amdgpu_cs_parser *p, void *data)
>   		size = p->chunks[i].length_dw;
>   		cdata = (void __user *)(uintptr_t)user_chunk.chunk_data;
>   
> -		p->chunks[i].kdata = drm_malloc_ab(size, sizeof(uint32_t));
> +		p->chunks[i].kdata = kvmalloc_array(size, sizeof(uint32_t), GFP_KERNEL);
>   		if (p->chunks[i].kdata == NULL) {
>   			ret = -ENOMEM;
>   			i--;
> @@ -247,7 +247,7 @@ int amdgpu_cs_parser_init(struct amdgpu_cs_parser *p, void *data)
>   	i = p->nchunks - 1;
>   free_partial_kdata:
>   	for (; i >= 0; i--)
> -		drm_free_large(p->chunks[i].kdata);
> +		kvfree(p->chunks[i].kdata);
>   	kfree(p->chunks);
>   	p->chunks = NULL;
>   	p->nchunks = 0;
> @@ -505,7 +505,7 @@ static int amdgpu_cs_list_validate(struct amdgpu_cs_parser *p,
>   			return r;
>   
>   		if (binding_userptr) {
> -			drm_free_large(lobj->user_pages);
> +			kvfree(lobj->user_pages);
>   			lobj->user_pages = NULL;
>   		}
>   	}
> @@ -571,7 +571,7 @@ static int amdgpu_cs_parser_bos(struct amdgpu_cs_parser *p,
>   				release_pages(e->user_pages,
>   					      e->robj->tbo.ttm->num_pages,
>   					      false);
> -				drm_free_large(e->user_pages);
> +				kvfree(e->user_pages);
>   				e->user_pages = NULL;
>   			}
>   
> @@ -601,8 +601,9 @@ static int amdgpu_cs_parser_bos(struct amdgpu_cs_parser *p,
>   		list_for_each_entry(e, &need_pages, tv.head) {
>   			struct ttm_tt *ttm = e->robj->tbo.ttm;
>   
> -			e->user_pages = drm_calloc_large(ttm->num_pages,
> -							 sizeof(struct page*));
> +			e->user_pages = kvmalloc_array(ttm->num_pages,
> +							 sizeof(struct page*),
> +							 GFP_KERNEL | __GFP_ZERO);
>   			if (!e->user_pages) {
>   				r = -ENOMEM;
>   				DRM_ERROR("calloc failure in %s\n", __func__);
> @@ -612,7 +613,7 @@ static int amdgpu_cs_parser_bos(struct amdgpu_cs_parser *p,
>   			r = amdgpu_ttm_tt_get_user_pages(ttm, e->user_pages);
>   			if (r) {
>   				DRM_ERROR("amdgpu_ttm_tt_get_user_pages failed.\n");
> -				drm_free_large(e->user_pages);
> +				kvfree(e->user_pages);
>   				e->user_pages = NULL;
>   				goto error_free_pages;
>   			}
> @@ -708,7 +709,7 @@ static int amdgpu_cs_parser_bos(struct amdgpu_cs_parser *p,
>   			release_pages(e->user_pages,
>   				      e->robj->tbo.ttm->num_pages,
>   				      false);
> -			drm_free_large(e->user_pages);
> +			kvfree(e->user_pages);
>   		}
>   	}
>   
> @@ -761,7 +762,7 @@ static void amdgpu_cs_parser_fini(struct amdgpu_cs_parser *parser, int error, bo
>   		amdgpu_bo_list_put(parser->bo_list);
>   
>   	for (i = 0; i < parser->nchunks; i++)
> -		drm_free_large(parser->chunks[i].kdata);
> +		kvfree(parser->chunks[i].kdata);
>   	kfree(parser->chunks);
>   	if (parser->job)
>   		amdgpu_job_free(parser->job);
> diff --git a/drivers/gpu/drm/amd/amdgpu/amdgpu_vm.c b/drivers/gpu/drm/amd/amdgpu/amdgpu_vm.c
> index 07ff3b1514f1..749a6cde7985 100644
> --- a/drivers/gpu/drm/amd/amdgpu/amdgpu_vm.c
> +++ b/drivers/gpu/drm/amd/amdgpu/amdgpu_vm.c
> @@ -279,8 +279,9 @@ static int amdgpu_vm_alloc_levels(struct amdgpu_device *adev,
>   	if (!parent->entries) {
>   		unsigned num_entries = amdgpu_vm_num_entries(adev, level);
>   
> -		parent->entries = drm_calloc_large(num_entries,
> -						   sizeof(struct amdgpu_vm_pt));
> +		parent->entries = kvmalloc_array(num_entries,
> +						   sizeof(struct amdgpu_vm_pt),
> +						   GFP_KERNEL | __GFP_ZERO);
>   		if (!parent->entries)
>   			return -ENOMEM;
>   		memset(parent->entries, 0 , sizeof(struct amdgpu_vm_pt));
> @@ -2198,7 +2199,7 @@ static void amdgpu_vm_free_levels(struct amdgpu_vm_pt *level)
>   		for (i = 0; i <= level->last_entry_used; i++)
>   			amdgpu_vm_free_levels(&level->entries[i]);
>   
> -	drm_free_large(level->entries);
> +	kvfree(level->entries);
>   }
>   
>   /**
> diff --git a/drivers/gpu/drm/drm_gem.c b/drivers/gpu/drm/drm_gem.c
> index b1e28c944637..8dc11064253d 100644
> --- a/drivers/gpu/drm/drm_gem.c
> +++ b/drivers/gpu/drm/drm_gem.c
> @@ -521,7 +521,7 @@ struct page **drm_gem_get_pages(struct drm_gem_object *obj)
>   
>   	npages = obj->size >> PAGE_SHIFT;
>   
> -	pages = drm_malloc_ab(npages, sizeof(struct page *));
> +	pages = kvmalloc_array(npages, sizeof(struct page *), GFP_KERNEL);
>   	if (pages == NULL)
>   		return ERR_PTR(-ENOMEM);
>   
> @@ -546,7 +546,7 @@ struct page **drm_gem_get_pages(struct drm_gem_object *obj)
>   	while (i--)
>   		put_page(pages[i]);
>   
> -	drm_free_large(pages);
> +	kvfree(pages);
>   	return ERR_CAST(p);
>   }
>   EXPORT_SYMBOL(drm_gem_get_pages);
> @@ -582,7 +582,7 @@ void drm_gem_put_pages(struct drm_gem_object *obj, struct page **pages,
>   		put_page(pages[i]);
>   	}
>   
> -	drm_free_large(pages);
> +	kvfree(pages);
>   }
>   EXPORT_SYMBOL(drm_gem_put_pages);
>   
> diff --git a/drivers/gpu/drm/etnaviv/etnaviv_gem.c b/drivers/gpu/drm/etnaviv/etnaviv_gem.c
> index fd56f92f3469..d6fb724fc3cc 100644
> --- a/drivers/gpu/drm/etnaviv/etnaviv_gem.c
> +++ b/drivers/gpu/drm/etnaviv/etnaviv_gem.c
> @@ -748,7 +748,7 @@ static struct page **etnaviv_gem_userptr_do_get_pages(
>   	uintptr_t ptr;
>   	unsigned int flags = 0;
>   
> -	pvec = drm_malloc_ab(npages, sizeof(struct page *));
> +	pvec = kvmalloc_array(npages, sizeof(struct page *), GFP_KERNEL);
>   	if (!pvec)
>   		return ERR_PTR(-ENOMEM);
>   
> @@ -772,7 +772,7 @@ static struct page **etnaviv_gem_userptr_do_get_pages(
>   
>   	if (ret < 0) {
>   		release_pages(pvec, pinned, 0);
> -		drm_free_large(pvec);
> +		kvfree(pvec);
>   		return ERR_PTR(ret);
>   	}
>   
> @@ -823,7 +823,7 @@ static int etnaviv_gem_userptr_get_pages(struct etnaviv_gem_object *etnaviv_obj)
>   	mm = get_task_mm(etnaviv_obj->userptr.task);
>   	pinned = 0;
>   	if (mm == current->mm) {
> -		pvec = drm_malloc_ab(npages, sizeof(struct page *));
> +		pvec = kvmalloc_array(npages, sizeof(struct page *), GFP_KERNEL);
>   		if (!pvec) {
>   			mmput(mm);
>   			return -ENOMEM;
> @@ -832,7 +832,7 @@ static int etnaviv_gem_userptr_get_pages(struct etnaviv_gem_object *etnaviv_obj)
>   		pinned = __get_user_pages_fast(etnaviv_obj->userptr.ptr, npages,
>   					       !etnaviv_obj->userptr.ro, pvec);
>   		if (pinned < 0) {
> -			drm_free_large(pvec);
> +			kvfree(pvec);
>   			mmput(mm);
>   			return pinned;
>   		}
> @@ -845,7 +845,7 @@ static int etnaviv_gem_userptr_get_pages(struct etnaviv_gem_object *etnaviv_obj)
>   	}
>   
>   	release_pages(pvec, pinned, 0);
> -	drm_free_large(pvec);
> +	kvfree(pvec);
>   
>   	work = kmalloc(sizeof(*work), GFP_KERNEL);
>   	if (!work) {
> @@ -879,7 +879,7 @@ static void etnaviv_gem_userptr_release(struct etnaviv_gem_object *etnaviv_obj)
>   		int npages = etnaviv_obj->base.size >> PAGE_SHIFT;
>   
>   		release_pages(etnaviv_obj->pages, npages, 0);
> -		drm_free_large(etnaviv_obj->pages);
> +		kvfree(etnaviv_obj->pages);
>   	}
>   	put_task_struct(etnaviv_obj->userptr.task);
>   }
> diff --git a/drivers/gpu/drm/etnaviv/etnaviv_gem_prime.c b/drivers/gpu/drm/etnaviv/etnaviv_gem_prime.c
> index abed6f781281..e5da4f2300ba 100644
> --- a/drivers/gpu/drm/etnaviv/etnaviv_gem_prime.c
> +++ b/drivers/gpu/drm/etnaviv/etnaviv_gem_prime.c
> @@ -87,7 +87,7 @@ static void etnaviv_gem_prime_release(struct etnaviv_gem_object *etnaviv_obj)
>   	 * ours, just free the array we allocated:
>   	 */
>   	if (etnaviv_obj->pages)
> -		drm_free_large(etnaviv_obj->pages);
> +		kvfree(etnaviv_obj->pages);
>   
>   	drm_prime_gem_destroy(&etnaviv_obj->base, etnaviv_obj->sgt);
>   }
> @@ -128,7 +128,7 @@ struct drm_gem_object *etnaviv_gem_prime_import_sg_table(struct drm_device *dev,
>   	npages = size / PAGE_SIZE;
>   
>   	etnaviv_obj->sgt = sgt;
> -	etnaviv_obj->pages = drm_malloc_ab(npages, sizeof(struct page *));
> +	etnaviv_obj->pages = kvmalloc_array(npages, sizeof(struct page *), GFP_KERNEL);
>   	if (!etnaviv_obj->pages) {
>   		ret = -ENOMEM;
>   		goto fail;
> diff --git a/drivers/gpu/drm/etnaviv/etnaviv_gem_submit.c b/drivers/gpu/drm/etnaviv/etnaviv_gem_submit.c
> index de80ee1b71df..ee7069e93eda 100644
> --- a/drivers/gpu/drm/etnaviv/etnaviv_gem_submit.c
> +++ b/drivers/gpu/drm/etnaviv/etnaviv_gem_submit.c
> @@ -345,9 +345,9 @@ int etnaviv_ioctl_gem_submit(struct drm_device *dev, void *data,
>   	 * Copy the command submission and bo array to kernel space in
>   	 * one go, and do this outside of any locks.
>   	 */
> -	bos = drm_malloc_ab(args->nr_bos, sizeof(*bos));
> -	relocs = drm_malloc_ab(args->nr_relocs, sizeof(*relocs));
> -	stream = drm_malloc_ab(1, args->stream_size);
> +	bos = kvmalloc_array(args->nr_bos, sizeof(*bos), GFP_KERNEL);
> +	relocs = kvmalloc_array(args->nr_relocs, sizeof(*relocs), GFP_KERNEL);
> +	stream = kvmalloc_array(1, args->stream_size, GFP_KERNEL);
>   	cmdbuf = etnaviv_cmdbuf_new(gpu->cmdbuf_suballoc,
>   				    ALIGN(args->stream_size, 8) + 8,
>   				    args->nr_bos);
> @@ -489,11 +489,11 @@ int etnaviv_ioctl_gem_submit(struct drm_device *dev, void *data,
>   	if (cmdbuf)
>   		etnaviv_cmdbuf_free(cmdbuf);
>   	if (stream)
> -		drm_free_large(stream);
> +		kvfree(stream);
>   	if (bos)
> -		drm_free_large(bos);
> +		kvfree(bos);
>   	if (relocs)
> -		drm_free_large(relocs);
> +		kvfree(relocs);
>   
>   	return ret;
>   }
> diff --git a/drivers/gpu/drm/exynos/exynos_drm_gem.c b/drivers/gpu/drm/exynos/exynos_drm_gem.c
> index 55a1579d11b3..c23479be4850 100644
> --- a/drivers/gpu/drm/exynos/exynos_drm_gem.c
> +++ b/drivers/gpu/drm/exynos/exynos_drm_gem.c
> @@ -59,7 +59,8 @@ static int exynos_drm_alloc_buf(struct exynos_drm_gem *exynos_gem)
>   
>   	nr_pages = exynos_gem->size >> PAGE_SHIFT;
>   
> -	exynos_gem->pages = drm_calloc_large(nr_pages, sizeof(struct page *));
> +	exynos_gem->pages = kvmalloc_array(nr_pages, sizeof(struct page *),
> +			GFP_KERNEL | __GFP_ZERO);
>   	if (!exynos_gem->pages) {
>   		DRM_ERROR("failed to allocate pages.\n");
>   		return -ENOMEM;
> @@ -101,7 +102,7 @@ static int exynos_drm_alloc_buf(struct exynos_drm_gem *exynos_gem)
>   	dma_free_attrs(to_dma_dev(dev), exynos_gem->size, exynos_gem->cookie,
>   		       exynos_gem->dma_addr, exynos_gem->dma_attrs);
>   err_free:
> -	drm_free_large(exynos_gem->pages);
> +	kvfree(exynos_gem->pages);
>   
>   	return ret;
>   }
> @@ -122,7 +123,7 @@ static void exynos_drm_free_buf(struct exynos_drm_gem *exynos_gem)
>   			(dma_addr_t)exynos_gem->dma_addr,
>   			exynos_gem->dma_attrs);
>   
> -	drm_free_large(exynos_gem->pages);
> +	kvfree(exynos_gem->pages);
>   }
>   
>   static int exynos_drm_gem_handle_create(struct drm_gem_object *obj,
> @@ -559,7 +560,7 @@ exynos_drm_gem_prime_import_sg_table(struct drm_device *dev,
>   	exynos_gem->dma_addr = sg_dma_address(sgt->sgl);
>   
>   	npages = exynos_gem->size >> PAGE_SHIFT;
> -	exynos_gem->pages = drm_malloc_ab(npages, sizeof(struct page *));
> +	exynos_gem->pages = kvmalloc_array(npages, sizeof(struct page *), GFP_KERNEL);
>   	if (!exynos_gem->pages) {
>   		ret = -ENOMEM;
>   		goto err;
> @@ -588,7 +589,7 @@ exynos_drm_gem_prime_import_sg_table(struct drm_device *dev,
>   	return &exynos_gem->base;
>   
>   err_free_large:
> -	drm_free_large(exynos_gem->pages);
> +	kvfree(exynos_gem->pages);
>   err:
>   	drm_gem_object_release(&exynos_gem->base);
>   	kfree(exynos_gem);
> diff --git a/drivers/gpu/drm/i915/i915_debugfs.c b/drivers/gpu/drm/i915/i915_debugfs.c
> index bd9abef40c66..c8f3c0cc79fb 100644
> --- a/drivers/gpu/drm/i915/i915_debugfs.c
> +++ b/drivers/gpu/drm/i915/i915_debugfs.c
> @@ -229,7 +229,7 @@ static int i915_gem_stolen_list_info(struct seq_file *m, void *data)
>   	int ret;
>   
>   	total = READ_ONCE(dev_priv->mm.object_count);
> -	objects = drm_malloc_ab(total, sizeof(*objects));
> +	objects = kvmalloc_array(total, sizeof(*objects), GFP_KERNEL);
>   	if (!objects)
>   		return -ENOMEM;
>   
> @@ -274,7 +274,7 @@ static int i915_gem_stolen_list_info(struct seq_file *m, void *data)
>   
>   	mutex_unlock(&dev->struct_mutex);
>   out:
> -	drm_free_large(objects);
> +	kvfree(objects);
>   	return ret;
>   }
>   
> diff --git a/drivers/gpu/drm/i915/i915_gem.c b/drivers/gpu/drm/i915/i915_gem.c
> index 0c1cbe98c994..aa790a6d38e2 100644
> --- a/drivers/gpu/drm/i915/i915_gem.c
> +++ b/drivers/gpu/drm/i915/i915_gem.c
> @@ -2556,7 +2556,7 @@ static void *i915_gem_object_map(const struct drm_i915_gem_object *obj,
>   
>   	if (n_pages > ARRAY_SIZE(stack_pages)) {
>   		/* Too big for stack -- allocate temporary array instead */
> -		pages = drm_malloc_gfp(n_pages, sizeof(*pages), GFP_TEMPORARY);
> +		pages = kvmalloc_array(n_pages, sizeof(*pages), GFP_TEMPORARY);
>   		if (!pages)
>   			return NULL;
>   	}
> @@ -2578,7 +2578,7 @@ static void *i915_gem_object_map(const struct drm_i915_gem_object *obj,
>   	addr = vmap(pages, n_pages, 0, pgprot);
>   
>   	if (pages != stack_pages)
> -		drm_free_large(pages);
> +		kvfree(pages);
>   
>   	return addr;
>   }
> diff --git a/drivers/gpu/drm/i915/i915_gem_execbuffer.c b/drivers/gpu/drm/i915/i915_gem_execbuffer.c
> index af1965774e7b..04211c970b9f 100644
> --- a/drivers/gpu/drm/i915/i915_gem_execbuffer.c
> +++ b/drivers/gpu/drm/i915/i915_gem_execbuffer.c
> @@ -1019,11 +1019,11 @@ i915_gem_execbuffer_relocate_slow(struct drm_device *dev,
>   	for (i = 0; i < count; i++)
>   		total += exec[i].relocation_count;
>   
> -	reloc_offset = drm_malloc_ab(count, sizeof(*reloc_offset));
> -	reloc = drm_malloc_ab(total, sizeof(*reloc));
> +	reloc_offset = kvmalloc_array(count, sizeof(*reloc_offset), GFP_KERNEL);
> +	reloc = kvmalloc_array(total, sizeof(*reloc), GFP_KERNEL);
>   	if (reloc == NULL || reloc_offset == NULL) {
> -		drm_free_large(reloc);
> -		drm_free_large(reloc_offset);
> +		kvfree(reloc);
> +		kvfree(reloc_offset);
>   		mutex_lock(&dev->struct_mutex);
>   		return -ENOMEM;
>   	}
> @@ -1099,8 +1099,8 @@ i915_gem_execbuffer_relocate_slow(struct drm_device *dev,
>   	 */
>   
>   err:
> -	drm_free_large(reloc);
> -	drm_free_large(reloc_offset);
> +	kvfree(reloc);
> +	kvfree(reloc_offset);
>   	return ret;
>   }
>   
> @@ -1871,13 +1871,13 @@ i915_gem_execbuffer(struct drm_device *dev, void *data,
>   	}
>   
>   	/* Copy in the exec list from userland */
> -	exec_list = drm_malloc_ab(sizeof(*exec_list), args->buffer_count);
> -	exec2_list = drm_malloc_ab(sizeof(*exec2_list), args->buffer_count);
> +	exec_list = kvmalloc_array(sizeof(*exec_list), args->buffer_count, GFP_KERNEL);
> +	exec2_list = kvmalloc_array(sizeof(*exec2_list), args->buffer_count, GFP_KERNEL);
>   	if (exec_list == NULL || exec2_list == NULL) {
>   		DRM_DEBUG("Failed to allocate exec list for %d buffers\n",
>   			  args->buffer_count);
> -		drm_free_large(exec_list);
> -		drm_free_large(exec2_list);
> +		kvfree(exec_list);
> +		kvfree(exec2_list);
>   		return -ENOMEM;
>   	}
>   	ret = copy_from_user(exec_list,
> @@ -1886,8 +1886,8 @@ i915_gem_execbuffer(struct drm_device *dev, void *data,
>   	if (ret != 0) {
>   		DRM_DEBUG("copy %d exec entries failed %d\n",
>   			  args->buffer_count, ret);
> -		drm_free_large(exec_list);
> -		drm_free_large(exec2_list);
> +		kvfree(exec_list);
> +		kvfree(exec2_list);
>   		return -EFAULT;
>   	}
>   
> @@ -1936,8 +1936,8 @@ i915_gem_execbuffer(struct drm_device *dev, void *data,
>   		}
>   	}
>   
> -	drm_free_large(exec_list);
> -	drm_free_large(exec2_list);
> +	kvfree(exec_list);
> +	kvfree(exec2_list);
>   	return ret;
>   }
>   
> @@ -1955,7 +1955,7 @@ i915_gem_execbuffer2(struct drm_device *dev, void *data,
>   		return -EINVAL;
>   	}
>   
> -	exec2_list = drm_malloc_gfp(args->buffer_count,
> +	exec2_list = kvmalloc_array(args->buffer_count,
>   				    sizeof(*exec2_list),
>   				    GFP_TEMPORARY);
>   	if (exec2_list == NULL) {
> @@ -1969,7 +1969,7 @@ i915_gem_execbuffer2(struct drm_device *dev, void *data,
>   	if (ret != 0) {
>   		DRM_DEBUG("copy %d exec entries failed %d\n",
>   			  args->buffer_count, ret);
> -		drm_free_large(exec2_list);
> +		kvfree(exec2_list);
>   		return -EFAULT;
>   	}
>   
> @@ -1996,6 +1996,6 @@ i915_gem_execbuffer2(struct drm_device *dev, void *data,
>   		}
>   	}
>   
> -	drm_free_large(exec2_list);
> +	kvfree(exec2_list);
>   	return ret;
>   }
> diff --git a/drivers/gpu/drm/i915/i915_gem_gtt.c b/drivers/gpu/drm/i915/i915_gem_gtt.c
> index bc3c63e92c16..899427863547 100644
> --- a/drivers/gpu/drm/i915/i915_gem_gtt.c
> +++ b/drivers/gpu/drm/i915/i915_gem_gtt.c
> @@ -3114,7 +3114,7 @@ intel_rotate_pages(struct intel_rotation_info *rot_info,
>   	int ret = -ENOMEM;
>   
>   	/* Allocate a temporary list of source pages for random access. */
> -	page_addr_list = drm_malloc_gfp(n_pages,
> +	page_addr_list = kvmalloc_array(n_pages,
>   					sizeof(dma_addr_t),
>   					GFP_TEMPORARY);
>   	if (!page_addr_list)
> @@ -3147,14 +3147,14 @@ intel_rotate_pages(struct intel_rotation_info *rot_info,
>   	DRM_DEBUG_KMS("Created rotated page mapping for object size %zu (%ux%u tiles, %u pages)\n",
>   		      obj->base.size, rot_info->plane[0].width, rot_info->plane[0].height, size);
>   
> -	drm_free_large(page_addr_list);
> +	kvfree(page_addr_list);
>   
>   	return st;
>   
>   err_sg_alloc:
>   	kfree(st);
>   err_st_alloc:
> -	drm_free_large(page_addr_list);
> +	kvfree(page_addr_list);
>   
>   	DRM_DEBUG_KMS("Failed to create rotated mapping for object size %zu! (%ux%u tiles, %u pages)\n",
>   		      obj->base.size, rot_info->plane[0].width, rot_info->plane[0].height, size);
> diff --git a/drivers/gpu/drm/i915/i915_gem_userptr.c b/drivers/gpu/drm/i915/i915_gem_userptr.c
> index 58ccf8b8ca1c..1a0ce1dc68f5 100644
> --- a/drivers/gpu/drm/i915/i915_gem_userptr.c
> +++ b/drivers/gpu/drm/i915/i915_gem_userptr.c
> @@ -507,7 +507,7 @@ __i915_gem_userptr_get_pages_worker(struct work_struct *_work)
>   	ret = -ENOMEM;
>   	pinned = 0;
>   
> -	pvec = drm_malloc_gfp(npages, sizeof(struct page *), GFP_TEMPORARY);
> +	pvec = kvmalloc_array(npages, sizeof(struct page *), GFP_TEMPORARY);
>   	if (pvec != NULL) {
>   		struct mm_struct *mm = obj->userptr.mm->mm;
>   		unsigned int flags = 0;
> @@ -555,7 +555,7 @@ __i915_gem_userptr_get_pages_worker(struct work_struct *_work)
>   	mutex_unlock(&obj->mm.lock);
>   
>   	release_pages(pvec, pinned, 0);
> -	drm_free_large(pvec);
> +	kvfree(pvec);
>   
>   	i915_gem_object_put(obj);
>   	put_task_struct(work->task);
> @@ -642,7 +642,7 @@ i915_gem_userptr_get_pages(struct drm_i915_gem_object *obj)
>   	pinned = 0;
>   
>   	if (mm == current->mm) {
> -		pvec = drm_malloc_gfp(num_pages, sizeof(struct page *),
> +		pvec = kvmalloc_array(num_pages, sizeof(struct page *),
>   				      GFP_TEMPORARY |
>   				      __GFP_NORETRY |
>   				      __GFP_NOWARN);
> @@ -669,7 +669,7 @@ i915_gem_userptr_get_pages(struct drm_i915_gem_object *obj)
>   
>   	if (IS_ERR(pages))
>   		release_pages(pvec, pinned, 0);
> -	drm_free_large(pvec);
> +	kvfree(pvec);
>   
>   	return pages;
>   }
> diff --git a/drivers/gpu/drm/i915/selftests/intel_breadcrumbs.c b/drivers/gpu/drm/i915/selftests/intel_breadcrumbs.c
> index 19860a372d90..7276194c04f7 100644
> --- a/drivers/gpu/drm/i915/selftests/intel_breadcrumbs.c
> +++ b/drivers/gpu/drm/i915/selftests/intel_breadcrumbs.c
> @@ -117,7 +117,7 @@ static int igt_random_insert_remove(void *arg)
>   
>   	mock_engine_reset(engine);
>   
> -	waiters = drm_malloc_gfp(count, sizeof(*waiters), GFP_TEMPORARY);
> +	waiters = kvmalloc_array(count, sizeof(*waiters), GFP_TEMPORARY);
>   	if (!waiters)
>   		goto out_engines;
>   
> @@ -169,7 +169,7 @@ static int igt_random_insert_remove(void *arg)
>   out_bitmap:
>   	kfree(bitmap);
>   out_waiters:
> -	drm_free_large(waiters);
> +	kvfree(waiters);
>   out_engines:
>   	mock_engine_flush(engine);
>   	return err;
> @@ -187,7 +187,7 @@ static int igt_insert_complete(void *arg)
>   
>   	mock_engine_reset(engine);
>   
> -	waiters = drm_malloc_gfp(count, sizeof(*waiters), GFP_TEMPORARY);
> +	waiters = kvmalloc_array(count, sizeof(*waiters), GFP_TEMPORARY);
>   	if (!waiters)
>   		goto out_engines;
>   
> @@ -254,7 +254,7 @@ static int igt_insert_complete(void *arg)
>   out_bitmap:
>   	kfree(bitmap);
>   out_waiters:
> -	drm_free_large(waiters);
> +	kvfree(waiters);
>   out_engines:
>   	mock_engine_flush(engine);
>   	return err;
> @@ -368,7 +368,7 @@ static int igt_wakeup(void *arg)
>   
>   	mock_engine_reset(engine);
>   
> -	waiters = drm_malloc_gfp(count, sizeof(*waiters), GFP_TEMPORARY);
> +	waiters = kvmalloc_array(count, sizeof(*waiters), GFP_TEMPORARY);
>   	if (!waiters)
>   		goto out_engines;
>   
> @@ -454,7 +454,7 @@ static int igt_wakeup(void *arg)
>   		put_task_struct(waiters[n].tsk);
>   	}
>   
> -	drm_free_large(waiters);
> +	kvfree(waiters);
>   out_engines:
>   	mock_engine_flush(engine);
>   	return err;
> diff --git a/drivers/gpu/drm/msm/msm_gem.c b/drivers/gpu/drm/msm/msm_gem.c
> index 68e509b3b9e4..465dab942afa 100644
> --- a/drivers/gpu/drm/msm/msm_gem.c
> +++ b/drivers/gpu/drm/msm/msm_gem.c
> @@ -50,13 +50,13 @@ static struct page **get_pages_vram(struct drm_gem_object *obj,
>   	struct page **p;
>   	int ret, i;
>   
> -	p = drm_malloc_ab(npages, sizeof(struct page *));
> +	p = kvmalloc_array(npages, sizeof(struct page *), GFP_KERNEL);
>   	if (!p)
>   		return ERR_PTR(-ENOMEM);
>   
>   	ret = drm_mm_insert_node(&priv->vram.mm, msm_obj->vram_node, npages);
>   	if (ret) {
> -		drm_free_large(p);
> +		kvfree(p);
>   		return ERR_PTR(ret);
>   	}
>   
> @@ -127,7 +127,7 @@ static void put_pages(struct drm_gem_object *obj)
>   			drm_gem_put_pages(obj, msm_obj->pages, true, false);
>   		else {
>   			drm_mm_remove_node(msm_obj->vram_node);
> -			drm_free_large(msm_obj->pages);
> +			kvfree(msm_obj->pages);
>   		}
>   
>   		msm_obj->pages = NULL;
> @@ -707,7 +707,7 @@ void msm_gem_free_object(struct drm_gem_object *obj)
>   		 * ours, just free the array we allocated:
>   		 */
>   		if (msm_obj->pages)
> -			drm_free_large(msm_obj->pages);
> +			kvfree(msm_obj->pages);
>   
>   		drm_prime_gem_destroy(obj, msm_obj->sgt);
>   	} else {
> @@ -863,7 +863,7 @@ struct drm_gem_object *msm_gem_import(struct drm_device *dev,
>   
>   	msm_obj = to_msm_bo(obj);
>   	msm_obj->sgt = sgt;
> -	msm_obj->pages = drm_malloc_ab(npages, sizeof(struct page *));
> +	msm_obj->pages = kvmalloc_array(npages, sizeof(struct page *), GFP_KERNEL);
>   	if (!msm_obj->pages) {
>   		ret = -ENOMEM;
>   		goto fail;
> diff --git a/drivers/gpu/drm/radeon/radeon_cs.c b/drivers/gpu/drm/radeon/radeon_cs.c
> index 3ac671f6c8e1..00b22af70f5c 100644
> --- a/drivers/gpu/drm/radeon/radeon_cs.c
> +++ b/drivers/gpu/drm/radeon/radeon_cs.c
> @@ -87,7 +87,8 @@ static int radeon_cs_parser_relocs(struct radeon_cs_parser *p)
>   	p->dma_reloc_idx = 0;
>   	/* FIXME: we assume that each relocs use 4 dwords */
>   	p->nrelocs = chunk->length_dw / 4;
> -	p->relocs = drm_calloc_large(p->nrelocs, sizeof(struct radeon_bo_list));
> +	p->relocs = kvmalloc_array(p->nrelocs, sizeof(struct radeon_bo_list),
> +			GFP_KERNEL | __GFP_ZERO);
>   	if (p->relocs == NULL) {
>   		return -ENOMEM;
>   	}
> @@ -341,7 +342,7 @@ int radeon_cs_parser_init(struct radeon_cs_parser *p, void *data)
>   				continue;
>   		}
>   
> -		p->chunks[i].kdata = drm_malloc_ab(size, sizeof(uint32_t));
> +		p->chunks[i].kdata = kvmalloc_array(size, sizeof(uint32_t), GFP_KERNEL);
>   		size *= sizeof(uint32_t);
>   		if (p->chunks[i].kdata == NULL) {
>   			return -ENOMEM;
> @@ -440,10 +441,10 @@ static void radeon_cs_parser_fini(struct radeon_cs_parser *parser, int error, bo
>   		}
>   	}
>   	kfree(parser->track);
> -	drm_free_large(parser->relocs);
> -	drm_free_large(parser->vm_bos);
> +	kvfree(parser->relocs);
> +	kvfree(parser->vm_bos);
>   	for (i = 0; i < parser->nchunks; i++)
> -		drm_free_large(parser->chunks[i].kdata);
> +		kvfree(parser->chunks[i].kdata);
>   	kfree(parser->chunks);
>   	kfree(parser->chunks_array);
>   	radeon_ib_free(parser->rdev, &parser->ib);
> diff --git a/drivers/gpu/drm/radeon/radeon_gem.c b/drivers/gpu/drm/radeon/radeon_gem.c
> index dddb372de2b9..574bf7e6b118 100644
> --- a/drivers/gpu/drm/radeon/radeon_gem.c
> +++ b/drivers/gpu/drm/radeon/radeon_gem.c
> @@ -587,7 +587,7 @@ static void radeon_gem_va_update_vm(struct radeon_device *rdev,
>   	ttm_eu_backoff_reservation(&ticket, &list);
>   
>   error_free:
> -	drm_free_large(vm_bos);
> +	kvfree(vm_bos);
>   
>   	if (r && r != -ERESTARTSYS)
>   		DRM_ERROR("Couldn't update BO_VA (%d)\n", r);
> diff --git a/drivers/gpu/drm/radeon/radeon_ring.c b/drivers/gpu/drm/radeon/radeon_ring.c
> index 8c7872339c2a..84802b201bef 100644
> --- a/drivers/gpu/drm/radeon/radeon_ring.c
> +++ b/drivers/gpu/drm/radeon/radeon_ring.c
> @@ -314,7 +314,7 @@ unsigned radeon_ring_backup(struct radeon_device *rdev, struct radeon_ring *ring
>   	}
>   
>   	/* and then save the content of the ring */
> -	*data = drm_malloc_ab(size, sizeof(uint32_t));
> +	*data = kvmalloc_array(size, sizeof(uint32_t), GFP_KERNEL);
>   	if (!*data) {
>   		mutex_unlock(&rdev->ring_lock);
>   		return 0;
> @@ -356,7 +356,7 @@ int radeon_ring_restore(struct radeon_device *rdev, struct radeon_ring *ring,
>   	}
>   
>   	radeon_ring_unlock_commit(rdev, ring, false);
> -	drm_free_large(data);
> +	kvfree(data);
>   	return 0;
>   }
>   
> diff --git a/drivers/gpu/drm/radeon/radeon_vm.c b/drivers/gpu/drm/radeon/radeon_vm.c
> index a1358748cea5..5f68245579a3 100644
> --- a/drivers/gpu/drm/radeon/radeon_vm.c
> +++ b/drivers/gpu/drm/radeon/radeon_vm.c
> @@ -132,8 +132,8 @@ struct radeon_bo_list *radeon_vm_get_bos(struct radeon_device *rdev,
>   	struct radeon_bo_list *list;
>   	unsigned i, idx;
>   
> -	list = drm_malloc_ab(vm->max_pde_used + 2,
> -			     sizeof(struct radeon_bo_list));
> +	list = kvmalloc_array(vm->max_pde_used + 2,
> +			     sizeof(struct radeon_bo_list), GFP_KERNEL);
>   	if (!list)
>   		return NULL;
>   
> diff --git a/drivers/gpu/drm/ttm/ttm_tt.c b/drivers/gpu/drm/ttm/ttm_tt.c
> index 5260179d788a..8ebc8d3560c3 100644
> --- a/drivers/gpu/drm/ttm/ttm_tt.c
> +++ b/drivers/gpu/drm/ttm/ttm_tt.c
> @@ -39,7 +39,6 @@
>   #include <linux/slab.h>
>   #include <linux/export.h>
>   #include <drm/drm_cache.h>
> -#include <drm/drm_mem_util.h>
>   #include <drm/ttm/ttm_module.h>
>   #include <drm/ttm/ttm_bo_driver.h>
>   #include <drm/ttm/ttm_placement.h>
> @@ -53,14 +52,16 @@
>    */
>   static void ttm_tt_alloc_page_directory(struct ttm_tt *ttm)
>   {
> -	ttm->pages = drm_calloc_large(ttm->num_pages, sizeof(void*));
> +	ttm->pages = kvmalloc_array(ttm->num_pages, sizeof(void*),
> +			GFP_KERNEL | __GFP_ZERO);
>   }
>   
>   static void ttm_dma_tt_alloc_page_directory(struct ttm_dma_tt *ttm)
>   {
> -	ttm->ttm.pages = drm_calloc_large(ttm->ttm.num_pages,
> +	ttm->ttm.pages = kvmalloc_array(ttm->ttm.num_pages,
>   					  sizeof(*ttm->ttm.pages) +
> -					  sizeof(*ttm->dma_address));
> +					  sizeof(*ttm->dma_address),
> +					  GFP_KERNEL | __GFP_ZERO);
>   	ttm->dma_address = (void *) (ttm->ttm.pages + ttm->ttm.num_pages);
>   }
>   
> @@ -208,7 +209,7 @@ EXPORT_SYMBOL(ttm_tt_init);
>   
>   void ttm_tt_fini(struct ttm_tt *ttm)
>   {
> -	drm_free_large(ttm->pages);
> +	kvfree(ttm->pages);
>   	ttm->pages = NULL;
>   }
>   EXPORT_SYMBOL(ttm_tt_fini);
> @@ -243,7 +244,7 @@ void ttm_dma_tt_fini(struct ttm_dma_tt *ttm_dma)
>   {
>   	struct ttm_tt *ttm = &ttm_dma->ttm;
>   
> -	drm_free_large(ttm->pages);
> +	kvfree(ttm->pages);
>   	ttm->pages = NULL;
>   	ttm_dma->dma_address = NULL;
>   }
> diff --git a/drivers/gpu/drm/udl/udl_dmabuf.c b/drivers/gpu/drm/udl/udl_dmabuf.c
> index ed0e636243b2..2e031a894813 100644
> --- a/drivers/gpu/drm/udl/udl_dmabuf.c
> +++ b/drivers/gpu/drm/udl/udl_dmabuf.c
> @@ -228,7 +228,7 @@ static int udl_prime_create(struct drm_device *dev,
>   		return -ENOMEM;
>   
>   	obj->sg = sg;
> -	obj->pages = drm_malloc_ab(npages, sizeof(struct page *));
> +	obj->pages = kvmalloc_array(npages, sizeof(struct page *), GFP_KERNEL);
>   	if (obj->pages == NULL) {
>   		DRM_ERROR("obj pages is NULL %d\n", npages);
>   		return -ENOMEM;
> diff --git a/drivers/gpu/drm/udl/udl_gem.c b/drivers/gpu/drm/udl/udl_gem.c
> index 775c50e4f02c..db9ceceba30e 100644
> --- a/drivers/gpu/drm/udl/udl_gem.c
> +++ b/drivers/gpu/drm/udl/udl_gem.c
> @@ -146,7 +146,7 @@ int udl_gem_get_pages(struct udl_gem_object *obj)
>   void udl_gem_put_pages(struct udl_gem_object *obj)
>   {
>   	if (obj->base.import_attach) {
> -		drm_free_large(obj->pages);
> +		kvfree(obj->pages);
>   		obj->pages = NULL;
>   		return;
>   	}
> diff --git a/drivers/gpu/drm/vc4/vc4_gem.c b/drivers/gpu/drm/vc4/vc4_gem.c
> index e9c381c42139..bf466674ca9b 100644
> --- a/drivers/gpu/drm/vc4/vc4_gem.c
> +++ b/drivers/gpu/drm/vc4/vc4_gem.c
> @@ -545,14 +545,15 @@ vc4_cl_lookup_bos(struct drm_device *dev,
>   		return -EINVAL;
>   	}
>   
> -	exec->bo = drm_calloc_large(exec->bo_count,
> -				    sizeof(struct drm_gem_cma_object *));
> +	exec->bo = kvmalloc_array(exec->bo_count,
> +				    sizeof(struct drm_gem_cma_object *),
> +				    GFP_KERNEL | __GFP_ZERO);
>   	if (!exec->bo) {
>   		DRM_ERROR("Failed to allocate validated BO pointers\n");
>   		return -ENOMEM;
>   	}
>   
> -	handles = drm_malloc_ab(exec->bo_count, sizeof(uint32_t));
> +	handles = kvmalloc_array(exec->bo_count, sizeof(uint32_t), GFP_KERNEL);
>   	if (!handles) {
>   		ret = -ENOMEM;
>   		DRM_ERROR("Failed to allocate incoming GEM handles\n");
> @@ -584,7 +585,7 @@ vc4_cl_lookup_bos(struct drm_device *dev,
>   	spin_unlock(&file_priv->table_lock);
>   
>   fail:
> -	drm_free_large(handles);
> +	kvfree(handles);
>   	return ret;
>   }
>   
> @@ -622,7 +623,7 @@ vc4_get_bcl(struct drm_device *dev, struct vc4_exec_info *exec)
>   	 * read the contents back for validation, and I think the
>   	 * bo->vaddr is uncached access.
>   	 */
> -	temp = drm_malloc_ab(temp_size, 1);
> +	temp = kvmalloc_array(temp_size, 1, GFP_KERNEL);
>   	if (!temp) {
>   		DRM_ERROR("Failed to allocate storage for copying "
>   			  "in bin/render CLs.\n");
> @@ -697,7 +698,7 @@ vc4_get_bcl(struct drm_device *dev, struct vc4_exec_info *exec)
>   	ret = vc4_wait_for_seqno(dev, exec->bin_dep_seqno, ~0ull, true);
>   
>   fail:
> -	drm_free_large(temp);
> +	kvfree(temp);
>   	return ret;
>   }
>   
> @@ -710,7 +711,7 @@ vc4_complete_exec(struct drm_device *dev, struct vc4_exec_info *exec)
>   	if (exec->bo) {
>   		for (i = 0; i < exec->bo_count; i++)
>   			drm_gem_object_unreference_unlocked(&exec->bo[i]->base);
> -		drm_free_large(exec->bo);
> +		kvfree(exec->bo);
>   	}
>   
>   	while (!list_empty(&exec->unref_list)) {
> diff --git a/drivers/gpu/drm/virtio/virtgpu_ioctl.c b/drivers/gpu/drm/virtio/virtgpu_ioctl.c
> index 61f3a963af95..6ed4bfc9b82b 100644
> --- a/drivers/gpu/drm/virtio/virtgpu_ioctl.c
> +++ b/drivers/gpu/drm/virtio/virtgpu_ioctl.c
> @@ -119,13 +119,14 @@ static int virtio_gpu_execbuffer_ioctl(struct drm_device *dev, void *data,
>   	INIT_LIST_HEAD(&validate_list);
>   	if (exbuf->num_bo_handles) {
>   
> -		bo_handles = drm_malloc_ab(exbuf->num_bo_handles,
> -					   sizeof(uint32_t));
> -		buflist = drm_calloc_large(exbuf->num_bo_handles,
> -					   sizeof(struct ttm_validate_buffer));
> +		bo_handles = kvmalloc_array(exbuf->num_bo_handles,
> +					   sizeof(uint32_t), GFP_KERNEL);
> +		buflist = kvmalloc_array(exbuf->num_bo_handles,
> +					   sizeof(struct ttm_validate_buffer),
> +					   GFP_KERNEL | __GFP_ZERO);
>   		if (!bo_handles || !buflist) {
> -			drm_free_large(bo_handles);
> -			drm_free_large(buflist);
> +			kvfree(bo_handles);
> +			kvfree(buflist);
>   			return -ENOMEM;
>   		}
>   
> @@ -133,16 +134,16 @@ static int virtio_gpu_execbuffer_ioctl(struct drm_device *dev, void *data,
>   		if (copy_from_user(bo_handles, user_bo_handles,
>   				   exbuf->num_bo_handles * sizeof(uint32_t))) {
>   			ret = -EFAULT;
> -			drm_free_large(bo_handles);
> -			drm_free_large(buflist);
> +			kvfree(bo_handles);
> +			kvfree(buflist);
>   			return ret;
>   		}
>   
>   		for (i = 0; i < exbuf->num_bo_handles; i++) {
>   			gobj = drm_gem_object_lookup(drm_file, bo_handles[i]);
>   			if (!gobj) {
> -				drm_free_large(bo_handles);
> -				drm_free_large(buflist);
> +				kvfree(bo_handles);
> +				kvfree(buflist);
>   				return -ENOENT;
>   			}
>   
> @@ -151,7 +152,7 @@ static int virtio_gpu_execbuffer_ioctl(struct drm_device *dev, void *data,
>   
>   			list_add(&buflist[i].head, &validate_list);
>   		}
> -		drm_free_large(bo_handles);
> +		kvfree(bo_handles);
>   	}
>   
>   	ret = virtio_gpu_object_list_validate(&ticket, &validate_list);
> @@ -171,7 +172,7 @@ static int virtio_gpu_execbuffer_ioctl(struct drm_device *dev, void *data,
>   
>   	/* fence the command bo */
>   	virtio_gpu_unref_list(&validate_list);
> -	drm_free_large(buflist);
> +	kvfree(buflist);
>   	dma_fence_put(&fence->f);
>   	return 0;
>   
> @@ -179,7 +180,7 @@ static int virtio_gpu_execbuffer_ioctl(struct drm_device *dev, void *data,
>   	ttm_eu_backoff_reservation(&ticket, &validate_list);
>   out_free:
>   	virtio_gpu_unref_list(&validate_list);
> -	drm_free_large(buflist);
> +	kvfree(buflist);
>   	return ret;
>   }
>   
> diff --git a/include/drm/drmP.h b/include/drm/drmP.h
> index e1daa4f343cd..59df08d14b89 100644
> --- a/include/drm/drmP.h
> +++ b/include/drm/drmP.h
> @@ -70,7 +70,6 @@
>   #include <drm/drm_fourcc.h>
>   #include <drm/drm_global.h>
>   #include <drm/drm_hashtab.h>
> -#include <drm/drm_mem_util.h>
>   #include <drm/drm_mm.h>
>   #include <drm/drm_os_linux.h>
>   #include <drm/drm_sarea.h>
> diff --git a/include/drm/drm_mem_util.h b/include/drm/drm_mem_util.h
> deleted file mode 100644
> index a1ddf55fda67..000000000000
> --- a/include/drm/drm_mem_util.h
> +++ /dev/null
> @@ -1,53 +0,0 @@
> -/*
> - * Copyright A(C) 2008 Intel Corporation
> - *
> - * Permission is hereby granted, free of charge, to any person obtaining a
> - * copy of this software and associated documentation files (the "Software"),
> - * to deal in the Software without restriction, including without limitation
> - * the rights to use, copy, modify, merge, publish, distribute, sublicense,
> - * and/or sell copies of the Software, and to permit persons to whom the
> - * Software is furnished to do so, subject to the following conditions:
> - *
> - * The above copyright notice and this permission notice (including the next
> - * paragraph) shall be included in all copies or substantial portions of the
> - * Software.
> - *
> - * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
> - * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
> - * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.  IN NO EVENT SHALL
> - * THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
> - * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
> - * FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS
> - * IN THE SOFTWARE.
> - *
> - * Authors:
> - *     Jesse Barnes <jbarnes@virtuousgeek.org>
> - *
> - */
> -#ifndef _DRM_MEM_UTIL_H_
> -#define _DRM_MEM_UTIL_H_
> -
> -#include <linux/vmalloc.h>
> -
> -static __inline__ void *drm_calloc_large(size_t nmemb, size_t size)
> -{
> -	return kvmalloc_array(nmemb, size, GFP_KERNEL | __GFP_ZERO);
> -}
> -
> -/* Modeled after cairo's malloc_ab, it's like calloc but without the zeroing. */
> -static __inline__ void *drm_malloc_ab(size_t nmemb, size_t size)
> -{
> -	return kvmalloc_array(nmemb, size, GFP_KERNEL);
> -}
> -
> -static __inline__ void *drm_malloc_gfp(size_t nmemb, size_t size, gfp_t gfp)
> -{
> -	return kvmalloc_array(nmemb, size, gfp);
> -}
> -
> -static __inline void drm_free_large(void *ptr)
> -{
> -	kvfree(ptr);
> -}
> -
> -#endif


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

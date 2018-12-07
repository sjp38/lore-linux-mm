Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ot1-f72.google.com (mail-ot1-f72.google.com [209.85.210.72])
	by kanga.kvack.org (Postfix) with ESMTP id EECE58E0004
	for <linux-mm@kvack.org>; Fri,  7 Dec 2018 09:50:25 -0500 (EST)
Received: by mail-ot1-f72.google.com with SMTP id m52so1933248otc.13
        for <linux-mm@kvack.org>; Fri, 07 Dec 2018 06:50:25 -0800 (PST)
Received: from foss.arm.com (foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id v76si1400258oie.253.2018.12.07.06.50.24
        for <linux-mm@kvack.org>;
        Fri, 07 Dec 2018 06:50:24 -0800 (PST)
Subject: Re: [PATCH v3 4/9] drm/rockchip/rockchip_drm_gem.c: Convert to use
 vm_insert_range
References: <20181206184227.GA28656@jordon-HP-15-Notebook-PC>
From: Robin Murphy <robin.murphy@arm.com>
Message-ID: <ca1779ea-7a87-971c-24c4-4a1c77a72e92@arm.com>
Date: Fri, 7 Dec 2018 14:50:16 +0000
MIME-Version: 1.0
In-Reply-To: <20181206184227.GA28656@jordon-HP-15-Notebook-PC>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Language: en-GB
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Souptick Joarder <jrdr.linux@gmail.com>, akpm@linux-foundation.org, willy@infradead.org, mhocko@suse.com, hjc@rock-chips.com, heiko@sntech.de, airlied@linux.ie
Cc: linux-mm@kvack.org, dri-devel@lists.freedesktop.org, linux-kernel@vger.kernel.org, linux-arm-kernel@lists.infradead.org, linux-rockchip@lists.infradead.org

On 06/12/2018 18:42, Souptick Joarder wrote:
> Convert to use vm_insert_range() to map range of kernel
> memory to user vma.
> 
> Signed-off-by: Souptick Joarder <jrdr.linux@gmail.com>
> Tested-by: Heiko Stuebner <heiko@sntech.de>
> Acked-by: Heiko Stuebner <heiko@sntech.de>
> ---
>   drivers/gpu/drm/rockchip/rockchip_drm_gem.c | 20 ++------------------
>   1 file changed, 2 insertions(+), 18 deletions(-)
> 
> diff --git a/drivers/gpu/drm/rockchip/rockchip_drm_gem.c b/drivers/gpu/drm/rockchip/rockchip_drm_gem.c
> index a8db758..2cb83bb 100644
> --- a/drivers/gpu/drm/rockchip/rockchip_drm_gem.c
> +++ b/drivers/gpu/drm/rockchip/rockchip_drm_gem.c
> @@ -221,26 +221,10 @@ static int rockchip_drm_gem_object_mmap_iommu(struct drm_gem_object *obj,
>   					      struct vm_area_struct *vma)
>   {
>   	struct rockchip_gem_object *rk_obj = to_rockchip_obj(obj);
> -	unsigned int i, count = obj->size >> PAGE_SHIFT;
>   	unsigned long user_count = vma_pages(vma);
> -	unsigned long uaddr = vma->vm_start;
> -	unsigned long offset = vma->vm_pgoff;
> -	unsigned long end = user_count + offset;
> -	int ret;
> -
> -	if (user_count == 0)
> -		return -ENXIO;
> -	if (end > count)
> -		return -ENXIO;
>   
> -	for (i = offset; i < end; i++) {
> -		ret = vm_insert_page(vma, uaddr, rk_obj->pages[i]);
> -		if (ret)
> -			return ret;
> -		uaddr += PAGE_SIZE;
> -	}
> -
> -	return 0;
> +	return vm_insert_range(vma, vma->vm_start, rk_obj->pages,
> +				user_count);

We're losing vm_pgoff handling here, which given the implication in 
57de50af162b, may well be a regression for at least some combination of 
GPU and userspace driver (I assume that commit was in the context of 
some version of the Arm Mali driver, possibly on RK3288).

Robin.

>   }
>   
>   static int rockchip_drm_gem_object_mmap_dma(struct drm_gem_object *obj,
> 

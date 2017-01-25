Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f69.google.com (mail-pg0-f69.google.com [74.125.83.69])
	by kanga.kvack.org (Postfix) with ESMTP id 5061B6B0069
	for <linux-mm@kvack.org>; Wed, 25 Jan 2017 17:40:52 -0500 (EST)
Received: by mail-pg0-f69.google.com with SMTP id f5so288011838pgi.1
        for <linux-mm@kvack.org>; Wed, 25 Jan 2017 14:40:52 -0800 (PST)
Received: from mga03.intel.com (mga03.intel.com. [134.134.136.65])
        by mx.google.com with ESMTPS id a85si21256157pfe.100.2017.01.25.14.40.51
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 25 Jan 2017 14:40:51 -0800 (PST)
Subject: Re: [PATCH] fixup! mm, fs: reduce fault, page_mkwrite, and
 pfn_mkwrite to take only vmf
References: <20170125223558.1451224-1-arnd@arndb.de>
From: Dave Jiang <dave.jiang@intel.com>
Message-ID: <4591c2d5-b3b0-e1ff-8fcc-ebbc23710eeb@intel.com>
Date: Wed, 25 Jan 2017 15:40:42 -0700
MIME-Version: 1.0
In-Reply-To: <20170125223558.1451224-1-arnd@arndb.de>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Arnd Bergmann <arnd@arndb.de>, Andrew Morton <akpm@linux-foundation.org>
Cc: Ross Zwisler <ross.zwisler@linux.intel.com>, linux-mm@kvack.org, Russell King <linux@armlinux.org.uk>, David Airlie <airlied@linux.ie>, Lucas Stach <l.stach@pengutronix.de>, Christian Gmeiner <christian.gmeiner@gmail.com>, Tomi Valkeinen <tomi.valkeinen@ti.com>, Sebastian Reichel <sre@kernel.org>, Chris Wilson <chris@chris-wilson.co.uk>, Laurent Pinchart <laurent.pinchart@ideasonboard.com>, Peter Ujfalusi <peter.ujfalusi@ti.com>, dri-devel@lists.freedesktop.org, linux-kernel@vger.kernel.org, etnaviv@lists.freedesktop.org

On 01/25/2017 03:35 PM, Arnd Bergmann wrote:
> I ran into a couple of build problems on ARM, these are the changes that
> should be folded into the original patch that changed all the ->fault()
> prototypes
> 
> Fixes: mmtom ("mm, fs: reduce fault, page_mkwrite, and pfn_mkwrite to take only vmf")
> Signed-off-by: Arnd Bergmann <arnd@arndb.de>

Thanks for catching these!

Acked-by: Dave Jiang <dave.jiang@intel.com>

> ---
>  drivers/gpu/drm/armada/armada_gem.c   | 9 +++++----
>  drivers/gpu/drm/etnaviv/etnaviv_drv.h | 2 +-
>  drivers/gpu/drm/omapdrm/omap_drv.h    | 2 +-
>  drivers/hsi/clients/cmt_speech.c      | 4 ++--
>  4 files changed, 9 insertions(+), 8 deletions(-)
> 
> diff --git a/drivers/gpu/drm/armada/armada_gem.c b/drivers/gpu/drm/armada/armada_gem.c
> index a293c8be232c..e1917adc30a4 100644
> --- a/drivers/gpu/drm/armada/armada_gem.c
> +++ b/drivers/gpu/drm/armada/armada_gem.c
> @@ -14,14 +14,15 @@
>  #include <drm/armada_drm.h>
>  #include "armada_ioctlP.h"
>  
> -static int armada_gem_vm_fault(struct vm_area_struct *vma, struct vm_fault *vmf)
> +static int armada_gem_vm_fault(struct vm_fault *vmf)
>  {
> -	struct armada_gem_object *obj = drm_to_armada_gem(vma->vm_private_data);
> +	struct drm_gem_object *gobj = vmf->vma->vm_private_data;
> +	struct armada_gem_object *obj = drm_to_armada_gem(gobj);
>  	unsigned long pfn = obj->phys_addr >> PAGE_SHIFT;
>  	int ret;
>  
> -	pfn += (vmf->address - vma->vm_start) >> PAGE_SHIFT;
> -	ret = vm_insert_pfn(vma, vmf->address, pfn);
> +	pfn += (vmf->address - vmf->vma->vm_start) >> PAGE_SHIFT;
> +	ret = vm_insert_pfn(vmf->vma, vmf->address, pfn);
>  
>  	switch (ret) {
>  	case 0:
> diff --git a/drivers/gpu/drm/etnaviv/etnaviv_drv.h b/drivers/gpu/drm/etnaviv/etnaviv_drv.h
> index c255eda40526..e41f38667c1c 100644
> --- a/drivers/gpu/drm/etnaviv/etnaviv_drv.h
> +++ b/drivers/gpu/drm/etnaviv/etnaviv_drv.h
> @@ -73,7 +73,7 @@ int etnaviv_ioctl_gem_submit(struct drm_device *dev, void *data,
>  		struct drm_file *file);
>  
>  int etnaviv_gem_mmap(struct file *filp, struct vm_area_struct *vma);
> -int etnaviv_gem_fault(struct vm_area_struct *vma, struct vm_fault *vmf);
> +int etnaviv_gem_fault(struct vm_fault *vmf);
>  int etnaviv_gem_mmap_offset(struct drm_gem_object *obj, u64 *offset);
>  struct sg_table *etnaviv_gem_prime_get_sg_table(struct drm_gem_object *obj);
>  void *etnaviv_gem_prime_vmap(struct drm_gem_object *obj);
> diff --git a/drivers/gpu/drm/omapdrm/omap_drv.h b/drivers/gpu/drm/omapdrm/omap_drv.h
> index 7d9dd5400cef..7a8f4bf6effb 100644
> --- a/drivers/gpu/drm/omapdrm/omap_drv.h
> +++ b/drivers/gpu/drm/omapdrm/omap_drv.h
> @@ -204,7 +204,7 @@ int omap_gem_dumb_create(struct drm_file *file, struct drm_device *dev,
>  int omap_gem_mmap(struct file *filp, struct vm_area_struct *vma);
>  int omap_gem_mmap_obj(struct drm_gem_object *obj,
>  		struct vm_area_struct *vma);
> -int omap_gem_fault(struct vm_area_struct *vma, struct vm_fault *vmf);
> +int omap_gem_fault(struct vm_fault *vmf);
>  int omap_gem_op_start(struct drm_gem_object *obj, enum omap_gem_op op);
>  int omap_gem_op_finish(struct drm_gem_object *obj, enum omap_gem_op op);
>  int omap_gem_op_sync(struct drm_gem_object *obj, enum omap_gem_op op);
> diff --git a/drivers/hsi/clients/cmt_speech.c b/drivers/hsi/clients/cmt_speech.c
> index 3deef6cc7d7c..7175e6bedf21 100644
> --- a/drivers/hsi/clients/cmt_speech.c
> +++ b/drivers/hsi/clients/cmt_speech.c
> @@ -1098,9 +1098,9 @@ static void cs_hsi_stop(struct cs_hsi_iface *hi)
>  	kfree(hi);
>  }
>  
> -static int cs_char_vma_fault(struct vm_area_struct *vma, struct vm_fault *vmf)
> +static int cs_char_vma_fault(struct vm_fault *vmf)
>  {
> -	struct cs_char *csdata = vma->vm_private_data;
> +	struct cs_char *csdata = vmf->vma->vm_private_data;
>  	struct page *page;
>  
>  	page = virt_to_page(csdata->mmap_base);
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

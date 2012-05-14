Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx203.postini.com [74.125.245.203])
	by kanga.kvack.org (Postfix) with SMTP id 580646B0083
	for <linux-mm@kvack.org>; Mon, 14 May 2012 04:12:50 -0400 (EDT)
Received: from epcpsbgm2.samsung.com (mailout1.samsung.com [203.254.224.24])
 by mailout1.samsung.com
 (Oracle Communications Messaging Server 7u4-24.01(7.0.4.24.0) 64bit (built Nov
 17 2011)) with ESMTP id <0M40003WV6T9XSJ0@mailout1.samsung.com> for
 linux-mm@kvack.org; Mon, 14 May 2012 17:12:48 +0900 (KST)
Received: from NOINKIDAE02 ([165.213.219.102])
 by mmp1.samsung.com (Oracle Communications Messaging Server 7u4-24.01
 (7.0.4.24.0) 64bit (built Nov 17 2011))
 with ESMTPA id <0M4000MD96TCXST1@mmp1.samsung.com> for linux-mm@kvack.org;
 Mon, 14 May 2012 17:12:48 +0900 (KST)
From: Inki Dae <inki.dae@samsung.com>
References: <1336544259-17222-1-git-send-email-inki.dae@samsung.com>
 <1336976268-14328-1-git-send-email-inki.dae@samsung.com>
 <1336976268-14328-2-git-send-email-inki.dae@samsung.com>
In-reply-to: <1336976268-14328-2-git-send-email-inki.dae@samsung.com>
Subject: RE: [PATCH 1/2 v4] drm/exynos: added userptr limit ioctl.
Date: Mon, 14 May 2012 17:12:44 +0900
Message-id: <003501cd31a9$57cab970$07602c50$%dae@samsung.com>
MIME-version: 1.0
Content-type: text/plain; charset=us-ascii
Content-transfer-encoding: 7bit
Content-language: ko
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: 'Inki Dae' <inki.dae@samsung.com>, airlied@linux.ie, dri-devel@lists.freedesktop.org
Cc: linux-mm@kvack.org, j.glisse@gmail.com, minchan@kernel.org, kosaki.motohiro@gmail.com, kyungmin.park@samsung.com, sw0312.kim@samsung.com, jy0922.shim@samsung.com

ccing linux-mm

> -----Original Message-----
> From: Inki Dae [mailto:inki.dae@samsung.com]
> Sent: Monday, May 14, 2012 3:18 PM
> To: airlied@linux.ie; dri-devel@lists.freedesktop.org
> Cc: j.glisse@gmail.com; minchan@kernel.org; kosaki.motohiro@gmail.com;
> kyungmin.park@samsung.com; sw0312.kim@samsung.com;
jy0922.shim@samsung.com;
> Inki Dae
> Subject: [PATCH 1/2 v4] drm/exynos: added userptr limit ioctl.
> 
> this ioctl is used to limit user-desired userptr size as pre-defined
> and also could be accessed by only root user.
> 
> with userptr feature, unprivileged user can allocate all the pages on
> system,
> so the amount of free physical pages will be very limited. if the VMAs
> within user address space was pinned, the pages couldn't be swapped out so
> it may result in significant degradation of system performance. so this
> feature would be used to avoid such situation.
> 
> Signed-off-by: Inki Dae <inki.dae@samsung.com>
> Signed-off-by: Kyungmin Park <kyungmin.park@samsung.com>
> ---
>  drivers/gpu/drm/exynos/exynos_drm_drv.c |    6 ++++++
>  drivers/gpu/drm/exynos/exynos_drm_drv.h |    6 ++++++
>  drivers/gpu/drm/exynos/exynos_drm_gem.c |   22 ++++++++++++++++++++++
>  drivers/gpu/drm/exynos/exynos_drm_gem.h |    3 +++
>  include/drm/exynos_drm.h                |   17 +++++++++++++++++
>  5 files changed, 54 insertions(+), 0 deletions(-)
> 
> diff --git a/drivers/gpu/drm/exynos/exynos_drm_drv.c
> b/drivers/gpu/drm/exynos/exynos_drm_drv.c
> index 9d3204c..1e68ec2 100644
> --- a/drivers/gpu/drm/exynos/exynos_drm_drv.c
> +++ b/drivers/gpu/drm/exynos/exynos_drm_drv.c
> @@ -64,6 +64,9 @@ static int exynos_drm_load(struct drm_device *dev,
> unsigned long flags)
>  		return -ENOMEM;
>  	}
> 
> +	/* maximum size of userptr is limited to 16MB as default. */
> +	private->userptr_limit = SZ_16M;
> +
>  	INIT_LIST_HEAD(&private->pageflip_event_list);
>  	dev->dev_private = (void *)private;
> 
> @@ -221,6 +224,9 @@ static struct drm_ioctl_desc exynos_ioctls[] = {
>  			exynos_drm_gem_mmap_ioctl, DRM_UNLOCKED | DRM_AUTH),
>  	DRM_IOCTL_DEF_DRV(EXYNOS_GEM_GET,
>  			exynos_drm_gem_get_ioctl, DRM_UNLOCKED),
> +	DRM_IOCTL_DEF_DRV(EXYNOS_USER_LIMIT,
> +			exynos_drm_gem_user_limit_ioctl, DRM_MASTER |
> +			DRM_ROOT_ONLY),
>  	DRM_IOCTL_DEF_DRV(EXYNOS_PLANE_SET_ZPOS,
> exynos_plane_set_zpos_ioctl,
>  			DRM_UNLOCKED | DRM_AUTH),
>  	DRM_IOCTL_DEF_DRV(EXYNOS_VIDI_CONNECTION,
> diff --git a/drivers/gpu/drm/exynos/exynos_drm_drv.h
> b/drivers/gpu/drm/exynos/exynos_drm_drv.h
> index c82c90c..b38ed6f 100644
> --- a/drivers/gpu/drm/exynos/exynos_drm_drv.h
> +++ b/drivers/gpu/drm/exynos/exynos_drm_drv.h
> @@ -235,6 +235,12 @@ struct exynos_drm_private {
>  	 * this array is used to be aware of which crtc did it request
> vblank.
>  	 */
>  	struct drm_crtc *crtc[MAX_CRTC];
> +
> +	/*
> +	 * maximum size of allocation by userptr feature.
> +	 * - as default, this has 16MB and only root user can change it.
> +	 */
> +	unsigned long userptr_limit;
>  };
> 
>  /*
> diff --git a/drivers/gpu/drm/exynos/exynos_drm_gem.c
> b/drivers/gpu/drm/exynos/exynos_drm_gem.c
> index fc91293..e6abb66 100644
> --- a/drivers/gpu/drm/exynos/exynos_drm_gem.c
> +++ b/drivers/gpu/drm/exynos/exynos_drm_gem.c
> @@ -33,6 +33,8 @@
>  #include "exynos_drm_gem.h"
>  #include "exynos_drm_buf.h"
> 
> +#define USERPTR_MAX_SIZE		SZ_64M
> +
>  static unsigned int convert_to_vm_err_msg(int msg)
>  {
>  	unsigned int out_msg;
> @@ -630,6 +632,26 @@ int exynos_drm_gem_get_ioctl(struct drm_device *dev,
> void *data,
>  	return 0;
>  }
> 
> +int exynos_drm_gem_user_limit_ioctl(struct drm_device *dev, void *data,
> +				      struct drm_file *filp)
> +{
> +	struct exynos_drm_private *priv = dev->dev_private;
> +	struct drm_exynos_user_limit *limit = data;
> +
> +	if (limit->userptr_limit < PAGE_SIZE ||
> +			limit->userptr_limit > USERPTR_MAX_SIZE) {
> +		DRM_DEBUG_KMS("invalid userptr_limit size.\n");
> +		return -EINVAL;
> +	}
> +
> +	if (priv->userptr_limit == limit->userptr_limit)
> +		return 0;
> +
> +	priv->userptr_limit = limit->userptr_limit;
> +
> +	return 0;
> +}
> +
>  int exynos_drm_gem_init_object(struct drm_gem_object *obj)
>  {
>  	DRM_DEBUG_KMS("%s\n", __FILE__);
> diff --git a/drivers/gpu/drm/exynos/exynos_drm_gem.h
> b/drivers/gpu/drm/exynos/exynos_drm_gem.h
> index 14d038b..3334c9f 100644
> --- a/drivers/gpu/drm/exynos/exynos_drm_gem.h
> +++ b/drivers/gpu/drm/exynos/exynos_drm_gem.h
> @@ -78,6 +78,9 @@ struct exynos_drm_gem_obj {
> 
>  struct page **exynos_gem_get_pages(struct drm_gem_object *obj, gfp_t
> gfpmask);
> 
> +int exynos_drm_gem_user_limit_ioctl(struct drm_device *dev, void *data,
> +				      struct drm_file *filp);
> +
>  /* destroy a buffer with gem object */
>  void exynos_drm_gem_destroy(struct exynos_drm_gem_obj *exynos_gem_obj);
> 
> diff --git a/include/drm/exynos_drm.h b/include/drm/exynos_drm.h
> index 54c97e8..52465dc 100644
> --- a/include/drm/exynos_drm.h
> +++ b/include/drm/exynos_drm.h
> @@ -92,6 +92,19 @@ struct drm_exynos_gem_info {
>  };
> 
>  /**
> + * A structure to userptr limited information.
> + *
> + * @userptr_limit: maximum size to userptr buffer.
> + *	the buffer could be allocated by unprivileged user using malloc()
> + *	and the size of the buffer would be limited as userptr_limit value.
> + * @pad: just padding to be 64-bit aligned.
> + */
> +struct drm_exynos_user_limit {
> +	unsigned int userptr_limit;
> +	unsigned int pad;
> +};
> +
> +/**
>   * A structure for user connection request of virtual display.
>   *
>   * @connection: indicate whether doing connetion or not by user.
> @@ -162,6 +175,7 @@ struct drm_exynos_g2d_exec {
>  #define DRM_EXYNOS_GEM_MMAP		0x02
>  /* Reserved 0x03 ~ 0x05 for exynos specific gem ioctl */
>  #define DRM_EXYNOS_GEM_GET		0x04
> +#define DRM_EXYNOS_USER_LIMIT		0x05
>  #define DRM_EXYNOS_PLANE_SET_ZPOS	0x06
>  #define DRM_EXYNOS_VIDI_CONNECTION	0x07
> 
> @@ -182,6 +196,9 @@ struct drm_exynos_g2d_exec {
>  #define DRM_IOCTL_EXYNOS_GEM_GET	DRM_IOWR(DRM_COMMAND_BASE + \
>  		DRM_EXYNOS_GEM_GET,	struct drm_exynos_gem_info)
> 
> +#define DRM_IOCTL_EXYNOS_USER_LIMIT	DRM_IOWR(DRM_COMMAND_BASE + \
> +		DRM_EXYNOS_USER_LIMIT,	struct drm_exynos_user_limit)
> +
>  #define DRM_IOCTL_EXYNOS_PLANE_SET_ZPOS	DRM_IOWR(DRM_COMMAND_BASE +
> \
>  		DRM_EXYNOS_PLANE_SET_ZPOS, struct drm_exynos_plane_set_zpos)
> 
> --
> 1.7.4.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

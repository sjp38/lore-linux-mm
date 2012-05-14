Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx146.postini.com [74.125.245.146])
	by kanga.kvack.org (Postfix) with SMTP id 9D5AF6B004D
	for <linux-mm@kvack.org>; Mon, 14 May 2012 04:12:28 -0400 (EDT)
Received: from epcpsbgm2.samsung.com (mailout2.samsung.com [203.254.224.25])
 by mailout2.samsung.com
 (Oracle Communications Messaging Server 7u4-24.01(7.0.4.24.0) 64bit (built Nov
 17 2011)) with ESMTP id <0M4000FGO6SQ7UN0@mailout2.samsung.com> for
 linux-mm@kvack.org; Mon, 14 May 2012 17:12:27 +0900 (KST)
Received: from NOINKIDAE02 ([165.213.219.102])
 by mmp2.samsung.com (Oracle Communications Messaging Server 7u4-24.01
 (7.0.4.24.0) 64bit (built Nov 17 2011))
 with ESMTPA id <0M40009YB6SPDC90@mmp2.samsung.com> for linux-mm@kvack.org;
 Mon, 14 May 2012 17:12:25 +0900 (KST)
From: Inki Dae <inki.dae@samsung.com>
References: <1336544259-17222-1-git-send-email-inki.dae@samsung.com>
 <1336976268-14328-1-git-send-email-inki.dae@samsung.com>
In-reply-to: <1336976268-14328-1-git-send-email-inki.dae@samsung.com>
Subject: RE: [PATCH 0/2 v4] drm/exynos: added userptr feature
Date: Mon, 14 May 2012 17:12:21 +0900
Message-id: <003401cd31a9$49df56e0$dd9e04a0$%dae@samsung.com>
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
> Subject: [PATCH 0/2 v4] drm/exynos: added userptr feature
> 
> this feature could be used to memory region allocated by malloc() in user
> mode
> and mmaped memory region allocated by other memory allocators.
> userptr interface can identify memory type through vm_flags value and
> would get
> pages or page frame numbers to user space appropriately.
> 
> Changelog v4:
> we have discussed some issues to userptr feature with drm and mm guys and
> below are the issues.
> 
> The migration issue.
> - Pages reserved by CMA for some device using DMA could be used by
> kernel and if the device driver wants to use those pages
> while being used by kernel then the pages are copied into
> other ones allocated to migrate them and then finally,
> the device driver can use the pages for itself.
> Thus, migrated, the pages being accessed by DMA could be changed
> to other so this situation may incur that DMA accesses any pages
> it doesn't want.
> 
> The COW issue.
> - while DMA of a device is using the pages to VMAs, if current
> process was forked then the pages being accessed by the DMA
> would be copied into child's pages.(Copy On Write) so
> these pages may not have coherrency with parent's ones if
> child process wrote something on those pages so we need to
> flag VM_DONTCOPY to prevent pages from being COWed.
> 
> But the use of get_user_pages is safe from such magration issue
> because all the pages from get_user_pages CAN NOT BE not only
> migrated but also swapped out. this true has been confirmed
> by mm guys, Minchan Kim and KOSAKI Motohiro.
> However below issue could be incurred.
> 
> The deterioration issue of system performance by malicious process.
> - any malicious process can request all the pages of entire system memory
> through this userptr ioctl and as the result, all other processes would be
> blocked and this would incur the deterioration of system performance
> because the pages couldn't be swapped out.
> 
> So we limit user-desired userptr size to pre-defined and this ioctl
> command
> CAN BE accessed by only root user.
> 
> Changelog v3:
> Mitigated the issues pointed out by Dave and Jerome.
> 
> for this, added some codes to guarantee the pages to user space not
> to be swapped out, the VMAs within the user space would be locked and
> then unlocked when the pages are released.
> 
> but this lock might result in significant degradation of system
> performance
> because the pages couldn't be swapped out so added one more featrue
> that we can limit user-desired userptr size to pre-defined value using
> userptr limit ioctl that can be accessed by only root user.
> 
> Changelog v2:
> the memory regino mmaped with VM_PFNMAP type is physically continuous and
> start address of the memory region should be set into buf->dma_addr but
> previous patch had a problem that end address is set into buf->dma_addr
> so v2 fixes that problem.
> 
> Inki Dae (2):
>   drm/exynos: added userptr limit ioctl.
>   drm/exynos: added userptr feature.
> 
>  drivers/gpu/drm/exynos/exynos_drm_drv.c |    8 +
>  drivers/gpu/drm/exynos/exynos_drm_drv.h |    6 +
>  drivers/gpu/drm/exynos/exynos_drm_gem.c |  413
> +++++++++++++++++++++++++++++++
>  drivers/gpu/drm/exynos/exynos_drm_gem.h |   20 ++-
>  include/drm/exynos_drm.h                |   43 +++-
>  5 files changed, 487 insertions(+), 3 deletions(-)
> 
> --
> 1.7.4.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

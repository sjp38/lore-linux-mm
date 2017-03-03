Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f200.google.com (mail-wr0-f200.google.com [209.85.128.200])
	by kanga.kvack.org (Postfix) with ESMTP id 940406B0038
	for <linux-mm@kvack.org>; Fri,  3 Mar 2017 05:04:39 -0500 (EST)
Received: by mail-wr0-f200.google.com with SMTP id w37so38184622wrc.2
        for <linux-mm@kvack.org>; Fri, 03 Mar 2017 02:04:39 -0800 (PST)
Received: from mail-wm0-x241.google.com (mail-wm0-x241.google.com. [2a00:1450:400c:c09::241])
        by mx.google.com with ESMTPS id q16si11262856wra.35.2017.03.03.02.04.37
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 03 Mar 2017 02:04:37 -0800 (PST)
Received: by mail-wm0-x241.google.com with SMTP id m70so2313847wma.1
        for <linux-mm@kvack.org>; Fri, 03 Mar 2017 02:04:37 -0800 (PST)
Date: Fri, 3 Mar 2017 11:04:33 +0100
From: Daniel Vetter <daniel@ffwll.ch>
Subject: Re: [RFC PATCH 00/12] Ion cleanup in preparation for moving out of
 staging
Message-ID: <20170303100433.lm5t4hqxj6friyp6@phenom.ffwll.local>
References: <1488491084-17252-1-git-send-email-labbott@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1488491084-17252-1-git-send-email-labbott@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Laura Abbott <labbott@redhat.com>
Cc: Sumit Semwal <sumit.semwal@linaro.org>, Riley Andrews <riandrews@android.com>, arve@android.com, romlem@google.com, devel@driverdev.osuosl.org, linux-kernel@vger.kernel.org, linaro-mm-sig@lists.linaro.org, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, linux-arm-kernel@lists.infradead.org, linux-media@vger.kernel.org, dri-devel@lists.freedesktop.org, Brian Starkey <brian.starkey@arm.com>, Daniel Vetter <daniel.vetter@intel.com>, Mark Brown <broonie@kernel.org>, Benjamin Gaignard <benjamin.gaignard@linaro.org>, linux-mm@kvack.org

On Thu, Mar 02, 2017 at 01:44:32PM -0800, Laura Abbott wrote:
> Hi,
> 
> There's been some recent discussions[1] about Ion-like frameworks. There's
> apparently interest in just keeping Ion since it works reasonablly well.
> This series does what should be the final clean ups for it to possibly be
> moved out of staging.
> 
> This includes the following:
> - Some general clean up and removal of features that never got a lot of use
>   as far as I can tell.
> - Fixing up the caching. This is the series I proposed back in December[2]
>   but never heard any feedback on. It will certainly break existing
>   applications that rely on the implicit caching. I'd rather make an effort
>   to move to a model that isn't going directly against the establishement
>   though.
> - Fixing up the platform support. The devicetree approach was never well
>   recieved by DT maintainers. The proposal here is to think of Ion less as
>   specifying requirements and more of a framework for exposing memory to
>   userspace.
> - CMA allocations now happen without the need of a dummy device structure.
>   This fixes a bunch of the reasons why I attempted to add devicetree
>   support before.
> 
> I've had problems getting feedback in the past so if I don't hear any major
> objections I'm going to send out with the RFC dropped to be picked up.
> The only reason there isn't a patch to come out of staging is to discuss any
> other changes to the ABI people might want. Once this comes out of staging,
> I really don't want to mess with the ABI.
> 
> Feedback appreciated.

Imo looks all good. And I just realized that cross-checking with the TODO,
the 2 items about _CUSTOM and _IMPORT ioctls I noted are already there.

Otherwise I looked through the patches, looks all really reasonable.

Wrt merging, my experience from destaging the android syncpt stuff was
that merging the patches through the staging tree lead to lots of
cross-tree issues with the gpu folks wanting to use that. Ion will
probably run into similar things, so I'd propose we pull these cleanup
patches and the eventual de-staging in throught drm. Yes that defacto
means I'm also volunteering myself a bit :-)

In the end we could put it all into drivers/gpu/ion or something like
that.

Thoughts? Greg?
-Daniel


> 
> Thanks,
> Laura
> 
> [1] https://marc.info/?l=linux-kernel&m=148699712602105&w=2
> [2] https://marc.info/?l=linaro-mm-sig&m=148176050802908&w=2
> 
> Laura Abbott (12):
>   staging: android: ion: Remove dmap_cnt
>   staging: android: ion: Remove alignment from allocation field
>   staging: android: ion: Duplicate sg_table
>   staging: android: ion: Call dma_map_sg for syncing and mapping
>   staging: android: ion: Remove page faulting support
>   staging: android: ion: Remove crufty cache support
>   staging: android: ion: Remove old platform support
>   cma: Store a name in the cma structure
>   cma: Introduce cma_for_each_area
>   staging: android: ion: Use CMA APIs directly
>   staging: android: ion: Make Ion heaps selectable
>   staging; android: ion: Enumerate all available heaps
> 
>  drivers/base/dma-contiguous.c                      |   5 +-
>  drivers/staging/android/ion/Kconfig                |  51 ++--
>  drivers/staging/android/ion/Makefile               |  14 +-
>  drivers/staging/android/ion/hisilicon/Kconfig      |   5 -
>  drivers/staging/android/ion/hisilicon/Makefile     |   1 -
>  drivers/staging/android/ion/hisilicon/hi6220_ion.c | 113 ---------
>  drivers/staging/android/ion/ion-ioctl.c            |   6 -
>  drivers/staging/android/ion/ion.c                  | 282 ++++++---------------
>  drivers/staging/android/ion/ion.h                  |   5 +-
>  drivers/staging/android/ion/ion_carveout_heap.c    |  16 +-
>  drivers/staging/android/ion/ion_chunk_heap.c       |  15 +-
>  drivers/staging/android/ion/ion_cma_heap.c         | 102 ++------
>  drivers/staging/android/ion/ion_dummy_driver.c     | 156 ------------
>  drivers/staging/android/ion/ion_enumerate.c        |  89 +++++++
>  drivers/staging/android/ion/ion_of.c               | 184 --------------
>  drivers/staging/android/ion/ion_of.h               |  37 ---
>  drivers/staging/android/ion/ion_page_pool.c        |   3 -
>  drivers/staging/android/ion/ion_priv.h             |  57 ++++-
>  drivers/staging/android/ion/ion_system_heap.c      |  14 +-
>  drivers/staging/android/ion/tegra/Makefile         |   1 -
>  drivers/staging/android/ion/tegra/tegra_ion.c      |  80 ------
>  include/linux/cma.h                                |   6 +-
>  mm/cma.c                                           |  25 +-
>  mm/cma.h                                           |   1 +
>  mm/cma_debug.c                                     |   2 +-
>  25 files changed, 312 insertions(+), 958 deletions(-)
>  delete mode 100644 drivers/staging/android/ion/hisilicon/Kconfig
>  delete mode 100644 drivers/staging/android/ion/hisilicon/Makefile
>  delete mode 100644 drivers/staging/android/ion/hisilicon/hi6220_ion.c
>  delete mode 100644 drivers/staging/android/ion/ion_dummy_driver.c
>  create mode 100644 drivers/staging/android/ion/ion_enumerate.c
>  delete mode 100644 drivers/staging/android/ion/ion_of.c
>  delete mode 100644 drivers/staging/android/ion/ion_of.h
>  delete mode 100644 drivers/staging/android/ion/tegra/Makefile
>  delete mode 100644 drivers/staging/android/ion/tegra/tegra_ion.c
> 
> -- 
> 2.7.4
> 
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

-- 
Daniel Vetter
Software Engineer, Intel Corporation
http://blog.ffwll.ch

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

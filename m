Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ot1-f71.google.com (mail-ot1-f71.google.com [209.85.210.71])
	by kanga.kvack.org (Postfix) with ESMTP id 917406B04BA
	for <linux-mm@kvack.org>; Tue, 30 Oct 2018 00:45:38 -0400 (EDT)
Received: by mail-ot1-f71.google.com with SMTP id v95so1708549ota.3
        for <linux-mm@kvack.org>; Mon, 29 Oct 2018 21:45:38 -0700 (PDT)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [202.181.97.72])
        by mx.google.com with ESMTPS id l7si4260416otj.0.2018.10.29.21.45.36
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 29 Oct 2018 21:45:36 -0700 (PDT)
Message-Id: <201810300445.w9U4jMhu076672@www262.sakura.ne.jp>
Subject: Re: [RFC PATCH v2 3/3] mm, oom: hand over =?ISO-2022-JP?B?TU1GX09PTV9T?=
 =?ISO-2022-JP?B?S0lQIHRvIGV4aXQgcGF0aCBpZiBpdCBpcyBndXJhbnRlZWQgdG8gZmlu?=
 =?ISO-2022-JP?B?aXNo?=
From: Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>
MIME-Version: 1.0
Date: Tue, 30 Oct 2018 13:45:22 +0900
References: <20181025082403.3806-1-mhocko@kernel.org> <20181025082403.3806-4-mhocko@kernel.org>
In-Reply-To: <20181025082403.3806-4-mhocko@kernel.org>
Content-Type: text/plain; charset="ISO-2022-JP"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: linux-mm@kvack.org, Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, Roman Gushchin <guro@fb.com>, David Rientjes <rientjes@google.com>, Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>, Michal Hocko <mhocko@suse.com>

Michal Hocko wrote:
> @@ -3156,6 +3166,13 @@ void exit_mmap(struct mm_struct *mm)
>                 vma = remove_vma(vma);
>         }
>         vm_unacct_memory(nr_accounted);
> +
> +       /*
> +        * Now that the full address space is torn down, make sure the
> +        * OOM killer skips over this task
> +        */
> +       if (oom)
> +               set_bit(MMF_OOM_SKIP, &mm->flags);
>  }
> 
>  /* Insert vm structure into process list sorted by address

I don't like setting MMF_OOF_SKIP after remove_vma() loop. 50 users might
call vma->vm_ops->close() from remove_vma(). Some of them are doing fs
writeback, some of them might be doing GFP_KERNEL allocation from
vma->vm_ops->open() with a lock also held by vma->vm_ops->close().

I don't think that waiting for completion of remove_vma() loop is safe.
And my patch is safe.

 drivers/android/binder.c                          |    2 +-
 drivers/gpu/drm/drm_gem_cma_helper.c              |    2 +-
 drivers/gpu/drm/drm_vm.c                          |    8 ++++----
 drivers/gpu/drm/gma500/framebuffer.c              |    2 +-
 drivers/gpu/drm/gma500/psb_drv.c                  |    2 +-
 drivers/gpu/drm/i915/i915_drv.c                   |    2 +-
 drivers/gpu/drm/ttm/ttm_bo_vm.c                   |    2 +-
 drivers/gpu/drm/udl/udl_drv.c                     |    2 +-
 drivers/gpu/drm/v3d/v3d_drv.c                     |    2 +-
 drivers/gpu/drm/vc4/vc4_drv.c                     |    2 +-
 drivers/gpu/drm/vgem/vgem_drv.c                   |    2 +-
 drivers/gpu/drm/vkms/vkms_drv.c                   |    2 +-
 drivers/gpu/drm/xen/xen_drm_front.c               |    2 +-
 drivers/hwtracing/intel_th/msu.c                  |    2 +-
 drivers/hwtracing/stm/core.c                      |    2 +-
 drivers/infiniband/core/uverbs_main.c             |    2 +-
 drivers/infiniband/sw/rdmavt/mmap.c               |    2 +-
 drivers/infiniband/sw/rxe/rxe_mmap.c              |    2 +-
 drivers/media/common/videobuf2/videobuf2-memops.c |    2 +-
 drivers/media/pci/meye/meye.c                     |    2 +-
 drivers/media/platform/omap/omap_vout.c           |    2 +-
 drivers/media/usb/stkwebcam/stk-webcam.c          |    2 +-
 drivers/media/v4l2-core/videobuf-dma-contig.c     |    2 +-
 drivers/media/v4l2-core/videobuf-dma-sg.c         |    2 +-
 drivers/media/v4l2-core/videobuf-vmalloc.c        |    2 +-
 drivers/misc/genwqe/card_dev.c                    |    2 +-
 drivers/misc/mic/scif/scif_mmap.c                 |    2 +-
 drivers/misc/sgi-gru/grufile.c                    |    2 +-
 drivers/rapidio/devices/rio_mport_cdev.c          |    2 +-
 drivers/staging/comedi/comedi_fops.c              |    2 +-
 drivers/staging/media/zoran/zoran_driver.c        |    2 +-
 drivers/staging/vme/devices/vme_user.c            |    2 +-
 drivers/usb/core/devio.c                          |    2 +-
 drivers/usb/mon/mon_bin.c                         |    2 +-
 drivers/video/fbdev/omap2/omapfb/omapfb-main.c    |    2 +-
 drivers/xen/gntalloc.c                            |    2 +-
 drivers/xen/gntdev.c                              |    2 +-
 drivers/xen/privcmd-buf.c                         |    2 +-
 drivers/xen/privcmd.c                             |    2 +-
 fs/9p/vfs_file.c                                  |    2 +-
 fs/fuse/file.c                                    |    2 +-
 fs/kernfs/file.c                                  |    2 +-
 include/linux/mm.h                                |    2 +-
 ipc/shm.c                                         |    2 +-
 kernel/events/core.c                              |    2 +-
 kernel/relay.c                                    |    2 +-
 mm/hugetlb.c                                      |    2 +-
 mm/mmap.c                                         |   14 +++++++-------
 net/packet/af_packet.c                            |    2 +-
 sound/core/pcm_native.c                           |    4 ++--
 sound/usb/usx2y/us122l.c                          |    2 +-
 sound/usb/usx2y/usx2yhwdeppcm.c                   |    2 +-
 52 files changed, 62 insertions(+), 62 deletions(-)

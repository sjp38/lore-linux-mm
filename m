Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f197.google.com (mail-qk0-f197.google.com [209.85.220.197])
	by kanga.kvack.org (Postfix) with ESMTP id C977F6B039F
	for <linux-mm@kvack.org>; Wed, 29 Mar 2017 05:03:09 -0400 (EDT)
Received: by mail-qk0-f197.google.com with SMTP id z74so3461468qka.5
        for <linux-mm@kvack.org>; Wed, 29 Mar 2017 02:03:09 -0700 (PDT)
Received: from mail-qt0-x232.google.com (mail-qt0-x232.google.com. [2607:f8b0:400d:c0d::232])
        by mx.google.com with ESMTPS id d43si5717989qtf.124.2017.03.29.02.03.08
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 29 Mar 2017 02:03:08 -0700 (PDT)
Received: by mail-qt0-x232.google.com with SMTP id i34so7130587qtc.0
        for <linux-mm@kvack.org>; Wed, 29 Mar 2017 02:03:08 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <1489798493-16600-1-git-send-email-labbott@redhat.com>
References: <1489798493-16600-1-git-send-email-labbott@redhat.com>
From: Benjamin Gaignard <benjamin.gaignard@linaro.org>
Date: Wed, 29 Mar 2017 11:03:07 +0200
Message-ID: <CA+M3ks4ykYszxmzscnCAwKdahTZxwNWjPg7HvWDHh6bNdnD1=A@mail.gmail.com>
Subject: Re: [RFC PATCHv2 00/21] Ion clean in preparation for moving out of staging
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Laura Abbott <labbott@redhat.com>
Cc: Sumit Semwal <sumit.semwal@linaro.org>, Riley Andrews <riandrews@android.com>, =?UTF-8?B?QXJ2ZSBIasO4bm5ldsOlZw==?= <arve@android.com>, Rom Lemarchand <romlem@google.com>, devel@driverdev.osuosl.org, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, "linaro-mm-sig@lists.linaro.org" <linaro-mm-sig@lists.linaro.org>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, linux-arm-kernel@lists.infradead.org, "linux-media@vger.kernel.org" <linux-media@vger.kernel.org>, "dri-devel@lists.freedesktop.org" <dri-devel@lists.freedesktop.org>, Brian Starkey <brian.starkey@arm.com>, Daniel Vetter <daniel.vetter@intel.com>, Mark Brown <broonie@kernel.org>, Linux MM <linux-mm@kvack.org>, Laurent Pinchart <laurent.pinchart@ideasonboard.com>

2017-03-18 1:54 GMT+01:00 Laura Abbott <labbott@redhat.com>:
>
> Hi,
>
> This is v2 of the series to do some serious Ion clean up in preparation f=
or
> moving out of staging. I got good feedback last time so this series mostl=
y
> attempts to address that feedback and do more still more cleanup. Highlig=
hts:
>
> - All calls to DMA APIs should now be with a real actual proper device
>   structure
> - Patch to stop setting sg_dma_address manually now included
> - Fix for a bug in the query interface
> - Removal of custom ioctl interface
> - Removal of import interface
> - Removal of any notion of using Ion as an in kernel interface.
> - Cleanup of ABI so compat interface is no longer needed
> - Deletion of a bit more platform code
> - Combined heap enumeration and heap registration code up so there are fe=
wer
>   layers of abstraction
> - Some general cleanup and header reduction.
> - Removal of both the ion_client and ion_handle structures since these mo=
stly
>   become redundant. As a result, Ion only returns a dma_buf fd. The overa=
ll
>   result is that the only Ion interfaces are the query ioctl and the allo=
c
>   ioctl.
>
> The following are still TODOs/open problems:
> - Sumit's comments about the CMA naming.
> - Bindings/platform for chunk and carveout heap
> - There was some discussion about making the sg_table duplication generic=
. I
>   got bogged down in handling some of the edge cases for generic handling
>   so I put this aside. Making it generic is still something that should h=
appen.
> - More fine-grained support for restricting heap access. There are good
>   arguments to be made for having a way for having good integration with
>   selinux and other policy mechanisms.
> - While not on the original list, there is still no good good test standa=
lone
>   test framework. I noticed that the existing ion_test was fairly generic=
 so I
>   proposed moving it to dma_buf. Daniel Vetter suggested just using the V=
GEM
>   module instead. Ideally, the tests can live as part of some other exist=
ing
>   test set (drm tests maybe?)
>
> Feedback appreciated as always.

Thanks for this v2, it really clean up and simplify ION.

For me the last question mark is about restricting heap access with
SElinux policy.
Since I haven't see other proposals I still believe that we should
have a /dev/ion/$heapname
per heap.

>
> Thanks,
> Laura
>
> Laura Abbott (21):
>   cma: Store a name in the cma structure
>   cma: Introduce cma_for_each_area
>   staging: android: ion: Remove dmap_cnt
>   staging: android: ion: Remove alignment from allocation field
>   staging: android: ion: Duplicate sg_table
>   staging: android: ion: Call dma_map_sg for syncing and mapping
>   staging: android: ion: Remove page faulting support
>   staging: android: ion: Remove crufty cache support
>   staging: android: ion: Remove custom ioctl interface
>   staging: android: ion: Remove import interface
>   staging: android: ion: Remove duplicate ION_IOC_MAP
>   staging: android: ion: Remove old platform support
>   staging: android: ion: Use CMA APIs directly
>   staging: android: ion: Stop butchering the DMA address
>   staging: android: ion: Break the ABI in the name of forward progress
>   staging: android: ion: Get rid of ion_phys_addr_t
>   staging: android: ion: Collapse internal header files
>   staging: android: ion: Rework heap registration/enumeration
>   staging: android: ion: Drop ion_map_kernel interface
>   staging: android: ion: Remove ion_handle and ion_client
>   staging: android: ion: Set query return value
>
>  drivers/base/dma-contiguous.c                      |    5 +-
>  drivers/staging/android/ion/Kconfig                |   56 +-
>  drivers/staging/android/ion/Makefile               |   18 +-
>  drivers/staging/android/ion/compat_ion.c           |  195 ----
>  drivers/staging/android/ion/compat_ion.h           |   29 -
>  drivers/staging/android/ion/hisilicon/Kconfig      |    5 -
>  drivers/staging/android/ion/hisilicon/Makefile     |    1 -
>  drivers/staging/android/ion/hisilicon/hi6220_ion.c |  113 --
>  drivers/staging/android/ion/ion-ioctl.c            |   85 +-
>  drivers/staging/android/ion/ion.c                  | 1164 +++-----------=
------
>  drivers/staging/android/ion/ion.h                  |  393 +++++--
>  drivers/staging/android/ion/ion_carveout_heap.c    |   37 +-
>  drivers/staging/android/ion/ion_chunk_heap.c       |   27 +-
>  drivers/staging/android/ion/ion_cma_heap.c         |  125 +--
>  drivers/staging/android/ion/ion_dummy_driver.c     |  156 ---
>  drivers/staging/android/ion/ion_heap.c             |   68 --
>  drivers/staging/android/ion/ion_of.c               |  184 ----
>  drivers/staging/android/ion/ion_of.h               |   37 -
>  drivers/staging/android/ion/ion_page_pool.c        |    6 +-
>  drivers/staging/android/ion/ion_priv.h             |  473 --------
>  drivers/staging/android/ion/ion_system_heap.c      |   53 +-
>  drivers/staging/android/ion/ion_test.c             |  305 -----
>  drivers/staging/android/ion/tegra/Makefile         |    1 -
>  drivers/staging/android/ion/tegra/tegra_ion.c      |   80 --
>  drivers/staging/android/uapi/ion.h                 |   86 +-
>  drivers/staging/android/uapi/ion_test.h            |   69 --
>  include/linux/cma.h                                |    6 +-
>  mm/cma.c                                           |   25 +-
>  mm/cma.h                                           |    1 +
>  mm/cma_debug.c                                     |    2 +-
>  30 files changed, 610 insertions(+), 3195 deletions(-)
>  delete mode 100644 drivers/staging/android/ion/compat_ion.c
>  delete mode 100644 drivers/staging/android/ion/compat_ion.h
>  delete mode 100644 drivers/staging/android/ion/hisilicon/Kconfig
>  delete mode 100644 drivers/staging/android/ion/hisilicon/Makefile
>  delete mode 100644 drivers/staging/android/ion/hisilicon/hi6220_ion.c
>  delete mode 100644 drivers/staging/android/ion/ion_dummy_driver.c
>  delete mode 100644 drivers/staging/android/ion/ion_of.c
>  delete mode 100644 drivers/staging/android/ion/ion_of.h
>  delete mode 100644 drivers/staging/android/ion/ion_priv.h
>  delete mode 100644 drivers/staging/android/ion/ion_test.c
>  delete mode 100644 drivers/staging/android/ion/tegra/Makefile
>  delete mode 100644 drivers/staging/android/ion/tegra/tegra_ion.c
>  delete mode 100644 drivers/staging/android/uapi/ion_test.h
>
> --
> 2.7.4
>



--=20
Benjamin Gaignard

Graphic Study Group

Linaro.org =E2=94=82 Open source software for ARM SoCs

Follow Linaro: Facebook | Twitter | Blog

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f180.google.com (mail-pd0-f180.google.com [209.85.192.180])
	by kanga.kvack.org (Postfix) with ESMTP id 6C47B6B0253
	for <linux-mm@kvack.org>; Mon, 13 Jul 2015 06:54:17 -0400 (EDT)
Received: by pdrg1 with SMTP id g1so90454715pdr.2
        for <linux-mm@kvack.org>; Mon, 13 Jul 2015 03:54:17 -0700 (PDT)
Received: from mga03.intel.com (mga03.intel.com. [134.134.136.65])
        by mx.google.com with ESMTP id dn2si27870766pdb.54.2015.07.13.03.54.16
        for <linux-mm@kvack.org>;
        Mon, 13 Jul 2015 03:54:16 -0700 (PDT)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: [PATCH 0/5] Make vma_is_anonymous() reliable
Date: Mon, 13 Jul 2015 13:54:07 +0300
Message-Id: <1436784852-144369-1-git-send-email-kirill.shutemov@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Oleg Nesterov <oleg@redhat.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

We rely on ->vm_ops == NULL to detect anonymous VMA but this check is not
always reliable:

 - MPX sets ->vm_ops on anonymous VMA;

 - many drivers don't set ->vm_ops. See for instance hpet_mmap().

This patchset makes vma_is_anonymous() more reliable and makes few
cleanups around the code.

Kirill A. Shutemov (5):
  mm: mark most vm_operations_struct const
  x86, mpx: do not set ->vm_ops on mpx VMAs
  mm: make sure all file VMAs have ->vm_ops set
  mm, madvise: use vma_is_anonymous() to check for anon VMA
  mm, memcontrol: use vma_is_anonymous() to check for anon VMA

 arch/x86/kernel/vsyscall_64.c                  |  2 +-
 arch/x86/mm/mmap.c                             |  7 +++++++
 arch/x86/mm/mpx.c                              | 20 +-------------------
 drivers/android/binder.c                       |  2 +-
 drivers/gpu/drm/vgem/vgem_drv.c                |  2 +-
 drivers/hsi/clients/cmt_speech.c               |  2 +-
 drivers/infiniband/hw/qib/qib_file_ops.c       |  2 +-
 drivers/infiniband/hw/qib/qib_mmap.c           |  2 +-
 drivers/media/platform/omap/omap_vout.c        |  2 +-
 drivers/misc/genwqe/card_dev.c                 |  2 +-
 drivers/staging/android/ion/ion.c              |  2 +-
 drivers/staging/comedi/comedi_fops.c           |  2 +-
 drivers/video/fbdev/omap2/omapfb/omapfb-main.c |  2 +-
 drivers/xen/gntalloc.c                         |  2 +-
 drivers/xen/gntdev.c                           |  2 +-
 drivers/xen/privcmd.c                          |  4 ++--
 fs/ceph/addr.c                                 |  2 +-
 fs/cifs/file.c                                 |  2 +-
 mm/madvise.c                                   |  2 +-
 mm/memcontrol.c                                |  2 +-
 mm/mmap.c                                      |  8 ++++++++
 security/selinux/selinuxfs.c                   |  2 +-
 22 files changed, 36 insertions(+), 39 deletions(-)

-- 
2.1.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

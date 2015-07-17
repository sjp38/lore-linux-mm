Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f41.google.com (mail-pa0-f41.google.com [209.85.220.41])
	by kanga.kvack.org (Postfix) with ESMTP id 6D971280324
	for <linux-mm@kvack.org>; Fri, 17 Jul 2015 07:53:24 -0400 (EDT)
Received: by pactm7 with SMTP id tm7so60256768pac.2
        for <linux-mm@kvack.org>; Fri, 17 Jul 2015 04:53:24 -0700 (PDT)
Received: from mga03.intel.com (mga03.intel.com. [134.134.136.65])
        by mx.google.com with ESMTP id kt9si18326203pab.169.2015.07.17.04.53.23
        for <linux-mm@kvack.org>;
        Fri, 17 Jul 2015 04:53:23 -0700 (PDT)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: [PATCHv2 0/6] Make vma_is_anonymous() reliable
Date: Fri, 17 Jul 2015 14:53:07 +0300
Message-Id: <1437133993-91885-1-git-send-email-kirill.shutemov@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Oleg Nesterov <oleg@redhat.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

We rely on ->vm_ops == NULL to detect anonymous VMA but this check is not
always reliable:

 - MPX sets ->vm_ops on anonymous VMA;

  - many drivers don't set ->vm_ops. See for instance hpet_mmap().

  This patchset makes vma_is_anonymous() more reliable and makes few
  cleanups around the code.

v2:
 - drop broken patch;
 - more cleanup for mpx code (Oleg);
 - vma_is_anonymous() in create_huge_pmd() and wp_huge_pmd();

Kirill A. Shutemov (5):
  mm: mark most vm_operations_struct const
  x86, mpx: do not set ->vm_ops on mpx VMAs
  mm: make sure all file VMAs have ->vm_ops set
  mm: use vma_is_anonymous() in create_huge_pmd() and wp_huge_pmd()
  mm, madvise: use vma_is_anonymous() to check for anon VMA

Oleg Nesterov (1):
  mm, mpx: add "vm_flags_t vm_flags" arg to do_mmap_pgoff()

 arch/x86/kernel/vsyscall_64.c                  |  2 +-
 arch/x86/mm/mmap.c                             |  7 +++
 arch/x86/mm/mpx.c                              | 71 +++-----------------------
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
 drivers/xen/privcmd.c                          |  4 +-
 fs/ceph/addr.c                                 |  2 +-
 fs/cifs/file.c                                 |  2 +-
 include/linux/mm.h                             | 12 ++++-
 mm/madvise.c                                   |  2 +-
 mm/memory.c                                    |  4 +-
 mm/mmap.c                                      | 18 ++++---
 mm/nommu.c                                     | 15 +++---
 security/selinux/selinuxfs.c                   |  2 +-
 24 files changed, 66 insertions(+), 99 deletions(-)

-- 
2.1.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

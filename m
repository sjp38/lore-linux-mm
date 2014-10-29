Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qa0-f51.google.com (mail-qa0-f51.google.com [209.85.216.51])
	by kanga.kvack.org (Postfix) with ESMTP id A222390008B
	for <linux-mm@kvack.org>; Wed, 29 Oct 2014 12:36:16 -0400 (EDT)
Received: by mail-qa0-f51.google.com with SMTP id f12so2402031qad.10
        for <linux-mm@kvack.org>; Wed, 29 Oct 2014 09:36:16 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id s38si8218235qge.85.2014.10.29.09.36.14
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 29 Oct 2014 09:36:15 -0700 (PDT)
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: [PATCH 0/5] get_user_pages_locked|unlocked v1
Date: Wed, 29 Oct 2014 17:35:15 +0100
Message-Id: <1414600520-7664-1-git-send-email-aarcange@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
Cc: "Kirill A. Shutemov" <kirill@shutemov.name>, Michel Lespinasse <walken@google.com>, Andrew Jones <drjones@redhat.com>, Hugh Dickins <hughd@google.com>, Mel Gorman <mgorman@suse.de>, Andres Lagar-Cavilla <andreslc@google.com>, Minchan Kim <minchan@kernel.org>, KOSAKI Motohiro <kosaki.motohiro@gmail.com>, "\\\"Dr. David Alan Gilbert\\\"" <dgilbert@redhat.com>, Peter Feiner <pfeiner@google.com>, Peter Zijlstra <peterz@infradead.org>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, James Bottomley <James.Bottomley@HansenPartnership.com>, David Miller <davem@davemloft.net>, Steve Capper <steve.capper@linaro.org>, Johannes Weiner <jweiner@redhat.com>

This patchset standalone is an optimization leveraging the page fault
FAULT_FLAG_ALLOW_RETRY flag which allows the page fault paths to drop
the mmap_sem before I/O.

For the userfaultfd patchset this patch is instead a dependency as we
need that flag always set the first time any thread attempts a page
fault, in order to release the mmap_sem before stopping the page fault
(while waiting for a later userland wakeup).

http://thread.gmane.org/gmane.linux.kernel.mm/123575

Andrea Arcangeli (5):
  mm: gup: add get_user_pages_locked and get_user_pages_unlocked
  mm: gup: add __get_user_pages_unlocked to customize gup_flags
  mm: gup: use get_user_pages_unlocked within get_user_pages_fast
  mm: gup: use get_user_pages_unlocked
  mm: gup: kvm use get_user_pages_unlocked

 arch/mips/mm/gup.c                 |   8 +-
 arch/powerpc/mm/gup.c              |   6 +-
 arch/s390/mm/gup.c                 |   6 +-
 arch/sh/mm/gup.c                   |   6 +-
 arch/sparc/mm/gup.c                |   6 +-
 arch/x86/mm/gup.c                  |   7 +-
 drivers/iommu/amd_iommu_v2.c       |   6 +-
 drivers/media/pci/ivtv/ivtv-udma.c |   6 +-
 drivers/scsi/st.c                  |   7 +-
 drivers/video/fbdev/pvr2fb.c       |   6 +-
 include/linux/kvm_host.h           |  11 --
 include/linux/mm.h                 |  11 ++
 mm/gup.c                           | 203 ++++++++++++++++++++++++++++++++++---
 mm/nommu.c                         |  33 ++++++
 mm/process_vm_access.c             |   7 +-
 mm/util.c                          |  10 +-
 net/ceph/pagevec.c                 |   6 +-
 virt/kvm/async_pf.c                |   2 +-
 virt/kvm/kvm_main.c                |  50 +--------
 19 files changed, 265 insertions(+), 132 deletions(-)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

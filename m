Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f199.google.com (mail-qt0-f199.google.com [209.85.216.199])
	by kanga.kvack.org (Postfix) with ESMTP id 7A6496B025F
	for <linux-mm@kvack.org>; Tue, 29 Aug 2017 16:11:40 -0400 (EDT)
Received: by mail-qt0-f199.google.com with SMTP id w42so13392445qtg.2
        for <linux-mm@kvack.org>; Tue, 29 Aug 2017 13:11:40 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id u2si3662808qkf.108.2017.08.29.13.11.39
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 29 Aug 2017 13:11:39 -0700 (PDT)
From: =?UTF-8?q?J=C3=A9r=C3=B4me=20Glisse?= <jglisse@redhat.com>
Subject: [PATCH 0/4] mmu_notifier semantic update
Date: Tue, 29 Aug 2017 16:11:28 -0400
Message-Id: <20170829201132.9292-1-jglisse@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org, linux-mm@kvack.org
Cc: =?UTF-8?q?J=C3=A9r=C3=B4me=20Glisse?= <jglisse@redhat.com>, Linus Torvalds <torvalds@linux-foundation.org>, Bernhard Held <berny156@gmx.de>, Adam Borowski <kilobyte@angband.pl>, Andrea Arcangeli <aarcange@redhat.com>, =?UTF-8?q?Radim=20Kr=C4=8Dm=C3=A1=C5=99?= <rkrcmar@redhat.com>, Wanpeng Li <kernellwp@gmail.com>, Paolo Bonzini <pbonzini@redhat.com>, Takashi Iwai <tiwai@suse.de>, Nadav Amit <nadav.amit@gmail.com>, Mike Galbraith <efault@gmx.de>, "Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>, axie <axie@amd.com>, Andrew Morton <akpm@linux-foundation.org>, Dan Williams <dan.j.williams@intel.com>, Ross Zwisler <ross.zwisler@linux.intel.com>

So we do not want to allow sleep during call to mmu_notifier_invalidate_page()
but some code do not have surrounding mmu_notifier_invalidate_range_start()/
mmu_notifier_invalidate_range_end() or mmu_notifier_invalidate_range()

This patch serie just make sure that there is at least a call (outside spinlock
section) to mmu_notifier_invalidate_range() after mmu_notifier_invalidate_page()

This fix issue with AMD IOMMU v2 while avoiding to introduce issue for others
user of the mmu_notifier API. For releavent threads see:

https://lkml.kernel.org/r/20170809204333.27485-1-jglisse@redhat.com
https://lkml.kernel.org/r/20170804134928.l4klfcnqatni7vsc@black.fi.intel.com
https://marc.info/?l=kvm&m=150327081325160&w=2

Signed-off-by: JA(C)rA'me Glisse <jglisse@redhat.com>
Cc: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Bernhard Held <berny156@gmx.de>
Cc: Adam Borowski <kilobyte@angband.pl>
Cc: Andrea Arcangeli <aarcange@redhat.com>
Cc: Radim KrA?mA!A? <rkrcmar@redhat.com>
Cc: Wanpeng Li <kernellwp@gmail.com>
Cc: Paolo Bonzini <pbonzini@redhat.com>
Cc: Takashi Iwai <tiwai@suse.de>
Cc: Nadav Amit <nadav.amit@gmail.com>
Cc: Mike Galbraith <efault@gmx.de>
Cc: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
Cc: axie <axie@amd.com>
Cc: Andrew Morton <akpm@linux-foundation.org>
Cc: Dan Williams <dan.j.williams@intel.com>
Cc: Ross Zwisler <ross.zwisler@linux.intel.com>

JA(C)rA'me Glisse (4):
  mm/mmu_notifier: document new behavior for
    mmu_notifier_invalidate_page()
  dax/mmu_notifier: update to new mmu_notifier semantic
  mm/rmap: update to new mmu_notifier_invalidate_page() semantic
  iommu/amd: update to new mmu_notifier_invalidate_page() semantic

 drivers/iommu/amd_iommu_v2.c |  8 --------
 fs/dax.c                     |  8 ++++++--
 include/linux/mmu_notifier.h |  6 ++++++
 mm/rmap.c                    | 18 +++++++++++++++++-
 4 files changed, 29 insertions(+), 11 deletions(-)

-- 
2.13.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

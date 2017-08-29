Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f199.google.com (mail-qk0-f199.google.com [209.85.220.199])
	by kanga.kvack.org (Postfix) with ESMTP id AD3FD280300
	for <linux-mm@kvack.org>; Tue, 29 Aug 2017 19:54:59 -0400 (EDT)
Received: by mail-qk0-f199.google.com with SMTP id l65so14372977qkc.1
        for <linux-mm@kvack.org>; Tue, 29 Aug 2017 16:54:59 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id t1si3977101qtb.379.2017.08.29.16.54.58
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 29 Aug 2017 16:54:58 -0700 (PDT)
From: =?UTF-8?q?J=C3=A9r=C3=B4me=20Glisse?= <jglisse@redhat.com>
Subject: [PATCH 00/13] mmu_notifier kill invalidate_page callback
Date: Tue, 29 Aug 2017 19:54:34 -0400
Message-Id: <20170829235447.10050-1-jglisse@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org, linux-mm@kvack.org
Cc: =?UTF-8?q?J=C3=A9r=C3=B4me=20Glisse?= <jglisse@redhat.com>, "Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>, Joerg Roedel <jroedel@suse.de>, Dan Williams <dan.j.williams@intel.com>, Sudeep Dutt <sudeep.dutt@intel.com>, Ashutosh Dixit <ashutosh.dixit@intel.com>, Dimitri Sivanich <sivanich@sgi.com>, Jack Steiner <steiner@sgi.com>, Paolo Bonzini <pbonzini@redhat.com>, =?UTF-8?q?Radim=20Kr=C4=8Dm=C3=A1=C5=99?= <rkrcmar@redhat.com>, linuxppc-dev@lists.ozlabs.org, dri-devel@lists.freedesktop.org, amd-gfx@lists.freedesktop.org, linux-rdma@vger.kernel.org, iommu@lists.linux-foundation.org, xen-devel@lists.xenproject.org, kvm@vger.kernel.org

(Sorry for so many list cross-posting and big cc)

Please help testing !

The invalidate_page callback suffered from 2 pitfalls. First it used to
happen after page table lock was release and thus a new page might have
been setup for the virtual address before the call to invalidate_page().

This is in a weird way fixed by c7ab0d2fdc840266b39db94538f74207ec2afbf6
which moved the callback under the page table lock. Which also broke
several existing user of the mmu_notifier API that assumed they could
sleep inside this callback.

The second pitfall was invalidate_page being the only callback not taking
a range of address in respect to invalidation but was giving an address
and a page. Lot of the callback implementer assumed this could never be
THP and thus failed to invalidate the appropriate range for THP pages.

By killing this callback we unify the mmu_notifier callback API to always
take a virtual address range as input.

There is now 2 clear API (I am not mentioning the youngess API which is
seldomly used):
  - invalidate_range_start()/end() callback (which allow you to sleep)
  - invalidate_range() where you can not sleep but happen right after
    page table update under page table lock


Note that a lot of existing user feels broken in respect to range_start/
range_end. Many user only have range_start() callback but there is nothing
preventing them to undo what was invalidated in their range_start() callback
after it returns but before any CPU page table update take place.

The code pattern use in kvm or umem odp is an example on how to properly
avoid such race. In a nutshell use some kind of sequence number and active
range invalidation counter to block anything that might undo what the
range_start() callback did.

If you do not care about keeping fully in sync with CPU page table (ie
you can live with CPU page table pointing to new different page for a
given virtual address) then you can take a reference on the pages inside
the range_start callback and drop it in range_end or when your driver
is done with those pages.

Last alternative is to use invalidate_range() if you can do invalidation
without sleeping as invalidate_range() callback happens under the CPU
page table spinlock right after the page table is updated.


Note this is barely tested. I intend to do more testing of next few days
but i do not have access to all hardware that make use of the mmu_notifier
API.


First 2 patches convert existing call of mmu_notifier_invalidate_page()
to mmu_notifier_invalidate_range() and bracket those call with call to
mmu_notifier_invalidate_range_start()/end().

The next 10 patches remove existing invalidate_page() callback as it can
no longer happen.

Finaly the last page remove it completely so it can RIP.

JA(C)rA'me Glisse (13):
  dax: update to new mmu_notifier semantic
  mm/rmap: update to new mmu_notifier semantic
  powerpc/powernv: update to new mmu_notifier semantic
  drm/amdgpu: update to new mmu_notifier semantic
  IB/umem: update to new mmu_notifier semantic
  IB/hfi1: update to new mmu_notifier semantic
  iommu/amd: update to new mmu_notifier semantic
  iommu/intel: update to new mmu_notifier semantic
  misc/mic/scif: update to new mmu_notifier semantic
  sgi-gru: update to new mmu_notifier semantic
  xen/gntdev: update to new mmu_notifier semantic
  KVM: update to new mmu_notifier semantic
  mm/mmu_notifier: kill invalidate_page

Cc: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
Cc: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Andrew Morton <akpm@linux-foundation.org>
Cc: Andrea Arcangeli <aarcange@redhat.com>
Cc: Joerg Roedel <jroedel@suse.de>
Cc: Dan Williams <dan.j.williams@intel.com>
Cc: Sudeep Dutt <sudeep.dutt@intel.com>
Cc: Ashutosh Dixit <ashutosh.dixit@intel.com>
Cc: Dimitri Sivanich <sivanich@sgi.com>
Cc: Jack Steiner <steiner@sgi.com>
Cc: Paolo Bonzini <pbonzini@redhat.com>
Cc: Radim KrA?mA!A? <rkrcmar@redhat.com>

Cc: linuxppc-dev@lists.ozlabs.org
Cc: dri-devel@lists.freedesktop.org
Cc: amd-gfx@lists.freedesktop.org
Cc: linux-rdma@vger.kernel.org
Cc: iommu@lists.linux-foundation.org
Cc: xen-devel@lists.xenproject.org
Cc: kvm@vger.kernel.org


 arch/powerpc/platforms/powernv/npu-dma.c | 10 --------
 drivers/gpu/drm/amd/amdgpu/amdgpu_mn.c   | 31 ----------------------
 drivers/infiniband/core/umem_odp.c       | 19 --------------
 drivers/infiniband/hw/hfi1/mmu_rb.c      |  9 -------
 drivers/iommu/amd_iommu_v2.c             |  8 ------
 drivers/iommu/intel-svm.c                |  9 -------
 drivers/misc/mic/scif/scif_dma.c         | 11 --------
 drivers/misc/sgi-gru/grutlbpurge.c       | 12 ---------
 drivers/xen/gntdev.c                     |  8 ------
 fs/dax.c                                 | 19 ++++++++------
 include/linux/mm.h                       |  1 +
 include/linux/mmu_notifier.h             | 25 ------------------
 mm/memory.c                              | 26 +++++++++++++++----
 mm/mmu_notifier.c                        | 14 ----------
 mm/rmap.c                                | 44 +++++++++++++++++++++++++++++---
 virt/kvm/kvm_main.c                      | 42 ------------------------------
 16 files changed, 74 insertions(+), 214 deletions(-)

-- 
2.13.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

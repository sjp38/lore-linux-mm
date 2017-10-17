Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f199.google.com (mail-qk0-f199.google.com [209.85.220.199])
	by kanga.kvack.org (Postfix) with ESMTP id 8B8726B0038
	for <linux-mm@kvack.org>; Mon, 16 Oct 2017 23:10:15 -0400 (EDT)
Received: by mail-qk0-f199.google.com with SMTP id d67so504298qkg.3
        for <linux-mm@kvack.org>; Mon, 16 Oct 2017 20:10:15 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id f83si4120043qke.449.2017.10.16.20.10.14
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 16 Oct 2017 20:10:14 -0700 (PDT)
From: jglisse@redhat.com
Subject: [PATCH 0/2] Optimize mmu_notifier->invalidate_range callback
Date: Mon, 16 Oct 2017 23:10:01 -0400
Message-Id: <20171017031003.7481-1-jglisse@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: linux-kernel@vger.kernel.org, =?UTF-8?q?J=C3=A9r=C3=B4me=20Glisse?= <jglisse@redhat.com>, Andrea Arcangeli <aarcange@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Joerg Roedel <jroedel@suse.de>, Suravee Suthikulpanit <suravee.suthikulpanit@amd.com>, David Woodhouse <dwmw2@infradead.org>, Alistair Popple <alistair@popple.id.au>, Michael Ellerman <mpe@ellerman.id.au>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Stephen Rothwell <sfr@canb.auug.org.au>, Andrew Donnellan <andrew.donnellan@au1.ibm.com>, iommu@lists.linux-foundation.org, linuxppc-dev@lists.ozlabs.org

From: JA(C)rA'me Glisse <jglisse@redhat.com>

(Andrew you already have v1 in your queue of patch 1, patch 2 is new,
 i think you can drop it patch 1 v1 for v2, v2 is bit more conservative
 and i fixed typos)

All this only affect user of invalidate_range callback (at this time
CAPI arch/powerpc/platforms/powernv/npu-dma.c, IOMMU ATS/PASID in
drivers/iommu/amd_iommu_v2.c|intel-svm.c)

This patchset remove useless double call to mmu_notifier->invalidate_range
callback wherever it is safe to do so. The first patch just remove useless
call and add documentation explaining why it is safe to do so. The second
patch go further by introducing mmu_notifier_invalidate_range_only_end()
which skip callback to invalidate_range this can be done when clearing a
pte, pmd or pud with notification which call invalidate_range right after
clearing under the page table lock.

It should improve performances but i am lacking hardware and benchmarks
which might show an improvement. Maybe folks in cc can help here.

Cc: Andrea Arcangeli <aarcange@redhat.com>
Cc: Andrew Morton <akpm@linux-foundation.org>
Cc: Joerg Roedel <jroedel@suse.de>
Cc: Suravee Suthikulpanit <suravee.suthikulpanit@amd.com>
Cc: David Woodhouse <dwmw2@infradead.org>
Cc: Alistair Popple <alistair@popple.id.au>
Cc: Michael Ellerman <mpe@ellerman.id.au>
Cc: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Cc: Stephen Rothwell <sfr@canb.auug.org.au>
Cc: Andrew Donnellan <andrew.donnellan@au1.ibm.com>
Cc: iommu@lists.linux-foundation.org
Cc: linuxppc-dev@lists.ozlabs.org

JA(C)rA'me Glisse (2):
  mm/mmu_notifier: avoid double notification when it is useless v2
  mm/mmu_notifier: avoid call to invalidate_range() in range_end()

 Documentation/vm/mmu_notifier.txt | 93 +++++++++++++++++++++++++++++++++++++++
 fs/dax.c                          |  9 +++-
 include/linux/mmu_notifier.h      | 20 +++++++--
 mm/huge_memory.c                  | 66 ++++++++++++++++++++++++---
 mm/hugetlb.c                      | 16 +++++--
 mm/ksm.c                          | 15 ++++++-
 mm/memory.c                       |  6 ++-
 mm/migrate.c                      | 15 +++++--
 mm/mmu_notifier.c                 | 11 ++++-
 mm/rmap.c                         | 59 ++++++++++++++++++++++---
 10 files changed, 281 insertions(+), 29 deletions(-)
 create mode 100644 Documentation/vm/mmu_notifier.txt

-- 
2.13.6

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

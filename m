Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt1-f198.google.com (mail-qt1-f198.google.com [209.85.160.198])
	by kanga.kvack.org (Postfix) with ESMTP id E0BD98E0047
	for <linux-mm@kvack.org>; Wed, 23 Jan 2019 17:23:42 -0500 (EST)
Received: by mail-qt1-f198.google.com with SMTP id q33so4209476qte.23
        for <linux-mm@kvack.org>; Wed, 23 Jan 2019 14:23:42 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id k18si1459105qtb.401.2019.01.23.14.23.42
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 23 Jan 2019 14:23:42 -0800 (PST)
From: jglisse@redhat.com
Subject: [PATCH v4 4/9] mm/mmu_notifier: pass down vma and reasons why mmu notifier is happening
Date: Wed, 23 Jan 2019 17:23:10 -0500
Message-Id: <20190123222315.1122-5-jglisse@redhat.com>
In-Reply-To: <20190123222315.1122-1-jglisse@redhat.com>
References: <20190123222315.1122-1-jglisse@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, =?UTF-8?q?J=C3=A9r=C3=B4me=20Glisse?= <jglisse@redhat.com>, =?UTF-8?q?Christian=20K=C3=B6nig?= <christian.koenig@amd.com>, Jan Kara <jack@suse.cz>, Felix Kuehling <Felix.Kuehling@amd.com>, Jason Gunthorpe <jgg@mellanox.com>, Matthew Wilcox <mawilcox@microsoft.com>, Ross Zwisler <zwisler@kernel.org>, Dan Williams <dan.j.williams@intel.com>, Paolo Bonzini <pbonzini@redhat.com>, =?UTF-8?q?Radim=20Kr=C4=8Dm=C3=A1=C5=99?= <rkrcmar@redhat.com>, Michal Hocko <mhocko@kernel.org>, Ralph Campbell <rcampbell@nvidia.com>, John Hubbard <jhubbard@nvidia.com>, kvm@vger.kernel.org, dri-devel@lists.freedesktop.org, linux-rdma@vger.kernel.org, linux-fsdevel@vger.kernel.org, Arnd Bergmann <arnd@arndb.de>

From: Jérôme Glisse <jglisse@redhat.com>

CPU page table update can happens for many reasons, not only as a result
of a syscall (munmap(), mprotect(), mremap(), madvise(), ...) but also
as a result of kernel activities (memory compression, reclaim, migration,
...).

Users of mmu notifier API track changes to the CPU page table and take
specific action for them. While current API only provide range of virtual
address affected by the change, not why the changes is happening

This patch is just passing down the new informations by adding it to the
mmu_notifier_range structure.

Signed-off-by: Jérôme Glisse <jglisse@redhat.com>
Cc: Christian König <christian.koenig@amd.com>
Cc: Jan Kara <jack@suse.cz>
Cc: Felix Kuehling <Felix.Kuehling@amd.com>
Cc: Jason Gunthorpe <jgg@mellanox.com>
Cc: Andrew Morton <akpm@linux-foundation.org>
Cc: Matthew Wilcox <mawilcox@microsoft.com>
Cc: Ross Zwisler <zwisler@kernel.org>
Cc: Dan Williams <dan.j.williams@intel.com>
Cc: Paolo Bonzini <pbonzini@redhat.com>
Cc: Radim Krčmář <rkrcmar@redhat.com>
Cc: Michal Hocko <mhocko@kernel.org>
Cc: Ralph Campbell <rcampbell@nvidia.com>
Cc: John Hubbard <jhubbard@nvidia.com>
Cc: kvm@vger.kernel.org
Cc: dri-devel@lists.freedesktop.org
Cc: linux-rdma@vger.kernel.org
Cc: linux-fsdevel@vger.kernel.org
Cc: Arnd Bergmann <arnd@arndb.de>
---
 include/linux/mmu_notifier.h | 4 ++++
 1 file changed, 4 insertions(+)

diff --git a/include/linux/mmu_notifier.h b/include/linux/mmu_notifier.h
index a9808add4070..7514775817de 100644
--- a/include/linux/mmu_notifier.h
+++ b/include/linux/mmu_notifier.h
@@ -56,9 +56,11 @@ struct mmu_notifier_mm {
 };
 
 struct mmu_notifier_range {
+	struct vm_area_struct *vma;
 	struct mm_struct *mm;
 	unsigned long start;
 	unsigned long end;
+	enum mmu_notifier_event event;
 	bool blockable;
 };
 
@@ -354,6 +356,8 @@ static inline void mmu_notifier_range_init(struct mmu_notifier_range *range,
 					   unsigned long start,
 					   unsigned long end)
 {
+	range->vma = vma;
+	range->event = event;
 	range->mm = mm;
 	range->start = start;
 	range->end = end;
-- 
2.17.2

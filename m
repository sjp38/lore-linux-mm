Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt1-f198.google.com (mail-qt1-f198.google.com [209.85.160.198])
	by kanga.kvack.org (Postfix) with ESMTP id 091588E0047
	for <linux-mm@kvack.org>; Wed, 23 Jan 2019 17:23:34 -0500 (EST)
Received: by mail-qt1-f198.google.com with SMTP id n50so4350077qtb.9
        for <linux-mm@kvack.org>; Wed, 23 Jan 2019 14:23:34 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id r65si8550397qtd.301.2019.01.23.14.23.33
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 23 Jan 2019 14:23:33 -0800 (PST)
From: jglisse@redhat.com
Subject: [PATCH v4 1/9] mm/mmu_notifier: contextual information for event enums
Date: Wed, 23 Jan 2019 17:23:07 -0500
Message-Id: <20190123222315.1122-2-jglisse@redhat.com>
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

This patch introduce a set of enums that can be associated with each of
the events triggering a mmu notifier. Latter patches take advantages of
those enum values.

    - UNMAP: munmap() or mremap()
    - CLEAR: page table is cleared (migration, compaction, reclaim, ...)
    - PROTECTION_VMA: change in access protections for the range
    - PROTECTION_PAGE: change in access protections for page in the range
    - SOFT_DIRTY: soft dirtyness tracking

Being able to identify munmap() and mremap() from other reasons why the
page table is cleared is important to allow user of mmu notifier to
update their own internal tracking structure accordingly (on munmap or
mremap it is not longer needed to track range of virtual address as it
becomes invalid).

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
 include/linux/mmu_notifier.h | 30 ++++++++++++++++++++++++++++++
 1 file changed, 30 insertions(+)

diff --git a/include/linux/mmu_notifier.h b/include/linux/mmu_notifier.h
index 4050ec1c3b45..abc9dbb7bcb6 100644
--- a/include/linux/mmu_notifier.h
+++ b/include/linux/mmu_notifier.h
@@ -10,6 +10,36 @@
 struct mmu_notifier;
 struct mmu_notifier_ops;
 
+/**
+ * enum mmu_notifier_event - reason for the mmu notifier callback
+ * @MMU_NOTIFY_UNMAP: either munmap() that unmap the range or a mremap() that
+ * move the range
+ *
+ * @MMU_NOTIFY_CLEAR: clear page table entry (many reasons for this like
+ * madvise() or replacing a page by another one, ...).
+ *
+ * @MMU_NOTIFY_PROTECTION_VMA: update is due to protection change for the range
+ * ie using the vma access permission (vm_page_prot) to update the whole range
+ * is enough no need to inspect changes to the CPU page table (mprotect()
+ * syscall)
+ *
+ * @MMU_NOTIFY_PROTECTION_PAGE: update is due to change in read/write flag for
+ * pages in the range so to mirror those changes the user must inspect the CPU
+ * page table (from the end callback).
+ *
+ * @MMU_NOTIFY_SOFT_DIRTY: soft dirty accounting (still same page and same
+ * access flags). User should soft dirty the page in the end callback to make
+ * sure that anyone relying on soft dirtyness catch pages that might be written
+ * through non CPU mappings.
+ */
+enum mmu_notifier_event {
+	MMU_NOTIFY_UNMAP = 0,
+	MMU_NOTIFY_CLEAR,
+	MMU_NOTIFY_PROTECTION_VMA,
+	MMU_NOTIFY_PROTECTION_PAGE,
+	MMU_NOTIFY_SOFT_DIRTY,
+};
+
 #ifdef CONFIG_MMU_NOTIFIER
 
 /*
-- 
2.17.2

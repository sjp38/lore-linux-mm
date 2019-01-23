Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt1-f199.google.com (mail-qt1-f199.google.com [209.85.160.199])
	by kanga.kvack.org (Postfix) with ESMTP id 792758E0047
	for <linux-mm@kvack.org>; Wed, 23 Jan 2019 17:23:56 -0500 (EST)
Received: by mail-qt1-f199.google.com with SMTP id p24so4368941qtl.2
        for <linux-mm@kvack.org>; Wed, 23 Jan 2019 14:23:56 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id c4si3776096qtj.64.2019.01.23.14.23.55
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 23 Jan 2019 14:23:55 -0800 (PST)
From: jglisse@redhat.com
Subject: [PATCH v4 9/9] RDMA/umem_odp: optimize out the case when a range is updated to read only
Date: Wed, 23 Jan 2019 17:23:15 -0500
Message-Id: <20190123222315.1122-10-jglisse@redhat.com>
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

When range of virtual address is updated read only and corresponding
user ptr object are already read only it is pointless to do anything.
Optimize this case out.

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
 drivers/infiniband/core/umem_odp.c | 22 +++++++++++++++++++---
 include/rdma/ib_umem_odp.h         |  1 +
 2 files changed, 20 insertions(+), 3 deletions(-)

diff --git a/drivers/infiniband/core/umem_odp.c b/drivers/infiniband/core/umem_odp.c
index a4ec43093cb3..fa4e7fdcabfc 100644
--- a/drivers/infiniband/core/umem_odp.c
+++ b/drivers/infiniband/core/umem_odp.c
@@ -140,8 +140,15 @@ static void ib_umem_notifier_release(struct mmu_notifier *mn,
 static int invalidate_range_start_trampoline(struct ib_umem_odp *item,
 					     u64 start, u64 end, void *cookie)
 {
+	bool update_to_read_only = *((bool *)cookie);
+
 	ib_umem_notifier_start_account(item);
-	item->umem.context->invalidate_range(item, start, end);
+	/*
+	 * If it is already read only and we are updating to read only then we
+	 * do not need to change anything. So save time and skip this one.
+	 */
+	if (!update_to_read_only || !item->read_only)
+		item->umem.context->invalidate_range(item, start, end);
 	return 0;
 }
 
@@ -150,6 +157,7 @@ static int ib_umem_notifier_invalidate_range_start(struct mmu_notifier *mn,
 {
 	struct ib_ucontext_per_mm *per_mm =
 		container_of(mn, struct ib_ucontext_per_mm, mn);
+	bool update_to_read_only;
 
 	if (range->blockable)
 		down_read(&per_mm->umem_rwsem);
@@ -166,10 +174,13 @@ static int ib_umem_notifier_invalidate_range_start(struct mmu_notifier *mn,
 		return 0;
 	}
 
+	update_to_read_only = mmu_notifier_range_update_to_read_only(range);
+
 	return rbt_ib_umem_for_each_in_range(&per_mm->umem_tree, range->start,
 					     range->end,
 					     invalidate_range_start_trampoline,
-					     range->blockable, NULL);
+					     range->blockable,
+					     &update_to_read_only);
 }
 
 static int invalidate_range_end_trampoline(struct ib_umem_odp *item, u64 start,
@@ -363,6 +374,9 @@ struct ib_umem_odp *ib_alloc_odp_umem(struct ib_ucontext_per_mm *per_mm,
 		goto out_odp_data;
 	}
 
+	/* Assume read only at first, each time GUP is call this is updated. */
+	odp_data->read_only = true;
+
 	odp_data->dma_list =
 		vzalloc(array_size(pages, sizeof(*odp_data->dma_list)));
 	if (!odp_data->dma_list) {
@@ -619,8 +633,10 @@ int ib_umem_odp_map_dma_pages(struct ib_umem_odp *umem_odp, u64 user_virt,
 		goto out_put_task;
 	}
 
-	if (access_mask & ODP_WRITE_ALLOWED_BIT)
+	if (access_mask & ODP_WRITE_ALLOWED_BIT) {
+		umem_odp->read_only = false;
 		flags |= FOLL_WRITE;
+	}
 
 	start_idx = (user_virt - ib_umem_start(umem)) >> page_shift;
 	k = start_idx;
diff --git a/include/rdma/ib_umem_odp.h b/include/rdma/ib_umem_odp.h
index 0b1446fe2fab..8256668c6170 100644
--- a/include/rdma/ib_umem_odp.h
+++ b/include/rdma/ib_umem_odp.h
@@ -76,6 +76,7 @@ struct ib_umem_odp {
 	struct completion	notifier_completion;
 	int			dying;
 	struct work_struct	work;
+	bool read_only;
 };
 
 static inline struct ib_umem_odp *to_ib_umem_odp(struct ib_umem *umem)
-- 
2.17.2

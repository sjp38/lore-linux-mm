Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk1-f198.google.com (mail-qk1-f198.google.com [209.85.222.198])
	by kanga.kvack.org (Postfix) with ESMTP id 220258E0047
	for <linux-mm@kvack.org>; Wed, 23 Jan 2019 17:23:48 -0500 (EST)
Received: by mail-qk1-f198.google.com with SMTP id y27so3418545qkj.21
        for <linux-mm@kvack.org>; Wed, 23 Jan 2019 14:23:48 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id h10si8990634qtc.140.2019.01.23.14.23.47
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 23 Jan 2019 14:23:47 -0800 (PST)
From: jglisse@redhat.com
Subject: [PATCH v4 6/9] gpu/drm/radeon: optimize out the case when a range is updated to read only
Date: Wed, 23 Jan 2019 17:23:12 -0500
Message-Id: <20190123222315.1122-7-jglisse@redhat.com>
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
 drivers/gpu/drm/radeon/radeon_mn.c | 13 +++++++++++++
 1 file changed, 13 insertions(+)

diff --git a/drivers/gpu/drm/radeon/radeon_mn.c b/drivers/gpu/drm/radeon/radeon_mn.c
index b3019505065a..f77294f58e63 100644
--- a/drivers/gpu/drm/radeon/radeon_mn.c
+++ b/drivers/gpu/drm/radeon/radeon_mn.c
@@ -124,6 +124,7 @@ static int radeon_mn_invalidate_range_start(struct mmu_notifier *mn,
 	struct radeon_mn *rmn = container_of(mn, struct radeon_mn, mn);
 	struct ttm_operation_ctx ctx = { false, false };
 	struct interval_tree_node *it;
+	bool update_to_read_only;
 	unsigned long end;
 	int ret = 0;
 
@@ -138,6 +139,8 @@ static int radeon_mn_invalidate_range_start(struct mmu_notifier *mn,
 	else if (!mutex_trylock(&rmn->lock))
 		return -EAGAIN;
 
+	update_to_read_only = mmu_notifier_range_update_to_read_only(range);
+
 	it = interval_tree_iter_first(&rmn->objects, range->start, end);
 	while (it) {
 		struct radeon_mn_node *node;
@@ -153,10 +156,20 @@ static int radeon_mn_invalidate_range_start(struct mmu_notifier *mn,
 		it = interval_tree_iter_next(it, range->start, end);
 
 		list_for_each_entry(bo, &node->bos, mn_list) {
+			bool read_only;
 
 			if (!bo->tbo.ttm || bo->tbo.ttm->state != tt_bound)
 				continue;
 
+			/*
+			 * If it is already read only and we are updating to
+			 * read only then we do not need to change anything.
+			 * So save time and skip this one.
+			 */
+			read_only = radeon_ttm_tt_is_readonly(bo->tbo.ttm);
+			if (update_to_read_only && read_only)
+				continue;
+
 			r = radeon_bo_reserve(bo, true);
 			if (r) {
 				DRM_ERROR("(%ld) failed to reserve user bo\n", r);
-- 
2.17.2

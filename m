Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f200.google.com (mail-qk0-f200.google.com [209.85.220.200])
	by kanga.kvack.org (Postfix) with ESMTP id 271B9280300
	for <linux-mm@kvack.org>; Tue, 29 Aug 2017 19:55:10 -0400 (EDT)
Received: by mail-qk0-f200.google.com with SMTP id o63so14201685qkb.4
        for <linux-mm@kvack.org>; Tue, 29 Aug 2017 16:55:10 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id g3si3579731qti.530.2017.08.29.16.55.09
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 29 Aug 2017 16:55:09 -0700 (PDT)
From: =?UTF-8?q?J=C3=A9r=C3=B4me=20Glisse?= <jglisse@redhat.com>
Subject: [PATCH 04/13] drm/amdgpu: update to new mmu_notifier semantic
Date: Tue, 29 Aug 2017 19:54:38 -0400
Message-Id: <20170829235447.10050-5-jglisse@redhat.com>
In-Reply-To: <20170829235447.10050-1-jglisse@redhat.com>
References: <20170829235447.10050-1-jglisse@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org, linux-mm@kvack.org
Cc: =?UTF-8?q?J=C3=A9r=C3=B4me=20Glisse?= <jglisse@redhat.com>, amd-gfx@lists.freedesktop.org, Felix Kuehling <Felix.Kuehling@amd.com>, =?UTF-8?q?Christian=20K=C3=B6nig?= <christian.koenig@amd.com>, Alex Deucher <alexander.deucher@amd.com>, "Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>, Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>

Call to mmu_notifier_invalidate_page() are replaced by call to
mmu_notifier_invalidate_range() and thus call are bracketed by
call to mmu_notifier_invalidate_range_start()/end()

Remove now useless invalidate_page callback.

Signed-off-by: JA(C)rA'me Glisse <jglisse@redhat.com>
Cc: amd-gfx@lists.freedesktop.org
Cc: Felix Kuehling <Felix.Kuehling@amd.com>
Cc: Christian KA?nig <christian.koenig@amd.com>
Cc: Alex Deucher <alexander.deucher@amd.com>
Cc: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
Cc: Andrew Morton <akpm@linux-foundation.org>
Cc: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Andrea Arcangeli <aarcange@redhat.com>
---
 drivers/gpu/drm/amd/amdgpu/amdgpu_mn.c | 31 -------------------------------
 1 file changed, 31 deletions(-)

diff --git a/drivers/gpu/drm/amd/amdgpu/amdgpu_mn.c b/drivers/gpu/drm/amd/amdgpu/amdgpu_mn.c
index 6558a3ed57a7..e1cde6b80027 100644
--- a/drivers/gpu/drm/amd/amdgpu/amdgpu_mn.c
+++ b/drivers/gpu/drm/amd/amdgpu/amdgpu_mn.c
@@ -147,36 +147,6 @@ static void amdgpu_mn_invalidate_node(struct amdgpu_mn_node *node,
 }
 
 /**
- * amdgpu_mn_invalidate_page - callback to notify about mm change
- *
- * @mn: our notifier
- * @mn: the mm this callback is about
- * @address: address of invalidate page
- *
- * Invalidation of a single page. Blocks for all BOs mapping it
- * and unmap them by move them into system domain again.
- */
-static void amdgpu_mn_invalidate_page(struct mmu_notifier *mn,
-				      struct mm_struct *mm,
-				      unsigned long address)
-{
-	struct amdgpu_mn *rmn = container_of(mn, struct amdgpu_mn, mn);
-	struct interval_tree_node *it;
-
-	mutex_lock(&rmn->lock);
-
-	it = interval_tree_iter_first(&rmn->objects, address, address);
-	if (it) {
-		struct amdgpu_mn_node *node;
-
-		node = container_of(it, struct amdgpu_mn_node, it);
-		amdgpu_mn_invalidate_node(node, address, address);
-	}
-
-	mutex_unlock(&rmn->lock);
-}
-
-/**
  * amdgpu_mn_invalidate_range_start - callback to notify about mm change
  *
  * @mn: our notifier
@@ -215,7 +185,6 @@ static void amdgpu_mn_invalidate_range_start(struct mmu_notifier *mn,
 
 static const struct mmu_notifier_ops amdgpu_mn_ops = {
 	.release = amdgpu_mn_release,
-	.invalidate_page = amdgpu_mn_invalidate_page,
 	.invalidate_range_start = amdgpu_mn_invalidate_range_start,
 };
 
-- 
2.13.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

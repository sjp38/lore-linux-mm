Return-Path: <SRS0=Z+ZU=Q2=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 6AA13C43381
	for <linux-mm@archiver.kernel.org>; Tue, 19 Feb 2019 20:04:58 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 2159C21773
	for <linux-mm@archiver.kernel.org>; Tue, 19 Feb 2019 20:04:58 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 2159C21773
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 8B8BD8E0006; Tue, 19 Feb 2019 15:04:56 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 83EB88E0002; Tue, 19 Feb 2019 15:04:56 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 72CF58E0006; Tue, 19 Feb 2019 15:04:56 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f200.google.com (mail-qt1-f200.google.com [209.85.160.200])
	by kanga.kvack.org (Postfix) with ESMTP id 43DC48E0002
	for <linux-mm@kvack.org>; Tue, 19 Feb 2019 15:04:56 -0500 (EST)
Received: by mail-qt1-f200.google.com with SMTP id 35so21129048qtq.5
        for <linux-mm@kvack.org>; Tue, 19 Feb 2019 12:04:56 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=ZuWLtcN1UYxcz3AFIn4HBVvwNrzebalGYVzIwEYwbhQ=;
        b=TX6hDk3CyJIff8TQvakd96YQYtUZ+6GaqyzDVT9KM5uNSyE5TxjFsCFpGYCB5OnJ1B
         S62/tiNQ5gSaOJ3D7N6l0Bbe9l6PYRH5lBv4TCAc31ik4k5jQX9zdk04EWymbHWHJigq
         VkWy03xzMb876igqIm0h8D9hV8plaQLxWha96a5fYQV1DWqfVrWpncQSmtdfvvIg9o4R
         fTfePS8v17LSYQ3NXpTn1zg7Jv1R7NRvlj2/bAwZZmvNS5nkxoEtX9oneZ6OWplgo8PQ
         QacZmPnzOCfevHvruxLrIuxN4kTJo7DbzrNYN7bBFzgLQfk9cz6Uv1dom78P9xGHDYlk
         xH5Q==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jglisse@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: AHQUAuaWSo5tHWozpukdTS8VDRjw6uroucZBY2vdz5/WemlpzH7kNlad
	5KcYhm5DYvigSnbvUqE3poq/EqISu4R7kHLFbLVVLcSkxgaKq1cX2Rpawgf7dcyXsgB4XgegGZQ
	ZaV46zqC6o7prRwmI7OTnFPY9ql1Z3wa9dfBR42CXJeYdRJY74K6/1uxCwLz2aeNuug==
X-Received: by 2002:a37:c04a:: with SMTP id o71mr21521356qki.234.1550606696025;
        Tue, 19 Feb 2019 12:04:56 -0800 (PST)
X-Google-Smtp-Source: AHgI3IaTX1AgDkMqMCRexySUllMAcXodBeQ+AD5IADzyE9H32BZa0XCcSm546qTzDcbiGbfcz8tH
X-Received: by 2002:a37:c04a:: with SMTP id o71mr21521287qki.234.1550606694908;
        Tue, 19 Feb 2019 12:04:54 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1550606694; cv=none;
        d=google.com; s=arc-20160816;
        b=fhOLhSBTR51Kjep+bC0uGs8mgP44jJ6615E/Lw8tKiyNnSjGW5qxOqNFj/8ZLOv5WW
         qc3pnloUi5AEvo5hLPsFVE71kOWdVcKvEnjZQWCdN9sOmBJ/hDmKjCAy8o9fpQA0Y8Lo
         zQT5jDFl1sQf7fg+XRyfI2NtO6Jem31joFLn3HG2nn6VyF1+QTXFU0YvIVr/XGiUMG8h
         TOGb30pbG/b8GkfqErC0X6kSBdUpAy87Xb3/x5J26sB+TOKkqCOM5Dh2Ysr6y9uYwSFy
         RfDZiC7CGFCzpAhTTYP7XMhRjol1AofQvj6SJxyc0SKU5HdypNrtYUp4mU8YuVQC4KvT
         aB+g==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from;
        bh=ZuWLtcN1UYxcz3AFIn4HBVvwNrzebalGYVzIwEYwbhQ=;
        b=d87+D6R1UJcYb5I95+hIBeTsIJuULS/WGwbyNqIHnHcK4nmZlw1Hs6HSnJOEweJkqh
         6Dv8tP/71hbHdnHyFkWsAvvZmZzdjtc9Ax3LnhuyXBNZHlEQn39N1Hht1YJWGgSKZLAr
         ZRrpotsXgeMwF0YFoTSi2Svf7Z/n04Nl2Ca0j9YEcCRgl0wRehoVClBYguVhWgFweFS4
         Pj2KV/xXQ4nEqlaBv7OvuSNBIqpEZKv7X+4A/70LuiZLiJQ/iFzQ2bAMEXwDR4Mv8Su6
         q59sF38/OyQutQNM29OI9sQjo4CtQj4LZQxfnww4gKHM0PNbsf8gNaxIdQLr9uqlvqvd
         qXKg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jglisse@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id a49si1425133qva.62.2019.02.19.12.04.54
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 19 Feb 2019 12:04:54 -0800 (PST)
Received-SPF: pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jglisse@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx01.intmail.prod.int.phx2.redhat.com [10.5.11.11])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id 6C95F29A5D;
	Tue, 19 Feb 2019 20:04:53 +0000 (UTC)
Received: from localhost.localdomain.com (ovpn-122-134.rdu2.redhat.com [10.10.122.134])
	by smtp.corp.redhat.com (Postfix) with ESMTP id 94AB86013C;
	Tue, 19 Feb 2019 20:04:48 +0000 (UTC)
From: jglisse@redhat.com
To: linux-mm@kvack.org,
	Andrew Morton <akpm@linux-foundation.org>
Cc: linux-kernel@vger.kernel.org,
	=?UTF-8?q?J=C3=A9r=C3=B4me=20Glisse?= <jglisse@redhat.com>,
	=?UTF-8?q?Christian=20K=C3=B6nig?= <christian.koenig@amd.com>,
	Joonas Lahtinen <joonas.lahtinen@linux.intel.com>,
	Jani Nikula <jani.nikula@linux.intel.com>,
	Rodrigo Vivi <rodrigo.vivi@intel.com>,
	Jan Kara <jack@suse.cz>,
	Andrea Arcangeli <aarcange@redhat.com>,
	Peter Xu <peterx@redhat.com>,
	Felix Kuehling <Felix.Kuehling@amd.com>,
	Jason Gunthorpe <jgg@mellanox.com>,
	Ross Zwisler <zwisler@kernel.org>,
	Dan Williams <dan.j.williams@intel.com>,
	Paolo Bonzini <pbonzini@redhat.com>,
	=?UTF-8?q?Radim=20Kr=C4=8Dm=C3=A1=C5=99?= <rkrcmar@redhat.com>,
	Michal Hocko <mhocko@kernel.org>,
	Ralph Campbell <rcampbell@nvidia.com>,
	John Hubbard <jhubbard@nvidia.com>,
	kvm@vger.kernel.org,
	dri-devel@lists.freedesktop.org,
	linux-rdma@vger.kernel.org,
	Arnd Bergmann <arnd@arndb.de>
Subject: [PATCH v5 2/9] mm/mmu_notifier: convert user range->blockable to helper function
Date: Tue, 19 Feb 2019 15:04:23 -0500
Message-Id: <20190219200430.11130-3-jglisse@redhat.com>
In-Reply-To: <20190219200430.11130-1-jglisse@redhat.com>
References: <20190219200430.11130-1-jglisse@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.11
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.28]); Tue, 19 Feb 2019 20:04:54 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

From: Jérôme Glisse <jglisse@redhat.com>

Use the mmu_notifier_range_blockable() helper function instead of
directly dereferencing the range->blockable field. This is done to
make it easier to change the mmu_notifier range field.

This patch is the outcome of the following coccinelle patch:

%<-------------------------------------------------------------------
@@
identifier I1, FN;
@@
FN(..., struct mmu_notifier_range *I1, ...) {
<...
-I1->blockable
+mmu_notifier_range_blockable(I1)
...>
}
------------------------------------------------------------------->%

spatch --in-place --sp-file blockable.spatch --dir .

Signed-off-by: Jérôme Glisse <jglisse@redhat.com>
Cc: Christian König <christian.koenig@amd.com>
Cc: Joonas Lahtinen <joonas.lahtinen@linux.intel.com>
Cc: Jani Nikula <jani.nikula@linux.intel.com>
Cc: Rodrigo Vivi <rodrigo.vivi@intel.com>
Cc: Jan Kara <jack@suse.cz>
Cc: Andrea Arcangeli <aarcange@redhat.com>
Cc: Peter Xu <peterx@redhat.com>
Cc: Felix Kuehling <Felix.Kuehling@amd.com>
Cc: Jason Gunthorpe <jgg@mellanox.com>
Cc: Ross Zwisler <zwisler@kernel.org>
Cc: Dan Williams <dan.j.williams@intel.com>
Cc: Paolo Bonzini <pbonzini@redhat.com>
Cc: Radim Krčmář <rkrcmar@redhat.com>
Cc: Michal Hocko <mhocko@kernel.org>
Cc: Christian Koenig <christian.koenig@amd.com>
Cc: Ralph Campbell <rcampbell@nvidia.com>
Cc: John Hubbard <jhubbard@nvidia.com>
Cc: kvm@vger.kernel.org
Cc: dri-devel@lists.freedesktop.org
Cc: linux-rdma@vger.kernel.org
Cc: Arnd Bergmann <arnd@arndb.de>
---
 drivers/gpu/drm/amd/amdgpu/amdgpu_mn.c  | 8 ++++----
 drivers/gpu/drm/i915/i915_gem_userptr.c | 2 +-
 drivers/gpu/drm/radeon/radeon_mn.c      | 4 ++--
 drivers/infiniband/core/umem_odp.c      | 5 +++--
 drivers/xen/gntdev.c                    | 6 +++---
 mm/hmm.c                                | 6 +++---
 mm/mmu_notifier.c                       | 2 +-
 virt/kvm/kvm_main.c                     | 3 ++-
 8 files changed, 19 insertions(+), 17 deletions(-)

diff --git a/drivers/gpu/drm/amd/amdgpu/amdgpu_mn.c b/drivers/gpu/drm/amd/amdgpu/amdgpu_mn.c
index 3e6823fdd939..58ed401c5996 100644
--- a/drivers/gpu/drm/amd/amdgpu/amdgpu_mn.c
+++ b/drivers/gpu/drm/amd/amdgpu/amdgpu_mn.c
@@ -256,14 +256,14 @@ static int amdgpu_mn_invalidate_range_start_gfx(struct mmu_notifier *mn,
 	/* TODO we should be able to split locking for interval tree and
 	 * amdgpu_mn_invalidate_node
 	 */
-	if (amdgpu_mn_read_lock(amn, range->blockable))
+	if (amdgpu_mn_read_lock(amn, mmu_notifier_range_blockable(range)))
 		return -EAGAIN;
 
 	it = interval_tree_iter_first(&amn->objects, range->start, end);
 	while (it) {
 		struct amdgpu_mn_node *node;
 
-		if (!range->blockable) {
+		if (!mmu_notifier_range_blockable(range)) {
 			amdgpu_mn_read_unlock(amn);
 			return -EAGAIN;
 		}
@@ -299,7 +299,7 @@ static int amdgpu_mn_invalidate_range_start_hsa(struct mmu_notifier *mn,
 	/* notification is exclusive, but interval is inclusive */
 	end = range->end - 1;
 
-	if (amdgpu_mn_read_lock(amn, range->blockable))
+	if (amdgpu_mn_read_lock(amn, mmu_notifier_range_blockable(range)))
 		return -EAGAIN;
 
 	it = interval_tree_iter_first(&amn->objects, range->start, end);
@@ -307,7 +307,7 @@ static int amdgpu_mn_invalidate_range_start_hsa(struct mmu_notifier *mn,
 		struct amdgpu_mn_node *node;
 		struct amdgpu_bo *bo;
 
-		if (!range->blockable) {
+		if (!mmu_notifier_range_blockable(range)) {
 			amdgpu_mn_read_unlock(amn);
 			return -EAGAIN;
 		}
diff --git a/drivers/gpu/drm/i915/i915_gem_userptr.c b/drivers/gpu/drm/i915/i915_gem_userptr.c
index 1d3f9a31ad61..777b3f8727e7 100644
--- a/drivers/gpu/drm/i915/i915_gem_userptr.c
+++ b/drivers/gpu/drm/i915/i915_gem_userptr.c
@@ -122,7 +122,7 @@ userptr_mn_invalidate_range_start(struct mmu_notifier *_mn,
 	while (it) {
 		struct drm_i915_gem_object *obj;
 
-		if (!range->blockable) {
+		if (!mmu_notifier_range_blockable(range)) {
 			ret = -EAGAIN;
 			break;
 		}
diff --git a/drivers/gpu/drm/radeon/radeon_mn.c b/drivers/gpu/drm/radeon/radeon_mn.c
index b3019505065a..c9bd1278f573 100644
--- a/drivers/gpu/drm/radeon/radeon_mn.c
+++ b/drivers/gpu/drm/radeon/radeon_mn.c
@@ -133,7 +133,7 @@ static int radeon_mn_invalidate_range_start(struct mmu_notifier *mn,
 	/* TODO we should be able to split locking for interval tree and
 	 * the tear down.
 	 */
-	if (range->blockable)
+	if (mmu_notifier_range_blockable(range))
 		mutex_lock(&rmn->lock);
 	else if (!mutex_trylock(&rmn->lock))
 		return -EAGAIN;
@@ -144,7 +144,7 @@ static int radeon_mn_invalidate_range_start(struct mmu_notifier *mn,
 		struct radeon_bo *bo;
 		long r;
 
-		if (!range->blockable) {
+		if (!mmu_notifier_range_blockable(range)) {
 			ret = -EAGAIN;
 			goto out_unlock;
 		}
diff --git a/drivers/infiniband/core/umem_odp.c b/drivers/infiniband/core/umem_odp.c
index 012044f16d1c..3a3f1538d295 100644
--- a/drivers/infiniband/core/umem_odp.c
+++ b/drivers/infiniband/core/umem_odp.c
@@ -151,7 +151,7 @@ static int ib_umem_notifier_invalidate_range_start(struct mmu_notifier *mn,
 	struct ib_ucontext_per_mm *per_mm =
 		container_of(mn, struct ib_ucontext_per_mm, mn);
 
-	if (range->blockable)
+	if (mmu_notifier_range_blockable(range))
 		down_read(&per_mm->umem_rwsem);
 	else if (!down_read_trylock(&per_mm->umem_rwsem))
 		return -EAGAIN;
@@ -169,7 +169,8 @@ static int ib_umem_notifier_invalidate_range_start(struct mmu_notifier *mn,
 	return rbt_ib_umem_for_each_in_range(&per_mm->umem_tree, range->start,
 					     range->end,
 					     invalidate_range_start_trampoline,
-					     range->blockable, NULL);
+					     mmu_notifier_range_blockable(range),
+					     NULL);
 }
 
 static int invalidate_range_end_trampoline(struct ib_umem_odp *item, u64 start,
diff --git a/drivers/xen/gntdev.c b/drivers/xen/gntdev.c
index 5efc5eee9544..9da8f7192f46 100644
--- a/drivers/xen/gntdev.c
+++ b/drivers/xen/gntdev.c
@@ -526,20 +526,20 @@ static int mn_invl_range_start(struct mmu_notifier *mn,
 	struct gntdev_grant_map *map;
 	int ret = 0;
 
-	if (range->blockable)
+	if (mmu_notifier_range_blockable(range))
 		mutex_lock(&priv->lock);
 	else if (!mutex_trylock(&priv->lock))
 		return -EAGAIN;
 
 	list_for_each_entry(map, &priv->maps, next) {
 		ret = unmap_if_in_range(map, range->start, range->end,
-					range->blockable);
+					mmu_notifier_range_blockable(range));
 		if (ret)
 			goto out_unlock;
 	}
 	list_for_each_entry(map, &priv->freeable_maps, next) {
 		ret = unmap_if_in_range(map, range->start, range->end,
-					range->blockable);
+					mmu_notifier_range_blockable(range));
 		if (ret)
 			goto out_unlock;
 	}
diff --git a/mm/hmm.c b/mm/hmm.c
index 3c9781037918..a03b5083d880 100644
--- a/mm/hmm.c
+++ b/mm/hmm.c
@@ -205,9 +205,9 @@ static int hmm_invalidate_range_start(struct mmu_notifier *mn,
 	update.start = nrange->start;
 	update.end = nrange->end;
 	update.event = HMM_UPDATE_INVALIDATE;
-	update.blockable = nrange->blockable;
+	update.blockable = mmu_notifier_range_blockable(nrange);
 
-	if (nrange->blockable)
+	if (mmu_notifier_range_blockable(nrange))
 		mutex_lock(&hmm->lock);
 	else if (!mutex_trylock(&hmm->lock)) {
 		ret = -EAGAIN;
@@ -222,7 +222,7 @@ static int hmm_invalidate_range_start(struct mmu_notifier *mn,
 	}
 	mutex_unlock(&hmm->lock);
 
-	if (nrange->blockable)
+	if (mmu_notifier_range_blockable(nrange))
 		down_read(&hmm->mirrors_sem);
 	else if (!down_read_trylock(&hmm->mirrors_sem)) {
 		ret = -EAGAIN;
diff --git a/mm/mmu_notifier.c b/mm/mmu_notifier.c
index 9c884abc7850..abd88c466eb2 100644
--- a/mm/mmu_notifier.c
+++ b/mm/mmu_notifier.c
@@ -180,7 +180,7 @@ int __mmu_notifier_invalidate_range_start(struct mmu_notifier_range *range)
 			if (_ret) {
 				pr_info("%pS callback failed with %d in %sblockable context.\n",
 					mn->ops->invalidate_range_start, _ret,
-					!range->blockable ? "non-" : "");
+					!mmu_notifier_range_blockable(range) ? "non-" : "");
 				ret = _ret;
 			}
 		}
diff --git a/virt/kvm/kvm_main.c b/virt/kvm/kvm_main.c
index 38df17b7760e..629760c0fb95 100644
--- a/virt/kvm/kvm_main.c
+++ b/virt/kvm/kvm_main.c
@@ -386,7 +386,8 @@ static int kvm_mmu_notifier_invalidate_range_start(struct mmu_notifier *mn,
 	spin_unlock(&kvm->mmu_lock);
 
 	ret = kvm_arch_mmu_notifier_invalidate_range(kvm, range->start,
-					range->end, range->blockable);
+					range->end,
+					mmu_notifier_range_blockable(range));
 
 	srcu_read_unlock(&kvm->srcu, idx);
 
-- 
2.17.2


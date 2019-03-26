Return-Path: <SRS0=c5Kt=R5=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,URIBL_BLOCKED
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id DA16CC43381
	for <linux-mm@archiver.kernel.org>; Tue, 26 Mar 2019 16:48:09 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 87E86205F4
	for <linux-mm@archiver.kernel.org>; Tue, 26 Mar 2019 16:48:09 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 87E86205F4
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 253BD6B000D; Tue, 26 Mar 2019 12:48:09 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 205176B000E; Tue, 26 Mar 2019 12:48:09 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 0D1206B028D; Tue, 26 Mar 2019 12:48:09 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f197.google.com (mail-qk1-f197.google.com [209.85.222.197])
	by kanga.kvack.org (Postfix) with ESMTP id D10016B000D
	for <linux-mm@kvack.org>; Tue, 26 Mar 2019 12:48:08 -0400 (EDT)
Received: by mail-qk1-f197.google.com with SMTP id k21so12085534qkg.19
        for <linux-mm@kvack.org>; Tue, 26 Mar 2019 09:48:08 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=IoaIeKySqTbuYcbt1VrYg4qHpnesClR2CyNU6akPjSw=;
        b=ahAmFOaGoi2V+PX8Ldp6Ae1s8v0YpahV2iAJ7nktOiYoYd2/JlOcLE8NZFam6di6lJ
         8djKOPWzXgA/0bi7gcTEfM/xqi/hQAzKgu9PlZKaDKisKTSiWRf2beDZ9T+6yup91BV2
         9VuyspM1lF6uXsWGRQHVo1ksht8B46yJc+6RdNEkjC3y9inDcLlacz99zqKGo2bsoBK/
         XUh9GafqbhOGFQCHQ6xvmfxjbMrKC7b+Zn864y9gr/B0FD6n7d5FmEbjqD6uI5GNiRfa
         69WiGKQ5wlnHOAJLqO7DU8dpvF9wGPCVCOzKJX+hpM6mUs4mbMyMlb/wTkhniyieDp0y
         qHyQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jglisse@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: APjAAAWKFQWsreuz0Cw8Z+/7IsfMNY2EOPjeBKNZX/ptvG7VFBHHz3ap
	hsCSYBT1wuiru3Kegjm1gC5Ice/stYGPCPD/p5Z55pUXgRWtmDUAuVtACKh+OrQIzBu1Bk3I8LW
	Tcva5rmdqEU4S2JrwJ0hU4TO89RYt9HpQhpb4oLWLYa3cO0tvT7TcCz9xUwDkkQ5JAg==
X-Received: by 2002:a0c:8445:: with SMTP id l63mr26578500qva.187.1553618888111;
        Tue, 26 Mar 2019 09:48:08 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzsrMwC3ry8U9vm6VZ7IF8cmQr0Fl65fRM2blZ5NTp7xWWaBOUJL4K6ihlnS4TRYvFrSwF8
X-Received: by 2002:a0c:8445:: with SMTP id l63mr26578421qva.187.1553618886967;
        Tue, 26 Mar 2019 09:48:06 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1553618886; cv=none;
        d=google.com; s=arc-20160816;
        b=0HcaAJMIOk5rb277GmrF8IB1mVeedq9W/ntbDhqy6yHG7tQDE654+0BenSRLiCnGnw
         nmbwccEq8C+hXb9nfvEXoK88NKxgCPmA90Cw0O7gswIu62GLywTMOoQnlIRw7jwf4yMT
         u8RhE0RJjx/aWBcohmAAznYfgEtRiO2ukKFskSoQ0msxS18fA4nmg+gHJPMzplI3rAIU
         kkdR2m4LAaduRlKRhmkwZ0IZvs6piUoXXVLGxQ8ie2eWMMFjxfX14n88kHuzAOeV04q9
         DMb6nV4ZHkI7s7tAhEnKw1zefWLI0/JuzSYofv/I1Wba8eUISfio/bmFLyjEYblV9r0I
         GNMg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from;
        bh=IoaIeKySqTbuYcbt1VrYg4qHpnesClR2CyNU6akPjSw=;
        b=f3UzUU/8+spZn0ovjW2pwxHxTDk705tlzNpO/ZDPNYJIwRRt1ZoPWChjWVvhrg5Z1h
         Itg6YJklfYhmfl88J01AzW3lsOBgw+8ksPrb+GZtz3aXJ9ZgEGOjZgWvWGQua9uwZM7o
         JvfoxKRBFYSr/BhKZ8gPsYMIaYW7RUrk1jkNfeeVmCvddKYvH32yWeBzQKbLUHRHYR01
         1nruP9QjsqrUN5bDSVD3Fbq3qQKzLv3YYg24903lS95CPcyejBWTwqGWtZYvkrhsTSlZ
         mgQf6M6EoOk/NN9AZKuVCDYUPXAdVR5W6CinXuXcWTDLd/uM1OMF7O5170MIfbak1V/J
         ru3w==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jglisse@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id r7si2788060qtj.61.2019.03.26.09.48.06
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 26 Mar 2019 09:48:06 -0700 (PDT)
Received-SPF: pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jglisse@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx05.intmail.prod.int.phx2.redhat.com [10.5.11.15])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id E73168667D;
	Tue, 26 Mar 2019 16:48:05 +0000 (UTC)
Received: from localhost.localdomain.com (unknown [10.20.6.236])
	by smtp.corp.redhat.com (Postfix) with ESMTP id C19FB62669;
	Tue, 26 Mar 2019 16:48:03 +0000 (UTC)
From: jglisse@redhat.com
To: linux-kernel@vger.kernel.org
Cc: =?UTF-8?q?J=C3=A9r=C3=B4me=20Glisse?= <jglisse@redhat.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	linux-mm@kvack.org,
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
Subject: [PATCH v6 2/8] mm/mmu_notifier: convert user range->blockable to helper function
Date: Tue, 26 Mar 2019 12:47:41 -0400
Message-Id: <20190326164747.24405-3-jglisse@redhat.com>
In-Reply-To: <20190326164747.24405-1-jglisse@redhat.com>
References: <20190326164747.24405-1-jglisse@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.15
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.26]); Tue, 26 Mar 2019 16:48:06 +0000 (UTC)
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
Cc: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org
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
index e6ec79ad9cc8..59ef912fbe03 100644
--- a/drivers/infiniband/core/umem_odp.c
+++ b/drivers/infiniband/core/umem_odp.c
@@ -152,7 +152,7 @@ static int ib_umem_notifier_invalidate_range_start(struct mmu_notifier *mn,
 	struct ib_ucontext_per_mm *per_mm =
 		container_of(mn, struct ib_ucontext_per_mm, mn);
 
-	if (range->blockable)
+	if (mmu_notifier_range_blockable(range))
 		down_read(&per_mm->umem_rwsem);
 	else if (!down_read_trylock(&per_mm->umem_rwsem))
 		return -EAGAIN;
@@ -170,7 +170,8 @@ static int ib_umem_notifier_invalidate_range_start(struct mmu_notifier *mn,
 	return rbt_ib_umem_for_each_in_range(&per_mm->umem_tree, range->start,
 					     range->end,
 					     invalidate_range_start_trampoline,
-					     range->blockable, NULL);
+					     mmu_notifier_range_blockable(range),
+					     NULL);
 }
 
 static int invalidate_range_end_trampoline(struct ib_umem_odp *item, u64 start,
diff --git a/drivers/xen/gntdev.c b/drivers/xen/gntdev.c
index 7cf9c51318aa..8012ab7f5120 100644
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
index fd143251b157..25f372da325a 100644
--- a/mm/hmm.c
+++ b/mm/hmm.c
@@ -201,9 +201,9 @@ static int hmm_invalidate_range_start(struct mmu_notifier *mn,
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
@@ -218,7 +218,7 @@ static int hmm_invalidate_range_start(struct mmu_notifier *mn,
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
index f25aa98a94df..16edfc3e0d1a 100644
--- a/virt/kvm/kvm_main.c
+++ b/virt/kvm/kvm_main.c
@@ -391,7 +391,8 @@ static int kvm_mmu_notifier_invalidate_range_start(struct mmu_notifier *mn,
 	spin_unlock(&kvm->mmu_lock);
 
 	ret = kvm_arch_mmu_notifier_invalidate_range(kvm, range->start,
-					range->end, range->blockable);
+					range->end,
+					mmu_notifier_range_blockable(range));
 
 	srcu_read_unlock(&kvm->srcu, idx);
 
-- 
2.20.1


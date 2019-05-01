Return-Path: <SRS0=L4L0=TB=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,USER_AGENT_GIT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 8D8A4C43219
	for <linux-mm@archiver.kernel.org>; Wed,  1 May 2019 14:03:18 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 49DFA21670
	for <linux-mm@archiver.kernel.org>; Wed,  1 May 2019 14:03:18 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 49DFA21670
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 85CD96B000E; Wed,  1 May 2019 10:03:09 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 811186B0010; Wed,  1 May 2019 10:03:09 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 6FD196B0266; Wed,  1 May 2019 10:03:09 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f198.google.com (mail-pf1-f198.google.com [209.85.210.198])
	by kanga.kvack.org (Postfix) with ESMTP id 3952C6B000E
	for <linux-mm@kvack.org>; Wed,  1 May 2019 10:03:09 -0400 (EDT)
Received: by mail-pf1-f198.google.com with SMTP id j18so11041855pfi.20
        for <linux-mm@kvack.org>; Wed, 01 May 2019 07:03:09 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to
         :subject:date:message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=7DuZmk//m+TJEgso8niAEXIhBVD4m+iZUrt06/JgkP4=;
        b=SHYlkSHISQC80LWu4ZY5NokUT082aj/DpNCoKt57T6rhClRtDMkSzSIfmEpOkSyR7/
         rJwSs0SDHpALgoLr2GHYnc9yHPboxHbp7ZGZYZobZTv2P11y5/LRRXEisO6lne/dfGSs
         wpAMnJcmGIdyE9HTeZRbyRPChwei2+X15S29yo+DOOdvNCdRILjQZ2iJaXsKvCCW03KQ
         IUJNA/6VKJfe9C7C+NCKZeC8gS2eTR14xT9G5uQVfQ2PuXrlP0OWBN6UTnJEYCuRlFrc
         LVAOC/XYDWYaao4aoNQeC6NO5bgTcCl18ipJakkeebetB1bmkxKmRXsEyHQBHQhRrV9c
         wrxA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of brian.welty@intel.com designates 192.55.52.43 as permitted sender) smtp.mailfrom=brian.welty@intel.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Gm-Message-State: APjAAAUh4yCA0/zht1F8VzLwqBpr1898oSLk64C7B7naPMc1ppZNCa8x
	oui9zw8A36bRfCt24YtesNvuakBsUqqbwuzywlrKzBdtRv/nJJha4JBqbM+8IaV38jnCZBanpUg
	McAu1FzNGmIz29Lym2i69RMr/NiD9lnp8jaDuXKmpAOOm4MbzFdof7QWuT4N9KTqQXQ==
X-Received: by 2002:a62:2e02:: with SMTP id u2mr40965629pfu.1.1556719388885;
        Wed, 01 May 2019 07:03:08 -0700 (PDT)
X-Google-Smtp-Source: APXvYqysB6+eCd8FcUMA9rqHrQ643s9nx20VUH0Dmk087QuEmYuRgBS5z67LO8aC8mwjekvhzoGo
X-Received: by 2002:a62:2e02:: with SMTP id u2mr40965513pfu.1.1556719387936;
        Wed, 01 May 2019 07:03:07 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1556719387; cv=none;
        d=google.com; s=arc-20160816;
        b=OakM+FJ2P8kXna3xoVT9lsjKCC1dpjZATCUr1/Q+31ZMpuquDQBhJjh6p2yMcx2T9V
         JGhr87us7zh6fRhQzY6B+2Hf0/OYNAKAsZ2/epwP57bJzI3VGyvkxawFkmGBh7PKZFCD
         Tb4xy/kF6E0l9HfkzGd2lsJCK7oFHlDOgj2NSWRiQPTTy4nr23ADbIB8HBp/1xcbOYYY
         jYM9VWymYxIiaB3SqTk6fc7xHdVkR74gDVeOyCqvs9nMyAkNPvVUCinK6LhhAbtQcy7U
         gwXa1IiH5r/DFHi3FjM+uDLXjoikMZGobQQUVpNVkqG2Bv7PVC/NTcXfBXlnqpSdcPTw
         9SOw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:to:from;
        bh=7DuZmk//m+TJEgso8niAEXIhBVD4m+iZUrt06/JgkP4=;
        b=JeVUrudWvzaF4HBJqteckZaoKfhELwO/EQOOLnzm3DaeWNeE7/Oes8bNYate+A4zAj
         4KphnX1YgK0LbFo+9hj3UR8iOhy8swjwXt/qAtFghZpGXHGzi1yBcjAy8fc0TjAgtYam
         N7M4/RauQPTgNeh11RvMdOSknIDhzl8WuAGv970Mif2WSs80u0Lfl4ai9GqhJ/m2dAHa
         Wix8Lqv1JqhpAbp3V3J1OozpiA+mBXGKJFgN5VAZoCYTkaxJp/Z2kHPVnG5oLMv9czmV
         aQisqpRLWRKM1fFXg2gTLD0D3/ZXTDR7p/Yuv5BohtAszG8rn/hkvM81iSoBWxju7tHg
         UeQg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of brian.welty@intel.com designates 192.55.52.43 as permitted sender) smtp.mailfrom=brian.welty@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mga05.intel.com (mga05.intel.com. [192.55.52.43])
        by mx.google.com with ESMTPS id q25si38000486pgv.534.2019.05.01.07.03.07
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 01 May 2019 07:03:07 -0700 (PDT)
Received-SPF: pass (google.com: domain of brian.welty@intel.com designates 192.55.52.43 as permitted sender) client-ip=192.55.52.43;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of brian.welty@intel.com designates 192.55.52.43 as permitted sender) smtp.mailfrom=brian.welty@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Amp-Result: SKIPPED(no attachment in message)
X-Amp-File-Uploaded: False
Received: from fmsmga008.fm.intel.com ([10.253.24.58])
  by fmsmga105.fm.intel.com with ESMTP/TLS/DHE-RSA-AES256-GCM-SHA384; 01 May 2019 07:03:07 -0700
X-ExtLoop1: 1
X-IronPort-AV: E=Sophos;i="5.60,417,1549958400"; 
   d="scan'208";a="145141419"
Received: from nperf12.hd.intel.com ([10.127.88.161])
  by fmsmga008.fm.intel.com with ESMTP; 01 May 2019 07:03:06 -0700
From: Brian Welty <brian.welty@intel.com>
To: cgroups@vger.kernel.org,
	Tejun Heo <tj@kernel.org>,
	Li Zefan <lizefan@huawei.com>,
	Johannes Weiner <hannes@cmpxchg.org>,
	linux-mm@kvack.org,
	Michal Hocko <mhocko@kernel.org>,
	Vladimir Davydov <vdavydov.dev@gmail.com>,
	dri-devel@lists.freedesktop.org,
	David Airlie <airlied@linux.ie>,
	Daniel Vetter <daniel@ffwll.ch>,
	intel-gfx@lists.freedesktop.org,
	Jani Nikula <jani.nikula@linux.intel.com>,
	Joonas Lahtinen <joonas.lahtinen@linux.intel.com>,
	Rodrigo Vivi <rodrigo.vivi@intel.com>,
	=?UTF-8?q?Christian=20K=C3=B6nig?= <christian.koenig@amd.com>,
	Alex Deucher <alexander.deucher@amd.com>,
	ChunMing Zhou <David1.Zhou@amd.com>,
	=?UTF-8?q?J=C3=A9r=C3=B4me=20Glisse?= <jglisse@redhat.com>
Subject: [RFC PATCH 5/5] drm/i915: Use memory cgroup for enforcing device memory limit
Date: Wed,  1 May 2019 10:04:38 -0400
Message-Id: <20190501140438.9506-6-brian.welty@intel.com>
X-Mailer: git-send-email 2.21.0
In-Reply-To: <20190501140438.9506-1-brian.welty@intel.com>
References: <20190501140438.9506-1-brian.welty@intel.com>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

i915 driver now includes DRIVER_CGROUPS in feature bits.

To charge device memory allocations, we need to (1) identify appropriate
cgroup to charge (currently decided at object creation time), and (2)
make the charging call at the time that memory pages are being allocated.

For (1), see prior DRM patch which associates current task's cgroup with
GEM objects as they are created.  That cgroup will be charged/uncharged
for all paging activity against the GEM object.

For (2), we call mem_cgroup_try_charge_direct() in .get_pages callback
for the GEM object type.  Uncharging is done in .put_pages when the
memory is marked such that it can be evicted.  The try_charge() call will
fail with -ENOMEM if the current memory allocation will exceed the cgroup
device memory maximum, and allow for driver to perform memory reclaim.

Cc: cgroups@vger.kernel.org
Cc: linux-mm@kvack.org
Cc: dri-devel@lists.freedesktop.org
Cc: Matt Roper <matthew.d.roper@intel.com>
Signed-off-by: Brian Welty <brian.welty@intel.com>
---
 drivers/gpu/drm/i915/i915_drv.c            |  2 +-
 drivers/gpu/drm/i915/intel_memory_region.c | 24 ++++++++++++++++++----
 2 files changed, 21 insertions(+), 5 deletions(-)

diff --git a/drivers/gpu/drm/i915/i915_drv.c b/drivers/gpu/drm/i915/i915_drv.c
index 5a0a59922cb4..4d496c3c3681 100644
--- a/drivers/gpu/drm/i915/i915_drv.c
+++ b/drivers/gpu/drm/i915/i915_drv.c
@@ -3469,7 +3469,7 @@ static struct drm_driver driver = {
 	 * deal with them for Intel hardware.
 	 */
 	.driver_features =
-	    DRIVER_GEM | DRIVER_PRIME |
+	    DRIVER_GEM | DRIVER_PRIME | DRIVER_CGROUPS |
 	    DRIVER_RENDER | DRIVER_MODESET | DRIVER_ATOMIC | DRIVER_SYNCOBJ,
 	.release = i915_driver_release,
 	.open = i915_driver_open,
diff --git a/drivers/gpu/drm/i915/intel_memory_region.c b/drivers/gpu/drm/i915/intel_memory_region.c
index 813ff83c132b..e4ac5e4d4857 100644
--- a/drivers/gpu/drm/i915/intel_memory_region.c
+++ b/drivers/gpu/drm/i915/intel_memory_region.c
@@ -53,6 +53,8 @@ i915_memory_region_put_pages_buddy(struct drm_i915_gem_object *obj,
 	mutex_unlock(&obj->memory_region->mm_lock);
 
 	obj->mm.dirty = false;
+	mem_cgroup_uncharge_direct(obj->base.memcg,
+				   obj->base.size >> PAGE_SHIFT);
 }
 
 int
@@ -65,19 +67,29 @@ i915_memory_region_get_pages_buddy(struct drm_i915_gem_object *obj)
 	struct scatterlist *sg;
 	unsigned int sg_page_sizes;
 	unsigned long n_pages;
+	int err;
 
 	GEM_BUG_ON(!IS_ALIGNED(size, mem->mm.min_size));
 	GEM_BUG_ON(!list_empty(&obj->blocks));
 
+	err = mem_cgroup_try_charge_direct(obj->base.memcg, size >> PAGE_SHIFT);
+	if (err) {
+		DRM_DEBUG("MEMCG: try_charge failed for %lld\n", size);
+		return err;
+	}
+
 	st = kmalloc(sizeof(*st), GFP_KERNEL);
-	if (!st)
-		return -ENOMEM;
+	if (!st) {
+		err = -ENOMEM;
+		goto err_uncharge;
+	}
 
 	n_pages = div64_u64(size, mem->mm.min_size);
 
 	if (sg_alloc_table(st, n_pages, GFP_KERNEL)) {
 		kfree(st);
-		return -ENOMEM;
+		err = -ENOMEM;
+		goto err_uncharge;
 	}
 
 	sg = st->sgl;
@@ -161,7 +173,11 @@ i915_memory_region_get_pages_buddy(struct drm_i915_gem_object *obj)
 err_free_blocks:
 	memory_region_free_pages(obj, st);
 	mutex_unlock(&mem->mm_lock);
-	return -ENXIO;
+	err = -ENXIO;
+err_uncharge:
+	mem_cgroup_uncharge_direct(obj->base.memcg,
+				   obj->base.size >> PAGE_SHIFT);
+	return err;
 }
 
 int i915_memory_region_init_buddy(struct intel_memory_region *mem)
-- 
2.21.0


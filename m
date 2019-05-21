Return-Path: <SRS0=IGNm=TV=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	URIBL_BLOCKED,USER_AGENT_GIT autolearn=unavailable autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 0409DC04E87
	for <linux-mm@archiver.kernel.org>; Tue, 21 May 2019 04:53:08 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id BA29121783
	for <linux-mm@archiver.kernel.org>; Tue, 21 May 2019 04:53:07 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org BA29121783
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=stgolabs.net
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 879686B0007; Tue, 21 May 2019 00:53:06 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 677926B0008; Tue, 21 May 2019 00:53:06 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 454A46B000C; Tue, 21 May 2019 00:53:06 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f71.google.com (mail-ed1-f71.google.com [209.85.208.71])
	by kanga.kvack.org (Postfix) with ESMTP id EA5366B0007
	for <linux-mm@kvack.org>; Tue, 21 May 2019 00:53:05 -0400 (EDT)
Received: by mail-ed1-f71.google.com with SMTP id y12so28687421ede.19
        for <linux-mm@kvack.org>; Mon, 20 May 2019 21:53:05 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references;
        bh=NrTsgDq9F5o4NLlcJGFlvDuokv4X+sdo2Fo8h4tGyWs=;
        b=tyYq0DoAOqGMMlkUTIQvPpj9vW9xJju8Dys/vXOsbDKNZ+7YgaSKyh1VFbJNk2I3rU
         fIWNcc7HLASQP5L4V7bO929TnqQHtN1jnzBMVD3wcIJuykcs+WJCLYdnoSV5kCOBkVwa
         1xSGu47R7+YHsb8lLAfIjRUgmdw4ZxDalMdMaCFm+dWnyb9FZsPiTU1Bkr1SOW2GbV5G
         H66SzmMwD0S0uBH149YSxkMvCL13WlFZ19TSL0tnUfW19gGmN88J5ik5yrT6abwJgJyK
         7ljYjgeX3U1tSx864RhEJ6ihIMDSdSl1j/Q6zg8dC56lTB0ulLgIZdaKNm0dKdrvsTcL
         mkzw==
X-Original-Authentication-Results: mx.google.com;       spf=softfail (google.com: domain of transitioning dave@stgolabs.net does not designate 195.135.221.5 as permitted sender) smtp.mailfrom=dave@stgolabs.net
X-Gm-Message-State: APjAAAWFx9gjBr1P+C5QI31GljkD765Sdu36m5qjABdkVat3xgTHIjrg
	W03B286L0vCkaYroZfllJmH96aYQj3ukJrcryyawxqSC3ECQ+738b0D+KN861zo+pEZ0kFDBQnS
	mhotgDVqDMJn2V8oSw0NAldXSA4Zv4brAJZJZZFnWCLKkMZ+hXYtZCCxDAurtl1o=
X-Received: by 2002:a50:9581:: with SMTP id w1mr80216439eda.6.1558414385463;
        Mon, 20 May 2019 21:53:05 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwfbkc6XlTQNPrIt2qUKwqv59Ic9wV0zaDGIXXuztfE4osMRAoharAWpS/NWXwANMnE7kld
X-Received: by 2002:a50:9581:: with SMTP id w1mr80216351eda.6.1558414384083;
        Mon, 20 May 2019 21:53:04 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1558414384; cv=none;
        d=google.com; s=arc-20160816;
        b=hbAzi7CDcB38qaaZoF3eTqmM11ADRldnYdGsDYVNuAN6FJRgARmsFv8hJkB60irhhv
         8KDK6Ip8/yg/aIbpMVgeCjPdfb4z4D9TJfZZopnM8bZRsp6YomuHxFyX/GmBhi3UmL4i
         BslHOCIelutENhPVEzagCiyLTH5t3IY12asA2KKL2qQoCn1voX/A3M0zb+E3HocKSWZa
         PDLTnz5Bxlwh6UWE2jl4qWnIUZEu1jfdE+tChWYpvDwKJ+z3LXDFMx2AiFTswUv/95wM
         Qt39TT5oG3MkvcrLG2PttciV6+PKsC2kooCgAsUND2RSdIUN4Uur8gPlvivLY2nYLfAD
         jzxQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=references:in-reply-to:message-id:date:subject:cc:to:from;
        bh=NrTsgDq9F5o4NLlcJGFlvDuokv4X+sdo2Fo8h4tGyWs=;
        b=YS0DfwasNnC/6XK1HUlUATI2doiSmReW0Q4s3rim+QZNHLuTVV+f5eAvV/fa+OKzk1
         SNkK8MUKptg3PDpc6qTXUe43GDQFmhtNfo4lyCivU0NEe7u6syFvp3ten8oFf/rbfaKu
         VSSfDEFRqTdKUdh0BkBE5fFapGtr93ous1nOcWbN+f874bHem4/xXTvGWtj0YN5s4BkL
         XjIK2mf0pIPLfgWQeoD5cLp42UARziEybddVqWYcl7UA1u6FJejjCUFpq3tI1RuEhBYM
         ywbxzwqxVq5Wet3t6zh6n+DybwLsgvlXDmC0NzUV4yLWw4qKQPmagb2zjgkdBCUQM9WP
         SLnw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=softfail (google.com: domain of transitioning dave@stgolabs.net does not designate 195.135.221.5 as permitted sender) smtp.mailfrom=dave@stgolabs.net
Received: from smtp.nue.novell.com (smtp.nue.novell.com. [195.135.221.5])
        by mx.google.com with ESMTPS id hb9si3894244ejb.235.2019.05.20.21.53.03
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 20 May 2019 21:53:04 -0700 (PDT)
Received-SPF: softfail (google.com: domain of transitioning dave@stgolabs.net does not designate 195.135.221.5 as permitted sender) client-ip=195.135.221.5;
Authentication-Results: mx.google.com;
       spf=softfail (google.com: domain of transitioning dave@stgolabs.net does not designate 195.135.221.5 as permitted sender) smtp.mailfrom=dave@stgolabs.net
Received: from emea4-mta.ukb.novell.com ([10.120.13.87])
	by smtp.nue.novell.com with ESMTP (TLS encrypted); Tue, 21 May 2019 06:53:03 +0200
Received: from linux-r8p5.suse.de (nwb-a10-snat.microfocus.com [10.120.13.201])
	by emea4-mta.ukb.novell.com with ESMTP (TLS encrypted); Tue, 21 May 2019 05:52:57 +0100
From: Davidlohr Bueso <dave@stgolabs.net>
To: linux-mm@kvack.org,
	linux-kernel@vger.kernel.org
Cc: akpm@linux-foundation.org,
	willy@infradead.org,
	mhocko@kernel.org,
	mgorman@techsingularity.net,
	jglisse@redhat.com,
	ldufour@linux.vnet.ibm.com,
	dave@stgolabs.net,
	Davidlohr Bueso <dbueso@suse.de>
Subject: [PATCH 01/14] interval-tree: build unconditionally
Date: Mon, 20 May 2019 21:52:29 -0700
Message-Id: <20190521045242.24378-2-dave@stgolabs.net>
X-Mailer: git-send-email 2.16.4
In-Reply-To: <20190521045242.24378-1-dave@stgolabs.net>
References: <20190521045242.24378-1-dave@stgolabs.net>
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

In preparation for range locking, this patch gets rid of
CONFIG_INTERVAL_TREE option as we will unconditionally
build it.

Signed-off-by: Davidlohr Bueso <dbueso@suse.de>
---
 drivers/gpu/drm/Kconfig      |  2 --
 drivers/gpu/drm/i915/Kconfig |  1 -
 drivers/iommu/Kconfig        |  1 -
 lib/Kconfig                  | 14 --------------
 lib/Kconfig.debug            |  1 -
 lib/Makefile                 |  3 +--
 6 files changed, 1 insertion(+), 21 deletions(-)

diff --git a/drivers/gpu/drm/Kconfig b/drivers/gpu/drm/Kconfig
index e360a4a131e1..3405336175ed 100644
--- a/drivers/gpu/drm/Kconfig
+++ b/drivers/gpu/drm/Kconfig
@@ -200,7 +200,6 @@ config DRM_RADEON
 	select POWER_SUPPLY
 	select HWMON
 	select BACKLIGHT_CLASS_DEVICE
-	select INTERVAL_TREE
 	help
 	  Choose this option if you have an ATI Radeon graphics card.  There
 	  are both PCI and AGP versions.  You don't need to choose this to
@@ -220,7 +219,6 @@ config DRM_AMDGPU
 	select POWER_SUPPLY
 	select HWMON
 	select BACKLIGHT_CLASS_DEVICE
-	select INTERVAL_TREE
 	select CHASH
 	help
 	  Choose this option if you have a recent AMD Radeon graphics card.
diff --git a/drivers/gpu/drm/i915/Kconfig b/drivers/gpu/drm/i915/Kconfig
index 3d5f1cb6a76c..54d4bc8d141f 100644
--- a/drivers/gpu/drm/i915/Kconfig
+++ b/drivers/gpu/drm/i915/Kconfig
@@ -3,7 +3,6 @@ config DRM_I915
 	depends on DRM
 	depends on X86 && PCI
 	select INTEL_GTT
-	select INTERVAL_TREE
 	# we need shmfs for the swappable backing store, and in particular
 	# the shmem_readpage() which depends upon tmpfs
 	select SHMEM
diff --git a/drivers/iommu/Kconfig b/drivers/iommu/Kconfig
index a2ed2b51a0f7..d21e6dc2adae 100644
--- a/drivers/iommu/Kconfig
+++ b/drivers/iommu/Kconfig
@@ -477,7 +477,6 @@ config VIRTIO_IOMMU
 	depends on VIRTIO=y
 	depends on ARM64
 	select IOMMU_API
-	select INTERVAL_TREE
 	help
 	  Para-virtualised IOMMU driver with virtio.
 
diff --git a/lib/Kconfig b/lib/Kconfig
index 8d9239a4156c..e089ac40c062 100644
--- a/lib/Kconfig
+++ b/lib/Kconfig
@@ -409,20 +409,6 @@ config TEXTSEARCH_FSM
 config BTREE
 	bool
 
-config INTERVAL_TREE
-	bool
-	help
-	  Simple, embeddable, interval-tree. Can find the start of an
-	  overlapping range in log(n) time and then iterate over all
-	  overlapping nodes. The algorithm is implemented as an
-	  augmented rbtree.
-
-	  See:
-
-		Documentation/rbtree.txt
-
-	  for more information.
-
 config XARRAY_MULTI
 	bool
 	help
diff --git a/lib/Kconfig.debug b/lib/Kconfig.debug
index 4c35e52c5a2e..54bafed8ba70 100644
--- a/lib/Kconfig.debug
+++ b/lib/Kconfig.debug
@@ -1759,7 +1759,6 @@ config RBTREE_TEST
 config INTERVAL_TREE_TEST
 	tristate "Interval tree test"
 	depends on DEBUG_KERNEL
-	select INTERVAL_TREE
 	help
 	  A benchmark measuring the performance of the interval tree library
 
diff --git a/lib/Makefile b/lib/Makefile
index fb7697031a79..39fd34156692 100644
--- a/lib/Makefile
+++ b/lib/Makefile
@@ -50,7 +50,7 @@ obj-y += bcd.o sort.o parser.o debug_locks.o random32.o \
 	 bsearch.o find_bit.o llist.o memweight.o kfifo.o \
 	 percpu-refcount.o rhashtable.o \
 	 once.o refcount.o usercopy.o errseq.o bucket_locks.o \
-	 generic-radix-tree.o
+	 generic-radix-tree.o interval_tree.o
 obj-$(CONFIG_STRING_SELFTEST) += test_string.o
 obj-y += string_helpers.o
 obj-$(CONFIG_TEST_STRING_HELPERS) += test-string_helpers.o
@@ -115,7 +115,6 @@ obj-y += logic_pio.o
 obj-$(CONFIG_GENERIC_HWEIGHT) += hweight.o
 
 obj-$(CONFIG_BTREE) += btree.o
-obj-$(CONFIG_INTERVAL_TREE) += interval_tree.o
 obj-$(CONFIG_ASSOCIATIVE_ARRAY) += assoc_array.o
 obj-$(CONFIG_DEBUG_PREEMPT) += smp_processor_id.o
 obj-$(CONFIG_DEBUG_LIST) += list_debug.o
-- 
2.16.4


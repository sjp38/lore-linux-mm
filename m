Return-Path: <SRS0=4FFe=UQ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.5 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id E4C12C31E58
	for <linux-mm@archiver.kernel.org>; Mon, 17 Jun 2019 12:29:00 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 9F4292084D
	for <linux-mm@archiver.kernel.org>; Mon, 17 Jun 2019 12:29:00 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=infradead.org header.i=@infradead.org header.b="UUq7egVT"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 9F4292084D
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=lst.de
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 119548E001B; Mon, 17 Jun 2019 08:28:36 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 07B538E000B; Mon, 17 Jun 2019 08:28:36 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id EAB8B8E001B; Mon, 17 Jun 2019 08:28:35 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f197.google.com (mail-pg1-f197.google.com [209.85.215.197])
	by kanga.kvack.org (Postfix) with ESMTP id B2B7D8E000B
	for <linux-mm@kvack.org>; Mon, 17 Jun 2019 08:28:35 -0400 (EDT)
Received: by mail-pg1-f197.google.com with SMTP id b10so7628192pgb.22
        for <linux-mm@kvack.org>; Mon, 17 Jun 2019 05:28:35 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=oJ6UkI2ll43ZwHiXYrdbiTYuFk63kXXY+nO1oYpLkTE=;
        b=R3grHY1OP+L23k4dK2q+fpNR2qxkE1Dq0bqHT7L5UNxgDTImEyiF/mCxAMolbmOBhk
         G5/ZvjdW4rN/aPNbdj7MmkYpwKhMkOlFT5702yY6Et2nvhNsKqpZZ2L+3hAiHhVGYFzg
         E5BfC4RsfWw2WNtfTuAaPhcRHu05V/c6Js4rSv56IdRInT0y5i7P3ZNExNArqmx1V5eB
         0UImk6rahQqdzdRSuRPybUJdIuUjQQeyaxVVqz88WKRaEZ2zsCYGFl50i6TPNZWmr3xC
         esRfi85LwWQ5V3Cq6qsG3tRfZL0na+cAlpcWvPSBvCQ0i/hc9PcH1GS8tDVvC5weOJ8k
         oP/w==
X-Gm-Message-State: APjAAAUuPs19LlBdEG7Kj7jeGUBbd3rRVRBLla3d0iiaSENPcYKcNRAU
	8Xj2YNEYwLbiO60CyJm56puyFJxa085/F7fsmA/3PDLRHpwxJKzig2lGE6DZdvYnwnnYJSE6gXU
	SpovyFLitYyK9up/co1tPMsBmSVVOJvZWeYgNhBPhbB/3EXJz5lYgLv8PEW6MLF0=
X-Received: by 2002:a63:292:: with SMTP id 140mr17300236pgc.88.1560774515238;
        Mon, 17 Jun 2019 05:28:35 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyo5l+Qcz9MLgvkEM8lolTZD6kDXy4RS02+Uah0SMFjGdyhruu+Ma+RNrqe57oMC/J429SX
X-Received: by 2002:a63:292:: with SMTP id 140mr17300190pgc.88.1560774514251;
        Mon, 17 Jun 2019 05:28:34 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1560774514; cv=none;
        d=google.com; s=arc-20160816;
        b=IejNBqW1XjTYug/dfxe6lX7vub59que+8a9TJhzXbmKn7setCP0ue3mH8bc8HYD6ek
         tQ96VlNog9t8WCmJCvrlljRU7wjoJ1s5t2L3dRf7Izp3a43YLR/nm671+17cpPRiZRhq
         bRSGEGavaNZFGyZTpQjOI81OCbgT5ChIYY1whh0jnwOZInmxCsCHTDVIsH2I1sHYNqSB
         gWR0TPK1YIzRApWE5by4BBnsMgVQFh7IzVOfMLZdv1j2/xqW4Dg6uXuMUW36yvSZ5y6o
         D6Hy8IFJev1z/XUPucPYGbwCIP876FiWPevpuCbOH7ASIhpmgvdnqxe+VEuldvYdMTS7
         p6EA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:dkim-signature;
        bh=oJ6UkI2ll43ZwHiXYrdbiTYuFk63kXXY+nO1oYpLkTE=;
        b=iTWP+MWUtbkS8roG80tWYM1X3p+gM4R5WG9OtrwqBMTwJttPjbSOPFix0w+hypChXq
         sAke1XA02lmGaJscLtMcL+n0PCDmjhGIO3iQr+TzUoqxUc/9v0Z0iwJY1iCtoxlw6MN0
         Bs1FLTJ9byQmZyC0sUDNfovNh+bZ+BSGj/Yz67jsn5HV8WOWsQV93vQmYjjtxxY3YCPE
         1CYTDQqZqeWkEONsOLI6FqV6S9pFW1jabK6+wYCjl5UBUWOVn+3EqhB4DRNR4WsF/rdp
         LYtsSzM4QAEoZAmDGwWWanwZcGOYqoFMiTzKpeLeqK5aqHAMvmxu3uhDiEBYDrgm9Hkt
         Mieg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=UUq7egVT;
       spf=pass (google.com: best guess record for domain of batv+a9ecd0bfb5b639be820a+5776+infradead.org+hch@bombadil.srs.infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=BATV+a9ecd0bfb5b639be820a+5776+infradead.org+hch@bombadil.srs.infradead.org
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id w21si10622539pff.263.2019.06.17.05.28.34
        for <linux-mm@kvack.org>
        (version=TLS1_3 cipher=AEAD-AES256-GCM-SHA384 bits=256/256);
        Mon, 17 Jun 2019 05:28:34 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of batv+a9ecd0bfb5b639be820a+5776+infradead.org+hch@bombadil.srs.infradead.org designates 2607:7c80:54:e::133 as permitted sender) client-ip=2607:7c80:54:e::133;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=UUq7egVT;
       spf=pass (google.com: best guess record for domain of batv+a9ecd0bfb5b639be820a+5776+infradead.org+hch@bombadil.srs.infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=BATV+a9ecd0bfb5b639be820a+5776+infradead.org+hch@bombadil.srs.infradead.org
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
	d=infradead.org; s=bombadil.20170209; h=Content-Transfer-Encoding:
	MIME-Version:References:In-Reply-To:Message-Id:Date:Subject:Cc:To:From:Sender
	:Reply-To:Content-Type:Content-ID:Content-Description:Resent-Date:Resent-From
	:Resent-Sender:Resent-To:Resent-Cc:Resent-Message-ID:List-Id:List-Help:
	List-Unsubscribe:List-Subscribe:List-Post:List-Owner:List-Archive;
	bh=oJ6UkI2ll43ZwHiXYrdbiTYuFk63kXXY+nO1oYpLkTE=; b=UUq7egVTFG3R6ymg30RMyb8xZb
	N4gLZFg+je0866s6fGFSQWP07O2W6hqApeIXVnHo5RGcIVYiYzqgJyRlHryVTgecysq2TS615QErk
	ilJpsjSBskMhBJF+fttIBW7l9k+zAIGLx2DizTuMzuhwmOqlhKk5CLOCmBJw2s4iDcDFNL6l7FHnU
	1U3/WvF56rTxvB4JDAUygKm22RxHdTSqgSO6uL0kx5Uu22RUQb3Kh74REUN0YsRh2TOnjGvFfSGJS
	4hq6hldBqT2FqB6axJvRuJ+QKnIoSd3vPSjJ3RRC8a/jLA8H4dmmneEFQ7DfXCzw85mWDkkY52rbE
	MreNdXsg==;
Received: from clnet-p19-102.ikbnet.co.at ([83.175.77.102] helo=localhost)
	by bombadil.infradead.org with esmtpsa (Exim 4.92 #3 (Red Hat Linux))
	id 1hcqkQ-0000bA-Nv; Mon, 17 Jun 2019 12:28:31 +0000
From: Christoph Hellwig <hch@lst.de>
To: Dan Williams <dan.j.williams@intel.com>,
	=?UTF-8?q?J=C3=A9r=C3=B4me=20Glisse?= <jglisse@redhat.com>,
	Jason Gunthorpe <jgg@mellanox.com>,
	Ben Skeggs <bskeggs@redhat.com>
Cc: linux-mm@kvack.org,
	nouveau@lists.freedesktop.org,
	dri-devel@lists.freedesktop.org,
	linux-nvdimm@lists.01.org,
	linux-pci@vger.kernel.org,
	linux-kernel@vger.kernel.org
Subject: [PATCH 24/25] mm: remove the HMM config option
Date: Mon, 17 Jun 2019 14:27:32 +0200
Message-Id: <20190617122733.22432-25-hch@lst.de>
X-Mailer: git-send-email 2.20.1
In-Reply-To: <20190617122733.22432-1-hch@lst.de>
References: <20190617122733.22432-1-hch@lst.de>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-SRS-Rewrite: SMTP reverse-path rewritten from <hch@infradead.org> by bombadil.infradead.org. See http://www.infradead.org/rpr.html
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

All the mm/hmm.c code is better keyed off HMM_MIRROR.  Also let nouveau
depend on it instead of the mix of a dummy dependency symbol plus the
actually selected one.  Drop various odd dependencies, as the code is
pretty portable.

Signed-off-by: Christoph Hellwig <hch@lst.de>
---
 drivers/gpu/drm/nouveau/Kconfig |  3 +--
 include/linux/hmm.h             | 10 +---------
 include/linux/mm_types.h        |  2 +-
 mm/Kconfig                      | 30 +++++-------------------------
 mm/Makefile                     |  2 +-
 mm/hmm.c                        |  2 --
 6 files changed, 9 insertions(+), 40 deletions(-)

diff --git a/drivers/gpu/drm/nouveau/Kconfig b/drivers/gpu/drm/nouveau/Kconfig
index 6303d203ab1d..66c839d8e9d1 100644
--- a/drivers/gpu/drm/nouveau/Kconfig
+++ b/drivers/gpu/drm/nouveau/Kconfig
@@ -84,11 +84,10 @@ config DRM_NOUVEAU_BACKLIGHT
 
 config DRM_NOUVEAU_SVM
 	bool "(EXPERIMENTAL) Enable SVM (Shared Virtual Memory) support"
-	depends on ARCH_HAS_HMM
 	depends on DEVICE_PRIVATE
 	depends on DRM_NOUVEAU
+	depends on HMM_MIRROR
 	depends on STAGING
-	select HMM_MIRROR
 	default n
 	help
 	  Say Y here if you want to enable experimental support for
diff --git a/include/linux/hmm.h b/include/linux/hmm.h
index 454be41f2eaf..ffc52820d976 100644
--- a/include/linux/hmm.h
+++ b/include/linux/hmm.h
@@ -62,7 +62,7 @@
 #include <linux/kconfig.h>
 #include <asm/pgtable.h>
 
-#if IS_ENABLED(CONFIG_HMM)
+#ifdef CONFIG_HMM_MIRROR
 
 #include <linux/device.h>
 #include <linux/migrate.h>
@@ -334,9 +334,6 @@ static inline uint64_t hmm_pfn_from_pfn(const struct hmm_range *range,
 	return hmm_device_entry_from_pfn(range, pfn);
 }
 
-
-
-#if IS_ENABLED(CONFIG_HMM_MIRROR)
 /*
  * Mirroring: how to synchronize device page table with CPU page table.
  *
@@ -586,9 +583,4 @@ static inline void hmm_mm_destroy(struct mm_struct *mm) {}
 static inline void hmm_mm_init(struct mm_struct *mm) {}
 #endif /* IS_ENABLED(CONFIG_HMM_MIRROR) */
 
-#else /* IS_ENABLED(CONFIG_HMM) */
-static inline void hmm_mm_destroy(struct mm_struct *mm) {}
-static inline void hmm_mm_init(struct mm_struct *mm) {}
-#endif /* IS_ENABLED(CONFIG_HMM) */
-
 #endif /* LINUX_HMM_H */
diff --git a/include/linux/mm_types.h b/include/linux/mm_types.h
index f33a1289c101..8d37182f8dbe 100644
--- a/include/linux/mm_types.h
+++ b/include/linux/mm_types.h
@@ -501,7 +501,7 @@ struct mm_struct {
 #endif
 		struct work_struct async_put_work;
 
-#if IS_ENABLED(CONFIG_HMM)
+#ifdef CONFIG_HMM_MIRROR
 		/* HMM needs to track a few things per mm */
 		struct hmm *hmm;
 #endif
diff --git a/mm/Kconfig b/mm/Kconfig
index 4dbd718c8cf4..7fa785551f96 100644
--- a/mm/Kconfig
+++ b/mm/Kconfig
@@ -669,37 +669,18 @@ config ZONE_DEVICE
 
 	  If FS_DAX is enabled, then say Y.
 
-config ARCH_HAS_HMM_MIRROR
-	bool
-	default y
-	depends on (X86_64 || PPC64)
-	depends on MMU && 64BIT
-
-config ARCH_HAS_HMM
-	bool
-	depends on (X86_64 || PPC64)
-	depends on ZONE_DEVICE
-	depends on MMU && 64BIT
-	depends on MEMORY_HOTPLUG
-	depends on MEMORY_HOTREMOVE
-	depends on SPARSEMEM_VMEMMAP
-	default y
-
 config MIGRATE_VMA_HELPER
 	bool
 
 config DEV_PAGEMAP_OPS
 	bool
 
-config HMM
-	bool
-	select MMU_NOTIFIER
-	select MIGRATE_VMA_HELPER
-
 config HMM_MIRROR
 	bool "HMM mirror CPU page table into a device page table"
-	depends on ARCH_HAS_HMM
-	select HMM
+	depends on (X86_64 || PPC64)
+	depends on MMU && 64BIT
+	select MMU_NOTIFIER
+	select MIGRATE_VMA_HELPER
 	help
 	  Select HMM_MIRROR if you want to mirror range of the CPU page table of a
 	  process into a device page table. Here, mirror means "keep synchronized".
@@ -719,9 +700,8 @@ config DEVICE_PRIVATE
 
 config DEVICE_PUBLIC
 	bool "Addressable device memory (like GPU memory)"
-	depends on ARCH_HAS_HMM
 	depends on BROKEN
-	select HMM
+	depends on ZONE_DEVICE
 	select DEV_PAGEMAP_OPS
 
 	help
diff --git a/mm/Makefile b/mm/Makefile
index ac5e5ba78874..91c99040065c 100644
--- a/mm/Makefile
+++ b/mm/Makefile
@@ -102,5 +102,5 @@ obj-$(CONFIG_FRAME_VECTOR) += frame_vector.o
 obj-$(CONFIG_DEBUG_PAGE_REF) += debug_page_ref.o
 obj-$(CONFIG_HARDENED_USERCOPY) += usercopy.o
 obj-$(CONFIG_PERCPU_STATS) += percpu-stats.o
-obj-$(CONFIG_HMM) += hmm.o
+obj-$(CONFIG_HMM_MIRROR) += hmm.o
 obj-$(CONFIG_MEMFD_CREATE) += memfd.o
diff --git a/mm/hmm.c b/mm/hmm.c
index 17ed080d9c32..cefeec5c58aa 100644
--- a/mm/hmm.c
+++ b/mm/hmm.c
@@ -25,7 +25,6 @@
 #include <linux/mmu_notifier.h>
 #include <linux/memory_hotplug.h>
 
-#if IS_ENABLED(CONFIG_HMM_MIRROR)
 static const struct mmu_notifier_ops hmm_mmu_notifier_ops;
 
 static inline struct hmm *mm_get_hmm(struct mm_struct *mm)
@@ -1323,4 +1322,3 @@ long hmm_range_dma_unmap(struct hmm_range *range,
 	return cpages;
 }
 EXPORT_SYMBOL(hmm_range_dma_unmap);
-#endif /* IS_ENABLED(CONFIG_HMM_MIRROR) */
-- 
2.20.1


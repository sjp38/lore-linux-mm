Return-Path: <SRS0=C/CR=UZ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.5 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 0645DC48BD8
	for <linux-mm@archiver.kernel.org>; Wed, 26 Jun 2019 12:29:02 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id B59B92063F
	for <linux-mm@archiver.kernel.org>; Wed, 26 Jun 2019 12:29:01 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=infradead.org header.i=@infradead.org header.b="qeW+utdJ"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org B59B92063F
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=lst.de
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 564FF8E001F; Wed, 26 Jun 2019 08:28:36 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 4C7E48E0005; Wed, 26 Jun 2019 08:28:36 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 344F58E001F; Wed, 26 Jun 2019 08:28:36 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f197.google.com (mail-pl1-f197.google.com [209.85.214.197])
	by kanga.kvack.org (Postfix) with ESMTP id E8BC28E0005
	for <linux-mm@kvack.org>; Wed, 26 Jun 2019 08:28:35 -0400 (EDT)
Received: by mail-pl1-f197.google.com with SMTP id q2so1352829plr.19
        for <linux-mm@kvack.org>; Wed, 26 Jun 2019 05:28:35 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=8c7Qw79j4iTVfYu8BDZ4XSZccS1fj4ydMQxMOZ0rYRM=;
        b=SmazmG2E+o4I4dFOsu8r9Qe7qDokUC0XQpOpoy82t7vgWjN4ZrnGY+u9ELWguH3yco
         GQHn8UhifxE77lE6nJRgLskaqnDcoMuk9t6+hUmvt1J/kR1jOB6QtkrfJOtiPb2TYjV1
         ZGzEpG1Np9WmpJhoDzSjQzi/w3AbS4Yx5q3hnV/vYVPb6NEH19zgArO1fzN8F6mqgfNr
         V+ieTTmSzYdYmLU+NtsUFQVIAQq/toqHXP2cVpQSCaY3ZV6MNQjq/yHLoHix5pUV2fgy
         aRloEB0A0v8sjFaGuzr6ZDbgrPOd6Z+5eaPwf5tXkWR4XSyGxvSFd6NB6Q4O9BUjsn5u
         TMhw==
X-Gm-Message-State: APjAAAXOCd0diysW8kMsYK/z+RF65nnNgr3ZvQPXrzvUQi3ruyyT7sU2
	gRr1lkikBxkTL2aDPXyAktFnz4h9RFXG7fpXNb/tAgUGs8lBKXqFGKRr7qP7i4IBTSU140vH4Ff
	MO9YYlMZjlkKANtquCU6sA6NFJc/XcjxkABSSNJ7rUBy39UJyWTCVbQu3aDIHiDc=
X-Received: by 2002:a65:5c8c:: with SMTP id a12mr2734268pgt.255.1561552115435;
        Wed, 26 Jun 2019 05:28:35 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzzqFUCByEVVHcgIvOCGPgzTDdjj0kfhFcBG3mV8Y0bh9L+ORY5wpcc04a/3FRDCaCXo+Wo
X-Received: by 2002:a65:5c8c:: with SMTP id a12mr2734202pgt.255.1561552114516;
        Wed, 26 Jun 2019 05:28:34 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1561552114; cv=none;
        d=google.com; s=arc-20160816;
        b=Ys7ZIJrkX/Sb59cNDBLayVUEiekJFM3e8rebaGhf/urGiA/dZ9SGEHxv77cUfinqRl
         icHRizq+p4Flw0YjDX+DUCsY1DluyOwIvUZEWDRvCLImcTN/HrtOhk3ogNQ5N3byw2Zu
         9iZ63c4Z1H+CMdF93HMhI2UFi/aBgvRXbrLQh5KKf47G2DUBmtYoEKjg6/DYfOyRf2L2
         PEzCImhfwLjCQT9pUgfCVJGJxm9C5mU0fIXa6vmFdfaezGbLKga37WQt97+/SK1p/8Jc
         T//MKlbTAVariKMuhwTymrrR3JVSZtH4Ipfp0g2Lsleg7D5s17++POMSoTh6TJPTgZlc
         priw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:dkim-signature;
        bh=8c7Qw79j4iTVfYu8BDZ4XSZccS1fj4ydMQxMOZ0rYRM=;
        b=lCHxzpLuOlrlgWxcckzvv21NbEA8TzGe6+xiVLqxQNxixYWFFomv2lgGc+HTsjP+3R
         PqDCqZ26wkPCl6wSLoXOHNLpBRDFvtqdr0AZ5kja44sSxScKItH6l8KUxtlhZHSnnMK4
         mC9WvDz+TwJhvl+UOHC0KnpSqE82wnm1dBzFdt9WKk0H5CyN4y5/lm/1htYjp3FcnG6F
         dsm4PEZ+hvPpnxwvcapKjMH5+d4gqquOx5ScjyYQbftdjfSYMd+upHBBPcTuT8GPq1oK
         JQEIRvIedgM1iUVgGNt/p04iBWBw6yxresUDcUrf6vQI/n0gR1NQdoF0ES7PBdNxqWIw
         e2VA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=qeW+utdJ;
       spf=pass (google.com: best guess record for domain of batv+ab1f803c58217d155be4+5785+infradead.org+hch@bombadil.srs.infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=BATV+ab1f803c58217d155be4+5785+infradead.org+hch@bombadil.srs.infradead.org
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id y134si18040826pfc.285.2019.06.26.05.28.34
        for <linux-mm@kvack.org>
        (version=TLS1_3 cipher=AEAD-AES256-GCM-SHA384 bits=256/256);
        Wed, 26 Jun 2019 05:28:34 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of batv+ab1f803c58217d155be4+5785+infradead.org+hch@bombadil.srs.infradead.org designates 2607:7c80:54:e::133 as permitted sender) client-ip=2607:7c80:54:e::133;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=qeW+utdJ;
       spf=pass (google.com: best guess record for domain of batv+ab1f803c58217d155be4+5785+infradead.org+hch@bombadil.srs.infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=BATV+ab1f803c58217d155be4+5785+infradead.org+hch@bombadil.srs.infradead.org
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
	d=infradead.org; s=bombadil.20170209; h=Content-Transfer-Encoding:
	MIME-Version:References:In-Reply-To:Message-Id:Date:Subject:Cc:To:From:Sender
	:Reply-To:Content-Type:Content-ID:Content-Description:Resent-Date:Resent-From
	:Resent-Sender:Resent-To:Resent-Cc:Resent-Message-ID:List-Id:List-Help:
	List-Unsubscribe:List-Subscribe:List-Post:List-Owner:List-Archive;
	bh=8c7Qw79j4iTVfYu8BDZ4XSZccS1fj4ydMQxMOZ0rYRM=; b=qeW+utdJvjdhQsheXW/BJJc+6E
	Je3Qw7KX8yqGRD61b+aMkwDnKhRl79dbPTB2oSJS9EJkkp6B04gH0AKwiMVXmZSWXedEVwmeZuHtd
	rxfolj9Lb0kntloPPle3ysnemn+eVNPk1PVLI65krTeg8f8ixCclNzvQ1VMgjJNdcaSfpbGEE5JqZ
	LdQuIQpaH4WpWeh96t9pFdDMHn8Nlh1iBjfjdCn7Tu5xaSa1u8SC412S343cnc/TFWSgHhCX2D4kz
	T8P1Ggyzn7yKEs00DA9YZRe2O9RSSxL1RnyDktKkewIGQSovonLhKuAUk0FzNPPqOPnS9qC33UPWA
	glFwMabA==;
Received: from clnet-p19-102.ikbnet.co.at ([83.175.77.102] helo=localhost)
	by bombadil.infradead.org with esmtpsa (Exim 4.92 #3 (Red Hat Linux))
	id 1hg72M-0001fg-QA; Wed, 26 Jun 2019 12:28:31 +0000
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
Date: Wed, 26 Jun 2019 14:27:23 +0200
Message-Id: <20190626122724.13313-25-hch@lst.de>
X-Mailer: git-send-email 2.20.1
In-Reply-To: <20190626122724.13313-1-hch@lst.de>
References: <20190626122724.13313-1-hch@lst.de>
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
 include/linux/hmm.h             |  5 +----
 include/linux/mm_types.h        |  2 +-
 mm/Kconfig                      | 27 ++++-----------------------
 mm/Makefile                     |  2 +-
 mm/hmm.c                        |  2 --
 6 files changed, 8 insertions(+), 33 deletions(-)

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
index 3d00e9550e77..b697496e85ba 100644
--- a/include/linux/hmm.h
+++ b/include/linux/hmm.h
@@ -62,7 +62,7 @@
 #include <linux/kconfig.h>
 #include <asm/pgtable.h>
 
-#if IS_ENABLED(CONFIG_HMM)
+#ifdef CONFIG_HMM_MIRROR
 
 #include <linux/device.h>
 #include <linux/migrate.h>
@@ -332,9 +332,6 @@ static inline uint64_t hmm_pfn_from_pfn(const struct hmm_range *range,
 	return hmm_device_entry_from_pfn(range, pfn);
 }
 
-
-
-#if IS_ENABLED(CONFIG_HMM_MIRROR)
 /*
  * Mirroring: how to synchronize device page table with CPU page table.
  *
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
index eecf037a54b3..1e426c26b1d6 100644
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
index 90ca0cdab9db..d62ce64d6bca 100644
--- a/mm/hmm.c
+++ b/mm/hmm.c
@@ -25,7 +25,6 @@
 #include <linux/mmu_notifier.h>
 #include <linux/memory_hotplug.h>
 
-#if IS_ENABLED(CONFIG_HMM_MIRROR)
 static const struct mmu_notifier_ops hmm_mmu_notifier_ops;
 
 static inline struct hmm *mm_get_hmm(struct mm_struct *mm)
@@ -1326,4 +1325,3 @@ long hmm_range_dma_unmap(struct hmm_range *range,
 	return cpages;
 }
 EXPORT_SYMBOL(hmm_range_dma_unmap);
-#endif /* IS_ENABLED(CONFIG_HMM_MIRROR) */
-- 
2.20.1


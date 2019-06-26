Return-Path: <SRS0=C/CR=UZ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.5 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id B3EB4C48BD3
	for <linux-mm@archiver.kernel.org>; Wed, 26 Jun 2019 12:28:20 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 62A3E2063F
	for <linux-mm@archiver.kernel.org>; Wed, 26 Jun 2019 12:28:20 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=infradead.org header.i=@infradead.org header.b="VAr9mXfz"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 62A3E2063F
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=lst.de
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 20AC38E0015; Wed, 26 Jun 2019 08:28:04 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 147408E000E; Wed, 26 Jun 2019 08:28:04 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id F29EC8E0015; Wed, 26 Jun 2019 08:28:03 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f199.google.com (mail-pf1-f199.google.com [209.85.210.199])
	by kanga.kvack.org (Postfix) with ESMTP id B2FF18E000E
	for <linux-mm@kvack.org>; Wed, 26 Jun 2019 08:28:03 -0400 (EDT)
Received: by mail-pf1-f199.google.com with SMTP id q14so1682069pff.8
        for <linux-mm@kvack.org>; Wed, 26 Jun 2019 05:28:03 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=eSi3S2UCkxhmCBrnGHmtw81ZNxp9oxJ8kWoR9DuGVFo=;
        b=qprjIyf4AbeHIGB7k8YHWZeaRoeCDVqKltEDzNFhLVzPYqavlsFnXu+R3D8XkPsx0U
         2sYxcOuViLkJPRAUlWPPLL5h6OPutTm2PC0SIm6jlrsLYm7VjZustsiejiiMlRQBKTvx
         CT5nM3YS36BHcMznwP2+FP2BjlDZi7XGfoWNTbCX5pd9sjqxeJ47+VO69O4GZCsNOObG
         mgR8aX/9bDpiITkc1QQqZ8LJWENakQZOVty9dbDKkoV8VG/uJR4sYyjGqM2vvbnh+mpo
         qwlyngE+AYHX6mAy+2ORFbe6uVReymfdiz1Le+CFpFPiMR9/U8Of+fuU82tDqCJSm1Z1
         /sfg==
X-Gm-Message-State: APjAAAWRUsNwYEBVSuQHSfzb14Hj+E1hs3xOY7yb2BtYsRIfv05+91yh
	S7MRKstd8hXTgsJjyWCXK3rjsNHyMIqoTMvtsCQDPzt8f3kTM74gRrCd5joEBA03jVfEZ6aFW3Z
	Lxbl0GKkARR9aRhD7O0knRls3lf3PJSaFD2IZSQMItuB2K34CWq2DEQ+O6WhKn1I=
X-Received: by 2002:a17:902:404:: with SMTP id 4mr5277573ple.200.1561552083383;
        Wed, 26 Jun 2019 05:28:03 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwVBbwEtVzC9zvWTWSG03lOn4TiTE5ejCxPZUfj0A2VsVYnMIX2r+aGt//CwjK42NxNo6M3
X-Received: by 2002:a17:902:404:: with SMTP id 4mr5277511ple.200.1561552082404;
        Wed, 26 Jun 2019 05:28:02 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1561552082; cv=none;
        d=google.com; s=arc-20160816;
        b=YJ7ckoXcxIGIc5H1l36Sw3f9mop9zasG239lmezj2s+YHiJWrfL36Sji1TNUE2NroS
         gkJNGm6MxMQ4CNNmXAi9WoFs5XWgb1vVb82L7gn5+n5yCSntv/VJVwEZKejzi/ffUrE9
         fkyTA+a188COGKxRIGK/no+V5AhqFnxCTy4bRSFyuJXLbHEAcsm++aGpo08B7CEfc55n
         fQbGqbWaHYoqj7kFGgQn3Y7JFpt+W733eumcJTTUzNQCw84M+wwVDBcI2BUvDxWyUC+m
         LCKzY21f7dB/OppGRVBKtXwp1nGaQDQJh9bfoeXbDLyJwLYeLsXPngUfVdZErozII0/p
         5SIQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:dkim-signature;
        bh=eSi3S2UCkxhmCBrnGHmtw81ZNxp9oxJ8kWoR9DuGVFo=;
        b=JOK8xl1LVpBLx5uXmSLEMZ2J6I5sG3QSzigX1961RL+5k63BvlFgan4gRGC+yiladP
         Rm4nrQcAtk+tgwsTCqk+Olyl0VVopi1tainpenDUjwXFQh/yvPNv/kFL1mwFKSRmpCjQ
         9E3SgT1D+TRV+wO17MbH5BVc5K49zJTfhNuV4zvbvd2TyzIpMh9cuoTxdJuSkcEY4ibm
         YFQExLxQ+IMuc9s3+HRXAOJLZ2tc0aVJQNpLjfjsYtEaEAr81gooCEJqKOUZVzB1QGiX
         frfDUOjq5pemjhyY4p1wT9qiwQ9d241mZy8ebfryRKCW0/A5CMAdM8+RsnQviTUFfhu9
         QobA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=VAr9mXfz;
       spf=pass (google.com: best guess record for domain of batv+ab1f803c58217d155be4+5785+infradead.org+hch@bombadil.srs.infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=BATV+ab1f803c58217d155be4+5785+infradead.org+hch@bombadil.srs.infradead.org
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id a4si1386797pjh.87.2019.06.26.05.28.02
        for <linux-mm@kvack.org>
        (version=TLS1_3 cipher=AEAD-AES256-GCM-SHA384 bits=256/256);
        Wed, 26 Jun 2019 05:28:02 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of batv+ab1f803c58217d155be4+5785+infradead.org+hch@bombadil.srs.infradead.org designates 2607:7c80:54:e::133 as permitted sender) client-ip=2607:7c80:54:e::133;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=VAr9mXfz;
       spf=pass (google.com: best guess record for domain of batv+ab1f803c58217d155be4+5785+infradead.org+hch@bombadil.srs.infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=BATV+ab1f803c58217d155be4+5785+infradead.org+hch@bombadil.srs.infradead.org
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
	d=infradead.org; s=bombadil.20170209; h=Content-Transfer-Encoding:
	MIME-Version:References:In-Reply-To:Message-Id:Date:Subject:Cc:To:From:Sender
	:Reply-To:Content-Type:Content-ID:Content-Description:Resent-Date:Resent-From
	:Resent-Sender:Resent-To:Resent-Cc:Resent-Message-ID:List-Id:List-Help:
	List-Unsubscribe:List-Subscribe:List-Post:List-Owner:List-Archive;
	bh=eSi3S2UCkxhmCBrnGHmtw81ZNxp9oxJ8kWoR9DuGVFo=; b=VAr9mXfz7cA+wOHeq9MHRYNO/Z
	Tw/udMQowLV+trSw45gnqEt0HZNhWG7lVgavlyWH7jsxvhGv9JgYvbk4lz7GD2//xNo/lo8m5agAs
	GxbGTWyz4pMQYv0hMGA19IuNlfi5HbAxp8MprYgFCBettSw3l032ywNQ0jbdWLeDaKHaJvhULeKQT
	YE6yKAU+ZSd0HR+Jw67bWZty6cwjOAyK2xSnjiJD5uG7aol2AxKoP2n3PoM6gDA2aswJclMgxpg87
	4+Uygu7KZHfUC/zlgwWL5vJgddLEwVi4vJPg1q+Mz7uahZKqAZw4H1L+/SVnzz4/d8xL31Zgdt49k
	cHkty14w==;
Received: from clnet-p19-102.ikbnet.co.at ([83.175.77.102] helo=localhost)
	by bombadil.infradead.org with esmtpsa (Exim 4.92 #3 (Red Hat Linux))
	id 1hg71q-0001T6-VB; Wed, 26 Jun 2019 12:27:59 +0000
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
	linux-kernel@vger.kernel.org,
	Ralph Campbell <rcampbell@nvidia.com>
Subject: [PATCH 12/25] memremap: add a migrate_to_ram method to struct dev_pagemap_ops
Date: Wed, 26 Jun 2019 14:27:11 +0200
Message-Id: <20190626122724.13313-13-hch@lst.de>
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

This replaces the hacky ->fault callback, which is currently directly
called from common code through a hmm specific data structure as an
exercise in layering violations.

Signed-off-by: Christoph Hellwig <hch@lst.de>
Reviewed-by: Ralph Campbell <rcampbell@nvidia.com>
---
 include/linux/hmm.h      |  6 ------
 include/linux/memremap.h |  6 ++++++
 include/linux/swapops.h  | 15 ---------------
 kernel/memremap.c        | 35 ++++-------------------------------
 mm/hmm.c                 | 13 +++++--------
 mm/memory.c              |  9 ++-------
 6 files changed, 17 insertions(+), 67 deletions(-)

diff --git a/include/linux/hmm.h b/include/linux/hmm.h
index 44a5ac738bb5..ba19c19e24ed 100644
--- a/include/linux/hmm.h
+++ b/include/linux/hmm.h
@@ -692,11 +692,6 @@ struct hmm_devmem_ops {
  * chunk, as an optimization. It must, however, prioritize the faulting address
  * over all the others.
  */
-typedef vm_fault_t (*dev_page_fault_t)(struct vm_area_struct *vma,
-				unsigned long addr,
-				const struct page *page,
-				unsigned int flags,
-				pmd_t *pmdp);
 
 struct hmm_devmem {
 	struct completion		completion;
@@ -707,7 +702,6 @@ struct hmm_devmem {
 	struct dev_pagemap		pagemap;
 	const struct hmm_devmem_ops	*ops;
 	struct percpu_ref		ref;
-	dev_page_fault_t		page_fault;
 };
 
 /*
diff --git a/include/linux/memremap.h b/include/linux/memremap.h
index b8666a0d8665..ac985bd03a7f 100644
--- a/include/linux/memremap.h
+++ b/include/linux/memremap.h
@@ -80,6 +80,12 @@ struct dev_pagemap_ops {
 	 * Wait for refcount in struct dev_pagemap to be idle and reap it.
 	 */
 	void (*cleanup)(struct dev_pagemap *pgmap);
+
+	/*
+	 * Used for private (un-addressable) device memory only.  Must migrate
+	 * the page back to a CPU accessible page.
+	 */
+	vm_fault_t (*migrate_to_ram)(struct vm_fault *vmf);
 };
 
 /**
diff --git a/include/linux/swapops.h b/include/linux/swapops.h
index 4d961668e5fc..15bdb6fe71e5 100644
--- a/include/linux/swapops.h
+++ b/include/linux/swapops.h
@@ -129,12 +129,6 @@ static inline struct page *device_private_entry_to_page(swp_entry_t entry)
 {
 	return pfn_to_page(swp_offset(entry));
 }
-
-vm_fault_t device_private_entry_fault(struct vm_area_struct *vma,
-		       unsigned long addr,
-		       swp_entry_t entry,
-		       unsigned int flags,
-		       pmd_t *pmdp);
 #else /* CONFIG_DEVICE_PRIVATE */
 static inline swp_entry_t make_device_private_entry(struct page *page, bool write)
 {
@@ -164,15 +158,6 @@ static inline struct page *device_private_entry_to_page(swp_entry_t entry)
 {
 	return NULL;
 }
-
-static inline vm_fault_t device_private_entry_fault(struct vm_area_struct *vma,
-				     unsigned long addr,
-				     swp_entry_t entry,
-				     unsigned int flags,
-				     pmd_t *pmdp)
-{
-	return VM_FAULT_SIGBUS;
-}
 #endif /* CONFIG_DEVICE_PRIVATE */
 
 #ifdef CONFIG_MIGRATION
diff --git a/kernel/memremap.c b/kernel/memremap.c
index 3219a4c91d07..c06a5487dda7 100644
--- a/kernel/memremap.c
+++ b/kernel/memremap.c
@@ -11,7 +11,6 @@
 #include <linux/types.h>
 #include <linux/wait_bit.h>
 #include <linux/xarray.h>
-#include <linux/hmm.h>
 
 static DEFINE_XARRAY(pgmap_array);
 #define SECTION_MASK ~((1UL << PA_SECTION_SHIFT) - 1)
@@ -46,36 +45,6 @@ static int devmap_managed_enable_get(struct device *dev, struct dev_pagemap *pgm
 }
 #endif /* CONFIG_DEV_PAGEMAP_OPS */
 
-#if IS_ENABLED(CONFIG_DEVICE_PRIVATE)
-vm_fault_t device_private_entry_fault(struct vm_area_struct *vma,
-		       unsigned long addr,
-		       swp_entry_t entry,
-		       unsigned int flags,
-		       pmd_t *pmdp)
-{
-	struct page *page = device_private_entry_to_page(entry);
-	struct hmm_devmem *devmem;
-
-	devmem = container_of(page->pgmap, typeof(*devmem), pagemap);
-
-	/*
-	 * The page_fault() callback must migrate page back to system memory
-	 * so that CPU can access it. This might fail for various reasons
-	 * (device issue, device was unsafely unplugged, ...). When such
-	 * error conditions happen, the callback must return VM_FAULT_SIGBUS.
-	 *
-	 * Note that because memory cgroup charges are accounted to the device
-	 * memory, this should never fail because of memory restrictions (but
-	 * allocation of regular system page might still fail because we are
-	 * out of memory).
-	 *
-	 * There is a more in-depth description of what that callback can and
-	 * cannot do, in include/linux/memremap.h
-	 */
-	return devmem->page_fault(vma, addr, page, flags, pmdp);
-}
-#endif /* CONFIG_DEVICE_PRIVATE */
-
 static void pgmap_array_delete(struct resource *res)
 {
 	xa_store_range(&pgmap_array, PHYS_PFN(res->start), PHYS_PFN(res->end),
@@ -193,6 +162,10 @@ void *devm_memremap_pages(struct device *dev, struct dev_pagemap *pgmap)
 			WARN(1, "Device private memory not supported\n");
 			return ERR_PTR(-EINVAL);
 		}
+		if (!pgmap->ops || !pgmap->ops->migrate_to_ram) {
+			WARN(1, "Missing migrate_to_ram method\n");
+			return ERR_PTR(-EINVAL);
+		}
 		break;
 	case MEMORY_DEVICE_FS_DAX:
 		if (!IS_ENABLED(CONFIG_ZONE_DEVICE) ||
diff --git a/mm/hmm.c b/mm/hmm.c
index 5b0bd5f6a74f..96633ee066d8 100644
--- a/mm/hmm.c
+++ b/mm/hmm.c
@@ -1366,15 +1366,12 @@ static void hmm_devmem_ref_kill(struct dev_pagemap *pgmap)
 	percpu_ref_kill(pgmap->ref);
 }
 
-static vm_fault_t hmm_devmem_fault(struct vm_area_struct *vma,
-			    unsigned long addr,
-			    const struct page *page,
-			    unsigned int flags,
-			    pmd_t *pmdp)
+static vm_fault_t hmm_devmem_migrate_to_ram(struct vm_fault *vmf)
 {
-	struct hmm_devmem *devmem = page->pgmap->data;
+	struct hmm_devmem *devmem = vmf->page->pgmap->data;
 
-	return devmem->ops->fault(devmem, vma, addr, page, flags, pmdp);
+	return devmem->ops->fault(devmem, vmf->vma, vmf->address, vmf->page,
+			vmf->flags, vmf->pmd);
 }
 
 static void hmm_devmem_free(struct page *page, void *data)
@@ -1388,6 +1385,7 @@ static const struct dev_pagemap_ops hmm_pagemap_ops = {
 	.page_free		= hmm_devmem_free,
 	.kill			= hmm_devmem_ref_kill,
 	.cleanup		= hmm_devmem_ref_exit,
+	.migrate_to_ram		= hmm_devmem_migrate_to_ram,
 };
 
 /*
@@ -1438,7 +1436,6 @@ struct hmm_devmem *hmm_devmem_add(const struct hmm_devmem_ops *ops,
 	devmem->pfn_first = devmem->resource->start >> PAGE_SHIFT;
 	devmem->pfn_last = devmem->pfn_first +
 			   (resource_size(devmem->resource) >> PAGE_SHIFT);
-	devmem->page_fault = hmm_devmem_fault;
 
 	devmem->pagemap.type = MEMORY_DEVICE_PRIVATE;
 	devmem->pagemap.res = *devmem->resource;
diff --git a/mm/memory.c b/mm/memory.c
index bd21e7063bf0..293d2936fd6c 100644
--- a/mm/memory.c
+++ b/mm/memory.c
@@ -2748,13 +2748,8 @@ vm_fault_t do_swap_page(struct vm_fault *vmf)
 			migration_entry_wait(vma->vm_mm, vmf->pmd,
 					     vmf->address);
 		} else if (is_device_private_entry(entry)) {
-			/*
-			 * For un-addressable device memory we call the pgmap
-			 * fault handler callback. The callback must migrate
-			 * the page back to some CPU accessible page.
-			 */
-			ret = device_private_entry_fault(vma, vmf->address, entry,
-						 vmf->flags, vmf->pmd);
+			vmf->page = device_private_entry_to_page(entry);
+			ret = vmf->page->pgmap->ops->migrate_to_ram(vmf);
 		} else if (is_hwpoison_entry(entry)) {
 			ret = VM_FAULT_HWPOISON;
 		} else {
-- 
2.20.1


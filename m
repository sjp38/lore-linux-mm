Return-Path: <SRS0=7jwN=UM=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.6 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,USER_AGENT_GIT autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id EFBD3C31E45
	for <linux-mm@archiver.kernel.org>; Thu, 13 Jun 2019 09:44:03 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 9A1F621473
	for <linux-mm@archiver.kernel.org>; Thu, 13 Jun 2019 09:44:03 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=infradead.org header.i=@infradead.org header.b="ZLjh9Yz1"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 9A1F621473
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=lst.de
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 41C5C6B000C; Thu, 13 Jun 2019 05:44:03 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 3D1B66B026A; Thu, 13 Jun 2019 05:44:03 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 21FDA6B026B; Thu, 13 Jun 2019 05:44:03 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f200.google.com (mail-pf1-f200.google.com [209.85.210.200])
	by kanga.kvack.org (Postfix) with ESMTP id D35BC6B000C
	for <linux-mm@kvack.org>; Thu, 13 Jun 2019 05:44:02 -0400 (EDT)
Received: by mail-pf1-f200.google.com with SMTP id c17so14089559pfb.21
        for <linux-mm@kvack.org>; Thu, 13 Jun 2019 02:44:02 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=0g0wuDYxGWA/uLah/sn+BRxeQhPX6KLUiVSrhTXjDEs=;
        b=SRB9nq95ER79NzCRi5Bko3TRAq617Q/Q/WLFv5jK8BaYnP3GJ00zMllHqCz7VovmCV
         cOtUyO81plYYLrw0UX35zYxXwzR4hoZoApzkvqpGFOMCBjLyWQVb/9CVovH6gAeWQ6uU
         SE9d8XkRknmeqjZr71evwXtwaCIp+81u/h7WqqorGlkqL2yKCAzcpf37ygM9O4PE2BMl
         PF0U0wq80itsP9Hk3zfc9cOPeD/KCk1SJNohQDNXeMjKyMTaYonBqPh693hJSU/abFMb
         X1x7/7dqqdLN17CDFa4MqV7+rPAVpsFEUlweX3Was65wGaRU2l9pdnNdTutYX3jm/34e
         EsNw==
X-Gm-Message-State: APjAAAVWcxHqVwXr5ADFX3aGvHaoG4PTqqjJN++qrmmj2iXLsGSErhKU
	NSRD5lkBC1IcT7QBEuiptfil/KXtEeGIIiBOwcPHbEvMLKecWqntLbEZ28tvcP6r+TSCHjgrHc6
	cCSn9DpN7RtRbdEXUu7+695WDkxU3BsvivMVVIxNI0qnO1imkSiihdTcYgoU7WB0=
X-Received: by 2002:a63:87c8:: with SMTP id i191mr30087839pge.131.1560419042416;
        Thu, 13 Jun 2019 02:44:02 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwkl4NO+yGdk1wDqv2WaZXqomrhtK5eYtWykaraQmceYm4qxhvnWK0eOWgfcATo2BTh51Iz
X-Received: by 2002:a63:87c8:: with SMTP id i191mr30087731pge.131.1560419041318;
        Thu, 13 Jun 2019 02:44:01 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1560419041; cv=none;
        d=google.com; s=arc-20160816;
        b=js/iklAgznsi78zBIlNKMYT2gu/zR678BEw4SkB+ILuH/tdlQw0dgwX6NgSOHHVw6G
         CrTNSvZcuQTChmHSIFaBfhYBXmbnWwPRPHnhQ4LHtVpYcG+UUi3sLXa3HFECspFbjVX4
         OLYV31CBxrAV0C56vYuib73GXPB8e9lXqSfcBe++hBDokvHaKri2UQHIdw0HmmpDOoHU
         c6uZeKKtivDk6mI3Grg5yyNomNOgOeOKoPUBcPYu+D4yPO41AtXBF52/I8Fys85bMWyP
         GFtqiaoSOeq/+1b74/sUy8mMl5GHxqCwvgXjlVwhBxH9FiSBgohQ1O6xnqi3AOuVFRwQ
         pA9A==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:dkim-signature;
        bh=0g0wuDYxGWA/uLah/sn+BRxeQhPX6KLUiVSrhTXjDEs=;
        b=JKaWYUWcOgdZ39ufEgSQJcxBECIn7eBLFzBozWXTS/mwwrCLRjRUNQslAJK7s6LpxP
         /ssSDPEAL/sKTipV9QT2bb9YcPnq4gWZYb/NcQwPgrEjiH/8xPLtwV2n4APuUhWMQbJV
         l6/qqzpG2xVE40pAlVB8I97P02OrKaPasTLgosjy7vyZCDzXZszzkTE7F/Mv9VzF++Te
         1CjFuaATHjSoGiY8FtifwyrkSep46hmT58GQ4ogzsRg6kcciTVt5gucFcej/XfBXMbRS
         VVCsQlKm5c0uzkzBQZhp0Uw+ajkUYeZakXth99tY9FzmhdNuVVEI7UUi+fwkrS1YmAww
         T9Pg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=ZLjh9Yz1;
       spf=pass (google.com: best guess record for domain of batv+aff2f865c54b6c032bcd+5772+infradead.org+hch@bombadil.srs.infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=BATV+aff2f865c54b6c032bcd+5772+infradead.org+hch@bombadil.srs.infradead.org
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id t10si2579961pgg.221.2019.06.13.02.44.01
        for <linux-mm@kvack.org>
        (version=TLS1_3 cipher=AEAD-AES256-GCM-SHA384 bits=256/256);
        Thu, 13 Jun 2019 02:44:01 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of batv+aff2f865c54b6c032bcd+5772+infradead.org+hch@bombadil.srs.infradead.org designates 2607:7c80:54:e::133 as permitted sender) client-ip=2607:7c80:54:e::133;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=ZLjh9Yz1;
       spf=pass (google.com: best guess record for domain of batv+aff2f865c54b6c032bcd+5772+infradead.org+hch@bombadil.srs.infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=BATV+aff2f865c54b6c032bcd+5772+infradead.org+hch@bombadil.srs.infradead.org
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
	d=infradead.org; s=bombadil.20170209; h=Content-Transfer-Encoding:
	MIME-Version:References:In-Reply-To:Message-Id:Date:Subject:Cc:To:From:Sender
	:Reply-To:Content-Type:Content-ID:Content-Description:Resent-Date:Resent-From
	:Resent-Sender:Resent-To:Resent-Cc:Resent-Message-ID:List-Id:List-Help:
	List-Unsubscribe:List-Subscribe:List-Post:List-Owner:List-Archive;
	bh=0g0wuDYxGWA/uLah/sn+BRxeQhPX6KLUiVSrhTXjDEs=; b=ZLjh9Yz1nklcjKdmhxD6xZcbQo
	QbG27zlG2JdbvoFLZ4goiroQQp5omTY7qsv0f1kkQHlkXOY5mtw4SIZ3UO+qnZZ9g2oWXish4ad26
	Y1nN1CTY2P0JV7cX1Vl+D2kXrDd/qJUxIh4ZgoV+i22hzsn25KEeQg91gzlTI4OUSHCCCbtQlxqm0
	1ihbJMMVc5tSN8cZILVzBB+hSKj5oUIWFefG9pKBC8SCrRkNz2gPZUlaWM9F73Kc0IiggR7UiyCPx
	mp0x9Pd7Ji7+hu/alGDMiKM1FIDL88GB6CxBWuAxCM1X94PTiZPav5hG47m7GQq1feotxeQQJsne8
	A3rm5Oow==;
Received: from mpp-cp1-natpool-1-198.ethz.ch ([82.130.71.198] helo=localhost)
	by bombadil.infradead.org with esmtpsa (Exim 4.92 #3 (Red Hat Linux))
	id 1hbMH0-0001pk-1S; Thu, 13 Jun 2019 09:43:58 +0000
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
Subject: [PATCH 10/22] memremap: add a migrate callback to struct dev_pagemap_ops
Date: Thu, 13 Jun 2019 11:43:13 +0200
Message-Id: <20190613094326.24093-11-hch@lst.de>
X-Mailer: git-send-email 2.20.1
In-Reply-To: <20190613094326.24093-1-hch@lst.de>
References: <20190613094326.24093-1-hch@lst.de>
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
---
 include/linux/hmm.h      |  6 ------
 include/linux/memremap.h |  6 ++++++
 include/linux/swapops.h  | 15 ---------------
 kernel/memremap.c        | 31 -------------------------------
 mm/hmm.c                 | 13 +++++--------
 mm/memory.c              |  9 ++-------
 6 files changed, 13 insertions(+), 67 deletions(-)

diff --git a/include/linux/hmm.h b/include/linux/hmm.h
index 5761a39221a6..3c9a59dbfdb8 100644
--- a/include/linux/hmm.h
+++ b/include/linux/hmm.h
@@ -658,11 +658,6 @@ struct hmm_devmem_ops {
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
@@ -673,7 +668,6 @@ struct hmm_devmem {
 	struct dev_pagemap		pagemap;
 	const struct hmm_devmem_ops	*ops;
 	struct percpu_ref		ref;
-	dev_page_fault_t		page_fault;
 };
 
 /*
diff --git a/include/linux/memremap.h b/include/linux/memremap.h
index 96a3a6d564ad..03a4099be701 100644
--- a/include/linux/memremap.h
+++ b/include/linux/memremap.h
@@ -75,6 +75,12 @@ struct dev_pagemap_ops {
 	 * Transition the percpu_ref in struct dev_pagemap to the dead state.
 	 */
 	void (*kill)(struct dev_pagemap *pgmap);
+
+	/*
+	 * Used for private (un-addressable) device memory only.  Must migrate
+	 * the page back to a CPU accessible page.
+	 */
+	vm_fault_t (*migrate)(struct vm_fault *vmf);
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
index 6a3183cac764..7167e717647d 100644
--- a/kernel/memremap.c
+++ b/kernel/memremap.c
@@ -11,7 +11,6 @@
 #include <linux/types.h>
 #include <linux/wait_bit.h>
 #include <linux/xarray.h>
-#include <linux/hmm.h>
 
 static DEFINE_XARRAY(pgmap_array);
 #define SECTION_MASK ~((1UL << PA_SECTION_SHIFT) - 1)
@@ -48,36 +47,6 @@ static inline int dev_pagemap_enable(struct device *dev)
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
diff --git a/mm/hmm.c b/mm/hmm.c
index 6dc769feb2e1..aab799677c7d 100644
--- a/mm/hmm.c
+++ b/mm/hmm.c
@@ -1330,15 +1330,12 @@ static void hmm_devmem_ref_kill(struct dev_pagemap *pgmap)
 	percpu_ref_kill(pgmap->ref);
 }
 
-static vm_fault_t hmm_devmem_fault(struct vm_area_struct *vma,
-			    unsigned long addr,
-			    const struct page *page,
-			    unsigned int flags,
-			    pmd_t *pmdp)
+static vm_fault_t hmm_devmem_migrate(struct vm_fault *vmf)
 {
-	struct hmm_devmem *devmem = page->pgmap->data;
+	struct hmm_devmem *devmem = vmf->page->pgmap->data;
 
-	return devmem->ops->fault(devmem, vma, addr, page, flags, pmdp);
+	return devmem->ops->fault(devmem, vmf->vma, vmf->address, vmf->page,
+			vmf->flags, vmf->pmd);
 }
 
 static void hmm_devmem_free(struct page *page, void *data)
@@ -1351,6 +1348,7 @@ static void hmm_devmem_free(struct page *page, void *data)
 static const struct dev_pagemap_ops hmm_pagemap_ops = {
 	.page_free		= hmm_devmem_free,
 	.kill			= hmm_devmem_ref_kill,
+	.migrate		= hmm_devmem_migrate,
 };
 
 /*
@@ -1405,7 +1403,6 @@ struct hmm_devmem *hmm_devmem_add(const struct hmm_devmem_ops *ops,
 	devmem->pfn_first = devmem->resource->start >> PAGE_SHIFT;
 	devmem->pfn_last = devmem->pfn_first +
 			   (resource_size(devmem->resource) >> PAGE_SHIFT);
-	devmem->page_fault = hmm_devmem_fault;
 
 	devmem->pagemap.type = MEMORY_DEVICE_PRIVATE;
 	devmem->pagemap.res = *devmem->resource;
diff --git a/mm/memory.c b/mm/memory.c
index ddf20bd0c317..cbf3cb598436 100644
--- a/mm/memory.c
+++ b/mm/memory.c
@@ -2782,13 +2782,8 @@ vm_fault_t do_swap_page(struct vm_fault *vmf)
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
+			ret = page->pgmap->ops->migrate(vmf);
 		} else if (is_hwpoison_entry(entry)) {
 			ret = VM_FAULT_HWPOISON;
 		} else {
-- 
2.20.1


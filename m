Return-Path: <SRS0=4FFe=UQ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.5 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id A4858C31E57
	for <linux-mm@archiver.kernel.org>; Mon, 17 Jun 2019 12:28:15 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 5FDE1208C0
	for <linux-mm@archiver.kernel.org>; Mon, 17 Jun 2019 12:28:15 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=infradead.org header.i=@infradead.org header.b="N1OQ9Slu"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 5FDE1208C0
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=lst.de
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 140228E000E; Mon, 17 Jun 2019 08:28:07 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 0F3B48E000B; Mon, 17 Jun 2019 08:28:06 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id DE8948E000E; Mon, 17 Jun 2019 08:28:06 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f198.google.com (mail-pg1-f198.google.com [209.85.215.198])
	by kanga.kvack.org (Postfix) with ESMTP id A1AEF8E000B
	for <linux-mm@kvack.org>; Mon, 17 Jun 2019 08:28:06 -0400 (EDT)
Received: by mail-pg1-f198.google.com with SMTP id c4so7633872pgm.21
        for <linux-mm@kvack.org>; Mon, 17 Jun 2019 05:28:06 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=iv+pqtBnZ+9vrpFbmVzdknNqM8MSPQoIbzGf9L5B0pI=;
        b=VPt5Xs7JiZHSB5hkL0jAMNpN1EdG2TGDALaxPQqdYudkI6Ef1dU8rMkuUxNUb8vRk3
         QAiKqsQQbqQBMXFvPYhQNDeqrerMTPZfvN0LKJutogImUikOR9ImWCpEc3BHgtEg7Mf8
         Vf8EsEXHmf5nCavpc6gmdQKbVn4tcXrKQLQo4ArBsSOhp0qeN/eAEW11iY/eM2KbzG1B
         beDNVnkY7ujljIoN7KQQfM1aaehF7BREZ1Qq4DM1w5PSPDVtQLPp7uz6LYO9dE/a2gDn
         7tvwJOad8dRaqc+yEyg/ZVmOVhzQZ3XOwiciWy0LdNWXuEpM6+8E9+pSc2LNROYkQF7d
         Efbw==
X-Gm-Message-State: APjAAAWeQqneSWZ409MPqKCZncRHkVSxf9rrE7v4f5uIEFeOAoJQKD/T
	eMWMOqOXapsjIvDkxTL4gs/6F/mxdrJrmfimTakkQTxoTQSaUt0TlKfdug9sGQF7wJE/g5XBd9L
	o+AIBLpqdHlI+WFZKvlg2TiuXUXYBfqTH2NiTdA66DYYWciEA+RFT1kK5fABMaoQ=
X-Received: by 2002:a63:5f16:: with SMTP id t22mr7976591pgb.156.1560774486200;
        Mon, 17 Jun 2019 05:28:06 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwwJbRygqYjaexjcLzf9NhSwrmiUOWEjOAIBuuiJC3/6Iq1w2eV+KYIyZjkgsMFn+o6Rc49
X-Received: by 2002:a63:5f16:: with SMTP id t22mr7976528pgb.156.1560774485171;
        Mon, 17 Jun 2019 05:28:05 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1560774485; cv=none;
        d=google.com; s=arc-20160816;
        b=Iym/1f29bk8cEmfkoZSGeNZlMh9m01Q7tPpwbxLLmRSGruq/OqH54I7ujBlsWcZ0R4
         ATrrGKEqGiiXzURSUzGJb0cakxZjZLlPKUx72fYWsneH+uq8jVYRQMj8yxQLePMr9L5l
         tOIs86dxsNOkakYWz9z7DAY6ogR1QxDHR2KQmLHvPo1YF+NGYDbIKELjn5d60SqKtYYZ
         OvO9J51LfDBnQORuf0oGOaWNNgOSG3g6z6BE0hFAbuolKfA6Gw0lh/Zm1S8JeNeIqS18
         un6ZD0XcIZGgPZkK8Hi+bfRq/nklZzaWXvdVvs7G6nP4ZLCb7y38FRIVM8u6sPVay+ni
         dgJQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:dkim-signature;
        bh=iv+pqtBnZ+9vrpFbmVzdknNqM8MSPQoIbzGf9L5B0pI=;
        b=kQuRCYFKw8F0RHaxGUJHLy3EbXwILNLLcMia6T7R93nkdfOsfNaWtcUeEjfjjZjluy
         i/AdOPzIdn3rSAed00yeYtrwHi1bEngUFEXVJR7cyiZz9HO2pZ1CfXRgVxkD15FEW3JI
         b5RgN1wCeS9Z1JCTCXe/QdkwU2IC1N8HnbFOBqa+dABcJ5wbd8lpucUD7BkUL7TCGKQz
         /u2Jvzq9g0GQIR105/bkfF7/i0mElahGkwMxroDSyi51aPj7UpN0q1TTWzrLB/H0sCSo
         UjRk6gup7aDdnccSDryM65r9PRogtkydWQvtxF2zEkNOmAQlyD+Ria7ZdB09ZClp0MRG
         Q48A==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=N1OQ9Slu;
       spf=pass (google.com: best guess record for domain of batv+a9ecd0bfb5b639be820a+5776+infradead.org+hch@bombadil.srs.infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=BATV+a9ecd0bfb5b639be820a+5776+infradead.org+hch@bombadil.srs.infradead.org
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id g35si10259081pje.73.2019.06.17.05.28.05
        for <linux-mm@kvack.org>
        (version=TLS1_3 cipher=AEAD-AES256-GCM-SHA384 bits=256/256);
        Mon, 17 Jun 2019 05:28:05 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of batv+a9ecd0bfb5b639be820a+5776+infradead.org+hch@bombadil.srs.infradead.org designates 2607:7c80:54:e::133 as permitted sender) client-ip=2607:7c80:54:e::133;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=N1OQ9Slu;
       spf=pass (google.com: best guess record for domain of batv+a9ecd0bfb5b639be820a+5776+infradead.org+hch@bombadil.srs.infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=BATV+a9ecd0bfb5b639be820a+5776+infradead.org+hch@bombadil.srs.infradead.org
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
	d=infradead.org; s=bombadil.20170209; h=Content-Transfer-Encoding:
	MIME-Version:References:In-Reply-To:Message-Id:Date:Subject:Cc:To:From:Sender
	:Reply-To:Content-Type:Content-ID:Content-Description:Resent-Date:Resent-From
	:Resent-Sender:Resent-To:Resent-Cc:Resent-Message-ID:List-Id:List-Help:
	List-Unsubscribe:List-Subscribe:List-Post:List-Owner:List-Archive;
	bh=iv+pqtBnZ+9vrpFbmVzdknNqM8MSPQoIbzGf9L5B0pI=; b=N1OQ9SluZvi98Ibke/xZB5BxX+
	HVWJ4hNyQg5HMYWozA63VMEhvoz1tAI35jZCuaEI4zSvMgTLHihi6fu+a0yB4sgXvQ3JVywEeSgZ1
	5SiPEROVO/ysqUEMXlfVOiurlEYPotzp3TK+XFRosVNjpnFs1vajh2o0y18nGPGqeTRoWrnTyxDw0
	M2jB5LSQy0WGONV9HzAYr70iXUxoFl+jivgQYph5y5e1Hgh4qk1jq5BZsmSnDyboDV9+bP3LjgxMA
	naw6fZMlAMnEVTVPWK/9HITFPpo936y/jFr9k2lBoGKyjSmlOkHTKJnbkkvEQHbrFsg1d661VS7aU
	bp3DCnmQ==;
Received: from clnet-p19-102.ikbnet.co.at ([83.175.77.102] helo=localhost)
	by bombadil.infradead.org with esmtpsa (Exim 4.92 #3 (Red Hat Linux))
	id 1hcqjx-0000Ap-Ob; Mon, 17 Jun 2019 12:28:02 +0000
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
Subject: [PATCH 11/25] memremap: add a migrate_to_ram method to struct dev_pagemap_ops
Date: Mon, 17 Jun 2019 14:27:19 +0200
Message-Id: <20190617122733.22432-12-hch@lst.de>
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
index 31e1c5347331..e64824334b85 100644
--- a/include/linux/hmm.h
+++ b/include/linux/hmm.h
@@ -694,11 +694,6 @@ struct hmm_devmem_ops {
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
@@ -709,7 +704,6 @@ struct hmm_devmem {
 	struct dev_pagemap		pagemap;
 	const struct hmm_devmem_ops	*ops;
 	struct percpu_ref		ref;
-	dev_page_fault_t		page_fault;
 };
 
 /*
diff --git a/include/linux/memremap.h b/include/linux/memremap.h
index cec02d5400f1..72a8a1a9303b 100644
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
index 7272027fbdd7..5245c25b10e3 100644
--- a/kernel/memremap.c
+++ b/kernel/memremap.c
@@ -11,7 +11,6 @@
 #include <linux/types.h>
 #include <linux/wait_bit.h>
 #include <linux/xarray.h>
-#include <linux/hmm.h>
 
 static DEFINE_XARRAY(pgmap_array);
 #define SECTION_MASK ~((1UL << PA_SECTION_SHIFT) - 1)
@@ -46,36 +45,6 @@ static int dev_pagemap_get_ops(struct device *dev, struct dev_pagemap *pgmap)
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
@@ -192,6 +161,10 @@ void *devm_memremap_pages(struct device *dev, struct dev_pagemap *pgmap)
 			WARN(1, "Device private memory not supported\n");
 			return ERR_PTR(-EINVAL);
 		}
+		if (!pgmap->ops || !pgmap->ops->migrate_to_ram) {
+			WARN(1, "Missing migrate_to_ram method\n");
+			return ERR_PTR(-EINVAL);
+		}
 		break;
 	case MEMORY_DEVICE_PUBLIC:
 		if (!IS_ENABLED(CONFIG_DEVICE_PUBLIC)) {
diff --git a/mm/hmm.c b/mm/hmm.c
index 0add50944d64..2e5642dc6b04 100644
--- a/mm/hmm.c
+++ b/mm/hmm.c
@@ -1363,15 +1363,12 @@ static void hmm_devmem_ref_kill(struct dev_pagemap *pgmap)
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
@@ -1385,6 +1382,7 @@ static const struct dev_pagemap_ops hmm_pagemap_ops = {
 	.page_free		= hmm_devmem_free,
 	.kill			= hmm_devmem_ref_kill,
 	.cleanup		= hmm_devmem_ref_exit,
+	.migrate_to_ram		= hmm_devmem_migrate_to_ram,
 };
 
 /*
@@ -1435,7 +1433,6 @@ struct hmm_devmem *hmm_devmem_add(const struct hmm_devmem_ops *ops,
 	devmem->pfn_first = devmem->resource->start >> PAGE_SHIFT;
 	devmem->pfn_last = devmem->pfn_first +
 			   (resource_size(devmem->resource) >> PAGE_SHIFT);
-	devmem->page_fault = hmm_devmem_fault;
 
 	devmem->pagemap.type = MEMORY_DEVICE_PRIVATE;
 	devmem->pagemap.res = *devmem->resource;
diff --git a/mm/memory.c b/mm/memory.c
index ddf20bd0c317..e8d0012032d7 100644
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
+			ret = vmf->page->pgmap->ops->migrate_to_ram(vmf);
 		} else if (is_hwpoison_entry(entry)) {
 			ret = VM_FAULT_HWPOISON;
 		} else {
-- 
2.20.1


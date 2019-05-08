Return-Path: <SRS0=OmxZ=TI=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.9 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,URIBL_BLOCKED,
	USER_AGENT_GIT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 8266BC04A6B
	for <linux-mm@archiver.kernel.org>; Wed,  8 May 2019 14:47:38 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 3C5E721019
	for <linux-mm@archiver.kernel.org>; Wed,  8 May 2019 14:47:38 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 3C5E721019
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=linux.intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 84EDC6B02C7; Wed,  8 May 2019 10:46:28 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 802E16B02CA; Wed,  8 May 2019 10:46:28 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 56E6C6B02CB; Wed,  8 May 2019 10:46:28 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f197.google.com (mail-pf1-f197.google.com [209.85.210.197])
	by kanga.kvack.org (Postfix) with ESMTP id 0AEEC6B02C7
	for <linux-mm@kvack.org>; Wed,  8 May 2019 10:46:28 -0400 (EDT)
Received: by mail-pf1-f197.google.com with SMTP id a141so12786431pfa.13
        for <linux-mm@kvack.org>; Wed, 08 May 2019 07:46:28 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=C6+rU85YmF2u5coeebI+WWQ+A0Fr/0PqCfQHlswCpow=;
        b=fvVOpemxZrEmGlr8ArKJqalL2m6QZmxNyvrVrKuPQvR/Rb4LRbXw60NOzUYUivx7Ab
         nae934/73lOX5W+CogOSvR+oevp2D9JVvaJJ/cwViAcOrevy/AzV4h6YvxNYRQZZ40+5
         etsspuj6IDILWz0sbZygmsGfZr4TQCqf8HhGSVJjpZKx+ghSmOyY+whcKHivE7UPgqrX
         YOzIXsggfqO9wfWtdNcy+oYse2jcCfsRnTZq6HMQ6v2S0XX5uOEg5e2vr6dNU/l1t0h6
         ggG7jyvLYzukWc75w8alSJfjOdEqK3JLN/1Sa+APGv5yPzIz+IQQfp5YUg7xjxKBq/8Y
         VMvQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: best guess record for domain of kirill.shutemov@linux.intel.com designates 192.55.52.151 as permitted sender) smtp.mailfrom=kirill.shutemov@linux.intel.com;       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Gm-Message-State: APjAAAXONRsDheCGefHxTLE+8FsMCTwEUlhnEKjtyVK/B1cdjaAEKSPO
	TLpkGwDW3Rat9poMhJo9MmK+D/3tIzvpU/nZjK3cW5Q+AlPJQDcujQ07mAneJtqi5iqTLqRytAx
	nCUa1iTH8DNb4RzKvb+jAgC6zh9dls3ekqT7n4U2ObyZGjA3cG65gGGtYjE0eGePxsg==
X-Received: by 2002:aa7:8190:: with SMTP id g16mr49303179pfi.92.1557326787713;
        Wed, 08 May 2019 07:46:27 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzFSIlF/x2yrxTV5f2DesZxZR2qpouZzzYlXEGeX1GbNWC8BuGZhftM9Aw3vtKGa0r+Wy5e
X-Received: by 2002:aa7:8190:: with SMTP id g16mr49291599pfi.92.1557326691967;
        Wed, 08 May 2019 07:44:51 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1557326691; cv=none;
        d=google.com; s=arc-20160816;
        b=IF1AZ6jwYyfPmHNxFIIuqrbjbw4/p9YXhSlYhIWCIkMdsy//YcdqBjnvJtmDFwNbtA
         BMhSq3UfghVCFBJHK5LNsuFwGDaLvO4+GNAc3ZIpBeavtfbgg3RrB2iG/KExN8keLp5G
         k9cS/Z15k5sUqKL9sCkGq23Mb9LUIQIg2QG9DncuzbuK+9QnxJFqDRSjzDdGLXRq6Iye
         kVimzbSV9uMkJxMtNREKx7eBxURophl+9qgVgKIz1vLpghJqe/piNCbrhWEzTkyFdsye
         O7vM4zKPSs8an28nwGxC6ykz4erF3pP3x/LjXMkjl7jV3+UEsxh8A+bXBAOOFWHZa/iF
         eM2w==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from;
        bh=C6+rU85YmF2u5coeebI+WWQ+A0Fr/0PqCfQHlswCpow=;
        b=ds2EyNm6ABc9QwHipVcsQiLyHSAP9Kh/oFGU67Ju5+9jE1jlQ5GcxXkLTV6qxKSATN
         /8wksPMSirvJVydxXoXr5Vw/57mBwdgCd+g2qTzdaQRHxD0Fq78A4ABt0D6wJpskJxDv
         5f7oxvz3Vvlo1Z2Il9gQrVfLsUKdNrdGKnlyUwzd7Wlq6M0RP69jwLZ2O1xd09LgYLS0
         I1MZYTWtoL8xzMLr8QY+870mEi+BCRygTGkLq2ZtK6zEgddlp5/Ix7MMYY3aU8ns5uvW
         +JqpvDeE2IqBIAnZOtUqnFJ73YHvWqS1aoxKbYqEBd3WaoBz8zpAaopY/MhGMACBaIU5
         4Fuw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: best guess record for domain of kirill.shutemov@linux.intel.com designates 192.55.52.151 as permitted sender) smtp.mailfrom=kirill.shutemov@linux.intel.com;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mga17.intel.com (mga17.intel.com. [192.55.52.151])
        by mx.google.com with ESMTPS id b63si24289903plb.146.2019.05.08.07.44.51
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 08 May 2019 07:44:51 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of kirill.shutemov@linux.intel.com designates 192.55.52.151 as permitted sender) client-ip=192.55.52.151;
Authentication-Results: mx.google.com;
       spf=pass (google.com: best guess record for domain of kirill.shutemov@linux.intel.com designates 192.55.52.151 as permitted sender) smtp.mailfrom=kirill.shutemov@linux.intel.com;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Amp-Result: SKIPPED(no attachment in message)
X-Amp-File-Uploaded: False
Received: from orsmga003.jf.intel.com ([10.7.209.27])
  by fmsmga107.fm.intel.com with ESMTP/TLS/DHE-RSA-AES256-GCM-SHA384; 08 May 2019 07:44:51 -0700
X-ExtLoop1: 1
Received: from black.fi.intel.com ([10.237.72.28])
  by orsmga003.jf.intel.com with ESMTP; 08 May 2019 07:44:46 -0700
Received: by black.fi.intel.com (Postfix, from userid 1000)
	id 474571101; Wed,  8 May 2019 17:44:31 +0300 (EEST)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
To: Andrew Morton <akpm@linux-foundation.org>,
	x86@kernel.org,
	Thomas Gleixner <tglx@linutronix.de>,
	Ingo Molnar <mingo@redhat.com>,
	"H. Peter Anvin" <hpa@zytor.com>,
	Borislav Petkov <bp@alien8.de>,
	Peter Zijlstra <peterz@infradead.org>,
	Andy Lutomirski <luto@amacapital.net>,
	David Howells <dhowells@redhat.com>
Cc: Kees Cook <keescook@chromium.org>,
	Dave Hansen <dave.hansen@intel.com>,
	Kai Huang <kai.huang@linux.intel.com>,
	Jacob Pan <jacob.jun.pan@linux.intel.com>,
	Alison Schofield <alison.schofield@intel.com>,
	linux-mm@kvack.org,
	kvm@vger.kernel.org,
	keyrings@vger.kernel.org,
	linux-kernel@vger.kernel.org,
	"Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>
Subject: [PATCH, RFC 51/62] iommu/vt-d: Support MKTME in DMA remapping
Date: Wed,  8 May 2019 17:44:11 +0300
Message-Id: <20190508144422.13171-52-kirill.shutemov@linux.intel.com>
X-Mailer: git-send-email 2.20.1
In-Reply-To: <20190508144422.13171-1-kirill.shutemov@linux.intel.com>
References: <20190508144422.13171-1-kirill.shutemov@linux.intel.com>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

From: Jacob Pan <jacob.jun.pan@linux.intel.com>

When MKTME is enabled, keyid is stored in the high order bits of physical
address. For DMA transactions targeting encrypted physical memory, keyid
must be included in the IOVA to physical address translation.

This patch appends page keyid when setting up the IOMMU PTEs. On the
reverse direction, keyid bits are cleared in the physical address lookup.
Mapping functions of both DMA ops and IOMMU ops are covered.

Signed-off-by: Jacob Pan <jacob.jun.pan@linux.intel.com>
Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
---
 drivers/iommu/intel-iommu.c | 29 +++++++++++++++++++++++++++--
 include/linux/intel-iommu.h |  9 ++++++++-
 2 files changed, 35 insertions(+), 3 deletions(-)

diff --git a/drivers/iommu/intel-iommu.c b/drivers/iommu/intel-iommu.c
index 28cb713d728c..1ff7e87e25f1 100644
--- a/drivers/iommu/intel-iommu.c
+++ b/drivers/iommu/intel-iommu.c
@@ -862,6 +862,28 @@ static void free_context_table(struct intel_iommu *iommu)
 	spin_unlock_irqrestore(&iommu->lock, flags);
 }
 
+static inline void set_pte_mktme_keyid(unsigned long phys_pfn,
+		phys_addr_t *pteval)
+{
+	unsigned long keyid;
+
+	if (!pfn_valid(phys_pfn))
+		return;
+
+	keyid = page_keyid(pfn_to_page(phys_pfn));
+
+#ifdef CONFIG_X86_INTEL_MKTME
+	/*
+	 * When MKTME is enabled, set keyid in PTE such that DMA
+	 * remapping will include keyid in the translation from IOVA
+	 * to physical address. This applies to both user and kernel
+	 * allocated DMA memory.
+	 */
+	*pteval &= ~mktme_keyid_mask;
+	*pteval |= keyid << mktme_keyid_shift;
+#endif
+}
+
 static struct dma_pte *pfn_to_dma_pte(struct dmar_domain *domain,
 				      unsigned long pfn, int *target_level)
 {
@@ -888,7 +910,7 @@ static struct dma_pte *pfn_to_dma_pte(struct dmar_domain *domain,
 			break;
 
 		if (!dma_pte_present(pte)) {
-			uint64_t pteval;
+			phys_addr_t pteval;
 
 			tmp_page = alloc_pgtable_page(domain->nid);
 
@@ -896,7 +918,8 @@ static struct dma_pte *pfn_to_dma_pte(struct dmar_domain *domain,
 				return NULL;
 
 			domain_flush_cache(domain, tmp_page, VTD_PAGE_SIZE);
-			pteval = ((uint64_t)virt_to_dma_pfn(tmp_page) << VTD_PAGE_SHIFT) | DMA_PTE_READ | DMA_PTE_WRITE;
+			pteval = (virt_to_dma_pfn(tmp_page) << VTD_PAGE_SHIFT) | DMA_PTE_READ | DMA_PTE_WRITE;
+			set_pte_mktme_keyid(virt_to_dma_pfn(tmp_page), &pteval);
 			if (cmpxchg64(&pte->val, 0ULL, pteval))
 				/* Someone else set it while we were thinking; use theirs. */
 				free_pgtable_page(tmp_page);
@@ -2289,6 +2312,8 @@ static int __domain_mapping(struct dmar_domain *domain, unsigned long iov_pfn,
 			}
 
 		}
+		set_pte_mktme_keyid(phys_pfn, &pteval);
+
 		/* We don't need lock here, nobody else
 		 * touches the iova range
 		 */
diff --git a/include/linux/intel-iommu.h b/include/linux/intel-iommu.h
index fa364de9db18..48a377a2b896 100644
--- a/include/linux/intel-iommu.h
+++ b/include/linux/intel-iommu.h
@@ -34,6 +34,8 @@
 
 #include <asm/cacheflush.h>
 #include <asm/iommu.h>
+#include <asm/page.h>
+
 
 /*
  * VT-d hardware uses 4KiB page size regardless of host page size.
@@ -603,7 +605,12 @@ static inline void dma_clear_pte(struct dma_pte *pte)
 static inline u64 dma_pte_addr(struct dma_pte *pte)
 {
 #ifdef CONFIG_64BIT
-	return pte->val & VTD_PAGE_MASK;
+	u64 addr = pte->val;
+	addr &= VTD_PAGE_MASK;
+#ifdef CONFIG_X86_INTEL_MKTME
+	addr &= ~mktme_keyid_mask;
+#endif
+	return addr;
 #else
 	/* Must have a full atomic 64-bit read */
 	return  __cmpxchg64(&pte->val, 0ULL, 0ULL) & VTD_PAGE_MASK;
-- 
2.20.1


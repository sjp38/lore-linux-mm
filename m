Return-Path: <SRS0=2Grs=V4=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.8 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 1ABC9C32751
	for <linux-mm@archiver.kernel.org>; Wed, 31 Jul 2019 15:14:48 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id CA42820693
	for <linux-mm@archiver.kernel.org>; Wed, 31 Jul 2019 15:14:47 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=shutemov-name.20150623.gappssmtp.com header.i=@shutemov-name.20150623.gappssmtp.com header.b="0XV6P/gt"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org CA42820693
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=shutemov.name
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 8513A8E0034; Wed, 31 Jul 2019 11:14:02 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 7D9D08E0030; Wed, 31 Jul 2019 11:14:02 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 6CA668E0035; Wed, 31 Jul 2019 11:14:02 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f70.google.com (mail-ed1-f70.google.com [209.85.208.70])
	by kanga.kvack.org (Postfix) with ESMTP id 17F068E0030
	for <linux-mm@kvack.org>; Wed, 31 Jul 2019 11:14:02 -0400 (EDT)
Received: by mail-ed1-f70.google.com with SMTP id n3so42588186edr.8
        for <linux-mm@kvack.org>; Wed, 31 Jul 2019 08:14:02 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=hC2uwgXxojO8zk/Rcrr6mceJUJW70ppjchwtq4ruRCg=;
        b=FYpAeKIWQCEMCndPv+YnKbgZYfNQW5hYKFn6+XQm/8knomxgw7XWCxeBsUbgzdDaYI
         fEyryF4XUY3xENtJSA5EN8s9AZsuUnwNzmeUpQ1lB3mNRUItmOroKltUEcieycnc+C6j
         EWNJMoJ3NCbQW9VYjuuTz0PKWrXnaK/9Su8Gna26v+RXLVdYlV3gQ3jkYyazmHIdzBMP
         nw9wQpZrHVhjKnhL2hhDzmu/mtOe2F6t8sRWZXCe2LUhcVHq9NMVnZC8ZsXCteNvVYK7
         El+VI8L0djyxt0N+tGJmHH69ggvLvUKDN8GyesZO3Zr8z/u7I34EXay065Z0TlUPIpto
         gsgA==
X-Gm-Message-State: APjAAAWt6S0r7/5t7PJ59v7Vrq4DEIDJM12w1I5Y8Ufelf4JVNS40Vqv
	w3FS0u5Moi+dRcmeQTv5ceVIlC9wHIGiIjA0Q9/L2zNRt2+5NSAptb1Rogzd63/pmV/ufV99UzH
	+lnknim5ERIqquxk0SJ0M/ESZ0J9WQUFxg1ICVVWxU5l0BX03O04n7dNh8XkPxHE=
X-Received: by 2002:a17:906:3f87:: with SMTP id b7mr92885567ejj.164.1564586041626;
        Wed, 31 Jul 2019 08:14:01 -0700 (PDT)
X-Received: by 2002:a17:906:3f87:: with SMTP id b7mr92885439ejj.164.1564586040181;
        Wed, 31 Jul 2019 08:14:00 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1564586040; cv=none;
        d=google.com; s=arc-20160816;
        b=cWvMm+TmCN93Sk8DLhp+lMS+GnE7VgR/1/QLBL8kMkYKEfxABRH4prYMc0WisTPFUP
         x3iUCx0zM5P8E1fCGSTtDQsDCTgtAYszle+IPrIPAZwAdHOAv5o4H6ExN2DFJxq+3MCS
         PENNzgRuV9luRmcncXoCGULZitPnTx/OIuJJPhQFJu/u9yCEoooVX2r9ZUiNnnTTTxfl
         qI40Ai+aHZXN6uz8hEaCkMFq52kzlTZkY5a503NPa1j4WlQGkVWQi4ADD0AFO44r1fOz
         HuL5j9NIT18HnaMwBQmrEsjHpySxCxd0swX26mfcCYrDAOtobwUdZFddIWBCix13IAsA
         sQiw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:dkim-signature;
        bh=hC2uwgXxojO8zk/Rcrr6mceJUJW70ppjchwtq4ruRCg=;
        b=ssvlSR//Hze1lNw4QrLD+ptIUgmUbLPaeIbcTN3EvinNPn0XKYifI2FibyuxnRGtWa
         zoguVAbJ+UVMPbHgqOEzDMpYiExjPetC+jQWTduNVzlO5sszLSoC6yUUTcTR8nKE648P
         jmpt5cT8h6dxa2wvOGxmRTSqJW+JP7v7XAWZ7jAec8nDFimZFaMYq7SCC6DUku6riUvm
         65e3s2Ps9xxh0cISDI32JL0BbIn7CgkPLx8JlkxAYqeWB2qTl97TSb+2s1PJ8Z958hon
         8bK7eD3GsbX8hKneHkUIS9qb0XlUdmuwPFeEu5952fSCIgOgnXDk/ML11Lq8ToyO10bh
         7gTQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@shutemov-name.20150623.gappssmtp.com header.s=20150623 header.b="0XV6P/gt";
       spf=neutral (google.com: 209.85.220.65 is neither permitted nor denied by best guess record for domain of kirill@shutemov.name) smtp.mailfrom=kirill@shutemov.name
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id r6sor22075013ejr.30.2019.07.31.08.13.59
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 31 Jul 2019 08:14:00 -0700 (PDT)
Received-SPF: neutral (google.com: 209.85.220.65 is neither permitted nor denied by best guess record for domain of kirill@shutemov.name) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@shutemov-name.20150623.gappssmtp.com header.s=20150623 header.b="0XV6P/gt";
       spf=neutral (google.com: 209.85.220.65 is neither permitted nor denied by best guess record for domain of kirill@shutemov.name) smtp.mailfrom=kirill@shutemov.name
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=shutemov-name.20150623.gappssmtp.com; s=20150623;
        h=from:to:cc:subject:date:message-id:in-reply-to:references
         :mime-version:content-transfer-encoding;
        bh=hC2uwgXxojO8zk/Rcrr6mceJUJW70ppjchwtq4ruRCg=;
        b=0XV6P/gt+Sg4f27WCDZfMiz3yUD8gmqmXbpUkqw2qeKte/64P4ld/yFj9TtHQsxMva
         Sbd6SFVGZn15wA2StFIL5OKo0viglmdPGCy3S9nsnoLjxmIaz4pZPHVNhzJMBFiEItzK
         GGFxIZHfCywnX+w1VFB8az1H4FFBZ0dEp86xAnm0F7Jfw3TX8bJ2UwJ4MOp6xtqistdS
         ci1LlbxLwNn2UPtS72pBvzNbUsUQSbVvUvjpSYYoWOORZ9uWxZOyAGcJabNrh3zrp7Ty
         xsBZdp44F7iwElj0Db5RusDWd82dGLl/6L2fkZUDkulyOvXwh+aBdW95+eM1LPwVFqZZ
         pCfQ==
X-Google-Smtp-Source: APXvYqz5v5Tv2OUvZrbCEWIRRAB8vEgVkF30Jl6xeuTpZr0HJyo73/wTXum206aQYtxXoB+6KiDpDg==
X-Received: by 2002:a17:906:9447:: with SMTP id z7mr29540487ejx.165.1564586039736;
        Wed, 31 Jul 2019 08:13:59 -0700 (PDT)
Received: from box.localdomain ([86.57.175.117])
        by smtp.gmail.com with ESMTPSA id g11sm12443173ejm.86.2019.07.31.08.13.53
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 31 Jul 2019 08:13:57 -0700 (PDT)
From: "Kirill A. Shutemov" <kirill@shutemov.name>
X-Google-Original-From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Received: by box.localdomain (Postfix, from userid 1000)
	id 488B9104606; Wed, 31 Jul 2019 18:08:17 +0300 (+03)
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
Subject: [PATCHv2 48/59] iommu/vt-d: Support MKTME in DMA remapping
Date: Wed, 31 Jul 2019 18:08:02 +0300
Message-Id: <20190731150813.26289-49-kirill.shutemov@linux.intel.com>
X-Mailer: git-send-email 2.21.0
In-Reply-To: <20190731150813.26289-1-kirill.shutemov@linux.intel.com>
References: <20190731150813.26289-1-kirill.shutemov@linux.intel.com>
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
index ac4172c02244..32d22872656b 100644
--- a/drivers/iommu/intel-iommu.c
+++ b/drivers/iommu/intel-iommu.c
@@ -867,6 +867,28 @@ static void free_context_table(struct intel_iommu *iommu)
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
+	*pteval &= ~mktme_keyid_mask();
+	*pteval |= keyid << mktme_keyid_shift();
+#endif
+}
+
 static struct dma_pte *pfn_to_dma_pte(struct dmar_domain *domain,
 				      unsigned long pfn, int *target_level)
 {
@@ -893,7 +915,7 @@ static struct dma_pte *pfn_to_dma_pte(struct dmar_domain *domain,
 			break;
 
 		if (!dma_pte_present(pte)) {
-			uint64_t pteval;
+			phys_addr_t pteval;
 
 			tmp_page = alloc_pgtable_page(domain->nid);
 
@@ -901,7 +923,8 @@ static struct dma_pte *pfn_to_dma_pte(struct dmar_domain *domain,
 				return NULL;
 
 			domain_flush_cache(domain, tmp_page, VTD_PAGE_SIZE);
-			pteval = ((uint64_t)virt_to_dma_pfn(tmp_page) << VTD_PAGE_SHIFT) | DMA_PTE_READ | DMA_PTE_WRITE;
+			pteval = (virt_to_dma_pfn(tmp_page) << VTD_PAGE_SHIFT) | DMA_PTE_READ | DMA_PTE_WRITE;
+			set_pte_mktme_keyid(virt_to_dma_pfn(tmp_page), &pteval);
 			if (cmpxchg64(&pte->val, 0ULL, pteval))
 				/* Someone else set it while we were thinking; use theirs. */
 				free_pgtable_page(tmp_page);
@@ -2214,6 +2237,8 @@ static int __domain_mapping(struct dmar_domain *domain, unsigned long iov_pfn,
 			}
 
 		}
+		set_pte_mktme_keyid(phys_pfn, &pteval);
+
 		/* We don't need lock here, nobody else
 		 * touches the iova range
 		 */
diff --git a/include/linux/intel-iommu.h b/include/linux/intel-iommu.h
index f2ae8a006ff8..8fbb9353d5a6 100644
--- a/include/linux/intel-iommu.h
+++ b/include/linux/intel-iommu.h
@@ -22,6 +22,8 @@
 
 #include <asm/cacheflush.h>
 #include <asm/iommu.h>
+#include <asm/page.h>
+
 
 /*
  * VT-d hardware uses 4KiB page size regardless of host page size.
@@ -608,7 +610,12 @@ static inline void dma_clear_pte(struct dma_pte *pte)
 static inline u64 dma_pte_addr(struct dma_pte *pte)
 {
 #ifdef CONFIG_64BIT
-	return pte->val & VTD_PAGE_MASK;
+	u64 addr = pte->val;
+	addr &= VTD_PAGE_MASK;
+#ifdef CONFIG_X86_INTEL_MKTME
+	addr &= ~mktme_keyid_mask();
+#endif
+	return addr;
 #else
 	/* Must have a full atomic 64-bit read */
 	return  __cmpxchg64(&pte->val, 0ULL, 0ULL) & VTD_PAGE_MASK;
-- 
2.21.0


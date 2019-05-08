Return-Path: <SRS0=OmxZ=TI=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.9 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,USER_AGENT_GIT
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 478FCC04A6B
	for <linux-mm@archiver.kernel.org>; Wed,  8 May 2019 14:44:42 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 05FEF2173C
	for <linux-mm@archiver.kernel.org>; Wed,  8 May 2019 14:44:41 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 05FEF2173C
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=linux.intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 1C3D26B000D; Wed,  8 May 2019 10:44:37 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 0AE436B000A; Wed,  8 May 2019 10:44:37 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id E1B106B000C; Wed,  8 May 2019 10:44:36 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f200.google.com (mail-pl1-f200.google.com [209.85.214.200])
	by kanga.kvack.org (Postfix) with ESMTP id 84EE36B0005
	for <linux-mm@kvack.org>; Wed,  8 May 2019 10:44:36 -0400 (EDT)
Received: by mail-pl1-f200.google.com with SMTP id f3so11614818plb.17
        for <linux-mm@kvack.org>; Wed, 08 May 2019 07:44:36 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=Sxk2x6HISKLJRuuRm6m1tq95dR8EsdPH1NWCxyLMIQY=;
        b=PAWWbNTiRirsPlTDlFm+615IathWNYJcGvA5l43AF6aBCLdw1JCZxgvFDFw+oibJSq
         3AMQzE/ngbvjaxHFvYr0VsKKInvoDRV2u0a6LNJIC56IJ23CEjm4pt9heaf9EW/z+gWR
         FimWzSsW/OO6ZdWTI2J+kE5p1qdMkS23HHJKjyOyhMQD4F0IvvPIDfb1OcE/FNHR1i+6
         CDLskgJ54IrSWJ5BTVdReaFi1cgn1S4YWgwjLzTkf6CWhc6RyVUi6OP0o/8XRf1UfX3N
         lgpIRtcPmQFwuLRgSqziy3+1Fb32DkXjrKGw6dHNzk9Srz5dsu/H8FTt5kmmwGXxbQ95
         2Scw==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: best guess record for domain of kirill.shutemov@linux.intel.com designates 134.134.136.65 as permitted sender) smtp.mailfrom=kirill.shutemov@linux.intel.com;       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Gm-Message-State: APjAAAW3965itK4EI/yP9x7l9GKqkFPFaQ+LEbO/JIwpijhalDKedvNx
	mwp+4GVks2Ts7tcqaDN3DG+tnLp1eeBqfLsF2TKjLhncmbXbXugkBqCtcczhYaGaRyZw7OTwDp4
	IXk1PnrXhbTST3W9eHDk4nFeN7iDbhgOFGAM0INteRqSi2pxq7vFXv8EzP4nUf47H+g==
X-Received: by 2002:a63:b64:: with SMTP id a36mr41319128pgl.58.1557326676186;
        Wed, 08 May 2019 07:44:36 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxFAx3XoKBn/Q+zIM8TApPHF0WQfFyma+8dafEKZNQVrNAhbiWVPXH/ZyD6OFajqjG72xck
X-Received: by 2002:a63:b64:: with SMTP id a36mr41318968pgl.58.1557326674651;
        Wed, 08 May 2019 07:44:34 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1557326674; cv=none;
        d=google.com; s=arc-20160816;
        b=ITo2IYCXkKyT5wDNats5C0uJIsGjKf7UZDl3kUrZSegOnauJOKoacyK8Hon1VNTGE1
         SLb96Dpx/mlsvnaOmamVrZboj4wjSTysymjixvOfwOoVTNOUghrH9A38YY723aqvz6+O
         qtwyrdzqh3ojME+YxBo1kr5+MeU2fKpdmfSkK/2a/N6m+kScAjcLmF3mmOM4lpbz1Gkw
         jyPM7pn/ghkKMrE9cRfru/qPatRUicJx6b2DEnhCq/xJ+F9vhgC0cougXUfwJwaWGIrs
         rvobCxoeo0ZAjcgMKBqL9mK9rUNSO0BgaHJVVWgmSVyQLH2DZGQecMJGfTQ1eSVozc4a
         Jq0w==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from;
        bh=Sxk2x6HISKLJRuuRm6m1tq95dR8EsdPH1NWCxyLMIQY=;
        b=ky/tSIkSJ4iGDAIMiQBsFIlIlfg7yahSNo2+of9UHnMfl6VNayaHPqaiVeej1rsePj
         zyUNkciGYb/zFBwUa03AXGOODt8Ll04EGkmyqnjJGN1tL2PTjmPR287dJlUgcYfH8XvL
         OdNl0teqy2ZZyn/4M+XSLhKMyy5wDCzVfpgM61RK0bnoWqVemLiDs+RVBbLKST40IOvl
         5nobVZ+RoOcFZCrJ/AXElTUEZhN7J+FUntwYLlRsEPrhQydsE747wDjhlv9ub1TInIhq
         He9l9Im/BFEflyMPdrroy8rxvebr18kwB3Wde2CiawYFQz6oKPXxvPDQq1l1JuAHaVX6
         D3Fw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: best guess record for domain of kirill.shutemov@linux.intel.com designates 134.134.136.65 as permitted sender) smtp.mailfrom=kirill.shutemov@linux.intel.com;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mga03.intel.com (mga03.intel.com. [134.134.136.65])
        by mx.google.com with ESMTPS id n6si22562220pgq.486.2019.05.08.07.44.34
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 08 May 2019 07:44:34 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of kirill.shutemov@linux.intel.com designates 134.134.136.65 as permitted sender) client-ip=134.134.136.65;
Authentication-Results: mx.google.com;
       spf=pass (google.com: best guess record for domain of kirill.shutemov@linux.intel.com designates 134.134.136.65 as permitted sender) smtp.mailfrom=kirill.shutemov@linux.intel.com;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Amp-Result: SKIPPED(no attachment in message)
X-Amp-File-Uploaded: False
Received: from fmsmga008.fm.intel.com ([10.253.24.58])
  by orsmga103.jf.intel.com with ESMTP; 08 May 2019 07:44:33 -0700
X-ExtLoop1: 1
Received: from black.fi.intel.com ([10.237.72.28])
  by fmsmga008.fm.intel.com with ESMTP; 08 May 2019 07:44:29 -0700
Received: by black.fi.intel.com (Postfix, from userid 1000)
	id 9AE752E5; Wed,  8 May 2019 17:44:28 +0300 (EEST)
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
	"Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: [PATCH, RFC 02/62] mm: Add helpers to setup zero page mappings
Date: Wed,  8 May 2019 17:43:22 +0300
Message-Id: <20190508144422.13171-3-kirill.shutemov@linux.intel.com>
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

When kernel setups an encrypted page mapping, encryption KeyID is
derived from a VMA. KeyID is going to be part of vma->vm_page_prot and
it will be propagated transparently to page table entry on mk_pte().

But there is an exception: zero page is never encrypted and its mapping
must use KeyID-0, regardless VMA's KeyID.

Introduce helpers that create a page table entry for zero page.

The generic implementation will be overridden by architecture-specific
code that takes care about using correct KeyID.

Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
---
 fs/dax.c                      | 3 +--
 include/asm-generic/pgtable.h | 8 ++++++++
 mm/huge_memory.c              | 6 ++----
 mm/memory.c                   | 3 +--
 mm/userfaultfd.c              | 3 +--
 5 files changed, 13 insertions(+), 10 deletions(-)

diff --git a/fs/dax.c b/fs/dax.c
index e5e54da1715f..6d609bff53b9 100644
--- a/fs/dax.c
+++ b/fs/dax.c
@@ -1441,8 +1441,7 @@ static vm_fault_t dax_pmd_load_hole(struct xa_state *xas, struct vm_fault *vmf,
 		pgtable_trans_huge_deposit(vma->vm_mm, vmf->pmd, pgtable);
 		mm_inc_nr_ptes(vma->vm_mm);
 	}
-	pmd_entry = mk_pmd(zero_page, vmf->vma->vm_page_prot);
-	pmd_entry = pmd_mkhuge(pmd_entry);
+	pmd_entry = mk_zero_pmd(zero_page, vmf->vma->vm_page_prot);
 	set_pmd_at(vmf->vma->vm_mm, pmd_addr, vmf->pmd, pmd_entry);
 	spin_unlock(ptl);
 	trace_dax_pmd_load_hole(inode, vmf, zero_page, *entry);
diff --git a/include/asm-generic/pgtable.h b/include/asm-generic/pgtable.h
index fa782fba51ee..cde8b81f6f2b 100644
--- a/include/asm-generic/pgtable.h
+++ b/include/asm-generic/pgtable.h
@@ -879,8 +879,16 @@ static inline unsigned long my_zero_pfn(unsigned long addr)
 }
 #endif
 
+#ifndef mk_zero_pte
+#define mk_zero_pte(addr, prot) pte_mkspecial(pfn_pte(my_zero_pfn(addr), prot))
+#endif
+
 #ifdef CONFIG_MMU
 
+#ifndef mk_zero_pmd
+#define mk_zero_pmd(zero_page, prot) pmd_mkhuge(mk_pmd(zero_page, prot))
+#endif
+
 #ifndef CONFIG_TRANSPARENT_HUGEPAGE
 static inline int pmd_trans_huge(pmd_t pmd)
 {
diff --git a/mm/huge_memory.c b/mm/huge_memory.c
index 165ea46bf149..26c3503824ba 100644
--- a/mm/huge_memory.c
+++ b/mm/huge_memory.c
@@ -675,8 +675,7 @@ static bool set_huge_zero_page(pgtable_t pgtable, struct mm_struct *mm,
 	pmd_t entry;
 	if (!pmd_none(*pmd))
 		return false;
-	entry = mk_pmd(zero_page, vma->vm_page_prot);
-	entry = pmd_mkhuge(entry);
+	entry = mk_zero_pmd(zero_page, vma->vm_page_prot);
 	if (pgtable)
 		pgtable_trans_huge_deposit(mm, pmd, pgtable);
 	set_pmd_at(mm, haddr, pmd, entry);
@@ -2101,8 +2100,7 @@ static void __split_huge_zero_page_pmd(struct vm_area_struct *vma,
 
 	for (i = 0; i < HPAGE_PMD_NR; i++, haddr += PAGE_SIZE) {
 		pte_t *pte, entry;
-		entry = pfn_pte(my_zero_pfn(haddr), vma->vm_page_prot);
-		entry = pte_mkspecial(entry);
+		entry = mk_zero_pte(haddr, vma->vm_page_prot);
 		pte = pte_offset_map(&_pmd, haddr);
 		VM_BUG_ON(!pte_none(*pte));
 		set_pte_at(mm, haddr, pte, entry);
diff --git a/mm/memory.c b/mm/memory.c
index ab650c21bccd..c5e0c87a12b7 100644
--- a/mm/memory.c
+++ b/mm/memory.c
@@ -2927,8 +2927,7 @@ static vm_fault_t do_anonymous_page(struct vm_fault *vmf)
 	/* Use the zero-page for reads */
 	if (!(vmf->flags & FAULT_FLAG_WRITE) &&
 			!mm_forbids_zeropage(vma->vm_mm)) {
-		entry = pte_mkspecial(pfn_pte(my_zero_pfn(vmf->address),
-						vma->vm_page_prot));
+		entry = mk_zero_pte(vmf->address, vma->vm_page_prot);
 		vmf->pte = pte_offset_map_lock(vma->vm_mm, vmf->pmd,
 				vmf->address, &vmf->ptl);
 		if (!pte_none(*vmf->pte))
diff --git a/mm/userfaultfd.c b/mm/userfaultfd.c
index d59b5a73dfb3..ac1ce3866036 100644
--- a/mm/userfaultfd.c
+++ b/mm/userfaultfd.c
@@ -122,8 +122,7 @@ static int mfill_zeropage_pte(struct mm_struct *dst_mm,
 	pgoff_t offset, max_off;
 	struct inode *inode;
 
-	_dst_pte = pte_mkspecial(pfn_pte(my_zero_pfn(dst_addr),
-					 dst_vma->vm_page_prot));
+	_dst_pte = mk_zero_pte(dst_addr, dst_vma->vm_page_prot);
 	dst_pte = pte_offset_map_lock(dst_mm, dst_pmd, dst_addr, &ptl);
 	if (dst_vma->vm_file) {
 		/* the shmem MAP_PRIVATE case requires checking the i_size */
-- 
2.20.1


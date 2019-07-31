Return-Path: <SRS0=2Grs=V4=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.8 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 5929AC433FF
	for <linux-mm@archiver.kernel.org>; Wed, 31 Jul 2019 15:08:20 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 0B5E7208E3
	for <linux-mm@archiver.kernel.org>; Wed, 31 Jul 2019 15:08:19 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=shutemov-name.20150623.gappssmtp.com header.i=@shutemov-name.20150623.gappssmtp.com header.b="R36gYrhW"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 0B5E7208E3
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=shutemov.name
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 9B3158E0005; Wed, 31 Jul 2019 11:08:19 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 93C6F8E0001; Wed, 31 Jul 2019 11:08:19 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 805828E0005; Wed, 31 Jul 2019 11:08:19 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f70.google.com (mail-ed1-f70.google.com [209.85.208.70])
	by kanga.kvack.org (Postfix) with ESMTP id 315EA8E0001
	for <linux-mm@kvack.org>; Wed, 31 Jul 2019 11:08:19 -0400 (EDT)
Received: by mail-ed1-f70.google.com with SMTP id l26so42618337eda.2
        for <linux-mm@kvack.org>; Wed, 31 Jul 2019 08:08:19 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=wLPXwl8hvJobXFCl++g4aCvf+npUzZ0QqPbdONmdAQc=;
        b=CmKiSOOS5hyKqbkgqzco6ibq3zbxnN9IL66loXFi/aF6iLTL+Z3TUozgGmvDFKQX4c
         BBxjP6gh6SaRZWvVkgequqFP4eI8j1LHFespIhopmZ49q/8i9bb6Ji8OSNCLlfi0LxhL
         9tWr4610oOf1r0sWsCv8l5wJ+8URvQqZRe1ifzn2aAQw/oqXxM/VwhdFW4F17KcjNwDv
         dX97bIOXzoTzmxaXmDhPQjqd5ZmFKqkToocC9InkaL1zckP99bSUp1pJdH4eH7cAtE2E
         0E/tUtBfPv473n9jywtfUWG1nWlTKuK+qlts2r5n5RTD97LoVKJreqnx5HYFpjADlDfs
         iBGA==
X-Gm-Message-State: APjAAAXDombhfIIxYjtJfha4yH0UxkMemnPotEzD8vWntNqmKIUXfsDc
	9Vew2HaTbvTLN6DnkQTjsTaGZWVJkgUjX6Fgjbj04jFRTUeWkkKAiKPwbzPMvbJQdSSTtgkpYGz
	cZkyuIApvBIXhb5h8WSu2wfQSyBMDeH9DvoffXwL+jK2Q/2VKrKebFHJ2J3xCbas=
X-Received: by 2002:a50:d7d0:: with SMTP id m16mr105325235edj.162.1564585698770;
        Wed, 31 Jul 2019 08:08:18 -0700 (PDT)
X-Received: by 2002:a50:d7d0:: with SMTP id m16mr105325071edj.162.1564585697301;
        Wed, 31 Jul 2019 08:08:17 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1564585697; cv=none;
        d=google.com; s=arc-20160816;
        b=QQjdD8FDnFCLcvQoyJEU54EIlGNkwXHjdNmJS6s222lQtARrPfqdIjM7e9ZUMY1K38
         +8f0v99SkrzEHzOBuPUnYO8eJ34J0HC15daJt9AYWmmv7IPnZSDMyipsdKo439e0IFyh
         dXUHRNg22+gRSIcgpI0dftfXa7/InSlxneEyjbXieUD2mIkSowBtX0hPPL4FmaeeKS5f
         v1I4KBZgbHmr9Ncc9iWe89EoLBD76bw0l4OiOOHjyK4iRODBUbz0IJyECbTx0ub8/L9P
         CVSGWENQ7NkLLS5yxp006R9XsNfdbxxxM/cCacxoZLyon+WVHaVXkrUnIJ/i20RnYTw4
         RgeA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:dkim-signature;
        bh=wLPXwl8hvJobXFCl++g4aCvf+npUzZ0QqPbdONmdAQc=;
        b=R9eBVQ6nA9pVnjnowKnujDCg8Oh/9Vd0Y/C/BmjZIMGoiCqvv7c7jL5D+VlgTfo/+e
         d7gr+J5SmXcA5UeE89atq7opswepw0up52F1gWlI8KZzeV2AMot2ul2LrtoHC2TQHMVB
         +9HWyC0Dyy60VNEVoWtOfrVcQznZTAN1QTjCk+0clBr/eqdULt2Dv981yYf33UKvR/PP
         GDFbaPKDGAUkxbCpS6SC1KacPZIdDRxKyzqzajC6JtxTPaskoQjwAiit2oXxfy1cdZrQ
         2+4x7NGTMA+MQOD6oSHwuOmqiFMOJi2aH7Rdc6wH9Ga+ZXI1Djs5N3e0dAzZbRQJQmpK
         vDCA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@shutemov-name.20150623.gappssmtp.com header.s=20150623 header.b=R36gYrhW;
       spf=neutral (google.com: 209.85.220.65 is neither permitted nor denied by best guess record for domain of kirill@shutemov.name) smtp.mailfrom=kirill@shutemov.name
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id bq17sor22167147ejb.55.2019.07.31.08.08.17
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 31 Jul 2019 08:08:17 -0700 (PDT)
Received-SPF: neutral (google.com: 209.85.220.65 is neither permitted nor denied by best guess record for domain of kirill@shutemov.name) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@shutemov-name.20150623.gappssmtp.com header.s=20150623 header.b=R36gYrhW;
       spf=neutral (google.com: 209.85.220.65 is neither permitted nor denied by best guess record for domain of kirill@shutemov.name) smtp.mailfrom=kirill@shutemov.name
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=shutemov-name.20150623.gappssmtp.com; s=20150623;
        h=from:to:cc:subject:date:message-id:in-reply-to:references
         :mime-version:content-transfer-encoding;
        bh=wLPXwl8hvJobXFCl++g4aCvf+npUzZ0QqPbdONmdAQc=;
        b=R36gYrhWPE65DAN624GOKj6Zcvo/ac/skfKDjJ3xcAQFiNmr7dX573jmLVCRaNG72Z
         xcMGnyIs1LpXnhGK5JxEboIEAPxR/EeGcod/4MYW/A0bbBy9yBKnmU2CF6SqodBq1bbG
         2et49Q8QeC0Gi2N/dOFWHDkpO2qo6+z6lshk3KNGVbQlqNYxKAMnCnpgag0jzwh5HEUj
         dMc4Sem5sBJAfoYBQzfFvzczhmipMrh7ObYbRCqFmv9xdDuVsiGlTB/dwRP9co2iZadV
         LxdeXO4uRP+DUWTuqbPXM46fxWLgXQuCInUrkr1thUYy5i2Mt2bnKrQGqLbEspEV6MTU
         W2og==
X-Google-Smtp-Source: APXvYqw0oWdSxi7D+H/1P5QUyRaVYREdYgbW7LIf4XE4H22UAM6yie49PO/SDUQu/e/ngKqwbq3xkA==
X-Received: by 2002:a17:906:430a:: with SMTP id j10mr10514767ejm.92.1564585696918;
        Wed, 31 Jul 2019 08:08:16 -0700 (PDT)
Received: from box.localdomain ([86.57.175.117])
        by smtp.gmail.com with ESMTPSA id y11sm12444493ejb.54.2019.07.31.08.08.15
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 31 Jul 2019 08:08:15 -0700 (PDT)
From: "Kirill A. Shutemov" <kirill@shutemov.name>
X-Google-Original-From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Received: by box.localdomain (Postfix, from userid 1000)
	id F174F101319; Wed, 31 Jul 2019 18:08:15 +0300 (+03)
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
Subject: [PATCHv2 02/59] mm: Add helpers to setup zero page mappings
Date: Wed, 31 Jul 2019 18:07:16 +0300
Message-Id: <20190731150813.26289-3-kirill.shutemov@linux.intel.com>
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

When kernel sets up an encrypted page mapping, encryption KeyID is
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
index a237141d8787..6ecc9c560e62 100644
--- a/fs/dax.c
+++ b/fs/dax.c
@@ -1445,8 +1445,7 @@ static vm_fault_t dax_pmd_load_hole(struct xa_state *xas, struct vm_fault *vmf,
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
index 75d9d68a6de7..afcfbb4af4b2 100644
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
index 1334ede667a8..e9a791413730 100644
--- a/mm/huge_memory.c
+++ b/mm/huge_memory.c
@@ -678,8 +678,7 @@ static bool set_huge_zero_page(pgtable_t pgtable, struct mm_struct *mm,
 	pmd_t entry;
 	if (!pmd_none(*pmd))
 		return false;
-	entry = mk_pmd(zero_page, vma->vm_page_prot);
-	entry = pmd_mkhuge(entry);
+	entry = mk_zero_pmd(zero_page, vma->vm_page_prot);
 	if (pgtable)
 		pgtable_trans_huge_deposit(mm, pmd, pgtable);
 	set_pmd_at(mm, haddr, pmd, entry);
@@ -2109,8 +2108,7 @@ static void __split_huge_zero_page_pmd(struct vm_area_struct *vma,
 
 	for (i = 0; i < HPAGE_PMD_NR; i++, haddr += PAGE_SIZE) {
 		pte_t *pte, entry;
-		entry = pfn_pte(my_zero_pfn(haddr), vma->vm_page_prot);
-		entry = pte_mkspecial(entry);
+		entry = mk_zero_pte(haddr, vma->vm_page_prot);
 		pte = pte_offset_map(&_pmd, haddr);
 		VM_BUG_ON(!pte_none(*pte));
 		set_pte_at(mm, haddr, pte, entry);
diff --git a/mm/memory.c b/mm/memory.c
index e2bb51b6242e..81ae8c39f75b 100644
--- a/mm/memory.c
+++ b/mm/memory.c
@@ -2970,8 +2970,7 @@ static vm_fault_t do_anonymous_page(struct vm_fault *vmf)
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
index c7ae74ce5ff3..06bf4ea3ee05 100644
--- a/mm/userfaultfd.c
+++ b/mm/userfaultfd.c
@@ -120,8 +120,7 @@ static int mfill_zeropage_pte(struct mm_struct *dst_mm,
 	pgoff_t offset, max_off;
 	struct inode *inode;
 
-	_dst_pte = pte_mkspecial(pfn_pte(my_zero_pfn(dst_addr),
-					 dst_vma->vm_page_prot));
+	_dst_pte = mk_zero_pte(dst_addr, dst_vma->vm_page_prot);
 	dst_pte = pte_offset_map_lock(dst_mm, dst_pmd, dst_addr, &ptl);
 	if (dst_vma->vm_file) {
 		/* the shmem MAP_PRIVATE case requires checking the i_size */
-- 
2.21.0


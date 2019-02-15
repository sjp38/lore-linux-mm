Return-Path: <SRS0=VMr4=QW=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.9 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_PASS,USER_AGENT_GIT autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 1203FC4360F
	for <linux-mm@archiver.kernel.org>; Fri, 15 Feb 2019 22:09:53 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id B1D86222D9
	for <linux-mm@archiver.kernel.org>; Fri, 15 Feb 2019 22:09:52 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=sent.com header.i=@sent.com header.b="AYblONMb";
	dkim=pass (2048-bit key) header.d=messagingengine.com header.i=@messagingengine.com header.b="AqcjlNuy"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org B1D86222D9
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=sent.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id A22BA8E0011; Fri, 15 Feb 2019 17:09:24 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 9A4498E0009; Fri, 15 Feb 2019 17:09:24 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 81DF78E0011; Fri, 15 Feb 2019 17:09:24 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f199.google.com (mail-qk1-f199.google.com [209.85.222.199])
	by kanga.kvack.org (Postfix) with ESMTP id 694B28E0009
	for <linux-mm@kvack.org>; Fri, 15 Feb 2019 17:09:24 -0500 (EST)
Received: by mail-qk1-f199.google.com with SMTP id a11so9325286qkk.10
        for <linux-mm@kvack.org>; Fri, 15 Feb 2019 14:09:24 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:dkim-signature:from:to:cc:subject
         :date:message-id:in-reply-to:references:reply-to:mime-version
         :content-transfer-encoding;
        bh=TKkr6F+pcQWOHjR1WyLSliHQNu6t5AXNp24XvGYdLBs=;
        b=rlNQwv0f0Ah2N+RvecJfquB1BqBN+cg1PlJG/8Y5/ZTtCTC3FbNQ6PUoGOjqAgQiFG
         N41gyUduItEm3T5Zt9YBwt4etwYcptiQKhunqxFJqPYgF7fE0I2ZdmLMtR7TMlJJvpvG
         cDz6AE1hdpczIe5o2p7GfFdVLIv1O5U1DfSuhs8/vOTJp6hrF0DK76Gh/cbeeQvPtXtC
         mswj0BmNz8933Cl2d1+FAZV7uhQitA9akPmHYVvxV6V5lJgLOPj94FPhVk3JAfjKR76f
         IgqJp2sGxgrtxkiyzO+uAGGKRUrGT1eEpR7vBIf2KXQAT8V4gaG6qHOQNQewdto1Phqc
         Yd8A==
X-Gm-Message-State: AHQUAuZBkB3d/D0knAvQFDOJyje13QLjO1nm8gsoulQcGGbVHTgra619
	eCU5C/V/Aug4nHJu9vjX3YkNM3q6rQSTKRVTYED3goTUYmoKIR5/9EQnuJqoduq5UMFNS0r+GnJ
	QefQuP1Wu2mVLcuKhaVqUx8xKmC1bPTtxxzAm3JJ3f6EAPbRo4MvzHwkB7swHgvqxUg==
X-Received: by 2002:a0c:b515:: with SMTP id d21mr9090146qve.31.1550268564171;
        Fri, 15 Feb 2019 14:09:24 -0800 (PST)
X-Google-Smtp-Source: AHgI3IZzxLnjVjZZzZv2fFK0D8hEiHlyRC6Bw99llGbWuxayQvrXIlUTmwN1O6FAaUZ66L6Xyk5Q
X-Received: by 2002:a0c:b515:: with SMTP id d21mr9090117qve.31.1550268563477;
        Fri, 15 Feb 2019 14:09:23 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1550268563; cv=none;
        d=google.com; s=arc-20160816;
        b=caha3Z27Nk11r/O/EuVaZMi4/ElT4Z4DcUOC50QO7blVmcBABfT1xVRYDc/16CQmHn
         7dwVCA/ctDO1MsAqq8cuskiEf6n5dDO1hCfvxPJmNJJC8DGSw6rFQNeEmE7Syqb/0Jlo
         o9byIqKSRGIEj8xwQlG+Mce+Mz+mI7FmV3jKj/x/za3Oihqqaa56D8aHxiXMY+X/+ZO3
         fm0YtL/SDRtXwF/S/UGLBXjtRjlPgBbmlXVyFeVUsjN8/s9gbwnunsT/84q22Atutj77
         2wGiKDelHhtKVmJ/cuTFlwlbAUCinAAJByWRglu8LxYecUZJN5BGvje8Gu37bJx21u1T
         35Hg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:reply-to:references
         :in-reply-to:message-id:date:subject:cc:to:from:dkim-signature
         :dkim-signature;
        bh=TKkr6F+pcQWOHjR1WyLSliHQNu6t5AXNp24XvGYdLBs=;
        b=U6j7YM8GVxt3OXz+lM5yvrwAXT0YGdHXjEYAnb8o76bBonQhg3KcNpd+jkAJMn8+O/
         cjJPZfDNvoYgGApfdr9CP9gOE7O5btg89x7TBj2NCTP6ODP/56v+9EUYfNUJV2UGdieM
         XzZNxoEQCHJM19vrWMR1cjR9PGDhFM1Okj5PHg/soGJTyfmuliB20GrUuwVNHqC55zfE
         KBim/0m0DLSVfCNxmbrnoLd54Tf3Dd5QM66xkRo1Qm7GfLbcrDmsFJHz+ESEy7uMWdqj
         gn9eqximogm0/LXyFLSx9sx//dM9CQlAfMIOlsTvGE50vhG8NmJ0osbf6zPxtgZHd0sF
         U4Aw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@sent.com header.s=fm2 header.b=AYblONMb;
       dkim=pass header.i=@messagingengine.com header.s=fm2 header.b=AqcjlNuy;
       spf=pass (google.com: domain of zi.yan@sent.com designates 64.147.123.25 as permitted sender) smtp.mailfrom=zi.yan@sent.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=sent.com
Received: from wout2-smtp.messagingengine.com (wout2-smtp.messagingengine.com. [64.147.123.25])
        by mx.google.com with ESMTPS id b67si3647254qke.116.2019.02.15.14.09.23
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 15 Feb 2019 14:09:23 -0800 (PST)
Received-SPF: pass (google.com: domain of zi.yan@sent.com designates 64.147.123.25 as permitted sender) client-ip=64.147.123.25;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@sent.com header.s=fm2 header.b=AYblONMb;
       dkim=pass header.i=@messagingengine.com header.s=fm2 header.b=AqcjlNuy;
       spf=pass (google.com: domain of zi.yan@sent.com designates 64.147.123.25 as permitted sender) smtp.mailfrom=zi.yan@sent.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=sent.com
Received: from compute3.internal (compute3.nyi.internal [10.202.2.43])
	by mailout.west.internal (Postfix) with ESMTP id AF61C328F;
	Fri, 15 Feb 2019 17:09:21 -0500 (EST)
Received: from mailfrontend1 ([10.202.2.162])
  by compute3.internal (MEProxy); Fri, 15 Feb 2019 17:09:22 -0500
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=sent.com; h=from
	:to:cc:subject:date:message-id:in-reply-to:references:reply-to
	:mime-version:content-transfer-encoding; s=fm2; bh=TKkr6F+pcQWOH
	jR1WyLSliHQNu6t5AXNp24XvGYdLBs=; b=AYblONMbNmEVoXDrndoP5hiaC7BxH
	if8PValgurwRTWKMwStlOQlHgFz12nYs8gjBmaxY4KEM7asJGnAvXpD24jL0OfCl
	sVMk0tjTf/wEJ5wOkTRVVIVVL65o1nYeV3IW57dEYTpi3W/6Ngp019RFTukKaVCO
	wUTsRKrojwvQl7HzZq+P3Yd7pDn+WVgRlugOEgYVlzYzSLSwPN1P3tWEVgFhi27V
	hkbCZ0SbB+tbcuu3Oau0ThbO+FeNjEwkcEDeGh+CE3lHVhoD+HTTMJ66GWhg4nib
	w2qApPqUhsTNf2WZReocjnMKGlGvoHn/FZPNCsaj4PYA/NxIe/3eSobPg==
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=
	messagingengine.com; h=cc:content-transfer-encoding:date:from
	:in-reply-to:message-id:mime-version:references:reply-to:subject
	:to:x-me-proxy:x-me-proxy:x-me-sender:x-me-sender:x-sasl-enc; s=
	fm2; bh=TKkr6F+pcQWOHjR1WyLSliHQNu6t5AXNp24XvGYdLBs=; b=AqcjlNuy
	xcXQy0AfD6UJGUFVV2Qode5Ko3w0XsnPltynvlKlr+tV60C4P33rkCP0ttnaCk2A
	mErF0rSZXutipuZMwcuIavwzayInHGuFlY3wrzeJuIhfXABlUeZhlvoudnsuR8i6
	5bwvOStiD21N9oe8SCrn4bCPCL5EGoIRaxvINy/5EO25rpLo2vN4/QsVoiCXKJQQ
	8erINEI7KWACOjsIrLXoSLIlP6YRoUqmmP0aZwCdy5YpqBSV2KziZwT8ShhSpl1v
	7ft2c/SNmHjpkSf0xfjOP3bqXUHjWKco/rcIt1pFA0AU2ll6BItBz+UXA45ZLc46
	29JD3OXLsrLEBg==
X-ME-Sender: <xms:kThnXK-5A1JrnVKXO6sNFjThTopVp-2DhMxnE-HBpkoRGAS3QSS2_Q>
X-ME-Proxy-Cause: gggruggvucftvghtrhhoucdtuddrgedtledruddtjedgudehkecutefuodetggdotefrod
    ftvfcurfhrohhfihhlvgemucfhrghsthforghilhdpqfhuthenuceurghilhhouhhtmecu
    fedttdenucesvcftvggtihhpihgvnhhtshculddquddttddmnecujfgurhephffvufffkf
    fojghfrhgggfestdekredtredttdenucfhrhhomhepkghiucgjrghnuceoiihirdihrghn
    sehsvghnthdrtghomheqnecukfhppedvudeirddvvdekrdduuddvrddvvdenucfrrghrrg
    hmpehmrghilhhfrhhomhepiihirdihrghnsehsvghnthdrtghomhenucevlhhushhtvghr
    ufhiiigvpedufe
X-ME-Proxy: <xmx:kThnXFzwsZmcSJRn19uf1flDo0v1F26l-WKVgGNzKU9kWQ9um00-xQ>
    <xmx:kThnXIGOCoVkzPauthtn_YdeKr45iq8cnYaSII_uCjQUKWjiWVGSvg>
    <xmx:kThnXEvM2gpt0WlnqyB69wAenVhltEpDeWmlKEFOcnbCoXvzZD_nqw>
    <xmx:kThnXDWr71QphxZ_Z7m8VeM_SrqHTpXjsF0eJnAhOkavk1U2NEhsGQ>
Received: from nvrsysarch5.nvidia.com (thunderhill.nvidia.com [216.228.112.22])
	by mail.messagingengine.com (Postfix) with ESMTPA id AD1A9E46AE;
	Fri, 15 Feb 2019 17:09:19 -0500 (EST)
From: Zi Yan <zi.yan@sent.com>
To: linux-mm@kvack.org,
	linux-kernel@vger.kernel.org
Cc: Dave Hansen <dave.hansen@linux.intel.com>,
	Michal Hocko <mhocko@kernel.org>,
	"Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	Vlastimil Babka <vbabka@suse.cz>,
	Mel Gorman <mgorman@techsingularity.net>,
	John Hubbard <jhubbard@nvidia.com>,
	Mark Hairgrove <mhairgrove@nvidia.com>,
	Nitin Gupta <nigupta@nvidia.com>,
	David Nellans <dnellans@nvidia.com>,
	Zi Yan <ziy@nvidia.com>
Subject: [RFC PATCH 14/31] mm: thp: handling 1GB THP reference bit.
Date: Fri, 15 Feb 2019 14:08:39 -0800
Message-Id: <20190215220856.29749-15-zi.yan@sent.com>
X-Mailer: git-send-email 2.20.1
In-Reply-To: <20190215220856.29749-1-zi.yan@sent.com>
References: <20190215220856.29749-1-zi.yan@sent.com>
Reply-To: ziy@nvidia.com
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

From: Zi Yan <ziy@nvidia.com>

Add PUD-level TLB flush ops and teach page_vma_mapped_talk about 1GB
THPs.

Signed-off-by: Zi Yan <ziy@nvidia.com>
---
 arch/x86/include/asm/pgtable.h |  3 +++
 arch/x86/mm/pgtable.c          | 13 +++++++++++++
 include/asm-generic/pgtable.h  | 14 ++++++++++++++
 include/linux/mmu_notifier.h   | 13 +++++++++++++
 include/linux/rmap.h           |  1 +
 mm/page_vma_mapped.c           | 33 +++++++++++++++++++++++++++++----
 mm/rmap.c                      | 12 +++++++++---
 7 files changed, 82 insertions(+), 7 deletions(-)

diff --git a/arch/x86/include/asm/pgtable.h b/arch/x86/include/asm/pgtable.h
index ae3ac49c32ad..f99ce657d282 100644
--- a/arch/x86/include/asm/pgtable.h
+++ b/arch/x86/include/asm/pgtable.h
@@ -1151,6 +1151,9 @@ extern int pudp_test_and_clear_young(struct vm_area_struct *vma,
 extern int pmdp_clear_flush_young(struct vm_area_struct *vma,
 				  unsigned long address, pmd_t *pmdp);
 
+#define __HAVE_ARCH_PUDP_CLEAR_YOUNG_FLUSH
+extern int pudp_clear_flush_young(struct vm_area_struct *vma,
+				  unsigned long address, pud_t *pudp);
 
 #define pmd_write pmd_write
 static inline int pmd_write(pmd_t pmd)
diff --git a/arch/x86/mm/pgtable.c b/arch/x86/mm/pgtable.c
index 0a5008690d7c..0edcfa8007cb 100644
--- a/arch/x86/mm/pgtable.c
+++ b/arch/x86/mm/pgtable.c
@@ -643,6 +643,19 @@ int pmdp_clear_flush_young(struct vm_area_struct *vma,
 
 	return young;
 }
+int pudp_clear_flush_young(struct vm_area_struct *vma,
+			   unsigned long address, pud_t *pudp)
+{
+	int young;
+
+	VM_BUG_ON(address & ~HPAGE_PUD_MASK);
+
+	young = pudp_test_and_clear_young(vma, address, pudp);
+	if (young)
+		flush_tlb_range(vma, address, address + HPAGE_PUD_SIZE);
+
+	return young;
+}
 #endif
 
 /**
diff --git a/include/asm-generic/pgtable.h b/include/asm-generic/pgtable.h
index 0f626d6177c3..682531e0d55c 100644
--- a/include/asm-generic/pgtable.h
+++ b/include/asm-generic/pgtable.h
@@ -121,6 +121,20 @@ static inline int pmdp_clear_flush_young(struct vm_area_struct *vma,
 #endif /* CONFIG_TRANSPARENT_HUGEPAGE */
 #endif
 
+#ifndef __HAVE_ARCH_PUDP_CLEAR_YOUNG_FLUSH
+#ifdef CONFIG_HAVE_ARCH_TRANSPARENT_HUGEPAGE_PUD
+extern int pudp_clear_flush_young(struct vm_area_struct *vma,
+				  unsigned long address, pud_t *pudp);
+#else
+int pudp_clear_flush_young(struct vm_area_struct *vma,
+				  unsigned long address, pud_t *pudp)
+{
+	BUILD_BUG();
+	return 0;
+}
+#endif /* CONFIG_HAVE_ARCH_TRANSPARENT_HUGEPAGE_PUD  */
+#endif
+
 #ifndef __HAVE_ARCH_PTEP_GET_AND_CLEAR
 static inline pte_t ptep_get_and_clear(struct mm_struct *mm,
 				       unsigned long address,
diff --git a/include/linux/mmu_notifier.h b/include/linux/mmu_notifier.h
index 4050ec1c3b45..6850b9e9b2cb 100644
--- a/include/linux/mmu_notifier.h
+++ b/include/linux/mmu_notifier.h
@@ -353,6 +353,19 @@ static inline void mmu_notifier_range_init(struct mmu_notifier_range *range,
 	__young;							\
 })
 
+#define pudp_clear_flush_young_notify(__vma, __address, __pudp)		\
+({									\
+	int __young;							\
+	struct vm_area_struct *___vma = __vma;				\
+	unsigned long ___address = __address;				\
+	__young = pudp_clear_flush_young(___vma, ___address, __pudp);	\
+	__young |= mmu_notifier_clear_flush_young(___vma->vm_mm,	\
+						  ___address,		\
+						  ___address +		\
+							PUD_SIZE);	\
+	__young;							\
+})
+
 #define ptep_clear_young_notify(__vma, __address, __ptep)		\
 ({									\
 	int __young;							\
diff --git a/include/linux/rmap.h b/include/linux/rmap.h
index 988d176472df..2b566736e3c2 100644
--- a/include/linux/rmap.h
+++ b/include/linux/rmap.h
@@ -206,6 +206,7 @@ struct page_vma_mapped_walk {
 	struct page *page;
 	struct vm_area_struct *vma;
 	unsigned long address;
+	pud_t *pud;
 	pmd_t *pmd;
 	pte_t *pte;
 	spinlock_t *ptl;
diff --git a/mm/page_vma_mapped.c b/mm/page_vma_mapped.c
index 11df03e71288..a473553aa9a5 100644
--- a/mm/page_vma_mapped.c
+++ b/mm/page_vma_mapped.c
@@ -141,9 +141,12 @@ bool page_vma_mapped_walk(struct page_vma_mapped_walk *pvmw)
 	struct page *page = pvmw->page;
 	pgd_t *pgd;
 	p4d_t *p4d;
-	pud_t *pud;
+	pud_t pude;
 	pmd_t pmde;
 
+	if (!pvmw->pte && !pvmw->pmd && pvmw->pud)
+		return not_found(pvmw);
+
 	/* The only possible pmd mapping has been handled on last iteration */
 	if (pvmw->pmd && !pvmw->pte)
 		return not_found(pvmw);
@@ -171,10 +174,31 @@ bool page_vma_mapped_walk(struct page_vma_mapped_walk *pvmw)
 	p4d = p4d_offset(pgd, pvmw->address);
 	if (!p4d_present(*p4d))
 		return false;
-	pud = pud_offset(p4d, pvmw->address);
-	if (!pud_present(*pud))
+	pvmw->pud = pud_offset(p4d, pvmw->address);
+
+	/*
+	 * Make sure the pud value isn't cached in a register by the
+	 * compiler and used as a stale value after we've observed a
+	 * subsequent update.
+	 */
+	pude = READ_ONCE(*pvmw->pud);
+	if (pud_trans_huge(pude)) {
+		pvmw->ptl = pud_lock(mm, pvmw->pud);
+		if (likely(pud_trans_huge(*pvmw->pud))) {
+			if (pvmw->flags & PVMW_MIGRATION)
+				return not_found(pvmw);
+			if (pud_page(*pvmw->pud) != page)
+				return not_found(pvmw);
+			return true;
+		} else {
+			/* THP pud was split under us: handle on pmd level */
+			spin_unlock(pvmw->ptl);
+			pvmw->ptl = NULL;
+		}
+	} else if (!pud_present(pude))
 		return false;
-	pvmw->pmd = pmd_offset(pud, pvmw->address);
+
+	pvmw->pmd = pmd_offset(pvmw->pud, pvmw->address);
 	/*
 	 * Make sure the pmd value isn't cached in a register by the
 	 * compiler and used as a stale value after we've observed a
@@ -210,6 +234,7 @@ bool page_vma_mapped_walk(struct page_vma_mapped_walk *pvmw)
 	} else if (!pmd_present(pmde)) {
 		return false;
 	}
+
 	if (!map_pte(pvmw))
 		goto next_pte;
 	while (1) {
diff --git a/mm/rmap.c b/mm/rmap.c
index dae66a4329ea..f69d81d4a956 100644
--- a/mm/rmap.c
+++ b/mm/rmap.c
@@ -789,9 +789,15 @@ static bool page_referenced_one(struct page *page, struct vm_area_struct *vma,
 					referenced++;
 			}
 		} else if (IS_ENABLED(CONFIG_TRANSPARENT_HUGEPAGE)) {
-			if (pmdp_clear_flush_young_notify(vma, address,
-						pvmw.pmd))
-				referenced++;
+			if (pvmw.pmd) {
+				if (pmdp_clear_flush_young_notify(vma, address,
+							pvmw.pmd))
+					referenced++;
+			} else if (pvmw.pud) {
+				if (pudp_clear_flush_young_notify(vma, address,
+							pvmw.pud))
+					referenced++;
+			}
 		} else {
 			/* unexpected pmd-mapped page? */
 			WARN_ON_ONCE(1);
-- 
2.20.1


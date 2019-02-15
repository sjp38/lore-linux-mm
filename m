Return-Path: <SRS0=VMr4=QW=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.9 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_PASS,USER_AGENT_GIT autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 53E81C10F06
	for <linux-mm@archiver.kernel.org>; Fri, 15 Feb 2019 22:10:10 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id E8CB2222D0
	for <linux-mm@archiver.kernel.org>; Fri, 15 Feb 2019 22:10:09 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=sent.com header.i=@sent.com header.b="CdOxNozZ";
	dkim=pass (2048-bit key) header.d=messagingengine.com header.i=@messagingengine.com header.b="4LPh6hb6"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org E8CB2222D0
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=sent.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 81DBC8E0016; Fri, 15 Feb 2019 17:09:31 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 7D1128E0014; Fri, 15 Feb 2019 17:09:31 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 6C1DE8E0016; Fri, 15 Feb 2019 17:09:31 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f197.google.com (mail-qk1-f197.google.com [209.85.222.197])
	by kanga.kvack.org (Postfix) with ESMTP id 3CA858E0014
	for <linux-mm@kvack.org>; Fri, 15 Feb 2019 17:09:31 -0500 (EST)
Received: by mail-qk1-f197.google.com with SMTP id a65so9379064qkf.19
        for <linux-mm@kvack.org>; Fri, 15 Feb 2019 14:09:31 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:dkim-signature:from:to:cc:subject
         :date:message-id:in-reply-to:references:reply-to:mime-version
         :content-transfer-encoding;
        bh=A2wlhWDTpb+gR/4BLLRTuLLz9Rcq9oerJDarTKQq2Lo=;
        b=XoHsE2H0+gaILOKdx4l7TJywzWzD0mP6uLXpLqZi660wOJe40kb1C07jzfrAR19rgM
         B7ebfDeQ4LYgIzO1PsK0coup586dosPeBKaBrg9Nde/cjc9+ZYcDf3MGg6v+Y56XEq2q
         BhCxmRcVc8J4lKCC2JLLhxfLT5BNL7euD9C8Achemeb+Dcsn+IFe3OmiJy9MKKwb3owp
         qJrn0IWHgQ6Q+bk416iZ7befHL6xn5D/X70veX3AX33iQlT/ZNKXFd2J780AX69wiCKY
         vhW/MvbveX0aUHKhWVGzVVkasRTPhEYlMLW2JqLbHFqcG9vISoUSpTHZnR09nc8eNMIF
         6L4g==
X-Gm-Message-State: AHQUAuZha1CBLhLUCu1Vafsao8qm0BjSoH/jqhuC1Hl64ZgwKkPHuP9g
	Ga++Kyd8FviaBUDgKTZRVAlH9IeEAx9vMpYnUIwZvCPBDfvTikUok8mP3eOUS/ovSxoRj0S0w99
	+8Sofaukdj9vmnVRQnlH6rMkZj1LMpmDHwI82uPwcgGERRcBb9AZ7dbszcr+Xi4cKHA==
X-Received: by 2002:aed:3964:: with SMTP id l91mr9441962qte.33.1550268571005;
        Fri, 15 Feb 2019 14:09:31 -0800 (PST)
X-Google-Smtp-Source: AHgI3IYE7FMj6Jl4jrEKEZ0QZhzLTxzyYylXYhdFceoAEqNtQQRbH3R8wI1EfDEusO3CGWNITTXM
X-Received: by 2002:aed:3964:: with SMTP id l91mr9441919qte.33.1550268570282;
        Fri, 15 Feb 2019 14:09:30 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1550268570; cv=none;
        d=google.com; s=arc-20160816;
        b=ls0CW3Q5LJfFdm5mK41GFQ9Bs1zIZYeZjN8hNCv6ibY6M/XdZ3CbVESXxpnn1a0g1l
         bN/d1JxbqZyUf/lmrn8K3sDF4yOd1WdTLt8uUGxkuCEzHixKHKAxVAGAo5so54GFGfB5
         nBAZWzLc9i7C7H2lF31M/WSH9sE4VkdM5vxgoR2Cm832E3y8x3A6KtMpFnpyPBIzXp1y
         BmoLZ7S5PM7fghnmEXXEcXPmuKQNdbofBp4k3XcqAIFlwz4Mov+NPktV/trLH4ctIuEn
         J8Y+IVCYHIFEZUTmCopaIBn1IVaRvdp8bQuyT+Iz3IGwROguu8so0c9Vla2toTwxTD3R
         2gWw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:reply-to:references
         :in-reply-to:message-id:date:subject:cc:to:from:dkim-signature
         :dkim-signature;
        bh=A2wlhWDTpb+gR/4BLLRTuLLz9Rcq9oerJDarTKQq2Lo=;
        b=lzB64bBNwMGCXU2ILKXkEdJ4af+LTgIY85ky4P8zQdmK6MihFFJS5/Sjbab6z9ToFD
         oFruq5M3wl3qDUvUyaRpETHgloA3QgzTORNNyPJ/bVGe0GU5u5366cfXvNI9hPzrKmNl
         axFnS2VxDJ/+yBChJR3HzxQmmkNnWbzynOVLvA6zH1aDa+b47H6deb+Lk/1p6Be2FACG
         M1ziycGdpzvbYXZQxnhnQ1t0FVdAp1pJ4tq6DsG5uZth/44L5JnmJrBX+7W6IBgrF8qC
         ISRQVzzr6fWt965arP8znNsz1Y0keCklY9MhaJ+JcOt/qOYcoRE5MP6uQ3clBX3RrPwA
         4fnQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@sent.com header.s=fm2 header.b=CdOxNozZ;
       dkim=pass header.i=@messagingengine.com header.s=fm2 header.b=4LPh6hb6;
       spf=pass (google.com: domain of zi.yan@sent.com designates 64.147.123.25 as permitted sender) smtp.mailfrom=zi.yan@sent.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=sent.com
Received: from wout2-smtp.messagingengine.com (wout2-smtp.messagingengine.com. [64.147.123.25])
        by mx.google.com with ESMTPS id m96si484268qte.185.2019.02.15.14.09.30
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 15 Feb 2019 14:09:30 -0800 (PST)
Received-SPF: pass (google.com: domain of zi.yan@sent.com designates 64.147.123.25 as permitted sender) client-ip=64.147.123.25;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@sent.com header.s=fm2 header.b=CdOxNozZ;
       dkim=pass header.i=@messagingengine.com header.s=fm2 header.b=4LPh6hb6;
       spf=pass (google.com: domain of zi.yan@sent.com designates 64.147.123.25 as permitted sender) smtp.mailfrom=zi.yan@sent.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=sent.com
Received: from compute3.internal (compute3.nyi.internal [10.202.2.43])
	by mailout.west.internal (Postfix) with ESMTP id 786CBDC6;
	Fri, 15 Feb 2019 17:09:28 -0500 (EST)
Received: from mailfrontend1 ([10.202.2.162])
  by compute3.internal (MEProxy); Fri, 15 Feb 2019 17:09:29 -0500
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=sent.com; h=from
	:to:cc:subject:date:message-id:in-reply-to:references:reply-to
	:mime-version:content-transfer-encoding; s=fm2; bh=A2wlhWDTpb+gR
	/4BLLRTuLLz9Rcq9oerJDarTKQq2Lo=; b=CdOxNozZGNlFNkj+2EJXTHf/tO5oG
	CASqtGZhC4bOmawHzNTZVXwf2tSGpauaptrZKrnLC89Atk//w1E3YDuhfff5g6Pj
	irjr7byySDvaEc7fjZqj3ZxqAQhdBqwZbveystsraWZbdOOZT2mHze6r9uuDearm
	ASz3bT5Mx+nGiBh2cWRSgWWTcsSSgbJRdp0UPLf7shQAnJ7B9Xx62N3G/KuJU/Bg
	MtSBefB/XkkvTrJz11Uv9YAeLa6TkMyYKVC0Kt66kDXbvN9ITabVdVTGT4i/T+aa
	sJvnGwzg3AzDRAKYUtZqPb0mj9VdAjNpXUYM/uUuQ9pAP88/Xzdy+IokQ==
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=
	messagingengine.com; h=cc:content-transfer-encoding:date:from
	:in-reply-to:message-id:mime-version:references:reply-to:subject
	:to:x-me-proxy:x-me-proxy:x-me-sender:x-me-sender:x-sasl-enc; s=
	fm2; bh=A2wlhWDTpb+gR/4BLLRTuLLz9Rcq9oerJDarTKQq2Lo=; b=4LPh6hb6
	ugawOwv39w9Rk8ETYkQrzYu8WKuoxYvkcfeF77Ld/907CcQXYwI3aHMwvNz7NckF
	fbb0ISZdAb19hsgT/rC8XVOOz9cUs6KvN58D3SzTkS0fZlJDly3UPpvUYdBlWShp
	9HxDcRo6KtFQdKG5XRTrkCViZpdrQ5ahhP0VsxpAZtDMFPJ/j2xNK6paOdMagMiG
	qDbxvivXBXwHm4z+ihEHhBdll3zhhsxMgWS3DREluy9d88sjN6OwixR7fKGtkImI
	5KtKv/FdFSeBq6QblB0Ijux0VwrSlyIXVLp7MPcqvhYZ6T/0/7VHt8NOKXrPa2hG
	bRC16dKRLEzaxw==
X-ME-Sender: <xms:lzhnXDUTXp0wUKlCMroYqvBvwyyKA19B82Cgc0DWiGUtptBIooYUag>
X-ME-Proxy-Cause: gggruggvucftvghtrhhoucdtuddrgedtledruddtjedgudehkecutefuodetggdotefrod
    ftvfcurfhrohhfihhlvgemucfhrghsthforghilhdpqfhuthenuceurghilhhouhhtmecu
    fedttdenucesvcftvggtihhpihgvnhhtshculddquddttddmnecujfgurhephffvufffkf
    fojghfrhgggfestdekredtredttdenucfhrhhomhepkghiucgjrghnuceoiihirdihrghn
    sehsvghnthdrtghomheqnecukfhppedvudeirddvvdekrdduuddvrddvvdenucfrrghrrg
    hmpehmrghilhhfrhhomhepiihirdihrghnsehsvghnthdrtghomhenucevlhhushhtvghr
    ufhiiigvpeduke
X-ME-Proxy: <xmx:lzhnXHZr8t2f1L6vOmbwgBnVttWlAmz2RxNdGSltsuedkVBz9C6gEA>
    <xmx:lzhnXF3p8swRnfCQ_Zqewhk7zqNxClHra2avaOfS0fYNfamZhgsR3Q>
    <xmx:lzhnXLDv_dx84mDZa6xrfQSU6wLL_83MUlydF-7ZDngW5Z259xRzsQ>
    <xmx:mDhnXOUvj-6UHb6q4HsiMLQWAUDSlqMU2xASOk8u3e2vEz5TQaJKRQ>
Received: from nvrsysarch5.nvidia.com (thunderhill.nvidia.com [216.228.112.22])
	by mail.messagingengine.com (Postfix) with ESMTPA id 7F8C4E4680;
	Fri, 15 Feb 2019 17:09:26 -0500 (EST)
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
Subject: [RFC PATCH 19/31] mm: thp: 1GB THP support in try_to_unmap().
Date: Fri, 15 Feb 2019 14:08:44 -0800
Message-Id: <20190215220856.29749-20-zi.yan@sent.com>
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

Unmap different subpages in different sized THPs properly in the
try_to_unmap() function.

Signed-off-by: Zi Yan <ziy@nvidia.com>
---
 mm/migrate.c |   2 +-
 mm/rmap.c    | 140 +++++++++++++++++++++++++++++++++++++--------------
 2 files changed, 103 insertions(+), 39 deletions(-)

diff --git a/mm/migrate.c b/mm/migrate.c
index f7e5d88210ee..7deb64d75adb 100644
--- a/mm/migrate.c
+++ b/mm/migrate.c
@@ -223,7 +223,7 @@ static bool remove_migration_pte(struct page *page, struct vm_area_struct *vma,
 
 #ifdef CONFIG_ARCH_ENABLE_THP_MIGRATION
 		/* PMD-mapped THP migration entry */
-		if (!pvmw.pte) {
+		if (!pvmw.pte && pvmw.pmd) {
 			VM_BUG_ON_PAGE(PageHuge(page) || !PageTransCompound(page), page);
 			remove_migration_pmd(&pvmw, new);
 			continue;
diff --git a/mm/rmap.c b/mm/rmap.c
index 79908cfc518a..39f446a6775d 100644
--- a/mm/rmap.c
+++ b/mm/rmap.c
@@ -1031,7 +1031,7 @@ void page_move_anon_rmap(struct page *page, struct vm_area_struct *vma)
  * __page_set_anon_rmap - set up new anonymous rmap
  * @page:	Page or Hugepage to add to rmap
  * @vma:	VM area to add page to.
- * @address:	User virtual address of the mapping	
+ * @address:	User virtual address of the mapping
  * @exclusive:	the page is exclusively owned by the current process
  */
 static void __page_set_anon_rmap(struct page *page,
@@ -1423,7 +1423,9 @@ static bool try_to_unmap_one(struct page *page, struct vm_area_struct *vma,
 		.address = address,
 	};
 	pte_t pteval;
-	struct page *subpage;
+	pmd_t pmdval;
+	pud_t pudval;
+	struct page *subpage = NULL;
 	bool ret = true;
 	struct mmu_notifier_range range;
 	enum ttu_flags flags = (enum ttu_flags)arg;
@@ -1436,6 +1438,11 @@ static bool try_to_unmap_one(struct page *page, struct vm_area_struct *vma,
 	    is_zone_device_page(page) && !is_device_private_page(page))
 		return true;
 
+	if (flags & TTU_SPLIT_HUGE_PUD) {
+		split_huge_pud_address(vma, address,
+				flags & TTU_SPLIT_FREEZE, page);
+	}
+
 	if (flags & TTU_SPLIT_HUGE_PMD) {
 		split_huge_pmd_address(vma, address,
 				flags & TTU_SPLIT_FREEZE, page);
@@ -1465,7 +1472,7 @@ static bool try_to_unmap_one(struct page *page, struct vm_area_struct *vma,
 	while (page_vma_mapped_walk(&pvmw)) {
 #ifdef CONFIG_ARCH_ENABLE_THP_MIGRATION
 		/* PMD-mapped THP migration entry */
-		if (!pvmw.pte && (flags & TTU_MIGRATION)) {
+		if (!pvmw.pte && pvmw.pmd && (flags & TTU_MIGRATION)) {
 			VM_BUG_ON_PAGE(PageHuge(page) || !PageTransCompound(page), page);
 
 			set_pmd_migration_entry(&pvmw, page);
@@ -1497,9 +1504,14 @@ static bool try_to_unmap_one(struct page *page, struct vm_area_struct *vma,
 		}
 
 		/* Unexpected PMD-mapped THP? */
-		VM_BUG_ON_PAGE(!pvmw.pte, page);
 
-		subpage = page - page_to_pfn(page) + pte_pfn(*pvmw.pte);
+		if (pvmw.pte)
+			subpage = page - page_to_pfn(page) + pte_pfn(*pvmw.pte);
+		else if (!pvmw.pte && pvmw.pmd)
+			subpage = page - page_to_pfn(page) + pmd_pfn(*pvmw.pmd);
+		else if (!pvmw.pte && !pvmw.pmd && pvmw.pud)
+			subpage = page - page_to_pfn(page) + pud_pfn(*pvmw.pud);
+		VM_BUG_ON(!subpage);
 		address = pvmw.address;
 
 		if (PageHuge(page)) {
@@ -1556,16 +1568,26 @@ static bool try_to_unmap_one(struct page *page, struct vm_area_struct *vma,
 		}
 
 		if (!(flags & TTU_IGNORE_ACCESS)) {
-			if (ptep_clear_flush_young_notify(vma, address,
-						pvmw.pte)) {
-				ret = false;
-				page_vma_mapped_walk_done(&pvmw);
-				break;
+			if ((pvmw.pte &&
+				 ptep_clear_flush_young_notify(vma, address, pvmw.pte)) ||
+				((!pvmw.pte && pvmw.pmd) &&
+				 pmdp_clear_flush_young_notify(vma, address, pvmw.pmd)) ||
+				((!pvmw.pte && !pvmw.pmd && pvmw.pud) &&
+				 pudp_clear_flush_young_notify(vma, address, pvmw.pud))
+				) {
+					ret = false;
+					page_vma_mapped_walk_done(&pvmw);
+					break;
 			}
 		}
 
 		/* Nuke the page table entry. */
-		flush_cache_page(vma, address, pte_pfn(*pvmw.pte));
+		if (pvmw.pte)
+			flush_cache_page(vma, address, pte_pfn(*pvmw.pte));
+		else if (!pvmw.pte && pvmw.pmd)
+			flush_cache_page(vma, address, pmd_pfn(*pvmw.pmd));
+		else if (!pvmw.pte && !pvmw.pmd && pvmw.pud)
+			flush_cache_page(vma, address, pud_pfn(*pvmw.pud));
 		if (should_defer_flush(mm, flags)) {
 			/*
 			 * We clear the PTE but do not flush so potentially
@@ -1575,16 +1597,34 @@ static bool try_to_unmap_one(struct page *page, struct vm_area_struct *vma,
 			 * transition on a cached TLB entry is written through
 			 * and traps if the PTE is unmapped.
 			 */
-			pteval = ptep_get_and_clear(mm, address, pvmw.pte);
+			if (pvmw.pte) {
+				pteval = ptep_get_and_clear(mm, address, pvmw.pte);
+
+				set_tlb_ubc_flush_pending(mm, pte_dirty(pteval));
+			} else if (!pvmw.pte && pvmw.pmd) {
+				pmdval = pmdp_huge_get_and_clear(mm, address, pvmw.pmd);
 
-			set_tlb_ubc_flush_pending(mm, pte_dirty(pteval));
+				set_tlb_ubc_flush_pending(mm, pmd_dirty(pmdval));
+			} else if (!pvmw.pte && !pvmw.pmd && pvmw.pud) {
+				pudval = pudp_huge_get_and_clear(mm, address, pvmw.pud);
+
+				set_tlb_ubc_flush_pending(mm, pud_dirty(pudval));
+			}
 		} else {
-			pteval = ptep_clear_flush(vma, address, pvmw.pte);
+			if (pvmw.pte)
+				pteval = ptep_clear_flush(vma, address, pvmw.pte);
+			else if (!pvmw.pte && pvmw.pmd)
+				pmdval = pmdp_huge_clear_flush(vma, address, pvmw.pmd);
+			else if (!pvmw.pte && !pvmw.pmd && pvmw.pud)
+				pudval = pudp_huge_clear_flush(vma, address, pvmw.pud);
 		}
 
 		/* Move the dirty bit to the page. Now the pte is gone. */
-		if (pte_dirty(pteval))
-			set_page_dirty(page);
+			if ((pvmw.pte && pte_dirty(pteval)) ||
+				((!pvmw.pte && pvmw.pmd) && pmd_dirty(pmdval)) ||
+				((!pvmw.pte && !pvmw.pmd && pvmw.pud) && pud_dirty(pudval))
+				)
+				set_page_dirty(page);
 
 		/* Update high watermark before we lower rss */
 		update_hiwater_rss(mm);
@@ -1620,33 +1660,57 @@ static bool try_to_unmap_one(struct page *page, struct vm_area_struct *vma,
 		} else if (IS_ENABLED(CONFIG_MIGRATION) &&
 				(flags & (TTU_MIGRATION|TTU_SPLIT_FREEZE))) {
 			swp_entry_t entry;
-			pte_t swp_pte;
 
-			if (arch_unmap_one(mm, vma, address, pteval) < 0) {
-				set_pte_at(mm, address, pvmw.pte, pteval);
-				ret = false;
-				page_vma_mapped_walk_done(&pvmw);
-				break;
-			}
+			if (pvmw.pte) {
+				pte_t swp_pte;
 
-			/*
-			 * Store the pfn of the page in a special migration
-			 * pte. do_swap_page() will wait until the migration
-			 * pte is removed and then restart fault handling.
-			 */
-			entry = make_migration_entry(subpage,
-					pte_write(pteval));
-			swp_pte = swp_entry_to_pte(entry);
-			if (pte_soft_dirty(pteval))
-				swp_pte = pte_swp_mksoft_dirty(swp_pte);
-			set_pte_at(mm, address, pvmw.pte, swp_pte);
-			/*
-			 * No need to invalidate here it will synchronize on
-			 * against the special swap migration pte.
-			 */
+				if (arch_unmap_one(mm, vma, address, pteval) < 0) {
+					set_pte_at(mm, address, pvmw.pte, pteval);
+					ret = false;
+					page_vma_mapped_walk_done(&pvmw);
+					break;
+				}
+
+				/*
+				 * Store the pfn of the page in a special migration
+				 * pte. do_swap_page() will wait until the migration
+				 * pte is removed and then restart fault handling.
+				 */
+				entry = make_migration_entry(subpage,
+						pte_write(pteval));
+				swp_pte = swp_entry_to_pte(entry);
+				if (pte_soft_dirty(pteval))
+					swp_pte = pte_swp_mksoft_dirty(swp_pte);
+				set_pte_at(mm, address, pvmw.pte, swp_pte);
+				/*
+				 * No need to invalidate here it will synchronize on
+				 * against the special swap migration pte.
+				 */
+			} else if (!pvmw.pte && pvmw.pmd) {
+				pmd_t swp_pmd;
+				/*
+				 * Store the pfn of the page in a special migration
+				 * pte. do_swap_page() will wait until the migration
+				 * pte is removed and then restart fault handling.
+				 */
+				entry = make_migration_entry(subpage,
+						pmd_write(pmdval));
+				swp_pmd = swp_entry_to_pmd(entry);
+				if (pmd_soft_dirty(pmdval))
+					swp_pmd = pmd_swp_mksoft_dirty(swp_pmd);
+				set_pmd_at(mm, address, pvmw.pmd, swp_pmd);
+				/*
+				 * No need to invalidate here it will synchronize on
+				 * against the special swap migration pte.
+				 */
+			} else if (!pvmw.pte && !pvmw.pmd && pvmw.pud) {
+				VM_BUG_ON(1);
+			}
 		} else if (PageAnon(page)) {
 			swp_entry_t entry = { .val = page_private(subpage) };
 			pte_t swp_pte;
+
+			VM_BUG_ON(!pvmw.pte);
 			/*
 			 * Store the swap location in the pte.
 			 * See handle_pte_fault() ...
-- 
2.20.1


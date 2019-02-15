Return-Path: <SRS0=VMr4=QW=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.9 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_PASS,USER_AGENT_GIT autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id B9C5EC43381
	for <linux-mm@archiver.kernel.org>; Fri, 15 Feb 2019 22:10:33 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 4C6D6222D0
	for <linux-mm@archiver.kernel.org>; Fri, 15 Feb 2019 22:10:33 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=sent.com header.i=@sent.com header.b="CJ04xWmv";
	dkim=pass (2048-bit key) header.d=messagingengine.com header.i=@messagingengine.com header.b="U9MlAYrI"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 4C6D6222D0
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=sent.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id E14798E001E; Fri, 15 Feb 2019 17:09:42 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id DC40F8E0014; Fri, 15 Feb 2019 17:09:42 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id C65738E001E; Fri, 15 Feb 2019 17:09:42 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f199.google.com (mail-qt1-f199.google.com [209.85.160.199])
	by kanga.kvack.org (Postfix) with ESMTP id 95C938E0014
	for <linux-mm@kvack.org>; Fri, 15 Feb 2019 17:09:42 -0500 (EST)
Received: by mail-qt1-f199.google.com with SMTP id d13so10343821qth.6
        for <linux-mm@kvack.org>; Fri, 15 Feb 2019 14:09:42 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:dkim-signature:from:to:cc:subject
         :date:message-id:in-reply-to:references:reply-to:mime-version
         :content-transfer-encoding;
        bh=Dbtcm1k9n8crLQHYsC2HtO/EHp8WfiZYUCKxILxdM4M=;
        b=QhNcg9W6nnWrJfKdNHiy2eaAqFrMqimZT3uZ2mB3MqKWSCOTevHIKW32eMiK+KOn8d
         /oacMFO4kjwxcyTFwdF2Fejs1XXnRN7gh7EvwqFpfAZ3FRrXz+R2HRaCptCC6aTC5zMl
         du3qbkWlvsbs9MxfzhyghHeB0aS6E5v/2ydHr+kgHMWNz4Ttc7c32JLZgka6pNT2wc1l
         IZ515OOzNAga9NcW9cnId3RnTRw+Ig0hj00XCadOssFeQflN79hZifpeQ0wTbLHcDAvh
         s7RfU5fslCv0TXIuHnVCyib488jlpaS/0qMvi2Q7T25gKBJZuE6+uOlU7Ejdnup+Ykj8
         8q0g==
X-Gm-Message-State: AHQUAuZ+j8XAkeT6i5P+fEVzD0jTGj+IUBIAKevpx3pVLsG9sJErqiJg
	v/Yhm+xABdM8r55tlYkQQ1egYhMk8EbfoRDEkoXzNqRC/S9djn+dMyrZTDYI2LYoEDV16fKhT3y
	DdI0go68cFZYabUGX5S6dZ8YYo9SiIDGFgIccI3QCueh3JPF9Or7z418QKfOXjArINw==
X-Received: by 2002:ac8:393a:: with SMTP id s55mr9478293qtb.70.1550268582318;
        Fri, 15 Feb 2019 14:09:42 -0800 (PST)
X-Google-Smtp-Source: AHgI3IZJLG7Pxq7mA1P+dgbDmuztYdzAGUjy929GLoKTtbQ951a88hVlQ6I3E90hOdMJcSITSiNE
X-Received: by 2002:ac8:393a:: with SMTP id s55mr9478234qtb.70.1550268581173;
        Fri, 15 Feb 2019 14:09:41 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1550268581; cv=none;
        d=google.com; s=arc-20160816;
        b=LEiekC25zTO1KW9281VvyuRl0ZPc6jdlVfW0d7qxa/+qRTG4uz1w4I6ViPb7aP6F49
         C5IWYBff6TZ1CyuhzWXYaE30YUR7+Ck7vjvk/gEQL435QMBxXkRViA+eWzMty8fwVjMW
         RM51LqCNpY452JfQM4L9XLtgiC4zDQMrq+nR6IshJ8CxqUq7M/EVfQKOvWaetNwBN82S
         48qKPrZvGyTXQ3Nj0DzsRzCHHQ0Z/rgA89zdRj2qo7gX3VfmjmVmRYujDFv0XEHBsQqZ
         +18k2znqrHo60pWfeZkdsnbIxU54cwRNr1QmnLIH5S9xl4Txvz7q1jvCsskuZSJbKof7
         +mmg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:reply-to:references
         :in-reply-to:message-id:date:subject:cc:to:from:dkim-signature
         :dkim-signature;
        bh=Dbtcm1k9n8crLQHYsC2HtO/EHp8WfiZYUCKxILxdM4M=;
        b=ORkKEZeNz7iYdoDZmyEl/3MnwqAMSPtSS5u+MfcqXzrhFUVhM0uSrd75ba9jVud2mb
         NV9oiBFixVWF1XKAoRtXEYjHyE8rhG+U87q68n6yDPgZEtSMvYD3K7g1tIBpfh+Ka9P0
         Z25pPhR0VOllRIv9TWA4MVhGbwgc4TdZG5/jt7Dr8sJLEVbjC9Bn/TB4sjxvq1On8RDr
         CQ0XPVcfAPBUIDbnheqClXDlNzqMfIwcazE0syOJbYkuFLjk7efF0psDglaWIluDEOKO
         25YyKOtIMDEP+RQM+OzfuStG5uxWUVK+9ut5QR5NYuGYc4o/doaALYV1w9T7EGwZ1JOE
         aJGQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@sent.com header.s=fm2 header.b=CJ04xWmv;
       dkim=pass header.i=@messagingengine.com header.s=fm2 header.b=U9MlAYrI;
       spf=pass (google.com: domain of zi.yan@sent.com designates 64.147.123.25 as permitted sender) smtp.mailfrom=zi.yan@sent.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=sent.com
Received: from wout2-smtp.messagingengine.com (wout2-smtp.messagingengine.com. [64.147.123.25])
        by mx.google.com with ESMTPS id l7si4249042qtj.301.2019.02.15.14.09.40
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 15 Feb 2019 14:09:41 -0800 (PST)
Received-SPF: pass (google.com: domain of zi.yan@sent.com designates 64.147.123.25 as permitted sender) client-ip=64.147.123.25;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@sent.com header.s=fm2 header.b=CJ04xWmv;
       dkim=pass header.i=@messagingengine.com header.s=fm2 header.b=U9MlAYrI;
       spf=pass (google.com: domain of zi.yan@sent.com designates 64.147.123.25 as permitted sender) smtp.mailfrom=zi.yan@sent.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=sent.com
Received: from compute3.internal (compute3.nyi.internal [10.202.2.43])
	by mailout.west.internal (Postfix) with ESMTP id 5EF6A3016;
	Fri, 15 Feb 2019 17:09:39 -0500 (EST)
Received: from mailfrontend1 ([10.202.2.162])
  by compute3.internal (MEProxy); Fri, 15 Feb 2019 17:09:40 -0500
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=sent.com; h=from
	:to:cc:subject:date:message-id:in-reply-to:references:reply-to
	:mime-version:content-transfer-encoding; s=fm2; bh=Dbtcm1k9n8crL
	QHYsC2HtO/EHp8WfiZYUCKxILxdM4M=; b=CJ04xWmvrOFbXnkPj1UeC+utwQcP7
	xZi1ygG+u8bo3tl/KuwqLulw1G2AzOhRIrUtueMKdxOxBBR8gGPwydXASO6MDdBs
	C/SkCnFokHu3yWQ3QDWYAMzfnN8QLkDnmMvGStnOzvbHbIkRr+r/3/pQwaG7xeMk
	jDwBylyQnaFzu4bF7hwY/mFAbwXZ/rMzwb4Wqky3hee68OOZIqOhCi0q3FnkRVmZ
	sUbsOwzkDXPxD90Fjmyu+asoLEjSebXyMZQDgsu2CyaFqZCLVphUpGNcMZN3qdKK
	JQQYOzq3IEGZTkgTVNzN9OqHoh2tyuh3/G98KWRFKdV8gwIrwC5c6tDcg==
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=
	messagingengine.com; h=cc:content-transfer-encoding:date:from
	:in-reply-to:message-id:mime-version:references:reply-to:subject
	:to:x-me-proxy:x-me-proxy:x-me-sender:x-me-sender:x-sasl-enc; s=
	fm2; bh=Dbtcm1k9n8crLQHYsC2HtO/EHp8WfiZYUCKxILxdM4M=; b=U9MlAYrI
	ZXlyebYBh9CZFgIH+JK5WVIiXbQbJppYgtcTEh9eVHExRXn4bFhUlCdQxmhZoHzQ
	j4hpaTZgvjObIDacpDtkRn9fEfQsiJRtHDMvKvHxvDBX1ExZfRijUyBsBus4mHLG
	CKBAmj70NVVPmbpEkvsxSDHsY5JDKquv0x31L0YUpNjyl7OpPouEAw6p4q0kaLA/
	Txpu2gQuBP3QectkRq3rEp7G9Gke0OQrl+PG8FQJxwrSXd48fWCizC9XC/mP63jP
	cb2L0dKNiePGyPxmkORSRkOdNP3CaGiXy8v37bH7oGPaAqEGu0/s2F0+eiqx1+Fe
	g75sHKi0mUbHVA==
X-ME-Sender: <xms:ojhnXNV9LwahYkn0cgwapPMJ-TUnCV4KHpp0BTLxkVmc_7z-ml6f5w>
X-ME-Proxy-Cause: gggruggvucftvghtrhhoucdtuddrgedtledruddtjedgudehkecutefuodetggdotefrod
    ftvfcurfhrohhfihhlvgemucfhrghsthforghilhdpqfhuthenuceurghilhhouhhtmecu
    fedttdenucesvcftvggtihhpihgvnhhtshculddquddttddmnecujfgurhephffvufffkf
    fojghfrhgggfestdekredtredttdenucfhrhhomhepkghiucgjrghnuceoiihirdihrghn
    sehsvghnthdrtghomheqnecukfhppedvudeirddvvdekrdduuddvrddvvdenucfrrghrrg
    hmpehmrghilhhfrhhomhepiihirdihrghnsehsvghnthdrtghomhenucevlhhushhtvghr
    ufhiiigvpedvvd
X-ME-Proxy: <xmx:ojhnXK_9cKq_22heDk36HAe5-B-HRrObFuCT-j9AQt2cV3E64D7GRg>
    <xmx:ojhnXPBqSV_6NqaNAYXbiVFbFG0WqwInl4-ZeTAfyR5T39nACfaC_A>
    <xmx:ojhnXK4q-Y7Z0LCgC7gHwd0YMIVW6j6AAVy8IPq2zJVWhyeL4s7trA>
    <xmx:ojhnXNSPcfdTZQ9rN2YGGFlOi7QDdDMy5S3oKDtbftUXyTYC8DlOhA>
Received: from nvrsysarch5.nvidia.com (thunderhill.nvidia.com [216.228.112.22])
	by mail.messagingengine.com (Postfix) with ESMTPA id 715DCE462B;
	Fri, 15 Feb 2019 17:09:37 -0500 (EST)
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
Subject: [RFC PATCH 27/31] mm: thp: promote PMD-mapped PUD pages to PUD-mapped PUD pages.
Date: Fri, 15 Feb 2019 14:08:52 -0800
Message-Id: <20190215220856.29749-28-zi.yan@sent.com>
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

First promote 512 PMD-mapped THPs to a PMD-mapped PUD THP, then promote
a PMD-mapped PUD THP to a PUD-mapped PUD THP.

Signed-off-by: Zi Yan <ziy@nvidia.com>
---
 arch/x86/include/asm/pgalloc.h |   2 +
 include/asm-generic/pgtable.h  |  10 +
 mm/huge_memory.c               | 497 ++++++++++++++++++++++++++++++++-
 mm/internal.h                  |   2 +
 mm/pgtable-generic.c           |  20 ++
 mm/rmap.c                      |  23 +-
 6 files changed, 540 insertions(+), 14 deletions(-)

diff --git a/arch/x86/include/asm/pgalloc.h b/arch/x86/include/asm/pgalloc.h
index ebcb022f6bb9..153a6749f92b 100644
--- a/arch/x86/include/asm/pgalloc.h
+++ b/arch/x86/include/asm/pgalloc.h
@@ -119,6 +119,8 @@ static inline void pud_populate_with_pgtable(struct mm_struct *mm, pud_t *pud,
 	set_pud(pud, __pud(((pteval_t)pfn << PAGE_SHIFT) | _PAGE_TABLE));
 }
 
+#define pud_pgtable(pud) pud_page(pud)
+
 #if CONFIG_PGTABLE_LEVELS > 2
 static inline pmd_t *pmd_alloc_one(struct mm_struct *mm, unsigned long addr)
 {
diff --git a/include/asm-generic/pgtable.h b/include/asm-generic/pgtable.h
index 1ae33b6590b8..9984c75d64ce 100644
--- a/include/asm-generic/pgtable.h
+++ b/include/asm-generic/pgtable.h
@@ -302,6 +302,8 @@ static inline void pudp_set_wrprotect(struct mm_struct *mm,
 #ifdef CONFIG_TRANSPARENT_HUGEPAGE
 extern pmd_t pmdp_collapse_flush(struct vm_area_struct *vma,
 				 unsigned long address, pmd_t *pmdp);
+extern pud_t pudp_collapse_flush(struct vm_area_struct *vma,
+				 unsigned long address, pud_t *pudp);
 #else
 static inline pmd_t pmdp_collapse_flush(struct vm_area_struct *vma,
 					unsigned long address,
@@ -310,7 +312,15 @@ static inline pmd_t pmdp_collapse_flush(struct vm_area_struct *vma,
 	BUILD_BUG();
 	return *pmdp;
 }
+static inline pud_t pudp_collapse_flush(struct vm_area_struct *vma,
+					unsigned long address,
+					pud_t *pudp)
+{
+	BUILD_BUG();
+	return *pudp;
+}
 #define pmdp_collapse_flush pmdp_collapse_flush
+#define pudp_collapse_flush pudp_collapse_flush
 #endif /* CONFIG_TRANSPARENT_HUGEPAGE */
 #endif
 
diff --git a/mm/huge_memory.c b/mm/huge_memory.c
index f856f7e39095..67fd1821f4dc 100644
--- a/mm/huge_memory.c
+++ b/mm/huge_memory.c
@@ -2958,7 +2958,7 @@ void split_huge_pud_address(struct vm_area_struct *vma, unsigned long address,
 	__split_huge_pud(vma, pud, address, freeze, page);
 }
 
-static void freeze_pud_page(struct page *page)
+static void unmap_pud_page(struct page *page)
 {
 	enum ttu_flags ttu_flags = TTU_IGNORE_MLOCK | TTU_IGNORE_ACCESS |
 		TTU_RMAP_LOCKED | TTU_SPLIT_HUGE_PUD;
@@ -2973,7 +2973,7 @@ static void freeze_pud_page(struct page *page)
 	VM_BUG_ON_PAGE(!unmap_success, page);
 }
 
-static void unfreeze_pud_page(struct page *page)
+static void remap_pud_page(struct page *page)
 {
 	int i;
 
@@ -3109,7 +3109,7 @@ static void __split_huge_pud_page(struct page *page, struct list_head *list,
 
 	spin_unlock_irqrestore(zone_lru_lock(page_zone(head)), flags);
 
-	unfreeze_pud_page(head);
+	remap_pud_page(head);
 
 	for (i = 0; i < HPAGE_PUD_NR; i += HPAGE_PMD_NR) {
 		struct page *subpage = head + i;
@@ -3210,7 +3210,7 @@ int split_huge_pud_page_to_list(struct page *page, struct list_head *list)
 	}
 
 	/*
-	 * Racy check if we can split the page, before freeze_pud_page() will
+	 * Racy check if we can split the page, before unmap_pud_page() will
 	 * split PUDs
 	 */
 	if (!can_split_huge_pud_page(head, &extra_pins)) {
@@ -3219,7 +3219,7 @@ int split_huge_pud_page_to_list(struct page *page, struct list_head *list)
 	}
 
 	mlocked = PageMlocked(page);
-	freeze_pud_page(head);
+	unmap_pud_page(head);
 	VM_BUG_ON_PAGE(compound_mapcount(head), head);
 
 	/* Make sure the page is not on per-CPU pagevec as it takes pin */
@@ -3285,7 +3285,7 @@ int split_huge_pud_page_to_list(struct page *page, struct list_head *list)
 			xa_unlock(&mapping->i_pages);
 		}
 		spin_unlock_irqrestore(zone_lru_lock(page_zone(head)), flags);
-		unfreeze_pud_page(head);
+		remap_pud_page(head);
 		ret = -EBUSY;
 	}
 
@@ -4703,3 +4703,488 @@ int promote_huge_page_address(struct vm_area_struct *vma, unsigned long haddr)
 
 	return promote_list_to_huge_page(head, &subpage_list);
 }
+
+static pud_t *mm_find_pud(struct mm_struct *mm, unsigned long address)
+{
+	pgd_t *pgd;
+	p4d_t *p4d;
+	pud_t *pud = NULL;
+	pud_t pude;
+
+	pgd = pgd_offset(mm, address);
+	if (!pgd_present(*pgd))
+		goto out;
+
+	p4d = p4d_offset(pgd, address);
+	if (!p4d_present(*p4d))
+		goto out;
+
+	pud = pud_offset(p4d, address);
+
+	pude = *pud;
+	barrier();
+	if (!pud_present(pude) || pud_trans_huge(pude))
+		pud = NULL;
+out:
+	return pud;
+}
+
+/* promote HPAGE_PUD_SIZE range into a PUD map.
+ * mmap_sem needs to be down_write.
+ */
+int promote_huge_pud_address(struct vm_area_struct *vma, unsigned long haddr)
+{
+	struct mm_struct *mm = vma->vm_mm;
+	pud_t *pud, _pud;
+	pmd_t *pmd, *_pmd;
+	spinlock_t *pud_ptl, *pmd_ptl;
+	struct mmu_notifier_range range;
+	pgtable_t pgtable;
+	struct page *page, *head;
+	unsigned long address = haddr;
+	int ret = -EBUSY;
+
+	VM_BUG_ON(haddr & ~HPAGE_PUD_MASK);
+
+	if (haddr < vma->vm_start || (haddr + HPAGE_PUD_SIZE) > vma->vm_end)
+		return -EINVAL;
+
+	pud = mm_find_pud(mm, haddr);
+	if (!pud)
+		goto out;
+
+	anon_vma_lock_write(vma->anon_vma);
+
+	pmd = pmd_offset(pud, haddr);
+	pmd_ptl = pmd_lockptr(mm, pmd);
+
+	head = page = vm_normal_page_pmd(vma, haddr, *pmd);
+	if (!page || !PageTransCompound(page) ||
+		compound_order(page) != HPAGE_PUD_ORDER)
+		goto out_unlock;
+	VM_BUG_ON(head != compound_head(page));
+	lock_page(head);
+
+	mmu_notifier_range_init(&range, mm, haddr, haddr + HPAGE_PUD_SIZE);
+	mmu_notifier_invalidate_range_start(&range);
+	pud_ptl = pud_lock(mm, pud);
+	/*
+	 * After this gup_fast can't run anymore. This also removes
+	 * any huge TLB entry from the CPU so we won't allow
+	 * huge and small TLB entries for the same virtual address
+	 * to avoid the risk of CPU bugs in that area.
+	 */
+
+	_pud = pudp_collapse_flush(vma, haddr, pud);
+	spin_unlock(pud_ptl);
+	mmu_notifier_invalidate_range_end(&range);
+
+	/* remove ptes */
+	for (_pmd = pmd; _pmd < pmd + (1<<(HPAGE_PUD_ORDER-HPAGE_PMD_ORDER));
+				_pmd++, page += HPAGE_PMD_NR, address += HPAGE_PMD_SIZE) {
+		pmd_t pmdval = *_pmd;
+
+		if (pmd_none(pmdval) || is_zero_pfn(pmd_pfn(pmdval))) {
+			if (is_zero_pfn(pmd_pfn(pmdval))) {
+				/*
+				 * ptl mostly unnecessary.
+				 */
+				spin_lock(pmd_ptl);
+				/*
+				 * paravirt calls inside pte_clear here are
+				 * superfluous.
+				 */
+				pmd_clear(_pmd);
+				spin_unlock(pmd_ptl);
+			}
+		} else {
+			/*
+			 * ptl mostly unnecessary, but preempt has to
+			 * be disabled to update the per-cpu stats
+			 * inside page_remove_rmap().
+			 */
+			spin_lock(pmd_ptl);
+			/*
+			 * paravirt calls inside pte_clear here are
+			 * superfluous.
+			 */
+			pmd_clear(_pmd);
+			atomic_dec(sub_compound_mapcount_ptr(page, 1));
+			__dec_node_page_state(page, NR_ANON_THPS);
+			spin_unlock(pmd_ptl);
+		}
+	}
+	page_ref_sub(head, (1<<(HPAGE_PUD_ORDER-HPAGE_PMD_ORDER)) - 1);
+
+	pgtable = pud_pgtable(_pud);
+
+	_pud = mk_huge_pud(head, vma->vm_page_prot);
+	_pud = maybe_pud_mkwrite(pud_mkdirty(_pud), vma);
+
+	/*
+	 * spin_lock() below is not the equivalent of smp_wmb(), so
+	 * this is needed to avoid the copy_huge_page writes to become
+	 * visible after the set_pmd_at() write.
+	 */
+	smp_wmb();
+
+	spin_lock(pud_ptl);
+	BUG_ON(!pud_none(*pud));
+	pgtable_trans_huge_pud_deposit(mm, pud, pgtable);
+	set_pud_at(mm, haddr, pud, _pud);
+	update_mmu_cache_pud(vma, haddr, pud);
+	__inc_node_page_state(head, NR_ANON_THPS_PUD);
+	atomic_inc(compound_mapcount_ptr(head));
+	spin_unlock(pud_ptl);
+	unlock_page(head);
+	ret = 0;
+
+out_unlock:
+	anon_vma_unlock_write(vma->anon_vma);
+out:
+	return ret;
+}
+
+/* Racy check whether the huge page can be split */
+static bool can_promote_huge_pud_page(struct page *page)
+{
+	int extra_pins;
+
+	/* Additional pins from radix tree */
+	if (PageAnon(page))
+		extra_pins = PageSwapCache(page) ? 1 : 0;
+	else
+		return false;
+	if (PageSwapCache(page))
+		return false;
+	if (PageWriteback(page))
+		return false;
+	return total_mapcount(page) == page_count(page) - extra_pins - 1;
+}
+
+
+static void release_pmd_page(struct page *page)
+{
+	mod_node_page_state(page_pgdat(page),
+		NR_ISOLATED_ANON + page_is_file_cache(page),
+		-hpage_nr_pages(page));
+	unlock_page(page);
+	putback_lru_page(page);
+}
+
+void release_pmd_pages(pmd_t *pmd, pmd_t *_pmd)
+{
+	while (--_pmd >= pmd) {
+		pmd_t pmdval = *_pmd;
+
+		if (!pmd_none(pmdval) && !is_zero_pfn(pmd_pfn(pmdval)))
+			release_pmd_page(pmd_page(pmdval));
+	}
+}
+
+/* write a __promote_huge_page_isolate(struct vm_area_struct *vma,
+ * unsigned long address, pte_t *pte) to isolate all subpages into a list,
+ * then call promote_list_to_huge_page() to promote in-place
+ */
+
+static int __promote_huge_pud_page_isolate(struct vm_area_struct *vma,
+					unsigned long haddr, pmd_t *pmd,
+					struct page **head, struct list_head *subpage_list)
+{
+	struct page *page = NULL;
+	pmd_t *_pmd;
+	bool writable = false;
+	unsigned long address = haddr;
+
+	*head = NULL;
+
+	lru_add_drain();
+	for (_pmd = pmd; _pmd < pmd+PTRS_PER_PMD;
+	     _pmd++, address += HPAGE_PMD_SIZE) {
+		pmd_t pmdval = *_pmd;
+
+		if (pmd_none(pmdval) || (pmd_trans_huge(pmdval) &&
+				is_zero_pfn(pmd_pfn(pmdval))))
+			goto out;
+		if (!pmd_present(pmdval))
+			goto out;
+		page = vm_normal_page_pmd(vma, address, pmdval);
+		if (unlikely(!page))
+			goto out;
+
+		if (address == haddr) {
+			*head = page;
+			if (page_to_pfn(page) & ((1<<HPAGE_PUD_ORDER) - 1))
+				goto out;
+		}
+
+		if ((*head + (address - haddr)/PAGE_SIZE) != page)
+			goto out;
+
+		if (!PageCompound(page) || compound_order(page) != HPAGE_PMD_ORDER)
+			goto out;
+
+		if (PageMlocked(page))
+			goto out;
+
+		VM_BUG_ON_PAGE(!PageAnon(page), page);
+
+		/*
+		 * We can do it before isolate_lru_page because the
+		 * page can't be freed from under us. NOTE: PG_lock
+		 * is needed to serialize against split_huge_page
+		 * when invoked from the VM.
+		 */
+		if (!trylock_page(page))
+			goto out;
+
+		/*
+		 * cannot use mapcount: can't collapse if there's a gup pin.
+		 * The page must only be referenced by the scanned process
+		 * and page swap cache.
+		 */
+		if (page_count(page) != page_mapcount(page) + PageSwapCache(page)) {
+			unlock_page(page);
+			goto out;
+		}
+		if (pmd_write(pmdval)) {
+			writable = true;
+		} else {
+			if (PageSwapCache(page) &&
+			    !reuse_swap_page(page, NULL)) {
+				unlock_page(page);
+				goto out;
+			}
+			/*
+			 * Page is not in the swap cache. It can be collapsed
+			 * into a THP.
+			 */
+		}
+
+		/*
+		 * Isolate the page to avoid collapsing an hugepage
+		 * currently in use by the VM.
+		 */
+		if (isolate_lru_page(page)) {
+			unlock_page(page);
+			goto out;
+		}
+
+		mod_node_page_state(page_pgdat(page),
+				NR_ISOLATED_ANON + page_is_file_cache(page),
+				hpage_nr_pages(page));
+		VM_BUG_ON_PAGE(!PageLocked(page), page);
+		VM_BUG_ON_PAGE(PageLRU(page), page);
+	}
+	if (likely(writable)) {
+		int i;
+
+		for (i = 0; i < HPAGE_PUD_NR; i += HPAGE_PMD_NR) {
+			struct page *p = *head + i;
+
+			list_add_tail(&p->lru, subpage_list);
+			VM_BUG_ON_PAGE(!PageLocked(p), p);
+		}
+		return 1;
+	} else {
+		/*result = SCAN_PAGE_RO;*/
+	}
+
+out:
+	release_pmd_pages(pmd, _pmd);
+	return 0;
+}
+
+static int promote_huge_pud_page_isolate(struct vm_area_struct *vma,
+					unsigned long haddr,
+					struct page **head, struct list_head *subpage_list)
+{
+	struct mm_struct *mm = vma->vm_mm;
+	pud_t *pud;
+	pmd_t *pmd;
+	spinlock_t *pmd_ptl;
+	int ret = -EBUSY;
+
+	pud = mm_find_pud(mm, haddr);
+	if (!pud)
+		goto out;
+
+	anon_vma_lock_write(vma->anon_vma);
+
+	pmd = pmd_offset(pud, haddr);
+	if (!pmd)
+		goto out_unlock;
+	pmd_ptl = pmd_lockptr(mm, pmd);
+
+	spin_lock(pmd_ptl);
+	ret = __promote_huge_pud_page_isolate(vma, haddr, pmd, head, subpage_list);
+	spin_unlock(pmd_ptl);
+
+	if (unlikely(!ret)) {
+		ret = -EBUSY;
+		goto out_unlock;
+	}
+	ret = 0;
+	/*
+	 * All pages are isolated and locked so anon_vma rmap
+	 * can't run anymore.
+	 */
+out_unlock:
+	anon_vma_unlock_write(vma->anon_vma);
+out:
+	return ret;
+}
+
+/*
+ * This function promotes normal pages into a huge page. @list point to all
+ * subpages of huge page to promote, @head point to the head page.
+ *
+ * Only caller must hold pin on the pages on @list, otherwise promotion
+ * fails with -EBUSY. All subpages must be locked.
+ *
+ * Both head page and tail pages will inherit mapping, flags, and so on from
+ * the hugepage.
+ *
+ * GUP pin and PG_locked transferred to @page. *
+ *
+ * Returns 0 if the hugepage is promoted successfully.
+ * Returns -EBUSY if any subpage is pinned or if anon_vma disappeared from
+ * under us.
+ */
+int promote_list_to_huge_pud_page(struct page *head, struct list_head *list)
+{
+	struct anon_vma *anon_vma = NULL;
+	int ret = 0;
+	DECLARE_BITMAP(subpage_bitmap, HPAGE_PMD_NR);
+	struct page *subpage;
+	int i;
+
+	/* no file-backed page support yet */
+	if (PageAnon(head)) {
+		/*
+		 * The caller does not necessarily hold an mmap_sem that would
+		 * prevent the anon_vma disappearing so we first we take a
+		 * reference to it and then lock the anon_vma for write. This
+		 * is similar to page_lock_anon_vma_read except the write lock
+		 * is taken to serialise against parallel split or collapse
+		 * operations.
+		 */
+		anon_vma = page_get_anon_vma(head);
+		if (!anon_vma) {
+			ret = -EBUSY;
+			goto out;
+		}
+		anon_vma_lock_write(anon_vma);
+	} else {
+		ret = -EBUSY;
+		goto out;
+	}
+
+	/* Racy check each subpage to see if any has extra pin */
+	list_for_each_entry(subpage, list, lru) {
+		if (can_promote_huge_pud_page(subpage))
+			bitmap_set(subpage_bitmap, (subpage - head)/HPAGE_PMD_NR, 1);
+	}
+	/* Proceed only if none of subpages has extra pin.  */
+	if (!bitmap_full(subpage_bitmap, HPAGE_PMD_NR)) {
+		ret = -EBUSY;
+		goto out_unlock;
+	}
+
+	list_for_each_entry(subpage, list, lru) {
+		enum ttu_flags ttu_flags = TTU_IGNORE_MLOCK | TTU_IGNORE_ACCESS |
+			TTU_RMAP_LOCKED;
+		bool unmap_success;
+		struct pglist_data *pgdata = NULL;
+
+		if (PageAnon(subpage))
+			ttu_flags |= TTU_SPLIT_FREEZE;
+
+		unmap_success = try_to_unmap(subpage, ttu_flags);
+		VM_BUG_ON_PAGE(!unmap_success, subpage);
+
+		/* remove subpages from page_deferred_list */
+		pgdata = NODE_DATA(page_to_nid(subpage));
+		spin_lock(&pgdata->split_queue_lock);
+		if (!list_empty(page_deferred_list(subpage))) {
+			pgdata->split_queue_len--;
+			list_del_init(page_deferred_list(subpage));
+		}
+		spin_unlock(&pgdata->split_queue_lock);
+	}
+
+	/*first_compound_mapcount = compound_mapcount(head);*/
+	/* Take care of migration wait list:
+	 * make compound page first, since it is impossible to move waiting
+	 * process from subpage queues to the head page queue.
+	 */
+	set_compound_page_dtor(head, COMPOUND_PAGE_DTOR);
+	set_compound_order(head, HPAGE_PUD_ORDER);
+	__SetPageHead(head);
+	list_del(&head->lru);
+	for (i = 1; i < HPAGE_PUD_NR; i++) {
+		struct page *p = head + i;
+
+		if (i % HPAGE_PMD_NR == 0) {
+			list_del(&p->lru);
+			/* move subpage refcount to head page */
+			page_ref_add(head, page_count(p) - 1);
+		}
+		p->index = 0;
+		p->mapping = TAIL_MAPPING;
+		p->mem_cgroup = NULL;
+		ClearPageActive(p);
+		set_page_count(p, 0);
+		set_compound_head(p, head);
+	}
+	atomic_set(compound_mapcount_ptr(head), -1);
+	for (i = 0; i < HPAGE_PUD_NR; i += HPAGE_PMD_NR)
+		atomic_set(sub_compound_mapcount_ptr(&head[i], 1), -1);
+	prep_transhuge_page(head);
+	/* Set first PMD-mapped page sub_compound_mapcount */
+
+	remap_pud_page(head);
+
+	for (i = HPAGE_PMD_NR; i < HPAGE_PUD_NR; i += HPAGE_PMD_NR) {
+		struct page *subpage = head + i;
+
+		__unlock_page(subpage);
+	}
+
+	INIT_LIST_HEAD(&head->lru);
+	unlock_page(head);
+	putback_lru_page(head);
+
+	mod_node_page_state(page_pgdat(head),
+			NR_ISOLATED_ANON + page_is_file_cache(head), -HPAGE_PUD_NR);
+out_unlock:
+	if (anon_vma) {
+		anon_vma_unlock_write(anon_vma);
+		put_anon_vma(anon_vma);
+	}
+out:
+	while (!list_empty(list)) {
+		struct page *p = list_first_entry(list, struct page, lru);
+		list_del(&p->lru);
+		unlock_page(p);
+		putback_lru_page(p);
+	}
+	return ret;
+}
+
+/* assume mmap_sem is down_write, wrapper for madvise */
+int promote_huge_pud_page_address(struct vm_area_struct *vma, unsigned long haddr)
+{
+	LIST_HEAD(subpage_list);
+	struct page *head;
+
+	if (haddr & (HPAGE_PUD_SIZE - 1))
+		return -EINVAL;
+	if (haddr < vma->vm_start || (haddr + HPAGE_PUD_SIZE) > vma->vm_end)
+		return -EINVAL;
+
+	if (promote_huge_pud_page_isolate(vma, haddr, &head, &subpage_list))
+		return -EBUSY;
+
+	return promote_list_to_huge_pud_page(head, &subpage_list);
+}
diff --git a/mm/internal.h b/mm/internal.h
index c5e5a0f1cc58..6d5ebcdcde4c 100644
--- a/mm/internal.h
+++ b/mm/internal.h
@@ -584,7 +584,9 @@ void prep_new_page(struct page *page, unsigned int order, gfp_t gfp_flags,
 void __unlock_page(struct page *page);
 
 int promote_huge_pmd_address(struct vm_area_struct *vma, unsigned long haddr);
+int promote_huge_pud_address(struct vm_area_struct *vma, unsigned long haddr);
 
 int promote_huge_page_address(struct vm_area_struct *vma, unsigned long haddr);
+int promote_huge_pud_page_address(struct vm_area_struct *vma, unsigned long haddr);
 
 #endif	/* __MM_INTERNAL_H */
diff --git a/mm/pgtable-generic.c b/mm/pgtable-generic.c
index 95af1d67f209..99c4fb526c04 100644
--- a/mm/pgtable-generic.c
+++ b/mm/pgtable-generic.c
@@ -266,4 +266,24 @@ pmd_t pmdp_collapse_flush(struct vm_area_struct *vma, unsigned long address,
 	return pmd;
 }
 #endif
+
+#ifndef pudp_collapse_flush
+pud_t pudp_collapse_flush(struct vm_area_struct *vma, unsigned long address,
+			  pud_t *pudp)
+{
+	/*
+	 * pud and hugepage pte format are same. So we could
+	 * use the same function.
+	 */
+	pud_t pud;
+
+	VM_BUG_ON(address & ~HPAGE_PUD_MASK);
+	VM_BUG_ON(pud_trans_huge(*pudp));
+	pud = pudp_huge_get_and_clear(vma->vm_mm, address, pudp);
+
+	/* collapse entails shooting down ptes not pmd */
+	flush_tlb_range(vma, address, address + HPAGE_PUD_SIZE);
+	return pud;
+}
+#endif
 #endif /* CONFIG_TRANSPARENT_HUGEPAGE */
diff --git a/mm/rmap.c b/mm/rmap.c
index 39f446a6775d..49ccbf0cfe4d 100644
--- a/mm/rmap.c
+++ b/mm/rmap.c
@@ -1112,12 +1112,13 @@ void do_page_add_anon_rmap(struct page *page,
 {
 	bool compound = flags & RMAP_COMPOUND;
 	bool first;
+	struct page *head = compound_head(page);
 
 	if (compound) {
 		atomic_t *mapcount;
 		VM_BUG_ON_PAGE(!PageLocked(page), page);
-		VM_BUG_ON_PAGE(!PageTransHuge(page), page);
-		if (compound_order(page) == HPAGE_PUD_ORDER) {
+		VM_BUG_ON_PAGE(!PMDPageInPUD(page) && !PageTransHuge(page), page);
+		if (compound_order(head) == HPAGE_PUD_ORDER) {
 			if (order == HPAGE_PUD_ORDER) {
 				mapcount = compound_mapcount_ptr(page);
 			} else if (order == HPAGE_PMD_ORDER) {
@@ -1125,7 +1126,7 @@ void do_page_add_anon_rmap(struct page *page,
 				mapcount = sub_compound_mapcount_ptr(page, 1);
 			} else
 				VM_BUG_ON(1);
-		} else if (compound_order(page) == HPAGE_PMD_ORDER) {
+		} else if (compound_order(head) == HPAGE_PMD_ORDER) {
 			mapcount = compound_mapcount_ptr(page);
 		} else
 			VM_BUG_ON(1);
@@ -1135,7 +1136,8 @@ void do_page_add_anon_rmap(struct page *page,
 	}
 
 	if (first) {
-		int nr = compound ? hpage_nr_pages(page) : 1;
+		/*int nr = compound ? hpage_nr_pages(page) : 1;*/
+		int nr = 1<<order;
 		/*
 		 * We use the irq-unsafe __{inc|mod}_zone_page_stat because
 		 * these counters are not modified in interrupt context, and
@@ -1429,6 +1431,7 @@ static bool try_to_unmap_one(struct page *page, struct vm_area_struct *vma,
 	bool ret = true;
 	struct mmu_notifier_range range;
 	enum ttu_flags flags = (enum ttu_flags)arg;
+	int order = 0;
 
 	/* munlock has nothing to gain from examining un-locked vmas */
 	if ((flags & TTU_MUNLOCK) && !(vma->vm_flags & VM_LOCKED))
@@ -1505,12 +1508,16 @@ static bool try_to_unmap_one(struct page *page, struct vm_area_struct *vma,
 
 		/* Unexpected PMD-mapped THP? */
 
-		if (pvmw.pte)
+		if (pvmw.pte) {
 			subpage = page - page_to_pfn(page) + pte_pfn(*pvmw.pte);
-		else if (!pvmw.pte && pvmw.pmd)
+			order = 0;
+		} else if (!pvmw.pte && pvmw.pmd) {
 			subpage = page - page_to_pfn(page) + pmd_pfn(*pvmw.pmd);
-		else if (!pvmw.pte && !pvmw.pmd && pvmw.pud)
+			order = HPAGE_PMD_ORDER;
+		} else if (!pvmw.pte && !pvmw.pmd && pvmw.pud) {
 			subpage = page - page_to_pfn(page) + pud_pfn(*pvmw.pud);
+			order = HPAGE_PUD_ORDER;
+		}
 		VM_BUG_ON(!subpage);
 		address = pvmw.address;
 
@@ -1794,7 +1801,7 @@ static bool try_to_unmap_one(struct page *page, struct vm_area_struct *vma,
 		 *
 		 * See Documentation/vm/mmu_notifier.rst
 		 */
-		page_remove_rmap(subpage, PageHuge(page), 0);
+		page_remove_rmap(subpage, PageHuge(page) || order >= HPAGE_PMD_ORDER, order);
 		put_page(page);
 	}
 
-- 
2.20.1


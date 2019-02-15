Return-Path: <SRS0=VMr4=QW=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.9 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_PASS,USER_AGENT_GIT autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 51FD8C4360F
	for <linux-mm@archiver.kernel.org>; Fri, 15 Feb 2019 22:09:49 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id DA0F6222D0
	for <linux-mm@archiver.kernel.org>; Fri, 15 Feb 2019 22:09:48 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=sent.com header.i=@sent.com header.b="NboxJUb4";
	dkim=pass (2048-bit key) header.d=messagingengine.com header.i=@messagingengine.com header.b="V5O/6hnz"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org DA0F6222D0
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=sent.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id B7D7E8E0010; Fri, 15 Feb 2019 17:09:23 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id B057B8E0009; Fri, 15 Feb 2019 17:09:23 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 980458E0010; Fri, 15 Feb 2019 17:09:23 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f199.google.com (mail-qk1-f199.google.com [209.85.222.199])
	by kanga.kvack.org (Postfix) with ESMTP id 6194E8E0009
	for <linux-mm@kvack.org>; Fri, 15 Feb 2019 17:09:23 -0500 (EST)
Received: by mail-qk1-f199.google.com with SMTP id i66so9295096qke.21
        for <linux-mm@kvack.org>; Fri, 15 Feb 2019 14:09:23 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:dkim-signature:from:to:cc:subject
         :date:message-id:in-reply-to:references:reply-to:mime-version
         :content-transfer-encoding;
        bh=6izkSh0QkhVkdlYUdv/QvNmi6VpmN/HVg2zSBUK92No=;
        b=uISxrtZfNP1+WeocFiIhRXTu5wjUsjULlWKL5ay9W8G7M/2tiGHlNFyTuWFFit6mXx
         o10MpobUSC+39BQUfTuuMY8FVHyyirGVpBWxugazHPlgGzV77urvaCVD4+GslqlPRqgs
         5NkEd9J7Okau1g5xWDSuR52unIM1kcsNmAzofRYGm25B0RUuyT4KHN2AO5LLMuQswP3Y
         kJ4hooatBV77Fo7BRlv4l/B2+wLBbzHonYhIIly1yCfTB1To44WuPAONUqVlyA49yGr/
         SkHfWQa80w1XJW1+ARuvBfKa3jZBTAZK5IVXol+SXWzgWmzm54ZaA0DSm5UHJQUZKa2e
         gtFg==
X-Gm-Message-State: AHQUAuaQnZfOeXF9u60NrubSIRhVkoq0libFCIo4GAh1W7uaVY15fZFw
	WVHdIk0qVF91Lgv0MnGLHsmL3kVfXc/6AXnORDkc0q/+3PwveMgIhHKuNbTVdL24ioDysj46d2m
	UrTDi7YNthlNMmL+Q4zWmwsGAFFlaP5sOo90z+nn/Ll5lS9VaqbkDMWDA9kaGKNwMeg==
X-Received: by 2002:ac8:2798:: with SMTP id w24mr9301313qtw.280.1550268563143;
        Fri, 15 Feb 2019 14:09:23 -0800 (PST)
X-Google-Smtp-Source: AHgI3IY1UShbkO641PmYLTjgE7MRJYGYBfPoSIik/RVh9bDlDWAOl5z0mxU76dOpHBM8ggeQ25Zw
X-Received: by 2002:ac8:2798:: with SMTP id w24mr9301264qtw.280.1550268562194;
        Fri, 15 Feb 2019 14:09:22 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1550268562; cv=none;
        d=google.com; s=arc-20160816;
        b=QjgTJjscy2i54qB7g7GPgL90I+bNyu3+wbfFmkNucclyVhHrwTr2oSNRW9yqojYqjP
         AuNOnr2U6RriAYLJ9SF///MJu6OMe8PhueTzl+c/Ue+CC9xNUpxbtQqtsruKwdnKVMjd
         1LZkea9fRh9nR5p6CAR/KJqB8augbA5RlzcmeB65/LblZbPEIaUvTY0zeUCkJES151x9
         bqC1eQ14BfdY9Vq2JATrlbz2z7tRwC4CNJbOwj73oL/MCQdQV+K3slhI0+YzzTg1BDWe
         9z6qQ21VWftAHG2xl3xLR9dsKRL26mkLsSHpYK7gHVf+7PfCH+bp+dakn0B4fm//smOV
         dFhA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:reply-to:references
         :in-reply-to:message-id:date:subject:cc:to:from:dkim-signature
         :dkim-signature;
        bh=6izkSh0QkhVkdlYUdv/QvNmi6VpmN/HVg2zSBUK92No=;
        b=DdoSzD8TPjqhjmklzuRpTXjMYA8++2ucYjURrUWRUDMlPBQavDgoOtoKnnGPK9kuas
         gXrxhGCKrv8A7duicas49L3UPuGzIaw0QCvjUqjRJvHE4EMiCekG83VXxiAwJ32jKCoD
         kR8k1RTzRa6VpYVbv8wZ3xdG0qOw+IFFo08+MNduPpGZ0BF2BP86NfnNwt6U9vp/9oAu
         TsXqIc+b9qYObzhnGqWrTY/rmwSIGB5Ea6hvGYYNHxq9EEGqGQM3PCVhDbycNWx8FZ+G
         3vlKaRarCdIiB1pEKd/oHAoxZQjRgP0KIMAr3m2OtGeFfPcYUT6h2vTwXqhlr529hZf9
         B6OQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@sent.com header.s=fm2 header.b=NboxJUb4;
       dkim=pass header.i=@messagingengine.com header.s=fm2 header.b="V5O/6hnz";
       spf=pass (google.com: domain of zi.yan@sent.com designates 64.147.123.25 as permitted sender) smtp.mailfrom=zi.yan@sent.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=sent.com
Received: from wout2-smtp.messagingengine.com (wout2-smtp.messagingengine.com. [64.147.123.25])
        by mx.google.com with ESMTPS id i67si111062qke.61.2019.02.15.14.09.22
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 15 Feb 2019 14:09:22 -0800 (PST)
Received-SPF: pass (google.com: domain of zi.yan@sent.com designates 64.147.123.25 as permitted sender) client-ip=64.147.123.25;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@sent.com header.s=fm2 header.b=NboxJUb4;
       dkim=pass header.i=@messagingengine.com header.s=fm2 header.b="V5O/6hnz";
       spf=pass (google.com: domain of zi.yan@sent.com designates 64.147.123.25 as permitted sender) smtp.mailfrom=zi.yan@sent.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=sent.com
Received: from compute3.internal (compute3.nyi.internal [10.202.2.43])
	by mailout.west.internal (Postfix) with ESMTP id 68849310A;
	Fri, 15 Feb 2019 17:09:20 -0500 (EST)
Received: from mailfrontend1 ([10.202.2.162])
  by compute3.internal (MEProxy); Fri, 15 Feb 2019 17:09:21 -0500
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=sent.com; h=from
	:to:cc:subject:date:message-id:in-reply-to:references:reply-to
	:mime-version:content-transfer-encoding; s=fm2; bh=6izkSh0QkhVkd
	lYUdv/QvNmi6VpmN/HVg2zSBUK92No=; b=NboxJUb4JJbErEEjJuHEaXojREiBj
	IoGoDAYLyW9M4ZlbXDLD5a4W8IWjKO0Lx/GTmmtBGOVdE/IgQi/QNUaq55/aIrxS
	rfsX3qFXTjklZIOjgrvQ8pnEC/BVBzTtlkPotu+d4rHZKzVsclO7/1srDu3xjcws
	mcpveWVzvfWxQdEra7EDSuGQ4jlnBG52NRa5E6/oeK792X1izyhuWiqJWXFflZzr
	bGoZvbegF31pe+hYlJATS0O3Xbta4fiBppVpWO1O/kc/ghnjUeAgRGKoea6T7QTb
	685QmxY2A/JbgfJikJFEHWANCEyIWszkcoUh87eCOtGz9a+pDVNR91RdQ==
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=
	messagingengine.com; h=cc:content-transfer-encoding:date:from
	:in-reply-to:message-id:mime-version:references:reply-to:subject
	:to:x-me-proxy:x-me-proxy:x-me-sender:x-me-sender:x-sasl-enc; s=
	fm2; bh=6izkSh0QkhVkdlYUdv/QvNmi6VpmN/HVg2zSBUK92No=; b=V5O/6hnz
	5DVgh0AQ+oFk/xn02eM91U6It3D895X9V5Ru8KPmXp30Hx1BOLt+nEtLby5e9l4K
	twJRM8vyfAzvVv2GNSMerTUpAMtDZLa1MjeoWQlUnx97nA12lLv/23sLeqIVQ+hN
	7aBGO/QT1yd6lgJJZqTbzsOBEkjDvA9MPAOqLLZRz38wdN+cyoqUKkAq12oi3Sgp
	qO2bAGFxFuwDFILE4F3BXCss//2W1QPIGgA8DCEeo/6LV072rKcXcKZ2QflJhOuc
	yoQYgpfqltmK+2IGR4Srp7BeDLGFLzsw6+yHLLrarsRTrTU7gJf8p+LWMRN5nzDZ
	+mbPucr9aPVIcg==
X-ME-Sender: <xms:jzhnXLM_CoCVjN9Htlvp_bw55_2FXYYhQ4twD_N-hRiSIWLRXObtLA>
X-ME-Proxy-Cause: gggruggvucftvghtrhhoucdtuddrgedtledruddtjedgudehkecutefuodetggdotefrod
    ftvfcurfhrohhfihhlvgemucfhrghsthforghilhdpqfhuthenuceurghilhhouhhtmecu
    fedttdenucesvcftvggtihhpihgvnhhtshculddquddttddmnecujfgurhephffvufffkf
    fojghfrhgggfestdekredtredttdenucfhrhhomhepkghiucgjrghnuceoiihirdihrghn
    sehsvghnthdrtghomheqnecukfhppedvudeirddvvdekrdduuddvrddvvdenucfrrghrrg
    hmpehmrghilhhfrhhomhepiihirdihrghnsehsvghnthdrtghomhenucevlhhushhtvghr
    ufhiiigvpeel
X-ME-Proxy: <xmx:jzhnXFpfVE6BGzQkKkAjg8u-Mj65r6-Y-zEZATVEMbJxxyJM36O1rg>
    <xmx:jzhnXAMoLQnI-ue2yUgkL31zJGsu_n-Zf4F-hFvXPxlYH3k7qsjfHg>
    <xmx:jzhnXJ93mC53NoXZPjzsjf0d7TLhdpVGAhyZqQD9O2GwGRYLW0l61Q>
    <xmx:jzhnXBaOaxmycjrFY3eBcg6HSGImfs3TMQxkwf-cf06lU-3vvkP_7A>
Received: from nvrsysarch5.nvidia.com (thunderhill.nvidia.com [216.228.112.22])
	by mail.messagingengine.com (Postfix) with ESMTPA id 4AB1DE46AB;
	Fri, 15 Feb 2019 17:09:18 -0500 (EST)
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
Subject: [RFC PATCH 13/31] mm: thp: 1GB THP copy on write implementation.
Date: Fri, 15 Feb 2019 14:08:38 -0800
Message-Id: <20190215220856.29749-14-zi.yan@sent.com>
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

COW on 1GB THPs will fall back to 2MB THPs if 1GB THP is not available.

Signed-off-by: Zi Yan <ziy@nvidia.com>
---
 arch/x86/include/asm/pgalloc.h |   9 +
 include/linux/huge_mm.h        |   5 +
 mm/huge_memory.c               | 319 ++++++++++++++++++++++++++++++++-
 mm/memory.c                    |   2 +-
 4 files changed, 331 insertions(+), 4 deletions(-)

diff --git a/arch/x86/include/asm/pgalloc.h b/arch/x86/include/asm/pgalloc.h
index 6e29ad9b9d7f..ebcb022f6bb9 100644
--- a/arch/x86/include/asm/pgalloc.h
+++ b/arch/x86/include/asm/pgalloc.h
@@ -110,6 +110,15 @@ static inline void pmd_populate(struct mm_struct *mm, pmd_t *pmd,
 
 #define pmd_pgtable(pmd) pmd_page(pmd)
 
+static inline void pud_populate_with_pgtable(struct mm_struct *mm, pud_t *pud,
+				struct page *pte)
+{
+	unsigned long pfn = page_to_pfn(pte);
+
+	paravirt_alloc_pmd(mm, pfn);
+	set_pud(pud, __pud(((pteval_t)pfn << PAGE_SHIFT) | _PAGE_TABLE));
+}
+
 #if CONFIG_PGTABLE_LEVELS > 2
 static inline pmd_t *pmd_alloc_one(struct mm_struct *mm, unsigned long addr)
 {
diff --git a/include/linux/huge_mm.h b/include/linux/huge_mm.h
index c6272e6ffc35..02419fa91e12 100644
--- a/include/linux/huge_mm.h
+++ b/include/linux/huge_mm.h
@@ -19,6 +19,7 @@ extern int copy_huge_pud(struct mm_struct *dst_mm, struct mm_struct *src_mm,
 #ifdef CONFIG_HAVE_ARCH_TRANSPARENT_HUGEPAGE_PUD
 extern void huge_pud_set_accessed(struct vm_fault *vmf, pud_t orig_pud);
 extern int do_huge_pud_anonymous_page(struct vm_fault *vmf);
+extern int do_huge_pud_wp_page(struct vm_fault *vmf, pud_t orig_pud);
 #else
 static inline void huge_pud_set_accessed(struct vm_fault *vmf, pud_t orig_pud)
 {
@@ -27,6 +28,10 @@ extern int do_huge_pud_anonymous_page(struct vm_fault *vmf)
 {
 	return VM_FAULT_FALLBACK;
 }
+extern int do_huge_pud_wp_page(struct vm_fault *vmf, pud_t orig_pud)
+{
+	return VM_FAULT_FALLBACK;
+}
 #endif
 
 extern vm_fault_t do_huge_pmd_wp_page(struct vm_fault *vmf, pmd_t orig_pmd);
diff --git a/mm/huge_memory.c b/mm/huge_memory.c
index cad4ef01f607..0a006592f3fe 100644
--- a/mm/huge_memory.c
+++ b/mm/huge_memory.c
@@ -1284,7 +1284,12 @@ int copy_huge_pud(struct mm_struct *dst_mm, struct mm_struct *src_mm,
 {
 	spinlock_t *dst_ptl, *src_ptl;
 	pud_t pud;
-	int ret;
+	pmd_t *pmd_pgtable = NULL;
+	int ret = -ENOMEM;
+
+	pmd_pgtable = pmd_alloc_one_page_with_ptes(vma->vm_mm, addr);
+	if (unlikely(!pmd_pgtable))
+		goto out;
 
 	dst_ptl = pud_lock(dst_mm, dst_pud);
 	src_ptl = pud_lockptr(src_mm, src_pud);
@@ -1292,8 +1297,13 @@ int copy_huge_pud(struct mm_struct *dst_mm, struct mm_struct *src_mm,
 
 	ret = -EAGAIN;
 	pud = *src_pud;
-	if (unlikely(!pud_trans_huge(pud) && !pud_devmap(pud)))
+	if (unlikely(!pud_trans_huge(pud) && !pud_devmap(pud))) {
+		pmd_free_page_with_ptes(dst_mm, pmd_pgtable);
 		goto out_unlock;
+	}
+
+	if (pud_devmap(pud))
+		pmd_free_page_with_ptes(dst_mm, pmd_pgtable);
 
 	/*
 	 * When page table lock is held, the huge zero pud should not be
@@ -1301,7 +1311,32 @@ int copy_huge_pud(struct mm_struct *dst_mm, struct mm_struct *src_mm,
 	 * a page table.
 	 */
 	if (is_huge_zero_pud(pud)) {
-		/* No huge zero pud yet */
+		struct page *zero_page;
+		/*
+		 * get_huge_zero_page() will never allocate a new page here,
+		 * since we already have a zero page to copy. It just takes a
+		 * reference.
+		 */
+		zero_page = mm_get_huge_pud_zero_page(dst_mm);
+		set_huge_pud_zero_page(virt_to_page(pmd_pgtable),
+			dst_mm, vma, addr, dst_pud, zero_page);
+		ret = 0;
+		goto out_unlock;
+	}
+
+	if (pud_trans_huge(pud)) {
+		struct page *src_page;
+		int i;
+
+		src_page = pud_page(pud);
+		VM_BUG_ON_PAGE(!PageHead(src_page), src_page);
+		get_page(src_page);
+		page_dup_rmap(src_page, true);
+		add_mm_counter(dst_mm, MM_ANONPAGES, HPAGE_PUD_NR);
+		mm_inc_nr_pmds(dst_mm);
+		for (i = 0; i < (1<<(HPAGE_PUD_ORDER - HPAGE_PMD_ORDER)); i++)
+			mm_inc_nr_ptes(dst_mm);
+		pgtable_trans_huge_pud_deposit(dst_mm, dst_pud, virt_to_page(pmd_pgtable));
 	}
 
 	pudp_set_wrprotect(src_mm, addr, src_pud);
@@ -1312,6 +1347,7 @@ int copy_huge_pud(struct mm_struct *dst_mm, struct mm_struct *src_mm,
 out_unlock:
 	spin_unlock(src_ptl);
 	spin_unlock(dst_ptl);
+out:
 	return ret;
 }
 
@@ -1335,6 +1371,283 @@ void huge_pud_set_accessed(struct vm_fault *vmf, pud_t orig_pud)
 unlock:
 	spin_unlock(vmf->ptl);
 }
+
+static int do_huge_pud_wp_page_fallback(struct vm_fault *vmf, pud_t orig_pud,
+		struct page *page)
+{
+	struct vm_area_struct *vma = vmf->vma;
+	unsigned long haddr = vmf->address & HPAGE_PUD_MASK;
+	struct mem_cgroup *memcg;
+	pgtable_t pgtable, pmd_pgtable;
+	pud_t _pud;
+	int ret = 0, i, j;
+	struct page **pages;
+	struct mmu_notifier_range range;
+
+	pages = kmalloc(sizeof(struct page *) * HPAGE_PUD_NR,
+			GFP_KERNEL);
+	if (unlikely(!pages)) {
+		ret |= VM_FAULT_OOM;
+		goto out;
+	}
+
+	pmd_pgtable = pte_alloc_order(vma->vm_mm, haddr,
+		HPAGE_PUD_ORDER - HPAGE_PMD_ORDER);
+	if (!pmd_pgtable) {
+		ret |= VM_FAULT_OOM;
+		goto out_kfree_pages;
+	}
+
+	for (i = 0; i < (1<<(HPAGE_PUD_ORDER-HPAGE_PMD_ORDER)); i++) {
+		pages[i] = alloc_page_vma_node(GFP_TRANSHUGE, vma,
+					       vmf->address, page_to_nid(page));
+		if (unlikely(!pages[i] ||
+			     mem_cgroup_try_charge(pages[i], vma->vm_mm,
+				     GFP_KERNEL, &memcg, true))) {
+			if (pages[i])
+				put_page(pages[i]);
+			while (--i >= 0) {
+				memcg = (void *)page_private(pages[i]);
+				set_page_private(pages[i], 0);
+				mem_cgroup_cancel_charge(pages[i], memcg,
+						true);
+				put_page(pages[i]);
+			}
+			kfree(pages);
+			pte_free_order(vma->vm_mm, pmd_pgtable,
+				HPAGE_PMD_ORDER - HPAGE_PMD_ORDER);
+			ret |= VM_FAULT_OOM;
+			goto out;
+		}
+		count_vm_event(THP_FAULT_ALLOC);
+		set_page_private(pages[i], (unsigned long)memcg);
+		prep_transhuge_page(pages[i]);
+	}
+
+	for (i = 0; i < (1<<(HPAGE_PUD_ORDER-HPAGE_PMD_ORDER)); i++) {
+		for (j = 0; j < HPAGE_PMD_NR; j++) {
+			copy_user_highpage(pages[i] + j, page + i * HPAGE_PMD_NR + j,
+					   haddr + PAGE_SIZE * (i * HPAGE_PMD_NR + j), vma);
+			cond_resched();
+		}
+		__SetPageUptodate(pages[i]);
+	}
+
+	mmu_notifier_range_init(&range, vma->vm_mm, haddr,
+				haddr + HPAGE_PUD_SIZE);
+	mmu_notifier_invalidate_range_start(&range);
+
+	vmf->ptl = pud_lock(vma->vm_mm, vmf->pud);
+	if (unlikely(!pud_same(*vmf->pud, orig_pud)))
+		goto out_free_pages;
+	VM_BUG_ON_PAGE(!PageHead(page), page);
+
+	/*
+	 * Leave pmd empty until pte is filled note we must notify here as
+	 * concurrent CPU thread might write to new page before the call to
+	 * mmu_notifier_invalidate_range_end() happens which can lead to a
+	 * device seeing memory write in different order than CPU.
+	 *
+	 * See Documentation/vm/mmu_notifier.txt
+	 */
+	pmdp_huge_clear_flush_notify(vma, haddr, vmf->pmd);
+
+	pgtable = pgtable_trans_huge_pud_withdraw(vma->vm_mm, vmf->pud);
+	pud_populate_with_pgtable(vma->vm_mm, &_pud, pgtable);
+
+	for (i = 0; i < (1<<(HPAGE_PUD_ORDER-HPAGE_PMD_ORDER));
+		 i++, haddr += (PAGE_SIZE * HPAGE_PMD_NR)) {
+		pmd_t entry;
+
+		entry = mk_huge_pmd(pages[i], vma->vm_page_prot);
+		entry = maybe_pmd_mkwrite(pmd_mkdirty(entry), vma);
+		memcg = (void *)page_private(pages[i]);
+		set_page_private(pages[i], 0);
+		page_add_new_anon_rmap(pages[i], vmf->vma, haddr, true);
+		mem_cgroup_commit_charge(pages[i], memcg, false, true);
+		lru_cache_add_active_or_unevictable(pages[i], vma);
+		vmf->pmd = pmd_offset(&_pud, haddr);
+		VM_BUG_ON(!pmd_none(*vmf->pmd));
+		pgtable_trans_huge_deposit(vma->vm_mm, vmf->pmd, &pmd_pgtable[i]);
+		set_pmd_at(vma->vm_mm, haddr, vmf->pmd, entry);
+	}
+	kfree(pages);
+
+	smp_wmb(); /* make pte visible before pmd */
+	pud_populate_with_pgtable(vma->vm_mm, vmf->pud, pgtable);
+	page_remove_rmap(page, true);
+	spin_unlock(vmf->ptl);
+
+	/*
+	 * No need to double call mmu_notifier->invalidate_range() callback as
+	 * the above pmdp_huge_clear_flush_notify() did already call it.
+	 */
+	mmu_notifier_invalidate_range_only_end(&range);
+
+	ret |= VM_FAULT_WRITE;
+	put_page(page);
+
+out:
+	return ret;
+
+out_free_pages:
+	spin_unlock(vmf->ptl);
+	mmu_notifier_invalidate_range_end(&range);
+	for (i = 0; i < (1<<(HPAGE_PUD_ORDER-HPAGE_PMD_ORDER)); i++) {
+		memcg = (void *)page_private(pages[i]);
+		set_page_private(pages[i], 0);
+		mem_cgroup_cancel_charge(pages[i], memcg, true);
+		put_page(pages[i]);
+	}
+out_kfree_pages:
+	kfree(pages);
+	goto out;
+}
+
+int do_huge_pud_wp_page(struct vm_fault *vmf, pud_t orig_pud)
+{
+	struct vm_area_struct *vma = vmf->vma;
+	struct page *page = NULL, *new_page;
+	struct mem_cgroup *memcg;
+	unsigned long haddr = vmf->address & HPAGE_PUD_MASK;
+	struct mmu_notifier_range range;
+	gfp_t huge_gfp;			/* for allocation and charge */
+	int ret = 0;
+
+	vmf->ptl = pud_lockptr(vma->vm_mm, vmf->pud);
+	VM_BUG_ON_VMA(!vma->anon_vma, vma);
+	if (is_huge_zero_pud(orig_pud))
+		goto alloc;
+	spin_lock(vmf->ptl);
+	if (unlikely(!pud_same(*vmf->pud, orig_pud)))
+		goto out_unlock;
+
+	page = pud_page(orig_pud);
+	VM_BUG_ON_PAGE(!PageCompound(page) || !PageHead(page), page);
+	/*
+	 * We can only reuse the page if nobody else maps the huge page or it's
+	 * part.
+	 */
+	if (!trylock_page(page)) {
+		get_page(page);
+		spin_unlock(vmf->ptl);
+		lock_page(page);
+		spin_lock(vmf->ptl);
+		if (unlikely(!pud_same(*vmf->pud, orig_pud))) {
+			unlock_page(page);
+			put_page(page);
+			goto out_unlock;
+		}
+		put_page(page);
+	}
+	if (reuse_swap_page(page, NULL)) {
+		pud_t entry;
+
+		entry = pud_mkyoung(orig_pud);
+		entry = maybe_pud_mkwrite(pud_mkdirty(entry), vma);
+		if (pudp_set_access_flags(vma, haddr, vmf->pud, entry,  1))
+			update_mmu_cache_pud(vma, vmf->address, vmf->pud);
+		ret |= VM_FAULT_WRITE;
+		unlock_page(page);
+		goto out_unlock;
+	}
+	unlock_page(page);
+	get_page(page);
+	spin_unlock(vmf->ptl);
+alloc:
+	if (transparent_hugepage_enabled(vma) &&
+	    !transparent_hugepage_debug_cow()) {
+		huge_gfp = alloc_hugepage_direct_gfpmask(vma);
+		new_page = alloc_hugepage_vma(huge_gfp, vma, haddr, HPAGE_PUD_ORDER);
+	} else
+		new_page = NULL;
+
+	if (likely(new_page)) {
+		prep_transhuge_page(new_page);
+	} else {
+		if (!page) {
+			WARN(1, "%s: split_huge_page\n", __func__);
+			split_huge_pud(vma, vmf->pud, vmf->address);
+			ret |= VM_FAULT_FALLBACK;
+		} else {
+			ret = do_huge_pud_wp_page_fallback(vmf, orig_pud, page);
+			if (ret & VM_FAULT_OOM) {
+				WARN(1, "%s: split_huge_page after wp fallback\n", __func__);
+				split_huge_pud(vma, vmf->pud, vmf->address);
+				ret |= VM_FAULT_FALLBACK;
+			}
+			put_page(page);
+		}
+		count_vm_event(THP_FAULT_FALLBACK_PUD);
+		goto out;
+	}
+
+	if (unlikely(mem_cgroup_try_charge(new_page, vma->vm_mm,
+					huge_gfp, &memcg, true))) {
+		put_page(new_page);
+		WARN(1, "%s: split_huge_page after mem cgroup failed\n", __func__);
+		split_huge_pud(vma, vmf->pud, vmf->address);
+		if (page)
+			put_page(page);
+		ret |= VM_FAULT_FALLBACK;
+		count_vm_event(THP_FAULT_FALLBACK_PUD);
+		goto out;
+	}
+
+	count_vm_event(THP_FAULT_ALLOC_PUD);
+
+	if (!page)
+		clear_huge_page(new_page, vmf->address, HPAGE_PUD_NR);
+	else
+		copy_user_huge_page(new_page, page, haddr, vma, HPAGE_PUD_NR);
+	__SetPageUptodate(new_page);
+
+	mmu_notifier_range_init(&range, vma->vm_mm, haddr,
+				haddr + HPAGE_PUD_SIZE);
+	mmu_notifier_invalidate_range_start(&range);
+
+	spin_lock(vmf->ptl);
+	if (page)
+		put_page(page);
+	if (unlikely(!pud_same(*vmf->pud, orig_pud))) {
+		spin_unlock(vmf->ptl);
+		mem_cgroup_cancel_charge(new_page, memcg, true);
+		put_page(new_page);
+		goto out_mn;
+	} else {
+		pud_t entry;
+
+		entry = mk_huge_pud(new_page, vma->vm_page_prot);
+		entry = maybe_pud_mkwrite(pud_mkdirty(entry), vma);
+		pudp_huge_clear_flush_notify(vma, haddr, vmf->pud);
+		page_add_new_anon_rmap(new_page, vma, haddr, true);
+		mem_cgroup_commit_charge(new_page, memcg, false, true);
+		lru_cache_add_active_or_unevictable(new_page, vma);
+		set_pud_at(vma->vm_mm, haddr, vmf->pud, entry);
+		update_mmu_cache_pud(vma, vmf->address, vmf->pud);
+		if (!page) {
+			add_mm_counter(vma->vm_mm, MM_ANONPAGES, HPAGE_PUD_NR);
+		} else {
+			VM_BUG_ON_PAGE(!PageHead(page), page);
+			page_remove_rmap(page, true);
+			put_page(page);
+		}
+		ret |= VM_FAULT_WRITE;
+	}
+	spin_unlock(vmf->ptl);
+out_mn:
+	/*
+	 * No need to double call mmu_notifier->invalidate_range() callback as
+	 * the above pmdp_huge_clear_flush_notify() did already call it.
+	 */
+	mmu_notifier_invalidate_range_only_end(&range);
+out:
+	return ret;
+out_unlock:
+	spin_unlock(vmf->ptl);
+	return ret;
+}
+
 #endif /* CONFIG_HAVE_ARCH_TRANSPARENT_HUGEPAGE_PUD */
 
 void huge_pmd_set_accessed(struct vm_fault *vmf, pmd_t orig_pmd)
diff --git a/mm/memory.c b/mm/memory.c
index 177478d5ee47..3608b5436519 100644
--- a/mm/memory.c
+++ b/mm/memory.c
@@ -3722,7 +3722,7 @@ static vm_fault_t wp_huge_pud(struct vm_fault *vmf, pud_t orig_pud)
 #ifdef CONFIG_TRANSPARENT_HUGEPAGE
 	/* No support for anonymous transparent PUD pages yet */
 	if (vma_is_anonymous(vmf->vma))
-		return VM_FAULT_FALLBACK;
+		return do_huge_pud_wp_page(vmf, orig_pud);
 	if (vmf->vma->vm_ops->huge_fault)
 		return vmf->vma->vm_ops->huge_fault(vmf, PE_SIZE_PUD);
 #endif /* CONFIG_TRANSPARENT_HUGEPAGE */
-- 
2.20.1


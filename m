Return-Path: <SRS0=VMr4=QW=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.9 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_PASS,USER_AGENT_GIT autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 9A7DDC43381
	for <linux-mm@archiver.kernel.org>; Fri, 15 Feb 2019 22:10:30 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 2D0B1222D0
	for <linux-mm@archiver.kernel.org>; Fri, 15 Feb 2019 22:10:30 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=sent.com header.i=@sent.com header.b="Kq3tLwQ+";
	dkim=pass (2048-bit key) header.d=messagingengine.com header.i=@messagingengine.com header.b="oeod5Wkj"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 2D0B1222D0
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=sent.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 95C2D8E001D; Fri, 15 Feb 2019 17:09:41 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 8E20D8E0014; Fri, 15 Feb 2019 17:09:41 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 7D9D68E001D; Fri, 15 Feb 2019 17:09:41 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f199.google.com (mail-qt1-f199.google.com [209.85.160.199])
	by kanga.kvack.org (Postfix) with ESMTP id 4CA368E0014
	for <linux-mm@kvack.org>; Fri, 15 Feb 2019 17:09:41 -0500 (EST)
Received: by mail-qt1-f199.google.com with SMTP id 35so10451874qtq.5
        for <linux-mm@kvack.org>; Fri, 15 Feb 2019 14:09:41 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:dkim-signature:from:to:cc:subject
         :date:message-id:in-reply-to:references:reply-to:mime-version
         :content-transfer-encoding;
        bh=HOulFDNFYu4K6/JzIStY0Ib6K58LTjkyep/ybBEhbPw=;
        b=VJE7ffjnPzqbQuh6+P1o8dGFCo9OdfU4ZGwoVyM0nZaWzXMGkrj+8YyvFMiy82Cw6P
         V6JSzLsjWaYFny0j1A+27EIPvvJEnr16kOiUlh1RuqCvdfdsKiQYFYhdVkz+Wq/0q4Kl
         QyVJ/JhFqNZz8FsdRo9ddrUxtum1fruiUMoTkwFin5cRwuBdT8gmIKBBqWF/cAiiNw5f
         1QILTSR0LFZ2fi1r3b3Dp6IK3VcJqU6VIDyfQ5TkyaP9hVBq5Sjqx2CU6IRgA0NuY4Ot
         k2I9gBhqXjy5ULZW7koZE8Re1dDev8VXZcgrox7ajtjz55+YYrvMkRKBGHm3+5wOpbie
         lC/w==
X-Gm-Message-State: AHQUAubqAfIeDCZp0xCuZQ+uJ1Roi4wYbHLB7Oa+lTZ/Tj0TS/wZnIul
	RKSMmqP+/imAfprAm4g/p/Aex7ESIiF7vHtFxEhxWbbf3pg8lsWFjUPcyUmXVLRwcy3mjM2yskU
	GGxqMj8JVLTR9dMKgYnlZD21z9U/gcaJtDSREowvdRrNq3BwD04YJl/BG1CE7zLD8Ww==
X-Received: by 2002:a37:74a:: with SMTP id 71mr8820842qkh.47.1550268580997;
        Fri, 15 Feb 2019 14:09:40 -0800 (PST)
X-Google-Smtp-Source: AHgI3IYoGX7OnfB4dmZJlDT+JqBqrPkfsNR7jWRxJU14u5syACLOKowEotrySRAa+6EQESd0r6AA
X-Received: by 2002:a37:74a:: with SMTP id 71mr8820783qkh.47.1550268579857;
        Fri, 15 Feb 2019 14:09:39 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1550268579; cv=none;
        d=google.com; s=arc-20160816;
        b=sDjnqCpdIi03Ja41OVaIGuTR9j+6ttywSDPhzxJFWEHtvVsc100Br5umKEm+349H/R
         RULQTNVEo+/ordr94Ci7L3aLbpsZWBR48cNV2lTGVHkqSicyiWBSplfxBdnlk6bBeXUR
         ivDrkactgPsn44C72wP4VODR8ocsUh9YBQ/0qXOqxoN/U/pbL9C94Gzam6EejBqO0Tnh
         J6M3cbSCed7sGJtxLiLgfqD0eviX7jctiScZn2+Ujk8W7aiC8Ork1zhlAoEnUTy5y+qX
         3YcFNR8sDswLVx89PbpwnuhqJCsKa8zHCp6GYw9ohsl9z01eWkLmgWx/uDJPzSXhqafC
         fhkQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:reply-to:references
         :in-reply-to:message-id:date:subject:cc:to:from:dkim-signature
         :dkim-signature;
        bh=HOulFDNFYu4K6/JzIStY0Ib6K58LTjkyep/ybBEhbPw=;
        b=ZuBAa5l1M2DZ/udBgVgFq1c1032PLXXzrD/Nq/D4xt/9mKB1oaylnyYYCH57wWFS5z
         hrwRGaUUkLShZCMkb+UuCaVoN/OZ0QqiIG4j2QZL8IIsMMZPAz5XwAx3gh9q8+QKPWoi
         fUWo2GhPZw47QFuWocfEd2n4ntR/jmGGLFzj6lBB5mN8igZ7K1+eodA5jqExiZ8jLSgd
         IC23XrBFWxknIZiLCnpqgot8s2Wo+QzsNZM653Jf06feZMFujA+dgL8Esn3N9GV5e8E9
         puYOsLMpXtYfIrllZJSOykKbhkPrdegNWlK/0Wt33Kh9xum9Fs7t7j5WxwXEGxVh5kM+
         y6cA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@sent.com header.s=fm2 header.b=Kq3tLwQ+;
       dkim=pass header.i=@messagingengine.com header.s=fm2 header.b=oeod5Wkj;
       spf=pass (google.com: domain of zi.yan@sent.com designates 64.147.123.25 as permitted sender) smtp.mailfrom=zi.yan@sent.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=sent.com
Received: from wout2-smtp.messagingengine.com (wout2-smtp.messagingengine.com. [64.147.123.25])
        by mx.google.com with ESMTPS id w12si395424qka.209.2019.02.15.14.09.39
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 15 Feb 2019 14:09:39 -0800 (PST)
Received-SPF: pass (google.com: domain of zi.yan@sent.com designates 64.147.123.25 as permitted sender) client-ip=64.147.123.25;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@sent.com header.s=fm2 header.b=Kq3tLwQ+;
       dkim=pass header.i=@messagingengine.com header.s=fm2 header.b=oeod5Wkj;
       spf=pass (google.com: domain of zi.yan@sent.com designates 64.147.123.25 as permitted sender) smtp.mailfrom=zi.yan@sent.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=sent.com
Received: from compute3.internal (compute3.nyi.internal [10.202.2.43])
	by mailout.west.internal (Postfix) with ESMTP id 198B3329F;
	Fri, 15 Feb 2019 17:09:38 -0500 (EST)
Received: from mailfrontend1 ([10.202.2.162])
  by compute3.internal (MEProxy); Fri, 15 Feb 2019 17:09:38 -0500
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=sent.com; h=from
	:to:cc:subject:date:message-id:in-reply-to:references:reply-to
	:mime-version:content-transfer-encoding; s=fm2; bh=HOulFDNFYu4K6
	/JzIStY0Ib6K58LTjkyep/ybBEhbPw=; b=Kq3tLwQ+1p7rOgUvlAEzqr3U0nUTD
	V47unYDYG/pH+wCKTQm+r4gTnVbWkbXGVbGacKIO2ayKnO+UQDd09Fk/67pv2CTv
	ig2dDSNEpwEOCh+6c1++xfQa/oQCtbn0iazNiG0Lz6TgfJ6ZgJgV4x5W+d2OwVfG
	uQQIy8fnn2hYF4yU1MK4nXneQmQexZpPKaCrzap527CJZ8qZNNQFHq/fSdSF4yUT
	prxVcKmq6VQNEM6TSLgiYmhVRvUna0UxRGyeBEk/sTGU3W2LkekY2cAYA1HzXu2+
	EMrXcz/ywtau3hV9xwiXFwW+t5OaY5OlSGcT2MAxyT1RfJjKB8p+NlKQw==
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=
	messagingengine.com; h=cc:content-transfer-encoding:date:from
	:in-reply-to:message-id:mime-version:references:reply-to:subject
	:to:x-me-proxy:x-me-proxy:x-me-sender:x-me-sender:x-sasl-enc; s=
	fm2; bh=HOulFDNFYu4K6/JzIStY0Ib6K58LTjkyep/ybBEhbPw=; b=oeod5Wkj
	njyO7NIpXsxKStu7/by8XCTq3ciJjewsXPcIuFpDfQtgC6A1LsvahP/tN6okDKDX
	A552YC9glj/afabIa3rUWehu1Jx9Iytfo8GCFs5VMJdWYOWEe/coulMTfL7EydEg
	OYLIHNG3nYaYxbNSFUNrLPx9laWyxrKMaLeHIpp/dhVB0xf+Cn8i9VdJo85M0dud
	n1EZ5CynuS+DWfarDdyQXrovJfCDxVLTi9DXFBXg8aFhturGVu8pwH3AMBfARCTC
	ZaLK8/zWEBX940rYEAJ641xvbPlxuHSA91HGZnprPVfGt93dDJ5fADSV9KP7G57o
	5b+A28WigEOa8A==
X-ME-Sender: <xms:oThnXIcLEjRYQ4ynoevQytpVUZEjdE52w1qOGKLQimExT4n3ib188A>
X-ME-Proxy-Cause: gggruggvucftvghtrhhoucdtuddrgedtledruddtjedgudehkecutefuodetggdotefrod
    ftvfcurfhrohhfihhlvgemucfhrghsthforghilhdpqfhuthenuceurghilhhouhhtmecu
    fedttdenucesvcftvggtihhpihgvnhhtshculddquddttddmnecujfgurhephffvufffkf
    fojghfrhgggfestdekredtredttdenucfhrhhomhepkghiucgjrghnuceoiihirdihrghn
    sehsvghnthdrtghomheqnecukfhppedvudeirddvvdekrdduuddvrddvvdenucfrrghrrg
    hmpehmrghilhhfrhhomhepiihirdihrghnsehsvghnthdrtghomhenucevlhhushhtvghr
    ufhiiigvpedvvd
X-ME-Proxy: <xmx:oThnXOcno7VVLDyH7pQm6tvmDZx9v9wsqU0raGuEP-9LW1iptLkJ6w>
    <xmx:oThnXEh08MiwFMAiVP_DSP-doh-7VJALjGrwwppDIHV23cTKfZAKYg>
    <xmx:oThnXCQ8OUgiwZizqFhk9RpOFg_6JvUimscTVHeE3hx0lHgL3XSWFw>
    <xmx:oThnXGb55cdRLWEV_XIPZN8o08yTfRGWgSHlEdntmhYf4za5nxAoCg>
Received: from nvrsysarch5.nvidia.com (thunderhill.nvidia.com [216.228.112.22])
	by mail.messagingengine.com (Postfix) with ESMTPA id 19DF4E46AB;
	Fri, 15 Feb 2019 17:09:36 -0500 (EST)
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
Subject: [RFC PATCH 26/31] mm: thp: promote PTE-mapped THP to PMD-mapped THP.
Date: Fri, 15 Feb 2019 14:08:51 -0800
Message-Id: <20190215220856.29749-27-zi.yan@sent.com>
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

First promote 512 base pages to a PTE-mapped THP, then promote the
PTE-mapped THP to a PMD-mapped THP.

Signed-off-by: Zi Yan <ziy@nvidia.com>
---
 include/linux/khugepaged.h |   1 +
 mm/filemap.c               |   8 +
 mm/huge_memory.c           | 419 +++++++++++++++++++++++++++++++++++++
 mm/internal.h              |   6 +
 mm/khugepaged.c            |   2 +-
 5 files changed, 435 insertions(+), 1 deletion(-)

diff --git a/include/linux/khugepaged.h b/include/linux/khugepaged.h
index 082d1d2a5216..675c5ee99698 100644
--- a/include/linux/khugepaged.h
+++ b/include/linux/khugepaged.h
@@ -55,6 +55,7 @@ static inline int khugepaged_enter(struct vm_area_struct *vma,
 				return -ENOMEM;
 	return 0;
 }
+void release_pte_pages(pte_t *pte, pte_t *_pte);
 #else /* CONFIG_TRANSPARENT_HUGEPAGE */
 static inline int khugepaged_fork(struct mm_struct *mm, struct mm_struct *oldmm)
 {
diff --git a/mm/filemap.c b/mm/filemap.c
index 9f5e323e883e..54babad945ad 100644
--- a/mm/filemap.c
+++ b/mm/filemap.c
@@ -1236,6 +1236,14 @@ static inline bool clear_bit_unlock_is_negative_byte(long nr, volatile void *mem
 
 #endif
 
+void __unlock_page(struct page *page)
+{
+	BUILD_BUG_ON(PG_waiters != 7);
+	VM_BUG_ON_PAGE(!PageLocked(page), page);
+	if (clear_bit_unlock_is_negative_byte(PG_locked, &page->flags))
+		wake_up_page_bit(page, PG_locked);
+}
+
 /**
  * unlock_page - unlock a locked page
  * @page: the page
diff --git a/mm/huge_memory.c b/mm/huge_memory.c
index fa3e12b17621..f856f7e39095 100644
--- a/mm/huge_memory.c
+++ b/mm/huge_memory.c
@@ -4284,3 +4284,422 @@ void remove_migration_pmd(struct page_vma_mapped_walk *pvmw, struct page *new)
 	update_mmu_cache_pmd(vma, address, pvmw->pmd);
 }
 #endif
+
+/* promote HPAGE_PMD_SIZE range into a PMD map.
+ * mmap_sem needs to be down_write.
+ */
+int promote_huge_pmd_address(struct vm_area_struct *vma, unsigned long haddr)
+{
+	struct mm_struct *mm = vma->vm_mm;
+	pmd_t *pmd, _pmd;
+	pte_t *pte, *_pte;
+	spinlock_t *pmd_ptl, *pte_ptl;
+	struct mmu_notifier_range range;
+	pgtable_t pgtable;
+	struct page *page, *head;
+	unsigned long address = haddr;
+	int ret = -EBUSY;
+
+	VM_BUG_ON(haddr & ~HPAGE_PMD_MASK);
+
+	if (haddr < vma->vm_start || (haddr + HPAGE_PMD_SIZE) > vma->vm_end)
+		return -EINVAL;
+
+	pmd = mm_find_pmd(mm, haddr);
+	if (!pmd || pmd_trans_huge(*pmd))
+		goto out;
+
+	anon_vma_lock_write(vma->anon_vma);
+
+	pte = pte_offset_map(pmd, haddr);
+	pte_ptl = pte_lockptr(mm, pmd);
+
+	head = page = vm_normal_page(vma, haddr, *pte);
+	if (!page || !PageTransCompound(page))
+		goto out_unlock;
+	VM_BUG_ON(page != compound_head(page));
+	lock_page(head);
+
+	mmu_notifier_range_init(&range, mm, haddr, haddr + HPAGE_PMD_SIZE);
+	mmu_notifier_invalidate_range_start(&range);
+	pmd_ptl = pmd_lock(mm, pmd); /* probably unnecessary */
+	/*
+	 * After this gup_fast can't run anymore. This also removes
+	 * any huge TLB entry from the CPU so we won't allow
+	 * huge and small TLB entries for the same virtual address
+	 * to avoid the risk of CPU bugs in that area.
+	 */
+
+	_pmd = pmdp_collapse_flush(vma, haddr, pmd);
+	spin_unlock(pmd_ptl);
+	mmu_notifier_invalidate_range_end(&range);
+
+	/* remove ptes */
+	for (_pte = pte; _pte < pte + HPAGE_PMD_NR;
+				_pte++, page++, address += PAGE_SIZE) {
+		pte_t pteval = *_pte;
+
+		if (pte_none(pteval) || is_zero_pfn(pte_pfn(pteval))) {
+			pr_err("pte none or zero pfn during pmd promotion\n");
+			if (is_zero_pfn(pte_pfn(pteval))) {
+				/*
+				 * ptl mostly unnecessary.
+				 */
+				spin_lock(pte_ptl);
+				/*
+				 * paravirt calls inside pte_clear here are
+				 * superfluous.
+				 */
+				pte_clear(vma->vm_mm, address, _pte);
+				spin_unlock(pte_ptl);
+			}
+		} else {
+			/*
+			 * ptl mostly unnecessary, but preempt has to
+			 * be disabled to update the per-cpu stats
+			 * inside page_remove_rmap().
+			 */
+			spin_lock(pte_ptl);
+			/*
+			 * paravirt calls inside pte_clear here are
+			 * superfluous.
+			 */
+			pte_clear(vma->vm_mm, address, _pte);
+			atomic_dec(&page->_mapcount);
+			/*page_remove_rmap(page, false, 0);*/
+			if (atomic_read(&page->_mapcount) > -1) {
+				SetPageDoubleMap(head);
+				pr_info("page double mapped");
+			}
+			spin_unlock(pte_ptl);
+		}
+	}
+	page_ref_sub(head, HPAGE_PMD_NR - 1);
+
+	pte_unmap(pte);
+	pgtable = pmd_pgtable(_pmd);
+
+	_pmd = mk_huge_pmd(head, vma->vm_page_prot);
+	_pmd = maybe_pmd_mkwrite(pmd_mkdirty(_pmd), vma);
+
+	/*
+	 * spin_lock() below is not the equivalent of smp_wmb(), so
+	 * this is needed to avoid the copy_huge_page writes to become
+	 * visible after the set_pmd_at() write.
+	 */
+	smp_wmb();
+
+	spin_lock(pmd_ptl);
+	VM_BUG_ON(!pmd_none(*pmd));
+	atomic_inc(compound_mapcount_ptr(head));
+	__inc_node_page_state(head, NR_ANON_THPS);
+	pgtable_trans_huge_deposit(mm, pmd, pgtable);
+	set_pmd_at(mm, haddr, pmd, _pmd);
+	update_mmu_cache_pmd(vma, haddr, pmd);
+	spin_unlock(pmd_ptl);
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
+static bool can_promote_huge_page(struct page *page)
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
+/* write a __promote_huge_page_isolate(struct vm_area_struct *vma,
+ * unsigned long address, pte_t *pte) to isolate all subpages into a list,
+ * then call promote_list_to_huge_page() to promote in-place
+ */
+
+static int __promote_huge_page_isolate(struct vm_area_struct *vma,
+					unsigned long haddr, pte_t *pte,
+					struct page **head, struct list_head *subpage_list)
+{
+	struct page *page = NULL;
+	pte_t *_pte;
+	bool writable = false;
+	unsigned long address = haddr;
+
+	*head = NULL;
+	lru_add_drain();
+	for (_pte = pte; _pte < pte+HPAGE_PMD_NR;
+	     _pte++, address += PAGE_SIZE) {
+		pte_t pteval = *_pte;
+
+		if (pte_none(pteval) || (pte_present(pteval) &&
+				is_zero_pfn(pte_pfn(pteval))))
+			goto out;
+		if (!pte_present(pteval))
+			goto out;
+		page = vm_normal_page(vma, address, pteval);
+		if (unlikely(!page))
+			goto out;
+
+		if (address == haddr) {
+			*head = page;
+			if (page_to_pfn(page) & ((1<<HPAGE_PMD_ORDER) - 1))
+				goto out;
+		}
+
+		if ((*head + (address - haddr)/PAGE_SIZE) != page)
+			goto out;
+
+		if (PageCompound(page))
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
+		if (pte_write(pteval)) {
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
+		inc_node_page_state(page,
+				NR_ISOLATED_ANON + page_is_file_cache(page));
+		VM_BUG_ON_PAGE(!PageLocked(page), page);
+		VM_BUG_ON_PAGE(PageLRU(page), page);
+	}
+	if (likely(writable)) {
+		int i;
+
+		for (i = 0; i < HPAGE_PMD_NR; i++) {
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
+	release_pte_pages(pte, _pte);
+	return 0;
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
+int promote_list_to_huge_page(struct page *head, struct list_head *list)
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
+	} else
+		return -EBUSY;
+
+	/* Racy check each subpage to see if any has extra pin */
+	list_for_each_entry(subpage, list, lru) {
+		if (can_promote_huge_page(subpage))
+			bitmap_set(subpage_bitmap, subpage - head, 1);
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
+
+		if (PageAnon(subpage))
+			ttu_flags |= TTU_SPLIT_FREEZE;
+
+		unmap_success = try_to_unmap(subpage, ttu_flags);
+		VM_BUG_ON_PAGE(!unmap_success, subpage);
+	}
+
+	/* Take care of migration wait list:
+	 * make compound page first, since it is impossible to move waiting
+	 * process from subpage queues to the head page queue.
+	 */
+	set_compound_page_dtor(head, COMPOUND_PAGE_DTOR);
+	set_compound_order(head, HPAGE_PMD_ORDER);
+	__SetPageHead(head);
+	for (i = 1; i < HPAGE_PMD_NR; i++) {
+		struct page *p = head + i;
+
+		p->index = 0;
+		p->mapping = TAIL_MAPPING;
+		p->mem_cgroup = NULL;
+		ClearPageActive(p);
+		/* move subpage refcount to head page */
+		page_ref_add(head, page_count(p) - 1);
+		set_page_count(p, 0);
+		set_compound_head(p, head);
+	}
+	atomic_set(compound_mapcount_ptr(head), -1);
+	prep_transhuge_page(head);
+
+	remap_page(head);
+
+	if (!mem_cgroup_disabled())
+		mod_memcg_state(head->mem_cgroup, MEMCG_RSS_HUGE, HPAGE_PMD_NR);
+
+	for (i = 1; i < HPAGE_PMD_NR; i++) {
+		struct page *subpage = head + i;
+		__unlock_page(subpage);
+	}
+
+	INIT_LIST_HEAD(&head->lru);
+	unlock_page(head);
+	putback_lru_page(head);
+
+	mod_node_page_state(page_pgdat(head),
+			NR_ISOLATED_ANON + page_is_file_cache(head), -HPAGE_PMD_NR);
+out_unlock:
+	if (anon_vma) {
+		anon_vma_unlock_write(anon_vma);
+		put_anon_vma(anon_vma);
+	}
+out:
+	return ret;
+}
+
+static int promote_huge_page_isolate(struct vm_area_struct *vma,
+					unsigned long haddr,
+					struct page **head, struct list_head *subpage_list)
+{
+	struct mm_struct *mm = vma->vm_mm;
+	pmd_t *pmd;
+	pte_t *pte;
+	spinlock_t *pte_ptl;
+	int ret = -EBUSY;
+
+	pmd = mm_find_pmd(mm, haddr);
+	if (!pmd || pmd_trans_huge(*pmd))
+		goto out;
+
+	anon_vma_lock_write(vma->anon_vma);
+
+	pte = pte_offset_map(pmd, haddr);
+	pte_ptl = pte_lockptr(mm, pmd);
+
+	spin_lock(pte_ptl);
+	ret = __promote_huge_page_isolate(vma, haddr, pte, head, subpage_list);
+	spin_unlock(pte_ptl);
+
+	if (unlikely(!ret)) {
+		pte_unmap(pte);
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
+/* assume mmap_sem is down_write, wrapper for madvise */
+int promote_huge_page_address(struct vm_area_struct *vma, unsigned long haddr)
+{
+	LIST_HEAD(subpage_list);
+	struct page *head;
+
+	if (haddr & (HPAGE_PMD_SIZE - 1))
+		return -EINVAL;
+
+	if (haddr < vma->vm_start || (haddr + HPAGE_PMD_SIZE) > vma->vm_end)
+		return -EINVAL;
+
+	if (promote_huge_page_isolate(vma, haddr, &head, &subpage_list))
+		return -EBUSY;
+
+	return promote_list_to_huge_page(head, &subpage_list);
+}
diff --git a/mm/internal.h b/mm/internal.h
index 70a6ef603e5b..c5e5a0f1cc58 100644
--- a/mm/internal.h
+++ b/mm/internal.h
@@ -581,4 +581,10 @@ int expand_free_page(struct zone *zone, struct page *buddy_head,
 void prep_new_page(struct page *page, unsigned int order, gfp_t gfp_flags,
 							unsigned int alloc_flags);
 
+void __unlock_page(struct page *page);
+
+int promote_huge_pmd_address(struct vm_area_struct *vma, unsigned long haddr);
+
+int promote_huge_page_address(struct vm_area_struct *vma, unsigned long haddr);
+
 #endif	/* __MM_INTERNAL_H */
diff --git a/mm/khugepaged.c b/mm/khugepaged.c
index 3acfddcba714..ff059353ebc3 100644
--- a/mm/khugepaged.c
+++ b/mm/khugepaged.c
@@ -508,7 +508,7 @@ static void release_pte_page(struct page *page)
 	putback_lru_page(page);
 }
 
-static void release_pte_pages(pte_t *pte, pte_t *_pte)
+void release_pte_pages(pte_t *pte, pte_t *_pte)
 {
 	while (--_pte >= pte) {
 		pte_t pteval = *_pte;
-- 
2.20.1


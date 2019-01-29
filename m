Return-Path: <SRS0=Ydgi=QF=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 758E3C169C4
	for <linux-mm@archiver.kernel.org>; Tue, 29 Jan 2019 16:55:01 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 0C8FC2175B
	for <linux-mm@archiver.kernel.org>; Tue, 29 Jan 2019 16:55:01 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 0C8FC2175B
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 254918E000A; Tue, 29 Jan 2019 11:54:53 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 2086B8E0008; Tue, 29 Jan 2019 11:54:53 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 056E38E000A; Tue, 29 Jan 2019 11:54:53 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f199.google.com (mail-qt1-f199.google.com [209.85.160.199])
	by kanga.kvack.org (Postfix) with ESMTP id CDF4E8E0008
	for <linux-mm@kvack.org>; Tue, 29 Jan 2019 11:54:52 -0500 (EST)
Received: by mail-qt1-f199.google.com with SMTP id n50so25446901qtb.9
        for <linux-mm@kvack.org>; Tue, 29 Jan 2019 08:54:52 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=tJ4kFBT5/PoC5R6rCwqTGnIldGPFFgCmYxq4Ju4J1I8=;
        b=ORYF6Zjxywlp8zfl6Od47Id6C09jD39uj0Br+HbawqVPjTyFOsDM/e9ecgpeJKNXZI
         X1LQO/yMQHeBk8+mZKR0ZggalW5rr0TBCWumQk17ogoXAjYc6EnpU5czs4EPswxDIsfW
         hy86rE4KMwtdil1qQ2Iw8++j+PiddR2A2U7T9Uh7+gjEbzt5BiiT+kPrG4sv9qX9DJw2
         G5kJe84fafpSsZpLbXUhB3G8nHWDbftLnwiaZMYoPfgeI/b8sXKM8CsLPc7QQDS9QqmS
         e5Z2FLTJGE3cmZp0d49WSTUTKrJVphglPtKSjowYNv6RVG+m/JV/AjeYkVIQtGG6PBvQ
         Of5A==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jglisse@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: AJcUuke5nCZDrsd/LgCNu0u7cm9gFmVpS+I/u/mY80KbIpzKYlKFBxRF
	xA+rxNLBNz5q0rzRU6UwNsUGzAPpfLQc5IRUDN6vxQGzPhYP5RiZ57aqz7QRNdyzVLgHixOanHR
	jOK/E5Dh0dAAyaw9KkCZxM7a47TD2denGcbcTqSDvXNvGbOg6+ZeYeV6ayPSQMSFsSA==
X-Received: by 2002:aed:2fc4:: with SMTP id m62mr25126403qtd.8.1548780892602;
        Tue, 29 Jan 2019 08:54:52 -0800 (PST)
X-Google-Smtp-Source: ALg8bN7EckU2meyofUz7Wi65GwvAkWLVwClt/KJSzr0QEg1zwZMRj/StbydZyQpNCMmnK2siXfwJ
X-Received: by 2002:aed:2fc4:: with SMTP id m62mr25126364qtd.8.1548780891883;
        Tue, 29 Jan 2019 08:54:51 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1548780891; cv=none;
        d=google.com; s=arc-20160816;
        b=iaoFvlrvpFtnOlq3BduTIAJLJAm8P92FUnmm4jZ/CtO17Gg068eBxeS2eCdzkM8z8Q
         tG5daFVVv0JN11XjZzqCeb92j/AffRjC8cv0YJRLBkfWJsTkYyqIbasE1OobuVuVOlD0
         tcyfEfzJfq9LjL1+g7O9dhs6khj1KJJvnM3vwVxCoEPI4EEiLihjBfC5e51kE3jODVU8
         pYHLePpQ63KbHo4TaMnjzcNtIbQY5HGOHNR7fe2aE/ieMRQfbQp0y//brzRrYovsJhKi
         hnWtKXWE9CByX9i3ZxBcugyUsPpcq6arxMAp9SQahY8iq2BKhIV+EW8/HLsMWkCDcns/
         3y+A==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from;
        bh=tJ4kFBT5/PoC5R6rCwqTGnIldGPFFgCmYxq4Ju4J1I8=;
        b=s7r0hDAhdpcx25dQTObgMwSwY8yfpmnu0LiQM/e/fj6+nJ3tLbMgIn8Sq/kd43b44l
         9rqRomGAg0PwDrwvhMUFO6rSiYU52TtnteoRoirK4OGcwusUhOU40ABuZyytKeM+M/Yz
         tPOWrR/XiyhsKQdCgDVIbcBfniFcVfSOQez8vAatEGeg2DEA+KgOFnJTb2gLZ3DYtXHc
         QDjYXVj/xn4a6Pla9dM3R2Ru02NTbShinZ/ZoR6CwhW8NkMeGbjZEtcarYGicf5kXPok
         pc2rLCeBt0xzk75FxSqbWXu8Opgdv3FdTT2Hjaa1ubvZMVl51Sc+M1ALJdnzu3Dd5OK7
         uKYQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jglisse@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id 88si3177158qte.245.2019.01.29.08.54.51
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 29 Jan 2019 08:54:51 -0800 (PST)
Received-SPF: pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jglisse@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx07.intmail.prod.int.phx2.redhat.com [10.5.11.22])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id 13C377D0E0;
	Tue, 29 Jan 2019 16:54:51 +0000 (UTC)
Received: from localhost.localdomain.com (ovpn-122-2.rdu2.redhat.com [10.10.122.2])
	by smtp.corp.redhat.com (Postfix) with ESMTP id 3DE881048105;
	Tue, 29 Jan 2019 16:54:48 +0000 (UTC)
From: jglisse@redhat.com
To: linux-mm@kvack.org
Cc: linux-kernel@vger.kernel.org,
	=?UTF-8?q?J=C3=A9r=C3=B4me=20Glisse?= <jglisse@redhat.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	Ralph Campbell <rcampbell@nvidia.com>,
	John Hubbard <jhubbard@nvidia.com>
Subject: [PATCH 08/10] mm/hmm: support hugetlbfs (snap shoting, faulting and DMA mapping)
Date: Tue, 29 Jan 2019 11:54:26 -0500
Message-Id: <20190129165428.3931-9-jglisse@redhat.com>
In-Reply-To: <20190129165428.3931-1-jglisse@redhat.com>
References: <20190129165428.3931-1-jglisse@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
X-Scanned-By: MIMEDefang 2.84 on 10.5.11.22
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.26]); Tue, 29 Jan 2019 16:54:51 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

From: Jérôme Glisse <jglisse@redhat.com>

This adds support for hugetlbfs so that HMM user can map mirror range
of virtual address back by hugetlbfs. Note that now the range allows
user to optimize DMA mapping of such page so that we can map a huge
page as one chunk.

Signed-off-by: Jérôme Glisse <jglisse@redhat.com>
Cc: Andrew Morton <akpm@linux-foundation.org>
Cc: Ralph Campbell <rcampbell@nvidia.com>
Cc: John Hubbard <jhubbard@nvidia.com>
---
 include/linux/hmm.h |  29 ++++++++-
 mm/hmm.c            | 141 +++++++++++++++++++++++++++++++++++++-------
 2 files changed, 147 insertions(+), 23 deletions(-)

diff --git a/include/linux/hmm.h b/include/linux/hmm.h
index fc3630d0bbfd..b3850297352f 100644
--- a/include/linux/hmm.h
+++ b/include/linux/hmm.h
@@ -181,10 +181,31 @@ struct hmm_range {
 	const uint64_t		*values;
 	uint64_t		default_flags;
 	uint64_t		pfn_flags_mask;
+	uint8_t			page_shift;
 	uint8_t			pfn_shift;
 	bool			valid;
 };
 
+/*
+ * hmm_range_page_shift() - return the page shift for the range
+ * @range: range being queried
+ * Returns: page shift (page size = 1 << page shift) for the range
+ */
+static inline unsigned hmm_range_page_shift(const struct hmm_range *range)
+{
+	return range->page_shift;
+}
+
+/*
+ * hmm_range_page_size() - return the page size for the range
+ * @range: range being queried
+ * Returns: page size for the range in bytes
+ */
+static inline unsigned long hmm_range_page_size(const struct hmm_range *range)
+{
+	return 1UL << hmm_range_page_shift(range);
+}
+
 /*
  * hmm_range_wait_until_valid() - wait for range to be valid
  * @range: range affected by invalidation to wait on
@@ -438,7 +459,7 @@ void hmm_mirror_unregister(struct hmm_mirror *mirror);
  *          struct hmm_range range;
  *          ...
  *
- *          ret = hmm_range_register(&range, mm, start, end);
+ *          ret = hmm_range_register(&range, mm, start, end, page_shift);
  *          if (ret)
  *              return ret;
  *
@@ -498,7 +519,8 @@ void hmm_mirror_unregister(struct hmm_mirror *mirror);
 int hmm_range_register(struct hmm_range *range,
 		       struct mm_struct *mm,
 		       unsigned long start,
-		       unsigned long end);
+		       unsigned long end,
+		       unsigned page_shift);
 void hmm_range_unregister(struct hmm_range *range);
 long hmm_range_snapshot(struct hmm_range *range);
 long hmm_range_fault(struct hmm_range *range, bool block);
@@ -538,7 +560,8 @@ static inline int hmm_vma_fault(struct hmm_range *range, bool block)
 	range->pfn_flags_mask = -1UL;
 
 	ret = hmm_range_register(range, range->vma->vm_mm,
-				 range->start, range->end);
+				 range->start, range->end,
+				 PAGE_SHIFT);
 	if (ret)
 		return (int)ret;
 
diff --git a/mm/hmm.c b/mm/hmm.c
index 9cd68334a759..8b87e1813313 100644
--- a/mm/hmm.c
+++ b/mm/hmm.c
@@ -396,11 +396,13 @@ static int hmm_vma_walk_hole_(unsigned long addr, unsigned long end,
 	struct hmm_vma_walk *hmm_vma_walk = walk->private;
 	struct hmm_range *range = hmm_vma_walk->range;
 	uint64_t *pfns = range->pfns;
-	unsigned long i;
+	unsigned long i, page_size;
 
 	hmm_vma_walk->last = addr;
-	i = (addr - range->start) >> PAGE_SHIFT;
-	for (; addr < end; addr += PAGE_SIZE, i++) {
+	page_size = 1UL << range->page_shift;
+	i = (addr - range->start) >> range->page_shift;
+
+	for (; addr < end; addr += page_size, i++) {
 		pfns[i] = range->values[HMM_PFN_NONE];
 		if (fault || write_fault) {
 			int ret;
@@ -712,6 +714,69 @@ static int hmm_vma_walk_pmd(pmd_t *pmdp,
 	return 0;
 }
 
+static int hmm_vma_walk_hugetlb_entry(pte_t *pte, unsigned long hmask,
+				      unsigned long start, unsigned long end,
+				      struct mm_walk *walk)
+{
+#ifdef CONFIG_HUGETLB_PAGE
+	unsigned long addr = start, i, pfn, mask, size, pfn_inc;
+	struct hmm_vma_walk *hmm_vma_walk = walk->private;
+	struct hmm_range *range = hmm_vma_walk->range;
+	struct vm_area_struct *vma = walk->vma;
+	struct hstate *h = hstate_vma(vma);
+	uint64_t orig_pfn, cpu_flags;
+	bool fault, write_fault;
+	spinlock_t *ptl;
+	pte_t entry;
+	int ret = 0;
+
+	size = 1UL << huge_page_shift(h);
+	mask = size - 1;
+	if (range->page_shift != PAGE_SHIFT) {
+		/* Make sure we are looking at full page. */
+		if (start & mask)
+			return -EINVAL;
+		if (end < (start + size))
+			return -EINVAL;
+		pfn_inc = size >> PAGE_SHIFT;
+	} else {
+		pfn_inc = 1;
+		size = PAGE_SIZE;
+	}
+
+
+	ptl = huge_pte_lock(hstate_vma(walk->vma), walk->mm, pte);
+	entry = huge_ptep_get(pte);
+
+	i = (start - range->start) >> range->page_shift;
+	orig_pfn = range->pfns[i];
+	range->pfns[i] = range->values[HMM_PFN_NONE];
+	cpu_flags = pte_to_hmm_pfn_flags(range, entry);
+	fault = write_fault = false;
+	hmm_pte_need_fault(hmm_vma_walk, orig_pfn, cpu_flags,
+			   &fault, &write_fault);
+	if (fault || write_fault) {
+		ret = -ENOENT;
+		goto unlock;
+	}
+
+	pfn = pte_pfn(entry) + (start & mask);
+	for (; addr < end; addr += size, i++, pfn += pfn_inc)
+		range->pfns[i] = hmm_pfn_from_pfn(range, pfn) | cpu_flags;
+	hmm_vma_walk->last = end;
+
+unlock:
+	spin_unlock(ptl);
+
+	if (ret == -ENOENT)
+		return hmm_vma_walk_hole_(addr, end, fault, write_fault, walk);
+
+	return ret;
+#else /* CONFIG_HUGETLB_PAGE */
+	return -EINVAL;
+#endif
+}
+
 static void hmm_pfns_clear(struct hmm_range *range,
 			   uint64_t *pfns,
 			   unsigned long addr,
@@ -735,6 +800,7 @@ static void hmm_pfns_special(struct hmm_range *range)
  * @mm: the mm struct for the range of virtual address
  * @start: start virtual address (inclusive)
  * @end: end virtual address (exclusive)
+ * @page_shift: expect page shift for the range
  * Returns 0 on success, -EFAULT if the address space is no longer valid
  *
  * Track updates to the CPU page table see include/linux/hmm.h
@@ -742,15 +808,22 @@ static void hmm_pfns_special(struct hmm_range *range)
 int hmm_range_register(struct hmm_range *range,
 		       struct mm_struct *mm,
 		       unsigned long start,
-		       unsigned long end)
+		       unsigned long end,
+		       unsigned page_shift)
 {
-	range->start = start & PAGE_MASK;
-	range->end = end & PAGE_MASK;
+	unsigned long mask = ((1UL << page_shift) - 1UL);
+
 	range->valid = false;
 	range->hmm = NULL;
 
-	if (range->start >= range->end)
+	if ((start & mask) || (end & mask))
 		return -EINVAL;
+	if (start >= end)
+		return -EINVAL;
+
+	range->page_shift = page_shift;
+	range->start = start;
+	range->end = end;
 
 	range->hmm = hmm_register(mm);
 	if (!range->hmm)
@@ -818,6 +891,7 @@ EXPORT_SYMBOL(hmm_range_unregister);
  */
 long hmm_range_snapshot(struct hmm_range *range)
 {
+	const unsigned long device_vma = VM_IO | VM_PFNMAP | VM_MIXEDMAP;
 	unsigned long start = range->start, end;
 	struct hmm_vma_walk hmm_vma_walk;
 	struct hmm *hmm = range->hmm;
@@ -834,15 +908,26 @@ long hmm_range_snapshot(struct hmm_range *range)
 			return -EAGAIN;
 
 		vma = find_vma(hmm->mm, start);
-		if (vma == NULL || (vma->vm_flags & VM_SPECIAL))
+		if (vma == NULL || (vma->vm_flags & device_vma))
 			return -EFAULT;
 
-		/* FIXME support hugetlb fs/dax */
-		if (is_vm_hugetlb_page(vma) || vma_is_dax(vma)) {
+		/* FIXME support dax */
+		if (vma_is_dax(vma)) {
 			hmm_pfns_special(range);
 			return -EINVAL;
 		}
 
+		if (is_vm_hugetlb_page(vma)) {
+			struct hstate *h = hstate_vma(vma);
+
+			if (huge_page_shift(h) != range->page_shift &&
+			    range->page_shift != PAGE_SHIFT)
+				return -EINVAL;
+		} else {
+			if (range->page_shift != PAGE_SHIFT)
+				return -EINVAL;
+		}
+
 		if (!(vma->vm_flags & VM_READ)) {
 			/*
 			 * If vma do not allow read access, then assume that it
@@ -868,6 +953,7 @@ long hmm_range_snapshot(struct hmm_range *range)
 		mm_walk.hugetlb_entry = NULL;
 		mm_walk.pmd_entry = hmm_vma_walk_pmd;
 		mm_walk.pte_hole = hmm_vma_walk_hole;
+		mm_walk.hugetlb_entry = hmm_vma_walk_hugetlb_entry;
 
 		walk_page_range(start, end, &mm_walk);
 		start = end;
@@ -909,6 +995,7 @@ EXPORT_SYMBOL(hmm_range_snapshot);
  */
 long hmm_range_fault(struct hmm_range *range, bool block)
 {
+	const unsigned long device_vma = VM_IO | VM_PFNMAP | VM_MIXEDMAP;
 	unsigned long start = range->start, end;
 	struct hmm_vma_walk hmm_vma_walk;
 	struct hmm *hmm = range->hmm;
@@ -928,15 +1015,26 @@ long hmm_range_fault(struct hmm_range *range, bool block)
 		}
 
 		vma = find_vma(hmm->mm, start);
-		if (vma == NULL || (vma->vm_flags & VM_SPECIAL))
+		if (vma == NULL || (vma->vm_flags & device_vma))
 			return -EFAULT;
 
-		/* FIXME support hugetlb fs/dax */
-		if (is_vm_hugetlb_page(vma) || vma_is_dax(vma)) {
+		/* FIXME support dax */
+		if (vma_is_dax(vma)) {
 			hmm_pfns_special(range);
 			return -EINVAL;
 		}
 
+		if (is_vm_hugetlb_page(vma)) {
+			struct hstate *h = hstate_vma(vma);
+
+			if (huge_page_shift(h) != range->page_shift &&
+			    range->page_shift != PAGE_SHIFT)
+				return -EINVAL;
+		} else {
+			if (range->page_shift != PAGE_SHIFT)
+				return -EINVAL;
+		}
+
 		if (!(vma->vm_flags & VM_READ)) {
 			/*
 			 * If vma do not allow read access, then assume that it
@@ -963,6 +1061,7 @@ long hmm_range_fault(struct hmm_range *range, bool block)
 		mm_walk.hugetlb_entry = NULL;
 		mm_walk.pmd_entry = hmm_vma_walk_pmd;
 		mm_walk.pte_hole = hmm_vma_walk_hole;
+		mm_walk.hugetlb_entry = hmm_vma_walk_hugetlb_entry;
 
 		do {
 			ret = walk_page_range(start, end, &mm_walk);
@@ -1003,14 +1102,15 @@ long hmm_range_dma_map(struct hmm_range *range,
 		       dma_addr_t *daddrs,
 		       bool block)
 {
-	unsigned long i, npages, mapped;
+	unsigned long i, npages, mapped, page_size;
 	long ret;
 
 	ret = hmm_range_fault(range, block);
 	if (ret <= 0)
 		return ret ? ret : -EBUSY;
 
-	npages = (range->end - range->start) >> PAGE_SHIFT;
+	page_size = hmm_range_page_size(range);
+	npages = (range->end - range->start) >> range->page_shift;
 	for (i = 0, mapped = 0; i < npages; ++i) {
 		enum dma_data_direction dir = DMA_FROM_DEVICE;
 		struct page *page;
@@ -1039,7 +1139,7 @@ long hmm_range_dma_map(struct hmm_range *range,
 		if (range->pfns[i] & range->values[HMM_PFN_WRITE])
 			dir = DMA_BIDIRECTIONAL;
 
-		daddrs[i] = dma_map_page(device, page, 0, PAGE_SIZE, dir);
+		daddrs[i] = dma_map_page(device, page, 0, page_size, dir);
 		if (dma_mapping_error(device, daddrs[i])) {
 			ret = -EFAULT;
 			goto unmap;
@@ -1066,7 +1166,7 @@ long hmm_range_dma_map(struct hmm_range *range,
 		if (range->pfns[i] & range->values[HMM_PFN_WRITE])
 			dir = DMA_BIDIRECTIONAL;
 
-		dma_unmap_page(device, daddrs[i], PAGE_SIZE, dir);
+		dma_unmap_page(device, daddrs[i], page_size, dir);
 		mapped--;
 	}
 
@@ -1094,7 +1194,7 @@ long hmm_range_dma_unmap(struct hmm_range *range,
 			 dma_addr_t *daddrs,
 			 bool dirty)
 {
-	unsigned long i, npages;
+	unsigned long i, npages, page_size;
 	long cpages = 0;
 
 	/* Sanity check. */
@@ -1105,7 +1205,8 @@ long hmm_range_dma_unmap(struct hmm_range *range,
 	if (!range->pfns)
 		return -EINVAL;
 
-	npages = (range->end - range->start) >> PAGE_SHIFT;
+	page_size = hmm_range_page_size(range);
+	npages = (range->end - range->start) >> range->page_shift;
 	for (i = 0; i < npages; ++i) {
 		enum dma_data_direction dir = DMA_FROM_DEVICE;
 		struct page *page;
@@ -1127,7 +1228,7 @@ long hmm_range_dma_unmap(struct hmm_range *range,
 		}
 
 		/* Unmap and clear pfns/dma address */
-		dma_unmap_page(device, daddrs[i], PAGE_SIZE, dir);
+		dma_unmap_page(device, daddrs[i], page_size, dir);
 		range->pfns[i] = range->values[HMM_PFN_NONE];
 		/* FIXME see comments in hmm_vma_dma_map() */
 		daddrs[i] = 0;
-- 
2.17.2


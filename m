Return-Path: <SRS0=RIH8=R4=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,URIBL_BLOCKED
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 67DDBC10F06
	for <linux-mm@archiver.kernel.org>; Mon, 25 Mar 2019 14:40:44 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 11CD12087C
	for <linux-mm@archiver.kernel.org>; Mon, 25 Mar 2019 14:40:44 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 11CD12087C
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 64E0A6B0269; Mon, 25 Mar 2019 10:40:23 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 5D5E96B026A; Mon, 25 Mar 2019 10:40:23 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 400026B026B; Mon, 25 Mar 2019 10:40:23 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f199.google.com (mail-qt1-f199.google.com [209.85.160.199])
	by kanga.kvack.org (Postfix) with ESMTP id 16CA56B0269
	for <linux-mm@kvack.org>; Mon, 25 Mar 2019 10:40:23 -0400 (EDT)
Received: by mail-qt1-f199.google.com with SMTP id d49so10317656qtk.8
        for <linux-mm@kvack.org>; Mon, 25 Mar 2019 07:40:23 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=yPsEqCCThZ59tsHvaH8tH7RPC6kh++zybcKk5Kp6i4k=;
        b=afKQfemjhZjaPj+kWe+cE9DFOuHlJ507KoTEZJc0obGU5u2Dzu1w82PTOrWRw0VkJj
         3nqSEi0vpUoWQu1ylTfdzO2g5TBmBfk0uJtldPzTbjNmpgP0W89rUIucknBGfVZ8F+ym
         EYDygi2txr0XbHIWVtQtVp3fl9YB9VV3xvJKdhZ86KsDTM8kFmP8QjztjXixaUZlMvlM
         JvBKQSf9oFaLEWQBc41kzdgNvai6xSQDz9hZ0wX6VemJux5C5bkNtl0c8Tt/3cnfH43x
         Xu2ceOzgZ54K8OQAMVSqzmnkgmld9ikQJaqW0lGNBqK+YugoGewsWsMR3xQs+jbQRX4V
         S7hQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jglisse@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: APjAAAWRYmMgPRorwNel+fNulWkko5BVPnj3KW3bq9NPvq/M4o0QvhA6
	Hd9noU+OXklEK/UqYDemxL9Kw9pORn65HIh96wWP/sIBtkYR5urMFUsFGMVNMrIsDjNNI7szZlH
	yQh84vRI4hJOLmSfubZWDsstiCXF0bCwEXsJetbGVPHpfyIEjty8AJinvLFvapn7Zyw==
X-Received: by 2002:a37:4c08:: with SMTP id z8mr19791732qka.32.1553524822806;
        Mon, 25 Mar 2019 07:40:22 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzaAFFuJqmfwhN/EKFNOsKS1S7qa2BtWtdgrL11E0tq9Q/S5njFDMNH0AThvIsyOSQEUmxp
X-Received: by 2002:a37:4c08:: with SMTP id z8mr19791677qka.32.1553524821988;
        Mon, 25 Mar 2019 07:40:21 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1553524821; cv=none;
        d=google.com; s=arc-20160816;
        b=lmfuP4wWyUycMM5lRCW9JADR+Dmt75R5miL7vc3q7m84uSfVuhH4oJ1JBvWdsGwE8b
         m9ep1A5ZM4tlkS7ZDFO3tH3C3SNkFQHixhXC06fwADBjBNRK/06wHx7t8IEmCL0OJ8CI
         Fj5JyIefKazS0nTOCWNY/B+AYeTrDPb0obxc1NNNR+tYGXFXJxyhPtYdYCeCR1jdfFk6
         dJeUXYFEEk2Pl5Tyo3ZoaqLimkYTNvRRZCFI77wFSmc1q0M40yt5ux2DdiP2az1WpDfc
         9otsUIi9G8pTjOXJ8M6+/FS77AV26AP+xCdx2h+2dChvWmxgBr9zldymgN+igAFeSwhH
         psyg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from;
        bh=yPsEqCCThZ59tsHvaH8tH7RPC6kh++zybcKk5Kp6i4k=;
        b=YLO4948TNBPig4vFUr5n51ySDG4X+/0LcYBE/KIKf9jBLvB3VXMF/kGH1Tv0JzLl72
         8f4PPjA/MCqGnQyxZppmzJOIcfO5fJmho/n+0sCyDew+OZFNT5VPpV1yLB6tMY542ByK
         FIFSn1HDJW8fodmjPgrPUDJfdR9i4aP/aMODp6bgioTm+501N7pyurPZ+5o6uRxV2zc1
         2kCO8RTZgFVMicIRii+AhSIyvtJgOZOdKTUZOszcdGCt3GDCvqHQOoo9EKhrZxZFWxd+
         MM+2+cWn7moGC8K6QUXJMcnbW58fi27FC1r9SeWCIGkzCgeVllA758yfiYi/kfn7SX9W
         A3KA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jglisse@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id u17si1476612qvm.77.2019.03.25.07.40.21
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 25 Mar 2019 07:40:21 -0700 (PDT)
Received-SPF: pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jglisse@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx07.intmail.prod.int.phx2.redhat.com [10.5.11.22])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id 2598F3092641;
	Mon, 25 Mar 2019 14:40:21 +0000 (UTC)
Received: from localhost.localdomain.com (unknown [10.20.6.236])
	by smtp.corp.redhat.com (Postfix) with ESMTP id 616EF100164A;
	Mon, 25 Mar 2019 14:40:20 +0000 (UTC)
From: jglisse@redhat.com
To: linux-mm@kvack.org
Cc: linux-kernel@vger.kernel.org,
	=?UTF-8?q?J=C3=A9r=C3=B4me=20Glisse?= <jglisse@redhat.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	John Hubbard <jhubbard@nvidia.com>,
	Dan Williams <dan.j.williams@intel.com>,
	Arnd Bergmann <arnd@arndb.de>
Subject: [PATCH v2 08/11] mm/hmm: mirror hugetlbfs (snapshoting, faulting and DMA mapping) v2
Date: Mon, 25 Mar 2019 10:40:08 -0400
Message-Id: <20190325144011.10560-9-jglisse@redhat.com>
In-Reply-To: <20190325144011.10560-1-jglisse@redhat.com>
References: <20190325144011.10560-1-jglisse@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
X-Scanned-By: MIMEDefang 2.84 on 10.5.11.22
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.43]); Mon, 25 Mar 2019 14:40:21 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

From: Jérôme Glisse <jglisse@redhat.com>

HMM mirror is a device driver helpers to mirror range of virtual address.
It means that the process jobs running on the device can access the same
virtual address as the CPU threads of that process. This patch adds support
for hugetlbfs mapping (ie range of virtual address that are mmap of a
hugetlbfs).

Changes since v1:
    - improved commit message
    - squashed: Arnd Bergmann: fix unused variable warnings

Signed-off-by: Jérôme Glisse <jglisse@redhat.com>
Reviewed-by: Ralph Campbell <rcampbell@nvidia.com>
Cc: Andrew Morton <akpm@linux-foundation.org>
Cc: John Hubbard <jhubbard@nvidia.com>
Cc: Dan Williams <dan.j.williams@intel.com>
Cc: Arnd Bergmann <arnd@arndb.de>
---
 include/linux/hmm.h |  29 ++++++++--
 mm/hmm.c            | 126 +++++++++++++++++++++++++++++++++++++++-----
 2 files changed, 138 insertions(+), 17 deletions(-)

diff --git a/include/linux/hmm.h b/include/linux/hmm.h
index 13bc2c72f791..f3b919b04eda 100644
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
@@ -529,7 +551,8 @@ static inline int hmm_vma_fault(struct hmm_range *range, bool block)
 	range->pfn_flags_mask = -1UL;
 
 	ret = hmm_range_register(range, range->vma->vm_mm,
-				 range->start, range->end);
+				 range->start, range->end,
+				 PAGE_SHIFT);
 	if (ret)
 		return (int)ret;
 
diff --git a/mm/hmm.c b/mm/hmm.c
index 4fe88a196d17..64a33770813b 100644
--- a/mm/hmm.c
+++ b/mm/hmm.c
@@ -387,11 +387,13 @@ static int hmm_vma_walk_hole_(unsigned long addr, unsigned long end,
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
@@ -703,6 +705,69 @@ static int hmm_vma_walk_pmd(pmd_t *pmdp,
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
@@ -726,6 +791,7 @@ static void hmm_pfns_special(struct hmm_range *range)
  * @mm: the mm struct for the range of virtual address
  * @start: start virtual address (inclusive)
  * @end: end virtual address (exclusive)
+ * @page_shift: expect page shift for the range
  * Returns 0 on success, -EFAULT if the address space is no longer valid
  *
  * Track updates to the CPU page table see include/linux/hmm.h
@@ -733,16 +799,23 @@ static void hmm_pfns_special(struct hmm_range *range)
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
+		return -EINVAL;
+	if (start >= end)
 		return -EINVAL;
 
+	range->page_shift = page_shift;
+	range->start = start;
+	range->end = end;
+
 	range->hmm = hmm_register(mm);
 	if (!range->hmm)
 		return -EFAULT;
@@ -809,6 +882,7 @@ EXPORT_SYMBOL(hmm_range_unregister);
  */
 long hmm_range_snapshot(struct hmm_range *range)
 {
+	const unsigned long device_vma = VM_IO | VM_PFNMAP | VM_MIXEDMAP;
 	unsigned long start = range->start, end;
 	struct hmm_vma_walk hmm_vma_walk;
 	struct hmm *hmm = range->hmm;
@@ -825,15 +899,26 @@ long hmm_range_snapshot(struct hmm_range *range)
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
@@ -859,6 +944,7 @@ long hmm_range_snapshot(struct hmm_range *range)
 		mm_walk.hugetlb_entry = NULL;
 		mm_walk.pmd_entry = hmm_vma_walk_pmd;
 		mm_walk.pte_hole = hmm_vma_walk_hole;
+		mm_walk.hugetlb_entry = hmm_vma_walk_hugetlb_entry;
 
 		walk_page_range(start, end, &mm_walk);
 		start = end;
@@ -877,7 +963,7 @@ EXPORT_SYMBOL(hmm_range_snapshot);
  *          then one of the following values may be returned:
  *
  *           -EINVAL  invalid arguments or mm or virtual address are in an
- *                    invalid vma (ie either hugetlbfs or device file vma).
+ *                    invalid vma (for instance device file vma).
  *           -ENOMEM: Out of memory.
  *           -EPERM:  Invalid permission (for instance asking for write and
  *                    range is read only).
@@ -898,6 +984,7 @@ EXPORT_SYMBOL(hmm_range_snapshot);
  */
 long hmm_range_fault(struct hmm_range *range, bool block)
 {
+	const unsigned long device_vma = VM_IO | VM_PFNMAP | VM_MIXEDMAP;
 	unsigned long start = range->start, end;
 	struct hmm_vma_walk hmm_vma_walk;
 	struct hmm *hmm = range->hmm;
@@ -917,15 +1004,25 @@ long hmm_range_fault(struct hmm_range *range, bool block)
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
+			if (huge_page_shift(hstate_vma(vma)) !=
+			    range->page_shift &&
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
@@ -952,6 +1049,7 @@ long hmm_range_fault(struct hmm_range *range, bool block)
 		mm_walk.hugetlb_entry = NULL;
 		mm_walk.pmd_entry = hmm_vma_walk_pmd;
 		mm_walk.pte_hole = hmm_vma_walk_hole;
+		mm_walk.hugetlb_entry = hmm_vma_walk_hugetlb_entry;
 
 		do {
 			ret = walk_page_range(start, end, &mm_walk);
-- 
2.17.2


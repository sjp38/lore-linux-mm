Return-Path: <SRS0=Ydgi=QF=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 435CEC169C4
	for <linux-mm@archiver.kernel.org>; Tue, 29 Jan 2019 16:55:04 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id F246220989
	for <linux-mm@archiver.kernel.org>; Tue, 29 Jan 2019 16:55:03 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org F246220989
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 58C018E000B; Tue, 29 Jan 2019 11:54:54 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 4F67D8E0008; Tue, 29 Jan 2019 11:54:54 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 3BB908E000B; Tue, 29 Jan 2019 11:54:54 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f198.google.com (mail-qt1-f198.google.com [209.85.160.198])
	by kanga.kvack.org (Postfix) with ESMTP id 0813D8E0008
	for <linux-mm@kvack.org>; Tue, 29 Jan 2019 11:54:54 -0500 (EST)
Received: by mail-qt1-f198.google.com with SMTP id w19so25441401qto.13
        for <linux-mm@kvack.org>; Tue, 29 Jan 2019 08:54:54 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=jHBmS4L3HjyWCkFWfDYs5jEZanpbacxsAkCpSGTqldM=;
        b=Io7LY9GNplDeC8BGMIA9qgheP4vXBJL8cOfUtI1ZJDUgnFw/xTUzM86e4gVdMjepIt
         lm2WlNAJBQjSpH5KQc4iMW5gZgtIrJRXGYkEzwYmTCtO0dxDWfMFVI7yGZwVvKWNHPJI
         JK2JkgTm5CWGbXeh/n+F8BI3BK+sZoLPCtIxusg3UnuUNzq+tZsw+wlUB3x/qIvNe3+F
         h0zMF32ks8HzrBuzM408+ObdFhUulWK5uEPKZ8zP8mpYbef+i8b/9IzCFSOHmqJu4HVg
         cnUOWg20Ul0ic4cEm9D8az4Tt6DIKEcyNRLW68JQxcEW9oP2w0gVh4H6G0mPua9wSYrd
         /36g==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jglisse@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: AJcUukdACP7m0V3QPwc5eNshE3HWqsNGTv+v8bKKs6MlDViFa6DpO901
	15/ztB7LNdISxy3vFFl6ckbW1yShThJOehvJnCeZC2QPF5qf7zQuQyEtef+rPR1t909Hol8asp0
	amnZbHhwgcN/tQDMVaEVAzKzOG1z1hh1mG9HQ5VZ1KDXCjKPnsAPM0v2cDnGumlQB8Q==
X-Received: by 2002:aed:202e:: with SMTP id 43mr26986379qta.27.1548780893791;
        Tue, 29 Jan 2019 08:54:53 -0800 (PST)
X-Google-Smtp-Source: ALg8bN6y6nhLw5U6dJd35uYP/B4BMrD/1MQvxYOM/mQ//hmoZnQIU5D1hveRv29SrDM40OWhcEEf
X-Received: by 2002:aed:202e:: with SMTP id 43mr26986353qta.27.1548780893310;
        Tue, 29 Jan 2019 08:54:53 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1548780893; cv=none;
        d=google.com; s=arc-20160816;
        b=AyEKlF9DBUayYsw1yZNd9Q6l6MiFA3QOFB/juwztm8pX0IkJjmEJ1ehccloMaCjGyg
         DJ+DUWJogjrLSXsMk/syMa0KG43ONv8aoTnKUbRulcsEpryoCXrS/+0PeTk31AHZ2F2P
         9fxvgw0crmt7hL6OEA/rri8UQhSHZ3LgYPLtNZ09lcj0U1taIhMTQYIwPlOwkG1QbVCN
         O7dcoJEkol3MzKVZRvCGgkQojzCYZNArNuO4pTt5bEgBjCPPokYWCzg/fd5ws8leystm
         AKW8OkDk8wjv0N+R9ORgi2kfiGmvqUSUIjMX8TGqF/W8IwlBx8rR9Rx43tz4S1i98A+F
         8RzQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from;
        bh=jHBmS4L3HjyWCkFWfDYs5jEZanpbacxsAkCpSGTqldM=;
        b=I/Y0CMUp7AAUALf7YGJXNJh4afw9ueh8R+P9hfbZJJGn2h3LnYp8XhpYKP+UOByngL
         x/QGaj2swXoTdFS//0GFzjeQINmSTqfS07ceXxv20htVf1e80gK1kxBQwXHSY4802yuj
         vSTXdx76Xbtsk9VJpm+Lsg89O429D7k9rJpF+68DbGabtw/lFlgmJVmN5ENWfySL3Gwk
         P1LUGMezy6CnHUW0DaQad8sQekXrXatYCUI39h3RJwZw4EMwLhd2HXZLaecmWd9TNPER
         RmjBv1Bxnc9Q2h1vGgj2ch2hKio4eKrlrwvD/COWGWapvCY7uJYKUtX9MKcatGYy2uzX
         3S7w==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jglisse@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id q11si3617032qkc.214.2019.01.29.08.54.53
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 29 Jan 2019 08:54:53 -0800 (PST)
Received-SPF: pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jglisse@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx07.intmail.prod.int.phx2.redhat.com [10.5.11.22])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id 689D9BDD0;
	Tue, 29 Jan 2019 16:54:52 +0000 (UTC)
Received: from localhost.localdomain.com (ovpn-122-2.rdu2.redhat.com [10.10.122.2])
	by smtp.corp.redhat.com (Postfix) with ESMTP id 43770102BCEB;
	Tue, 29 Jan 2019 16:54:51 +0000 (UTC)
From: jglisse@redhat.com
To: linux-mm@kvack.org
Cc: linux-kernel@vger.kernel.org,
	=?UTF-8?q?J=C3=A9r=C3=B4me=20Glisse?= <jglisse@redhat.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	Dan Williams <dan.j.williams@intel.com>,
	Ralph Campbell <rcampbell@nvidia.com>,
	John Hubbard <jhubbard@nvidia.com>
Subject: [PATCH 09/10] mm/hmm: allow to mirror vma of a file on a DAX backed filesystem
Date: Tue, 29 Jan 2019 11:54:27 -0500
Message-Id: <20190129165428.3931-10-jglisse@redhat.com>
In-Reply-To: <20190129165428.3931-1-jglisse@redhat.com>
References: <20190129165428.3931-1-jglisse@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
X-Scanned-By: MIMEDefang 2.84 on 10.5.11.22
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.29]); Tue, 29 Jan 2019 16:54:52 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

From: Jérôme Glisse <jglisse@redhat.com>

This add support to mirror vma which is an mmap of a file which is on
a filesystem that using a DAX block device. There is no reason not to
support that case.

Note that unlike GUP code we do not take page reference hence when we
back-off we have nothing to undo.

Signed-off-by: Jérôme Glisse <jglisse@redhat.com>
Cc: Andrew Morton <akpm@linux-foundation.org>
Cc: Dan Williams <dan.j.williams@intel.com>
Cc: Ralph Campbell <rcampbell@nvidia.com>
Cc: John Hubbard <jhubbard@nvidia.com>
---
 mm/hmm.c | 133 ++++++++++++++++++++++++++++++++++++++++++++++---------
 1 file changed, 112 insertions(+), 21 deletions(-)

diff --git a/mm/hmm.c b/mm/hmm.c
index 8b87e1813313..1a444885404e 100644
--- a/mm/hmm.c
+++ b/mm/hmm.c
@@ -334,6 +334,7 @@ EXPORT_SYMBOL(hmm_mirror_unregister);
 
 struct hmm_vma_walk {
 	struct hmm_range	*range;
+	struct dev_pagemap	*pgmap;
 	unsigned long		last;
 	bool			fault;
 	bool			block;
@@ -508,6 +509,15 @@ static inline uint64_t pmd_to_hmm_pfn_flags(struct hmm_range *range, pmd_t pmd)
 				range->flags[HMM_PFN_VALID];
 }
 
+static inline uint64_t pud_to_hmm_pfn_flags(struct hmm_range *range, pud_t pud)
+{
+	if (!pud_present(pud))
+		return 0;
+	return pud_write(pud) ? range->flags[HMM_PFN_VALID] |
+				range->flags[HMM_PFN_WRITE] :
+				range->flags[HMM_PFN_VALID];
+}
+
 static int hmm_vma_handle_pmd(struct mm_walk *walk,
 			      unsigned long addr,
 			      unsigned long end,
@@ -529,8 +539,19 @@ static int hmm_vma_handle_pmd(struct mm_walk *walk,
 		return hmm_vma_walk_hole_(addr, end, fault, write_fault, walk);
 
 	pfn = pmd_pfn(pmd) + pte_index(addr);
-	for (i = 0; addr < end; addr += PAGE_SIZE, i++, pfn++)
+	for (i = 0; addr < end; addr += PAGE_SIZE, i++, pfn++) {
+		if (pmd_devmap(pmd)) {
+			hmm_vma_walk->pgmap = get_dev_pagemap(pfn,
+					      hmm_vma_walk->pgmap);
+			if (unlikely(!hmm_vma_walk->pgmap))
+				return -EBUSY;
+		}
 		pfns[i] = hmm_pfn_from_pfn(range, pfn) | cpu_flags;
+	}
+	if (hmm_vma_walk->pgmap) {
+		put_dev_pagemap(hmm_vma_walk->pgmap);
+		hmm_vma_walk->pgmap = NULL;
+	}
 	hmm_vma_walk->last = end;
 	return 0;
 }
@@ -617,10 +638,24 @@ static int hmm_vma_handle_pte(struct mm_walk *walk, unsigned long addr,
 	if (fault || write_fault)
 		goto fault;
 
+	if (pte_devmap(pte)) {
+		hmm_vma_walk->pgmap = get_dev_pagemap(pte_pfn(pte),
+					      hmm_vma_walk->pgmap);
+		if (unlikely(!hmm_vma_walk->pgmap))
+			return -EBUSY;
+	} else if (IS_ENABLED(CONFIG_ARCH_HAS_PTE_SPECIAL) && pte_special(pte)) {
+		*pfn = range->values[HMM_PFN_SPECIAL];
+		return -EFAULT;
+	}
+
 	*pfn = hmm_pfn_from_pfn(range, pte_pfn(pte)) | cpu_flags;
 	return 0;
 
 fault:
+	if (hmm_vma_walk->pgmap) {
+		put_dev_pagemap(hmm_vma_walk->pgmap);
+		hmm_vma_walk->pgmap = NULL;
+	}
 	pte_unmap(ptep);
 	/* Fault any virtual address we were asked to fault */
 	return hmm_vma_walk_hole_(addr, end, fault, write_fault, walk);
@@ -708,12 +743,84 @@ static int hmm_vma_walk_pmd(pmd_t *pmdp,
 			return r;
 		}
 	}
+	if (hmm_vma_walk->pgmap) {
+		put_dev_pagemap(hmm_vma_walk->pgmap);
+		hmm_vma_walk->pgmap = NULL;
+	}
 	pte_unmap(ptep - 1);
 
 	hmm_vma_walk->last = addr;
 	return 0;
 }
 
+static int hmm_vma_walk_pud(pud_t *pudp,
+			    unsigned long start,
+			    unsigned long end,
+			    struct mm_walk *walk)
+{
+	struct hmm_vma_walk *hmm_vma_walk = walk->private;
+	struct hmm_range *range = hmm_vma_walk->range;
+	struct vm_area_struct *vma = walk->vma;
+	unsigned long addr = start, next;
+	pmd_t *pmdp;
+	pud_t pud;
+	int ret;
+
+again:
+	pud = READ_ONCE(*pudp);
+	if (pud_none(pud))
+		return hmm_vma_walk_hole(start, end, walk);
+
+	if (pud_huge(pud) && pud_devmap(pud)) {
+		unsigned long i, npages, pfn;
+		uint64_t *pfns, cpu_flags;
+		bool fault, write_fault;
+
+		if (!pud_present(pud))
+			return hmm_vma_walk_hole(start, end, walk);
+
+		i = (addr - range->start) >> PAGE_SHIFT;
+		npages = (end - addr) >> PAGE_SHIFT;
+		pfns = &range->pfns[i];
+
+		cpu_flags = pud_to_hmm_pfn_flags(range, pud);
+		hmm_range_need_fault(hmm_vma_walk, pfns, npages,
+				     cpu_flags, &fault, &write_fault);
+		if (fault || write_fault)
+			return hmm_vma_walk_hole_(addr, end, fault,
+						write_fault, walk);
+
+		pfn = pud_pfn(pud) + ((addr & ~PUD_MASK) >> PAGE_SHIFT);
+		for (i = 0; i < npages; ++i, ++pfn) {
+			hmm_vma_walk->pgmap = get_dev_pagemap(pfn,
+					      hmm_vma_walk->pgmap);
+			if (unlikely(!hmm_vma_walk->pgmap))
+				return -EBUSY;
+			pfns[i] = hmm_pfn_from_pfn(range, pfn) | cpu_flags;
+		}
+		if (hmm_vma_walk->pgmap) {
+			put_dev_pagemap(hmm_vma_walk->pgmap);
+			hmm_vma_walk->pgmap = NULL;
+		}
+		hmm_vma_walk->last = end;
+		return 0;
+	}
+
+	split_huge_pud(vma, pudp, addr);
+	if (pud_none(*pudp))
+		goto again;
+
+	pmdp = pmd_offset(pudp, addr);
+	do {
+		next = pmd_addr_end(addr, end);
+		ret = hmm_vma_walk_pmd(pmdp, addr, next, walk);
+		if (ret)
+			return ret;
+	} while (pmdp++, addr = next, addr != end);
+
+	return 0;
+}
+
 static int hmm_vma_walk_hugetlb_entry(pte_t *pte, unsigned long hmask,
 				      unsigned long start, unsigned long end,
 				      struct mm_walk *walk)
@@ -786,14 +893,6 @@ static void hmm_pfns_clear(struct hmm_range *range,
 		*pfns = range->values[HMM_PFN_NONE];
 }
 
-static void hmm_pfns_special(struct hmm_range *range)
-{
-	unsigned long addr = range->start, i = 0;
-
-	for (; addr < range->end; addr += PAGE_SIZE, i++)
-		range->pfns[i] = range->values[HMM_PFN_SPECIAL];
-}
-
 /*
  * hmm_range_register() - start tracking change to CPU page table over a range
  * @range: range
@@ -911,12 +1010,6 @@ long hmm_range_snapshot(struct hmm_range *range)
 		if (vma == NULL || (vma->vm_flags & device_vma))
 			return -EFAULT;
 
-		/* FIXME support dax */
-		if (vma_is_dax(vma)) {
-			hmm_pfns_special(range);
-			return -EINVAL;
-		}
-
 		if (is_vm_hugetlb_page(vma)) {
 			struct hstate *h = hstate_vma(vma);
 
@@ -940,6 +1033,7 @@ long hmm_range_snapshot(struct hmm_range *range)
 		}
 
 		range->vma = vma;
+		hmm_vma_walk.pgmap = NULL;
 		hmm_vma_walk.last = start;
 		hmm_vma_walk.fault = false;
 		hmm_vma_walk.range = range;
@@ -951,6 +1045,7 @@ long hmm_range_snapshot(struct hmm_range *range)
 		mm_walk.pte_entry = NULL;
 		mm_walk.test_walk = NULL;
 		mm_walk.hugetlb_entry = NULL;
+		mm_walk.pud_entry = hmm_vma_walk_pud;
 		mm_walk.pmd_entry = hmm_vma_walk_pmd;
 		mm_walk.pte_hole = hmm_vma_walk_hole;
 		mm_walk.hugetlb_entry = hmm_vma_walk_hugetlb_entry;
@@ -1018,12 +1113,6 @@ long hmm_range_fault(struct hmm_range *range, bool block)
 		if (vma == NULL || (vma->vm_flags & device_vma))
 			return -EFAULT;
 
-		/* FIXME support dax */
-		if (vma_is_dax(vma)) {
-			hmm_pfns_special(range);
-			return -EINVAL;
-		}
-
 		if (is_vm_hugetlb_page(vma)) {
 			struct hstate *h = hstate_vma(vma);
 
@@ -1047,6 +1136,7 @@ long hmm_range_fault(struct hmm_range *range, bool block)
 		}
 
 		range->vma = vma;
+		hmm_vma_walk.pgmap = NULL;
 		hmm_vma_walk.last = start;
 		hmm_vma_walk.fault = true;
 		hmm_vma_walk.block = block;
@@ -1059,6 +1149,7 @@ long hmm_range_fault(struct hmm_range *range, bool block)
 		mm_walk.pte_entry = NULL;
 		mm_walk.test_walk = NULL;
 		mm_walk.hugetlb_entry = NULL;
+		mm_walk.pud_entry = hmm_vma_walk_pud;
 		mm_walk.pmd_entry = hmm_vma_walk_pmd;
 		mm_walk.pte_hole = hmm_vma_walk_hole;
 		mm_walk.hugetlb_entry = hmm_vma_walk_hugetlb_entry;
-- 
2.17.2


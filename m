Return-Path: <SRS0=RIH8=R4=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id A7CD5C43381
	for <linux-mm@archiver.kernel.org>; Mon, 25 Mar 2019 14:40:48 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 55AC82087C
	for <linux-mm@archiver.kernel.org>; Mon, 25 Mar 2019 14:40:48 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 55AC82087C
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 36C3B6B026A; Mon, 25 Mar 2019 10:40:24 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 2EDCB6B026B; Mon, 25 Mar 2019 10:40:24 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 11D676B026C; Mon, 25 Mar 2019 10:40:24 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f197.google.com (mail-qt1-f197.google.com [209.85.160.197])
	by kanga.kvack.org (Postfix) with ESMTP id D8DF36B026A
	for <linux-mm@kvack.org>; Mon, 25 Mar 2019 10:40:23 -0400 (EDT)
Received: by mail-qt1-f197.google.com with SMTP id t22so9880809qtc.13
        for <linux-mm@kvack.org>; Mon, 25 Mar 2019 07:40:23 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=omd/FHaKWfRUxUYh143eh+Ou5RpsvJY2kGVkaQZxymU=;
        b=CRfANYj29hvp2pb7GZrb+LjnUnVV+GHNZ3x26EBJiuT/8poB78EbY5+wo1+YMrtreA
         27edHXE4mpTI0VjZFg7xEOjia1ttKSiVac4zpJKq9RzUitbWiCU5pX1t2zZmOKvUB6xG
         XvZa3OO+ynxWsQoyM0e3fbKddxahLagSW4H9tIfRWxcZv1OoQWaEFDLWRJaXT1mRQvUq
         4ObNydS/gzbsqEDwL1l2nUEUF9jnwIK8Kb3UnvHqaZYeEFlT66eJ+emvjZRWp6/EQK2B
         t56Mnsa1GB/MV8wLpJVO9Ta8dqSLyY77LNjS+E8lJru77da8Z9RQu4fr1Bl8YEqx4SQR
         paxA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jglisse@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: APjAAAX3j2pXO4dks7HBzenRVSKBzDnI6W7ZgYHFkn81ugl9Qty62NGz
	Fi3vzwT9xs/rdlVerq3TKkH4pcIe2CgOVTWQ1rYeybSvSLWDkd8PRrCThFmZ1OjZgP9ioaCcbZk
	nCEtRtDHaNHBvEUI6MmNcGEQsf8pYqg3/v58iJWomcEd02ThxPVniWIOhMBFHUKVygQ==
X-Received: by 2002:a0c:d4a2:: with SMTP id u31mr8581885qvh.139.1553524823604;
        Mon, 25 Mar 2019 07:40:23 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyZJLr3jjXb5MlA2DoTYeXRlZn4SXziHvU74vjAM4DdkycW58zGSgfu+wVryZxUm37J00hL
X-Received: by 2002:a0c:d4a2:: with SMTP id u31mr8581824qvh.139.1553524822873;
        Mon, 25 Mar 2019 07:40:22 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1553524822; cv=none;
        d=google.com; s=arc-20160816;
        b=fOOSCKB7bAS4RZ8hpCQg/gwdU1FdKFBh1ZLOw+4dEm051bSAi7ZbMSUp3ORl7Oou0M
         ZkausWV+wIXXnQ81DITNxX2135aGxobylhU7f1iJFDL5k9idi9TezXg0eJ5xLNVnuZbL
         AvnpF9TqFUznNLdnghtn1AbAv3Fq3LnadyK+Aqhe4ly4WAYv6maIR+3jWKf5Roiu/14R
         0RvDh8gC5B2e6wMj1U6UAB9In/reQ0RYCjPAJd/5F8JoVUkwg49eQzBN3ztQpewodlte
         N/ITk/nske6Tg4XaSXMzZ3dOlNRyZROtO/j6uyLwL+cIqdUxdcb+KUIJtor2eKk1JaR0
         Y/4A==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from;
        bh=omd/FHaKWfRUxUYh143eh+Ou5RpsvJY2kGVkaQZxymU=;
        b=lA7E/SARL77PgqX5p6zc/tzvzVQvBLFQ03asCGeq85AYqYZvP8MlO204RvBKjhMsDm
         TGyZLIOkzGxwkh78NqnkC7bZYIK0Pxeq3xuGtVVUw9ZpawhLtbTV6Ul20ZeFQ84cfAaN
         GQ9+H89Nwtd38rFt34fgXBw5iYA3vlTdKQq2rcR1s/JbdwgIF0JCupQc/bo5biH6fown
         A4FnhEek9Pmlb536HKsoDePJvWybdRO6nmaW5k3LO3ez4tcW695uPv9yXVREFcH+PwZY
         YrjG/vUiDwy4CBdE5ys1YSFhbU4/yMJq0F9Jqmd6OsrIz+jgnZWknH2aMyd0iUANVqmz
         xqjg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jglisse@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id t29si1293834qvc.4.2019.03.25.07.40.22
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 25 Mar 2019 07:40:22 -0700 (PDT)
Received-SPF: pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jglisse@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx07.intmail.prod.int.phx2.redhat.com [10.5.11.22])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id 0CA2866964;
	Mon, 25 Mar 2019 14:40:22 +0000 (UTC)
Received: from localhost.localdomain.com (unknown [10.20.6.236])
	by smtp.corp.redhat.com (Postfix) with ESMTP id 443361001DC8;
	Mon, 25 Mar 2019 14:40:21 +0000 (UTC)
From: jglisse@redhat.com
To: linux-mm@kvack.org
Cc: linux-kernel@vger.kernel.org,
	=?UTF-8?q?J=C3=A9r=C3=B4me=20Glisse?= <jglisse@redhat.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	Dan Williams <dan.j.williams@intel.com>,
	John Hubbard <jhubbard@nvidia.com>,
	Arnd Bergmann <arnd@arndb.de>
Subject: [PATCH v2 09/11] mm/hmm: allow to mirror vma of a file on a DAX backed filesystem v2
Date: Mon, 25 Mar 2019 10:40:09 -0400
Message-Id: <20190325144011.10560-10-jglisse@redhat.com>
In-Reply-To: <20190325144011.10560-1-jglisse@redhat.com>
References: <20190325144011.10560-1-jglisse@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
X-Scanned-By: MIMEDefang 2.84 on 10.5.11.22
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.38]); Mon, 25 Mar 2019 14:40:22 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

From: Jérôme Glisse <jglisse@redhat.com>

HMM mirror is a device driver helpers to mirror range of virtual address.
It means that the process jobs running on the device can access the same
virtual address as the CPU threads of that process. This patch adds support
for mirroring mapping of file that are on a DAX block device (ie range of
virtual address that is an mmap of a file in a filesystem on a DAX block
device). There is no reason to not support such case when mirroring virtual
address on a device.

Note that unlike GUP code we do not take page reference hence when we
back-off we have nothing to undo.

Changes since v1:
    - improved commit message
    - squashed: Arnd Bergmann: fix unused variable warning in hmm_vma_walk_pud

Signed-off-by: Jérôme Glisse <jglisse@redhat.com>
Reviewed-by: Ralph Campbell <rcampbell@nvidia.com>
Cc: Andrew Morton <akpm@linux-foundation.org>
Cc: Dan Williams <dan.j.williams@intel.com>
Cc: John Hubbard <jhubbard@nvidia.com>
Cc: Arnd Bergmann <arnd@arndb.de>
---
 mm/hmm.c | 132 ++++++++++++++++++++++++++++++++++++++++++++++---------
 1 file changed, 111 insertions(+), 21 deletions(-)

diff --git a/mm/hmm.c b/mm/hmm.c
index 64a33770813b..ce33151c6832 100644
--- a/mm/hmm.c
+++ b/mm/hmm.c
@@ -325,6 +325,7 @@ EXPORT_SYMBOL(hmm_mirror_unregister);
 
 struct hmm_vma_walk {
 	struct hmm_range	*range;
+	struct dev_pagemap	*pgmap;
 	unsigned long		last;
 	bool			fault;
 	bool			block;
@@ -499,6 +500,15 @@ static inline uint64_t pmd_to_hmm_pfn_flags(struct hmm_range *range, pmd_t pmd)
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
@@ -520,8 +530,19 @@ static int hmm_vma_handle_pmd(struct mm_walk *walk,
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
@@ -608,10 +629,24 @@ static int hmm_vma_handle_pte(struct mm_walk *walk, unsigned long addr,
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
@@ -699,12 +734,83 @@ static int hmm_vma_walk_pmd(pmd_t *pmdp,
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
+	split_huge_pud(walk->vma, pudp, addr);
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
@@ -777,14 +883,6 @@ static void hmm_pfns_clear(struct hmm_range *range,
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
@@ -902,12 +1000,6 @@ long hmm_range_snapshot(struct hmm_range *range)
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
 
@@ -931,6 +1023,7 @@ long hmm_range_snapshot(struct hmm_range *range)
 		}
 
 		range->vma = vma;
+		hmm_vma_walk.pgmap = NULL;
 		hmm_vma_walk.last = start;
 		hmm_vma_walk.fault = false;
 		hmm_vma_walk.range = range;
@@ -942,6 +1035,7 @@ long hmm_range_snapshot(struct hmm_range *range)
 		mm_walk.pte_entry = NULL;
 		mm_walk.test_walk = NULL;
 		mm_walk.hugetlb_entry = NULL;
+		mm_walk.pud_entry = hmm_vma_walk_pud;
 		mm_walk.pmd_entry = hmm_vma_walk_pmd;
 		mm_walk.pte_hole = hmm_vma_walk_hole;
 		mm_walk.hugetlb_entry = hmm_vma_walk_hugetlb_entry;
@@ -1007,12 +1101,6 @@ long hmm_range_fault(struct hmm_range *range, bool block)
 		if (vma == NULL || (vma->vm_flags & device_vma))
 			return -EFAULT;
 
-		/* FIXME support dax */
-		if (vma_is_dax(vma)) {
-			hmm_pfns_special(range);
-			return -EINVAL;
-		}
-
 		if (is_vm_hugetlb_page(vma)) {
 			if (huge_page_shift(hstate_vma(vma)) !=
 			    range->page_shift &&
@@ -1035,6 +1123,7 @@ long hmm_range_fault(struct hmm_range *range, bool block)
 		}
 
 		range->vma = vma;
+		hmm_vma_walk.pgmap = NULL;
 		hmm_vma_walk.last = start;
 		hmm_vma_walk.fault = true;
 		hmm_vma_walk.block = block;
@@ -1047,6 +1136,7 @@ long hmm_range_fault(struct hmm_range *range, bool block)
 		mm_walk.pte_entry = NULL;
 		mm_walk.test_walk = NULL;
 		mm_walk.hugetlb_entry = NULL;
+		mm_walk.pud_entry = hmm_vma_walk_pud;
 		mm_walk.pmd_entry = hmm_vma_walk_pmd;
 		mm_walk.pte_hole = hmm_vma_walk_hole;
 		mm_walk.hugetlb_entry = hmm_vma_walk_hugetlb_entry;
-- 
2.17.2


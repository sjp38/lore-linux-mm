Return-Path: <SRS0=DmM3=SF=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,URIBL_BLOCKED
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id A73DBC10F06
	for <linux-mm@archiver.kernel.org>; Wed,  3 Apr 2019 19:33:57 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 4CBAA2084B
	for <linux-mm@archiver.kernel.org>; Wed,  3 Apr 2019 19:33:57 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 4CBAA2084B
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id DFCE96B0272; Wed,  3 Apr 2019 15:33:42 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id DAFD56B0274; Wed,  3 Apr 2019 15:33:42 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id BFF426B0275; Wed,  3 Apr 2019 15:33:42 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f197.google.com (mail-qt1-f197.google.com [209.85.160.197])
	by kanga.kvack.org (Postfix) with ESMTP id 977486B0272
	for <linux-mm@kvack.org>; Wed,  3 Apr 2019 15:33:42 -0400 (EDT)
Received: by mail-qt1-f197.google.com with SMTP id k13so93072qtc.23
        for <linux-mm@kvack.org>; Wed, 03 Apr 2019 12:33:42 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=CfljN/CbOV6Fry9g92TnFDy7qc8FAxA2gGSJjNt1zCk=;
        b=YBSXAaG4ikiHAKe693twmbp20V9vEHEZPNZOiSb8dyE+b07zP5uJ080ahtmSMFNXFR
         jJqeN4xfIdNKuVVm/FzulGdPmvEfFk5Vb69yDO1gIb/S619/8rtH0qRwBA+yQIq72pmG
         uaA8JrHcXLkqnhGyjvUBCquqDvqbYxmfh5P1X80VL1wg65uzky+3Mg4wv+XFLt8YUsCl
         ccJ62cWmA3U9xNwYsKXvx0CfgAwca0QPHHMvh/T0OQABu9Tb7AqqK6zqKTUbQ2UkZXsu
         ujwWXKC3Ktlm0rB+msPNwW/u6AlDlbQH4r4K/kWNHOvIgoSXv4LvcPtS2HjQ9/WtQ6Pb
         uawg==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jglisse@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: APjAAAVlLk6qSMkQjWwZ9XnGgxNcRbf3QHwZG6IdRMm8wQMcojaayz1i
	EOQA9K2GB8r2GE4IwOYPBOdfbcnEsGfewHKQRj0gpny1oth69bOcE2NlSf5Ph/dv8ws297sX+Xg
	I5y9lHJoZFpCcFXKn8XOaH3AkCNEoITU7Fal7KE4Hlg75FK3BVYdOYjnXPfmkkNROWQ==
X-Received: by 2002:a37:a546:: with SMTP id o67mr1661624qke.134.1554320022375;
        Wed, 03 Apr 2019 12:33:42 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwwL/ExUm2pXhGLmccdI17TDSNkoS9ZfuQHALWo2tI42TPzgdn+p3exEs8Pa4jDLxePpk0K
X-Received: by 2002:a37:a546:: with SMTP id o67mr1661574qke.134.1554320021626;
        Wed, 03 Apr 2019 12:33:41 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1554320021; cv=none;
        d=google.com; s=arc-20160816;
        b=ofMIXS5IzHTVOePTVQiHBAgzwxKYhfv7v8yIYUSxteHFRWwXBw7jg/JUvj0v4lJddd
         QOHepFSIhQ0qCKvVwIoF7YCEby3PVG/F1VGK5Djy1NGL27CBXDrgCBhlbdcJHqVXcO5s
         v93Re3Io33AbOGwj27NBDu6k2HulGCp3Bwg0QZluW/KSDrphOd+VWUvrw4hdPECy/YJF
         kt+wyBQqxGxYg3Fh7roQTPKt1UeEqh4ZA0LzFlKm332nMP+wfHu5Lpxc/EFQhoRway+d
         G/NIPjlPNdzuzF9DlL/cY2cuFKJ+8SqWPCfUZbBGb8Ng+cnsgOIH22R6UO/Cx76VoEnw
         p28Q==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from;
        bh=CfljN/CbOV6Fry9g92TnFDy7qc8FAxA2gGSJjNt1zCk=;
        b=SzcpqpzBw8J+r1hIRpOsbx0B0Ki1xqZVknH6YWJQIlSCKXkp//I4YFkXMeQaEWNKl1
         x0ffI/BCSEgIwQiXIsIIAEb6AlUyWn+Os8YWHjF7mEdkQxKV7jDcjj8Yrc214mGGDikz
         X6jGRAsrrZP6uaVS3CbV1YXcbpnNN82PZdAIkFLCzq42p5xCn/wqWTJ1gVJIxHKvHoVS
         HkXtau1pkmbg7GHmIPYs0IdxtVvlMHK5R7qRgiCbQgGGbeoPNI2M//reLgd3UF/Xa0l8
         dxFaL5F3dM3JY+t98WlMEEE6sJg8sxZoII6Bf8aBwG/qf5clCKbVeVsm6LeUj6SCOGGH
         CLdw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jglisse@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id v91si2523291qte.315.2019.04.03.12.33.41
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 03 Apr 2019 12:33:41 -0700 (PDT)
Received-SPF: pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jglisse@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx01.intmail.prod.int.phx2.redhat.com [10.5.11.11])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id CC0A499D2E;
	Wed,  3 Apr 2019 19:33:40 +0000 (UTC)
Received: from localhost.localdomain.com (ovpn-125-190.rdu2.redhat.com [10.10.125.190])
	by smtp.corp.redhat.com (Postfix) with ESMTP id CC9306012C;
	Wed,  3 Apr 2019 19:33:39 +0000 (UTC)
From: jglisse@redhat.com
To: linux-mm@kvack.org,
	Andrew Morton <akpm@linux-foundation.org>
Cc: linux-kernel@vger.kernel.org,
	=?UTF-8?q?J=C3=A9r=C3=B4me=20Glisse?= <jglisse@redhat.com>,
	Dan Williams <dan.j.williams@intel.com>,
	John Hubbard <jhubbard@nvidia.com>,
	Arnd Bergmann <arnd@arndb.de>
Subject: [PATCH v3 09/12] mm/hmm: allow to mirror vma of a file on a DAX backed filesystem v3
Date: Wed,  3 Apr 2019 15:33:15 -0400
Message-Id: <20190403193318.16478-10-jglisse@redhat.com>
In-Reply-To: <20190403193318.16478-1-jglisse@redhat.com>
References: <20190403193318.16478-1-jglisse@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.11
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.38]); Wed, 03 Apr 2019 19:33:40 +0000 (UTC)
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

Changes since v2:
    - Added comments about get_dev_pagemap() optimization.
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
 mm/hmm.c | 138 ++++++++++++++++++++++++++++++++++++++++++++++---------
 1 file changed, 117 insertions(+), 21 deletions(-)

diff --git a/mm/hmm.c b/mm/hmm.c
index 9140cee24d36..39bc77d7e6e3 100644
--- a/mm/hmm.c
+++ b/mm/hmm.c
@@ -329,6 +329,7 @@ EXPORT_SYMBOL(hmm_mirror_unregister);
 
 struct hmm_vma_walk {
 	struct hmm_range	*range;
+	struct dev_pagemap	*pgmap;
 	unsigned long		last;
 	bool			fault;
 	bool			block;
@@ -503,6 +504,15 @@ static inline uint64_t pmd_to_hmm_pfn_flags(struct hmm_range *range, pmd_t pmd)
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
@@ -524,8 +534,19 @@ static int hmm_vma_handle_pmd(struct mm_walk *walk,
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
@@ -612,10 +633,24 @@ static int hmm_vma_handle_pte(struct mm_walk *walk, unsigned long addr,
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
@@ -703,12 +738,89 @@ static int hmm_vma_walk_pmd(pmd_t *pmdp,
 			return r;
 		}
 	}
+	if (hmm_vma_walk->pgmap) {
+		/*
+		 * We do put_dev_pagemap() here and not in hmm_vma_handle_pte()
+		 * so that we can leverage get_dev_pagemap() optimization which
+		 * will not re-take a reference on a pgmap if we already have
+		 * one.
+		 */
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
@@ -781,14 +893,6 @@ static void hmm_pfns_clear(struct hmm_range *range,
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
@@ -906,12 +1010,6 @@ long hmm_range_snapshot(struct hmm_range *range)
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
 
@@ -935,6 +1033,7 @@ long hmm_range_snapshot(struct hmm_range *range)
 		}
 
 		range->vma = vma;
+		hmm_vma_walk.pgmap = NULL;
 		hmm_vma_walk.last = start;
 		hmm_vma_walk.fault = false;
 		hmm_vma_walk.range = range;
@@ -946,6 +1045,7 @@ long hmm_range_snapshot(struct hmm_range *range)
 		mm_walk.pte_entry = NULL;
 		mm_walk.test_walk = NULL;
 		mm_walk.hugetlb_entry = NULL;
+		mm_walk.pud_entry = hmm_vma_walk_pud;
 		mm_walk.pmd_entry = hmm_vma_walk_pmd;
 		mm_walk.pte_hole = hmm_vma_walk_hole;
 		mm_walk.hugetlb_entry = hmm_vma_walk_hugetlb_entry;
@@ -1011,12 +1111,6 @@ long hmm_range_fault(struct hmm_range *range, bool block)
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
@@ -1039,6 +1133,7 @@ long hmm_range_fault(struct hmm_range *range, bool block)
 		}
 
 		range->vma = vma;
+		hmm_vma_walk.pgmap = NULL;
 		hmm_vma_walk.last = start;
 		hmm_vma_walk.fault = true;
 		hmm_vma_walk.block = block;
@@ -1051,6 +1146,7 @@ long hmm_range_fault(struct hmm_range *range, bool block)
 		mm_walk.pte_entry = NULL;
 		mm_walk.test_walk = NULL;
 		mm_walk.hugetlb_entry = NULL;
+		mm_walk.pud_entry = hmm_vma_walk_pud;
 		mm_walk.pmd_entry = hmm_vma_walk_pmd;
 		mm_walk.pte_hole = hmm_vma_walk_hole;
 		mm_walk.hugetlb_entry = hmm_vma_walk_hugetlb_entry;
-- 
2.17.2


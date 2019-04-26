Return-Path: <SRS0=i6a/=S4=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id BD04BC43219
	for <linux-mm@archiver.kernel.org>; Fri, 26 Apr 2019 04:54:07 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 8337B206C1
	for <linux-mm@archiver.kernel.org>; Fri, 26 Apr 2019 04:54:07 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 8337B206C1
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 213666B0274; Fri, 26 Apr 2019 00:54:07 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 1C3D86B0275; Fri, 26 Apr 2019 00:54:07 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 08C0A6B0276; Fri, 26 Apr 2019 00:54:07 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f200.google.com (mail-qt1-f200.google.com [209.85.160.200])
	by kanga.kvack.org (Postfix) with ESMTP id DCE826B0274
	for <linux-mm@kvack.org>; Fri, 26 Apr 2019 00:54:06 -0400 (EDT)
Received: by mail-qt1-f200.google.com with SMTP id 18so1847244qtw.20
        for <linux-mm@kvack.org>; Thu, 25 Apr 2019 21:54:06 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references;
        bh=yQDxWhs+lCUchDUREZ6Ld09bitOzgmvjoggeWW25uUE=;
        b=aBT18Ra/1X62gr9MCEQfpAkxRxS4IzbN8Yop82txlwmuc07SZZ/Qg3LnX5W7zZcz8w
         yT4JyIvQXW0CUESC13UBbto8e6ICPpobfDxawBSELjptcnX11wJH+8+Bnap6N+SbwN7R
         UaQvsG1OS2t5VsKpozZG9SuTjEMPrU9YZS2A6IclBE2ltcgud0rle9vu4ENthHneAL8j
         CMK+58ftCaOGXtzo2JYOJWJxLm62gP8ACQxus9GLQ0Xal+krzmJVBBULhsksW9zBJI68
         EG8VB/qUEG6Y2rSDAB6GCNNAms75+k9qJ0L+YDmwGpYYylAwNECdR1uwGdmN4Zc/d6tl
         Jtmg==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of peterx@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=peterx@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: APjAAAUYNSyDigAzpd0h8Ymi1broaYXHGusqkndpOOKYD3ROiVxfUryZ
	2gWFRMcWAFHwvDPzrlL5DORIT9IGFVgDtzygQQ72NGat8PNzCIqBAVdyjY0wx4tI8y/gCeJV6ND
	0VRDiZnhiThf2uZDMGnHCCzL0RHiN+uyiHIODAcDW59Ol8vVXkXFpySe0Yp4DKIq5Zw==
X-Received: by 2002:a37:a7c4:: with SMTP id q187mr27830430qke.242.1556254446679;
        Thu, 25 Apr 2019 21:54:06 -0700 (PDT)
X-Google-Smtp-Source: APXvYqy7UbMgIcPFHP0iOGdRlKdnxP2LYDhz0UP7GhyK9nS3ONGElwdltEPPCvkhwILFcGk/Ekra
X-Received: by 2002:a37:a7c4:: with SMTP id q187mr27830402qke.242.1556254445905;
        Thu, 25 Apr 2019 21:54:05 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1556254445; cv=none;
        d=google.com; s=arc-20160816;
        b=C4j+2+fw1RjdVouE5ZAkD5503CwjNmO77ILD88oBB1nNeItiL75HX8sHKig5F7erro
         +I202tmCsBWmK7sY9elBk43dyyXlryzJBjbnMHIrbo10H8yda7daTxOfg7dUzImbmhOy
         YQb/zgmjIDtRFrhRtSQu8rWrb/8PFl96NmdSKPDaM1q09Zr9G6sKMhmJF6gAS1xeVhsd
         oCf15OzOtA1CiSZyZC1DaY53zI5AI7A5ndo/srpwiPnOziuNvfK8OqaZJsyOHRR/KUWA
         C2Tty891BiOmJQqgRk51jB/eTRLE5DcrGFnRio/8H100RgMlQEFEeuBTwJDbOd99tUAj
         u8Rw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=references:in-reply-to:message-id:date:subject:cc:to:from;
        bh=yQDxWhs+lCUchDUREZ6Ld09bitOzgmvjoggeWW25uUE=;
        b=lPmyE9afq/TCDeyeLzQ2d7wf80vqHiSCE7YP3JtH9vsTZhP4F4ForRAcVrcfttbR9s
         DW1Dyd1z71KcuYd8XktqJs7gQeRTCVcEprrXLAFC1apBeEXBhV4ICO701jg/vA4qg5MV
         R/ZJ9srb8+4UP1mlLZgJheIdieRQ0pCWlWWQGVk8o3yczfLiNdWJbLmMhxoVmD5Qf9AE
         VIzpyiYkHnu0CWlG/ICwRK+uhwDoOTve0mVTGA4ySMqDG8llUDty6sr4RItRZBZWdDVM
         dLbuOwekd08xRn5PCHdzZyZQM46sdUSu3s+T9RHTFE8qSp0WrUD5nkJ7h0r0jwkiCkMb
         GE/A==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of peterx@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=peterx@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id d31si2873585qvh.37.2019.04.25.21.54.05
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 25 Apr 2019 21:54:05 -0700 (PDT)
Received-SPF: pass (google.com: domain of peterx@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of peterx@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=peterx@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx08.intmail.prod.int.phx2.redhat.com [10.5.11.23])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id 0755A81DFE;
	Fri, 26 Apr 2019 04:54:05 +0000 (UTC)
Received: from xz-x1.nay.redhat.com (dhcp-15-205.nay.redhat.com [10.66.15.205])
	by smtp.corp.redhat.com (Postfix) with ESMTP id 6B896194A0;
	Fri, 26 Apr 2019 04:53:59 +0000 (UTC)
From: Peter Xu <peterx@redhat.com>
To: linux-mm@kvack.org,
	linux-kernel@vger.kernel.org
Cc: David Hildenbrand <david@redhat.com>,
	Hugh Dickins <hughd@google.com>,
	Maya Gokhale <gokhale2@llnl.gov>,
	Jerome Glisse <jglisse@redhat.com>,
	Pavel Emelyanov <xemul@virtuozzo.com>,
	Johannes Weiner <hannes@cmpxchg.org>,
	peterx@redhat.com,
	Martin Cracauer <cracauer@cons.org>,
	Shaohua Li <shli@fb.com>,
	Denis Plotnikov <dplotnikov@virtuozzo.com>,
	Andrea Arcangeli <aarcange@redhat.com>,
	Mike Kravetz <mike.kravetz@oracle.com>,
	Marty McFadden <mcfadden8@llnl.gov>,
	Mike Rapoport <rppt@linux.vnet.ibm.com>,
	Mel Gorman <mgorman@suse.de>,
	"Kirill A . Shutemov" <kirill@shutemov.name>,
	"Dr . David Alan Gilbert" <dgilbert@redhat.com>
Subject: [PATCH v4 14/27] userfaultfd: wp: handle COW properly for uffd-wp
Date: Fri, 26 Apr 2019 12:51:38 +0800
Message-Id: <20190426045151.19556-15-peterx@redhat.com>
In-Reply-To: <20190426045151.19556-1-peterx@redhat.com>
References: <20190426045151.19556-1-peterx@redhat.com>
X-Scanned-By: MIMEDefang 2.84 on 10.5.11.23
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.25]); Fri, 26 Apr 2019 04:54:05 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

This allows uffd-wp to support write-protected pages for COW.

For example, the uffd write-protected PTE could also be write-protected
by other usages like COW or zero pages.  When that happens, we can't
simply set the write bit in the PTE since otherwise it'll change the
content of every single reference to the page.  Instead, we should do
the COW first if necessary, then handle the uffd-wp fault.

To correctly copy the page, we'll also need to carry over the
_PAGE_UFFD_WP bit if it was set in the original PTE.

For huge PMDs, we just simply split the huge PMDs where we want to
resolve an uffd-wp page fault always.  That matches what we do with
general huge PMD write protections.  In that way, we resolved the huge
PMD copy-on-write issue into PTE copy-on-write.

Signed-off-by: Peter Xu <peterx@redhat.com>
---
 mm/memory.c   |  5 ++++-
 mm/mprotect.c | 55 ++++++++++++++++++++++++++++++++++++++++++++++++---
 2 files changed, 56 insertions(+), 4 deletions(-)

diff --git a/mm/memory.c b/mm/memory.c
index ab98a1eb4702..965d974bb9bd 100644
--- a/mm/memory.c
+++ b/mm/memory.c
@@ -2299,7 +2299,10 @@ static vm_fault_t wp_page_copy(struct vm_fault *vmf)
 		}
 		flush_cache_page(vma, vmf->address, pte_pfn(vmf->orig_pte));
 		entry = mk_pte(new_page, vma->vm_page_prot);
-		entry = maybe_mkwrite(pte_mkdirty(entry), vma);
+		if (pte_uffd_wp(vmf->orig_pte))
+			entry = pte_mkuffd_wp(entry);
+		else
+			entry = maybe_mkwrite(pte_mkdirty(entry), vma);
 		/*
 		 * Clear the pte entry and flush it first, before updating the
 		 * pte with the new entry. This will avoid a race condition
diff --git a/mm/mprotect.c b/mm/mprotect.c
index 732d9b6d1d21..1f40662182f8 100644
--- a/mm/mprotect.c
+++ b/mm/mprotect.c
@@ -73,18 +73,18 @@ static unsigned long change_pte_range(struct vm_area_struct *vma, pmd_t *pmd,
 	flush_tlb_batched_pending(vma->vm_mm);
 	arch_enter_lazy_mmu_mode();
 	do {
+retry_pte:
 		oldpte = *pte;
 		if (pte_present(oldpte)) {
 			pte_t ptent;
 			bool preserve_write = prot_numa && pte_write(oldpte);
+			struct page *page;
 
 			/*
 			 * Avoid trapping faults against the zero or KSM
 			 * pages. See similar comment in change_huge_pmd.
 			 */
 			if (prot_numa) {
-				struct page *page;
-
 				page = vm_normal_page(vma, addr, oldpte);
 				if (!page || PageKsm(page))
 					continue;
@@ -114,6 +114,45 @@ static unsigned long change_pte_range(struct vm_area_struct *vma, pmd_t *pmd,
 					continue;
 			}
 
+			/*
+			 * Detect whether we'll need to COW before
+			 * resolving an uffd-wp fault.  Note that this
+			 * includes detection of the zero page (where
+			 * page==NULL)
+			 */
+			if (uffd_wp_resolve) {
+				struct vm_fault vmf = {
+					.vma = vma,
+					.address = addr & PAGE_MASK,
+					.orig_pte = oldpte,
+					.pmd = pmd,
+					.pte = pte,
+					.ptl = ptl,
+				};
+				vm_fault_t ret;
+
+				/* If the fault is resolved already, skip */
+				if (!pte_uffd_wp(*pte))
+					continue;
+
+				arch_leave_lazy_mmu_mode();
+				/* With PTE lock held */
+				ret = do_wp_page_cont(&vmf);
+				if (ret != VM_FAULT_WRITE && ret != 0)
+					/* Probably OOM */
+					return pages;
+				pte = pte_offset_map_lock(vma->vm_mm, pmd,
+							  addr, &ptl);
+				arch_enter_lazy_mmu_mode();
+				if (ret == 0 || !pte_present(*pte))
+					/*
+					 * This PTE could have been modified
+					 * during or after COW before taking
+					 * the lock; retry.
+					 */
+					goto retry_pte;
+			}
+
 			oldpte = ptep_modify_prot_start(vma, addr, pte);
 			ptent = pte_modify(oldpte, newprot);
 			if (preserve_write)
@@ -183,6 +222,7 @@ static inline unsigned long change_pmd_range(struct vm_area_struct *vma,
 	unsigned long pages = 0;
 	unsigned long nr_huge_updates = 0;
 	struct mmu_notifier_range range;
+	bool uffd_wp_resolve = cp_flags & MM_CP_UFFD_WP_RESOLVE;
 
 	range.start = 0;
 
@@ -202,7 +242,16 @@ static inline unsigned long change_pmd_range(struct vm_area_struct *vma,
 		}
 
 		if (is_swap_pmd(*pmd) || pmd_trans_huge(*pmd) || pmd_devmap(*pmd)) {
-			if (next - addr != HPAGE_PMD_SIZE) {
+			/*
+			 * When resolving an userfaultfd write
+			 * protection fault, it's not easy to identify
+			 * whether a THP is shared with others and
+			 * whether we'll need to do copy-on-write, so
+			 * just split it always for now to simply the
+			 * procedure.  And that's the policy too for
+			 * general THP write-protect in af9e4d5f2de2.
+			 */
+			if (next - addr != HPAGE_PMD_SIZE || uffd_wp_resolve) {
 				__split_huge_pmd(vma, pmd, addr, false, NULL);
 			} else {
 				int nr_ptes = change_huge_pmd(vma, pmd, addr,
-- 
2.17.1


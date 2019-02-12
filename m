Return-Path: <SRS0=CIMh=QT=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 20430C169C4
	for <linux-mm@archiver.kernel.org>; Tue, 12 Feb 2019 02:59:25 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id CFA782084D
	for <linux-mm@archiver.kernel.org>; Tue, 12 Feb 2019 02:59:24 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org CFA782084D
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 7101E8E01A7; Mon, 11 Feb 2019 21:59:24 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 6724A8E000E; Mon, 11 Feb 2019 21:59:24 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 53AD78E01A7; Mon, 11 Feb 2019 21:59:24 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f198.google.com (mail-qk1-f198.google.com [209.85.222.198])
	by kanga.kvack.org (Postfix) with ESMTP id 279778E000E
	for <linux-mm@kvack.org>; Mon, 11 Feb 2019 21:59:24 -0500 (EST)
Received: by mail-qk1-f198.google.com with SMTP id i66so11536616qke.21
        for <linux-mm@kvack.org>; Mon, 11 Feb 2019 18:59:24 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references;
        bh=ylIq5mGR3mm8NvVx73VTNBWfb4B1nm0xwLay7laduNk=;
        b=YbXCrpHiYyjpI5pLa8VQ0EYNU2YAH1o4LGu/dwKoCuSbEY35KC3yWv05rr8RnOK8fU
         5HingvkPzmeSJkdJNftKZMPD6W/GI5ZmP9fJUaLrDwxB1iJxrhe63MXaYx1vG6+fsXDE
         ZQ7og8UPznnBjEi3lt/7G/bySchvwN071F21j0x/w89Z5knGkVWM8Juu4acth6yKvJAF
         HtfswjnLKdJ1QeuFJw2jR62rYEwQeiq4PNfxezyyHfR2BftLQC0yj/4VmMkT26nloJGL
         V2RJ30+UELcMRhJHmC1ljV0QZjwjZs5pSy+7EdCWnuWM2pgd574wirWRFzx+wemAcdot
         /P2w==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of peterx@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=peterx@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: AHQUAuZomTB4K/GzzmJaL444xT4hawh5lOh0KXN+nBV6v88xAna2Etzc
	UcB8Zx6Xc0HUegwmuANpbULbr2bADGlfx4UZpDNFd8iF+tRD9dap9FyThU3ruacrSOg9sCVSTxG
	UMrpk5sNWRQY7eUSYN5zYj4yKLuTFCsF9E3WjxS7gcD8YQywR4u7eVqdL3kcW3zvKEQ==
X-Received: by 2002:ac8:336a:: with SMTP id u39mr1164500qta.64.1549940363944;
        Mon, 11 Feb 2019 18:59:23 -0800 (PST)
X-Google-Smtp-Source: AHgI3IaMUOqH1INHvGESXrEk2GmGUwHHN8jfZmvFSVa9ldsmXxvvTLVNI1n+YQmAgU2vpU3bwuvY
X-Received: by 2002:ac8:336a:: with SMTP id u39mr1164488qta.64.1549940363393;
        Mon, 11 Feb 2019 18:59:23 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1549940363; cv=none;
        d=google.com; s=arc-20160816;
        b=wtMtLan6Eb92MIas7A4ihXIGEBrSY9bo/OQmD4KZZWxeH+huLlfMdYiJ31sPFEbECW
         /fCN72yG2sw7u2tYY6kInhAWYhuH6M+JG4d+oK9u6g0wWuPkRM2T73xqHeNRUq2ni440
         2ds5gzPpo0eAWeUgnmyJ6nqWtaQx0+5AaChOScqTx+JEZkZ0V1zDF+b/8ljNZpWEwYWX
         8B8hGW1tIZwlUY8nNiYikbxfcXgAmuafbbq0nh7Nn38ohcBZZCRV5WE12pERxAazEXC1
         oZ9AvZbNL8S7uPmXbcGuWLKQrmBaiiu1pnPqFHVfjmOb4J1S4xRT4/oC5cgWnCeYGxRt
         HeVA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=references:in-reply-to:message-id:date:subject:cc:to:from;
        bh=ylIq5mGR3mm8NvVx73VTNBWfb4B1nm0xwLay7laduNk=;
        b=ce6WIAmJpGnqI+VtQJjltWDPixyviJZaUAljXldAPbPAsFKxrX4XOalyTn+ka8SlLe
         T9d4pak9pb6qbZlY9v1H87pszy20DKf9LBHGcNSdbGQ7hq1AIC0FvRRliDNx2of0KkDq
         p1MBPgDNIvpAAE5H1HJQczHJiGERp64204TK/rrcLRNWdSf1UxZRxgzXg/3KtT4/zHvb
         HZNJ/W11yYzOHSVFAzw+AXTJuoAEa7BSxgrPZU1UsW82wN73PVF36S3f92kYRvNgqKlQ
         fBYkR7A5kU15j2zo3dv6XyNm080/U+x4K0RXSjXw2CohBg1mxD9LkMQOpIN0yQawmv7H
         NS7A==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of peterx@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=peterx@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id w11si3720699qti.269.2019.02.11.18.59.23
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 11 Feb 2019 18:59:23 -0800 (PST)
Received-SPF: pass (google.com: domain of peterx@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of peterx@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=peterx@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx01.intmail.prod.int.phx2.redhat.com [10.5.11.11])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id 68D834902D;
	Tue, 12 Feb 2019 02:59:22 +0000 (UTC)
Received: from xz-x1.nay.redhat.com (dhcp-14-116.nay.redhat.com [10.66.14.116])
	by smtp.corp.redhat.com (Postfix) with ESMTP id 45FC6600C6;
	Tue, 12 Feb 2019 02:59:08 +0000 (UTC)
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
	Marty McFadden <mcfadden8@llnl.gov>,
	Andrea Arcangeli <aarcange@redhat.com>,
	Mike Kravetz <mike.kravetz@oracle.com>,
	Denis Plotnikov <dplotnikov@virtuozzo.com>,
	Mike Rapoport <rppt@linux.vnet.ibm.com>,
	Mel Gorman <mgorman@suse.de>,
	"Kirill A . Shutemov" <kirill@shutemov.name>,
	"Dr . David Alan Gilbert" <dgilbert@redhat.com>
Subject: [PATCH v2 14/26] userfaultfd: wp: handle COW properly for uffd-wp
Date: Tue, 12 Feb 2019 10:56:20 +0800
Message-Id: <20190212025632.28946-15-peterx@redhat.com>
In-Reply-To: <20190212025632.28946-1-peterx@redhat.com>
References: <20190212025632.28946-1-peterx@redhat.com>
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.11
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.38]); Tue, 12 Feb 2019 02:59:22 +0000 (UTC)
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
 mm/memory.c   |  2 ++
 mm/mprotect.c | 55 ++++++++++++++++++++++++++++++++++++++++++++++++---
 2 files changed, 54 insertions(+), 3 deletions(-)

diff --git a/mm/memory.c b/mm/memory.c
index 32d32b6e6339..b5d67bafae35 100644
--- a/mm/memory.c
+++ b/mm/memory.c
@@ -2291,6 +2291,8 @@ vm_fault_t wp_page_copy(struct vm_fault *vmf)
 		}
 		flush_cache_page(vma, vmf->address, pte_pfn(vmf->orig_pte));
 		entry = mk_pte(new_page, vma->vm_page_prot);
+		if (pte_uffd_wp(vmf->orig_pte))
+			entry = pte_mkuffd_wp(entry);
 		entry = maybe_mkwrite(pte_mkdirty(entry), vma);
 		/*
 		 * Clear the pte entry and flush it first, before updating the
diff --git a/mm/mprotect.c b/mm/mprotect.c
index 9d4433044c21..ae93721f3795 100644
--- a/mm/mprotect.c
+++ b/mm/mprotect.c
@@ -77,14 +77,13 @@ static unsigned long change_pte_range(struct vm_area_struct *vma, pmd_t *pmd,
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
@@ -114,6 +113,46 @@ static unsigned long change_pte_range(struct vm_area_struct *vma, pmd_t *pmd,
 					continue;
 			}
 
+			/*
+			 * Detect whether we'll need to COW before
+			 * resolving an uffd-wp fault.  Note that this
+			 * includes detection of the zero page (where
+			 * page==NULL)
+			 */
+			if (uffd_wp_resolve) {
+				/* If the fault is resolved already, skip */
+				if (!pte_uffd_wp(*pte))
+					continue;
+				page = vm_normal_page(vma, addr, oldpte);
+				if (!page || page_mapcount(page) > 1) {
+					struct vm_fault vmf = {
+						.vma = vma,
+						.address = addr & PAGE_MASK,
+						.page = page,
+						.orig_pte = oldpte,
+						.pmd = pmd,
+						/* pte and ptl not needed */
+					};
+					vm_fault_t ret;
+
+					if (page)
+						get_page(page);
+					arch_leave_lazy_mmu_mode();
+					pte_unmap_unlock(pte, ptl);
+					ret = wp_page_copy(&vmf);
+					/* PTE is changed, or OOM */
+					if (ret == 0)
+						/* It's done by others */
+						continue;
+					else if (WARN_ON(ret != VM_FAULT_WRITE))
+						return pages;
+					pte = pte_offset_map_lock(vma->vm_mm,
+								  pmd, addr,
+								  &ptl);
+					arch_enter_lazy_mmu_mode();
+				}
+			}
+
 			ptent = ptep_modify_prot_start(mm, addr, pte);
 			ptent = pte_modify(ptent, newprot);
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


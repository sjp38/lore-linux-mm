Return-Path: <SRS0=424v=UT=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.8 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id BB0A3C48BE0
	for <linux-mm@archiver.kernel.org>; Thu, 20 Jun 2019 02:22:58 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 6F6E3214AF
	for <linux-mm@archiver.kernel.org>; Thu, 20 Jun 2019 02:22:58 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 6F6E3214AF
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 1F5618E0002; Wed, 19 Jun 2019 22:22:58 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 1CD9F8E0001; Wed, 19 Jun 2019 22:22:58 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 0E3C88E0002; Wed, 19 Jun 2019 22:22:58 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f197.google.com (mail-qt1-f197.google.com [209.85.160.197])
	by kanga.kvack.org (Postfix) with ESMTP id E12188E0001
	for <linux-mm@kvack.org>; Wed, 19 Jun 2019 22:22:57 -0400 (EDT)
Received: by mail-qt1-f197.google.com with SMTP id a18so1645454qtj.18
        for <linux-mm@kvack.org>; Wed, 19 Jun 2019 19:22:57 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=WEH4Ey9rJITN7HxgV1WrePJ0D0pC4Vz8TTkGNcUXJd8=;
        b=C9nIR7CYg3d5kt2mZj/LWJw8BHcZhbYKumntPiViqziTdIGqStXADiumKdkgU5XCqQ
         iCVgQzRLFYO6vlNHtQhgiDeNusmloyExEHPfkr3mKeGDminzb82T4iD+Qql8x3VVtXHD
         MH9+HniPb54Wb8Yd5E4CmTuY3CsghYqD2ZZW9DWpgTjZhka31izUjJQ2clmWe3YlyKOq
         tfcK2ZjTdv/Ou/VJjf1vBjShDNfXU2srNkwpkFlbLnBIQCg3YPg6I73YVYnEIJYaEIZD
         tao3i/0fNApbLENtHzCfMqBCv3xuk8/tZh3nBoM/Lj7dEE/q0/UePh//hyGHhC1D9YoD
         WmAA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of peterx@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=peterx@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: APjAAAVLyXhpl7GvTg+mq89LiigiJK3qk3jy6O27ldM2I84/8wb7ioYI
	UV6EulSfYp2HFvjR0S/v5jGFuxJ3LYFWVodkVQOAzL9PGaRe6oXLo3orO9v2Z0Yd36P7Lary6CM
	9rzD5sMv7t7uFdb939ccaCBmDPBDdjvxHoyNmUozKzjK6o2fEZAx+PYEWBtAfmZTrfA==
X-Received: by 2002:ac8:5315:: with SMTP id t21mr13844132qtn.229.1560997377665;
        Wed, 19 Jun 2019 19:22:57 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxTzvcHLPZV0LFUuiKNE8gnsRJJL6jL3/Hw36uvD1N+w7jU339du78oF7f5Ux/A5wjin9nr
X-Received: by 2002:ac8:5315:: with SMTP id t21mr13844088qtn.229.1560997376658;
        Wed, 19 Jun 2019 19:22:56 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1560997376; cv=none;
        d=google.com; s=arc-20160816;
        b=LfjIjqYN2Vi9SEkltNTUPXpTrmrnb7h8cu82lbudiu+97sLEnnOr9a//ndLbWiZscq
         432grt6jR+yHyB+SMArATcAHN67+byz+ww8SfCaZ/5X9RJiTUbi11bRYCIPt8iv+I9oB
         N7+lgnr6PC5NvssBw5pVeJkfYEwGcz0pJ6WylSoYFnMun8emLJxFH7zbht/iTQ/8N5YT
         8qY/45qppfDamHRQYYBXoxAkljWjM72zbdvCq+HP5qFuexcaCQniNeF8xAFHx4EuuUKM
         uUf+KCLUuS/CcMxItDww93wd0hxpbQk2VDF71BEDHj5VDuPtoZja47uVr5HK7rlhBzb9
         bFew==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from;
        bh=WEH4Ey9rJITN7HxgV1WrePJ0D0pC4Vz8TTkGNcUXJd8=;
        b=tyDANQEtjcecsXTQe0ow4rzXG/rZ6g1Ncon6LikAEUjGMcSaI48mVQPm6WqBxaEL9b
         46i+erR153ovQDt1scG4n5asQN0IBzI5Jd8cs/nXx+VS/wL0yPwFlPxXq57klnmSQJQ7
         lyaoA7WqsMSz4iQXOEG8tRWI3nDPX25e2sNLZ8xmPyWxrtArEtQzha3aSRlSEflvsGnG
         Dd6+AVOHEwrrnwZ1mTZfNfsOepf9V8wXQAr6jmItg8mzSDJs9Oy7KmH7CvwOTxPO1d0B
         Ir+M70ZB6EordKbjhahmHBWvOTwVCRZEhmxsJUWf2Ekz8kbMsdeW1cPXMioTmRw7BvBz
         x49w==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of peterx@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=peterx@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id s45si3821730qtj.304.2019.06.19.19.22.56
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 19 Jun 2019 19:22:56 -0700 (PDT)
Received-SPF: pass (google.com: domain of peterx@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of peterx@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=peterx@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx07.intmail.prod.int.phx2.redhat.com [10.5.11.22])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id C092C81F0E;
	Thu, 20 Jun 2019 02:22:55 +0000 (UTC)
Received: from xz-x1.redhat.com (ovpn-12-78.pek2.redhat.com [10.72.12.78])
	by smtp.corp.redhat.com (Postfix) with ESMTP id 99FEA1001DE7;
	Thu, 20 Jun 2019 02:22:41 +0000 (UTC)
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
	Denis Plotnikov <dplotnikov@virtuozzo.com>,
	Shaohua Li <shli@fb.com>,
	Andrea Arcangeli <aarcange@redhat.com>,
	Mike Kravetz <mike.kravetz@oracle.com>,
	Marty McFadden <mcfadden8@llnl.gov>,
	Mike Rapoport <rppt@linux.vnet.ibm.com>,
	Mel Gorman <mgorman@suse.de>,
	"Kirill A . Shutemov" <kirill@shutemov.name>,
	"Dr . David Alan Gilbert" <dgilbert@redhat.com>
Subject: [PATCH v5 12/25] userfaultfd: wp: apply _PAGE_UFFD_WP bit
Date: Thu, 20 Jun 2019 10:19:55 +0800
Message-Id: <20190620022008.19172-13-peterx@redhat.com>
In-Reply-To: <20190620022008.19172-1-peterx@redhat.com>
References: <20190620022008.19172-1-peterx@redhat.com>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-Scanned-By: MIMEDefang 2.84 on 10.5.11.22
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.27]); Thu, 20 Jun 2019 02:22:55 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Firstly, introduce two new flags MM_CP_UFFD_WP[_RESOLVE] for
change_protection() when used with uffd-wp and make sure the two new
flags are exclusively used.  Then,

  - For MM_CP_UFFD_WP: apply the _PAGE_UFFD_WP bit and remove _PAGE_RW
    when a range of memory is write protected by uffd

  - For MM_CP_UFFD_WP_RESOLVE: remove the _PAGE_UFFD_WP bit and recover
    _PAGE_RW when write protection is resolved from userspace

And use this new interface in mwriteprotect_range() to replace the old
MM_CP_DIRTY_ACCT.

Do this change for both PTEs and huge PMDs.  Then we can start to
identify which PTE/PMD is write protected by general (e.g., COW or soft
dirty tracking), and which is for userfaultfd-wp.

Since we should keep the _PAGE_UFFD_WP when doing pte_modify(), add it
into _PAGE_CHG_MASK as well.  Meanwhile, since we have this new bit, we
can be even more strict when detecting uffd-wp page faults in either
do_wp_page() or wp_huge_pmd().

After we're with _PAGE_UFFD_WP, a special case is when a page is both
protected by the general COW logic and also userfault-wp.  Here the
userfault-wp will have higher priority and will be handled first.
Only after the uffd-wp bit is cleared on the PTE/PMD will we continue
to handle the general COW.  These are the steps on what will happen
with such a page:

  1. CPU accesses write protected shared page (so both protected by
     general COW and uffd-wp), blocked by uffd-wp first because in
     do_wp_page we'll handle uffd-wp first, so it has higher priority
     than general COW.

  2. Uffd service thread receives the request, do UFFDIO_WRITEPROTECT
     to remove the uffd-wp bit upon the PTE/PMD.  However here we
     still keep the write bit cleared.  Notify the blocked CPU.

  3. The blocked CPU resumes the page fault process with a fault
     retry, during retry it'll notice it was not with the uffd-wp bit
     this time but it is still write protected by general COW, then
     it'll go though the COW path in the fault handler, copy the page,
     apply write bit where necessary, and retry again.

  4. The CPU will be able to access this page with write bit set.

Suggested-by: Andrea Arcangeli <aarcange@redhat.com>
Signed-off-by: Peter Xu <peterx@redhat.com>
---
 include/linux/mm.h |  5 +++++
 mm/huge_memory.c   | 18 +++++++++++++++++-
 mm/memory.c        |  4 ++--
 mm/mprotect.c      | 17 +++++++++++++++++
 mm/userfaultfd.c   |  8 ++++++--
 5 files changed, 47 insertions(+), 5 deletions(-)

diff --git a/include/linux/mm.h b/include/linux/mm.h
index a93ac1c37940..beca76650271 100644
--- a/include/linux/mm.h
+++ b/include/linux/mm.h
@@ -1719,6 +1719,11 @@ extern unsigned long move_page_tables(struct vm_area_struct *vma,
 #define  MM_CP_DIRTY_ACCT                  (1UL << 0)
 /* Whether this protection change is for NUMA hints */
 #define  MM_CP_PROT_NUMA                   (1UL << 1)
+/* Whether this change is for write protecting */
+#define  MM_CP_UFFD_WP                     (1UL << 2) /* do wp */
+#define  MM_CP_UFFD_WP_RESOLVE             (1UL << 3) /* Resolve wp */
+#define  MM_CP_UFFD_WP_ALL                 (MM_CP_UFFD_WP | \
+					    MM_CP_UFFD_WP_RESOLVE)
 
 extern unsigned long change_protection(struct vm_area_struct *vma, unsigned long start,
 			      unsigned long end, pgprot_t newprot,
diff --git a/mm/huge_memory.c b/mm/huge_memory.c
index b7149a0acac1..3fda79f6746b 100644
--- a/mm/huge_memory.c
+++ b/mm/huge_memory.c
@@ -1911,6 +1911,8 @@ int change_huge_pmd(struct vm_area_struct *vma, pmd_t *pmd,
 	bool preserve_write;
 	int ret;
 	bool prot_numa = cp_flags & MM_CP_PROT_NUMA;
+	bool uffd_wp = cp_flags & MM_CP_UFFD_WP;
+	bool uffd_wp_resolve = cp_flags & MM_CP_UFFD_WP_RESOLVE;
 
 	ptl = __pmd_trans_huge_lock(pmd, vma);
 	if (!ptl)
@@ -1977,6 +1979,17 @@ int change_huge_pmd(struct vm_area_struct *vma, pmd_t *pmd,
 	entry = pmd_modify(entry, newprot);
 	if (preserve_write)
 		entry = pmd_mk_savedwrite(entry);
+	if (uffd_wp) {
+		entry = pmd_wrprotect(entry);
+		entry = pmd_mkuffd_wp(entry);
+	} else if (uffd_wp_resolve) {
+		/*
+		 * Leave the write bit to be handled by PF interrupt
+		 * handler, then things like COW could be properly
+		 * handled.
+		 */
+		entry = pmd_clear_uffd_wp(entry);
+	}
 	ret = HPAGE_PMD_NR;
 	set_pmd_at(mm, addr, pmd, entry);
 	BUG_ON(vma_is_anonymous(vma) && !preserve_write && pmd_write(entry));
@@ -2125,7 +2138,7 @@ static void __split_huge_pmd_locked(struct vm_area_struct *vma, pmd_t *pmd,
 	struct page *page;
 	pgtable_t pgtable;
 	pmd_t old_pmd, _pmd;
-	bool young, write, soft_dirty, pmd_migration = false;
+	bool young, write, soft_dirty, pmd_migration = false, uffd_wp = false;
 	unsigned long addr;
 	int i;
 
@@ -2207,6 +2220,7 @@ static void __split_huge_pmd_locked(struct vm_area_struct *vma, pmd_t *pmd,
 		write = pmd_write(old_pmd);
 		young = pmd_young(old_pmd);
 		soft_dirty = pmd_soft_dirty(old_pmd);
+		uffd_wp = pmd_uffd_wp(old_pmd);
 	}
 	VM_BUG_ON_PAGE(!page_count(page), page);
 	page_ref_add(page, HPAGE_PMD_NR - 1);
@@ -2240,6 +2254,8 @@ static void __split_huge_pmd_locked(struct vm_area_struct *vma, pmd_t *pmd,
 				entry = pte_mkold(entry);
 			if (soft_dirty)
 				entry = pte_mksoft_dirty(entry);
+			if (uffd_wp)
+				entry = pte_mkuffd_wp(entry);
 		}
 		pte = pte_offset_map(&_pmd, addr);
 		BUG_ON(!pte_none(*pte));
diff --git a/mm/memory.c b/mm/memory.c
index 05bcd741855b..d79e6d1f8c62 100644
--- a/mm/memory.c
+++ b/mm/memory.c
@@ -2579,7 +2579,7 @@ static vm_fault_t do_wp_page(struct vm_fault *vmf)
 {
 	struct vm_area_struct *vma = vmf->vma;
 
-	if (userfaultfd_wp(vma)) {
+	if (userfaultfd_pte_wp(vma, *vmf->pte)) {
 		pte_unmap_unlock(vmf->pte, vmf->ptl);
 		return handle_userfault(vmf, VM_UFFD_WP);
 	}
@@ -3800,7 +3800,7 @@ static inline vm_fault_t create_huge_pmd(struct vm_fault *vmf)
 static inline vm_fault_t wp_huge_pmd(struct vm_fault *vmf, pmd_t orig_pmd)
 {
 	if (vma_is_anonymous(vmf->vma)) {
-		if (userfaultfd_wp(vmf->vma))
+		if (userfaultfd_huge_pmd_wp(vmf->vma, orig_pmd))
 			return handle_userfault(vmf, VM_UFFD_WP);
 		return do_huge_pmd_wp_page(vmf, orig_pmd);
 	}
diff --git a/mm/mprotect.c b/mm/mprotect.c
index ae9caa4c6562..c7066d7384e3 100644
--- a/mm/mprotect.c
+++ b/mm/mprotect.c
@@ -45,6 +45,8 @@ static unsigned long change_pte_range(struct vm_area_struct *vma, pmd_t *pmd,
 	int target_node = NUMA_NO_NODE;
 	bool dirty_accountable = cp_flags & MM_CP_DIRTY_ACCT;
 	bool prot_numa = cp_flags & MM_CP_PROT_NUMA;
+	bool uffd_wp = cp_flags & MM_CP_UFFD_WP;
+	bool uffd_wp_resolve = cp_flags & MM_CP_UFFD_WP_RESOLVE;
 
 	/*
 	 * Can be called with only the mmap_sem for reading by
@@ -116,6 +118,19 @@ static unsigned long change_pte_range(struct vm_area_struct *vma, pmd_t *pmd,
 			if (preserve_write)
 				ptent = pte_mk_savedwrite(ptent);
 
+			if (uffd_wp) {
+				ptent = pte_wrprotect(ptent);
+				ptent = pte_mkuffd_wp(ptent);
+			} else if (uffd_wp_resolve) {
+				/*
+				 * Leave the write bit to be handled
+				 * by PF interrupt handler, then
+				 * things like COW could be properly
+				 * handled.
+				 */
+				ptent = pte_clear_uffd_wp(ptent);
+			}
+
 			/* Avoid taking write faults for known dirty pages */
 			if (dirty_accountable && pte_dirty(ptent) &&
 					(pte_soft_dirty(ptent) ||
@@ -302,6 +317,8 @@ unsigned long change_protection(struct vm_area_struct *vma, unsigned long start,
 {
 	unsigned long pages;
 
+	BUG_ON((cp_flags & MM_CP_UFFD_WP_ALL) == MM_CP_UFFD_WP_ALL);
+
 	if (is_vm_hugetlb_page(vma))
 		pages = hugetlb_change_protection(vma, start, end, newprot);
 	else
diff --git a/mm/userfaultfd.c b/mm/userfaultfd.c
index c8e7846e9b7e..5363376cb07a 100644
--- a/mm/userfaultfd.c
+++ b/mm/userfaultfd.c
@@ -73,8 +73,12 @@ static int mcopy_atomic_pte(struct mm_struct *dst_mm,
 		goto out_release;
 
 	_dst_pte = pte_mkdirty(mk_pte(page, dst_vma->vm_page_prot));
-	if ((dst_vma->vm_flags & VM_WRITE) && !wp_copy)
-		_dst_pte = pte_mkwrite(_dst_pte);
+	if (dst_vma->vm_flags & VM_WRITE) {
+		if (wp_copy)
+			_dst_pte = pte_mkuffd_wp(_dst_pte);
+		else
+			_dst_pte = pte_mkwrite(_dst_pte);
+	}
 
 	dst_pte = pte_offset_map_lock(dst_mm, dst_pmd, dst_addr, &ptl);
 	if (dst_vma->vm_file) {
-- 
2.21.0


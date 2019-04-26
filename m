Return-Path: <SRS0=i6a/=S4=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 6656BC43218
	for <linux-mm@archiver.kernel.org>; Fri, 26 Apr 2019 04:53:50 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 23C0D2089E
	for <linux-mm@archiver.kernel.org>; Fri, 26 Apr 2019 04:53:50 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 23C0D2089E
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id B3BF46B0271; Fri, 26 Apr 2019 00:53:49 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id AEC436B0272; Fri, 26 Apr 2019 00:53:49 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 9DC8F6B0273; Fri, 26 Apr 2019 00:53:49 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f199.google.com (mail-qt1-f199.google.com [209.85.160.199])
	by kanga.kvack.org (Postfix) with ESMTP id 7CDBF6B0271
	for <linux-mm@kvack.org>; Fri, 26 Apr 2019 00:53:49 -0400 (EDT)
Received: by mail-qt1-f199.google.com with SMTP id f20so1908627qtf.3
        for <linux-mm@kvack.org>; Thu, 25 Apr 2019 21:53:49 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references;
        bh=VeXRgvUJi1y1SW+1toogAxaUlYVOD2umH9qWZARvA0w=;
        b=L2SdKQJF+tWF47JfdxDKUaHR9T5ZQN0xOvEoYH2OHgT4NjsEX9xvayaaCBIDTsTZye
         xzjxRSbHfeoBYgSl7xojQejcxcbUMS2HExRh5BTZwO0/btHq/qjlIcBfhJ8pTEItpa0U
         NydN2rxmSLy9VomKwvFdKA1qlvLyIFTb8MX5185Wq7ESIffM/W90+4Y7dZ0PtsZORKRx
         OCYs/sKGzve4UV77ceKx/eRR+93toEkcu4TfL+PDJoY13F5e5k+O8YDu2irqSzIhg6V7
         F7kj4ws3OJvJqBKOSSsxWufLUymEUiplTPkRbP9Nq8ai4VYJtDMVdc1rhPDgMJMrljjP
         qwOA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of peterx@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=peterx@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: APjAAAVOg44lNWvRzKfUTCFoXVp2kJaqiK60+7n7Alcq0UH6x3PP6fxt
	P5yL0gDiC7It9nX/oUQ8Wbq+7wJEaT3l+/v0XeCviHIiLcDLkqzChVJdGn7Wrtz3/T4YpNuML8d
	N8ujbbYohl6q379iGF1uCy4AdgJyJgTmNfBVrO+sKnvKxJdRLnk/7alO4Qwljx32CCA==
X-Received: by 2002:a05:620a:1244:: with SMTP id a4mr242177qkl.282.1556254429281;
        Thu, 25 Apr 2019 21:53:49 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzPD8TgLhkkjPAlXU68f2v1MoHsvCvcGey+upfkABlZkcSHTYvBJQcHso0K2AiIQmh6VBtq
X-Received: by 2002:a05:620a:1244:: with SMTP id a4mr242143qkl.282.1556254428382;
        Thu, 25 Apr 2019 21:53:48 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1556254428; cv=none;
        d=google.com; s=arc-20160816;
        b=lIuoVGvNsIe1q7I7CKEaaVpICvpoYI4Rrpmjz0VYeGSJ9x+FcYol40z2zM5ReYYblj
         fk1k0G5FsrDsRlVkEeKXmCJlss8qkBYEiM0YdFboY/r3/HYCO8TcBac9AV7YBIY2qPFj
         qoJ6DOXfiI1D23Kr/vuLUxCunJYAa1+hU7jeQcST/EZqCLFXjp9zP6ozlRLoMHVacPyd
         CNsQr0zp4wkKzaDA7UsSsy1uDs/uQ71N77vSJ+wWcXodISvBCx+4/MsldbxtlZk66/Uu
         XkeHYTiYCoZD7gnw2iPw5bzqwV8XxwgsqN/j77HvdGNlWnsIQnx6URuzrmiGbUxoX4+n
         k7Zg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=references:in-reply-to:message-id:date:subject:cc:to:from;
        bh=VeXRgvUJi1y1SW+1toogAxaUlYVOD2umH9qWZARvA0w=;
        b=TY42V5YvQVX17D8TNjHwXLqhFt8oVktLzBLQ7DM/n/AG13RoIjegac1F8AjvLVHy8j
         1jNBqOU8zlBWEK4uXdealNlmGnuS1VYZYNeKItRbdGA3PA5J+Zu+gAv+XiFQz8jF0cZp
         vxZpgtFyGPFmbB+HZyRBxZmJLJdIDgqj3jCJdO1RRgqjl9yjEVFZq2ab9a1mAu77tlbj
         eeoT7hsAV4Fr3eJ8WopNNc7u377XospxlfKxgQxrrI7KKypSvkDnQ9SbV7Y4qZsUtgmO
         eP5mjX+f3wpyKW1d0OXAnyWWTl71ODFzMMgNYPDjyKHPewSEY28se4A6YAWjq8zteQzt
         aCEA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of peterx@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=peterx@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id u25si5035342qkj.20.2019.04.25.21.53.48
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 25 Apr 2019 21:53:48 -0700 (PDT)
Received-SPF: pass (google.com: domain of peterx@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of peterx@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=peterx@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx08.intmail.prod.int.phx2.redhat.com [10.5.11.23])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id 861213078ADD;
	Fri, 26 Apr 2019 04:53:47 +0000 (UTC)
Received: from xz-x1.nay.redhat.com (dhcp-15-205.nay.redhat.com [10.66.15.205])
	by smtp.corp.redhat.com (Postfix) with ESMTP id ED6AB17CC5;
	Fri, 26 Apr 2019 04:53:41 +0000 (UTC)
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
Subject: [PATCH v4 12/27] userfaultfd: wp: apply _PAGE_UFFD_WP bit
Date: Fri, 26 Apr 2019 12:51:36 +0800
Message-Id: <20190426045151.19556-13-peterx@redhat.com>
In-Reply-To: <20190426045151.19556-1-peterx@redhat.com>
References: <20190426045151.19556-1-peterx@redhat.com>
X-Scanned-By: MIMEDefang 2.84 on 10.5.11.23
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.48]); Fri, 26 Apr 2019 04:53:47 +0000 (UTC)
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

Reviewed-by: Jerome Glisse <jglisse@redhat.com>
Reviewed-by: Mike Rapoport <rppt@linux.vnet.ibm.com>
Signed-off-by: Peter Xu <peterx@redhat.com>
---
 include/linux/mm.h |  5 +++++
 mm/huge_memory.c   | 14 +++++++++++++-
 mm/memory.c        |  4 ++--
 mm/mprotect.c      | 12 ++++++++++++
 mm/userfaultfd.c   |  8 ++++++--
 5 files changed, 38 insertions(+), 5 deletions(-)

diff --git a/include/linux/mm.h b/include/linux/mm.h
index 086e69d4439d..a5ac81188523 100644
--- a/include/linux/mm.h
+++ b/include/linux/mm.h
@@ -1652,6 +1652,11 @@ extern unsigned long move_page_tables(struct vm_area_struct *vma,
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
index 64d26b1989d2..3885747d4901 100644
--- a/mm/huge_memory.c
+++ b/mm/huge_memory.c
@@ -1907,6 +1907,8 @@ int change_huge_pmd(struct vm_area_struct *vma, pmd_t *pmd,
 	bool preserve_write;
 	int ret;
 	bool prot_numa = cp_flags & MM_CP_PROT_NUMA;
+	bool uffd_wp = cp_flags & MM_CP_UFFD_WP;
+	bool uffd_wp_resolve = cp_flags & MM_CP_UFFD_WP_RESOLVE;
 
 	ptl = __pmd_trans_huge_lock(pmd, vma);
 	if (!ptl)
@@ -1973,6 +1975,13 @@ int change_huge_pmd(struct vm_area_struct *vma, pmd_t *pmd,
 	entry = pmd_modify(entry, newprot);
 	if (preserve_write)
 		entry = pmd_mk_savedwrite(entry);
+	if (uffd_wp) {
+		entry = pmd_wrprotect(entry);
+		entry = pmd_mkuffd_wp(entry);
+	} else if (uffd_wp_resolve) {
+		entry = pmd_mkwrite(entry);
+		entry = pmd_clear_uffd_wp(entry);
+	}
 	ret = HPAGE_PMD_NR;
 	set_pmd_at(mm, addr, pmd, entry);
 	BUG_ON(vma_is_anonymous(vma) && !preserve_write && pmd_write(entry));
@@ -2120,7 +2129,7 @@ static void __split_huge_pmd_locked(struct vm_area_struct *vma, pmd_t *pmd,
 	struct page *page;
 	pgtable_t pgtable;
 	pmd_t old_pmd, _pmd;
-	bool young, write, soft_dirty, pmd_migration = false;
+	bool young, write, soft_dirty, pmd_migration = false, uffd_wp = false;
 	unsigned long addr;
 	int i;
 
@@ -2202,6 +2211,7 @@ static void __split_huge_pmd_locked(struct vm_area_struct *vma, pmd_t *pmd,
 		write = pmd_write(old_pmd);
 		young = pmd_young(old_pmd);
 		soft_dirty = pmd_soft_dirty(old_pmd);
+		uffd_wp = pmd_uffd_wp(old_pmd);
 	}
 	VM_BUG_ON_PAGE(!page_count(page), page);
 	page_ref_add(page, HPAGE_PMD_NR - 1);
@@ -2235,6 +2245,8 @@ static void __split_huge_pmd_locked(struct vm_area_struct *vma, pmd_t *pmd,
 				entry = pte_mkold(entry);
 			if (soft_dirty)
 				entry = pte_mksoft_dirty(entry);
+			if (uffd_wp)
+				entry = pte_mkuffd_wp(entry);
 		}
 		pte = pte_offset_map(&_pmd, addr);
 		BUG_ON(!pte_none(*pte));
diff --git a/mm/memory.c b/mm/memory.c
index 8ccd4927b58d..64bd8075f054 100644
--- a/mm/memory.c
+++ b/mm/memory.c
@@ -2492,7 +2492,7 @@ static vm_fault_t do_wp_page(struct vm_fault *vmf)
 {
 	struct vm_area_struct *vma = vmf->vma;
 
-	if (userfaultfd_wp(vma)) {
+	if (userfaultfd_pte_wp(vma, *vmf->pte)) {
 		pte_unmap_unlock(vmf->pte, vmf->ptl);
 		return handle_userfault(vmf, VM_UFFD_WP);
 	}
@@ -3713,7 +3713,7 @@ static inline vm_fault_t create_huge_pmd(struct vm_fault *vmf)
 static inline vm_fault_t wp_huge_pmd(struct vm_fault *vmf, pmd_t orig_pmd)
 {
 	if (vma_is_anonymous(vmf->vma)) {
-		if (userfaultfd_wp(vmf->vma))
+		if (userfaultfd_huge_pmd_wp(vmf->vma, orig_pmd))
 			return handle_userfault(vmf, VM_UFFD_WP);
 		return do_huge_pmd_wp_page(vmf, orig_pmd);
 	}
diff --git a/mm/mprotect.c b/mm/mprotect.c
index 98091408bd11..732d9b6d1d21 100644
--- a/mm/mprotect.c
+++ b/mm/mprotect.c
@@ -46,6 +46,8 @@ static unsigned long change_pte_range(struct vm_area_struct *vma, pmd_t *pmd,
 	int target_node = NUMA_NO_NODE;
 	bool dirty_accountable = cp_flags & MM_CP_DIRTY_ACCT;
 	bool prot_numa = cp_flags & MM_CP_PROT_NUMA;
+	bool uffd_wp = cp_flags & MM_CP_UFFD_WP;
+	bool uffd_wp_resolve = cp_flags & MM_CP_UFFD_WP_RESOLVE;
 
 	/*
 	 * Can be called with only the mmap_sem for reading by
@@ -117,6 +119,14 @@ static unsigned long change_pte_range(struct vm_area_struct *vma, pmd_t *pmd,
 			if (preserve_write)
 				ptent = pte_mk_savedwrite(ptent);
 
+			if (uffd_wp) {
+				ptent = pte_wrprotect(ptent);
+				ptent = pte_mkuffd_wp(ptent);
+			} else if (uffd_wp_resolve) {
+				ptent = pte_mkwrite(ptent);
+				ptent = pte_clear_uffd_wp(ptent);
+			}
+
 			/* Avoid taking write faults for known dirty pages */
 			if (dirty_accountable && pte_dirty(ptent) &&
 					(pte_soft_dirty(ptent) ||
@@ -301,6 +311,8 @@ unsigned long change_protection(struct vm_area_struct *vma, unsigned long start,
 {
 	unsigned long pages;
 
+	BUG_ON((cp_flags & MM_CP_UFFD_WP_ALL) == MM_CP_UFFD_WP_ALL);
+
 	if (is_vm_hugetlb_page(vma))
 		pages = hugetlb_change_protection(vma, start, end, newprot);
 	else
diff --git a/mm/userfaultfd.c b/mm/userfaultfd.c
index eaecc21806da..240de2a8492d 100644
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
2.17.1


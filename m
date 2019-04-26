Return-Path: <SRS0=i6a/=S4=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 570A8C4321A
	for <linux-mm@archiver.kernel.org>; Fri, 26 Apr 2019 04:53:44 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 0F3242089E
	for <linux-mm@archiver.kernel.org>; Fri, 26 Apr 2019 04:53:44 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 0F3242089E
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id A2CF36B000C; Fri, 26 Apr 2019 00:53:43 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 9DB316B0270; Fri, 26 Apr 2019 00:53:43 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 87D946B0271; Fri, 26 Apr 2019 00:53:43 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f200.google.com (mail-qt1-f200.google.com [209.85.160.200])
	by kanga.kvack.org (Postfix) with ESMTP id 61AD86B000C
	for <linux-mm@kvack.org>; Fri, 26 Apr 2019 00:53:43 -0400 (EDT)
Received: by mail-qt1-f200.google.com with SMTP id k7so1433212qtg.8
        for <linux-mm@kvack.org>; Thu, 25 Apr 2019 21:53:43 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references;
        bh=tdgmvYv2ahMfXs/2KvDiokgAJnqmJRii5iG0BDeDRwU=;
        b=MEmLzKMETc/IBDJLFOoC9b3hMr8cjMRtvGRi09lYNCA0KAVmTd1f34gMzTQ6I+rDzC
         IkKCptJK7+pPZ/Kj+02ZzvfbJmOH1s24EzeMqrATXEQ7tqpQZh9oUUO85dssrXNtV/ic
         Srfk+1HX1DJynpyRLAJvpG2cdKOqdIl4ZyJBt7rcy0KqYTcjG73aJUiJCCUKVXd9dRgB
         MgG1LHe4f0arfY4O01BaiUBpvWrXafM9z/a3JH9lBSwSXvbhum73gdBlvn+5RBPr8Oln
         t1jjJylMPH9tg5NXsunoXMIAxSbXZVlOzHU1NWY5ksy4u95+UEYlYYVMGJ5Jh2mBKoUA
         l75g==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of peterx@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=peterx@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: APjAAAWgVzYTrPu66qR6P8J9whLgDrnJSKJjDlWKAcude0fCri7VCBqK
	SrbWXJyI6ZblYkJDrR0BTn8yVL8Rt8gX5EEHkLksmcn9Aq/KIeWwYCC3LrOPT1G1AhYPLNF8MG0
	vNPqhNiUmIBF96o39BZKhjTpDbf/RSBjnJPH9Z5jlpTUbiB/JqZ/RGzwEQkDUTJ5FSg==
X-Received: by 2002:a37:6897:: with SMTP id d145mr23103246qkc.185.1556254423162;
        Thu, 25 Apr 2019 21:53:43 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzmeesOWdR8UAm3rLdqGA9buIpFGFnKaetxFGfXNoEcCTFalbuUSrejeGylWxxFx+926lyw
X-Received: by 2002:a37:6897:: with SMTP id d145mr23103213qkc.185.1556254422312;
        Thu, 25 Apr 2019 21:53:42 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1556254422; cv=none;
        d=google.com; s=arc-20160816;
        b=y9ZH8TrrOTLOec0mpaGeZRZqX+y7Zv1htYSIE55bPMbPOLeopsyD+pfmPqVVw4rzW3
         QhCJUMzr8sJLJ0hPCtjFrErdkPtUXHHHPccoNjhMUK97cACudmbBWGaAM/rUGm/zRGqw
         qC0OprZzW716LVOoEzbKP6nAJ+HV9Otd5sV2RAuqibrB1+IJg4ZS+tj8WSzZDObQLIno
         njPeorN+7yT1OXnU/7WdLiDfJLQCeS7/NWYHnK/pI36Nw3b0/9loBZZadi85bUX+XQp0
         HIZAVndX2GjgCo6FJby9WTzi1ZIkQ8vAVgD4nxXofUhqbI5J2vGv2opGkKJksyJwcHDi
         SX7A==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=references:in-reply-to:message-id:date:subject:cc:to:from;
        bh=tdgmvYv2ahMfXs/2KvDiokgAJnqmJRii5iG0BDeDRwU=;
        b=DPrpmAo4yJEgYGvrZOeafgKuxHtiwiHrvi75v31Y6LLWovOuO8CAqpgv26FVssaVLl
         nrk3u74wv6qXx8vJUUn9rBrQxNydNZPAaWHfXvAxIDrKwjS41m/vol97/KQTSffjNq7n
         ztf1aZKdDFXo8NgWzl85voqvqw9cJQrg6zhyN6ExyIdYx7sGP94YhzV2xwnOM9gvREyK
         qrJPQaUIkIpLIwLEgVytTf9nuKDUJRKMzGHfiFhWaurZdBenyEbM8aYNJgybr+3Jryxd
         2QU7nXBh/P/4u/rMklgh5+7LXqQ8krse+eDVXF242QRIJklSY/wFINPMVSpauB6SMTQq
         mLag==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of peterx@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=peterx@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id g9si209388qkb.8.2019.04.25.21.53.42
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 25 Apr 2019 21:53:42 -0700 (PDT)
Received-SPF: pass (google.com: domain of peterx@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of peterx@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=peterx@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx08.intmail.prod.int.phx2.redhat.com [10.5.11.23])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id 73420C07DEA3;
	Fri, 26 Apr 2019 04:53:41 +0000 (UTC)
Received: from xz-x1.nay.redhat.com (dhcp-15-205.nay.redhat.com [10.66.15.205])
	by smtp.corp.redhat.com (Postfix) with ESMTP id DBFA5194A0;
	Fri, 26 Apr 2019 04:53:35 +0000 (UTC)
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
Subject: [PATCH v4 11/27] mm: merge parameters for change_protection()
Date: Fri, 26 Apr 2019 12:51:35 +0800
Message-Id: <20190426045151.19556-12-peterx@redhat.com>
In-Reply-To: <20190426045151.19556-1-peterx@redhat.com>
References: <20190426045151.19556-1-peterx@redhat.com>
X-Scanned-By: MIMEDefang 2.84 on 10.5.11.23
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.31]); Fri, 26 Apr 2019 04:53:41 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

change_protection() was used by either the NUMA or mprotect() code,
there's one parameter for each of the callers (dirty_accountable and
prot_numa).  Further, these parameters are passed along the calls:

  - change_protection_range()
  - change_p4d_range()
  - change_pud_range()
  - change_pmd_range()
  - ...

Now we introduce a flag for change_protect() and all these helpers to
replace these parameters.  Then we can avoid passing multiple parameters
multiple times along the way.

More importantly, it'll greatly simplify the work if we want to
introduce any new parameters to change_protection().  In the follow up
patches, a new parameter for userfaultfd write protection will be
introduced.

No functional change at all.

Reviewed-by: Jerome Glisse <jglisse@redhat.com>
Signed-off-by: Peter Xu <peterx@redhat.com>
---
 include/linux/huge_mm.h |  2 +-
 include/linux/mm.h      | 14 +++++++++++++-
 mm/huge_memory.c        |  3 ++-
 mm/mempolicy.c          |  2 +-
 mm/mprotect.c           | 29 ++++++++++++++++-------------
 5 files changed, 33 insertions(+), 17 deletions(-)

diff --git a/include/linux/huge_mm.h b/include/linux/huge_mm.h
index 381e872bfde0..1550fb12dbd4 100644
--- a/include/linux/huge_mm.h
+++ b/include/linux/huge_mm.h
@@ -46,7 +46,7 @@ extern bool move_huge_pmd(struct vm_area_struct *vma, unsigned long old_addr,
 			 pmd_t *old_pmd, pmd_t *new_pmd);
 extern int change_huge_pmd(struct vm_area_struct *vma, pmd_t *pmd,
 			unsigned long addr, pgprot_t newprot,
-			int prot_numa);
+			unsigned long cp_flags);
 vm_fault_t vmf_insert_pfn_pmd(struct vm_area_struct *vma, unsigned long addr,
 			pmd_t *pmd, pfn_t pfn, bool write);
 vm_fault_t vmf_insert_pfn_pud(struct vm_area_struct *vma, unsigned long addr,
diff --git a/include/linux/mm.h b/include/linux/mm.h
index bad93704abc8..086e69d4439d 100644
--- a/include/linux/mm.h
+++ b/include/linux/mm.h
@@ -1641,9 +1641,21 @@ extern unsigned long move_page_tables(struct vm_area_struct *vma,
 		unsigned long old_addr, struct vm_area_struct *new_vma,
 		unsigned long new_addr, unsigned long len,
 		bool need_rmap_locks);
+
+/*
+ * Flags used by change_protection().  For now we make it a bitmap so
+ * that we can pass in multiple flags just like parameters.  However
+ * for now all the callers are only use one of the flags at the same
+ * time.
+ */
+/* Whether we should allow dirty bit accounting */
+#define  MM_CP_DIRTY_ACCT                  (1UL << 0)
+/* Whether this protection change is for NUMA hints */
+#define  MM_CP_PROT_NUMA                   (1UL << 1)
+
 extern unsigned long change_protection(struct vm_area_struct *vma, unsigned long start,
 			      unsigned long end, pgprot_t newprot,
-			      int dirty_accountable, int prot_numa);
+			      unsigned long cp_flags);
 extern int mprotect_fixup(struct vm_area_struct *vma,
 			  struct vm_area_struct **pprev, unsigned long start,
 			  unsigned long end, unsigned long newflags);
diff --git a/mm/huge_memory.c b/mm/huge_memory.c
index 165ea46bf149..64d26b1989d2 100644
--- a/mm/huge_memory.c
+++ b/mm/huge_memory.c
@@ -1899,13 +1899,14 @@ bool move_huge_pmd(struct vm_area_struct *vma, unsigned long old_addr,
  *  - HPAGE_PMD_NR is protections changed and TLB flush necessary
  */
 int change_huge_pmd(struct vm_area_struct *vma, pmd_t *pmd,
-		unsigned long addr, pgprot_t newprot, int prot_numa)
+		unsigned long addr, pgprot_t newprot, unsigned long cp_flags)
 {
 	struct mm_struct *mm = vma->vm_mm;
 	spinlock_t *ptl;
 	pmd_t entry;
 	bool preserve_write;
 	int ret;
+	bool prot_numa = cp_flags & MM_CP_PROT_NUMA;
 
 	ptl = __pmd_trans_huge_lock(pmd, vma);
 	if (!ptl)
diff --git a/mm/mempolicy.c b/mm/mempolicy.c
index 2219e747df49..825053818bcb 100644
--- a/mm/mempolicy.c
+++ b/mm/mempolicy.c
@@ -575,7 +575,7 @@ unsigned long change_prot_numa(struct vm_area_struct *vma,
 {
 	int nr_updated;
 
-	nr_updated = change_protection(vma, addr, end, PAGE_NONE, 0, 1);
+	nr_updated = change_protection(vma, addr, end, PAGE_NONE, MM_CP_PROT_NUMA);
 	if (nr_updated)
 		count_vm_numa_events(NUMA_PTE_UPDATES, nr_updated);
 
diff --git a/mm/mprotect.c b/mm/mprotect.c
index 028c724dcb1a..98091408bd11 100644
--- a/mm/mprotect.c
+++ b/mm/mprotect.c
@@ -37,13 +37,15 @@
 
 static unsigned long change_pte_range(struct vm_area_struct *vma, pmd_t *pmd,
 		unsigned long addr, unsigned long end, pgprot_t newprot,
-		int dirty_accountable, int prot_numa)
+		unsigned long cp_flags)
 {
 	struct mm_struct *mm = vma->vm_mm;
 	pte_t *pte, oldpte;
 	spinlock_t *ptl;
 	unsigned long pages = 0;
 	int target_node = NUMA_NO_NODE;
+	bool dirty_accountable = cp_flags & MM_CP_DIRTY_ACCT;
+	bool prot_numa = cp_flags & MM_CP_PROT_NUMA;
 
 	/*
 	 * Can be called with only the mmap_sem for reading by
@@ -164,7 +166,7 @@ static unsigned long change_pte_range(struct vm_area_struct *vma, pmd_t *pmd,
 
 static inline unsigned long change_pmd_range(struct vm_area_struct *vma,
 		pud_t *pud, unsigned long addr, unsigned long end,
-		pgprot_t newprot, int dirty_accountable, int prot_numa)
+		pgprot_t newprot, unsigned long cp_flags)
 {
 	pmd_t *pmd;
 	unsigned long next;
@@ -194,7 +196,7 @@ static inline unsigned long change_pmd_range(struct vm_area_struct *vma,
 				__split_huge_pmd(vma, pmd, addr, false, NULL);
 			} else {
 				int nr_ptes = change_huge_pmd(vma, pmd, addr,
-						newprot, prot_numa);
+							      newprot, cp_flags);
 
 				if (nr_ptes) {
 					if (nr_ptes == HPAGE_PMD_NR) {
@@ -209,7 +211,7 @@ static inline unsigned long change_pmd_range(struct vm_area_struct *vma,
 			/* fall through, the trans huge pmd just split */
 		}
 		this_pages = change_pte_range(vma, pmd, addr, next, newprot,
-				 dirty_accountable, prot_numa);
+					      cp_flags);
 		pages += this_pages;
 next:
 		cond_resched();
@@ -225,7 +227,7 @@ static inline unsigned long change_pmd_range(struct vm_area_struct *vma,
 
 static inline unsigned long change_pud_range(struct vm_area_struct *vma,
 		p4d_t *p4d, unsigned long addr, unsigned long end,
-		pgprot_t newprot, int dirty_accountable, int prot_numa)
+		pgprot_t newprot, unsigned long cp_flags)
 {
 	pud_t *pud;
 	unsigned long next;
@@ -237,7 +239,7 @@ static inline unsigned long change_pud_range(struct vm_area_struct *vma,
 		if (pud_none_or_clear_bad(pud))
 			continue;
 		pages += change_pmd_range(vma, pud, addr, next, newprot,
-				 dirty_accountable, prot_numa);
+					  cp_flags);
 	} while (pud++, addr = next, addr != end);
 
 	return pages;
@@ -245,7 +247,7 @@ static inline unsigned long change_pud_range(struct vm_area_struct *vma,
 
 static inline unsigned long change_p4d_range(struct vm_area_struct *vma,
 		pgd_t *pgd, unsigned long addr, unsigned long end,
-		pgprot_t newprot, int dirty_accountable, int prot_numa)
+		pgprot_t newprot, unsigned long cp_flags)
 {
 	p4d_t *p4d;
 	unsigned long next;
@@ -257,7 +259,7 @@ static inline unsigned long change_p4d_range(struct vm_area_struct *vma,
 		if (p4d_none_or_clear_bad(p4d))
 			continue;
 		pages += change_pud_range(vma, p4d, addr, next, newprot,
-				 dirty_accountable, prot_numa);
+					  cp_flags);
 	} while (p4d++, addr = next, addr != end);
 
 	return pages;
@@ -265,7 +267,7 @@ static inline unsigned long change_p4d_range(struct vm_area_struct *vma,
 
 static unsigned long change_protection_range(struct vm_area_struct *vma,
 		unsigned long addr, unsigned long end, pgprot_t newprot,
-		int dirty_accountable, int prot_numa)
+		unsigned long cp_flags)
 {
 	struct mm_struct *mm = vma->vm_mm;
 	pgd_t *pgd;
@@ -282,7 +284,7 @@ static unsigned long change_protection_range(struct vm_area_struct *vma,
 		if (pgd_none_or_clear_bad(pgd))
 			continue;
 		pages += change_p4d_range(vma, pgd, addr, next, newprot,
-				 dirty_accountable, prot_numa);
+					  cp_flags);
 	} while (pgd++, addr = next, addr != end);
 
 	/* Only flush the TLB if we actually modified any entries: */
@@ -295,14 +297,15 @@ static unsigned long change_protection_range(struct vm_area_struct *vma,
 
 unsigned long change_protection(struct vm_area_struct *vma, unsigned long start,
 		       unsigned long end, pgprot_t newprot,
-		       int dirty_accountable, int prot_numa)
+		       unsigned long cp_flags)
 {
 	unsigned long pages;
 
 	if (is_vm_hugetlb_page(vma))
 		pages = hugetlb_change_protection(vma, start, end, newprot);
 	else
-		pages = change_protection_range(vma, start, end, newprot, dirty_accountable, prot_numa);
+		pages = change_protection_range(vma, start, end, newprot,
+						cp_flags);
 
 	return pages;
 }
@@ -430,7 +433,7 @@ mprotect_fixup(struct vm_area_struct *vma, struct vm_area_struct **pprev,
 	vma_set_page_prot(vma);
 
 	change_protection(vma, start, end, vma->vm_page_prot,
-			  dirty_accountable, 0);
+			  dirty_accountable ? MM_CP_DIRTY_ACCT : 0);
 
 	/*
 	 * Private VM_LOCKED VMA becoming writable: trigger COW to avoid major
-- 
2.17.1


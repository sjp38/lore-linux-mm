Return-Path: <SRS0=h9qD=RX=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id D9B04C10F03
	for <linux-mm@archiver.kernel.org>; Wed, 20 Mar 2019 02:08:29 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 87BAF217F4
	for <linux-mm@archiver.kernel.org>; Wed, 20 Mar 2019 02:08:29 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 87BAF217F4
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 32C036B0266; Tue, 19 Mar 2019 22:08:29 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 2DC7E6B0269; Tue, 19 Mar 2019 22:08:29 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 1CC6A6B026A; Tue, 19 Mar 2019 22:08:29 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f200.google.com (mail-qt1-f200.google.com [209.85.160.200])
	by kanga.kvack.org (Postfix) with ESMTP id F054D6B0266
	for <linux-mm@kvack.org>; Tue, 19 Mar 2019 22:08:28 -0400 (EDT)
Received: by mail-qt1-f200.google.com with SMTP id q21so902859qtf.10
        for <linux-mm@kvack.org>; Tue, 19 Mar 2019 19:08:28 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references;
        bh=WjdJ9EWZacrUvhsdi8dDMXNpxKcfuPtRIusuzsNon6w=;
        b=WMNEI2CG0JSRHOweK7Q10DBmUYktjiz6cMuSjelP1uFmovzzpbi9+6GxUfjfMfMoXj
         s0E/6nQa6UwNuZNd6GHocl9ldnzpBCyaP1d8EgakUrc+pq+r0Aaiptxn2jEbEj8sh59E
         mSgNjoDgqLgL4BRK8u8VOxGRZwEsmHl+gi2ZCUkNSF3KB2aSKeUyUg2PT2RRMAOO6VBi
         lTOO7yAhg13ZMVnTrSGZmdne+ATOZzRcnVBvEkPgyKHOYMI2UKc0bwij/vtOYjVPzm0i
         QBCpbosYHir59XSYijUoI7i1jPFiGLLVW9k/eFGvPYOXLeMwgUCyh1ORKKOGqqym0QWD
         bl4Q==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of peterx@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=peterx@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: APjAAAXw9wm7ejekBq22yzGnaAocwfuX8XbGYQPEAR4y9GoXfUN4w5Hm
	7Pc0ZicAFvW0qo5amKB/4926NjLHn42ezET1ec1VclLtei485G9leShlShIVBk2IsQ2bbHNaMP9
	ujbs8U/WeOnarRpecMeXI1Dj6AYDEG0DUaxAKLfKhKkn4GprOyvlYx6xKH7qa3r4KoA==
X-Received: by 2002:a37:4d52:: with SMTP id a79mr4483791qkb.75.1553047708738;
        Tue, 19 Mar 2019 19:08:28 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwUE/9Ctj6PL02zEWwsE1I/zvBqZt3TLfMUu18axNSos4tqV78zpjMULOb6yJrxBxf6LkEO
X-Received: by 2002:a37:4d52:: with SMTP id a79mr4483733qkb.75.1553047707294;
        Tue, 19 Mar 2019 19:08:27 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1553047707; cv=none;
        d=google.com; s=arc-20160816;
        b=eOvwA9JAGiGuu9VxTSRpo9X/ihj0xoVHVr+OVQ14zOIiGiWMMN0gjV1x3NUyCd+/GM
         tez/Q2ANXIsthvy23vgkNeHBezPNyEmV7MoH8iVwtarj9vDHIdw+jDWqyiZ5Avy9BR1E
         EAqYwUVx8QBZGRqRbMFIr2sPalO6c88CB5WRpFQ3XlZOVGUL0uXaj/JKdgMDh2K3y4wk
         QIOs9w70oP37jhjEETEOuYzfRgD/+RCsNhJqushbyrppmOrmmMyum5fKR+CitBKaIMpu
         BXP7h+KJ1ImqBjxLnIbGUdJTmCOhelNxkHHoJvnR+/iC5CRwbeGCABaABlfPzC+eEE+U
         tZJA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=references:in-reply-to:message-id:date:subject:cc:to:from;
        bh=WjdJ9EWZacrUvhsdi8dDMXNpxKcfuPtRIusuzsNon6w=;
        b=Rw7cjac2iziVEqmQ2y/PCQ2rlrgWUKuCm/XQhd8ocqxBpXKOe3la9TE6KBE1nw3CxP
         TGekmmigVJNB44it8ZTlv2Upu4fje+eVMnF3ZbY0OUUsKeWOLeQFDnOMLvyavhaG+Oqn
         xhF2pQBUFZllo4eJ1DjlW88spZi4jS7GhNoeEty5xRb8qhS1atvkOVlCsYfjqFfOeYtp
         b4MuJ/fMpQjIsfv1gOuPDO2ixX2xW25uZKUWrxFIm/wmMVHkNQ90kmUckdD7GFrL3Rka
         iSU1Q7G7MSDTuIWBLNuIahuYEKMCNaoJwQu4g6dNmEpRBrkZHBCAQ6C31NF7K/uoyaHG
         YM/A==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of peterx@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=peterx@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id u123si349474qkc.146.2019.03.19.19.08.27
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 19 Mar 2019 19:08:27 -0700 (PDT)
Received-SPF: pass (google.com: domain of peterx@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of peterx@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=peterx@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx01.intmail.prod.int.phx2.redhat.com [10.5.11.11])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id 6F9453086218;
	Wed, 20 Mar 2019 02:08:26 +0000 (UTC)
Received: from xz-x1.nay.redhat.com (dhcp-14-116.nay.redhat.com [10.66.14.116])
	by smtp.corp.redhat.com (Postfix) with ESMTP id B35646014E;
	Wed, 20 Mar 2019 02:08:20 +0000 (UTC)
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
	Andrea Arcangeli <aarcange@redhat.com>,
	Mike Kravetz <mike.kravetz@oracle.com>,
	Denis Plotnikov <dplotnikov@virtuozzo.com>,
	Mike Rapoport <rppt@linux.vnet.ibm.com>,
	Marty McFadden <mcfadden8@llnl.gov>,
	Mel Gorman <mgorman@suse.de>,
	"Kirill A . Shutemov" <kirill@shutemov.name>,
	"Dr . David Alan Gilbert" <dgilbert@redhat.com>
Subject: [PATCH v3 11/28] mm: merge parameters for change_protection()
Date: Wed, 20 Mar 2019 10:06:25 +0800
Message-Id: <20190320020642.4000-12-peterx@redhat.com>
In-Reply-To: <20190320020642.4000-1-peterx@redhat.com>
References: <20190320020642.4000-1-peterx@redhat.com>
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.11
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.42]); Wed, 20 Mar 2019 02:08:26 +0000 (UTC)
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
index f73dbc4a1957..937559a74dc4 100644
--- a/include/linux/mm.h
+++ b/include/linux/mm.h
@@ -1682,9 +1682,21 @@ extern unsigned long move_page_tables(struct vm_area_struct *vma,
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
index faf357eaf0ce..8d65b0f041f9 100644
--- a/mm/huge_memory.c
+++ b/mm/huge_memory.c
@@ -1860,13 +1860,14 @@ bool move_huge_pmd(struct vm_area_struct *vma, unsigned long old_addr,
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
index ee2bce59d2bf..55aed31b4f04 100644
--- a/mm/mempolicy.c
+++ b/mm/mempolicy.c
@@ -554,7 +554,7 @@ unsigned long change_prot_numa(struct vm_area_struct *vma,
 {
 	int nr_updated;
 
-	nr_updated = change_protection(vma, addr, end, PAGE_NONE, 0, 1);
+	nr_updated = change_protection(vma, addr, end, PAGE_NONE, MM_CP_PROT_NUMA);
 	if (nr_updated)
 		count_vm_numa_events(NUMA_PTE_UPDATES, nr_updated);
 
diff --git a/mm/mprotect.c b/mm/mprotect.c
index 36cb358db170..a6ba448c8565 100644
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


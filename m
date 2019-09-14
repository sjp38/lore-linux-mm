Return-Path: <SRS0=RN4K=XJ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-17.6 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,USER_AGENT_GIT,
	USER_IN_DEF_DKIM_WL autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id AB563C49ED6
	for <linux-mm@archiver.kernel.org>; Sat, 14 Sep 2019 07:05:37 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 34FFC2081B
	for <linux-mm@archiver.kernel.org>; Sat, 14 Sep 2019 07:05:37 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=google.com header.i=@google.com header.b="TFt74Cpq"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 34FFC2081B
Authentication-Results: mail.kernel.org; dmarc=fail (p=reject dis=none) header.from=google.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 9B7106B0005; Sat, 14 Sep 2019 03:05:36 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 968796B0006; Sat, 14 Sep 2019 03:05:36 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 87E3B6B0007; Sat, 14 Sep 2019 03:05:36 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0116.hostedemail.com [216.40.44.116])
	by kanga.kvack.org (Postfix) with ESMTP id 68F216B0005
	for <linux-mm@kvack.org>; Sat, 14 Sep 2019 03:05:36 -0400 (EDT)
Received: from smtpin24.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay05.hostedemail.com (Postfix) with SMTP id E484F181AC9AE
	for <linux-mm@kvack.org>; Sat, 14 Sep 2019 07:05:35 +0000 (UTC)
X-FDA: 75932640630.24.wound23_6b09a9a861442
X-HE-Tag: wound23_6b09a9a861442
X-Filterd-Recvd-Size: 12221
Received: from mail-yw1-f74.google.com (mail-yw1-f74.google.com [209.85.161.74])
	by imf43.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Sat, 14 Sep 2019 07:05:35 +0000 (UTC)
Received: by mail-yw1-f74.google.com with SMTP id 132so25491057ywo.13
        for <linux-mm@kvack.org>; Sat, 14 Sep 2019 00:05:35 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=google.com; s=20161025;
        h=date:in-reply-to:message-id:mime-version:references:subject:from:to
         :cc;
        bh=DJvDW0udwitjO1Jctpco23V2LugHZvH/rR3Gw2m+9lg=;
        b=TFt74CpqRx4liyP81l7T8Ew7QkCFUe+kj261h3E+ItvyzspkQtEGjE0oXMmNyQnPty
         SfToHmq8J8bVPdq5+Yb5XqJMpLX1UleGtDOxj4YbMUFYkDGWLTtgdSZpnkSziZgvqKJv
         Nr7X2tWYQJIAIp90Scdy+NlsjO00AO3P/ZMrnbwnMN+0JEv3M5M+y+bAqRBFBk8sDTmX
         xs5hdplc/hCTAifhln6fKvZPYqB0g17lERHnqItwvukMXBOHr7ctTDWfHal76HwBfrxd
         Vpe8qDLa38EL5TyvgGlNw36m9KA94inn5GpN45lZEs//j7R0M/z15KSN+wWDw1tdfyuI
         8cJw==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:date:in-reply-to:message-id:mime-version
         :references:subject:from:to:cc;
        bh=DJvDW0udwitjO1Jctpco23V2LugHZvH/rR3Gw2m+9lg=;
        b=dJK6fn6tA7Tabg9j2JPtvF//wl1GrvAYo2qQbFVwyTXeK7Kje8yNtYN5Y9peTGcXWt
         Te+M89Ih+/9qxc2WhPmTu/xzMRdpI0ZCWK36HYWqXKA3mTBpPdtI0cL8Jc8ZDGc1nsTh
         W3ZJ96QbQnlTZg28GU8/8N3yVyBDIbcOhQaKsD9OVBeWms4vOShdCg+z1nBEipimDgss
         +b1UyrWwgiGfIi6BJNm9ABWYKbFkYvN0loEY006MKqBttw8aGI45V+oLCh3Uk+2Z+dWc
         lYzoCsRUz9p8GSud0T4s9Wy+EDPB130bBOwRTpU/JtInN3W7UR2h1ms//TdsFFUOphoW
         +SKg==
X-Gm-Message-State: APjAAAV/T/Xz0DjAOfxVW0+/c0e0yZEIudivNadEVhsElwJraRtRBizV
	VphlDSBp2vE2LI+HQU/zzPqr8Vy9nLU=
X-Google-Smtp-Source: APXvYqzM6Rh9Smccv9ad2DIffWzTThuMjeU5/uZ8rC//3OTGe9e+fGdlVaLuzgf8FfKoFdLM0HvMcOQVWKE=
X-Received: by 2002:a81:650a:: with SMTP id z10mr9203069ywb.230.1568444734408;
 Sat, 14 Sep 2019 00:05:34 -0700 (PDT)
Date: Sat, 14 Sep 2019 01:05:18 -0600
In-Reply-To: <20190514230751.GA70050@google.com>
Message-Id: <20190914070518.112954-1-yuzhao@google.com>
Mime-Version: 1.0
References: <20190514230751.GA70050@google.com>
X-Mailer: git-send-email 2.23.0.237.gc6a4ce50a0-goog
Subject: [PATCH v2] mm: don't expose page to fast gup prematurely
From: Yu Zhao <yuzhao@google.com>
To: Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@suse.com>
Cc: Peter Zijlstra <peterz@infradead.org>, Ingo Molnar <mingo@redhat.com>, 
	Arnaldo Carvalho de Melo <acme@kernel.org>, Alexander Shishkin <alexander.shishkin@linux.intel.com>, 
	Jiri Olsa <jolsa@redhat.com>, Namhyung Kim <namhyung@kernel.org>, 
	"Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>, Vlastimil Babka <vbabka@suse.cz>, 
	Hugh Dickins <hughd@google.com>, 
	"=?UTF-8?q?J=C3=A9r=C3=B4me=20Glisse?=" <jglisse@redhat.com>, Andrea Arcangeli <aarcange@redhat.com>, 
	"Aneesh Kumar K . V" <aneesh.kumar@linux.ibm.com>, David Rientjes <rientjes@google.com>, 
	Matthew Wilcox <willy@infradead.org>, Lance Roy <ldr709@gmail.com>, 
	Ralph Campbell <rcampbell@nvidia.com>, Jason Gunthorpe <jgg@ziepe.ca>, Dave Airlie <airlied@redhat.com>, 
	Thomas Hellstrom <thellstrom@vmware.com>, Souptick Joarder <jrdr.linux@gmail.com>, 
	Mel Gorman <mgorman@suse.de>, Jan Kara <jack@suse.cz>, Mike Kravetz <mike.kravetz@oracle.com>, 
	Huang Ying <ying.huang@intel.com>, Aaron Lu <ziqian.lzq@antfin.com>, 
	Omar Sandoval <osandov@fb.com>, Thomas Gleixner <tglx@linutronix.de>, 
	Vineeth Remanan Pillai <vpillai@digitalocean.com>, Daniel Jordan <daniel.m.jordan@oracle.com>, 
	Mike Rapoport <rppt@linux.ibm.com>, Joel Fernandes <joel@joelfernandes.org>, 
	linux-kernel@vger.kernel.org, linux-mm@kvack.org, Yu Zhao <yuzhao@google.com>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

We don't want to expose page to fast gup running on a remote CPU
before all local non-atomic ops on page flags are visible first.

For anon page that isn't in swap cache, we need to make sure all
prior non-atomic ops, especially __SetPageSwapBacked() in
page_add_new_anon_rmap(), are order before set_pte_at() to prevent
the following race:

	CPU 1				CPU1
set_pte_at()			get_user_pages_fast()
page_add_new_anon_rmap()		gup_pte_range()
	__SetPageSwapBacked()			SetPageReferenced()

This demonstrates a non-fatal scenario. Though I haven't directly
observed any fatal ones, they can exist, e.g., PG_lock set by fast
gup caller and then overwritten by __SetPageSwapBacked().

For anon page that is in swap cache and file page including tmpfs,
we don't need smp_wmb() before set_pte_at(). We've already exposed
them after adding them to swap and file caches. xas_lock_irq() and
xas_unlock_irq() are used during the process, which guarantees
__SetPageUptodate() and other non-atomic ops are ordered before
set_pte_at(). (Using non-atomic ops thereafter is a bug, obviously).

The smp_wmb() is open-coded rather than inserted at the bottom of
page_add_new_anon_rmap() because there is one place that calls the
function doesn't need the barrier (do_huge_pmd_wp_page_fallback()).

Alternatively, we can use atomic ops instead. There seems at least
as many __SetPageUptodate() and __SetPageSwapBacked() to change.

Signed-off-by: Yu Zhao <yuzhao@google.com>
---
 kernel/events/uprobes.c |  2 ++
 mm/huge_memory.c        |  4 ++++
 mm/khugepaged.c         |  2 ++
 mm/memory.c             | 10 +++++++++-
 mm/migrate.c            |  2 ++
 mm/swapfile.c           |  6 ++++--
 mm/userfaultfd.c        |  2 ++
 7 files changed, 25 insertions(+), 3 deletions(-)

diff --git a/kernel/events/uprobes.c b/kernel/events/uprobes.c
index 84fa00497c49..7069785e2e52 100644
--- a/kernel/events/uprobes.c
+++ b/kernel/events/uprobes.c
@@ -194,6 +194,8 @@ static int __replace_page(struct vm_area_struct *vma, unsigned long addr,
 
 	flush_cache_page(vma, addr, pte_pfn(*pvmw.pte));
 	ptep_clear_flush_notify(vma, addr, pvmw.pte);
+	/* commit non-atomic ops before exposing to fast gup */
+	smp_wmb();
 	set_pte_at_notify(mm, addr, pvmw.pte,
 			mk_pte(new_page, vma->vm_page_prot));
 
diff --git a/mm/huge_memory.c b/mm/huge_memory.c
index de1f15969e27..0be8cee94a5b 100644
--- a/mm/huge_memory.c
+++ b/mm/huge_memory.c
@@ -616,6 +616,8 @@ static vm_fault_t __do_huge_pmd_anonymous_page(struct vm_fault *vmf,
 		mem_cgroup_commit_charge(page, memcg, false, true);
 		lru_cache_add_active_or_unevictable(page, vma);
 		pgtable_trans_huge_deposit(vma->vm_mm, vmf->pmd, pgtable);
+		/* commit non-atomic ops before exposing to fast gup */
+		smp_wmb();
 		set_pmd_at(vma->vm_mm, haddr, vmf->pmd, entry);
 		add_mm_counter(vma->vm_mm, MM_ANONPAGES, HPAGE_PMD_NR);
 		mm_inc_nr_ptes(vma->vm_mm);
@@ -1423,6 +1425,8 @@ vm_fault_t do_huge_pmd_wp_page(struct vm_fault *vmf, pmd_t orig_pmd)
 		page_add_new_anon_rmap(new_page, vma, haddr, true);
 		mem_cgroup_commit_charge(new_page, memcg, false, true);
 		lru_cache_add_active_or_unevictable(new_page, vma);
+		/* commit non-atomic ops before exposing to fast gup */
+		smp_wmb();
 		set_pmd_at(vma->vm_mm, haddr, vmf->pmd, entry);
 		update_mmu_cache_pmd(vma, vmf->address, vmf->pmd);
 		if (!page) {
diff --git a/mm/khugepaged.c b/mm/khugepaged.c
index eaaa21b23215..c703e4b7c9be 100644
--- a/mm/khugepaged.c
+++ b/mm/khugepaged.c
@@ -1081,6 +1081,8 @@ static void collapse_huge_page(struct mm_struct *mm,
 	count_memcg_events(memcg, THP_COLLAPSE_ALLOC, 1);
 	lru_cache_add_active_or_unevictable(new_page, vma);
 	pgtable_trans_huge_deposit(mm, pmd, pgtable);
+	/* commit non-atomic ops before exposing to fast gup */
+	smp_wmb();
 	set_pmd_at(mm, address, pmd, _pmd);
 	update_mmu_cache_pmd(vma, address, pmd);
 	spin_unlock(pmd_ptl);
diff --git a/mm/memory.c b/mm/memory.c
index ea3c74855b23..e56d7df0a206 100644
--- a/mm/memory.c
+++ b/mm/memory.c
@@ -2363,6 +2363,8 @@ static vm_fault_t wp_page_copy(struct vm_fault *vmf)
 		 * mmu page tables (such as kvm shadow page tables), we want the
 		 * new page to be mapped directly into the secondary page table.
 		 */
+		/* commit non-atomic ops before exposing to fast gup */
+		smp_wmb();
 		set_pte_at_notify(mm, vmf->address, vmf->pte, entry);
 		update_mmu_cache(vma, vmf->address, vmf->pte);
 		if (old_page) {
@@ -2873,7 +2875,6 @@ vm_fault_t do_swap_page(struct vm_fault *vmf)
 	flush_icache_page(vma, page);
 	if (pte_swp_soft_dirty(vmf->orig_pte))
 		pte = pte_mksoft_dirty(pte);
-	set_pte_at(vma->vm_mm, vmf->address, vmf->pte, pte);
 	arch_do_swap_page(vma->vm_mm, vma, vmf->address, pte, vmf->orig_pte);
 	vmf->orig_pte = pte;
 
@@ -2882,12 +2883,15 @@ vm_fault_t do_swap_page(struct vm_fault *vmf)
 		page_add_new_anon_rmap(page, vma, vmf->address, false);
 		mem_cgroup_commit_charge(page, memcg, false, false);
 		lru_cache_add_active_or_unevictable(page, vma);
+		/* commit non-atomic ops before exposing to fast gup */
+		smp_wmb();
 	} else {
 		do_page_add_anon_rmap(page, vma, vmf->address, exclusive);
 		mem_cgroup_commit_charge(page, memcg, true, false);
 		activate_page(page);
 	}
 
+	set_pte_at(vma->vm_mm, vmf->address, vmf->pte, pte);
 	swap_free(entry);
 	if (mem_cgroup_swap_full(page) ||
 	    (vma->vm_flags & VM_LOCKED) || PageMlocked(page))
@@ -3030,6 +3034,8 @@ static vm_fault_t do_anonymous_page(struct vm_fault *vmf)
 	page_add_new_anon_rmap(page, vma, vmf->address, false);
 	mem_cgroup_commit_charge(page, memcg, false, false);
 	lru_cache_add_active_or_unevictable(page, vma);
+	/* commit non-atomic ops before exposing to fast gup */
+	smp_wmb();
 setpte:
 	set_pte_at(vma->vm_mm, vmf->address, vmf->pte, entry);
 
@@ -3293,6 +3299,8 @@ vm_fault_t alloc_set_pte(struct vm_fault *vmf, struct mem_cgroup *memcg,
 		page_add_new_anon_rmap(page, vma, vmf->address, false);
 		mem_cgroup_commit_charge(page, memcg, false, false);
 		lru_cache_add_active_or_unevictable(page, vma);
+		/* commit non-atomic ops before exposing to fast gup */
+		smp_wmb();
 	} else {
 		inc_mm_counter_fast(vma->vm_mm, mm_counter_file(page));
 		page_add_file_rmap(page, false);
diff --git a/mm/migrate.c b/mm/migrate.c
index a42858d8e00b..ebfd58d2d606 100644
--- a/mm/migrate.c
+++ b/mm/migrate.c
@@ -2689,6 +2689,8 @@ static void migrate_vma_insert_page(struct migrate_vma *migrate,
 		lru_cache_add_active_or_unevictable(page, vma);
 	get_page(page);
 
+	/* commit non-atomic ops before exposing to fast gup */
+	smp_wmb();
 	if (flush) {
 		flush_cache_page(vma, addr, pte_pfn(*ptep));
 		ptep_clear_flush_notify(vma, addr, ptep);
diff --git a/mm/swapfile.c b/mm/swapfile.c
index 0789a762ce2f..8e2c8ba9f793 100644
--- a/mm/swapfile.c
+++ b/mm/swapfile.c
@@ -1880,8 +1880,6 @@ static int unuse_pte(struct vm_area_struct *vma, pmd_t *pmd,
 	dec_mm_counter(vma->vm_mm, MM_SWAPENTS);
 	inc_mm_counter(vma->vm_mm, MM_ANONPAGES);
 	get_page(page);
-	set_pte_at(vma->vm_mm, addr, pte,
-		   pte_mkold(mk_pte(page, vma->vm_page_prot)));
 	if (page == swapcache) {
 		page_add_anon_rmap(page, vma, addr, false);
 		mem_cgroup_commit_charge(page, memcg, true, false);
@@ -1889,7 +1887,11 @@ static int unuse_pte(struct vm_area_struct *vma, pmd_t *pmd,
 		page_add_new_anon_rmap(page, vma, addr, false);
 		mem_cgroup_commit_charge(page, memcg, false, false);
 		lru_cache_add_active_or_unevictable(page, vma);
+		/* commit non-atomic ops before exposing to fast gup */
+		smp_wmb();
 	}
+	set_pte_at(vma->vm_mm, addr, pte,
+		   pte_mkold(mk_pte(page, vma->vm_page_prot)));
 	swap_free(entry);
 	/*
 	 * Move the page to the active list so it is not
diff --git a/mm/userfaultfd.c b/mm/userfaultfd.c
index c7ae74ce5ff3..4f92913242a1 100644
--- a/mm/userfaultfd.c
+++ b/mm/userfaultfd.c
@@ -92,6 +92,8 @@ static int mcopy_atomic_pte(struct mm_struct *dst_mm,
 	mem_cgroup_commit_charge(page, memcg, false, false);
 	lru_cache_add_active_or_unevictable(page, dst_vma);
 
+	/* commit non-atomic ops before exposing to fast gup */
+	smp_wmb();
 	set_pte_at(dst_mm, dst_addr, dst_pte, _dst_pte);
 
 	/* No need to invalidate - it was non-present before */
-- 
2.23.0.237.gc6a4ce50a0-goog



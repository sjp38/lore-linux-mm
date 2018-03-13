Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f198.google.com (mail-wr0-f198.google.com [209.85.128.198])
	by kanga.kvack.org (Postfix) with ESMTP id 101E06B0012
	for <linux-mm@kvack.org>; Tue, 13 Mar 2018 14:00:39 -0400 (EDT)
Received: by mail-wr0-f198.google.com with SMTP id x8so392011wrg.14
        for <linux-mm@kvack.org>; Tue, 13 Mar 2018 11:00:39 -0700 (PDT)
Received: from mx0a-001b2d01.pphosted.com (mx0b-001b2d01.pphosted.com. [148.163.158.5])
        by mx.google.com with ESMTPS id f24si480231edc.237.2018.03.13.11.00.37
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 13 Mar 2018 11:00:37 -0700 (PDT)
Received: from pps.filterd (m0098414.ppops.net [127.0.0.1])
	by mx0b-001b2d01.pphosted.com (8.16.0.22/8.16.0.22) with SMTP id w2DHsp6A034249
	for <linux-mm@kvack.org>; Tue, 13 Mar 2018 14:00:36 -0400
Received: from e06smtp12.uk.ibm.com (e06smtp12.uk.ibm.com [195.75.94.108])
	by mx0b-001b2d01.pphosted.com with ESMTP id 2gpjjrah45-1
	(version=TLSv1.2 cipher=AES256-SHA256 bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Tue, 13 Mar 2018 14:00:35 -0400
Received: from localhost
	by e06smtp12.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <ldufour@linux.vnet.ibm.com>;
	Tue, 13 Mar 2018 18:00:33 -0000
From: Laurent Dufour <ldufour@linux.vnet.ibm.com>
Subject: [PATCH v9 13/24] mm: Introduce __lru_cache_add_active_or_unevictable
Date: Tue, 13 Mar 2018 18:59:43 +0100
In-Reply-To: <1520963994-28477-1-git-send-email-ldufour@linux.vnet.ibm.com>
References: <1520963994-28477-1-git-send-email-ldufour@linux.vnet.ibm.com>
Message-Id: <1520963994-28477-14-git-send-email-ldufour@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: paulmck@linux.vnet.ibm.com, peterz@infradead.org, akpm@linux-foundation.org, kirill@shutemov.name, ak@linux.intel.com, mhocko@kernel.org, dave@stgolabs.net, jack@suse.cz, Matthew Wilcox <willy@infradead.org>, benh@kernel.crashing.org, mpe@ellerman.id.au, paulus@samba.org, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, hpa@zytor.com, Will Deacon <will.deacon@arm.com>, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>, Andrea Arcangeli <aarcange@redhat.com>, Alexei Starovoitov <alexei.starovoitov@gmail.com>, kemi.wang@intel.com, sergey.senozhatsky.work@gmail.com, Daniel Jordan <daniel.m.jordan@oracle.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, haren@linux.vnet.ibm.com, khandual@linux.vnet.ibm.com, npiggin@gmail.com, bsingharora@gmail.com, Tim Chen <tim.c.chen@linux.intel.com>, linuxppc-dev@lists.ozlabs.org, x86@kernel.org

The speculative page fault handler which is run without holding the
mmap_sem is calling lru_cache_add_active_or_unevictable() but the vm_flags
is not guaranteed to remain constant.
Introducing __lru_cache_add_active_or_unevictable() which has the vma flags
value parameter instead of the vma pointer.

Signed-off-by: Laurent Dufour <ldufour@linux.vnet.ibm.com>
---
 include/linux/swap.h | 10 ++++++++--
 mm/memory.c          |  8 ++++----
 mm/swap.c            |  6 +++---
 3 files changed, 15 insertions(+), 9 deletions(-)

diff --git a/include/linux/swap.h b/include/linux/swap.h
index 1985940af479..a7dc37e0e405 100644
--- a/include/linux/swap.h
+++ b/include/linux/swap.h
@@ -338,8 +338,14 @@ extern void deactivate_file_page(struct page *page);
 extern void mark_page_lazyfree(struct page *page);
 extern void swap_setup(void);
 
-extern void lru_cache_add_active_or_unevictable(struct page *page,
-						struct vm_area_struct *vma);
+extern void __lru_cache_add_active_or_unevictable(struct page *page,
+						unsigned long vma_flags);
+
+static inline void lru_cache_add_active_or_unevictable(struct page *page,
+						struct vm_area_struct *vma)
+{
+	return __lru_cache_add_active_or_unevictable(page, vma->vm_flags);
+}
 
 /* linux/mm/vmscan.c */
 extern unsigned long zone_reclaimable_pages(struct zone *zone);
diff --git a/mm/memory.c b/mm/memory.c
index 412014d5785b..0a0a483d9a65 100644
--- a/mm/memory.c
+++ b/mm/memory.c
@@ -2560,7 +2560,7 @@ static int wp_page_copy(struct vm_fault *vmf)
 		ptep_clear_flush_notify(vma, vmf->address, vmf->pte);
 		page_add_new_anon_rmap(new_page, vma, vmf->address, false);
 		mem_cgroup_commit_charge(new_page, memcg, false, false);
-		lru_cache_add_active_or_unevictable(new_page, vma);
+		__lru_cache_add_active_or_unevictable(new_page, vmf->vma_flags);
 		/*
 		 * We call the notify macro here because, when using secondary
 		 * mmu page tables (such as kvm shadow page tables), we want the
@@ -3083,7 +3083,7 @@ int do_swap_page(struct vm_fault *vmf)
 	if (unlikely(page != swapcache && swapcache)) {
 		page_add_new_anon_rmap(page, vma, vmf->address, false);
 		mem_cgroup_commit_charge(page, memcg, false, false);
-		lru_cache_add_active_or_unevictable(page, vma);
+		__lru_cache_add_active_or_unevictable(page, vmf->vma_flags);
 	} else {
 		do_page_add_anon_rmap(page, vma, vmf->address, exclusive);
 		mem_cgroup_commit_charge(page, memcg, true, false);
@@ -3234,7 +3234,7 @@ static int do_anonymous_page(struct vm_fault *vmf)
 	inc_mm_counter_fast(vma->vm_mm, MM_ANONPAGES);
 	page_add_new_anon_rmap(page, vma, vmf->address, false);
 	mem_cgroup_commit_charge(page, memcg, false, false);
-	lru_cache_add_active_or_unevictable(page, vma);
+	__lru_cache_add_active_or_unevictable(page, vmf->vma_flags);
 setpte:
 	set_pte_at(vma->vm_mm, vmf->address, vmf->pte, entry);
 
@@ -3486,7 +3486,7 @@ int alloc_set_pte(struct vm_fault *vmf, struct mem_cgroup *memcg,
 		inc_mm_counter_fast(vma->vm_mm, MM_ANONPAGES);
 		page_add_new_anon_rmap(page, vma, vmf->address, false);
 		mem_cgroup_commit_charge(page, memcg, false, false);
-		lru_cache_add_active_or_unevictable(page, vma);
+		__lru_cache_add_active_or_unevictable(page, vmf->vma_flags);
 	} else {
 		inc_mm_counter_fast(vma->vm_mm, mm_counter_file(page));
 		page_add_file_rmap(page, false);
diff --git a/mm/swap.c b/mm/swap.c
index 3dd518832096..f2f9c587246f 100644
--- a/mm/swap.c
+++ b/mm/swap.c
@@ -455,12 +455,12 @@ void lru_cache_add(struct page *page)
  * directly back onto it's zone's unevictable list, it does NOT use a
  * per cpu pagevec.
  */
-void lru_cache_add_active_or_unevictable(struct page *page,
-					 struct vm_area_struct *vma)
+void __lru_cache_add_active_or_unevictable(struct page *page,
+					   unsigned long vma_flags)
 {
 	VM_BUG_ON_PAGE(PageLRU(page), page);
 
-	if (likely((vma->vm_flags & (VM_LOCKED | VM_SPECIAL)) != VM_LOCKED))
+	if (likely((vma_flags & (VM_LOCKED | VM_SPECIAL)) != VM_LOCKED))
 		SetPageActive(page);
 	else if (!TestSetPageMlocked(page)) {
 		/*
-- 
2.7.4

Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f198.google.com (mail-wr0-f198.google.com [209.85.128.198])
	by kanga.kvack.org (Postfix) with ESMTP id 759216B03B5
	for <linux-mm@kvack.org>; Thu, 17 Aug 2017 18:06:24 -0400 (EDT)
Received: by mail-wr0-f198.google.com with SMTP id o8so15695742wrg.11
        for <linux-mm@kvack.org>; Thu, 17 Aug 2017 15:06:24 -0700 (PDT)
Received: from mx0a-001b2d01.pphosted.com (mx0b-001b2d01.pphosted.com. [148.163.158.5])
        by mx.google.com with ESMTPS id z187si21778wmc.24.2017.08.17.15.06.22
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 17 Aug 2017 15:06:23 -0700 (PDT)
Received: from pps.filterd (m0098417.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.21/8.16.0.21) with SMTP id v7HM3vpE071331
	for <linux-mm@kvack.org>; Thu, 17 Aug 2017 18:06:21 -0400
Received: from e06smtp15.uk.ibm.com (e06smtp15.uk.ibm.com [195.75.94.111])
	by mx0a-001b2d01.pphosted.com with ESMTP id 2cdeq16jhq-1
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Thu, 17 Aug 2017 18:06:21 -0400
Received: from localhost
	by e06smtp15.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <ldufour@linux.vnet.ibm.com>;
	Thu, 17 Aug 2017 23:06:19 +0100
From: Laurent Dufour <ldufour@linux.vnet.ibm.com>
Subject: [PATCH v2 13/20] mm: Introduce __page_add_new_anon_rmap()
Date: Fri, 18 Aug 2017 00:05:12 +0200
In-Reply-To: <1503007519-26777-1-git-send-email-ldufour@linux.vnet.ibm.com>
References: <1503007519-26777-1-git-send-email-ldufour@linux.vnet.ibm.com>
Message-Id: <1503007519-26777-14-git-send-email-ldufour@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: paulmck@linux.vnet.ibm.com, peterz@infradead.org, akpm@linux-foundation.org, kirill@shutemov.name, ak@linux.intel.com, mhocko@kernel.org, dave@stgolabs.net, jack@suse.cz, Matthew Wilcox <willy@infradead.org>, benh@kernel.crashing.org, mpe@ellerman.id.au, paulus@samba.org, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, hpa@zytor.com, Will Deacon <will.deacon@arm.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, haren@linux.vnet.ibm.com, khandual@linux.vnet.ibm.com, npiggin@gmail.com, bsingharora@gmail.com, Tim Chen <tim.c.chen@linux.intel.com>, linuxppc-dev@lists.ozlabs.org, x86@kernel.org

When dealing with speculative page fault handler, we may race with VMA
being split or merged. In this case the vma->vm_start and vm->vm_end
fields may not match the address the page fault is occurring.

This can only happens when the VMA is split but in that case, the
anon_vma pointer of the new VMA will be the same as the original one,
because in __split_vma the new->anon_vma is set to src->anon_vma when
*new = *vma.

So even if the VMA boundaries are not correct, the anon_vma pointer is
still valid.

If the VMA has been merged, then the VMA in which it has been merged
must have the same anon_vma pointer otherwise the merge can't be done.

So in all the case we know that the anon_vma is valid, since we have
checked before starting the speculative page fault that the anon_vma
pointer is valid for this VMA and since there is an anon_vma this
means that at one time a page has been backed and that before the VMA
is cleaned, the page table lock would have to be grab to clean the
PTE, and the anon_vma field is checked once the PTE is locked.

This patch introduce a new __page_add_new_anon_rmap() service which
doesn't check for the VMA boundaries, and create a new inline one
which do the check.

When called from a page fault handler, if this is not a speculative one,
there is a guarantee that vm_start and vm_end match the faulting address,
so this check is useless. In the context of the speculative page fault
handler, this check may be wrong but anon_vma is still valid as explained
above.

Signed-off-by: Laurent Dufour <ldufour@linux.vnet.ibm.com>
---
 include/linux/rmap.h | 12 ++++++++++--
 mm/memory.c          |  8 ++++----
 mm/rmap.c            |  5 ++---
 3 files changed, 16 insertions(+), 9 deletions(-)

diff --git a/include/linux/rmap.h b/include/linux/rmap.h
index 43ef2c30cb0f..f5cd4dbc78b0 100644
--- a/include/linux/rmap.h
+++ b/include/linux/rmap.h
@@ -170,8 +170,16 @@ void page_add_anon_rmap(struct page *, struct vm_area_struct *,
 		unsigned long, bool);
 void do_page_add_anon_rmap(struct page *, struct vm_area_struct *,
 			   unsigned long, int);
-void page_add_new_anon_rmap(struct page *, struct vm_area_struct *,
-		unsigned long, bool);
+void __page_add_new_anon_rmap(struct page *, struct vm_area_struct *,
+			      unsigned long, bool);
+static inline void page_add_new_anon_rmap(struct page *page,
+					  struct vm_area_struct *vma,
+					  unsigned long address, bool compound)
+{
+	VM_BUG_ON_VMA(address < vma->vm_start || address >= vma->vm_end, vma);
+	__page_add_new_anon_rmap(page, vma, address, compound);
+}
+
 void page_add_file_rmap(struct page *, bool);
 void page_remove_rmap(struct page *, bool);
 
diff --git a/mm/memory.c b/mm/memory.c
index 9f9e5bb7a556..51bc8315281e 100644
--- a/mm/memory.c
+++ b/mm/memory.c
@@ -2376,7 +2376,7 @@ static int wp_page_copy(struct vm_fault *vmf)
 		 * thread doing COW.
 		 */
 		ptep_clear_flush_notify(vma, vmf->address, vmf->pte);
-		page_add_new_anon_rmap(new_page, vma, vmf->address, false);
+		__page_add_new_anon_rmap(new_page, vma, vmf->address, false);
 		mem_cgroup_commit_charge(new_page, memcg, false, false);
 		__lru_cache_add_active_or_unevictable(new_page, vmf->vma_flags);
 		/*
@@ -2847,7 +2847,7 @@ int do_swap_page(struct vm_fault *vmf)
 		mem_cgroup_commit_charge(page, memcg, true, false);
 		activate_page(page);
 	} else { /* ksm created a completely new copy */
-		page_add_new_anon_rmap(page, vma, vmf->address, false);
+		__page_add_new_anon_rmap(page, vma, vmf->address, false);
 		mem_cgroup_commit_charge(page, memcg, false, false);
 		__lru_cache_add_active_or_unevictable(page, vmf->vma_flags);
 	}
@@ -2985,7 +2985,7 @@ static int do_anonymous_page(struct vm_fault *vmf)
 	}
 
 	inc_mm_counter_fast(vma->vm_mm, MM_ANONPAGES);
-	page_add_new_anon_rmap(page, vma, vmf->address, false);
+	__page_add_new_anon_rmap(page, vma, vmf->address, false);
 	mem_cgroup_commit_charge(page, memcg, false, false);
 	__lru_cache_add_active_or_unevictable(page, vmf->vma_flags);
 setpte:
@@ -3237,7 +3237,7 @@ int alloc_set_pte(struct vm_fault *vmf, struct mem_cgroup *memcg,
 	/* copy-on-write page */
 	if (write && !(vmf->vma_flags & VM_SHARED)) {
 		inc_mm_counter_fast(vma->vm_mm, MM_ANONPAGES);
-		page_add_new_anon_rmap(page, vma, vmf->address, false);
+		__page_add_new_anon_rmap(page, vma, vmf->address, false);
 		mem_cgroup_commit_charge(page, memcg, false, false);
 		__lru_cache_add_active_or_unevictable(page, vmf->vma_flags);
 	} else {
diff --git a/mm/rmap.c b/mm/rmap.c
index c1286d47aa1f..0c9f8ded669a 100644
--- a/mm/rmap.c
+++ b/mm/rmap.c
@@ -1122,7 +1122,7 @@ void do_page_add_anon_rmap(struct page *page,
 }
 
 /**
- * page_add_new_anon_rmap - add pte mapping to a new anonymous page
+ * __page_add_new_anon_rmap - add pte mapping to a new anonymous page
  * @page:	the page to add the mapping to
  * @vma:	the vm area in which the mapping is added
  * @address:	the user virtual address mapped
@@ -1132,12 +1132,11 @@ void do_page_add_anon_rmap(struct page *page,
  * This means the inc-and-test can be bypassed.
  * Page does not have to be locked.
  */
-void page_add_new_anon_rmap(struct page *page,
+void __page_add_new_anon_rmap(struct page *page,
 	struct vm_area_struct *vma, unsigned long address, bool compound)
 {
 	int nr = compound ? hpage_nr_pages(page) : 1;
 
-	VM_BUG_ON_VMA(address < vma->vm_start || address >= vma->vm_end, vma);
 	__SetPageSwapBacked(page);
 	if (compound) {
 		VM_BUG_ON_PAGE(!PageTransHuge(page), page);
-- 
2.7.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

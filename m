Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id 44F8B6B0343
	for <linux-mm@kvack.org>; Thu, 27 Apr 2017 11:53:27 -0400 (EDT)
Received: by mail-pf0-f200.google.com with SMTP id q66so29176314pfi.16
        for <linux-mm@kvack.org>; Thu, 27 Apr 2017 08:53:27 -0700 (PDT)
Received: from mx0a-001b2d01.pphosted.com (mx0a-001b2d01.pphosted.com. [148.163.156.1])
        by mx.google.com with ESMTPS id f17si3252610plj.72.2017.04.27.08.53.25
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 27 Apr 2017 08:53:25 -0700 (PDT)
Received: from pps.filterd (m0098396.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.20/8.16.0.20) with SMTP id v3RFqL1Q007529
	for <linux-mm@kvack.org>; Thu, 27 Apr 2017 11:53:25 -0400
Received: from e06smtp12.uk.ibm.com (e06smtp12.uk.ibm.com [195.75.94.108])
	by mx0a-001b2d01.pphosted.com with ESMTP id 2a3j0k57ux-1
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Thu, 27 Apr 2017 11:53:24 -0400
Received: from localhost
	by e06smtp12.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <ldufour@linux.vnet.ibm.com>;
	Thu, 27 Apr 2017 16:53:21 +0100
From: Laurent Dufour <ldufour@linux.vnet.ibm.com>
Subject: [RFC v3 12/17] mm/spf: Protect changes to vm_flags
Date: Thu, 27 Apr 2017 17:52:51 +0200
In-Reply-To: <1493308376-23851-1-git-send-email-ldufour@linux.vnet.ibm.com>
References: <1493308376-23851-1-git-send-email-ldufour@linux.vnet.ibm.com>
Message-Id: <1493308376-23851-13-git-send-email-ldufour@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: paulmck@linux.vnet.ibm.com, peterz@infradead.org, akpm@linux-foundation.org, kirill@shutemov.name, ak@linux.intel.com, mhocko@kernel.org, dave@stgolabs.net, jack@suse.cz
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, haren@linux.vnet.ibm.com, khandual@linux.vnet.ibm.com, npiggin@gmail.com, bsingharora@gmail.com

Protect VMA's flags change against the speculative page fault handler.

Signed-off-by: Laurent Dufour <ldufour@linux.vnet.ibm.com>
---
 fs/proc/task_mmu.c | 2 ++
 mm/mempolicy.c     | 2 ++
 mm/mlock.c         | 9 ++++++---
 mm/mmap.c          | 2 ++
 mm/mprotect.c      | 2 ++
 5 files changed, 14 insertions(+), 3 deletions(-)

diff --git a/fs/proc/task_mmu.c b/fs/proc/task_mmu.c
index 8f96a49178d0..54c9a87530cb 100644
--- a/fs/proc/task_mmu.c
+++ b/fs/proc/task_mmu.c
@@ -1055,8 +1055,10 @@ static ssize_t clear_refs_write(struct file *file, const char __user *buf,
 					goto out_mm;
 				}
 				for (vma = mm->mmap; vma; vma = vma->vm_next) {
+					write_seqcount_begin(&vma->vm_sequence);
 					vma->vm_flags &= ~VM_SOFTDIRTY;
 					vma_set_page_prot(vma);
+					write_seqcount_end(&vma->vm_sequence);
 				}
 				downgrade_write(&mm->mmap_sem);
 				break;
diff --git a/mm/mempolicy.c b/mm/mempolicy.c
index 1e7873e40c9a..1518b022927d 100644
--- a/mm/mempolicy.c
+++ b/mm/mempolicy.c
@@ -603,9 +603,11 @@ unsigned long change_prot_numa(struct vm_area_struct *vma,
 {
 	int nr_updated;
 
+	write_seqcount_begin(&vma->vm_sequence);
 	nr_updated = change_protection(vma, addr, end, PAGE_NONE, 0, 1);
 	if (nr_updated)
 		count_vm_numa_events(NUMA_PTE_UPDATES, nr_updated);
+	write_seqcount_end(&vma->vm_sequence);
 
 	return nr_updated;
 }
diff --git a/mm/mlock.c b/mm/mlock.c
index cdbed8aaa426..44cf70413530 100644
--- a/mm/mlock.c
+++ b/mm/mlock.c
@@ -437,7 +437,9 @@ static unsigned long __munlock_pagevec_fill(struct pagevec *pvec,
 void munlock_vma_pages_range(struct vm_area_struct *vma,
 			     unsigned long start, unsigned long end)
 {
+	write_seqcount_begin(&vma->vm_sequence);
 	vma->vm_flags &= VM_LOCKED_CLEAR_MASK;
+	write_seqcount_end(&vma->vm_sequence);
 
 	while (start < end) {
 		struct page *page;
@@ -563,10 +565,11 @@ static int mlock_fixup(struct vm_area_struct *vma, struct vm_area_struct **prev,
 	 * It's okay if try_to_unmap_one unmaps a page just after we
 	 * set VM_LOCKED, populate_vma_page_range will bring it back.
 	 */
-
-	if (lock)
+	if (lock) {
+		write_seqcount_begin(&vma->vm_sequence);
 		vma->vm_flags = newflags;
-	else
+		write_seqcount_end(&vma->vm_sequence);
+	} else
 		munlock_vma_pages_range(vma, start, end);
 
 out:
diff --git a/mm/mmap.c b/mm/mmap.c
index 27f407d8f7d7..815065d740c4 100644
--- a/mm/mmap.c
+++ b/mm/mmap.c
@@ -1742,6 +1742,7 @@ unsigned long mmap_region(struct file *file, unsigned long addr,
 out:
 	perf_event_mmap(vma);
 
+	write_seqcount_begin(&vma->vm_sequence);
 	vm_stat_account(mm, vm_flags, len >> PAGE_SHIFT);
 	if (vm_flags & VM_LOCKED) {
 		if (!((vm_flags & VM_SPECIAL) || is_vm_hugetlb_page(vma) ||
@@ -1764,6 +1765,7 @@ unsigned long mmap_region(struct file *file, unsigned long addr,
 	vma->vm_flags |= VM_SOFTDIRTY;
 
 	vma_set_page_prot(vma);
+	write_seqcount_end(&vma->vm_sequence);
 
 	return addr;
 
diff --git a/mm/mprotect.c b/mm/mprotect.c
index f9c07f54dd62..646347faf4d5 100644
--- a/mm/mprotect.c
+++ b/mm/mprotect.c
@@ -341,6 +341,7 @@ mprotect_fixup(struct vm_area_struct *vma, struct vm_area_struct **pprev,
 	 * vm_flags and vm_page_prot are protected by the mmap_sem
 	 * held in write mode.
 	 */
+	write_seqcount_begin(&vma->vm_sequence);
 	vma->vm_flags = newflags;
 	dirty_accountable = vma_wants_writenotify(vma, vma->vm_page_prot);
 	vma_set_page_prot(vma);
@@ -356,6 +357,7 @@ mprotect_fixup(struct vm_area_struct *vma, struct vm_area_struct **pprev,
 			(newflags & VM_WRITE)) {
 		populate_vma_page_range(vma, start, end, NULL);
 	}
+	write_seqcount_end(&vma->vm_sequence);
 
 	vm_stat_account(mm, oldflags, -nrpages);
 	vm_stat_account(mm, newflags, nrpages);
-- 
2.7.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

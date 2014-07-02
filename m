Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f177.google.com (mail-wi0-f177.google.com [209.85.212.177])
	by kanga.kvack.org (Postfix) with ESMTP id 200E76B0031
	for <linux-mm@kvack.org>; Wed,  2 Jul 2014 12:50:54 -0400 (EDT)
Received: by mail-wi0-f177.google.com with SMTP id r20so863895wiv.16
        for <linux-mm@kvack.org>; Wed, 02 Jul 2014 09:50:53 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id h9si32557224wjw.163.2014.07.02.09.50.52
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 02 Jul 2014 09:50:53 -0700 (PDT)
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: [PATCH 01/10] mm: madvise MADV_USERFAULT: prepare vm_flags to allow more than 32bits
Date: Wed,  2 Jul 2014 18:50:07 +0200
Message-Id: <1404319816-30229-2-git-send-email-aarcange@redhat.com>
In-Reply-To: <1404319816-30229-1-git-send-email-aarcange@redhat.com>
References: <1404319816-30229-1-git-send-email-aarcange@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: qemu-devel@nongnu.org, kvm@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org
Cc: "\\\"Dr. David Alan Gilbert\\\"" <dgilbert@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Andrew Morton <akpm@linux-foundation.org>, Android Kernel Team <kernel-team@android.com>, Robert Love <rlove@google.com>, Mel Gorman <mel@csn.ul.ie>, Hugh Dickins <hughd@google.com>, Dave Hansen <dave@sr71.net>, Rik van Riel <riel@redhat.com>, Dmitry Adamushko <dmitry.adamushko@gmail.com>, Neil Brown <neilb@suse.de>, Andrea Arcangeli <aarcange@redhat.com>, Mike Hommey <mh@glandium.org>, Taras Glek <tglek@mozilla.com>, Jan Kara <jack@suse.cz>, KOSAKI Motohiro <kosaki.motohiro@gmail.com>, Michel Lespinasse <walken@google.com>, Minchan Kim <minchan@kernel.org>, Keith Packard <keithp@keithp.com>, "Huangpeng (Peter)" <peter.huangpeng@huawei.com>, Isaku Yamahata <yamahata@valinux.co.jp>, Paolo Bonzini <pbonzini@redhat.com>, Anthony Liguori <anthony@codemonkey.ws>, Stefan Hajnoczi <stefanha@gmail.com>, Wenchao Xia <wenchaoqemu@gmail.com>, Andrew Jones <drjones@redhat.com>, Juan Quintela <quintela@redhat.com>, Mel Gorman <mgorman@suse.de>

We run out of 32bits in vm_flags, noop change for 64bit archs.

Signed-off-by: Andrea Arcangeli <aarcange@redhat.com>
---
 fs/proc/task_mmu.c       | 4 ++--
 include/linux/huge_mm.h  | 4 ++--
 include/linux/ksm.h      | 4 ++--
 include/linux/mm_types.h | 2 +-
 mm/huge_memory.c         | 2 +-
 mm/ksm.c                 | 2 +-
 mm/madvise.c             | 2 +-
 mm/mremap.c              | 2 +-
 8 files changed, 11 insertions(+), 11 deletions(-)

diff --git a/fs/proc/task_mmu.c b/fs/proc/task_mmu.c
index cfa63ee..fb91692 100644
--- a/fs/proc/task_mmu.c
+++ b/fs/proc/task_mmu.c
@@ -532,11 +532,11 @@ static void show_smap_vma_flags(struct seq_file *m, struct vm_area_struct *vma)
 	/*
 	 * Don't forget to update Documentation/ on changes.
 	 */
-	static const char mnemonics[BITS_PER_LONG][2] = {
+	static const char mnemonics[BITS_PER_LONG+1][2] = {
 		/*
 		 * In case if we meet a flag we don't know about.
 		 */
-		[0 ... (BITS_PER_LONG-1)] = "??",
+		[0 ... (BITS_PER_LONG)] = "??",
 
 		[ilog2(VM_READ)]	= "rd",
 		[ilog2(VM_WRITE)]	= "wr",
diff --git a/include/linux/huge_mm.h b/include/linux/huge_mm.h
index b826239..3a2c57e 100644
--- a/include/linux/huge_mm.h
+++ b/include/linux/huge_mm.h
@@ -125,7 +125,7 @@ extern void split_huge_page_pmd_mm(struct mm_struct *mm, unsigned long address,
 #error "hugepages can't be allocated by the buddy allocator"
 #endif
 extern int hugepage_madvise(struct vm_area_struct *vma,
-			    unsigned long *vm_flags, int advice);
+			    vm_flags_t *vm_flags, int advice);
 extern void __vma_adjust_trans_huge(struct vm_area_struct *vma,
 				    unsigned long start,
 				    unsigned long end,
@@ -187,7 +187,7 @@ static inline int split_huge_page(struct page *page)
 #define split_huge_page_pmd_mm(__mm, __address, __pmd)	\
 	do { } while (0)
 static inline int hugepage_madvise(struct vm_area_struct *vma,
-				   unsigned long *vm_flags, int advice)
+				   vm_flags_t *vm_flags, int advice)
 {
 	BUG();
 	return 0;
diff --git a/include/linux/ksm.h b/include/linux/ksm.h
index 3be6bb1..8b35253 100644
--- a/include/linux/ksm.h
+++ b/include/linux/ksm.h
@@ -18,7 +18,7 @@ struct mem_cgroup;
 
 #ifdef CONFIG_KSM
 int ksm_madvise(struct vm_area_struct *vma, unsigned long start,
-		unsigned long end, int advice, unsigned long *vm_flags);
+		unsigned long end, int advice, vm_flags_t *vm_flags);
 int __ksm_enter(struct mm_struct *mm);
 void __ksm_exit(struct mm_struct *mm);
 
@@ -94,7 +94,7 @@ static inline int PageKsm(struct page *page)
 
 #ifdef CONFIG_MMU
 static inline int ksm_madvise(struct vm_area_struct *vma, unsigned long start,
-		unsigned long end, int advice, unsigned long *vm_flags)
+		unsigned long end, int advice, vm_flags_t *vm_flags)
 {
 	return 0;
 }
diff --git a/include/linux/mm_types.h b/include/linux/mm_types.h
index 96c5750..cd42c8c 100644
--- a/include/linux/mm_types.h
+++ b/include/linux/mm_types.h
@@ -217,7 +217,7 @@ struct page_frag {
 #endif
 };
 
-typedef unsigned long __nocast vm_flags_t;
+typedef unsigned long long __nocast vm_flags_t;
 
 /*
  * A region containing a mapping of a non-memory backed file under NOMMU
diff --git a/mm/huge_memory.c b/mm/huge_memory.c
index 33514d8..7e0776a 100644
--- a/mm/huge_memory.c
+++ b/mm/huge_memory.c
@@ -1929,7 +1929,7 @@ out:
 #define VM_NO_THP (VM_SPECIAL | VM_HUGETLB | VM_SHARED | VM_MAYSHARE)
 
 int hugepage_madvise(struct vm_area_struct *vma,
-		     unsigned long *vm_flags, int advice)
+		     vm_flags_t *vm_flags, int advice)
 {
 	switch (advice) {
 	case MADV_HUGEPAGE:
diff --git a/mm/ksm.c b/mm/ksm.c
index 346ddc9..6052cf2 100644
--- a/mm/ksm.c
+++ b/mm/ksm.c
@@ -1736,7 +1736,7 @@ static int ksm_scan_thread(void *nothing)
 }
 
 int ksm_madvise(struct vm_area_struct *vma, unsigned long start,
-		unsigned long end, int advice, unsigned long *vm_flags)
+		unsigned long end, int advice, vm_flags_t *vm_flags)
 {
 	struct mm_struct *mm = vma->vm_mm;
 	int err;
diff --git a/mm/madvise.c b/mm/madvise.c
index a402f8f..b31aad1 100644
--- a/mm/madvise.c
+++ b/mm/madvise.c
@@ -49,7 +49,7 @@ static long madvise_behavior(struct vm_area_struct *vma,
 	struct mm_struct *mm = vma->vm_mm;
 	int error = 0;
 	pgoff_t pgoff;
-	unsigned long new_flags = vma->vm_flags;
+	vm_flags_t new_flags = vma->vm_flags;
 
 	switch (behavior) {
 	case MADV_NORMAL:
diff --git a/mm/mremap.c b/mm/mremap.c
index 05f1180..fa7db87 100644
--- a/mm/mremap.c
+++ b/mm/mremap.c
@@ -239,7 +239,7 @@ static unsigned long move_vma(struct vm_area_struct *vma,
 {
 	struct mm_struct *mm = vma->vm_mm;
 	struct vm_area_struct *new_vma;
-	unsigned long vm_flags = vma->vm_flags;
+	vm_flags_t vm_flags = vma->vm_flags;
 	unsigned long new_pgoff;
 	unsigned long moved_len;
 	unsigned long excess = 0;

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f48.google.com (mail-wg0-f48.google.com [74.125.82.48])
	by kanga.kvack.org (Postfix) with ESMTP id 909236B00A1
	for <linux-mm@kvack.org>; Thu, 14 May 2015 13:32:04 -0400 (EDT)
Received: by wgbhc8 with SMTP id hc8so49356019wgb.3
        for <linux-mm@kvack.org>; Thu, 14 May 2015 10:32:04 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id gv10si15500758wib.68.2015.05.14.10.31.46
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 14 May 2015 10:31:47 -0700 (PDT)
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: [PATCH 08/23] userfaultfd: teach vma_merge to merge across vma->vm_userfaultfd_ctx
Date: Thu, 14 May 2015 19:31:05 +0200
Message-Id: <1431624680-20153-9-git-send-email-aarcange@redhat.com>
In-Reply-To: <1431624680-20153-1-git-send-email-aarcange@redhat.com>
References: <1431624680-20153-1-git-send-email-aarcange@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, qemu-devel@nongnu.org, kvm@vger.kernel.org, linux-api@vger.kernel.org
Cc: Pavel Emelyanov <xemul@parallels.com>, Sanidhya Kashyap <sanidhya.gatech@gmail.com>, zhang.zhanghailiang@huawei.com, Linus Torvalds <torvalds@linux-foundation.org>, "Kirill A. Shutemov" <kirill@shutemov.name>, Andres Lagar-Cavilla <andreslc@google.com>, Dave Hansen <dave.hansen@intel.com>, Paolo Bonzini <pbonzini@redhat.com>, Rik van Riel <riel@redhat.com>, Mel Gorman <mgorman@suse.de>, Andy Lutomirski <luto@amacapital.net>, Hugh Dickins <hughd@google.com>, Peter Feiner <pfeiner@google.com>, "Dr. David Alan Gilbert" <dgilbert@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, "Huangpeng (Peter)" <peter.huangpeng@huawei.com>

vma->vm_userfaultfd_ctx is yet another vma parameter that vma_merge
must be aware about so that we can merge vmas back like they were
originally before arming the userfaultfd on some memory range.

Signed-off-by: Andrea Arcangeli <aarcange@redhat.com>
---
 include/linux/mm.h |  2 +-
 mm/madvise.c       |  3 ++-
 mm/mempolicy.c     |  4 ++--
 mm/mlock.c         |  3 ++-
 mm/mmap.c          | 40 +++++++++++++++++++++++++++-------------
 mm/mprotect.c      |  3 ++-
 6 files changed, 36 insertions(+), 19 deletions(-)

diff --git a/include/linux/mm.h b/include/linux/mm.h
index 7fccd22..76376e0 100644
--- a/include/linux/mm.h
+++ b/include/linux/mm.h
@@ -1763,7 +1763,7 @@ extern int vma_adjust(struct vm_area_struct *vma, unsigned long start,
 extern struct vm_area_struct *vma_merge(struct mm_struct *,
 	struct vm_area_struct *prev, unsigned long addr, unsigned long end,
 	unsigned long vm_flags, struct anon_vma *, struct file *, pgoff_t,
-	struct mempolicy *);
+	struct mempolicy *, struct vm_userfaultfd_ctx);
 extern struct anon_vma *find_mergeable_anon_vma(struct vm_area_struct *);
 extern int split_vma(struct mm_struct *,
 	struct vm_area_struct *, unsigned long addr, int new_below);
diff --git a/mm/madvise.c b/mm/madvise.c
index 22e8f0c..d215ea9 100644
--- a/mm/madvise.c
+++ b/mm/madvise.c
@@ -111,7 +111,8 @@ static long madvise_behavior(struct vm_area_struct *vma,
 
 	pgoff = vma->vm_pgoff + ((start - vma->vm_start) >> PAGE_SHIFT);
 	*prev = vma_merge(mm, *prev, start, end, new_flags, vma->anon_vma,
-				vma->vm_file, pgoff, vma_policy(vma));
+			  vma->vm_file, pgoff, vma_policy(vma),
+			  vma->vm_userfaultfd_ctx);
 	if (*prev) {
 		vma = *prev;
 		goto success;
diff --git a/mm/mempolicy.c b/mm/mempolicy.c
index 7477432..eeec77a 100644
--- a/mm/mempolicy.c
+++ b/mm/mempolicy.c
@@ -722,8 +722,8 @@ static int mbind_range(struct mm_struct *mm, unsigned long start,
 		pgoff = vma->vm_pgoff +
 			((vmstart - vma->vm_start) >> PAGE_SHIFT);
 		prev = vma_merge(mm, prev, vmstart, vmend, vma->vm_flags,
-				  vma->anon_vma, vma->vm_file, pgoff,
-				  new_pol);
+				 vma->anon_vma, vma->vm_file, pgoff,
+				 new_pol, vma->vm_userfaultfd_ctx);
 		if (prev) {
 			vma = prev;
 			next = vma->vm_next;
diff --git a/mm/mlock.c b/mm/mlock.c
index 6fd2cf1..25936680 100644
--- a/mm/mlock.c
+++ b/mm/mlock.c
@@ -510,7 +510,8 @@ static int mlock_fixup(struct vm_area_struct *vma, struct vm_area_struct **prev,
 
 	pgoff = vma->vm_pgoff + ((start - vma->vm_start) >> PAGE_SHIFT);
 	*prev = vma_merge(mm, *prev, start, end, newflags, vma->anon_vma,
-			  vma->vm_file, pgoff, vma_policy(vma));
+			  vma->vm_file, pgoff, vma_policy(vma),
+			  vma->vm_userfaultfd_ctx);
 	if (*prev) {
 		vma = *prev;
 		goto success;
diff --git a/mm/mmap.c b/mm/mmap.c
index 9c1c5b9..5f09a7e 100644
--- a/mm/mmap.c
+++ b/mm/mmap.c
@@ -41,6 +41,7 @@
 #include <linux/notifier.h>
 #include <linux/memory.h>
 #include <linux/printk.h>
+#include <linux/userfaultfd_k.h>
 
 #include <asm/uaccess.h>
 #include <asm/cacheflush.h>
@@ -919,7 +920,8 @@ again:			remove_next = 1 + (end > next->vm_end);
  * per-vma resources, so we don't attempt to merge those.
  */
 static inline int is_mergeable_vma(struct vm_area_struct *vma,
-			struct file *file, unsigned long vm_flags)
+				struct file *file, unsigned long vm_flags,
+				struct vm_userfaultfd_ctx vm_userfaultfd_ctx)
 {
 	/*
 	 * VM_SOFTDIRTY should not prevent from VMA merging, if we
@@ -935,6 +937,8 @@ static inline int is_mergeable_vma(struct vm_area_struct *vma,
 		return 0;
 	if (vma->vm_ops && vma->vm_ops->close)
 		return 0;
+	if (!is_mergeable_vm_userfaultfd_ctx(vma, vm_userfaultfd_ctx))
+		return 0;
 	return 1;
 }
 
@@ -965,9 +969,11 @@ static inline int is_mergeable_anon_vma(struct anon_vma *anon_vma1,
  */
 static int
 can_vma_merge_before(struct vm_area_struct *vma, unsigned long vm_flags,
-	struct anon_vma *anon_vma, struct file *file, pgoff_t vm_pgoff)
+		     struct anon_vma *anon_vma, struct file *file,
+		     pgoff_t vm_pgoff,
+		     struct vm_userfaultfd_ctx vm_userfaultfd_ctx)
 {
-	if (is_mergeable_vma(vma, file, vm_flags) &&
+	if (is_mergeable_vma(vma, file, vm_flags, vm_userfaultfd_ctx) &&
 	    is_mergeable_anon_vma(anon_vma, vma->anon_vma, vma)) {
 		if (vma->vm_pgoff == vm_pgoff)
 			return 1;
@@ -984,9 +990,11 @@ can_vma_merge_before(struct vm_area_struct *vma, unsigned long vm_flags,
  */
 static int
 can_vma_merge_after(struct vm_area_struct *vma, unsigned long vm_flags,
-	struct anon_vma *anon_vma, struct file *file, pgoff_t vm_pgoff)
+		    struct anon_vma *anon_vma, struct file *file,
+		    pgoff_t vm_pgoff,
+		    struct vm_userfaultfd_ctx vm_userfaultfd_ctx)
 {
-	if (is_mergeable_vma(vma, file, vm_flags) &&
+	if (is_mergeable_vma(vma, file, vm_flags, vm_userfaultfd_ctx) &&
 	    is_mergeable_anon_vma(anon_vma, vma->anon_vma, vma)) {
 		pgoff_t vm_pglen;
 		vm_pglen = vma_pages(vma);
@@ -1029,7 +1037,8 @@ struct vm_area_struct *vma_merge(struct mm_struct *mm,
 			struct vm_area_struct *prev, unsigned long addr,
 			unsigned long end, unsigned long vm_flags,
 			struct anon_vma *anon_vma, struct file *file,
-			pgoff_t pgoff, struct mempolicy *policy)
+			pgoff_t pgoff, struct mempolicy *policy,
+			struct vm_userfaultfd_ctx vm_userfaultfd_ctx)
 {
 	pgoff_t pglen = (end - addr) >> PAGE_SHIFT;
 	struct vm_area_struct *area, *next;
@@ -1056,14 +1065,17 @@ struct vm_area_struct *vma_merge(struct mm_struct *mm,
 	if (prev && prev->vm_end == addr &&
 			mpol_equal(vma_policy(prev), policy) &&
 			can_vma_merge_after(prev, vm_flags,
-						anon_vma, file, pgoff)) {
+					    anon_vma, file, pgoff,
+					    vm_userfaultfd_ctx)) {
 		/*
 		 * OK, it can.  Can we now merge in the successor as well?
 		 */
 		if (next && end == next->vm_start &&
 				mpol_equal(policy, vma_policy(next)) &&
 				can_vma_merge_before(next, vm_flags,
-					anon_vma, file, pgoff+pglen) &&
+						     anon_vma, file,
+						     pgoff+pglen,
+						     vm_userfaultfd_ctx) &&
 				is_mergeable_anon_vma(prev->anon_vma,
 						      next->anon_vma, NULL)) {
 							/* cases 1, 6 */
@@ -1084,7 +1096,8 @@ struct vm_area_struct *vma_merge(struct mm_struct *mm,
 	if (next && end == next->vm_start &&
 			mpol_equal(policy, vma_policy(next)) &&
 			can_vma_merge_before(next, vm_flags,
-					anon_vma, file, pgoff+pglen)) {
+					     anon_vma, file, pgoff+pglen,
+					     vm_userfaultfd_ctx)) {
 		if (prev && addr < prev->vm_end)	/* case 4 */
 			err = vma_adjust(prev, prev->vm_start,
 				addr, prev->vm_pgoff, NULL);
@@ -1570,8 +1583,8 @@ unsigned long mmap_region(struct file *file, unsigned long addr,
 	/*
 	 * Can we just expand an old mapping?
 	 */
-	vma = vma_merge(mm, prev, addr, addr + len, vm_flags, NULL, file, pgoff,
-			NULL);
+	vma = vma_merge(mm, prev, addr, addr + len, vm_flags,
+			NULL, file, pgoff, NULL, NULL_VM_UFFD_CTX);
 	if (vma)
 		goto out;
 
@@ -2757,7 +2770,7 @@ static unsigned long do_brk(unsigned long addr, unsigned long len)
 
 	/* Can we just expand an old private anonymous mapping? */
 	vma = vma_merge(mm, prev, addr, addr + len, flags,
-					NULL, NULL, pgoff, NULL);
+			NULL, NULL, pgoff, NULL, NULL_VM_UFFD_CTX);
 	if (vma)
 		goto out;
 
@@ -2913,7 +2926,8 @@ struct vm_area_struct *copy_vma(struct vm_area_struct **vmap,
 	if (find_vma_links(mm, addr, addr + len, &prev, &rb_link, &rb_parent))
 		return NULL;	/* should never get here */
 	new_vma = vma_merge(mm, prev, addr, addr + len, vma->vm_flags,
-			vma->anon_vma, vma->vm_file, pgoff, vma_policy(vma));
+			    vma->anon_vma, vma->vm_file, pgoff, vma_policy(vma),
+			    vma->vm_userfaultfd_ctx);
 	if (new_vma) {
 		/*
 		 * Source vma may have been merged into new_vma
diff --git a/mm/mprotect.c b/mm/mprotect.c
index e7d6f11..ef5be8e 100644
--- a/mm/mprotect.c
+++ b/mm/mprotect.c
@@ -292,7 +292,8 @@ mprotect_fixup(struct vm_area_struct *vma, struct vm_area_struct **pprev,
 	 */
 	pgoff = vma->vm_pgoff + ((start - vma->vm_start) >> PAGE_SHIFT);
 	*pprev = vma_merge(mm, *pprev, start, end, newflags,
-			vma->anon_vma, vma->vm_file, pgoff, vma_policy(vma));
+			   vma->anon_vma, vma->vm_file, pgoff, vma_policy(vma),
+			   vma->vm_userfaultfd_ctx);
 	if (*pprev) {
 		vma = *pprev;
 		goto success;

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

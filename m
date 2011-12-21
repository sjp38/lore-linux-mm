Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx133.postini.com [74.125.245.133])
	by kanga.kvack.org (Postfix) with SMTP id 26A666B004D
	for <linux-mm@kvack.org>; Wed, 21 Dec 2011 18:09:45 -0500 (EST)
Date: Wed, 21 Dec 2011 15:09:33 -0800
From: tip-bot for Peter Zijlstra <a.p.zijlstra@chello.nl>
Message-ID: <tip-ab69f41ef93d98d27402440039f805585e5447ac@git.kernel.org>
Reply-To: mingo@redhat.com, hpa@zytor.com, levinsasha928@gmail.com,
        linux-kernel@vger.kernel.org, a.p.zijlstra@chello.nl,
        tglx@linutronix.de, linux-mm@kvack.org
In-Reply-To: <1324470416.10752.1.camel@twins>
References: <1324470416.10752.1.camel@twins>
Subject: [tip:core/urgent] futex: Fix uninterruptible loop due to gate_area
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
Content-Type: text/plain; charset=UTF-8
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-tip-commits@vger.kernel.org
Cc: linux-kernel@vger.kernel.org, levinsasha928@gmail.com, hpa@zytor.com, mingo@redhat.com, a.p.zijlstra@chello.nl, tglx@linutronix.de, linux-mm@kvack.org

Commit-ID:  ab69f41ef93d98d27402440039f805585e5447ac
Gitweb:     http://git.kernel.org/tip/ab69f41ef93d98d27402440039f805585e5447ac
Author:     Peter Zijlstra <a.p.zijlstra@chello.nl>
AuthorDate: Fri, 2 Dec 2011 14:12:06 +0100
Committer:  Thomas Gleixner <tglx@linutronix.de>
CommitDate: Wed, 21 Dec 2011 23:59:17 +0100

futex: Fix uninterruptible loop due to gate_area

It was found (by Sasha) that if you use a futex located in the gate
area we get stuck in an uninterruptible infinite loop, much like the
ZERO_PAGE issue.

While looking at this problem, I realized you'll get into similar
trouble when hitting any install_special_pages() mapping. The solution
chosen was not to modify special_mapping_fault() to install a non-zero
page->mapping because that might lead to issues when freeing these
pages. Instead do a find_vma() when we find we're again in the
!mapping branch.

Reported-by: Sasha Levin <levinsasha928@gmail.com>
Signed-off-by: Peter Zijlstra <a.p.zijlstra@chello.nl>
Cc: linux-mm@kvack.org <linux-mm@kvack.org>
Cc: stable@vger.kernel.org
Link: http://lkml.kernel.org/r/1324470416.10752.1.camel@twins
Signed-off-by: Thomas Gleixner <tglx@linutronix.de>
---
 include/linux/mm.h |    1 +
 kernel/futex.c     |   40 +++++++++++++++++++++++++++++++++++-----
 mm/mmap.c          |    5 +++++
 3 files changed, 41 insertions(+), 5 deletions(-)

diff --git a/include/linux/mm.h b/include/linux/mm.h
index 4baadd1..3025cbc 100644
--- a/include/linux/mm.h
+++ b/include/linux/mm.h
@@ -1395,6 +1395,7 @@ extern int may_expand_vm(struct mm_struct *mm, unsigned long npages);
 extern int install_special_mapping(struct mm_struct *mm,
 				   unsigned long addr, unsigned long len,
 				   unsigned long flags, struct page **pages);
+extern bool is_special_mapping(struct vm_area_struct *vma);
 
 extern unsigned long get_unmapped_area(struct file *, unsigned long, unsigned long, unsigned long, unsigned long);
 
diff --git a/kernel/futex.c b/kernel/futex.c
index ea87f4d..4d66cd3 100644
--- a/kernel/futex.c
+++ b/kernel/futex.c
@@ -59,6 +59,7 @@
 #include <linux/magic.h>
 #include <linux/pid.h>
 #include <linux/nsproxy.h>
+#include <linux/mm.h>
 
 #include <asm/futex.h>
 
@@ -236,7 +237,7 @@ get_futex_key(u32 __user *uaddr, int fshared, union futex_key *key, int rw)
 	unsigned long address = (unsigned long)uaddr;
 	struct mm_struct *mm = current->mm;
 	struct page *page, *page_head;
-	int err, ro = 0;
+	int err, ro = 0, no_mapping_tries = 0;
 
 	/*
 	 * The futex address must be "naturally" aligned.
@@ -317,13 +318,42 @@ again:
 	if (!page_head->mapping) {
 		unlock_page(page_head);
 		put_page(page_head);
+
 		/*
-		* ZERO_PAGE pages don't have a mapping. Avoid a busy loop
-		* trying to find one. RW mapping would have COW'd (and thus
-		* have a mapping) so this page is RO and won't ever change.
-		*/
+		 * ZERO_PAGE pages don't have a mapping. Avoid a busy loop
+		 * trying to find one. RW mapping would have COW'd (and thus
+		 * have a mapping) so this page is RO and won't ever change.
+		 */
 		if ((page_head == ZERO_PAGE(address)))
 			return -EFAULT;
+
+		/*
+		 * Similar problem for the gate area.
+		 */
+		if (in_gate_area(mm, address))
+			return -EFAULT;
+
+		/*
+		 * There is a special class of pages that will have no mapping
+		 * and yet is perfectly valid and not going anywhere. These
+		 * are the pages from install_special_mapping(). Since looking
+		 * up the vma is expensive, don't do so on the first go round.
+		 */
+		if (no_mapping_tries) {
+			struct vm_area_struct *vma;
+
+			err = 0;
+			down_read(&mm->mmap_sem);
+			vma = find_vma(mm, address);
+			if (vma && is_special_mapping(vma))
+				err = -EFAULT;
+			up_read(&mm->mmap_sem);
+
+			if (err)
+				return err;
+		}
+
+		++no_mapping_tries;
 		goto again;
 	}
 
diff --git a/mm/mmap.c b/mm/mmap.c
index eae90af..50fde2e 100644
--- a/mm/mmap.c
+++ b/mm/mmap.c
@@ -2479,6 +2479,11 @@ out:
 	return ret;
 }
 
+bool is_special_mapping(struct vm_area_struct *vma)
+{
+	return vma->vm_ops == &special_mapping_vmops;
+}
+
 static DEFINE_MUTEX(mm_all_locks_mutex);
 
 static void vm_lock_anon_vma(struct mm_struct *mm, struct anon_vma *anon_vma)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

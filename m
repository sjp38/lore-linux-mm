Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id CB28C6B0087
	for <linux-mm@kvack.org>; Fri,  7 Jan 2011 14:06:25 -0500 (EST)
Date: Fri, 7 Jan 2011 20:06:21 +0100
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: [PATCH -mm] KSM on THP
Message-ID: <20110107190620.GT15823@random.random>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, Hugh Dickins <hughd@google.com>
List-ID: <linux-mm.kvack.org>

Hello,

this is the second patch update and it should apply at the end.

======
Subject: KSM on THP

From: Andrea Arcangeli <aarcange@redhat.com>

This makes KSM full operational with THP pages. Subpages are scanned
while the hugepage is still in place and delivering max cpu
performance, and only if there's a match and we're going to
deduplicate memory, the single hugepages with the subpage match is
split.

There will be no false sharing between ksmd and khugepaged. khugepaged
won't collapse 2m virtual regions with KSM pages inside. ksmd also
should only split pages when the checksum matches and we're likely to
split an hugepage for some long living ksm page (usual ksm heuristic
to avoid sharing pages that get de-cowed).

Signed-off-by: Andrea Arcangeli <aarcange@redhat.com>
---

diff --git a/mm/ksm.c b/mm/ksm.c
--- a/mm/ksm.c
+++ b/mm/ksm.c
@@ -412,6 +412,29 @@ out:
 	up_read(&mm->mmap_sem);
 }
 
+static struct page *page_trans_compound_anon(struct page *page)
+{
+	if (PageTransCompound(page)) {
+		struct page *head;
+		head = compound_head(page);
+		/*
+		 * head may be a dangling pointer.
+		 * __split_huge_page_refcount clears PageTail
+		 * before overwriting first_page, so if
+		 * PageTail is still there it means the head
+		 * pointer isn't dangling.
+		 */
+		if (head != page) {
+			smp_rmb();
+			if (!PageTransCompound(page))
+				return NULL;
+		}
+		if (PageAnon(head))
+			return head;
+	}
+	return NULL;
+}
+
 static struct page *get_mergeable_page(struct rmap_item *rmap_item)
 {
 	struct mm_struct *mm = rmap_item->mm;
@@ -431,7 +454,7 @@ static struct page *get_mergeable_page(s
 	page = follow_page(vma, addr, FOLL_GET);
 	if (IS_ERR_OR_NULL(page))
 		goto out;
-	if (PageAnon(page) && !PageTransCompound(page)) {
+	if (PageAnon(page) || page_trans_compound_anon(page)) {
 		flush_anon_page(vma, page, addr);
 		flush_dcache_page(page);
 	} else {
@@ -709,6 +732,7 @@ static int write_protect_page(struct vm_
 	if (addr == -EFAULT)
 		goto out;
 
+	BUG_ON(PageTransCompound(page));
 	ptep = page_check_address(page, mm, addr, &ptl, 0);
 	if (!ptep)
 		goto out;
@@ -784,6 +808,7 @@ static int replace_page(struct vm_area_s
 		goto out;
 
 	pmd = pmd_offset(pud, addr);
+	BUG_ON(pmd_trans_huge(*pmd));
 	if (!pmd_present(*pmd))
 		goto out;
 
@@ -811,6 +836,33 @@ out:
 	return err;
 }
 
+static int page_trans_compound_anon_split(struct page *page)
+{
+	int ret = 0;
+	struct page *transhuge_head = page_trans_compound_anon(page);
+	if (transhuge_head) {
+		/* Get the reference on the head to split it. */
+		if (get_page_unless_zero(transhuge_head)) {
+			/*
+			 * Recheck we got the reference while the head
+			 * was still anonymous.
+			 */
+			if (PageAnon(transhuge_head))
+				ret = split_huge_page(transhuge_head);
+			else
+				/*
+				 * Retry later if split_huge_page run
+				 * from under us.
+				 */
+				ret = 1;
+			put_page(transhuge_head);
+		} else
+			/* Retry later if split_huge_page run from under us. */
+			ret = 1;
+	}
+	return ret;
+}
+
 /*
  * try_to_merge_one_page - take two pages and merge them into one
  * @vma: the vma that holds the pte pointing to page
@@ -831,6 +883,9 @@ static int try_to_merge_one_page(struct 
 
 	if (!(vma->vm_flags & VM_MERGEABLE))
 		goto out;
+	if (PageTransCompound(page) && page_trans_compound_anon_split(page))
+		goto out;
+	BUG_ON(PageTransCompound(page));
 	if (!PageAnon(page))
 		goto out;
 
@@ -1285,14 +1340,8 @@ next_mm:
 				cond_resched();
 				continue;
 			}
-			if (PageTransCompound(*page)) {
-				put_page(*page);
-				ksm_scan.address &= HPAGE_PMD_MASK;
-				ksm_scan.address += HPAGE_PMD_SIZE;
-				cond_resched();
-				continue;
-			}
-			if (PageAnon(*page)) {
+			if (PageAnon(*page) ||
+			    page_trans_compound_anon(*page)) {
 				flush_anon_page(vma, *page, ksm_scan.address);
 				flush_dcache_page(*page);
 				rmap_item = get_next_rmap_item(slot,

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id DA8496B00C2
	for <linux-mm@kvack.org>; Fri,  7 Jan 2011 14:08:48 -0500 (EST)
Date: Fri, 7 Jan 2011 20:08:43 +0100
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: [PATCH -mm] compound_trans_head
Message-ID: <20110107190843.GU15823@random.random>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, Hugh Dickins <hughd@google.com>, Johannes Weiner <jweiner@redhat.com>, Marcelo Tosatti <mtosatti@redhat.com>, Avi Kivity <avi@redhat.com>
List-ID: <linux-mm.kvack.org>

Hello Andrew,

this is the third and last patch and it should apply clean at the
end. It cleanup some code in KVM and KSM with an helper.

=======
Subject: add compound_trans_head helper

From: Andrea Arcangeli <aarcange@redhat.com>

Cleanup some code with common compound_trans_head helper.

Signed-off-by: Andrea Arcangeli <aarcange@redhat.com>
---
 include/linux/huge_mm.h |   18 ++++++++++++++++++
 mm/ksm.c                |   15 +++------------
 virt/kvm/kvm_main.c     |   38 ++++++++++++++------------------------
 3 files changed, 35 insertions(+), 36 deletions(-)

--- a/include/linux/huge_mm.h
+++ b/include/linux/huge_mm.h
@@ -126,6 +126,23 @@ static inline int hpage_nr_pages(struct 
 		return HPAGE_PMD_NR;
 	return 1;
 }
+static inline struct page *compound_trans_head(struct page *page)
+{
+	if (PageTail(page)) {
+		struct page *head;
+		head = page->first_page;
+		smp_rmb();
+		/*
+		 * head may be a dangling pointer.
+		 * __split_huge_page_refcount clears PageTail before
+		 * overwriting first_page, so if PageTail is still
+		 * there it means the head pointer isn't dangling.
+		 */
+		if (PageTail(page))
+			return head;
+	}
+	return page;
+}
 #else /* CONFIG_TRANSPARENT_HUGEPAGE */
 #define HPAGE_PMD_SHIFT ({ BUG(); 0; })
 #define HPAGE_PMD_MASK ({ BUG(); 0; })
@@ -144,6 +161,7 @@ static inline int split_huge_page(struct
 	do { } while (0)
 #define wait_split_huge_page(__anon_vma, __pmd)	\
 	do { } while (0)
+#define compound_trans_head(page) compound_head(page)
 static inline int hugepage_madvise(struct vm_area_struct *vma,
 				   unsigned long *vm_flags, int advice)
 {
--- a/mm/ksm.c
+++ b/mm/ksm.c
@@ -415,20 +415,11 @@ out:
 static struct page *page_trans_compound_anon(struct page *page)
 {
 	if (PageTransCompound(page)) {
-		struct page *head;
-		head = compound_head(page);
+		struct page *head = compound_trans_head(page);
 		/*
-		 * head may be a dangling pointer.
-		 * __split_huge_page_refcount clears PageTail
-		 * before overwriting first_page, so if
-		 * PageTail is still there it means the head
-		 * pointer isn't dangling.
+		 * head may actually be splitted and freed from under
+		 * us but it's ok here.
 		 */
-		if (head != page) {
-			smp_rmb();
-			if (!PageTransCompound(page))
-				return NULL;
-		}
 		if (PageAnon(head))
 			return head;
 	}
--- a/virt/kvm/kvm_main.c
+++ b/virt/kvm/kvm_main.c
@@ -103,34 +103,24 @@ static pfn_t fault_pfn;
 inline int kvm_is_mmio_pfn(pfn_t pfn)
 {
 	if (pfn_valid(pfn)) {
-		struct page *head;
+		int reserved;
 		struct page *tail = pfn_to_page(pfn);
-		head = compound_head(tail);
+		struct page *head = compound_trans_head(tail);
+		reserved = PageReserved(head);
 		if (head != tail) {
-			smp_rmb();
 			/*
-			 * head may be a dangling pointer.
-			 * __split_huge_page_refcount clears PageTail
-			 * before overwriting first_page, so if
-			 * PageTail is still there it means the head
-			 * pointer isn't dangling.
+			 * "head" is not a dangling pointer
+			 * (compound_trans_head takes care of that)
+			 * but the hugepage may have been splitted
+			 * from under us (and we may not hold a
+			 * reference count on the head page so it can
+			 * be reused before we run PageReferenced), so
+			 * we've to check PageTail before returning
+			 * what we just read.
 			 */
-			if (PageTail(tail)) {
-				/*
-				 * the "head" is not a dangling
-				 * pointer but the hugepage may have
-				 * been splitted from under us (and we
-				 * may not hold a reference count on
-				 * the head page so it can be reused
-				 * before we run PageReferenced), so
-				 * we've to recheck PageTail before
-				 * returning what we just read.
-				 */
-				int reserved = PageReserved(head);
-				smp_rmb();
-				if (PageTail(tail))
-					return reserved;
-			}
+			smp_rmb();
+			if (PageTail(tail))
+				return reserved;
 		}
 		return PageReserved(tail);
 	}

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

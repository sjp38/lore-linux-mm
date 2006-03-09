Message-Id: <200603091126.k29BQlg19037@unix-os.sc.intel.com>
From: "Chen, Kenneth W" <kenneth.w.chen@intel.com>
Subject: [patch] optimize follow_hugetlb_page
Date: Thu, 9 Mar 2006 03:26:49 -0800
MIME-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: wli@holomorphy.com, 'Andrew Morton' <akpm@osdl.org>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

follow_hugetlb_page walks a range of user virtual address and then
fills in list of struct page * into an array that is passed from
the argument list.  It also gets a reference count via get_page().
For compound page, get_page() actually traverse back to head page
via page_private() macro and then adds a reference count to the
head page.  Since we are doing a virt to pte look up, kernel already
has a struct page pointer into the head page.  So instead of traverse
into the small unit page struct and then follow a link back to the
head page, optimize that with incrementing the reference count
directly on the head page.

The benefit is that we don't take a cache miss on accessing page
struct for the corresponding user address and more importantly, not
to pollute the cache with a "not very useful" round trip of pointer
chasing.  This adds a moderate performance gain on an I/O intensive
database transaction workload.


Signed-off-by: Ken Chen <kenneth.w.chen@intel.com>


--- ./mm/hugetlb.c.orig	2006-02-22 18:57:37.218102659 -0800
+++ ./mm/hugetlb.c	2006-02-22 20:49:33.008059453 -0800
@@ -521,10 +521,9 @@ int follow_hugetlb_page(struct mm_struct
 			struct page **pages, struct vm_area_struct **vmas,
 			unsigned long *position, int *length, int i)
 {
-	unsigned long vpfn, vaddr = *position;
+	unsigned long pidx, vaddr = *position;
 	int remainder = *length;
 
-	vpfn = vaddr/PAGE_SIZE;
 	spin_lock(&mm->page_table_lock);
 	while (vaddr < vma->vm_end && remainder) {
 		pte_t *pte;
@@ -552,19 +551,23 @@ int follow_hugetlb_page(struct mm_struct
 			break;
 		}
 
-		if (pages) {
-			page = &pte_page(*pte)[vpfn % (HPAGE_SIZE/PAGE_SIZE)];
-			get_page(page);
-			pages[i] = page;
-		}
+		pidx = (vaddr & ~HPAGE_MASK) >> PAGE_SHIFT;
+		page = pte_page(*pte);
+same_page:
+		get_page(page);
+		if (pages)
+			pages[i] = page + pidx;
 
 		if (vmas)
 			vmas[i] = vma;
 
 		vaddr += PAGE_SIZE;
-		++vpfn;
+		++pidx;
 		--remainder;
 		++i;
+		if (vaddr < vma->vm_end && remainder &&
+		    pidx < HPAGE_SIZE/PAGE_SIZE)
+			goto same_page;
 	}
 	spin_unlock(&mm->page_table_lock);
 	*length = remainder;



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

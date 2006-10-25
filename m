Date: Wed, 25 Oct 2006 16:26:10 +1000
From: David Gibson <david@gibson.dropbear.id.au>
Subject: Re: [PATCH 3/3] hugetlb: fix absurd HugePages_Rsvd
Message-ID: <20061025062610.GB2330@localhost.localdomain>
References: <Pine.LNX.4.64.0610250323570.30678@blonde.wat.veritas.com> <Pine.LNX.4.64.0610250335530.30678@blonde.wat.veritas.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.64.0610250335530.30678@blonde.wat.veritas.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Hugh Dickins <hugh@veritas.com>
Cc: Andrew Morton <akpm@osdl.org>, Ken Chen <kenneth.w.chen@intel.com>, Bill Irwin <wli@holomorphy.com>, Adam Litke <agl@us.ibm.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, Oct 25, 2006 at 03:38:24AM +0100, Hugh Dickins wrote:
> If you truncated an mmap'ed hugetlbfs file, then faulted on the truncated
> area, /proc/meminfo's HugePages_Rsvd wrapped hugely "negative".  Reinstate
> my preliminary i_size check before attempting to allocate the page (though
> this only fixes the most obvious case: more work will be needed here).
> 
> Signed-off-by: Hugh Dickins <hugh@veritas.com>
> ___
> 
> This is not a complete solution (what if hugetlb_no_page is actually
> racing with truncate_hugepages?), and there are several other accounting
> anomalies in here (private versus shared pages, hugetlbfs quota handling);
> but those all need more thought.  It'll probably make sense to use i_mutex
> instead of hugetlb_instantiation_mutex, so locking out truncation
> and mmap.

Ah, yes.  I also encountered this one a few days ago - I found it in
the context of deserializing the hugepage fault path, which makes the
problem worse, and forgot to consider if there was also a problem in
the original case.

In fact, there's a second problem with the current location of the
i_size check.  As well as wrapping the reserved count, if there's a
fault on a truncated area and the hugepage pool is also empty, we can
get an OOM SIGKILL instead of the correct SIGBUS.

I don't things are quite as bad as you fear, though:  I believe the
page lock protects us against racing concurrent truncations (this is
one reason we have find_lock_page() here, rather than the
find_get_page() which appears in the analagous normal page path).

I suggest the slightly revised patch below, which doesn't duplicate
the i_size test, and cleans up the backout path (removing a
no-longer-useful goto label) in the process.

hugepage: Correct i_size test to fix some corner cases

If you truncated an mmap'ed hugetlbfs file, then faulted on the
truncated area, /proc/meminfo's HugePages_Rsvd wrapped hugely
"negative".  In addition, faulting on the truncated area when the
hugepage pool was also exhausted could result in a VM OOM SIGKILL
instead of the correct SIGBUS.

Correct these by moving the i_size check to before the allocation of a
new page.

Signed-off-by: Hugh Dickins <hugh@veritas.com>
Signed-off-by: David Gibson <david@gibson.dropbear.id.au>

 mm/hugetlb.c |   36 +++++++++++++++++++++++-------------
 1 file changed, 23 insertions(+), 13 deletions(-)

Index: working-2.6/mm/hugetlb.c
===================================================================
--- working-2.6.orig/mm/hugetlb.c	2006-10-25 16:04:12.000000000 +1000
+++ working-2.6/mm/hugetlb.c	2006-10-25 16:18:17.000000000 +1000
@@ -477,6 +477,22 @@ int hugetlb_no_page(struct mm_struct *mm
 	 */
 retry:
 	page = find_lock_page(mapping, idx);
+	/* In the case the page exists, we want to lock it before we
+	 * check against i_size to guard against racing truncations.
+	 * In the case it doesn't exist, we have to check against
+	 * i_size before attempting to allocate a page, or we could
+	 * get the wrong error if we're also out of hugepages in the
+	 * pool (OOM instead of SIGBUS).  So the i_size test has to go
+	 * in this slightly odd location. */
+	size = i_size_read(mapping->host) >> HPAGE_SHIFT;
+	if (idx >= size) {
+		hugetlb_put_quota(mapping);
+		if (page) {
+			unlock_page(page);
+			put_page(page);
+		}
+		return VM_FAULT_SIGBUS;
+	}
 	if (!page) {
 		if (hugetlb_get_quota(mapping))
 			goto out;
@@ -504,13 +520,14 @@ retry:
 	}
 
 	spin_lock(&mm->page_table_lock);
-	size = i_size_read(mapping->host) >> HPAGE_SHIFT;
-	if (idx >= size)
-		goto backout;
-
 	ret = VM_FAULT_MINOR;
-	if (!pte_none(*ptep))
-		goto backout;
+	if (!pte_none(*ptep)) {
+		spin_unlock(&mm->page_table_lock);
+		hugetlb_put_quota(mapping);
+		unlock_page(page);
+		put_page(page);
+		goto out;
+	}
 
 	add_mm_counter(mm, file_rss, HPAGE_SIZE / PAGE_SIZE);
 	new_pte = make_huge_pte(vma, page, ((vma->vm_flags & VM_WRITE)
@@ -526,13 +543,6 @@ retry:
 	unlock_page(page);
 out:
 	return ret;
-
-backout:
-	spin_unlock(&mm->page_table_lock);
-	hugetlb_put_quota(mapping);
-	unlock_page(page);
-	put_page(page);
-	goto out;
 }
 
 int hugetlb_fault(struct mm_struct *mm, struct vm_area_struct *vma,


-- 
David Gibson			| I'll have my music baroque, and my code
david AT gibson.dropbear.id.au	| minimalist, thank you.  NOT _the_ _other_
				| _way_ _around_!
http://www.ozlabs.org/~dgibson

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

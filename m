Subject: Re: [rfc][patch] mm: madvise(WILLNEED) for anonymous memory
From: Peter Zijlstra <peterz@infradead.org>
In-Reply-To: <1198162560.6821.30.camel@twins>
References: <1198155938.6821.3.camel@twins>
	 <Pine.LNX.4.64.0712201339010.18399@blonde.wat.veritas.com>
	 <1198162078.6821.27.camel@twins>  <1198162560.6821.30.camel@twins>
Content-Type: text/plain
Date: Thu, 20 Dec 2007 16:18:28 +0100
Message-Id: <1198163908.6821.33.camel@twins>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Hugh Dickins <hugh@veritas.com>
Cc: linux-kernel <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Nick Piggin <npiggin@suse.de>, riel <riel@redhat.com>, Lennart Poettering <mztabzr@0pointer.de>
List-ID: <linux-mm.kvack.org>

On Thu, 2007-12-20 at 15:56 +0100, Peter Zijlstra wrote:
> On Thu, 2007-12-20 at 15:47 +0100, Peter Zijlstra wrote:
> > On Thu, 2007-12-20 at 14:09 +0000, Hugh Dickins wrote:
> 
> > > Interesting divergence: make_pages_present faults in writable pages
> > > in a writable vma, whereas the file case's force_page_cache_readahead
> > > doesn't even insert the pages into the mm.
> > 
> > Yeah, the find_vma and write fault thing are the reason I didn't use
> > make_pages_present.
> > 
> > I had noticed the difference in pte population between
> > force_page_cache_readahead and make_pages_present, but it seemed to me
> > that writing a function to walk the page tables and populate the
> > swapcache but not populate the ptes wasn't worth the effort.
> 
> Ah, another, more important difference:
> 
> force_page_cache_readahead will not wait for the read to complete,
> whereas get_user_pages() will be fully synchronous.
> 
> I think I'd better come up with something else then,..

Depending on the page table walk from -mm

---
A best effort implementation of madvise(WILLNEED) for anonymous pages.

Signed-off-by: Peter Zijlstra <a.p.zijlstra@chello.nl>
---
diff --git a/mm/madvise.c b/mm/madvise.c
index 93ee375..e6f772a 100644
--- a/mm/madvise.c
+++ b/mm/madvise.c
@@ -11,6 +11,8 @@
 #include <linux/mempolicy.h>
 #include <linux/hugetlb.h>
 #include <linux/sched.h>
+#include <linux/swap.h>
+#include <linux/swapops.h>
 
 /*
  * Any behaviour which results in changes to the vma->vm_flags needs to
@@ -100,6 +102,34 @@ out:
 	return error;
 }
 
+static int madvise_willneed_anon_pte(pte_t *ptep,
+		unsigned long start, unsigned long end, void *arg)
+{
+	struct vm_area_struct *vma = arg;
+	struct page *page;
+
+	page = read_swap_cache_async(pte_to_swp_entry(*ptep), GFP_KERNEL,
+			vma, start);
+	if (page)
+		page_cache_release(page);
+
+	return 0;
+}
+
+static long madvise_willneed_anon(struct vm_area_struct * vma,
+				  struct vm_area_struct ** prev,
+				  unsigned long start, unsigned long end)
+{
+	struct mm_walk walk = {
+		.pte_entry = madvise_willneed_anon_pte,
+	};
+
+	*prev = vma;
+	walk_page_range(vma->vm_mm, start, end, &walk, vma);
+
+	return 0;
+}
+
 /*
  * Schedule all required I/O operations.  Do not wait for completion.
  */
@@ -110,7 +140,7 @@ static long madvise_willneed(struct vm_area_struct * vma,
 	struct file *file = vma->vm_file;
 
 	if (!file)
-		return -EBADF;
+		return madvise_willneed_anon(vma, prev, start, end);
 
 	if (file->f_mapping->a_ops->get_xip_page) {
 		/* no bad return value, but ignore advice */


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

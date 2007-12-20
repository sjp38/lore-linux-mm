Subject: Re: [rfc][patch] mm: madvise(WILLNEED) for anonymous memory
From: Peter Zijlstra <peterz@infradead.org>
In-Reply-To: <Pine.LNX.4.64.0712201508290.857@blonde.wat.veritas.com>
References: <1198155938.6821.3.camel@twins>
	 <Pine.LNX.4.64.0712201339010.18399@blonde.wat.veritas.com>
	 <1198162078.6821.27.camel@twins>
	 <Pine.LNX.4.64.0712201508290.857@blonde.wat.veritas.com>
Content-Type: text/plain
Date: Thu, 20 Dec 2007 17:53:41 +0100
Message-Id: <1198169621.6821.44.camel@twins>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Hugh Dickins <hugh@veritas.com>
Cc: linux-kernel <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Nick Piggin <npiggin@suse.de>, riel <riel@redhat.com>, Lennart Poettering <mztabzr@0pointer.de>, mpm <mpm@selenic.com>
List-ID: <linux-mm.kvack.org>

On Thu, 2007-12-20 at 15:26 +0000, Hugh Dickins wrote:

> The asynch code: perhaps not worth doing for MADV_WILLNEED alone,
> but might prove useful for more general use when swapping in.
> Not really the same as Con's swap prefetch, but worth looking
> at that for reference.  But I guess this becomes a much bigger
> issue than you were intending to get into here.

heh, yeah, got somewhat more complex that I'd hoped for.

last patch for today (not even compile tested), will do a proper patch
and test it tomorrow.

---
A best effort MADV_WILLNEED implementation for anonymous memory.

It adds a batch method to the page table walk routines so we can
copy a few ptes while holding the kmap, which makes it possible to
allocate the backing pages using GFP_KERNEL.

Signed-off-by: Peter Zijlstra <a.p.zijlstra@chello.nl>
---
diff --git a/include/linux/mm.h b/include/linux/mm.h
index 5c3655f..391a453 100644
--- a/include/linux/mm.h
+++ b/include/linux/mm.h
@@ -726,6 +726,7 @@ unsigned long unmap_vmas(struct mmu_gather **tlb,
  * @pmd_entry: if set, called for each non-empty PMD (3rd-level) entry
  * @pte_entry: if set, called for each non-empty PTE (4th-level) entry
  * @pte_hole: if set, called for each hole at all levels
+ * @pte_batch: if set, called for each %WALK_BATCH_SIZE PTE entries.
  *
  * (see walk_page_range for more details)
  */
@@ -735,8 +736,16 @@ struct mm_walk {
 	int (*pmd_entry)(pmd_t *, unsigned long, unsigned long, void *);
 	int (*pte_entry)(pte_t *, unsigned long, unsigned long, void *);
 	int (*pte_hole)(unsigned long, unsigned long, void *);
+	int (*pte_batch)(unsigned long, unsigned long, void *);
 };
 
+#define WALK_BATCH_SIZE	32
+
+static inline walk_addr_index(unsigned long addr)
+{
+	return (addr >> PAGE_SHIFT) % WALK_BATCH_SIZE;
+}
+
 int walk_page_range(const struct mm_struct *, unsigned long addr,
 		    unsigned long end, const struct mm_walk *walk,
 		    void *private);
diff --git a/mm/madvise.c b/mm/madvise.c
index 93ee375..86610a0 100644
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
@@ -100,17 +102,71 @@ out:
 	return error;
 }
 
+struct madvise_willneed_anon_data {
+	pte_t entries[WALK_BATCH_SIZE];
+	struct vm_area_struct *vma;
+}
+
+static int madvise_willneed_anon_pte(pte_t *ptep,
+		unsigned long addr, unsigned long end, void *arg)
+{
+	struct madvise_willneed_anon_data *data = arg;
+
+	data->entries[walk_addr_index(addr)] = *ptep;
+
+	return 0;
+}
+
+static int madvise_willneed_anon_batch(unsigned long addr,
+		unsigned long end, void *arg)
+{
+	struct madvise_willneed_anon_data *data = arg;
+	unsigned int i;
+
+	for (; addr != end; addr += PAGE_SIZE) {
+		pte_t pte = data->entries[walk_addr_index(addr)];
+
+		if (is_swap_pte(pte)) {
+			struct page *page =
+				read_swap_cache_async(pte_to_swp_entry(pte),
+						GFP_KERNEL, data->vma, addr);
+			if (page)
+				page_cache_release(page);
+		}
+	}
+
+	return 0;
+}
+
+static long madvise_willneed_anon(struct vm_area_struct *vma,
+				  struct vm_area_struct **prev,
+				  unsigned long start, unsigned long end)
+{
+	struct madvise_willneed_anon_data data = {
+		.vma = vma;
+	};
+	struct mm_walk walk = {
+		.pte_entry = madvise_willneed_anon_pte,
+		.pte_batch = madvise_willneed_anon_batch,
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
-static long madvise_willneed(struct vm_area_struct * vma,
-			     struct vm_area_struct ** prev,
+static long madvise_willneed(struct vm_area_struct *vma,
+			     struct vm_area_struct **prev,
 			     unsigned long start, unsigned long end)
 {
 	struct file *file = vma->vm_file;
 
 	if (!file)
-		return -EBADF;
+		return madvise_willneed_anon(vma, prev, start, end);
 
 	if (file->f_mapping->a_ops->get_xip_page) {
 		/* no bad return value, but ignore advice */
@@ -119,8 +175,6 @@ static long madvise_willneed(struct vm_area_struct * vma,
 
 	*prev = vma;
 	start = ((start - vma->vm_start) >> PAGE_SHIFT) + vma->vm_pgoff;
-	if (end > vma->vm_end)
-		end = vma->vm_end;
 	end = ((end - vma->vm_start) >> PAGE_SHIFT) + vma->vm_pgoff;
 
 	force_page_cache_readahead(file->f_mapping,
@@ -147,8 +201,8 @@ static long madvise_willneed(struct vm_area_struct * vma,
  * An interface that causes the system to free clean pages and flush
  * dirty pages is already available as msync(MS_INVALIDATE).
  */
-static long madvise_dontneed(struct vm_area_struct * vma,
-			     struct vm_area_struct ** prev,
+static long madvise_dontneed(struct vm_area_struct *vma,
+			     struct vm_area_struct **prev,
 			     unsigned long start, unsigned long end)
 {
 	*prev = vma;
diff --git a/mm/pagewalk.c b/mm/pagewalk.c
index b4f27d2..25fc656 100644
--- a/mm/pagewalk.c
+++ b/mm/pagewalk.c
@@ -2,12 +2,45 @@
 #include <linux/highmem.h>
 #include <linux/sched.h>
 
+static int walk_pte_range_batch(pmd_t *pmd, unsigned long addr, unsigned long end,
+			  const struct mm_walk *walk, void *private)
+{
+	int err = 0;
+
+	do {
+		unsigned int i;
+		pte_t *pte;
+		unsigned long start = addr;
+		int err2;
+
+		pte = pte_offset_map(pmd, addr);
+		for (i = 0; i < WALK_BATCH_SIZE && addr != end; 
+				i++, pte++, addr += PAGE_SIZE) {
+			err = walk->pte_entry(pte, addr, addr + PAGE_SIZE, private);
+			if (err)
+				break;
+		}
+		pte_unmap(pte);
+		
+		err2 = walk->pte_batch(start, end, private);
+		if (!err)
+			err = err2;
+		if (err)
+			break;
+	} while (addr != end);
+
+	return err;
+}
+
 static int walk_pte_range(pmd_t *pmd, unsigned long addr, unsigned long end,
 			  const struct mm_walk *walk, void *private)
 {
 	pte_t *pte;
 	int err = 0;
 
+	if (walk->pte_batch)
+		return walk_pte_range_batch(pmd, addr, end, walk, private);
+
 	pte = pte_offset_map(pmd, addr);
 	do {
 		err = walk->pte_entry(pte, addr, addr + PAGE_SIZE, private);


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

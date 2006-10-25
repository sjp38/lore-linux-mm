Date: Wed, 25 Oct 2006 03:35:41 +0100 (BST)
From: Hugh Dickins <hugh@veritas.com>
Subject: [PATCH 2/3] hugetlb: fix prio_tree unit
In-Reply-To: <Pine.LNX.4.64.0610250323570.30678@blonde.wat.veritas.com>
Message-ID: <Pine.LNX.4.64.0610250331220.30678@blonde.wat.veritas.com>
References: <Pine.LNX.4.64.0610250323570.30678@blonde.wat.veritas.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@osdl.org>
Cc: Ken Chen <kenneth.w.chen@intel.com>, Bill Irwin <wli@holomorphy.com>, Adam Litke <agl@us.ibm.com>, David Gibson <david@gibson.dropbear.id.au>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

hugetlb_vmtruncate_list was misconverted to prio_tree: its prio_tree is
in units of PAGE_SIZE (PAGE_CACHE_SIZE) like any other, not HPAGE_SIZE
(whereas its radix_tree is kept in units of HPAGE_SIZE, otherwise slots
would be absurdly sparse).

At first I thought the error benign, just calling __unmap_hugepage_range
on more vmas than necessary; but on 32-bit machines, when the prio_tree
is searched correctly, it happens to ensure the v_offset calculation won't
overflow.  As it stood, when truncating at or beyond 4GB, it was liable
to discard pages COWed from lower offsets; or even to clear pmd entries
of preceding vmas, triggering exit_mmap's BUG_ON(nr_ptes).

Signed-off-by: Hugh Dickins <hugh@veritas.com>
___

 fs/hugetlbfs/inode.c |   24 +++++++++++-------------
 1 file changed, 11 insertions(+), 13 deletions(-)

--- 2.6.19-rc3/fs/hugetlbfs/inode.c	2006-10-24 04:34:28.000000000 +0100
+++ linux/fs/hugetlbfs/inode.c	2006-10-24 17:43:08.000000000 +0100
@@ -271,26 +271,24 @@ static void hugetlbfs_drop_inode(struct 
 		hugetlbfs_forget_inode(inode);
 }
 
-/*
- * h_pgoff is in HPAGE_SIZE units.
- * vma->vm_pgoff is in PAGE_SIZE units.
- */
 static inline void
-hugetlb_vmtruncate_list(struct prio_tree_root *root, unsigned long h_pgoff)
+hugetlb_vmtruncate_list(struct prio_tree_root *root, pgoff_t pgoff)
 {
 	struct vm_area_struct *vma;
 	struct prio_tree_iter iter;
 
-	vma_prio_tree_foreach(vma, &iter, root, h_pgoff, ULONG_MAX) {
-		unsigned long h_vm_pgoff;
+	vma_prio_tree_foreach(vma, &iter, root, pgoff, ULONG_MAX) {
 		unsigned long v_offset;
 
-		h_vm_pgoff = vma->vm_pgoff >> (HPAGE_SHIFT - PAGE_SHIFT);
-		v_offset = (h_pgoff - h_vm_pgoff) << HPAGE_SHIFT;
 		/*
-		 * Is this VMA fully outside the truncation point?
+		 * Can the expression below overflow on 32-bit arches?
+		 * No, because the prio_tree returns us only those vmas
+		 * which overlap the truncated area starting at pgoff,
+		 * and no vma on a 32-bit arch can span beyond the 4GB.
 		 */
-		if (h_vm_pgoff >= h_pgoff)
+		if (vma->vm_pgoff < pgoff)
+			v_offset = (pgoff - vma->vm_pgoff) << PAGE_SHIFT;
+		else
 			v_offset = 0;
 
 		__unmap_hugepage_range(vma,
@@ -303,14 +301,14 @@ hugetlb_vmtruncate_list(struct prio_tree
  */
 static int hugetlb_vmtruncate(struct inode *inode, loff_t offset)
 {
-	unsigned long pgoff;
+	pgoff_t pgoff;
 	struct address_space *mapping = inode->i_mapping;
 
 	if (offset > inode->i_size)
 		return -EINVAL;
 
 	BUG_ON(offset & ~HPAGE_MASK);
-	pgoff = offset >> HPAGE_SHIFT;
+	pgoff = offset >> PAGE_SHIFT;
 
 	inode->i_size = offset;
 	spin_lock(&mapping->i_mmap_lock);

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

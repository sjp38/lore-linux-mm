Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pb0-f44.google.com (mail-pb0-f44.google.com [209.85.160.44])
	by kanga.kvack.org (Postfix) with ESMTP id B58906B0039
	for <linux-mm@kvack.org>; Tue, 18 Feb 2014 13:07:59 -0500 (EST)
Received: by mail-pb0-f44.google.com with SMTP id rq2so17053702pbb.31
        for <linux-mm@kvack.org>; Tue, 18 Feb 2014 10:07:59 -0800 (PST)
Received: from mga02.intel.com (mga02.intel.com. [134.134.136.20])
        by mx.google.com with ESMTP id vw10si19067005pbc.347.2014.02.18.10.07.58
        for <linux-mm@kvack.org>;
        Tue, 18 Feb 2014 10:07:58 -0800 (PST)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
In-Reply-To: <20140218175900.8CF90E0090@blue.fi.intel.com>
References: <1392662333-25470-1-git-send-email-kirill.shutemov@linux.intel.com>
 <CA+55aFwz+36NOk=uanDvii7zn46-s1kpMT1Lt=C0hhhn9v6w-Q@mail.gmail.com>
 <20140218175900.8CF90E0090@blue.fi.intel.com>
Subject: Re: [RFC, PATCHv2 0/2] mm: map few pages around fault address if they
 are in page cache
Content-Transfer-Encoding: 7bit
Message-Id: <20140218180730.C2552E0090@blue.fi.intel.com>
Date: Tue, 18 Feb 2014 20:07:30 +0200 (EET)
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Cc: Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, Andi Kleen <ak@linux.intel.com>, Matthew Wilcox <matthew.r.wilcox@intel.com>, Dave Hansen <dave.hansen@linux.intel.com>, Alexander Viro <viro@zeniv.linux.org.uk>, Dave Chinner <david@fromorbit.com>, linux-mm <linux-mm@kvack.org>, linux-fsdevel <linux-fsdevel@vger.kernel.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>

Kirill A. Shutemov wrote:
> Linus Torvalds wrote:
> > On Mon, Feb 17, 2014 at 10:38 AM, Kirill A. Shutemov
> > <kirill.shutemov@linux.intel.com> wrote:
> > >
> > > Now we have ->fault_nonblock() to ask filesystem for a page, if it's
> > > reachable without blocking. We request one page a time. It's not terribly
> > > efficient and I will probably re-think the interface once again to expose
> > > iterator or something...
> > 
> > Hmm. Yeah, clearly this isn't working, since the real workloads all
> > end up looking like
> > 
> > >        115,493,976      minor-faults                                                  ( +-  0.00% ) [100.00%]
> > >       59.686645587 seconds time elapsed                                          ( +-  0.30% )
> >  becomes
> > >         47,428,068      minor-faults                                                  ( +-  0.00% ) [100.00%]
> > >       60.241766430 seconds time elapsed                                          ( +-  0.85% )
> > 
> > and
> > 
> > >        268,039,365      minor-faults                                                 [100.00%]
> > >      132.830612471 seconds time elapsed
> > becomes
> > >        193,550,437      minor-faults                                                 [100.00%]
> > >      132.851823758 seconds time elapsed
> > 
> > and
> > 
> > >          4,967,540      minor-faults                                                  ( +-  0.06% ) [100.00%]
> > >       27.215434226 seconds time elapsed                                          ( +-  0.18% )
> > becomes
> > >          2,285,563      minor-faults                                                  ( +-  0.26% ) [100.00%]
> > >       27.292854546 seconds time elapsed                                          ( +-  0.29% )
> > 
> > ie it shows a clear reduction in faults, but the added costs clearly
> > eat up any wins and it all becomes (just _slightly_) slower.
> 
> I did an experement with setup pte directly in filemap_fault_nonblock() to
> see how much we can get from it. And it helps:
> 
> git:		-1.21s
> clean build:	-2.22s
> rebuild:	-0.63s
> 
> Is it a layering violation to setup pte directly in ->fault_nonblock()?
> 
> perf stat and patch below.
> 
> Git test-suite make -j60 test:
>  1,591,184,058,944      cycles                     ( +-  0.05% ) [100.00%]
>    811,200,260,823      instructions              #    0.51  insns per cycle
>                                                   #    3.24  stalled cycles per insn  ( +-  0.19% ) [100.00%]
>  2,631,511,271,429      stalled-cycles-frontend   #  165.38% frontend cycles idle     ( +-  0.08% )
>         47,305,697      minor-faults                                                  ( +-  0.00% ) [100.00%]
>                  1      major-faults
> 
>       59.028360009 seconds time elapsed                                          ( +-  0.58% )
> 
> Run make -j60 on clean allmodconfig kernel tree:
> 19,163,958,689,310      cycles                    [100.00%]
> 17,446,888,861,177      instructions              #    0.91  insns per cycle
>                                                   #    1.53  stalled cycles per insn [100.00%]
> 26,777,884,033,091      stalled-cycles-frontend   #  139.73% frontend cycles idle
>        193,118,569      minor-faults                                                 [100.00%]
>                  0      major-faults
> 
>      130.631767214 seconds time elapsed
> 
> Run make -j60 on already built allmodconfig kernel tree:
>    282,398,537,719      cycles                     ( +-  0.03% ) [100.00%]
>    385,807,937,931      instructions              #    1.37  insns per cycle
>                                                   #    0.95  stalled cycles per insn  ( +-  0.01% ) [100.00%]
>    365,940,576,310      stalled-cycles-frontend   #  129.58% frontend cycles idle     ( +-  0.07% )
>          2,254,887      minor-faults                                                  ( +-  0.02% ) [100.00%]
>                  0      major-faults
> 
>       26.660708754 seconds time elapsed                                          ( +-  0.29% )

Patch is wrong. Correct one is below.

diff --git a/fs/9p/vfs_file.c b/fs/9p/vfs_file.c
index a16b0ff497ca..a7f7e41bec37 100644
--- a/fs/9p/vfs_file.c
+++ b/fs/9p/vfs_file.c
@@ -832,6 +832,7 @@ static void v9fs_mmap_vm_close(struct vm_area_struct *vma)
 
 static const struct vm_operations_struct v9fs_file_vm_ops = {
 	.fault = filemap_fault,
+	.fault_nonblock = filemap_fault_nonblock,
 	.page_mkwrite = v9fs_vm_page_mkwrite,
 	.remap_pages = generic_file_remap_pages,
 };
@@ -839,6 +840,7 @@ static const struct vm_operations_struct v9fs_file_vm_ops = {
 static const struct vm_operations_struct v9fs_mmap_file_vm_ops = {
 	.close = v9fs_mmap_vm_close,
 	.fault = filemap_fault,
+	.fault_nonblock = filemap_fault_nonblock,
 	.page_mkwrite = v9fs_vm_page_mkwrite,
 	.remap_pages = generic_file_remap_pages,
 };
diff --git a/fs/btrfs/file.c b/fs/btrfs/file.c
index 0165b8672f09..13523a63e1f3 100644
--- a/fs/btrfs/file.c
+++ b/fs/btrfs/file.c
@@ -1993,6 +1993,7 @@ out:
 
 static const struct vm_operations_struct btrfs_file_vm_ops = {
 	.fault		= filemap_fault,
+	.fault_nonblock	= filemap_fault_nonblock,
 	.page_mkwrite	= btrfs_page_mkwrite,
 	.remap_pages	= generic_file_remap_pages,
 };
diff --git a/fs/cifs/file.c b/fs/cifs/file.c
index 755584684f6c..71aff75e067c 100644
--- a/fs/cifs/file.c
+++ b/fs/cifs/file.c
@@ -3094,6 +3094,7 @@ cifs_page_mkwrite(struct vm_area_struct *vma, struct vm_fault *vmf)
 
 static struct vm_operations_struct cifs_file_vm_ops = {
 	.fault = filemap_fault,
+	.fault_nonblock = filemap_fault_nonblock,
 	.page_mkwrite = cifs_page_mkwrite,
 	.remap_pages = generic_file_remap_pages,
 };
diff --git a/fs/ext4/file.c b/fs/ext4/file.c
index 1a5073959f32..182ae5543a1d 100644
--- a/fs/ext4/file.c
+++ b/fs/ext4/file.c
@@ -200,6 +200,7 @@ ext4_file_write(struct kiocb *iocb, const struct iovec *iov,
 
 static const struct vm_operations_struct ext4_file_vm_ops = {
 	.fault		= filemap_fault,
+	.fault_nonblock	= filemap_fault_nonblock,
 	.page_mkwrite   = ext4_page_mkwrite,
 	.remap_pages	= generic_file_remap_pages,
 };
diff --git a/fs/f2fs/file.c b/fs/f2fs/file.c
index 0dfcef53a6ed..7c48fd2eb99c 100644
--- a/fs/f2fs/file.c
+++ b/fs/f2fs/file.c
@@ -84,6 +84,7 @@ out:
 
 static const struct vm_operations_struct f2fs_file_vm_ops = {
 	.fault		= filemap_fault,
+	.fault_nonblock	= filemap_fault_nonblock,
 	.page_mkwrite	= f2fs_vm_page_mkwrite,
 	.remap_pages	= generic_file_remap_pages,
 };
diff --git a/fs/fuse/file.c b/fs/fuse/file.c
index 77bcc303c3ae..e95e52ec7bc2 100644
--- a/fs/fuse/file.c
+++ b/fs/fuse/file.c
@@ -1940,6 +1940,7 @@ static int fuse_page_mkwrite(struct vm_area_struct *vma, struct vm_fault *vmf)
 static const struct vm_operations_struct fuse_file_vm_ops = {
 	.close		= fuse_vma_close,
 	.fault		= filemap_fault,
+	.fault_nonblock	= filemap_fault_nonblock,
 	.page_mkwrite	= fuse_page_mkwrite,
 	.remap_pages	= generic_file_remap_pages,
 };
diff --git a/fs/gfs2/file.c b/fs/gfs2/file.c
index efc078f0ee4e..7c4b2f096ac8 100644
--- a/fs/gfs2/file.c
+++ b/fs/gfs2/file.c
@@ -494,6 +494,7 @@ out:
 
 static const struct vm_operations_struct gfs2_vm_ops = {
 	.fault = filemap_fault,
+	.fault_nonblock = filemap_fault_nonblock,
 	.page_mkwrite = gfs2_page_mkwrite,
 	.remap_pages = generic_file_remap_pages,
 };
diff --git a/fs/nfs/file.c b/fs/nfs/file.c
index 5bb790a69c71..8fbe80168d1f 100644
--- a/fs/nfs/file.c
+++ b/fs/nfs/file.c
@@ -617,6 +617,7 @@ out:
 
 static const struct vm_operations_struct nfs_file_vm_ops = {
 	.fault = filemap_fault,
+	.fault_nonblock = filemap_fault_nonblock,
 	.page_mkwrite = nfs_vm_page_mkwrite,
 	.remap_pages = generic_file_remap_pages,
 };
diff --git a/fs/nilfs2/file.c b/fs/nilfs2/file.c
index 08fdb77852ac..adc4aa07d7d8 100644
--- a/fs/nilfs2/file.c
+++ b/fs/nilfs2/file.c
@@ -134,6 +134,7 @@ static int nilfs_page_mkwrite(struct vm_area_struct *vma, struct vm_fault *vmf)
 
 static const struct vm_operations_struct nilfs_file_vm_ops = {
 	.fault		= filemap_fault,
+	.fault_nonblock	= filemap_fault_nonblock,
 	.page_mkwrite	= nilfs_page_mkwrite,
 	.remap_pages	= generic_file_remap_pages,
 };
diff --git a/fs/ubifs/file.c b/fs/ubifs/file.c
index 123c79b7261e..f27c4c401a3f 100644
--- a/fs/ubifs/file.c
+++ b/fs/ubifs/file.c
@@ -1538,6 +1538,7 @@ out_unlock:
 
 static const struct vm_operations_struct ubifs_file_vm_ops = {
 	.fault        = filemap_fault,
+	.fault_nonblock = filemap_fault_nonblock,
 	.page_mkwrite = ubifs_vm_page_mkwrite,
 	.remap_pages = generic_file_remap_pages,
 };
diff --git a/fs/xfs/xfs_file.c b/fs/xfs/xfs_file.c
index 64b48eade91d..bc619150c960 100644
--- a/fs/xfs/xfs_file.c
+++ b/fs/xfs/xfs_file.c
@@ -1465,6 +1465,7 @@ const struct file_operations xfs_dir_file_operations = {
 
 static const struct vm_operations_struct xfs_file_vm_ops = {
 	.fault		= filemap_fault,
+	.fault_nonblock	= filemap_fault_nonblock,
 	.page_mkwrite	= xfs_vm_page_mkwrite,
 	.remap_pages	= generic_file_remap_pages,
 };
diff --git a/include/linux/mm.h b/include/linux/mm.h
index f28f46eade6a..e671dd5abe27 100644
--- a/include/linux/mm.h
+++ b/include/linux/mm.h
@@ -221,6 +221,8 @@ struct vm_operations_struct {
 	void (*open)(struct vm_area_struct * area);
 	void (*close)(struct vm_area_struct * area);
 	int (*fault)(struct vm_area_struct *vma, struct vm_fault *vmf);
+	int (*fault_nonblock)(struct vm_area_struct *vma, struct vm_fault *vmf,
+		pgoff_t max_pgoff, int nr_pages, pte_t *pte);
 
 	/* notification that a previously read-only page is about to become
 	 * writable, if an error is returned it will cause a SIGBUS */
@@ -1810,6 +1812,8 @@ extern void truncate_inode_pages_range(struct address_space *,
 
 /* generic vm_area_ops exported for stackable file systems */
 extern int filemap_fault(struct vm_area_struct *, struct vm_fault *);
+int filemap_fault_nonblock(struct vm_area_struct *vma, struct vm_fault *vmf,
+		pgoff_t max_pgoff, int nr_pages, pte_t *pte);
 extern int filemap_page_mkwrite(struct vm_area_struct *vma, struct vm_fault *vmf);
 
 /* mm/page-writeback.c */
diff --git a/mm/filemap.c b/mm/filemap.c
index 7a13f6ac5421..0a8884efbcd8 100644
--- a/mm/filemap.c
+++ b/mm/filemap.c
@@ -33,6 +33,7 @@
 #include <linux/hardirq.h> /* for BUG_ON(!in_atomic()) only */
 #include <linux/memcontrol.h>
 #include <linux/cleancache.h>
+#include <linux/rmap.h>
 #include "internal.h"
 
 #define CREATE_TRACE_POINTS
@@ -1726,6 +1730,93 @@ page_not_uptodate:
 }
 EXPORT_SYMBOL(filemap_fault);
 
+void do_set_pte(struct vm_area_struct *vma, unsigned long address,
+		struct page *page, pte_t *pte, bool write, bool anon);
+int filemap_fault_nonblock(struct vm_area_struct *vma, struct vm_fault *vmf,
+		pgoff_t max_pgoff, int nr_pages, pte_t *pte)
+{
+	struct radix_tree_iter iter;
+	void **slot;
+	struct file *file = vma->vm_file;
+	struct address_space *mapping = file->f_mapping;
+	pgoff_t size;
+	struct page *page;
+	unsigned long address = (unsigned long) vmf->virtual_address;
+	unsigned long addr;
+	pte_t *_pte;
+	int ret = 0;
+
+	rcu_read_lock();
+restart:
+	radix_tree_for_each_slot(slot, &mapping->page_tree, &iter, vmf->pgoff) {
+repeat:
+		page = radix_tree_deref_slot(slot);
+
+		if (radix_tree_exception(page)) {
+			if (radix_tree_deref_retry(page)) {
+				/*
+				 * Transient condition which can only trigger
+				 * when entry at index 0 moves out of or back
+				 * to root: none yet gotten, safe to restart.
+				 */
+				WARN_ON(iter.index);
+				goto restart;
+			}
+			/*
+			 * Otherwise, shmem/tmpfs must be storing a swap entry
+			 * here as an exceptional entry: so skip over it -
+			 * we only reach this from invalidate_mapping_pages().
+			 */
+			continue;
+		}
+
+		if (!page_cache_get_speculative(page))
+			goto repeat;
+
+		/* Has the page moved? */
+		if (unlikely(page != *slot)) {
+			page_cache_release(page);
+			goto repeat;
+		}
+
+		if (page->index > max_pgoff) {
+			page_cache_release(page);
+			break;
+		}
+
+		if (PageReadahead(page) || PageHWPoison(page) ||
+				!PageUptodate(page))
+			goto skip;
+		if (!trylock_page(page))
+			goto skip;
+		if (page->mapping != mapping || !PageUptodate(page))
+			goto unlock;
+		size = (i_size_read(mapping->host) + PAGE_CACHE_SIZE - 1)
+			>> PAGE_CACHE_SHIFT;
+		if (page->index >= size)
+			goto unlock;
+		if (file->f_ra.mmap_miss > 0)
+			file->f_ra.mmap_miss--;
+		addr = address + (page->index - vmf->pgoff) * PAGE_SIZE;
+		_pte = pte + page->index - vmf->pgoff;
+		if (!pte_none(*_pte))
+			goto unlock;
+		do_set_pte(vma, addr, page, _pte, false, false);
+
+		unlock_page(page);
+		if (++ret == nr_pages || page->index == max_pgoff)
+			break;
+		continue;
+unlock:
+		unlock_page(page);
+skip:
+		page_cache_release(page);
+	}
+	rcu_read_unlock();
+	return ret;
+}
+EXPORT_SYMBOL(filemap_fault_nonblock);
+
 int filemap_page_mkwrite(struct vm_area_struct *vma, struct vm_fault *vmf)
 {
 	struct page *page = vmf->page;
@@ -1755,6 +1846,7 @@ EXPORT_SYMBOL(filemap_page_mkwrite);
 
 const struct vm_operations_struct generic_file_vm_ops = {
 	.fault		= filemap_fault,
+	.fault_nonblock	= filemap_fault_nonblock,
 	.page_mkwrite	= filemap_page_mkwrite,
 	.remap_pages	= generic_file_remap_pages,
 };
diff --git a/mm/memory.c b/mm/memory.c
index 7f52c46ef1e1..e79c8d6f6f47 100644
--- a/mm/memory.c
+++ b/mm/memory.c
@@ -3318,7 +3318,8 @@ static int __do_fault(struct vm_area_struct *vma, unsigned long address,
 	return ret;
 }
 
-static void do_set_pte(struct vm_area_struct *vma, unsigned long address,
+
+void do_set_pte(struct vm_area_struct *vma, unsigned long address,
 		struct page *page, pte_t *pte, bool write, bool anon)
 {
 	pte_t entry;
@@ -3342,6 +3343,49 @@ static void do_set_pte(struct vm_area_struct *vma, unsigned long address,
 	update_mmu_cache(vma, address, pte);
 }
 
+#define FAULT_AROUND_ORDER 5
+#define FAULT_AROUND_PAGES (1UL << FAULT_AROUND_ORDER)
+#define FAULT_AROUND_MASK ~((1UL << (PAGE_SHIFT + FAULT_AROUND_ORDER)) - 1)
+
+static void do_fault_around(struct vm_area_struct *vma, unsigned long address,
+		pte_t *pte, pgoff_t pgoff, unsigned int flags)
+{
+	unsigned long start_addr;
+	pgoff_t max_pgoff;
+	struct vm_fault vmf;
+	int off, ret;
+
+	/* Do not cross vma or page table border */
+	max_pgoff = min(pgoff - pte_index(address) + PTRS_PER_PTE - 1,
+			vma_pages(vma) + vma->vm_pgoff - 1);
+
+	start_addr = max(address & FAULT_AROUND_MASK, vma->vm_start);
+	if ((start_addr & PMD_MASK) != (address & PMD_MASK))
+		BUG();
+	off = pte_index(start_addr) - pte_index(address);
+	pte += off;
+	pgoff += off;
+
+	/* Check if it makes any sense to call ->fault_nonblock */
+	while (!pte_none(*pte)) {
+		pte++;
+		pgoff++;
+		start_addr += PAGE_SIZE;
+		/* Do not cross vma or page table border */
+		if (!pte_index(start_addr) || start_addr >= vma->vm_end)
+			return;
+		if ((start_addr & PMD_MASK) != (address & PMD_MASK))
+			BUG();
+	}
+
+
+	vmf.virtual_address = (void __user *) start_addr;
+	vmf.pgoff = pgoff;
+	vmf.flags = flags;
+	ret = vma->vm_ops->fault_nonblock(vma, &vmf,
+			max_pgoff, FAULT_AROUND_PAGES, pte);
+}
+
 static int do_read_fault(struct mm_struct *mm, struct vm_area_struct *vma,
 		unsigned long address, pmd_t *pmd,
 		pgoff_t pgoff, unsigned int flags, pte_t orig_pte)
@@ -3363,8 +3407,11 @@ static int do_read_fault(struct mm_struct *mm, struct vm_area_struct *vma,
 		return ret;
 	}
 	do_set_pte(vma, address, fault_page, pte, false, false);
-	pte_unmap_unlock(pte, ptl);
 	unlock_page(fault_page);
+
+	if (vma->vm_ops->fault_nonblock)
+		do_fault_around(vma, address, pte, pgoff, flags);
+	pte_unmap_unlock(pte, ptl);
 	return ret;
 }
 
-- 
 Kirill A. Shutemov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

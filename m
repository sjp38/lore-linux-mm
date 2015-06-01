Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f178.google.com (mail-wi0-f178.google.com [209.85.212.178])
	by kanga.kvack.org (Postfix) with ESMTP id C253C6B006C
	for <linux-mm@kvack.org>; Mon,  1 Jun 2015 09:00:12 -0400 (EDT)
Received: by wifw1 with SMTP id w1so104105400wif.0
        for <linux-mm@kvack.org>; Mon, 01 Jun 2015 06:00:12 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id m6si18889135wjb.7.2015.06.01.06.00.08
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Mon, 01 Jun 2015 06:00:09 -0700 (PDT)
From: Michal Hocko <mhocko@suse.cz>
Subject: [RFC 2/2] mm: Allow GFP_IOFS for page_cache_read page cache allocation
Date: Mon,  1 Jun 2015 15:00:03 +0200
Message-Id: <1433163603-13229-3-git-send-email-mhocko@suse.cz>
In-Reply-To: <1433163603-13229-1-git-send-email-mhocko@suse.cz>
References: <1433163603-13229-1-git-send-email-mhocko@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: Andrew Morton <akpm@linux-foundation.org>, Dave Chinner <david@fromorbit.com>, Neil Brown <neilb@suse.de>, Johannes Weiner <hannes@cmpxchg.org>, Al Viro <viro@zeniv.linux.org.uk>, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, LKML <linux-kernel@vger.kernel.org>, linux-fsdevel@vger.kernel.org

page_cache_read has been historically using page_cache_alloc_cold to
allocate a new page. This means that mapping_gfp_mask is used as the
base for the gfp_mask. Many filesystems are setting this mask to
GFP_NOFS to prevent from fs recursion issues. page_cache_read is,
however, not called from the fs layera directly so it doesn't need this
protection normally.

ceph and ocfs2 which call filemap_fault from their fault handlers
seem to be OK because they are not taking any fs lock before invoking
generic implementation. xfs which takes XFS_MMAPLOCK_SHARED is safe
from the reclaim recursion POV because this lock serializes truncate
and punch hole with the page faults and it doesn't get involved in the
reclaim.

The GFP_NOFS protection might be even harmful. There is a push to fail
GFP_NOFS allocations rather than loop within allocator indefinitely with
a very limited reclaim ability. Once we start failing those requests
the OOM killer might be triggered prematurely because the page cache
allocation failure is propagated up the page fault path and end up in
pagefault_out_of_memory.

We cannot play with mapping_gfp_mask directly because that would be racy
wrt. parallel page faults and it might interfere with other users who
really rely on NOFS semantic from the stored gfp_mask. The mask is also
inode proper so it would even be a layering violation. What we can do
instead is to push the gfp_mask into struct vm_fault and allow fs layer
to overwrite it should the callback need to be called with a different
allocation context.

Initialize the default to (mapping_gfp_mask | GFP_IOFS) because this
should be safe from the page fault path normally. Why do we care
about mapping_gfp_mask at all then? Because this doesn't hold only
reclaim protection flags but it also might contain zone and movability
restrictions (GFP_DMA32, __GFP_MOVABLE and others) so we have to respect
those.

Reported-by: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Signed-off-by: Michal Hocko <mhocko@suse.cz>
---
 include/linux/mm.h |  4 ++++
 mm/filemap.c       |  9 ++++-----
 mm/memory.c        | 17 +++++++++++++++++
 3 files changed, 25 insertions(+), 5 deletions(-)

diff --git a/include/linux/mm.h b/include/linux/mm.h
index 76376e04988a..03b8420e123c 100644
--- a/include/linux/mm.h
+++ b/include/linux/mm.h
@@ -219,10 +219,14 @@ extern pgprot_t protection_map[16];
  * ->fault function. The vma's ->fault is responsible for returning a bitmask
  * of VM_FAULT_xxx flags that give details about how the fault was handled.
  *
+ * MM layer fills up gfp_mask for page allocations but fault handler might
+ * alter it if its implementation requires a different allocation context.
+ *
  * pgoff should be used in favour of virtual_address, if possible.
  */
 struct vm_fault {
 	unsigned int flags;		/* FAULT_FLAG_xxx flags */
+	gfp_t gfp_mask;			/* gfp mask to be used for allocations */
 	pgoff_t pgoff;			/* Logical page offset based on vma */
 	void __user *virtual_address;	/* Faulting virtual address */
 
diff --git a/mm/filemap.c b/mm/filemap.c
index adfc5d2e21c8..bfbc30ff47a4 100644
--- a/mm/filemap.c
+++ b/mm/filemap.c
@@ -1760,19 +1760,18 @@ EXPORT_SYMBOL(generic_file_read_iter);
  * This adds the requested page to the page cache if it isn't already there,
  * and schedules an I/O to read in its contents from disk.
  */
-static int page_cache_read(struct file *file, pgoff_t offset)
+static int page_cache_read(struct file *file, pgoff_t offset, gfp_t gfp_mask)
 {
 	struct address_space *mapping = file->f_mapping;
 	struct page *page;
 	int ret;
 
 	do {
-		page = page_cache_alloc_cold(mapping);
+		page = __page_cache_alloc(gfp_mask|__GFP_COLD);
 		if (!page)
 			return -ENOMEM;
 
-		ret = add_to_page_cache_lru(page, mapping, offset,
-				GFP_KERNEL & mapping_gfp_mask(mapping));
+		ret = add_to_page_cache_lru(page, mapping, offset, GFP_KERNEL & gfp_mask);
 		if (ret == 0)
 			ret = mapping->a_ops->readpage(file, page);
 		else if (ret == -EEXIST)
@@ -1955,7 +1954,7 @@ int filemap_fault(struct vm_area_struct *vma, struct vm_fault *vmf)
 	 * We're only likely to ever get here if MADV_RANDOM is in
 	 * effect.
 	 */
-	error = page_cache_read(file, offset);
+	error = page_cache_read(file, offset, vmf->gfp_mask);
 
 	/*
 	 * The page we want has now been added to the page cache.
diff --git a/mm/memory.c b/mm/memory.c
index 8a2fc9945b46..25ab29560dca 100644
--- a/mm/memory.c
+++ b/mm/memory.c
@@ -1949,6 +1949,20 @@ static inline void cow_user_page(struct page *dst, struct page *src, unsigned lo
 		copy_user_highpage(dst, src, va, vma);
 }
 
+static gfp_t __get_fault_gfp_mask(struct vm_area_struct *vma)
+{
+	struct file *vm_file = vma->vm_file;
+
+	if (vm_file)
+		return mapping_gfp_mask(vm_file->f_mapping) | GFP_IOFS;
+
+	/*
+	 * Special mappings (e.g. VDSO) do not have any file so fake
+	 * a default GFP_KERNEL for them.
+	 */
+	return GFP_KERNEL;
+}
+
 /*
  * Notify the address space that the page is about to become writable so that
  * it can prohibit this or wait for the page to get into an appropriate state.
@@ -1964,6 +1978,7 @@ static int do_page_mkwrite(struct vm_area_struct *vma, struct page *page,
 	vmf.virtual_address = (void __user *)(address & PAGE_MASK);
 	vmf.pgoff = page->index;
 	vmf.flags = FAULT_FLAG_WRITE|FAULT_FLAG_MKWRITE;
+	vmf.gfp_mask = __get_fault_gfp_mask(vma);
 	vmf.page = page;
 	vmf.cow_page = NULL;
 
@@ -2763,6 +2778,7 @@ static int __do_fault(struct vm_area_struct *vma, unsigned long address,
 	vmf.pgoff = pgoff;
 	vmf.flags = flags;
 	vmf.page = NULL;
+	vmf.gfp_mask = __get_fault_gfp_mask(vma);
 	vmf.cow_page = cow_page;
 
 	ret = vma->vm_ops->fault(vma, &vmf);
@@ -2929,6 +2945,7 @@ static void do_fault_around(struct vm_area_struct *vma, unsigned long address,
 	vmf.pgoff = pgoff;
 	vmf.max_pgoff = max_pgoff;
 	vmf.flags = flags;
+	vmf.gfp_mask = __get_fault_gfp_mask(vma);
 	vma->vm_ops->map_pages(vma, &vmf);
 }
 
-- 
2.1.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

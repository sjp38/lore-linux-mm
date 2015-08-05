Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f169.google.com (mail-wi0-f169.google.com [209.85.212.169])
	by kanga.kvack.org (Postfix) with ESMTP id 4A4B29003C9
	for <linux-mm@kvack.org>; Wed,  5 Aug 2015 05:51:51 -0400 (EDT)
Received: by wijp15 with SMTP id p15so40956546wij.0
        for <linux-mm@kvack.org>; Wed, 05 Aug 2015 02:51:50 -0700 (PDT)
Received: from mail-wi0-f172.google.com (mail-wi0-f172.google.com. [209.85.212.172])
        by mx.google.com with ESMTPS id s4si4807932wjx.53.2015.08.05.02.51.48
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 05 Aug 2015 02:51:49 -0700 (PDT)
Received: by wijp15 with SMTP id p15so40955325wij.0
        for <linux-mm@kvack.org>; Wed, 05 Aug 2015 02:51:48 -0700 (PDT)
From: mhocko@kernel.org
Subject: [RFC 2/8] mm: Allow GFP_IOFS for page_cache_read page cache allocation
Date: Wed,  5 Aug 2015 11:51:18 +0200
Message-Id: <1438768284-30927-3-git-send-email-mhocko@kernel.org>
In-Reply-To: <1438768284-30927-1-git-send-email-mhocko@kernel.org>
References: <1438768284-30927-1-git-send-email-mhocko@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: LKML <linux-kernel@vger.kernel.org>
Cc: linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, Dave Chinner <david@fromorbit.com>, Theodore Ts'o <tytso@mit.edu>, linux-btrfs@vger.kernel.org, linux-ext4@vger.kernel.org, Jan Kara <jack@suse.cz>, Michal Hocko <mhocko@suse.com>

From: Michal Hocko <mhocko@suse.com>

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
Signed-off-by: Michal Hocko <mhocko@suse.com>
---
 include/linux/mm.h |  4 ++++
 mm/filemap.c       |  9 ++++-----
 mm/memory.c        | 17 +++++++++++++++++
 3 files changed, 25 insertions(+), 5 deletions(-)

diff --git a/include/linux/mm.h b/include/linux/mm.h
index 7f471789781a..962e37c7cd6a 100644
--- a/include/linux/mm.h
+++ b/include/linux/mm.h
@@ -220,10 +220,14 @@ extern pgprot_t protection_map[16];
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
index b63fb81df336..8a16a07bbe02 100644
--- a/mm/filemap.c
+++ b/mm/filemap.c
@@ -1774,19 +1774,18 @@ EXPORT_SYMBOL(generic_file_read_iter);
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
@@ -1969,7 +1968,7 @@ int filemap_fault(struct vm_area_struct *vma, struct vm_fault *vmf)
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
2.5.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

Return-Path: <linux-kernel-owner@vger.kernel.org>
From: Josef Bacik <josef@toxicpanda.com>
Subject: [PATCH 2/3] filemap: pass vm_fault to the mmap ra helpers
Date: Tue, 11 Dec 2018 12:38:00 -0500
Message-Id: <20181211173801.29535-3-josef@toxicpanda.com>
In-Reply-To: <20181211173801.29535-1-josef@toxicpanda.com>
References: <20181211173801.29535-1-josef@toxicpanda.com>
Sender: linux-kernel-owner@vger.kernel.org
To: kernel-team@fb.com, hannes@cmpxchg.org, linux-kernel@vger.kernel.org, tj@kernel.org, david@fromorbit.com, akpm@linux-foundation.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, riel@redhat.com, jack@suse.cz
List-ID: <linux-mm.kvack.org>

All of the arguments to these functions come from the vmf, and the
following patches are going to add more arguments.  Cut down on the
amount of arguments passed by simply passing in the vmf to these two
helpers.

Signed-off-by: Josef Bacik <josef@toxicpanda.com>
---
 mm/filemap.c | 28 ++++++++++++++--------------
 1 file changed, 14 insertions(+), 14 deletions(-)

diff --git a/mm/filemap.c b/mm/filemap.c
index 03bce38d8f2b..8fc45f24b201 100644
--- a/mm/filemap.c
+++ b/mm/filemap.c
@@ -2309,20 +2309,20 @@ EXPORT_SYMBOL(generic_file_read_iter);
  * Synchronous readahead happens when we don't even find
  * a page in the page cache at all.
  */
-static void do_sync_mmap_readahead(struct vm_area_struct *vma,
-				   struct file_ra_state *ra,
-				   struct file *file,
-				   pgoff_t offset)
+static void do_sync_mmap_readahead(struct vm_fault *vmf)
 {
+	struct file *file = vmf->vma->vm_file;
+	struct file_ra_state *ra = &file->f_ra;
 	struct address_space *mapping = file->f_mapping;
+	pgoff_t offset = vmf->pgoff;
 
 	/* If we don't want any read-ahead, don't bother */
-	if (vma->vm_flags & VM_RAND_READ)
+	if (vmf->vma->vm_flags & VM_RAND_READ)
 		return;
 	if (!ra->ra_pages)
 		return;
 
-	if (vma->vm_flags & VM_SEQ_READ) {
+	if (vmf->vma->vm_flags & VM_SEQ_READ) {
 		page_cache_sync_readahead(mapping, ra, file, offset,
 					  ra->ra_pages);
 		return;
@@ -2352,16 +2352,16 @@ static void do_sync_mmap_readahead(struct vm_area_struct *vma,
  * Asynchronous readahead happens when we find the page and PG_readahead,
  * so we want to possibly extend the readahead further..
  */
-static void do_async_mmap_readahead(struct vm_area_struct *vma,
-				    struct file_ra_state *ra,
-				    struct file *file,
-				    struct page *page,
-				    pgoff_t offset)
+static void do_async_mmap_readahead(struct vm_fault *vmf,
+				    struct page *page)
 {
+	struct file *file = vmf->vma->vm_file;
+	struct file_ra_state *ra = &file->f_ra;
 	struct address_space *mapping = file->f_mapping;
+	pgoff_t offset = vmf->pgoff;
 
 	/* If we don't want any read-ahead, don't bother */
-	if (vma->vm_flags & VM_RAND_READ)
+	if (vmf->vma->vm_flags & VM_RAND_READ)
 		return;
 	if (ra->mmap_miss > 0)
 		ra->mmap_miss--;
@@ -2418,10 +2418,10 @@ vm_fault_t filemap_fault(struct vm_fault *vmf)
 		 * We found the page, so try async readahead before
 		 * waiting for the lock.
 		 */
-		do_async_mmap_readahead(vmf->vma, ra, file, page, offset);
+		do_async_mmap_readahead(vmf, page);
 	} else if (!page) {
 		/* No page in the page cache at all */
-		do_sync_mmap_readahead(vmf->vma, ra, file, offset);
+		do_sync_mmap_readahead(vmf);
 		count_vm_event(PGMAJFAULT);
 		count_memcg_event_mm(vmf->vma->vm_mm, PGMAJFAULT);
 		ret = VM_FAULT_MAJOR;
-- 
2.14.3

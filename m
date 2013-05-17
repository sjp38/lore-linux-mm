Return-Path: <owner-linux-mm@kvack.org>
Date: Thu, 16 May 2013 20:23:49 -0400
From: Benjamin LaHaise <bcrl@kvack.org>
Subject: [WiP]: aio support for migrating pages (Re: [PATCH V2 1/2] mm: hotplug: implement non-movable version of get_user_pages() called get_user_pages_non_movable())
Message-ID: <20130517002349.GI1008@kvack.org>
References: <1360056113-14294-1-git-send-email-linfeng@cn.fujitsu.com> <1360056113-14294-2-git-send-email-linfeng@cn.fujitsu.com> <20130205120137.GG21389@suse.de> <20130206004234.GD11197@blaptop> <20130206095617.GN21389@suse.de> <5190AE4F.4000103@cn.fujitsu.com> <20130513091902.GP11497@suse.de> <5191B5B3.7080406@cn.fujitsu.com> <20130515132453.GB11497@suse.de> <5194748A.5070700@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <5194748A.5070700@cn.fujitsu.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tang Chen <tangchen@cn.fujitsu.com>
Cc: Mel Gorman <mgorman@suse.de>, Minchan Kim <minchan@kernel.org>, Lin Feng <linfeng@cn.fujitsu.com>, akpm@linux-foundation.org, viro@zeniv.linux.org.uk, khlebnikov@openvz.org, walken@google.com, kamezawa.hiroyu@jp.fujitsu.com, riel@redhat.com, rientjes@google.com, isimatu.yasuaki@jp.fujitsu.com, wency@cn.fujitsu.com, laijs@cn.fujitsu.com, jiang.liu@huawei.com, zab@redhat.com, jmoyer@redhat.com, linux-mm@kvack.org, linux-aio@kvack.org, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org, Marek Szyprowski <m.szyprowski@samsung.com>

On Thu, May 16, 2013 at 01:54:18PM +0800, Tang Chen wrote:
...
> OK, I'll try to figure out a proper place to put the callbacks.
> But I think we need to add something new to struct page. I'm just
> not sure if it is OK. Maybe we can discuss more about it when I send
> a RFC patch.
...

I ended up working on this a bit today, and managed to cobble together 
something that somewhat works -- please see the patch below.  It still is 
not completely tested, and it has a rather nasty bug owing to the fact 
that the file descriptors returned by anon_inode_getfile() all share the 
same inode (read: more than one instance of aio does not work), but it 
shows the basic idea.  Also, bad things probably happen if someone does 
an mremap() on the aio ring buffer.  I'll polish this off sometime next 
week after the long weekend if noone beats me to it.

		-ben
-- 
"Thought is the essence of where you are now."

 fs/aio.c                |   95 ++++++++++++++++++++++++++++++++++++++++++++++--
 include/linux/migrate.h |    3 +
 mm/migrate.c            |    2 -
 3 files changed, 96 insertions(+), 4 deletions(-)
diff --git a/fs/aio.c b/fs/aio.c
index c5b1a8c..dbad23e 100644
--- a/fs/aio.c
+++ b/fs/aio.c
@@ -35,6 +35,9 @@
 #include <linux/eventfd.h>
 #include <linux/blkdev.h>
 #include <linux/compat.h>
+#include <linux/anon_inodes.h>
+#include <linux/migrate.h>
+#include <linux/ramfs.h>
 
 #include <asm/kmap_types.h>
 #include <asm/uaccess.h>
@@ -108,6 +111,7 @@ struct kioctx {
 	} ____cacheline_aligned_in_smp;
 
 	struct page		*internal_pages[AIO_RING_PAGES];
+	struct file		*ctx_file;
 };
 
 /*------ sysctl variables----*/
@@ -146,8 +150,59 @@ static void aio_free_ring(struct kioctx *ctx)
 
 	if (ctx->ring_pages && ctx->ring_pages != ctx->internal_pages)
 		kfree(ctx->ring_pages);
+
+	if (ctx->ctx_file) {
+		truncate_setsize(ctx->ctx_file->f_inode, 0);
+		fput(ctx->ctx_file);
+		ctx->ctx_file = NULL;
+	}
+}
+
+static int aio_ctx_mmap(struct file *file, struct vm_area_struct *vma)
+{
+	vma->vm_ops = &generic_file_vm_ops;
+	return 0;
+}
+
+static const struct file_operations aio_ctx_fops = {
+	.mmap	= aio_ctx_mmap,
+};
+
+static int aio_set_page_dirty(struct page *page)
+{
+	return 0;
+}
+
+static int aio_migratepage(struct address_space *mapping, struct page *new,
+			   struct page *old, enum migrate_mode mode)
+{
+	struct kioctx *ctx = mapping->private_data;
+	unsigned long flags;
+	unsigned idx = old->index;
+	int rc;
+
+	BUG_ON(PageWriteback(old));    /* Writeback must be complete */
+	put_page(old);
+	rc = migrate_page_move_mapping(mapping, new, old, NULL, mode);
+	if (rc != MIGRATEPAGE_SUCCESS) {
+		get_page(old);
+		return rc;
+	}
+	get_page(new);
+
+	spin_lock_irqsave(&ctx->completion_lock, flags);
+	migrate_page_copy(new, old);
+	ctx->ring_pages[idx] = new;
+	spin_unlock_irqrestore(&ctx->completion_lock, flags);
+
+	return MIGRATEPAGE_SUCCESS;
 }
 
+static const struct address_space_operations aio_ctx_aops = {
+	.set_page_dirty = aio_set_page_dirty,
+	.migratepage	= aio_migratepage,
+};
+
 static int aio_setup_ring(struct kioctx *ctx)
 {
 	struct aio_ring *ring;
@@ -155,6 +210,7 @@ static int aio_setup_ring(struct kioctx *ctx)
 	struct mm_struct *mm = current->mm;
 	unsigned long size, populate;
 	int nr_pages;
+	int i;
 
 	/* Compensate for the ring buffer's head/tail overlap entry */
 	nr_events += 2;	/* 1 is required, 2 for good luck */
@@ -166,6 +222,31 @@ static int aio_setup_ring(struct kioctx *ctx)
 	if (nr_pages < 0)
 		return -EINVAL;
 
+	ctx->ctx_file = anon_inode_getfile("[aio]", &aio_ctx_fops, ctx, O_RDWR);
+	if (IS_ERR(ctx->ctx_file)) {
+		ctx->ctx_file = NULL;
+		return -EAGAIN;
+	}
+	ctx->ctx_file->f_inode->i_mapping->a_ops = &aio_ctx_aops;
+	ctx->ctx_file->f_inode->i_mapping->private_data = ctx;
+	ctx->ctx_file->f_inode->i_size = PAGE_SIZE * (loff_t)nr_pages;
+
+	for (i=0; i<nr_pages; i++) {
+		struct page *page;
+		void *ptr;
+		page = find_or_create_page(ctx->ctx_file->f_inode->i_mapping,
+					   i, GFP_KERNEL);
+		if (!page) {
+			break;
+		}
+		ptr = kmap(page);
+		clear_page(ptr);
+		kunmap(page);
+		SetPageUptodate(page);
+		SetPageDirty(page);
+		unlock_page(page);
+	}
+
 	nr_events = (PAGE_SIZE * nr_pages - sizeof(struct aio_ring)) / sizeof(struct io_event);
 
 	ctx->nr_events = 0;
@@ -180,20 +261,25 @@ static int aio_setup_ring(struct kioctx *ctx)
 	ctx->mmap_size = nr_pages * PAGE_SIZE;
 	pr_debug("attempting mmap of %lu bytes\n", ctx->mmap_size);
 	down_write(&mm->mmap_sem);
-	ctx->mmap_base = do_mmap_pgoff(NULL, 0, ctx->mmap_size,
+	ctx->mmap_base = do_mmap_pgoff(ctx->ctx_file, 0, ctx->mmap_size,
 				       PROT_READ|PROT_WRITE,
-				       MAP_ANONYMOUS|MAP_PRIVATE, 0, &populate);
+				       MAP_SHARED|MAP_POPULATE, 0,
+				       &populate);
 	if (IS_ERR((void *)ctx->mmap_base)) {
 		up_write(&mm->mmap_sem);
 		ctx->mmap_size = 0;
 		aio_free_ring(ctx);
 		return -EAGAIN;
 	}
+	up_write(&mm->mmap_sem);
+	mm_populate(ctx->mmap_base, populate);
 
 	pr_debug("mmap address: 0x%08lx\n", ctx->mmap_base);
 	ctx->nr_pages = get_user_pages(current, mm, ctx->mmap_base, nr_pages,
 				       1, 0, ctx->ring_pages, NULL);
-	up_write(&mm->mmap_sem);
+	for (i=0; i<ctx->nr_pages; i++) {
+		put_page(ctx->ring_pages[i]);
+	}
 
 	if (unlikely(ctx->nr_pages != nr_pages)) {
 		aio_free_ring(ctx);
@@ -403,6 +489,8 @@ out_cleanup:
 	err = -EAGAIN;
 	aio_free_ring(ctx);
 out_freectx:
+	if (ctx->ctx_file)
+		fput(ctx->ctx_file);
 	kmem_cache_free(kioctx_cachep, ctx);
 	pr_debug("error allocating ioctx %d\n", err);
 	return ERR_PTR(err);
@@ -852,6 +940,7 @@ SYSCALL_DEFINE2(io_setup, unsigned, nr_events, aio_context_t __user *, ctxp)
 	ioctx = ioctx_alloc(nr_events);
 	ret = PTR_ERR(ioctx);
 	if (!IS_ERR(ioctx)) {
+		ctx = ioctx->user_id;
 		ret = put_user(ioctx->user_id, ctxp);
 		if (ret)
 			kill_ioctx(ioctx);
diff --git a/include/linux/migrate.h b/include/linux/migrate.h
index a405d3dc..b6f3289 100644
--- a/include/linux/migrate.h
+++ b/include/linux/migrate.h
@@ -55,6 +55,9 @@ extern int migrate_vmas(struct mm_struct *mm,
 extern void migrate_page_copy(struct page *newpage, struct page *page);
 extern int migrate_huge_page_move_mapping(struct address_space *mapping,
 				  struct page *newpage, struct page *page);
+extern int migrate_page_move_mapping(struct address_space *mapping,
+                struct page *newpage, struct page *page,
+                struct buffer_head *head, enum migrate_mode mode);
 #else
 
 static inline void putback_lru_pages(struct list_head *l) {}
diff --git a/mm/migrate.c b/mm/migrate.c
index 27ed225..ac9c3a9 100644
--- a/mm/migrate.c
+++ b/mm/migrate.c
@@ -294,7 +294,7 @@ static inline bool buffer_migrate_lock_buffers(struct buffer_head *head,
  * 2 for pages with a mapping
  * 3 for pages with a mapping and PagePrivate/PagePrivate2 set.
  */
-static int migrate_page_move_mapping(struct address_space *mapping,
+int migrate_page_move_mapping(struct address_space *mapping,
 		struct page *newpage, struct page *page,
 		struct buffer_head *head, enum migrate_mode mode)
 {

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

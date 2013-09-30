Return-Path: <owner-linux-mm@kvack.org>
Date: Mon, 30 Sep 2013 17:50:57 -0400
From: Benjamin LaHaise <bcrl@kvack.org>
Subject: [PATCH] aio: fix use-after-free in aio_migratepage
Message-ID: <20130930215057.GA28362@kvack.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-aio@kvack.org
Cc: linux-fsdevel@vger.kernel.org, linux-mm@kvack.org

[sent for review -- hopefully a couple of other people can ack this]

Dmitry Vyukov managed to trigger a case where aio_migratepage can cause a
use-after-free during teardown of the aio ring buffer's mapping.  This turns
out to be caused by access to the ioctx's ring_pages via the migratepage
operation which was not being protected by any locks during ioctx freeing.
Use the address_space's private_lock to protect use and updates of the mapping's
private_data, and make ioctx teardown unlink the ioctx from the address space.

Reported-by: Dmitry Vyukov <dvyukov@google.com>
Tested-by: Dmitry Vyukov <dvyukov@google.com>
Signed-off-by: Benjamin LaHaise <bcrl@kvack.org>
---
 fs/aio.c | 52 +++++++++++++++++++++++++++++++++++++---------------
 1 file changed, 37 insertions(+), 15 deletions(-)

diff --git a/fs/aio.c b/fs/aio.c
index 6b868f0..067e3d3 100644
--- a/fs/aio.c
+++ b/fs/aio.c
@@ -167,10 +167,25 @@ static int __init aio_setup(void)
 }
 __initcall(aio_setup);
 
+static void put_aio_ring_file(struct kioctx *ctx)
+{
+	struct file *aio_ring_file = ctx->aio_ring_file;
+	if (aio_ring_file) {
+		truncate_setsize(aio_ring_file->f_inode, 0);
+
+		/* Prevent further access to the kioctx from migratepages */
+		spin_lock(&aio_ring_file->f_inode->i_mapping->private_lock);
+		aio_ring_file->f_inode->i_mapping->private_data = NULL;
+		ctx->aio_ring_file = NULL;
+		spin_unlock(&aio_ring_file->f_inode->i_mapping->private_lock);
+
+		fput(aio_ring_file);
+	}
+}
+
 static void aio_free_ring(struct kioctx *ctx)
 {
 	int i;
-	struct file *aio_ring_file = ctx->aio_ring_file;
 
 	for (i = 0; i < ctx->nr_pages; i++) {
 		pr_debug("pid(%d) [%d] page->count=%d\n", current->pid, i,
@@ -178,14 +193,10 @@ static void aio_free_ring(struct kioctx *ctx)
 		put_page(ctx->ring_pages[i]);
 	}
 
+	put_aio_ring_file(ctx);
+
 	if (ctx->ring_pages && ctx->ring_pages != ctx->internal_pages)
 		kfree(ctx->ring_pages);
-
-	if (aio_ring_file) {
-		truncate_setsize(aio_ring_file->f_inode, 0);
-		fput(aio_ring_file);
-		ctx->aio_ring_file = NULL;
-	}
 }
 
 static int aio_ring_mmap(struct file *file, struct vm_area_struct *vma)
@@ -207,9 +218,8 @@ static int aio_set_page_dirty(struct page *page)
 static int aio_migratepage(struct address_space *mapping, struct page *new,
 			struct page *old, enum migrate_mode mode)
 {
-	struct kioctx *ctx = mapping->private_data;
+	struct kioctx *ctx;
 	unsigned long flags;
-	unsigned idx = old->index;
 	int rc;
 
 	/* Writeback must be complete */
@@ -224,10 +234,23 @@ static int aio_migratepage(struct address_space *mapping, struct page *new,
 
 	get_page(new);
 
-	spin_lock_irqsave(&ctx->completion_lock, flags);
-	migrate_page_copy(new, old);
-	ctx->ring_pages[idx] = new;
-	spin_unlock_irqrestore(&ctx->completion_lock, flags);
+	/* We can potentially race against kioctx teardown here.  Use the
+	 * address_space's private data lock to protect the mapping's
+	 * private_data.
+	 */
+	spin_lock(&mapping->private_lock);
+	ctx = mapping->private_data;
+	if (ctx) {
+		pgoff_t idx;
+		spin_lock_irqsave(&ctx->completion_lock, flags);
+		migrate_page_copy(new, old);
+		idx = old->index;
+		if (idx < (pgoff_t)ctx->nr_pages)
+			ctx->ring_pages[idx] = new;
+		spin_unlock_irqrestore(&ctx->completion_lock, flags);
+	} else
+		rc = -EBUSY;
+	spin_unlock(&mapping->private_lock);
 
 	return rc;
 }
@@ -617,8 +640,7 @@ out_freepcpu:
 out_freeref:
 	free_percpu(ctx->users.pcpu_count);
 out_freectx:
-	if (ctx->aio_ring_file)
-		fput(ctx->aio_ring_file);
+	put_aio_ring_file(ctx);
 	kmem_cache_free(kioctx_cachep, ctx);
 	pr_debug("error allocating ioctx %d\n", err);
 	return ERR_PTR(err);
-- 
1.8.2.1


-- 
"Thought is the essence of where you are now."

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

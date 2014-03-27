Return-Path: <owner-linux-mm@kvack.org>
Date: Thu, 27 Mar 2014 09:46:53 -0400
From: Benjamin LaHaise <bcrl@kvack.org>
Subject: git pull -- [PATCH] aio: v2 ensure access to ctx->ring_pages is correctly serialised
Message-ID: <20140327134653.GA22407@kvack.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Yasuaki Ishimatsu <isimatu.yasuaki@jp.fujitsu.com>, Sasha Levin <sasha.levin@oracle.com>, Tang Chen <tangchen@cn.fujitsu.com>, Gu Zheng <guz.fnst@cn.fujitsu.com>, linux-kernel@vger.kernel.org, stable@vger.kernel.org, linux-aio@kvack.org, linux-mm@kvack.org

Hello Linus and everyone,

Please pull the change below from my aio-fixes git repository at 
git://git.kvack.org/~bcrl/aio-fixes.git which fixes a couple of issues 
found in the aio page migration code.  This patch is applicable to the 
3.12 and later stable trees as well.  Thanks to all the folks involved 
in reporting & testing.

		-ben
----snip----

As reported by Tang Chen, Gu Zheng and Yasuaki Isimatsu, the following issues
exist in the aio ring page migration support.

As a result, for example, we have the following problem:

            thread 1                      |              thread 2
                                          |
aio_migratepage()                         |
 |-> take ctx->completion_lock            |
 |-> migrate_page_copy(new, old)          |
 |   *NOW*, ctx->ring_pages[idx] == old   |
                                          |
                                          |    *NOW*, ctx->ring_pages[idx] == old
                                          |    aio_read_events_ring()
                                          |     |-> ring = kmap_atomic(ctx->ring_pages[0])
                                          |     |-> ring->head = head;          *HERE, write to the old ring page*
                                          |     |-> kunmap_atomic(ring);
                                          |
 |-> ctx->ring_pages[idx] = new           |
 |   *BUT NOW*, the content of            |
 |    ring_pages[idx] is old.             |
 |-> release ctx->completion_lock         |

As above, the new ring page will not be updated.

Fix this issue, as well as prevent races in aio_ring_setup() by taking
the ring_lock mutex during page migration and where otherwise applicable.
This avoids the overhead of taking another spinlock in
aio_read_events_ring() as Tang's and Gu's original fix did, pushing the
overhead into the migration code.

Note that to handle the nesting of ring_lock inside of mmap_sem, the
migratepage operation uses mutex_trylock().  Page migration is not a 100%
critical operation in this case, so the ocassional failure can be
tolerated.  This issue was reported by Sasha Levin.

Reported-by: Yasuaki Ishimatsu <isimatu.yasuaki@jp.fujitsu.com>
Reported-by: Sasha Levin <sasha.levin@oracle.com>
Signed-off-by: Benjamin LaHaise <bcrl@kvack.org>
Cc: Tang Chen <tangchen@cn.fujitsu.com>
Cc: Gu Zheng <guz.fnst@cn.fujitsu.com>
Cc: stable@vger.kernel.org
---
 fs/aio.c | 55 ++++++++++++++++++++++++++++++++++++++++++++++++-------
 1 file changed, 48 insertions(+), 7 deletions(-)

diff --git a/fs/aio.c b/fs/aio.c
index 062a5f6..bfe1497 100644
--- a/fs/aio.c
+++ b/fs/aio.c
@@ -241,8 +241,10 @@ static void put_aio_ring_file(struct kioctx *ctx)
 
 static void aio_free_ring(struct kioctx *ctx)
 {
+	unsigned long flags;
 	int i;
 
+	spin_lock_irqsave(&ctx->completion_lock, flags);
 	for (i = 0; i < ctx->nr_pages; i++) {
 		struct page *page;
 		pr_debug("pid(%d) [%d] page->count=%d\n", current->pid, i,
@@ -253,6 +255,7 @@ static void aio_free_ring(struct kioctx *ctx)
 		ctx->ring_pages[i] = NULL;
 		put_page(page);
 	}
+	spin_unlock_irqrestore(&ctx->completion_lock, flags);
 
 	put_aio_ring_file(ctx);
 
@@ -287,9 +290,29 @@ static int aio_migratepage(struct address_space *mapping, struct page *new,
 
 	rc = 0;
 
-	/* Make sure the old page hasn't already been changed */
+	/* Get a reference on the ioctx so we can take the ring_lock mutex. */
 	spin_lock(&mapping->private_lock);
 	ctx = mapping->private_data;
+	if (ctx)
+		percpu_ref_get(&ctx->users);
+	spin_unlock(&mapping->private_lock);
+
+	if (!ctx)
+		return -EINVAL;
+
+	/* We use mutex_trylock() here as the callers of migratepage may
+	 * already be holding current->mm->mmap_sem, and ->ring_lock must be
+	 * outside of mmap_sem due to its usage in aio_read_events_ring().
+	 * Since page migration is not an absolutely critical operation, the
+	 * occasional failure here is acceptable.
+	 */
+	if (!mutex_trylock(&ctx->ring_lock)) {
+		percpu_ref_put(&ctx->users);
+		return -EAGAIN;
+	}
+
+	/* Make sure the old page hasn't already been changed */
+	spin_lock(&mapping->private_lock);
 	if (ctx) {
 		pgoff_t idx;
 		spin_lock_irqsave(&ctx->completion_lock, flags);
@@ -305,7 +328,7 @@ static int aio_migratepage(struct address_space *mapping, struct page *new,
 	spin_unlock(&mapping->private_lock);
 
 	if (rc != 0)
-		return rc;
+		goto out_unlock;
 
 	/* Writeback must be complete */
 	BUG_ON(PageWriteback(old));
@@ -314,7 +337,7 @@ static int aio_migratepage(struct address_space *mapping, struct page *new,
 	rc = migrate_page_move_mapping(mapping, new, old, NULL, mode, 1);
 	if (rc != MIGRATEPAGE_SUCCESS) {
 		put_page(new);
-		return rc;
+		goto out_unlock;
 	}
 
 	/* We can potentially race against kioctx teardown here.  Use the
@@ -346,6 +369,9 @@ static int aio_migratepage(struct address_space *mapping, struct page *new,
 	else
 		put_page(new);
 
+out_unlock:
+	mutex_unlock(&ctx->ring_lock);
+	percpu_ref_put(&ctx->users);
 	return rc;
 }
 #endif
@@ -380,7 +406,7 @@ static int aio_setup_ring(struct kioctx *ctx)
 	file = aio_private_file(ctx, nr_pages);
 	if (IS_ERR(file)) {
 		ctx->aio_ring_file = NULL;
-		return -EAGAIN;
+		return -ENOMEM;
 	}
 
 	ctx->aio_ring_file = file;
@@ -415,7 +441,7 @@ static int aio_setup_ring(struct kioctx *ctx)
 
 	if (unlikely(i != nr_pages)) {
 		aio_free_ring(ctx);
-		return -EAGAIN;
+		return -ENOMEM;
 	}
 
 	ctx->mmap_size = nr_pages * PAGE_SIZE;
@@ -429,7 +455,7 @@ static int aio_setup_ring(struct kioctx *ctx)
 	if (IS_ERR((void *)ctx->mmap_base)) {
 		ctx->mmap_size = 0;
 		aio_free_ring(ctx);
-		return -EAGAIN;
+		return -ENOMEM;
 	}
 
 	pr_debug("mmap address: 0x%08lx\n", ctx->mmap_base);
@@ -556,9 +582,17 @@ static int ioctx_add_table(struct kioctx *ctx, struct mm_struct *mm)
 					rcu_read_unlock();
 					spin_unlock(&mm->ioctx_lock);
 
+					/*
+					 * Accessing ring pages must be done
+					 * holding ctx->completion_lock to
+					 * prevent aio ring page migration
+					 * procedure from migrating ring pages.
+					 */
+					spin_lock_irq(&ctx->completion_lock);
 					ring = kmap_atomic(ctx->ring_pages[0]);
 					ring->id = ctx->id;
 					kunmap_atomic(ring);
+					spin_unlock_irq(&ctx->completion_lock);
 					return 0;
 				}
 
@@ -657,7 +691,13 @@ static struct kioctx *ioctx_alloc(unsigned nr_events)
 	if (!ctx->cpu)
 		goto err;
 
-	if (aio_setup_ring(ctx) < 0)
+	/* Prevent races with page migration in aio_setup_ring() by holding
+	 * the ring_lock mutex.
+	 */
+	mutex_lock(&ctx->ring_lock);
+	err = aio_setup_ring(ctx);
+	mutex_unlock(&ctx->ring_lock);
+	if (err < 0)
 		goto err;
 
 	atomic_set(&ctx->reqs_available, ctx->nr_events - 1);
@@ -1024,6 +1064,7 @@ static long aio_read_events_ring(struct kioctx *ctx,
 
 	mutex_lock(&ctx->ring_lock);
 
+	/* Access to ->ring_pages here is protected by ctx->ring_lock. */
 	ring = kmap_atomic(ctx->ring_pages[0]);
 	head = ring->head;
 	tail = ring->tail;
-- 
1.8.2.1


-- 
"Thought is the essence of where you are now."

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

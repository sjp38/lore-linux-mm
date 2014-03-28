Return-Path: <owner-linux-mm@kvack.org>
Date: Fri, 28 Mar 2014 10:58:26 -0400
From: Benjamin LaHaise <bcrl@kvack.org>
Subject: Re: git pull -- [PATCH] aio: v2 ensure access to ctx->ring_pages is correctly serialised
Message-ID: <20140328145826.GE29656@kvack.org>
References: <20140327134653.GA22407@kvack.org> <CA+55aFzFgY4-26SO-MsFagzaj9JevkeeT1OJ3pjj-tcjuNCEeQ@mail.gmail.com> <CA+55aFx7vg2rvOu6Bu_e8+BB=ymoUMp0AM9JmAuUuSgo0LVEwg@mail.gmail.com> <20140327200851.GL17679@kvack.org> <CA+55aFy_sRnFu7KguAUAN5kbHk3Qa_0ZuATPU5i8LOyMMWZ_5g@mail.gmail.com> <20140327205749.GM17679@kvack.org> <CA+55aFyj2XFMkT1T=EPPw1CANt6atyFNmMaeaDm-p-NWfRNA+w@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CA+55aFyj2XFMkT1T=EPPw1CANt6atyFNmMaeaDm-p-NWfRNA+w@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Yasuaki Ishimatsu <isimatu.yasuaki@jp.fujitsu.com>, Sasha Levin <sasha.levin@oracle.com>, Tang Chen <tangchen@cn.fujitsu.com>, Gu Zheng <guz.fnst@cn.fujitsu.com>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, stable <stable@vger.kernel.org>, linux-aio@kvack.org, linux-mm <linux-mm@kvack.org>

On Thu, Mar 27, 2014 at 02:34:08PM -0700, Linus Torvalds wrote:
> On Thu, Mar 27, 2014 at 1:57 PM, Benjamin LaHaise <bcrl@kvack.org> wrote:
> >
> > *nod* -- I added that to the below variant.
> 
> You still have "goto err" for cases that have the ctx locked. Which
> means that the thing gets free'd while still locked, which causes
> problems for lockdep etc, so don't do it.
> 
> Do what I did: add a "err_unlock" label, and make anybody after the
> mutex_lock() call it. No broken shortcuts.

Here's a respin of that part.  I just moved the mutex initialization up so 
that it's always valid in the err path.  I have also run this version of 
the patch through xfstests and my migration test programs and it looks 
okay.

		-ben
-- 
"Thought is the essence of where you are now."

commit fa8a53c39f3fdde98c9eace6a9b412143f0f6ed6
Author: Benjamin LaHaise <bcrl@kvack.org>
Date:   Fri Mar 28 10:14:45 2014 -0400

    aio: v4 ensure access to ctx->ring_pages is correctly serialised for migration
    
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
    
    Fix this issue, as well as prevent races in aio_ring_setup() by holding
    the ring_lock mutex during kioctx setup and page migration.  This avoids
    the overhead of taking another spinlock in aio_read_events_ring() as Tang's
    and Gu's original fix did, pushing the overhead into the migration code.
    
    Note that to handle the nesting of ring_lock inside of mmap_sem, the
    migratepage operation uses mutex_trylock().  Page migration is not a 100%
    critical operation in this case, so the ocassional failure can be
    tolerated.  This issue was reported by Sasha Levin.
    
    Based on feedback from Linus, avoid the extra taking of ctx->completion_lock.
    Instead, make page migration fully serialised by mapping->private_lock, and
    have aio_free_ring() simply disconnect the kioctx from the mapping by calling
    put_aio_ring_file() before touching ctx->ring_pages[].  This simplifies the
    error handling logic in aio_migratepage(), and should improve robustness.
    
    v4: always do mutex_unlock() in cases when kioctx setup fails.
    
    Reported-by: Yasuaki Ishimatsu <isimatu.yasuaki@jp.fujitsu.com>
    Reported-by: Sasha Levin <sasha.levin@oracle.com>
    Signed-off-by: Benjamin LaHaise <bcrl@kvack.org>
    Cc: Tang Chen <tangchen@cn.fujitsu.com>
    Cc: Gu Zheng <guz.fnst@cn.fujitsu.com>
    Cc: stable@vger.kernel.org

diff --git a/fs/aio.c b/fs/aio.c
index 062a5f6..12a3de0e 100644
--- a/fs/aio.c
+++ b/fs/aio.c
@@ -52,7 +52,8 @@
 struct aio_ring {
 	unsigned	id;	/* kernel internal index number */
 	unsigned	nr;	/* number of io_events */
-	unsigned	head;
+	unsigned	head;	/* Written to by userland or under ring_lock
+				 * mutex by aio_read_events_ring(). */
 	unsigned	tail;
 
 	unsigned	magic;
@@ -243,6 +244,11 @@ static void aio_free_ring(struct kioctx *ctx)
 {
 	int i;
 
+	/* Disconnect the kiotx from the ring file.  This prevents future
+	 * accesses to the kioctx from page migration.
+	 */
+	put_aio_ring_file(ctx);
+
 	for (i = 0; i < ctx->nr_pages; i++) {
 		struct page *page;
 		pr_debug("pid(%d) [%d] page->count=%d\n", current->pid, i,
@@ -254,8 +260,6 @@ static void aio_free_ring(struct kioctx *ctx)
 		put_page(page);
 	}
 
-	put_aio_ring_file(ctx);
-
 	if (ctx->ring_pages && ctx->ring_pages != ctx->internal_pages) {
 		kfree(ctx->ring_pages);
 		ctx->ring_pages = NULL;
@@ -283,29 +287,38 @@ static int aio_migratepage(struct address_space *mapping, struct page *new,
 {
 	struct kioctx *ctx;
 	unsigned long flags;
+	pgoff_t idx;
 	int rc;
 
 	rc = 0;
 
-	/* Make sure the old page hasn't already been changed */
+	/* mapping->private_lock here protects against the kioctx teardown.  */
 	spin_lock(&mapping->private_lock);
 	ctx = mapping->private_data;
-	if (ctx) {
-		pgoff_t idx;
-		spin_lock_irqsave(&ctx->completion_lock, flags);
-		idx = old->index;
-		if (idx < (pgoff_t)ctx->nr_pages) {
-			if (ctx->ring_pages[idx] != old)
-				rc = -EAGAIN;
-		} else
-			rc = -EINVAL;
-		spin_unlock_irqrestore(&ctx->completion_lock, flags);
+	if (!ctx) {
+		rc = -EINVAL;
+		goto out;
+	}
+
+	/* The ring_lock mutex.  The prevents aio_read_events() from writing
+	 * to the ring's head, and prevents page migration from mucking in
+	 * a partially initialized kiotx.
+	 */
+	if (!mutex_trylock(&ctx->ring_lock)) {
+		rc = -EAGAIN;
+		goto out;
+	}
+
+	idx = old->index;
+	if (idx < (pgoff_t)ctx->nr_pages) {
+		/* Make sure the old page hasn't already been changed */
+		if (ctx->ring_pages[idx] != old)
+			rc = -EAGAIN;
 	} else
 		rc = -EINVAL;
-	spin_unlock(&mapping->private_lock);
 
 	if (rc != 0)
-		return rc;
+		goto out_unlock;
 
 	/* Writeback must be complete */
 	BUG_ON(PageWriteback(old));
@@ -314,38 +327,26 @@ static int aio_migratepage(struct address_space *mapping, struct page *new,
 	rc = migrate_page_move_mapping(mapping, new, old, NULL, mode, 1);
 	if (rc != MIGRATEPAGE_SUCCESS) {
 		put_page(new);
-		return rc;
+		goto out_unlock;
 	}
 
-	/* We can potentially race against kioctx teardown here.  Use the
-	 * address_space's private data lock to protect the mapping's
-	 * private_data.
+	/* Take completion_lock to prevent other writes to the ring buffer
+	 * while the old page is copied to the new.  This prevents new
+	 * events from being lost.
 	 */
-	spin_lock(&mapping->private_lock);
-	ctx = mapping->private_data;
-	if (ctx) {
-		pgoff_t idx;
-		spin_lock_irqsave(&ctx->completion_lock, flags);
-		migrate_page_copy(new, old);
-		idx = old->index;
-		if (idx < (pgoff_t)ctx->nr_pages) {
-			/* And only do the move if things haven't changed */
-			if (ctx->ring_pages[idx] == old)
-				ctx->ring_pages[idx] = new;
-			else
-				rc = -EAGAIN;
-		} else
-			rc = -EINVAL;
-		spin_unlock_irqrestore(&ctx->completion_lock, flags);
-	} else
-		rc = -EBUSY;
-	spin_unlock(&mapping->private_lock);
+	spin_lock_irqsave(&ctx->completion_lock, flags);
+	migrate_page_copy(new, old);
+	BUG_ON(ctx->ring_pages[idx] != old);
+	ctx->ring_pages[idx] = new;
+	spin_unlock_irqrestore(&ctx->completion_lock, flags);
 
-	if (rc == MIGRATEPAGE_SUCCESS)
-		put_page(old);
-	else
-		put_page(new);
+	/* The old page is no longer accessible. */
+	put_page(old);
 
+out_unlock:
+	mutex_unlock(&ctx->ring_lock);
+out:
+	spin_unlock(&mapping->private_lock);
 	return rc;
 }
 #endif
@@ -380,7 +381,7 @@ static int aio_setup_ring(struct kioctx *ctx)
 	file = aio_private_file(ctx, nr_pages);
 	if (IS_ERR(file)) {
 		ctx->aio_ring_file = NULL;
-		return -EAGAIN;
+		return -ENOMEM;
 	}
 
 	ctx->aio_ring_file = file;
@@ -415,7 +416,7 @@ static int aio_setup_ring(struct kioctx *ctx)
 
 	if (unlikely(i != nr_pages)) {
 		aio_free_ring(ctx);
-		return -EAGAIN;
+		return -ENOMEM;
 	}
 
 	ctx->mmap_size = nr_pages * PAGE_SIZE;
@@ -429,7 +430,7 @@ static int aio_setup_ring(struct kioctx *ctx)
 	if (IS_ERR((void *)ctx->mmap_base)) {
 		ctx->mmap_size = 0;
 		aio_free_ring(ctx);
-		return -EAGAIN;
+		return -ENOMEM;
 	}
 
 	pr_debug("mmap address: 0x%08lx\n", ctx->mmap_base);
@@ -556,6 +557,10 @@ static int ioctx_add_table(struct kioctx *ctx, struct mm_struct *mm)
 					rcu_read_unlock();
 					spin_unlock(&mm->ioctx_lock);
 
+					/* While kioctx setup is in progress,
+					 * we are protected from page migration
+					 * changes ring_pages by ->ring_lock.
+					 */
 					ring = kmap_atomic(ctx->ring_pages[0]);
 					ring->id = ctx->id;
 					kunmap_atomic(ring);
@@ -640,24 +645,28 @@ static struct kioctx *ioctx_alloc(unsigned nr_events)
 
 	ctx->max_reqs = nr_events;
 
-	if (percpu_ref_init(&ctx->users, free_ioctx_users))
-		goto err;
-
-	if (percpu_ref_init(&ctx->reqs, free_ioctx_reqs))
-		goto err;
-
 	spin_lock_init(&ctx->ctx_lock);
 	spin_lock_init(&ctx->completion_lock);
 	mutex_init(&ctx->ring_lock);
+	/* Protect against page migration throughout kiotx setup by keeping
+	 * the ring_lock mutex held until setup is complete. */
+	mutex_lock(&ctx->ring_lock);
 	init_waitqueue_head(&ctx->wait);
 
 	INIT_LIST_HEAD(&ctx->active_reqs);
 
+	if (percpu_ref_init(&ctx->users, free_ioctx_users))
+		goto err;
+
+	if (percpu_ref_init(&ctx->reqs, free_ioctx_reqs))
+		goto err;
+
 	ctx->cpu = alloc_percpu(struct kioctx_cpu);
 	if (!ctx->cpu)
 		goto err;
 
-	if (aio_setup_ring(ctx) < 0)
+	err = aio_setup_ring(ctx);
+	if (err < 0)
 		goto err;
 
 	atomic_set(&ctx->reqs_available, ctx->nr_events - 1);
@@ -683,6 +692,9 @@ static struct kioctx *ioctx_alloc(unsigned nr_events)
 	if (err)
 		goto err_cleanup;
 
+	/* Release the ring_lock mutex now that all setup is complete. */
+	mutex_unlock(&ctx->ring_lock);
+
 	pr_debug("allocated ioctx %p[%ld]: mm=%p mask=0x%x\n",
 		 ctx, ctx->user_id, mm, ctx->nr_events);
 	return ctx;
@@ -692,6 +704,7 @@ err_cleanup:
 err_ctx:
 	aio_free_ring(ctx);
 err:
+	mutex_unlock(&ctx->ring_lock);
 	free_percpu(ctx->cpu);
 	free_percpu(ctx->reqs.pcpu_count);
 	free_percpu(ctx->users.pcpu_count);
@@ -1024,6 +1037,7 @@ static long aio_read_events_ring(struct kioctx *ctx,
 
 	mutex_lock(&ctx->ring_lock);
 
+	/* Access to ->ring_pages here is protected by ctx->ring_lock. */
 	ring = kmap_atomic(ctx->ring_pages[0]);
 	head = ring->head;
 	tail = ring->tail;

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

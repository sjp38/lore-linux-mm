Return-Path: <owner-linux-mm@kvack.org>
Date: Thu, 27 Mar 2014 16:08:51 -0400
From: Benjamin LaHaise <bcrl@kvack.org>
Subject: Re: git pull -- [PATCH] aio: v2 ensure access to ctx->ring_pages is correctly serialised
Message-ID: <20140327200851.GL17679@kvack.org>
References: <20140327134653.GA22407@kvack.org> <CA+55aFzFgY4-26SO-MsFagzaj9JevkeeT1OJ3pjj-tcjuNCEeQ@mail.gmail.com> <CA+55aFx7vg2rvOu6Bu_e8+BB=ymoUMp0AM9JmAuUuSgo0LVEwg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CA+55aFx7vg2rvOu6Bu_e8+BB=ymoUMp0AM9JmAuUuSgo0LVEwg@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Yasuaki Ishimatsu <isimatu.yasuaki@jp.fujitsu.com>, Sasha Levin <sasha.levin@oracle.com>, Tang Chen <tangchen@cn.fujitsu.com>, Gu Zheng <guz.fnst@cn.fujitsu.com>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, stable <stable@vger.kernel.org>, linux-aio@kvack.org, linux-mm <linux-mm@kvack.org>

On Thu, Mar 27, 2014 at 12:43:13PM -0700, Linus Torvalds wrote:
> On Thu, Mar 27, 2014 at 11:16 AM, Linus Torvalds
> <torvalds@linux-foundation.org> wrote:
> >
> > It would all be cleaner if all the setup was done with the
> > ctx->ring_lock held (you can even *initialize* it to the locked state,
> > since this is the function that allocates it!) and then it would just
> > be unlocked when done.
> 
> Attached is a TOTALLY UNTESTED patch based on Ben's one that does at
> least this minimal cleanup, in addition to dropping the
> completion_lock in aio_free_ring() in favor of instead just doing the
> "put_aio_ring_file()" first.

I was just about to send a slightly different variant (see below).  Your rant 
was entirely justified.

> I do want to stress that "untested" part. I'm not going to commit
> this, because I don't have any real test-cases even if it were to boot
> and work for me otherwise.

The patch below is lightly tested -- my migration test case is able to 
successfully move the aio ring around multiple times.  It still needs to 
be run through some more thorough tests (like Trinity).  See below for 
the differences relative to your patch.

> I can't say that I like the locking. It really seems totally
> mis-designed to me. For example, the first completion_lock in
> aio_migratepage() seems to be total BS - it's locking against other
> migrations, but that's what "mapping->private_lock" (and now
> "ctx->ring_lock") protect against.

What I did instead is to just hold mapping->private_lock over the entire 
operation of aio_migratepage.  That gets rid of the probably broken attempt 
to take a reference count on the kioctx within aio_migratepage(), and makes 
it completely clear that migration won't touch a kioctx after 
put_aio_ring_file() returns.  It also cleans up much of the error handling 
in aio_migratepage() since things cannot change unexpectedly.

> The *second* completion_lock use in aio_migratepage() is actually
> valid: we can't copy the page contents to a new one when a completion
> might change the ring tail data, because then the change might be done
> to the old page but not the new page. But there the "check if things
> haven't changed" is bogus, since we've held the ring_lock.

Yes, that should have been cleaned up since it was no longer needed.

> I did *not* clean up that part. But it's an example of how the locking
> here seems to be more "voodoo programming" than actually thought about
> and designed.

I also added a few comments to help explain the locking.

> Please, somebody who has test-cases look at this, ok?

How does this version look?

		-ben

 aio.c |  107 +++++++++++++++++++++++++++++++++++++-----------------------------
 1 file changed, 60 insertions(+), 47 deletions(-)

diff --git a/fs/aio.c b/fs/aio.c
index 062a5f6..cdec97c 100644
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
@@ -649,6 +654,9 @@ static struct kioctx *ioctx_alloc(unsigned nr_events)
 	spin_lock_init(&ctx->ctx_lock);
 	spin_lock_init(&ctx->completion_lock);
 	mutex_init(&ctx->ring_lock);
+	/* Protect against page migration throughout kiotx setup by keeping
+	 * the ring_lock mutex held until setup is complete. */
+	mutex_lock(&ctx->ring_lock);
 	init_waitqueue_head(&ctx->wait);
 
 	INIT_LIST_HEAD(&ctx->active_reqs);
@@ -657,7 +665,8 @@ static struct kioctx *ioctx_alloc(unsigned nr_events)
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
@@ -1024,6 +1036,7 @@ static long aio_read_events_ring(struct kioctx *ctx,
 
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

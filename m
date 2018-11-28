Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf1-f200.google.com (mail-pf1-f200.google.com [209.85.210.200])
	by kanga.kvack.org (Postfix) with ESMTP id E8F026B4E5F
	for <linux-mm@kvack.org>; Wed, 28 Nov 2018 13:35:38 -0500 (EST)
Received: by mail-pf1-f200.google.com with SMTP id n17so9072334pfk.23
        for <linux-mm@kvack.org>; Wed, 28 Nov 2018 10:35:38 -0800 (PST)
From: Matthew Wilcox <willy@infradead.org>
Subject: [PATCH] aio: Convert ioctx_table to XArray
Date: Wed, 28 Nov 2018 10:35:31 -0800
Message-Id: <20181128183531.5139-1-willy@infradead.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Alexander Viro <viro@zeniv.linux.org.uk>, Benjamin LaHaise <bcrl@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, Kees Cook <keescook@chromium.org>, linux-fsdevel@vger.kernel.org, linux-aio@kvack.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Dan Carpenter <dan.carpenter@oracle.com>
Cc: Matthew Wilcox <willy@infradead.org>

This custom resizing array was vulnerable to a Spectre attack (speculating
off the end of an array to a user-controlled offset).  The XArray is
not vulnerable to Spectre as it always masks its lookups to be within
the bounds of the array.

Signed-off-by: Matthew Wilcox <willy@infradead.org>
---
 fs/aio.c                 | 182 ++++++++++++++-------------------------
 include/linux/mm_types.h |   5 +-
 kernel/fork.c            |   3 +-
 mm/debug.c               |   6 --
 4 files changed, 67 insertions(+), 129 deletions(-)

diff --git a/fs/aio.c b/fs/aio.c
index 301e6314183b..51ba7446a24f 100644
--- a/fs/aio.c
+++ b/fs/aio.c
@@ -71,12 +71,6 @@ struct aio_ring {
 
 #define AIO_RING_PAGES	8
 
-struct kioctx_table {
-	struct rcu_head		rcu;
-	unsigned		nr;
-	struct kioctx __rcu	*table[];
-};
-
 struct kioctx_cpu {
 	unsigned		reqs_available;
 };
@@ -313,27 +307,22 @@ static int aio_ring_mremap(struct vm_area_struct *vma)
 {
 	struct file *file = vma->vm_file;
 	struct mm_struct *mm = vma->vm_mm;
-	struct kioctx_table *table;
-	int i, res = -EINVAL;
+	struct kioctx *ctx;
+	unsigned long index;
+	int res = -EINVAL;
 
-	spin_lock(&mm->ioctx_lock);
-	rcu_read_lock();
-	table = rcu_dereference(mm->ioctx_table);
-	for (i = 0; i < table->nr; i++) {
-		struct kioctx *ctx;
-
-		ctx = rcu_dereference(table->table[i]);
-		if (ctx && ctx->aio_ring_file == file) {
-			if (!atomic_read(&ctx->dead)) {
-				ctx->user_id = ctx->mmap_base = vma->vm_start;
-				res = 0;
-			}
-			break;
+	xa_lock(&mm->ioctx);
+	xa_for_each(&mm->ioctx, ctx, index, ULONG_MAX, XA_PRESENT) {
+		if (ctx->aio_ring_file != file)
+			continue;
+		if (!atomic_read(&ctx->dead)) {
+			ctx->user_id = ctx->mmap_base = vma->vm_start;
+			res = 0;
 		}
+		break;
 	}
+	xa_unlock(&mm->ioctx);
 
-	rcu_read_unlock();
-	spin_unlock(&mm->ioctx_lock);
 	return res;
 }
 
@@ -617,57 +606,21 @@ static void free_ioctx_users(struct percpu_ref *ref)
 
 static int ioctx_add_table(struct kioctx *ctx, struct mm_struct *mm)
 {
-	unsigned i, new_nr;
-	struct kioctx_table *table, *old;
 	struct aio_ring *ring;
+	int err;
 
-	spin_lock(&mm->ioctx_lock);
-	table = rcu_dereference_raw(mm->ioctx_table);
-
-	while (1) {
-		if (table)
-			for (i = 0; i < table->nr; i++)
-				if (!rcu_access_pointer(table->table[i])) {
-					ctx->id = i;
-					rcu_assign_pointer(table->table[i], ctx);
-					spin_unlock(&mm->ioctx_lock);
-
-					/* While kioctx setup is in progress,
-					 * we are protected from page migration
-					 * changes ring_pages by ->ring_lock.
-					 */
-					ring = kmap_atomic(ctx->ring_pages[0]);
-					ring->id = ctx->id;
-					kunmap_atomic(ring);
-					return 0;
-				}
-
-		new_nr = (table ? table->nr : 1) * 4;
-		spin_unlock(&mm->ioctx_lock);
-
-		table = kzalloc(sizeof(*table) + sizeof(struct kioctx *) *
-				new_nr, GFP_KERNEL);
-		if (!table)
-			return -ENOMEM;
-
-		table->nr = new_nr;
-
-		spin_lock(&mm->ioctx_lock);
-		old = rcu_dereference_raw(mm->ioctx_table);
-
-		if (!old) {
-			rcu_assign_pointer(mm->ioctx_table, table);
-		} else if (table->nr > old->nr) {
-			memcpy(table->table, old->table,
-			       old->nr * sizeof(struct kioctx *));
+	err = xa_alloc(&mm->ioctx, &ctx->id, UINT_MAX, ctx, GFP_KERNEL);
+	if (err)
+		return err;
 
-			rcu_assign_pointer(mm->ioctx_table, table);
-			kfree_rcu(old, rcu);
-		} else {
-			kfree(table);
-			table = old;
-		}
-	}
+	/*
+	 * While kioctx setup is in progress, we are protected from
+	 * page migration changing ring_pages by ->ring_lock.
+	 */
+	ring = kmap_atomic(ctx->ring_pages[0]);
+	ring->id = ctx->id;
+	kunmap_atomic(ring);
+	return 0;
 }
 
 static void aio_nr_sub(unsigned nr)
@@ -793,27 +746,8 @@ static struct kioctx *ioctx_alloc(unsigned nr_events)
 	return ERR_PTR(err);
 }
 
-/* kill_ioctx
- *	Cancels all outstanding aio requests on an aio context.  Used
- *	when the processes owning a context have all exited to encourage
- *	the rapid destruction of the kioctx.
- */
-static int kill_ioctx(struct mm_struct *mm, struct kioctx *ctx,
-		      struct ctx_rq_wait *wait)
+static void __kill_ioctx(struct kioctx *ctx, struct ctx_rq_wait *wait)
 {
-	struct kioctx_table *table;
-
-	spin_lock(&mm->ioctx_lock);
-	if (atomic_xchg(&ctx->dead, 1)) {
-		spin_unlock(&mm->ioctx_lock);
-		return -EINVAL;
-	}
-
-	table = rcu_dereference_raw(mm->ioctx_table);
-	WARN_ON(ctx != rcu_access_pointer(table->table[ctx->id]));
-	RCU_INIT_POINTER(table->table[ctx->id], NULL);
-	spin_unlock(&mm->ioctx_lock);
-
 	/* free_ioctx_reqs() will do the necessary RCU synchronization */
 	wake_up_all(&ctx->wait);
 
@@ -831,6 +765,30 @@ static int kill_ioctx(struct mm_struct *mm, struct kioctx *ctx,
 
 	ctx->rq_wait = wait;
 	percpu_ref_kill(&ctx->users);
+}
+
+/* kill_ioctx
+ *	Cancels all outstanding aio requests on an aio context.  Used
+ *	when the processes owning a context have all exited to encourage
+ *	the rapid destruction of the kioctx.
+ */
+static int kill_ioctx(struct mm_struct *mm, struct kioctx *ctx,
+		      struct ctx_rq_wait *wait)
+{
+	struct kioctx *old;
+
+	/* I don't understand what this lock is protecting against */
+	xa_lock(&mm->ioctx);
+	if (atomic_xchg(&ctx->dead, 1)) {
+		xa_unlock(&mm->ioctx);
+		return -EINVAL;
+	}
+
+	old = __xa_erase(&mm->ioctx, ctx->id);
+	WARN_ON(old != ctx);
+	xa_unlock(&mm->ioctx);
+
+	__kill_ioctx(ctx, wait);
 	return 0;
 }
 
@@ -844,26 +802,21 @@ static int kill_ioctx(struct mm_struct *mm, struct kioctx *ctx,
  */
 void exit_aio(struct mm_struct *mm)
 {
-	struct kioctx_table *table = rcu_dereference_raw(mm->ioctx_table);
+	struct kioctx *ctx;
 	struct ctx_rq_wait wait;
-	int i, skipped;
+	unsigned long index;
 
-	if (!table)
+	if (xa_empty(&mm->ioctx))
 		return;
 
-	atomic_set(&wait.count, table->nr);
+	/*
+	 * Prevent count from getting to 0 until we're ready for it
+	 */
+	atomic_set(&wait.count, 1);
 	init_completion(&wait.comp);
 
-	skipped = 0;
-	for (i = 0; i < table->nr; ++i) {
-		struct kioctx *ctx =
-			rcu_dereference_protected(table->table[i], true);
-
-		if (!ctx) {
-			skipped++;
-			continue;
-		}
-
+	xa_lock(&mm->ioctx);
+	xa_for_each(&mm->ioctx, ctx, index, ULONG_MAX, XA_PRESENT) {
 		/*
 		 * We don't need to bother with munmap() here - exit_mmap(mm)
 		 * is coming and it'll unmap everything. And we simply can't,
@@ -872,16 +825,16 @@ void exit_aio(struct mm_struct *mm)
 		 * that it needs to unmap the area, just set it to 0.
 		 */
 		ctx->mmap_size = 0;
-		kill_ioctx(mm, ctx, &wait);
+		atomic_inc(&wait.count);
+		__xa_erase(&mm->ioctx, ctx->id);
+		__kill_ioctx(ctx, &wait);
 	}
+	xa_unlock(&mm->ioctx);
 
-	if (!atomic_sub_and_test(skipped, &wait.count)) {
+	if (!atomic_sub_and_test(1, &wait.count)) {
 		/* Wait until all IO for the context are done. */
 		wait_for_completion(&wait.comp);
 	}
-
-	RCU_INIT_POINTER(mm->ioctx_table, NULL);
-	kfree(table);
 }
 
 static void put_reqs_available(struct kioctx *ctx, unsigned nr)
@@ -1026,24 +979,17 @@ static struct kioctx *lookup_ioctx(unsigned long ctx_id)
 	struct aio_ring __user *ring  = (void __user *)ctx_id;
 	struct mm_struct *mm = current->mm;
 	struct kioctx *ctx, *ret = NULL;
-	struct kioctx_table *table;
 	unsigned id;
 
 	if (get_user(id, &ring->id))
 		return NULL;
 
 	rcu_read_lock();
-	table = rcu_dereference(mm->ioctx_table);
-
-	if (!table || id >= table->nr)
-		goto out;
-
-	ctx = rcu_dereference(table->table[id]);
+	ctx = xa_load(&mm->ioctx, id);
 	if (ctx && ctx->user_id == ctx_id) {
 		if (percpu_ref_tryget_live(&ctx->users))
 			ret = ctx;
 	}
-out:
 	rcu_read_unlock();
 	return ret;
 }
diff --git a/include/linux/mm_types.h b/include/linux/mm_types.h
index 5ed8f6292a53..1a95bb27f5a7 100644
--- a/include/linux/mm_types.h
+++ b/include/linux/mm_types.h
@@ -14,6 +14,7 @@
 #include <linux/uprobes.h>
 #include <linux/page-flags-layout.h>
 #include <linux/workqueue.h>
+#include <linux/xarray.h>
 
 #include <asm/mmu.h>
 
@@ -336,7 +337,6 @@ struct core_state {
 	struct completion startup;
 };
 
-struct kioctx_table;
 struct mm_struct {
 	struct {
 		struct vm_area_struct *mmap;		/* list of VMAs */
@@ -431,8 +431,7 @@ struct mm_struct {
 		atomic_t membarrier_state;
 #endif
 #ifdef CONFIG_AIO
-		spinlock_t			ioctx_lock;
-		struct kioctx_table __rcu	*ioctx_table;
+		struct xarray ioctx;
 #endif
 #ifdef CONFIG_MEMCG
 		/*
diff --git a/kernel/fork.c b/kernel/fork.c
index 07cddff89c7b..acb775f9592d 100644
--- a/kernel/fork.c
+++ b/kernel/fork.c
@@ -946,8 +946,7 @@ __setup("coredump_filter=", coredump_filter_setup);
 static void mm_init_aio(struct mm_struct *mm)
 {
 #ifdef CONFIG_AIO
-	spin_lock_init(&mm->ioctx_lock);
-	mm->ioctx_table = NULL;
+	xa_init_flags(&mm->ioctx, XA_FLAGS_ALLOC);
 #endif
 }
 
diff --git a/mm/debug.c b/mm/debug.c
index cdacba12e09a..d45ec63aed8c 100644
--- a/mm/debug.c
+++ b/mm/debug.c
@@ -127,9 +127,6 @@ void dump_mm(const struct mm_struct *mm)
 		"start_brk %lx brk %lx start_stack %lx\n"
 		"arg_start %lx arg_end %lx env_start %lx env_end %lx\n"
 		"binfmt %px flags %lx core_state %px\n"
-#ifdef CONFIG_AIO
-		"ioctx_table %px\n"
-#endif
 #ifdef CONFIG_MEMCG
 		"owner %px "
 #endif
@@ -158,9 +155,6 @@ void dump_mm(const struct mm_struct *mm)
 		mm->start_brk, mm->brk, mm->start_stack,
 		mm->arg_start, mm->arg_end, mm->env_start, mm->env_end,
 		mm->binfmt, mm->flags, mm->core_state,
-#ifdef CONFIG_AIO
-		mm->ioctx_table,
-#endif
 #ifdef CONFIG_MEMCG
 		mm->owner,
 #endif
-- 
2.19.1

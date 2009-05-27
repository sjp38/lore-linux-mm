Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id 99D256B00AD
	for <linux-mm@kvack.org>; Wed, 27 May 2009 13:43:13 -0400 (EDT)
From: Oren Laadan <orenl@cs.columbia.edu>
Subject: [RFC v16][PATCH 24/43] c/r: detect resource leaks for whole-container checkpoint
Date: Wed, 27 May 2009 13:32:50 -0400
Message-Id: <1243445589-32388-25-git-send-email-orenl@cs.columbia.edu>
In-Reply-To: <1243445589-32388-1-git-send-email-orenl@cs.columbia.edu>
References: <1243445589-32388-1-git-send-email-orenl@cs.columbia.edu>
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Linus Torvalds <torvalds@osdl.org>, containers@lists.linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-api@vger.kernel.org, Serge Hallyn <serue@us.ibm.com>, Dave Hansen <dave@linux.vnet.ibm.com>, Ingo Molnar <mingo@elte.hu>, "H. Peter Anvin" <hpa@zytor.com>, Alexander Viro <viro@zeniv.linux.org.uk>, Pavel Emelyanov <xemul@openvz.org>, Alexey Dobriyan <adobriyan@gmail.com>, Oren Laadan <orenl@cs.columbia.edu>
List-ID: <linux-mm.kvack.org>

Add a 'users' count to objhash items, and, for a !CHECKPOINT_SUBTREE
checkpoint, return an error code if the actual objects' counts are
higher, indicating leaks (references to the objects from a task not
being checkpointed).  Of course, by this time most of the checkpoint
image has been written out to disk, so this is purely advisory.  But
then, it's probably naive to argue that anything more than an advisory
'this went wrong' error code is useful.

The comparison of the objhash user counts to object refcounts as a
basis for checking for leaks comes from Alexey's OpenVZ-based c/r
patchset.

Signed-off-by: Oren Laadan <orenl@cs.columbia.edu>
---
 checkpoint/checkpoint.c    |    8 ++++
 checkpoint/objhash.c       |   82 ++++++++++++++++++++++++++++++++++++++++++--
 include/linux/checkpoint.h |    1 +
 3 files changed, 88 insertions(+), 3 deletions(-)

diff --git a/checkpoint/checkpoint.c b/checkpoint/checkpoint.c
index 92f219e..b70adf4 100644
--- a/checkpoint/checkpoint.c
+++ b/checkpoint/checkpoint.c
@@ -578,6 +578,14 @@ int do_checkpoint(struct ckpt_ctx *ctx, pid_t pid)
 	if (ret < 0)
 		goto out;
 
+	if (!(ctx->uflags & CHECKPOINT_SUBTREE)) {
+		/* verify that all objects are contained (no leaks) */
+		if (!ckpt_obj_contained(ctx)) {
+			ret = -EBUSY;
+			goto out;
+		}
+	}
+
 	/* on success, return (unique) checkpoint identifier */
 	ctx->crid = atomic_inc_return(&ctx_count);
 	ret = ctx->crid;
diff --git a/checkpoint/objhash.c b/checkpoint/objhash.c
index ff9388d..e481911 100644
--- a/checkpoint/objhash.c
+++ b/checkpoint/objhash.c
@@ -27,19 +27,23 @@ struct ckpt_obj_ops {
 	enum obj_type obj_type;
 	void (*ref_drop)(void *ptr);
 	int (*ref_grab)(void *ptr);
+	int (*ref_users)(void *ptr);
 	int (*checkpoint)(struct ckpt_ctx *ctx, void *ptr);
 	void *(*restore)(struct ckpt_ctx *ctx);
 };
 
 struct ckpt_obj {
+	int users;
 	int objref;
 	void *ptr;
 	struct ckpt_obj_ops *ops;
 	struct hlist_node hash;
+	struct hlist_node next;
 };
 
 struct ckpt_obj_hash {
 	struct hlist_head *head;
+	struct hlist_head list;
 	int next_free_objref;
 };
 
@@ -53,7 +57,7 @@ void *restore_bad(struct ckpt_ctx *ctx)
 	return ERR_PTR(-EINVAL);
 }
 
-/* helper grab/drop functions: */
+/* helper grab/drop/users functions */
 
 static void obj_no_drop(void *ptr)
 {
@@ -86,6 +90,11 @@ static void obj_file_table_drop(void *ptr)
 	put_files_struct((struct files_struct *) ptr);
 }
 
+static int obj_file_table_users(void *ptr)
+{
+	return atomic_read(&((struct files_struct *) ptr)->count);
+}
+
 static int obj_file_grab(void *ptr)
 {
 	get_file((struct file *) ptr);
@@ -97,6 +106,11 @@ static void obj_file_drop(void *ptr)
 	fput((struct file *) ptr);
 }
 
+static int obj_file_users(void *ptr)
+{
+	return atomic_long_read(&((struct file *) ptr)->f_count);
+}
+
 static int obj_mm_grab(void *ptr)
 {
 	atomic_inc(&((struct mm_struct *) ptr)->mm_users);
@@ -108,6 +122,11 @@ static void obj_mm_drop(void *ptr)
 	mmput((struct mm_struct *) ptr);
 }
 
+static int obj_mm_users(void *ptr)
+{
+	return atomic_read(&((struct mm_struct *) ptr)->mm_users);
+}
+
 static struct ckpt_obj_ops ckpt_obj_ops[] = {
 	/* ignored object */
 	{
@@ -131,6 +150,7 @@ static struct ckpt_obj_ops ckpt_obj_ops[] = {
 		.obj_type = CKPT_OBJ_FILE_TABLE,
 		.ref_drop = obj_file_table_drop,
 		.ref_grab = obj_file_table_grab,
+		.ref_users = obj_file_table_users,
 		.checkpoint = checkpoint_file_table,
 		.restore = restore_file_table,
 	},
@@ -140,6 +160,7 @@ static struct ckpt_obj_ops ckpt_obj_ops[] = {
 		.obj_type = CKPT_OBJ_FILE,
 		.ref_drop = obj_file_drop,
 		.ref_grab = obj_file_grab,
+		.ref_users = obj_file_users,
 		.checkpoint = checkpoint_file,
 		.restore = restore_file,
 	},
@@ -149,6 +170,7 @@ static struct ckpt_obj_ops ckpt_obj_ops[] = {
 		.obj_type = CKPT_OBJ_MM,
 		.ref_drop = obj_mm_drop,
 		.ref_grab = obj_mm_grab,
+		.ref_users = obj_mm_users,
 		.checkpoint = checkpoint_mm,
 		.restore = restore_mm,
 	},
@@ -201,6 +223,7 @@ int ckpt_obj_hash_alloc(struct ckpt_ctx *ctx)
 
 	obj_hash->head = head;
 	obj_hash->next_free_objref = 1;
+	INIT_HLIST_HEAD(&obj_hash->list);
 
 	ctx->obj_hash = obj_hash;
 	return 0;
@@ -259,6 +282,7 @@ static int obj_new(struct ckpt_ctx *ctx, void *ptr, int objref,
 
 	obj->ptr = ptr;
 	obj->ops = ops;
+	obj->users = 2;  /* extra reference that objhash itself takes */
 
 	if (objref) {
 		/* use @obj->objref to index (restart) */
@@ -271,10 +295,12 @@ static int obj_new(struct ckpt_ctx *ctx, void *ptr, int objref,
 	}
 
 	ret = ops->ref_grab(obj->ptr);
-	if (ret < 0)
+	if (ret < 0) {
 		kfree(obj);
-	else
+	} else {
 		hlist_add_head(&obj->hash, &ctx->obj_hash->head[i]);
+		hlist_add_head(&obj->next, &ctx->obj_hash->list);
+	}
 
 	return (ret < 0 ? ret : obj->objref);
 }
@@ -335,6 +361,7 @@ int ckpt_obj_lookup_add(struct ckpt_ctx *ctx, void *ptr,
 		return -EINVAL;
 	} else {
 		objref = obj->objref;
+		obj->users++;
 		*first = 0;
 	}
 
@@ -342,6 +369,54 @@ int ckpt_obj_lookup_add(struct ckpt_ctx *ctx, void *ptr,
 	return objref;
 }
 
+/* increment the 'users' count of an object */
+static void ckpt_obj_users_inc(struct ckpt_ctx *ctx, void *ptr, int increment)
+{
+	struct ckpt_obj *obj;
+
+	obj = obj_find_by_ptr(ctx, ptr);
+	if (obj)
+		obj->users += increment;
+}
+
+/**
+ * ckpt_obj_contained - test if shared objects are "contained" in checkpoint
+ * @ctx: checkpoint
+ *
+ * Loops through all objects in the table and compares the number of
+ * references accumulated during checkpoint, with the reference count
+ * reported by the kernel.
+ *
+ * Return 1 if respective counts match for all objects, 0 otherwise.
+ */
+int ckpt_obj_contained(struct ckpt_ctx *ctx)
+{
+	struct ckpt_obj *obj;
+	struct hlist_node *node;
+
+	/* account for ctx->file reference (if in the table already) */
+	ckpt_obj_users_inc(ctx, ctx->file, 1);
+
+	hlist_for_each_entry(obj, node, &ctx->obj_hash->list, next) {
+		if (!obj->ops->ref_users)
+			continue;
+		if (obj->ops->ref_users(obj->ptr) != obj->users) {
+			ckpt_debug("usage leak: %s\n", obj->ops->obj_name);
+			ckpt_write_err(ctx, "%s leak: users %d != c/r %d\n",
+				       obj->ops->obj_name,
+				       obj->ops->ref_users(obj->ptr),
+				       obj->users);
+			printk(KERN_NOTICE "c/r: %s users %d != count %d\n",
+			       obj->ops->obj_name,
+			       obj->ops->ref_users(obj->ptr),
+			       obj->users);
+			return 0;
+		}
+	}
+
+	return 1;
+}
+
 /**
  * checkpoint_obj - if not already in hash, add object and checkpoint
  * @ctx: checkpoint context
@@ -371,6 +446,7 @@ int checkpoint_obj(struct ckpt_ctx *ctx, void *ptr, enum obj_type type)
 	obj = obj_find_by_ptr(ctx, ptr);
 	if (obj) {
 		BUG_ON(obj->ops->obj_type != type);
+		obj->users++;
 		return obj->objref;
 	}
 
diff --git a/include/linux/checkpoint.h b/include/linux/checkpoint.h
index e9efa34..171e92e 100644
--- a/include/linux/checkpoint.h
+++ b/include/linux/checkpoint.h
@@ -44,6 +44,7 @@ extern int ckpt_obj_hash_alloc(struct ckpt_ctx *ctx);
 
 extern int restore_obj(struct ckpt_ctx *ctx, struct ckpt_hdr_objref *h);
 extern int checkpoint_obj(struct ckpt_ctx *ctx, void *ptr, enum obj_type type);
+extern int ckpt_obj_contained(struct ckpt_ctx *ctx);
 extern void *ckpt_obj_fetch(struct ckpt_ctx *ctx, int objref,
 			    enum obj_type type);
 extern int ckpt_obj_lookup_add(struct ckpt_ctx *ctx, void *ptr,
-- 
1.6.0.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

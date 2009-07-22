Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id E87706B00A5
	for <linux-mm@kvack.org>; Wed, 22 Jul 2009 06:10:17 -0400 (EDT)
From: Oren Laadan <orenl@librato.com>
Subject: [RFC v17][PATCH 31/60] c/r: detect resource leaks for whole-container checkpoint
Date: Wed, 22 Jul 2009 05:59:53 -0400
Message-Id: <1248256822-23416-32-git-send-email-orenl@librato.com>
In-Reply-To: <1248256822-23416-1-git-send-email-orenl@librato.com>
References: <1248256822-23416-1-git-send-email-orenl@librato.com>
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Linus Torvalds <torvalds@osdl.org>, containers@lists.linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-api@vger.kernel.org, Serge Hallyn <serue@us.ibm.com>, Dave Hansen <dave@linux.vnet.ibm.com>, Ingo Molnar <mingo@elte.hu>, "H. Peter Anvin" <hpa@zytor.com>, Alexander Viro <viro@zeniv.linux.org.uk>, Pavel Emelyanov <xemul@openvz.org>, Alexey Dobriyan <adobriyan@gmail.com>, Oren Laadan <orenl@librato.com>, Oren Laadan <orenl@cs.columbia.edu>
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

"Leak detection" occurs _before_ any real state is saved, as a
pre-step. This prevents races due to sharing with outside world where
the sharing ceases before the leak test takes place, thus protecting
the checkpoint image from inconsistencies.

Once leak testing concludes, checkpoint will proceed. Because objects
are already in the objhash, checkpoint_obj() cannot distinguish
between the first and subsequent encounters. This is solved with a
flag (CKPT_OBJ_CHECKPOINTED) per object.

Two additional checks take place during checkpoint: for objects that
were created during, and objects destroyed, while the leak-detection
pre-step took place.

Changelog[v17]:
  - Leak detection is performed in two-steps
  - Detect reverse-leaks (objects disappearing unexpectedly)
  - Skip reverse-leak detection if ops->ref_users isn't defined

Signed-off-by: Oren Laadan <orenl@cs.columbia.edu>
---
 checkpoint/checkpoint.c    |   36 ++++++++++
 checkpoint/objhash.c       |  153 +++++++++++++++++++++++++++++++++++++++++++-
 checkpoint/process.c       |    5 ++
 include/linux/checkpoint.h |    5 ++
 4 files changed, 196 insertions(+), 3 deletions(-)

diff --git a/checkpoint/checkpoint.c b/checkpoint/checkpoint.c
index fb14585..e126626 100644
--- a/checkpoint/checkpoint.c
+++ b/checkpoint/checkpoint.c
@@ -380,6 +380,20 @@ static int checkpoint_pids(struct ckpt_ctx *ctx)
 	return ret;
 }
 
+static int collect_objects(struct ckpt_ctx *ctx)
+{
+	int n, ret = 0;
+
+	for (n = 0; n < ctx->nr_tasks; n++) {
+		ckpt_debug("dumping task #%d\n", n);
+		ret = ckpt_collect_task(ctx, ctx->tasks_arr[n]);
+		if (ret < 0)
+			break;
+	}
+
+	return ret;
+}
+
 /* count number of tasks in tree (and optionally fill pid's in array) */
 static int tree_count_tasks(struct ckpt_ctx *ctx)
 {
@@ -619,6 +633,21 @@ long do_checkpoint(struct ckpt_ctx *ctx, pid_t pid)
 	if (ret < 0)
 		goto out;
 
+	if (!(ctx->uflags & CHECKPOINT_SUBTREE)) {
+		/*
+		 * Verify that all objects are contained (no leaks):
+		 * First collect them all into the while counting users
+		 * and then compare to the objects' real user counts.
+		 */
+		ret = collect_objects(ctx);
+		if (ret < 0)
+			goto out;
+		if (!ckpt_obj_contained(ctx)) {
+			ret = -EAGAIN;
+			goto out;
+		}
+	}
+
 	ret = checkpoint_write_header(ctx);
 	if (ret < 0)
 		goto out;
@@ -628,6 +657,13 @@ long do_checkpoint(struct ckpt_ctx *ctx, pid_t pid)
 	ret = checkpoint_all_tasks(ctx);
 	if (ret < 0)
 		goto out;
+
+	/* verify that all objects were indeed checkpointed */
+	if (!ckpt_obj_checkpointed(ctx)) {
+		ret = -EAGAIN;
+		goto out;
+	}
+
 	ret = checkpoint_write_tail(ctx);
 	if (ret < 0)
 		goto out;
diff --git a/checkpoint/objhash.c b/checkpoint/objhash.c
index eb2bb55..3f23910 100644
--- a/checkpoint/objhash.c
+++ b/checkpoint/objhash.c
@@ -25,16 +25,19 @@ struct ckpt_obj_ops {
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
 	int flags;
 	void *ptr;
 	struct ckpt_obj_ops *ops;
 	struct hlist_node hash;
+	struct hlist_node next;
 };
 
 /* object internal flags */
@@ -42,10 +45,21 @@ struct ckpt_obj {
 
 struct ckpt_obj_hash {
 	struct hlist_head *head;
+	struct hlist_head list;
 	int next_free_objref;
 };
 
-/* helper grab/drop functions: */
+int checkpoint_bad(struct ckpt_ctx *ctx, void *ptr)
+{
+	BUG();
+}
+
+void *restore_bad(struct ckpt_ctx *ctx)
+{
+	return ERR_PTR(-EINVAL);
+}
+
+/* helper grab/drop/users functions */
 
 static void obj_no_drop(void *ptr)
 {
@@ -114,6 +128,7 @@ int ckpt_obj_hash_alloc(struct ckpt_ctx *ctx)
 
 	obj_hash->head = head;
 	obj_hash->next_free_objref = 1;
+	INIT_HLIST_HEAD(&obj_hash->list);
 
 	ctx->obj_hash = obj_hash;
 	return 0;
@@ -176,6 +191,7 @@ static struct ckpt_obj *obj_new(struct ckpt_ctx *ctx, void *ptr,
 
 	obj->ptr = ptr;
 	obj->ops = ops;
+	obj->users = 2;  /* extra reference that objhash itself takes */
 
 	if (!objref) {
 		/* use @obj->ptr to index, assign objref (checkpoint) */
@@ -193,6 +209,7 @@ static struct ckpt_obj *obj_new(struct ckpt_ctx *ctx, void *ptr,
 		obj = ERR_PTR(ret);
 	} else {
 		hlist_add_head(&obj->hash, &ctx->obj_hash->head[i]);
+		hlist_add_head(&obj->next, &ctx->obj_hash->list);
 	}
 
 	return obj;
@@ -225,12 +242,36 @@ static struct ckpt_obj *obj_lookup_add(struct ckpt_ctx *ctx, void *ptr,
 		*first = 1;
 	} else {
 		BUG_ON(obj->ops->obj_type != type);
+		obj->users++;
 		*first = 0;
 	}
 	return obj;
 }
 
 /**
+ * ckpt_obj_collect - collect object into objhash
+ * @ctx: checkpoint context
+ * @ptr: pointer to object
+ * @type: object type
+ * @first: [output] first encoutner (added to table)
+ *
+ * [used during checkpoint].
+ * Return: objref
+ */
+int ckpt_obj_collect(struct ckpt_ctx *ctx, void *ptr, enum obj_type type)
+{
+	struct ckpt_obj *obj;
+	int first;
+
+	obj = obj_lookup_add(ctx, ptr, type, &first);
+	if (IS_ERR(obj))
+		return PTR_ERR(obj);
+	ckpt_debug("%s objref %d first %d\n",
+		   obj->ops->obj_name, obj->objref, first);
+	return obj->objref;
+}
+
+/**
  * ckpt_obj_lookup - lookup object (by pointer) in objhash
  * @ctx: checkpoint context
  * @ptr: pointer to object
@@ -291,12 +332,20 @@ int checkpoint_obj(struct ckpt_ctx *ctx, void *ptr, enum obj_type type)
 {
 	struct ckpt_hdr_objref *h;
 	struct ckpt_obj *obj;
-	int first, ret = 0;
+	int new, ret = 0;
 
-	obj = obj_lookup_add(ctx, ptr, type, &first);
+	obj = obj_lookup_add(ctx, ptr, type, &new);
 	if (IS_ERR(obj))
 		return PTR_ERR(obj);
 
+	/*
+	 * A "reverse" leak ?  All objects should already be in the
+	 * objhash by now. But an outside task may have created an
+	 * object while we were collecting, which we didn't catch.
+	 */
+	if (new && obj->ops->ref_users && !(ctx->uflags & CHECKPOINT_SUBTREE))
+		return -EAGAIN;
+
 	if (!(obj->flags & CKPT_OBJ_CHECKPOINTED)) {
 		h = ckpt_hdr_get_type(ctx, sizeof(*h), CKPT_HDR_OBJREF);
 		if (!h)
@@ -316,9 +365,107 @@ int checkpoint_obj(struct ckpt_ctx *ctx, void *ptr, enum obj_type type)
 
 		obj->flags |= CKPT_OBJ_CHECKPOINTED;
 	}
+
 	return (ret < 0 ? ret : obj->objref);
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
+/*
+ * "Leak detection" - to guarantee a consistent checkpoint of a full
+ * container we verify that all resources are confined and isolated in
+ * that container:
+ *
+ * c/r code first walks through all tasks and collects all shared
+ * resources into the objhash, while counting the references to them;
+ * then, it compares this count to the object's real reference count,
+ * and if they don't match it means that an object has "leaked" to the
+ * outside.
+ *
+ * Otherwise, it is guaranteed that there are no references outside
+ * (of container). c/r code now proceeds to walk through all tasks,
+ * again, and checkpoints the resources. It ensures that all resources
+ * are already in the objhash, and that all of them are checkpointed.
+ * Otherwise it means that due to a race, an object was created or
+ * destroyed during the first walk but not accounted for.
+ *
+ * For instance, consider an outside task A that shared files_struct
+ * with inside task B. Then, after B's files where collected, A opens
+ * or closes a file, and immediately exits - before the first leak
+ * test is performed, such that the test passes.
+ */
+
+/**
+ * ckpt_obj_contained - test if shared objects are "contained" in checkpoint
+ * @ctx: checkpoint context
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
+/**
+ * ckpt_obj_checkpointed - test that all shared objects were checkpointed
+ * @ctx: checkpoint context
+ *
+ * Return 1 if all objects where checkpointed, 0 otherwise.
+ */
+int ckpt_obj_checkpointed(struct ckpt_ctx *ctx)
+{
+	struct ckpt_obj *obj;
+	struct hlist_node *node;
+
+	hlist_for_each_entry(obj, node, &ctx->obj_hash->list, next) {
+		if (!(obj->flags & CKPT_OBJ_CHECKPOINTED)) {
+			ckpt_debug("reverse leak: %s\n", obj->ops->obj_name);
+			ckpt_write_err(ctx, "%s leak: not checkpointed\n",
+				       obj->ops->obj_name);
+			printk(KERN_NOTICE "c/r: %s object not checkpointed\n",
+			       obj->ops->obj_name);
+			return 0;
+		}
+	}
+
+	return 1;
+}
+
 /**************************************************************************
  * Restart
  */
diff --git a/checkpoint/process.c b/checkpoint/process.c
index 9e459c6..4da4e4a 100644
--- a/checkpoint/process.c
+++ b/checkpoint/process.c
@@ -241,6 +241,11 @@ int checkpoint_task(struct ckpt_ctx *ctx, struct task_struct *t)
 	return ret;
 }
 
+int ckpt_collect_task(struct ckpt_ctx *ctx, struct task_struct *t)
+{
+	return 0;
+}
+
 /***********************************************************************
  * Restart
  */
diff --git a/include/linux/checkpoint.h b/include/linux/checkpoint.h
index 8eb5434..efd05cc 100644
--- a/include/linux/checkpoint.h
+++ b/include/linux/checkpoint.h
@@ -86,6 +86,10 @@ extern int ckpt_obj_hash_alloc(struct ckpt_ctx *ctx);
 extern int restore_obj(struct ckpt_ctx *ctx, struct ckpt_hdr_objref *h);
 extern int checkpoint_obj(struct ckpt_ctx *ctx, void *ptr,
 			  enum obj_type type);
+extern int ckpt_obj_collect(struct ckpt_ctx *ctx, void *ptr,
+			    enum obj_type type);
+extern int ckpt_obj_contained(struct ckpt_ctx *ctx);
+extern int ckpt_obj_checkpointed(struct ckpt_ctx *ctx);
 extern int ckpt_obj_lookup(struct ckpt_ctx *ctx, void *ptr,
 			   enum obj_type type);
 extern int ckpt_obj_lookup_add(struct ckpt_ctx *ctx, void *ptr,
@@ -103,6 +107,7 @@ extern long do_restart(struct ckpt_ctx *ctx, pid_t pid);
 
 /* task */
 extern int ckpt_activate_next(struct ckpt_ctx *ctx);
+extern int ckpt_collect_task(struct ckpt_ctx *ctx, struct task_struct *t);
 extern int checkpoint_task(struct ckpt_ctx *ctx, struct task_struct *t);
 extern int restore_task(struct ckpt_ctx *ctx);
 
-- 
1.6.0.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

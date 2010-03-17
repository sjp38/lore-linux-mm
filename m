Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id EDE506B0225
	for <linux-mm@kvack.org>; Wed, 17 Mar 2010 12:14:55 -0400 (EDT)
From: Oren Laadan <orenl@cs.columbia.edu>
Subject: [C/R v20][PATCH 35/96] c/r: detect resource leaks for whole-container checkpoint
Date: Wed, 17 Mar 2010 12:08:23 -0400
Message-Id: <1268842164-5590-36-git-send-email-orenl@cs.columbia.edu>
In-Reply-To: <1268842164-5590-35-git-send-email-orenl@cs.columbia.edu>
References: <1268842164-5590-1-git-send-email-orenl@cs.columbia.edu>
 <1268842164-5590-2-git-send-email-orenl@cs.columbia.edu>
 <1268842164-5590-3-git-send-email-orenl@cs.columbia.edu>
 <1268842164-5590-4-git-send-email-orenl@cs.columbia.edu>
 <1268842164-5590-5-git-send-email-orenl@cs.columbia.edu>
 <1268842164-5590-6-git-send-email-orenl@cs.columbia.edu>
 <1268842164-5590-7-git-send-email-orenl@cs.columbia.edu>
 <1268842164-5590-8-git-send-email-orenl@cs.columbia.edu>
 <1268842164-5590-9-git-send-email-orenl@cs.columbia.edu>
 <1268842164-5590-10-git-send-email-orenl@cs.columbia.edu>
 <1268842164-5590-11-git-send-email-orenl@cs.columbia.edu>
 <1268842164-5590-12-git-send-email-orenl@cs.columbia.edu>
 <1268842164-5590-13-git-send-email-orenl@cs.columbia.edu>
 <1268842164-5590-14-git-send-email-orenl@cs.columbia.edu>
 <1268842164-5590-15-git-send-email-orenl@cs.columbia.edu>
 <1268842164-5590-16-git-send-email-orenl@cs.columbia.edu>
 <1268842164-5590-17-git-send-email-orenl@cs.columbia.edu>
 <1268842164-5590-18-git-send-email-orenl@cs.columbia.edu>
 <1268842164-5590-19-git-send-email-orenl@cs.columbia.edu>
 <1268842164-5590-20-git-send-email-orenl@cs.columbia.edu>
 <1268842164-5590-21-git-send-email-orenl@cs.columbia.edu>
 <1268842164-5590-22-git-send-email-orenl@cs.columbia.edu>
 <1268842164-5590-23-git-send-email-orenl@cs.columbia.edu>
 <1268842164-5590-24-git-send-email-orenl@cs.columbia.edu>
 <1268842164-5590-25-git-send-email-orenl@cs.columbia.edu>
 <1268842164-5590-26-git-send-email-orenl@cs.columbia.edu>
 <1268842164-5590-27-git-send-email-orenl@cs.columbia.edu>
 <1268842164-5590-28-git-send-email-orenl@cs.columbia.edu>
 <1268842164-5590-29-git-send-email-orenl@cs.columbia.edu>
 <1268842164-5590-30-git-send-email-orenl@cs.columbia.edu>
 <1268842164-5590-31-git-send-email-orenl@cs.columbia.edu>
 <1268842164-5590-32-git-send-email-orenl@cs.columbia.edu>
 <1268842164-5590-33-git-send-email-orenl@cs.columbia.edu>
 <1268842164-5590-34-git-send-email-orenl@cs.columbia.edu>
 <1268842164-5590-35-git-send-email-orenl@cs.columbia.edu>
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-api@vger.kernel.org, Serge Hallyn <serue@us.ibm.com>, Ingo Molnar <mingo@elte.hu>, containers@lists.linux-foundation.org, Oren Laadan <orenl@cs.columbia.edu>
List-ID: <linux-mm.kvack.org>

Add a 'users' count to objhash items, and, for a !CHECKPOINT_SUBTREE
checkpoint, return an error code if the actual objects' counts are
higher, indicating leaks (references to the objects from a task not
being checkpointed).

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
pre-step took place. (By the time this occurs part of the checkpoint
image has been written out to disk, so this is purely advisory).

Changelog[v20]:
  - Export key symbols to enable c/r from kernel modules
Changelog[v18]:
  - [Dan Smith] Fix ckpt_obj_lookup_add() leak detection logic
  - Replace some EAGAIN with EBUSY
  - Add a few more ckpt_write_err()s
  - Introduce CKPT_OBJ_VISITED
  - ckpt_obj_collect() returns objref for new objects, 0 otherwise
  - Rename ckpt_obj_checkpointed() to ckpt_obj_visited()
  - Introduce ckpt_obj_visit() to mark objects as visited
  - Set the CHECKPOINTED flag on objects before calling checkpoint
Changelog[v17]:
  - Leak detection is performed in two-steps
  - Detect reverse-leaks (objects disappearing unexpectedly)
  - Skip reverse-leak detection if ops->ref_users isn't defined

Signed-off-by: Oren Laadan <orenl@cs.columbia.edu>
Acked-by: Serge E. Hallyn <serue@us.ibm.com>
Tested-by: Serge E. Hallyn <serue@us.ibm.com>
---
 checkpoint/checkpoint.c    |   41 ++++++++++
 checkpoint/objhash.c       |  188 +++++++++++++++++++++++++++++++++++++++++++-
 checkpoint/process.c       |    5 +
 include/linux/checkpoint.h |    7 ++
 4 files changed, 237 insertions(+), 4 deletions(-)

diff --git a/checkpoint/checkpoint.c b/checkpoint/checkpoint.c
index ea1494d..c016a2d 100644
--- a/checkpoint/checkpoint.c
+++ b/checkpoint/checkpoint.c
@@ -314,6 +314,24 @@ static int checkpoint_pids(struct ckpt_ctx *ctx)
 	return ret;
 }
 
+static int collect_objects(struct ckpt_ctx *ctx)
+{
+	int n, ret = 0;
+
+	for (n = 0; n < ctx->nr_tasks; n++) {
+		ckpt_debug("dumping task #%d\n", n);
+		ret = ckpt_collect_task(ctx, ctx->tasks_arr[n]);
+		if (ret < 0) {
+			ctx->tsk = ctx->tasks_arr[n];
+			ckpt_err(ctx, ret, "%(T)Collect failed\n");
+			ctx->tsk = NULL;
+			break;
+		}
+	}
+
+	return ret;
+}
+
 struct ckpt_cnt_tasks {
 	struct ckpt_ctx *ctx;
 	int nr;
@@ -536,6 +554,21 @@ long do_checkpoint(struct ckpt_ctx *ctx, pid_t pid)
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
+			ret = -EBUSY;
+			goto out;
+		}
+	}
+
 	ret = checkpoint_write_header(ctx);
 	if (ret < 0)
 		goto out;
@@ -548,6 +581,14 @@ long do_checkpoint(struct ckpt_ctx *ctx, pid_t pid)
 	ret = checkpoint_all_tasks(ctx);
 	if (ret < 0)
 		goto out;
+
+	/* verify that all objects were indeed visited */
+	if (!ckpt_obj_visited(ctx)) {
+		ckpt_err(ctx, -EBUSY, "Leak: unvisited\n");
+		ret = -EBUSY;
+		goto out;
+	}
+
 	ret = checkpoint_write_tail(ctx);
 	if (ret < 0)
 		goto out;
diff --git a/checkpoint/objhash.c b/checkpoint/objhash.c
index ada5113..22b1601 100644
--- a/checkpoint/objhash.c
+++ b/checkpoint/objhash.c
@@ -25,27 +25,32 @@ struct ckpt_obj_ops {
 	enum obj_type obj_type;
 	void (*ref_drop)(void *ptr, int lastref);
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
 #define CKPT_OBJ_CHECKPOINTED		0x1   /* object already checkpointed */
+#define CKPT_OBJ_VISITED		0x2   /* object already visited */
 
 struct ckpt_obj_hash {
 	struct hlist_head *head;
+	struct hlist_head list;
 	int next_free_objref;
 };
 
-/* helper grab/drop functions: */
+/* helper grab/drop/users functions */
 
 static void obj_no_drop(void *ptr, int lastref)
 {
@@ -114,6 +119,7 @@ int ckpt_obj_hash_alloc(struct ckpt_ctx *ctx)
 
 	obj_hash->head = head;
 	obj_hash->next_free_objref = 1;
+	INIT_HLIST_HEAD(&obj_hash->list);
 
 	ctx->obj_hash = obj_hash;
 	return 0;
@@ -181,6 +187,7 @@ static struct ckpt_obj *obj_new(struct ckpt_ctx *ctx, void *ptr,
 
 	obj->ptr = ptr;
 	obj->ops = ops;
+	obj->users = 2;  /* extra reference that objhash itself takes */
 
 	if (!objref) {
 		/* use @obj->ptr to index, assign objref (checkpoint) */
@@ -198,6 +205,7 @@ static struct ckpt_obj *obj_new(struct ckpt_ctx *ctx, void *ptr,
 		obj = ERR_PTR(ret);
 	} else {
 		hlist_add_head(&obj->hash, &ctx->obj_hash->head[i]);
+		hlist_add_head(&obj->next, &ctx->obj_hash->list);
 	}
 
 	return obj;
@@ -230,12 +238,35 @@ static struct ckpt_obj *obj_lookup_add(struct ckpt_ctx *ctx, void *ptr,
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
+ *
+ * [used during checkpoint].
+ * Return: objref if object is new, 0 otherwise, or an error
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
+	return first ? obj->objref : 0;
+}
+
+/**
  * ckpt_obj_lookup - lookup object (by pointer) in objhash
  * @ctx: checkpoint context
  * @ptr: pointer to object
@@ -256,6 +287,21 @@ int ckpt_obj_lookup(struct ckpt_ctx *ctx, void *ptr, enum obj_type type)
 }
 EXPORT_SYMBOL(ckpt_obj_lookup);
 
+static inline int obj_reverse_leak(struct ckpt_ctx *ctx, struct ckpt_obj *obj)
+{
+	/*
+	 * A "reverse" leak ?  All objects should already be in the
+	 * objhash by now. But an outside task may have created an
+	 * object while we were collecting, which we didn't catch.
+	 */
+	if (obj->ops->ref_users && !(ctx->uflags & CHECKPOINT_SUBTREE)) {
+		ckpt_err(ctx, -EBUSY, "%(O)%(P)Leak: reverse added late (%s)\n",
+			       obj->objref, obj->ptr, obj->ops->obj_name);
+		return -EBUSY;
+	}
+	return 0;
+}
+
 /**
  * ckpt_obj_lookup_add - lookup object and add if not in objhash
  * @ctx: checkpoint context
@@ -276,7 +322,11 @@ int ckpt_obj_lookup_add(struct ckpt_ctx *ctx, void *ptr,
 		return PTR_ERR(obj);
 	ckpt_debug("%s objref %d first %d\n",
 		   obj->ops->obj_name, obj->objref, *first);
-	obj->flags |= CKPT_OBJ_CHECKPOINTED;
+
+	if (*first && obj_reverse_leak(ctx, obj))
+		return -EBUSY;
+
+	obj->flags |= CKPT_OBJ_VISITED;
 	return obj->objref;
 }
 EXPORT_SYMBOL(ckpt_obj_lookup_add);
@@ -318,6 +368,9 @@ int checkpoint_obj(struct ckpt_ctx *ctx, void *ptr, enum obj_type type)
 	if (IS_ERR(obj))
 		return PTR_ERR(obj);
 
+	if (new && obj_reverse_leak(ctx, obj))
+		return -EBUSY;
+
 	if (!(obj->flags & CKPT_OBJ_CHECKPOINTED)) {
 		h = ckpt_hdr_get_type(ctx, sizeof(*h), CKPT_HDR_OBJREF);
 		if (!h)
@@ -332,15 +385,142 @@ int checkpoint_obj(struct ckpt_ctx *ctx, void *ptr, enum obj_type type)
 			return ret;
 
 		/* invoke callback to actually dump the state */
-		if (obj->ops->checkpoint)
-			ret = obj->ops->checkpoint(ctx, ptr);
+		BUG_ON(!obj->ops->checkpoint);
 
 		obj->flags |= CKPT_OBJ_CHECKPOINTED;
+		ret = obj->ops->checkpoint(ctx, ptr);
 	}
+
+	obj->flags |= CKPT_OBJ_VISITED;
 	return (ret < 0 ? ret : obj->objref);
 }
 EXPORT_SYMBOL(checkpoint_obj);
 
+/**
+ * ckpt_obj_visit - mark object as visited
+ * @ctx: checkpoint context
+ * @ptr: pointer to object
+ * @type: object type
+ *
+ * [used during checkpoint].
+ * Marks the object as visited, or fail if not found
+ */
+int ckpt_obj_visit(struct ckpt_ctx *ctx, void *ptr, enum obj_type type)
+{
+	struct ckpt_obj *obj;
+
+	obj = obj_find_by_ptr(ctx, ptr);
+	BUG_ON(obj && obj->ops->obj_type != type);
+
+	if (!obj) {
+		if (!(ctx->uflags & CHECKPOINT_SUBTREE)) {
+			/* if not found report reverse leak (full container) */
+			ckpt_err(ctx, -EBUSY,
+				 "%(O)%(P)Leak: reverse unknown (%s)\n",
+				 obj->objref, obj->ptr, obj->ops->obj_name);
+			return -EBUSY;
+		}
+	} else {
+		ckpt_debug("visit %s objref %d\n",
+			   obj->ops->obj_name, obj->objref);
+		obj->flags |= CKPT_OBJ_VISITED;
+	}
+	return 0;
+}
+EXPORT_SYMBOL(ckpt_obj_visit);
+
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
+ * ckpt_obj_contained - test if shared objects are contained in checkpoint
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
+	/* account for ctx->{file,logfile} (if in the table already) */
+	ckpt_obj_users_inc(ctx, ctx->file, 1);
+	if (ctx->logfile)
+		ckpt_obj_users_inc(ctx, ctx->logfile, 1);
+
+	hlist_for_each_entry(obj, node, &ctx->obj_hash->list, next) {
+		if (!obj->ops->ref_users)
+			continue;
+		if (obj->ops->ref_users(obj->ptr) != obj->users) {
+			ckpt_err(ctx, -EBUSY,
+				 "%(O)%(P)%(S)Usage leak (%d != %d)\n",
+				 obj->objref, obj->ptr, obj->ops->obj_name,
+				 obj->ops->ref_users(obj->ptr), obj->users);
+			return 0;
+		}
+	}
+
+	return 1;
+}
+
+/**
+ * ckpt_obj_visited - test that all shared objects were visited
+ * @ctx: checkpoint context
+ *
+ * Return 1 if all objects where visited, 0 otherwise.
+ */
+int ckpt_obj_visited(struct ckpt_ctx *ctx)
+{
+	struct ckpt_obj *obj;
+	struct hlist_node *node;
+
+	hlist_for_each_entry(obj, node, &ctx->obj_hash->list, next) {
+		if (!(obj->flags & CKPT_OBJ_VISITED)) {
+			ckpt_err(ctx, -EBUSY,
+				 "%(O)%(P)%(S)Leak: not visited\n",
+				 obj->objref, obj->ptr, obj->ops->obj_name);
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
index f36e320..ef394a5 100644
--- a/checkpoint/process.c
+++ b/checkpoint/process.c
@@ -245,6 +245,11 @@ int checkpoint_task(struct ckpt_ctx *ctx, struct task_struct *t)
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
index da6fd36..50ce8f9 100644
--- a/include/linux/checkpoint.h
+++ b/include/linux/checkpoint.h
@@ -113,6 +113,12 @@ extern int ckpt_obj_hash_alloc(struct ckpt_ctx *ctx);
 extern int restore_obj(struct ckpt_ctx *ctx, struct ckpt_hdr_objref *h);
 extern int checkpoint_obj(struct ckpt_ctx *ctx, void *ptr,
 			  enum obj_type type);
+extern int ckpt_obj_collect(struct ckpt_ctx *ctx, void *ptr,
+			    enum obj_type type);
+extern int ckpt_obj_contained(struct ckpt_ctx *ctx);
+extern int ckpt_obj_visited(struct ckpt_ctx *ctx);
+extern int ckpt_obj_visit(struct ckpt_ctx *ctx, void *ptr,
+			  enum obj_type type);
 extern int ckpt_obj_lookup(struct ckpt_ctx *ctx, void *ptr,
 			   enum obj_type type);
 extern int ckpt_obj_lookup_add(struct ckpt_ctx *ctx, void *ptr,
@@ -133,6 +139,7 @@ extern long do_restart(struct ckpt_ctx *ctx, pid_t pid);
 
 /* task */
 extern int ckpt_activate_next(struct ckpt_ctx *ctx);
+extern int ckpt_collect_task(struct ckpt_ctx *ctx, struct task_struct *t);
 extern int checkpoint_task(struct ckpt_ctx *ctx, struct task_struct *t);
 extern int restore_task(struct ckpt_ctx *ctx);
 
-- 
1.6.3.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

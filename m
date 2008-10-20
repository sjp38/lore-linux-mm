From: Oren Laadan <orenl@cs.columbia.edu>
Subject: [RFC v7][PATCH 7/9] Infrastructure for shared objects
Date: Mon, 20 Oct 2008 01:40:35 -0400
Message-Id: <1224481237-4892-8-git-send-email-orenl@cs.columbia.edu>
In-Reply-To: <1224481237-4892-1-git-send-email-orenl@cs.columbia.edu>
References: <1224481237-4892-1-git-send-email-orenl@cs.columbia.edu>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Linus Torvalds <torvalds@osdl.org>
Cc: containers@lists.linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-api@vger.kernel.org, Thomas Gleixner <tglx@linutronix.de>, Serge Hallyn <serue@us.ibm.com>, Dave Hansen <dave@linux.vnet.ibm.com>, Ingo Molnar <mingo@elte.hu>, "H. Peter Anvin" <hpa@zytor.com>, Alexander Viro <viro@zeniv.linux.org.uk>, Oren Laadan <orenl@cs.columbia.edu>
List-ID: <linux-mm.kvack.org>

Infrastructure to handle objects that may be shared and referenced by
multiple tasks or other objects, e..g open files, memory address space
etc.

The state of shared objects is saved once. On the first encounter, the
state is dumped and the object is assigned a unique identifier (objref)
and also stored in a hash table (indexed by its physical kenrel address).
>From then on the object will be found in the hash and only its identifier
is saved.

On restart the identifier is looked up in the hash table; if not found
then the state is read, the object is created, and added to the hash
table (this time indexed by its identifier). Otherwise, the object in
the hash table is used.

Signed-off-by: Oren Laadan <orenl@cs.columbia.edu>
Acked-by: Serge Hallyn <serue@us.ibm.com>
Signed-off-by: Dave Hansen <dave@linux.vnet.ibm.com>
---
 Documentation/checkpoint.txt |   46 +++++++
 checkpoint/Makefile          |    2 +-
 checkpoint/objhash.c         |  268 ++++++++++++++++++++++++++++++++++++++++++
 checkpoint/sys.c             |    6 +
 include/linux/checkpoint.h   |   20 +++
 5 files changed, 341 insertions(+), 1 deletions(-)
 create mode 100644 checkpoint/objhash.c

diff --git a/Documentation/checkpoint.txt b/Documentation/checkpoint.txt
index a73a4f3..a9ea79c 100644
--- a/Documentation/checkpoint.txt
+++ b/Documentation/checkpoint.txt
@@ -189,6 +189,52 @@ cr_hdr + cr_hdr_task
 cr_hdr + cr_hdr_tail
 
 
+=== Shared resources (objects)
+
+Many resources used by tasks may be shared by more than one task (e.g.
+file descriptors, memory address space, etc), or even have multiple
+references from other resources (e.g. a single inode that represents
+two ends of a pipe).
+
+Clearly, the state of shared objects need only be saved once, even if
+they occur multiple times. We use a hash table (ctx->objhash) to keep
+track of shared objects and whether they were already saved.  Shared
+objects are stored in a hash table as they appear, indexed by their
+kernel address. (The hash table itself is not saved as part of the
+checkpoint image: it is constructed dynamically during both checkpoint
+and restart, and discarded at the end of the operation).
+
+Each shared object that is found is first looked up in the hash table.
+On the first encounter, the object will not be found, so its state is
+dumped, and the object is assigned a unique identifier and also stored
+in the hash table. Subsequent lookups of that object in the hash table
+will yield that entry, and then only the unique identifier is saved,
+as opposed the entire state of the object.
+
+During restart, shared objects are seen by their unique identifiers as
+assigned during the checkpoint. Each shared object that it read in is
+first looked up in the hash table. On the first encounter it will not
+be found, meaning that the object needs to be created and its state
+read in and restored. Then the object is added to the hash table, this
+time indexed by its unique identifier. Subsequent lookups of the same
+unique identifier in the hash table will yield that entry, and then
+the existing object instance is reused instead of creating another one.
+
+The interface for the hash table is the following:
+
+cr_obj_get_by_ptr() - find the unique object reference (objref)
+  of the object that is pointer to by ptr [checkpoint]
+
+cr_obj_add_ptr() - add the object pointed to by ptr to the hash table
+  if not already there, and fill its unique object reference (objref)
+
+cr_obj_get_by_ref() - return the pointer to the object whose unique
+  object reference is equal to objref [restart]
+
+cr_obj_add_ref() - add the object with given unique object reference
+  (objref), pointed to by ptr to the hash table. [restart]
+
+
 === Current Implementation
 
 [2008-Oct-07]
diff --git a/checkpoint/Makefile b/checkpoint/Makefile
index ac35033..9843fb9 100644
--- a/checkpoint/Makefile
+++ b/checkpoint/Makefile
@@ -2,5 +2,5 @@
 # Makefile for linux checkpoint/restart.
 #
 
-obj-$(CONFIG_CHECKPOINT_RESTART) += sys.o checkpoint.o restart.o \
+obj-$(CONFIG_CHECKPOINT_RESTART) += sys.o checkpoint.o restart.o objhash.o \
 		ckpt_mem.o rstr_mem.o
diff --git a/checkpoint/objhash.c b/checkpoint/objhash.c
new file mode 100644
index 0000000..05b1a1b
--- /dev/null
+++ b/checkpoint/objhash.c
@@ -0,0 +1,268 @@
+/*
+ *  Checkpoint-restart - object hash infrastructure to manage shared objects
+ *
+ *  Copyright (C) 2008 Oren Laadan
+ *
+ *  This file is subject to the terms and conditions of the GNU General Public
+ *  License.  See the file COPYING in the main directory of the Linux
+ *  distribution for more details.
+ */
+
+#include <linux/kernel.h>
+#include <linux/file.h>
+#include <linux/hash.h>
+#include <linux/checkpoint.h>
+
+struct cr_objref {
+	int objref;
+	void *ptr;
+	unsigned short type;
+	unsigned short flags;
+	struct hlist_node hash;
+};
+
+struct cr_objhash {
+	struct hlist_head *head;
+	int next_free_objref;
+};
+
+#define CR_OBJHASH_NBITS  10
+#define CR_OBJHASH_TOTAL  (1UL << CR_OBJHASH_NBITS)
+
+static void cr_obj_ref_drop(struct cr_objref *obj)
+{
+	switch (obj->type) {
+	case CR_OBJ_FILE:
+		fput((struct file *) obj->ptr);
+		break;
+	default:
+		BUG();
+	}
+}
+
+static void cr_obj_ref_grab(struct cr_objref *obj)
+{
+	switch (obj->type) {
+	case CR_OBJ_FILE:
+		get_file((struct file *) obj->ptr);
+		break;
+	default:
+		BUG();
+	}
+}
+
+static void cr_objhash_clear(struct cr_objhash *objhash)
+{
+	struct hlist_head *h = objhash->head;
+	struct hlist_node *n, *t;
+	struct cr_objref *obj;
+	int i;
+
+	for (i = 0; i < CR_OBJHASH_TOTAL; i++) {
+		hlist_for_each_entry_safe(obj, n, t, &h[i], hash) {
+			cr_obj_ref_drop(obj);
+			kfree(obj);
+		}
+	}
+}
+
+void cr_objhash_free(struct cr_ctx *ctx)
+{
+	struct cr_objhash *objhash = ctx->objhash;
+
+	if (objhash) {
+		cr_objhash_clear(objhash);
+		kfree(objhash->head);
+		kfree(ctx->objhash);
+		ctx->objhash = NULL;
+	}
+}
+
+int cr_objhash_alloc(struct cr_ctx *ctx)
+{
+	struct cr_objhash *objhash;
+	struct hlist_head *head;
+
+	objhash = kzalloc(sizeof(*objhash), GFP_KERNEL);
+	if (!objhash)
+		return -ENOMEM;
+	head = kzalloc(CR_OBJHASH_TOTAL * sizeof(*head), GFP_KERNEL);
+	if (!head) {
+		kfree(objhash);
+		return -ENOMEM;
+	}
+
+	objhash->head = head;
+	objhash->next_free_objref = 1;
+
+	ctx->objhash = objhash;
+	return 0;
+}
+
+static struct cr_objref *cr_obj_find_by_ptr(struct cr_ctx *ctx, void *ptr)
+{
+	struct hlist_head *h;
+	struct hlist_node *n;
+	struct cr_objref *obj;
+
+	h = &ctx->objhash->head[hash_ptr(ptr, CR_OBJHASH_NBITS)];
+	hlist_for_each_entry(obj, n, h, hash)
+		if (obj->ptr == ptr)
+			return obj;
+	return NULL;
+}
+
+static struct cr_objref *cr_obj_find_by_objref(struct cr_ctx *ctx, int objref)
+{
+	struct hlist_head *h;
+	struct hlist_node *n;
+	struct cr_objref *obj;
+
+	h = &ctx->objhash->head[hash_ptr((void *) objref, CR_OBJHASH_NBITS)];
+	hlist_for_each_entry(obj, n, h, hash)
+		if (obj->objref == objref)
+			return obj;
+	return NULL;
+}
+
+/**
+ * cr_obj_new - allocate an object and add to the hash table
+ * @ctx: checkpoint context
+ * @ptr: pointer to object
+ * @objref: unique object reference
+ * @type: object type
+ * @flags: object flags
+ *
+ * Allocate an object referring to @ptr and add to the hash table.
+ * If @objref is zero, assign a unique object reference and use @ptr
+ * as a hash key [checkpoint]. Else use @objref as a key [restart].
+ */
+static struct cr_objref *cr_obj_new(struct cr_ctx *ctx, void *ptr, int objref,
+				    unsigned short type, unsigned short flags)
+{
+	struct cr_objref *obj;
+	int i;
+
+	obj = kmalloc(sizeof(*obj), GFP_KERNEL);
+	if (!obj)
+		return NULL;
+
+	obj->ptr = ptr;
+	obj->type = type;
+	obj->flags = flags;
+
+	if (objref) {
+		/* use @objref to index (restart) */
+		obj->objref = objref;
+		i = hash_ptr((void *) objref, CR_OBJHASH_NBITS);
+	} else {
+		/* use @ptr to index, assign objref (checkpoint) */
+		obj->objref = ctx->objhash->next_free_objref++;;
+		i = hash_ptr(ptr, CR_OBJHASH_NBITS);
+	}
+
+	hlist_add_head(&obj->hash, &ctx->objhash->head[i]);
+	cr_obj_ref_grab(obj);
+	return obj;
+}
+
+/**
+ * cr_obj_add_ptr - add an object to the hash table if not already there
+ * @ctx: checkpoint context
+ * @ptr: pointer to object
+ * @objref: unique object reference [output]
+ * @type: object type
+ * @flags: object flags
+ *
+ * Look up the object pointed to by @ptr in the hash table. If it isn't
+ * already found there, then add the object to the table, and allocate a
+ * fresh unique object reference (objref). Fills the unique objref of
+ * the object into @objref.
+ * [This is used during checkpoint].
+ *
+ * Returns 0 if found, 1 if added, < 0 on error
+ */
+int cr_obj_add_ptr(struct cr_ctx *ctx, void *ptr, int *objref,
+		   unsigned short type, unsigned short flags)
+{
+	struct cr_objref *obj;
+	int ret = 0;
+
+	obj = cr_obj_find_by_ptr(ctx, ptr);
+	if (!obj) {
+		obj = cr_obj_new(ctx, ptr, 0, type, flags);
+		if (!obj)
+			return -ENOMEM;
+		else
+			ret = 1;
+	} else if (obj->type != type)	/* sanity check */
+		return -EINVAL;
+	*objref = obj->objref;
+	return ret;
+}
+
+/**
+ * cr_obj_add_ref - add an object with unique objref to the hash table
+ * @ctx: checkpoint context
+ * @ptr: pointer to object
+ * @objref: unique identifier - object reference
+ * @type: object type
+ * @flags: object flags
+ *
+ * Add the object pointer to by @ptr and identified by unique object
+ * reference given by @objref to the hash table (indexed by @objref).
+ * [This is used during restart].
+ */
+int cr_obj_add_ref(struct cr_ctx *ctx, void *ptr, int objref,
+		   unsigned short type, unsigned short flags)
+{
+	struct cr_objref *obj;
+
+	obj = cr_obj_new(ctx, ptr, objref, type, flags);
+	return obj ? 0 : -ENOMEM;
+}
+
+/**
+ * cr_obj_get_by_ptr - find the unique object reference of an object
+ * @ctx: checkpoint context
+ * @ptr: pointer to object
+ * @type: object type
+ *
+ * Look up the unique object reference (objref) of the object pointed
+ * to by @ptr, and return that number, or 0 if not found.
+ * [This is used during checkpoint].
+ */
+int cr_obj_get_by_ptr(struct cr_ctx *ctx, void *ptr, unsigned short type)
+{
+	struct cr_objref *obj;
+
+	obj = cr_obj_find_by_ptr(ctx, ptr);
+	if (!obj)
+		return -ESRCH;
+	if (obj->type != type)
+		return -EINVAL;
+	return obj->objref;
+}
+
+/**
+ * cr_obj_get_by_ref - find an object given its unique object reference
+ * @ctx: checkpoint context
+ * @objref: unique identifier - object reference
+ * @type: object type
+ *
+ * Look up the object who is identified by unique object reference that
+ * is specified by @objref, and return a pointer to that matching object,
+ * or NULL if not found.
+ * [This is used during restart].
+ */
+void *cr_obj_get_by_ref(struct cr_ctx *ctx, int objref, unsigned short type)
+{
+	struct cr_objref *obj;
+
+	obj = cr_obj_find_by_objref(ctx, objref);
+	if (!obj)
+		return NULL;
+	if (obj->type != type)
+		return ERR_PTR(-EINVAL);
+	return obj->ptr;
+}
diff --git a/checkpoint/sys.c b/checkpoint/sys.c
index 6a18966..c1f2c8f 100644
--- a/checkpoint/sys.c
+++ b/checkpoint/sys.c
@@ -167,6 +167,7 @@ void cr_ctx_free(struct cr_ctx *ctx)
 		path_put(ctx->vfsroot);
 
 	cr_pgarr_free(ctx);
+	cr_objhash_free(ctx);
 
 	kfree(ctx);
 }
@@ -191,6 +192,11 @@ struct cr_ctx *cr_ctx_alloc(pid_t pid, int fd, unsigned long flags)
 		return ERR_PTR(-ENOMEM);
 	}
 
+	if (cr_objhash_alloc(ctx) < 0) {
+		cr_ctx_free(ctx);
+		return ERR_PTR(-ENOMEM);
+	}
+
 	/*
 	 * assume checkpointer is in container's root vfs
 	 * FIXME: this works for now, but will change with real containers
diff --git a/include/linux/checkpoint.h b/include/linux/checkpoint.h
index 3c6d1d1..2da3a9f 100644
--- a/include/linux/checkpoint.h
+++ b/include/linux/checkpoint.h
@@ -28,6 +28,8 @@ struct cr_ctx {
 	void *hbuf;		/* temporary buffer for headers */
 	int hpos;		/* position in headers buffer */
 
+	struct cr_objhash *objhash;	/* hash for shared objects */
+
 	struct list_head pgarr_list;	/* page array to dump VMA contents */
 
 	struct path *vfsroot;	/* container root (FIXME) */
@@ -45,6 +47,24 @@ extern int cr_kread(struct cr_ctx *ctx, void *buf, int count);
 extern void *cr_hbuf_get(struct cr_ctx *ctx, int n);
 extern void cr_hbuf_put(struct cr_ctx *ctx, int n);
 
+/* shared objects handling */
+
+enum {
+	CR_OBJ_FILE = 1,
+	CR_OBJ_MAX
+};
+
+extern void cr_objhash_free(struct cr_ctx *ctx);
+extern int cr_objhash_alloc(struct cr_ctx *ctx);
+extern void *cr_obj_get_by_ref(struct cr_ctx *ctx,
+			       int objref, unsigned short type);
+extern int cr_obj_get_by_ptr(struct cr_ctx *ctx,
+			     void *ptr, unsigned short type);
+extern int cr_obj_add_ptr(struct cr_ctx *ctx, void *ptr, int *objref,
+			  unsigned short type, unsigned short flags);
+extern int cr_obj_add_ref(struct cr_ctx *ctx, void *ptr, int objref,
+			  unsigned short type, unsigned short flags);
+
 struct cr_hdr;
 
 extern int cr_write_obj(struct cr_ctx *ctx, struct cr_hdr *h, void *buf);
-- 
1.5.4.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

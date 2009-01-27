Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id CA2666B004A
	for <linux-mm@kvack.org>; Tue, 27 Jan 2009 12:08:40 -0500 (EST)
From: Oren Laadan <orenl@cs.columbia.edu>
Subject: [RFC v13][PATCH 08/14] Infrastructure for shared objects
Date: Tue, 27 Jan 2009 12:08:06 -0500
Message-Id: <1233076092-8660-9-git-send-email-orenl@cs.columbia.edu>
In-Reply-To: <1233076092-8660-1-git-send-email-orenl@cs.columbia.edu>
References: <1233076092-8660-1-git-send-email-orenl@cs.columbia.edu>
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Linus Torvalds <torvalds@osdl.org>, containers@lists.linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-api@vger.kernel.org, Thomas Gleixner <tglx@linutronix.de>, Serge Hallyn <serue@us.ibm.com>, Dave Hansen <dave@linux.vnet.ibm.com>, Ingo Molnar <mingo@elte.hu>, "H. Peter Anvin" <hpa@zytor.com>, Alexander Viro <viro@zeniv.linux.org.uk>, Oren Laadan <orenl@cs.columbia.edu>
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

The hash is "one-way": objects added to it are never deleted until the
hash it discarded. The hash is discarded at the end of checkpoint or
restart, whether successful or not.

The hash keeps a reference to every object that is added to it, matching
the object's type, and maintains this reference during its lifetime.
Therefore, it is always safe to use an object that is stored in the hash.

Changelog[v13]:
  - Use hash_long() with 'unsigned long' cast to support 64bit archs
    (Nathan Lynch <ntl@pobox.com>)

Changelog[v11]:
  - Doc: be explicit about grabbing a reference and object lifetime

Changelog[v4]:
  - Fix calculation of hash table size

Changelog[v3]:
  - Use standard hlist_... for hash table

Signed-off-by: Oren Laadan <orenl@cs.columbia.edu>
Acked-by: Serge Hallyn <serue@us.ibm.com>
Signed-off-by: Dave Hansen <dave@linux.vnet.ibm.com>
---
 checkpoint/Makefile        |    2 +-
 checkpoint/objhash.c       |  280 ++++++++++++++++++++++++++++++++++++++++++++
 checkpoint/sys.c           |    4 +
 include/linux/checkpoint.h |   20 +++
 4 files changed, 305 insertions(+), 1 deletions(-)
 create mode 100644 checkpoint/objhash.c

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
index 0000000..ee31b38
--- /dev/null
+++ b/checkpoint/objhash.c
@@ -0,0 +1,280 @@
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
+	h = &ctx->objhash->head[hash_long((unsigned long) ptr,
+					  CR_OBJHASH_NBITS)];
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
+	h = &ctx->objhash->head[hash_long((unsigned long) objref,
+					  CR_OBJHASH_NBITS)];
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
+ * In both cases, grab a reference (depending on @type) to said obejct.
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
+		i = hash_long((unsigned long) objref, CR_OBJHASH_NBITS);
+	} else {
+		/* use @ptr to index, assign objref (checkpoint) */
+		obj->objref = ctx->objhash->next_free_objref++;;
+		i = hash_long((unsigned long) ptr, CR_OBJHASH_NBITS);
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
+ * fresh unique object reference (objref). Grab a reference to every
+ * object that is added, and maintain the reference until the entire
+ * hash is free.
+ *
+ * Fills the unique objref of the object into @objref.
+ *
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
+ * Grab a reference to every object that is added, and maintain the
+ * reference until the entire hash is free.
+ *
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
+ *
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
+ *
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
index b5242fe..a506b3a 100644
--- a/checkpoint/sys.c
+++ b/checkpoint/sys.c
@@ -161,6 +161,7 @@ static void cr_ctx_free(struct cr_ctx *ctx)
 	path_put(&ctx->fs_mnt);		/* safe with NULL pointers */
 
 	cr_pgarr_free(ctx);
+	cr_objhash_free(ctx);
 
 	kfree(ctx);
 }
@@ -189,6 +190,9 @@ static struct cr_ctx *cr_ctx_alloc(int fd, unsigned long flags)
 	if (!ctx->hbuf)
 		goto err;
 
+	if (cr_objhash_alloc(ctx) < 0)
+		goto err;
+
 	return ctx;
 
  err:
diff --git a/include/linux/checkpoint.h b/include/linux/checkpoint.h
index 06b6e5a..0ad4940 100644
--- a/include/linux/checkpoint.h
+++ b/include/linux/checkpoint.h
@@ -29,6 +29,8 @@ struct cr_ctx {
 	void *hbuf;		/* temporary buffer for headers */
 	int hpos;		/* position in headers buffer */
 
+	struct cr_objhash *objhash;	/* hash for shared objects */
+
 	struct list_head pgarr_list;	/* page array to dump VMA contents */
 	struct list_head pgarr_pool;	/* pool of empty page arrays chain */
 
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

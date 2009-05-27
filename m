Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id 974166B0089
	for <linux-mm@kvack.org>; Wed, 27 May 2009 13:33:17 -0400 (EDT)
From: Oren Laadan <orenl@cs.columbia.edu>
Subject: [RFC v16][PATCH 07/43] c/r: infrastructure for shared objects
Date: Wed, 27 May 2009 13:32:33 -0400
Message-Id: <1243445589-32388-8-git-send-email-orenl@cs.columbia.edu>
In-Reply-To: <1243445589-32388-1-git-send-email-orenl@cs.columbia.edu>
References: <1243445589-32388-1-git-send-email-orenl@cs.columbia.edu>
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Linus Torvalds <torvalds@osdl.org>, containers@lists.linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-api@vger.kernel.org, Serge Hallyn <serue@us.ibm.com>, Dave Hansen <dave@linux.vnet.ibm.com>, Ingo Molnar <mingo@elte.hu>, "H. Peter Anvin" <hpa@zytor.com>, Alexander Viro <viro@zeniv.linux.org.uk>, Pavel Emelyanov <xemul@openvz.org>, Alexey Dobriyan <adobriyan@gmail.com>, Oren Laadan <orenl@cs.columbia.edu>
List-ID: <linux-mm.kvack.org>

The state of shared objects is saved once. On the first encounter, the
state is dumped and the object is assigned a unique identifier (objref)
and also stored in a hash table (indexed by its physical kernel address).
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

Changelog[v16]:
  - Introduce ckpt_obj_lookup() to find an object by its ptr

Changelog[v14]:
  - Introduce 'struct ckpt_obj_ops' to better modularize shared objs.
  - Replace long 'switch' statements with table lookups and callbacks.
  - Introduce checkpoint_obj() and restart_obj() helpers
  - Shared objects now dumped/saved right before they are referenced
  - Cleanup interface of shared objects

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
---
 checkpoint/Makefile              |    1 +
 checkpoint/objhash.c             |  397 ++++++++++++++++++++++++++++++++++++++
 checkpoint/restart.c             |   46 +++++
 checkpoint/sys.c                 |    7 +
 include/linux/checkpoint.h       |   15 ++
 include/linux/checkpoint_hdr.h   |   14 ++
 include/linux/checkpoint_types.h |    2 +
 7 files changed, 482 insertions(+), 0 deletions(-)

diff --git a/checkpoint/Makefile b/checkpoint/Makefile
index 99364cc..5aa6a75 100644
--- a/checkpoint/Makefile
+++ b/checkpoint/Makefile
@@ -4,6 +4,7 @@
 
 obj-$(CONFIG_CHECKPOINT) += \
 	sys.o \
+	objhash.o \
 	checkpoint.o \
 	restart.o \
 	process.o
diff --git a/checkpoint/objhash.c b/checkpoint/objhash.c
new file mode 100644
index 0000000..82b4618
--- /dev/null
+++ b/checkpoint/objhash.c
@@ -0,0 +1,397 @@
+/*
+ *  Checkpoint-restart - object hash infrastructure to manage shared objects
+ *
+ *  Copyright (C) 2008-2009 Oren Laadan
+ *
+ *  This file is subject to the terms and conditions of the GNU General Public
+ *  License.  See the file COPYING in the main directory of the Linux
+ *  distribution for more details.
+ */
+
+/* default debug level for output */
+#define CKPT_DFLAG  CKPT_DOBJ
+
+#include <linux/kernel.h>
+#include <linux/hash.h>
+#include <linux/checkpoint.h>
+#include <linux/checkpoint_hdr.h>
+
+struct ckpt_obj;
+struct ckpt_obj_ops;
+
+/* object operations */
+struct ckpt_obj_ops {
+	char *obj_name;
+	enum obj_type obj_type;
+	void (*ref_drop)(void *ptr);
+	int (*ref_grab)(void *ptr);
+	int (*checkpoint)(struct ckpt_ctx *ctx, void *ptr);
+	void *(*restore)(struct ckpt_ctx *ctx);
+};
+
+struct ckpt_obj {
+	int objref;
+	void *ptr;
+	struct ckpt_obj_ops *ops;
+	struct hlist_node hash;
+};
+
+struct ckpt_obj_hash {
+	struct hlist_head *head;
+	int next_free_objref;
+};
+
+/* helper grab/drop functions: */
+
+static void obj_no_drop(void *ptr)
+{
+	return;
+}
+
+static int obj_no_grab(void *ptr)
+{
+	return 0;
+}
+
+static struct ckpt_obj_ops ckpt_obj_ops[] = {
+	/* ignored object */
+	{
+		.obj_name = "IGNORED",
+		.obj_type = CKPT_OBJ_IGNORE,
+		.ref_drop = obj_no_drop,
+		.ref_grab = obj_no_grab,
+	},
+};
+
+
+#define CKPT_OBJ_HASH_NBITS  10
+#define CKPT_OBJ_HASH_TOTAL  (1UL << CKPT_OBJ_HASH_NBITS)
+
+static void obj_hash_clear(struct ckpt_obj_hash *obj_hash)
+{
+	struct hlist_head *h = obj_hash->head;
+	struct hlist_node *n, *t;
+	struct ckpt_obj *obj;
+	int i;
+
+	for (i = 0; i < CKPT_OBJ_HASH_TOTAL; i++) {
+		hlist_for_each_entry_safe(obj, n, t, &h[i], hash) {
+			obj->ops->ref_drop(obj->ptr);
+			kfree(obj);
+		}
+	}
+}
+
+void ckpt_obj_hash_free(struct ckpt_ctx *ctx)
+{
+	struct ckpt_obj_hash *obj_hash = ctx->obj_hash;
+
+	if (obj_hash) {
+		obj_hash_clear(obj_hash);
+		kfree(obj_hash->head);
+		kfree(ctx->obj_hash);
+		ctx->obj_hash = NULL;
+	}
+}
+
+int ckpt_obj_hash_alloc(struct ckpt_ctx *ctx)
+{
+	struct ckpt_obj_hash *obj_hash;
+	struct hlist_head *head;
+
+	obj_hash = kzalloc(sizeof(*obj_hash), GFP_KERNEL);
+	if (!obj_hash)
+		return -ENOMEM;
+	head = kzalloc(CKPT_OBJ_HASH_TOTAL * sizeof(*head), GFP_KERNEL);
+	if (!head) {
+		kfree(obj_hash);
+		return -ENOMEM;
+	}
+
+	obj_hash->head = head;
+	obj_hash->next_free_objref = 1;
+
+	ctx->obj_hash = obj_hash;
+	return 0;
+}
+
+static struct ckpt_obj *obj_find_by_ptr(struct ckpt_ctx *ctx, void *ptr)
+{
+	struct hlist_head *h;
+	struct hlist_node *n;
+	struct ckpt_obj *obj;
+
+	h = &ctx->obj_hash->head[hash_long((unsigned long) ptr,
+					   CKPT_OBJ_HASH_NBITS)];
+	hlist_for_each_entry(obj, n, h, hash)
+		if (obj->ptr == ptr)
+			return obj;
+	return NULL;
+}
+
+static struct ckpt_obj *obj_find_by_objref(struct ckpt_ctx *ctx, int objref)
+{
+	struct hlist_head *h;
+	struct hlist_node *n;
+	struct ckpt_obj *obj;
+
+	h = &ctx->obj_hash->head[hash_long((unsigned long) objref,
+					   CKPT_OBJ_HASH_NBITS)];
+	hlist_for_each_entry(obj, n, h, hash)
+		if (obj->objref == objref)
+			return obj;
+	return NULL;
+}
+
+/**
+ * ckpt_obj_new - add an object to the obj_hash
+ * @ctx: checkpoint context
+ * @ptr: pointer to object
+ * @objref: object unique id
+ * @ops: object operations
+ *
+ * Returns: objref
+ *
+ * Add the object to the obj_hash. If @objref is zero, assign a unique
+ * object id and use @ptr as a hash key [checkpoint]. Else use @objref
+ * as a key [restart].
+ */
+static int obj_new(struct ckpt_ctx *ctx, void *ptr, int objref,
+		   struct ckpt_obj_ops *ops)
+{
+	struct ckpt_obj *obj;
+	int i, ret;
+
+	obj = kmalloc(sizeof(*obj), GFP_KERNEL);
+	if (!obj)
+		return -ENOMEM;
+
+	obj->ptr = ptr;
+	obj->ops = ops;
+
+	if (objref) {
+		/* use @obj->objref to index (restart) */
+		obj->objref = objref;
+		i = hash_long((unsigned long) objref, CKPT_OBJ_HASH_NBITS);
+	} else {
+		/* use @obj->ptr to index, assign objref (checkpoint) */
+		obj->objref = ctx->obj_hash->next_free_objref++;;
+		i = hash_long((unsigned long) ptr, CKPT_OBJ_HASH_NBITS);
+	}
+
+	ret = ops->ref_grab(obj->ptr);
+	if (ret < 0)
+		kfree(obj);
+	else
+		hlist_add_head(&obj->hash, &ctx->obj_hash->head[i]);
+
+	return (ret < 0 ? ret : obj->objref);
+}
+
+/**
+* ckpt_obj_lookup - lookup object (by pointer) in objhash
+* @ctx: checkpoint context
+* @ptr: pointer to object
+* @type: object type
+*
+* Look up the object pointed to by @ptr in the hash table
+*
+* [This is used during checkpoint].
+*
+* Return: objref (or zero if not found)
+*/
+int ckpt_obj_lookup(struct ckpt_ctx *ctx, void *ptr, enum obj_type type)
+{
+	struct ckpt_obj *obj;
+
+	obj = obj_find_by_ptr(ctx, ptr);
+	BUG_ON(obj && obj->ops->obj_type != type);
+	if (obj)
+		ckpt_debug("%s objref %d\n", obj->ops->obj_name, obj->objref);
+	return obj ? obj->objref : 0;
+}
+
+/**
+* ckpt_obj_lookup_add - lookup object and add if not in obj_hash
+* @ctx: checkpoint context
+* @ptr: pointer to object
+* @type: object type
+* @first: [output] first encoutner (added to table)
+*
+* Look up the object pointed to by @ptr in the hash table. If it isn't
+* already found there, add the object, and allocate a unique object
+* id. Grab a reference to every object that is added, and maintain the
+* reference until the entire hash is freed.
+*
+* [This is used during checkpoint].
+*
+* Return: objref
+*/
+int ckpt_obj_lookup_add(struct ckpt_ctx *ctx, void *ptr,
+			enum obj_type type, int *first)
+{
+	struct ckpt_obj_ops *ops = &ckpt_obj_ops[type];
+	struct ckpt_obj *obj;
+	int objref;
+
+	obj = obj_find_by_ptr(ctx, ptr);
+	if (!obj) {
+		objref = obj_new(ctx, ptr, 0, ops);
+		if (objref < 0)
+			return objref;
+		*first = 1;
+	} else if (obj->ops->obj_type != type) {   /* sanity check */
+		return -EINVAL;
+	} else {
+		objref = obj->objref;
+		*first = 0;
+	}
+
+	ckpt_debug("%s objref %d first %d\n", ops->obj_name, objref, *first);
+	return objref;
+}
+
+/**
+ * checkpoint_obj - if not already in hash, add object and checkpoint
+ * @ctx: checkpoint context
+ * @ptr: pointer to object
+ * @type: object type
+ *
+ * Look up the object pointed to by @ptr in the hash table. If it
+ * isn't already there, then add the object to the table, allocate a
+ * fresh unique id (objref) and save the object's state, and grab a
+ * reference to every object that is added. (Maintain the reference
+ * until the entire hash is free).
+ *
+ * [This is used during checkpoint].
+ *
+ * Returns: objref
+ */
+int checkpoint_obj(struct ckpt_ctx *ctx, void *ptr, enum obj_type type)
+{
+	struct ckpt_obj_ops *ops = &ckpt_obj_ops[type];
+	struct ckpt_hdr_objref *h;
+	struct ckpt_obj *obj;
+	int objref, ret = 0;
+
+	/* make sure we don't change this accidentally */
+	BUG_ON(ops->obj_type != type);
+
+	obj = obj_find_by_ptr(ctx, ptr);
+	if (obj) {
+		BUG_ON(obj->ops->obj_type != type);
+		return obj->objref;
+	}
+
+	h = ckpt_hdr_get_type(ctx, sizeof(*h), CKPT_HDR_OBJREF);
+	if (!h)
+		return -ENOMEM;
+
+	objref = obj_new(ctx, ptr, 0, ops);
+	if (objref < 0)
+		goto out;
+
+	h->objtype = type;
+	h->objref = objref;
+	ret = ckpt_write_obj(ctx, &h->h);
+	if (ret < 0)
+		goto out;
+
+	/* invoke callback to actually dump the state */
+	if (ops->checkpoint)
+		ret = ops->checkpoint(ctx, ptr);
+ out:
+	ckpt_hdr_put(ctx, h);
+	return (ret < 0 ? ret : objref);
+}
+
+/**
+ * restore_obj - read in and restore a (first seen) shared object
+ * @ctx: checkpoint context
+ * @h: ckpt_hdr of shared object
+ *
+ * Read in the header payload (struct ckpt_hdr_objref). Lookup the
+ * object to verify it isn't there.  Then restore the object's state
+ * and add it to the objash. No need to explicitly grab a reference -
+ * we hold the initial instance of this object. (Object maintained
+ * until the entire hash is free).
+ *
+ * [This is used during restart].
+ */
+int restore_obj(struct ckpt_ctx *ctx, struct ckpt_hdr_objref *h)
+{
+	struct ckpt_obj_ops *ops;
+	void *ptr = NULL;
+	int ret;
+
+	ckpt_debug("len %d ref %d type %d\n", h->h.len, h->objref, h->objtype);
+	if (obj_find_by_objref(ctx, h->objref))
+		return -EINVAL;
+
+	if (h->objtype >= CKPT_OBJ_MAX)
+		return -EINVAL;
+
+	ops = &ckpt_obj_ops[h->objtype];
+	BUG_ON(ops->obj_type != h->objtype);
+
+	if (ops->restore)
+		ptr = ops->restore(ctx);
+	if (IS_ERR(ptr))
+		return PTR_ERR(ptr);
+
+	ret = obj_new(ctx, ptr, h->objref, ops);
+	/*
+	 * Drop an extra reference to the object returned by ops->restore:
+	 * On success, this clears the extra reference taken by obj_new(),
+	 * and on failure, this cleans up the object itself.
+	 */
+	ops->ref_drop(ptr);
+	if (ret < 0)
+		ops->ref_drop(ptr);
+
+	return ret;
+}
+
+/**
+ * ckpt_obj_insert - add an object with a given objref to obj_hash
+ * @ctx: checkpoint context
+ * @ptr: pointer to object
+ * @objref: unique object id
+ * @type: object type
+ *
+ * Add the object pointer to by @ptr and identified by unique object id
+ * @objref to the hash table (indexed by @objref).  Grab a reference to
+ * every object added, and maintain it until the entire hash is freed.
+ *
+ * [This is used during restart].
+ */
+int ckpt_obj_insert(struct ckpt_ctx *ctx, void *ptr, int objref,
+		    enum obj_type type)
+{
+	struct ckpt_obj_ops *ops = &ckpt_obj_ops[type];
+
+	ckpt_debug("%s objref %d\n", ops->obj_name, objref);
+	return obj_new(ctx, ptr, objref, ops);
+}
+
+/**
+ * ckpt_obj_fetch - fetch an object by its identifier
+ * @ctx: checkpoint context
+ * @objref: object id
+ * @type: object type
+ *
+ * Lookup the objref identifier by @objref in the hash table. Return
+ * an error not found.
+ *
+ * [This is used during restart].
+ */
+void *ckpt_obj_fetch(struct ckpt_ctx *ctx, int objref, enum obj_type type)
+{
+	struct ckpt_obj *obj;
+
+	obj = obj_find_by_objref(ctx, objref);
+	if (!obj)
+		return ERR_PTR(-EINVAL);
+	ckpt_debug("%s ref %d\n", obj->ops->obj_name, obj->objref);
+	return (obj->ops->obj_type == type ? obj->ptr : ERR_PTR(-ENOMSG));
+}
diff --git a/checkpoint/restart.c b/checkpoint/restart.c
index e839538..ce52e30 100644
--- a/checkpoint/restart.c
+++ b/checkpoint/restart.c
@@ -20,6 +20,34 @@
 #include <linux/checkpoint_hdr.h>
 
 /**
+ * _ckpt_read_objref - dispatch handling of a shared object
+ * @ctx: checkpoint context
+ * @hh: objrect descriptor
+ */
+static int _ckpt_read_objref(struct ckpt_ctx *ctx, struct ckpt_hdr *hh)
+{
+	struct ckpt_hdr *h;
+	int ret;
+
+	h = ckpt_hdr_get(ctx, hh->len);
+	if (!h)
+		return -ENOMEM;
+
+	*h = *hh;	/* yay ! */
+
+	_ckpt_debug(CKPT_DOBJ, "shared len %d type %d\n", h->len, h->type);
+	ret = ckpt_kread(ctx, (h + 1), hh->len - sizeof(struct ckpt_hdr));
+	if (ret < 0)
+		goto out;
+
+	ret = restore_obj(ctx, (struct ckpt_hdr_objref *) h);
+ out:
+	ckpt_hdr_put(ctx, h);
+	return ret;
+}
+
+
+/**
  * _ckpt_read_obj - read an object (ckpt_hdr followed by payload)
  * @ctx: checkpoint context
  * @h: desired ckpt_hdr
@@ -34,6 +62,7 @@ static int _ckpt_read_obj(struct ckpt_ctx *ctx, struct ckpt_hdr *h,
 {
 	int ret;
 
+ again:
 	ret = ckpt_kread(ctx, h, sizeof(*h));
 	if (ret < 0)
 		return ret;
@@ -41,7 +70,15 @@ static int _ckpt_read_obj(struct ckpt_ctx *ctx, struct ckpt_hdr *h,
 		    h->type, h->len, len, max);
 	if (h->len < sizeof(*h))
 		return -EINVAL;
+
 	/* if len specified, enforce, else if maximum specified, enforce */
+	if (h->type == CKPT_HDR_OBJREF) {
+		ret = _ckpt_read_objref(ctx, h);
+		if (ret < 0)
+			return ret;
+		goto again;
+	}
+
 	if ((len && h->len != len) || (!len && max && h->len > max))
 		return -EINVAL;
 
@@ -150,6 +187,7 @@ static void *ckpt_read_obj(struct ckpt_ctx *ctx, int len, int max)
 	struct ckpt_hdr *h;
 	int ret;
 
+ again:
 	ret = ckpt_kread(ctx, &hh, sizeof(hh));
 	if (ret < 0)
 		return ERR_PTR(ret);
@@ -157,6 +195,14 @@ static void *ckpt_read_obj(struct ckpt_ctx *ctx, int len, int max)
 		    hh.type, hh.len, len, max);
 	if (hh.len < sizeof(*h))
 		return ERR_PTR(-EINVAL);
+
+	if (hh.type == CKPT_HDR_OBJREF) {
+		ret = _ckpt_read_objref(ctx, &hh);
+		if (ret < 0)
+			return ERR_PTR(ret);
+		goto again;
+	}
+
 	/* if len specified, enforce, else if maximum specified, enforce */
 	if ((len && hh.len != len) || (!len && max && hh.len > max))
 		return ERR_PTR(-EINVAL);
diff --git a/checkpoint/sys.c b/checkpoint/sys.c
index 2ad9722..c8a260d 100644
--- a/checkpoint/sys.c
+++ b/checkpoint/sys.c
@@ -168,6 +168,9 @@ static void ckpt_ctx_free(struct ckpt_ctx *ctx)
 {
 	if (ctx->file)
 		fput(ctx->file);
+
+	ckpt_obj_hash_free(ctx);
+
 	kfree(ctx);
 }
 
@@ -189,6 +192,10 @@ static struct ckpt_ctx *ckpt_ctx_alloc(int fd, unsigned long uflags,
 	if (!ctx->file)
 		goto err;
 
+	err = -ENOMEM;
+	if (ckpt_obj_hash_alloc(ctx) < 0)
+		goto err;
+
 	return ctx;
  err:
 	ckpt_ctx_free(ctx);
diff --git a/include/linux/checkpoint.h b/include/linux/checkpoint.h
index 6247114..9f65a81 100644
--- a/include/linux/checkpoint.h
+++ b/include/linux/checkpoint.h
@@ -32,11 +32,25 @@ extern int ckpt_write_err(struct ckpt_ctx *ctx, char *fmt, ...);
 
 extern int _ckpt_read_obj_type(struct ckpt_ctx *ctx,
 			       void *ptr, int len, int type);
+extern int _ckpt_read_nbuffer(struct ckpt_ctx *ctx, void *ptr, int len);
 extern int _ckpt_read_buffer(struct ckpt_ctx *ctx, void *ptr, int len);
 extern int _ckpt_read_string(struct ckpt_ctx *ctx, void *ptr, int len);
 extern void *ckpt_read_obj_type(struct ckpt_ctx *ctx, int len, int type);
 extern void *ckpt_read_buf_type(struct ckpt_ctx *ctx, int len, int type);
 
+/* obj_hash */
+extern void ckpt_obj_hash_free(struct ckpt_ctx *ctx);
+extern int ckpt_obj_hash_alloc(struct ckpt_ctx *ctx);
+
+extern int restore_obj(struct ckpt_ctx *ctx, struct ckpt_hdr_objref *h);
+extern int checkpoint_obj(struct ckpt_ctx *ctx, void *ptr, enum obj_type type);
+extern void *ckpt_obj_fetch(struct ckpt_ctx *ctx, int objref,
+			    enum obj_type type);
+extern int ckpt_obj_lookup_add(struct ckpt_ctx *ctx, void *ptr,
+			       enum obj_type type, int *first);
+extern int ckpt_obj_insert(struct ckpt_ctx *ctx, void *ptr, int objref,
+			   enum obj_type type);
+
 extern int do_checkpoint(struct ckpt_ctx *ctx, pid_t pid);
 extern int do_restart(struct ckpt_ctx *ctx, pid_t pid);
 
@@ -58,6 +72,7 @@ extern int restore_cpu(struct ckpt_ctx *ctx);
 #define CKPT_DBASE	0x1		/* anything */
 #define CKPT_DSYS	0x2		/* generic (system) */
 #define CKPT_DRW	0x4		/* image read/write */
+#define CKPT_DOBJ	0x8		/* shared objects */
 
 #define CKPT_DDEFAULT	0x7		/* default debug level */
 
diff --git a/include/linux/checkpoint_hdr.h b/include/linux/checkpoint_hdr.h
index a0c576c..195e44b 100644
--- a/include/linux/checkpoint_hdr.h
+++ b/include/linux/checkpoint_hdr.h
@@ -44,6 +44,7 @@ enum {
 	CKPT_HDR_HEADER_ARCH,
 	CKPT_HDR_BUFFER,
 	CKPT_HDR_STRING,
+	CKPT_HDR_OBJREF,
 
 	CKPT_HDR_TASK = 101,
 	CKPT_HDR_THREAD,
@@ -61,6 +62,19 @@ enum {
 	CKPT_ARCH_X86_32 = 1,
 };
 
+/* shared objrects (objref) */
+struct ckpt_hdr_objref {
+	struct ckpt_hdr h;
+	__u32 objtype;
+	__s32 objref;
+} __attribute__((aligned(8)));
+
+/* shared objects types */
+enum obj_type {
+	CKPT_OBJ_IGNORE = 0,
+	CKPT_OBJ_MAX
+};
+
 /* checkpoint image header */
 struct ckpt_hdr_header {
 	struct ckpt_hdr h;
diff --git a/include/linux/checkpoint_types.h b/include/linux/checkpoint_types.h
index 2b8d59f..c1032fa 100644
--- a/include/linux/checkpoint_types.h
+++ b/include/linux/checkpoint_types.h
@@ -27,6 +27,8 @@ struct ckpt_ctx {
 	struct file *file;	/* input/output file */
 	int total;		/* total read/written */
 
+	struct ckpt_obj_hash *obj_hash;	/* repository for shared objects */
+
 	char err_string[256];	/* checkpoint: error string */
 };
 
-- 
1.6.0.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

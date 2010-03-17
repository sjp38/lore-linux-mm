Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id 9F0996B0225
	for <linux-mm@kvack.org>; Wed, 17 Mar 2010 12:14:54 -0400 (EDT)
From: Oren Laadan <orenl@cs.columbia.edu>
Subject: [C/R v20][PATCH 34/96] c/r: infrastructure for shared objects
Date: Wed, 17 Mar 2010 12:08:22 -0400
Message-Id: <1268842164-5590-35-git-send-email-orenl@cs.columbia.edu>
In-Reply-To: <1268842164-5590-34-git-send-email-orenl@cs.columbia.edu>
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
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-api@vger.kernel.org, Serge Hallyn <serue@us.ibm.com>, Ingo Molnar <mingo@elte.hu>, containers@lists.linux-foundation.org, Oren Laadan <orenl@cs.columbia.edu>
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

Changelog[v20]:
  - Export key symbols to enable c/r from kernel modules
  - Avoid crash if incoming object doesn't have .restore
Changelog[v19-rc1]:
  - Define ckpt_obj_try_fetch
  - Disallow zero or negative objref during restart
  - [Matt Helsley] Add cpp definitions for enums
  - [Serge Hallyn] Use ckpt_err() in ckpt_obj_fetch()
  - [Serge Hallyn] Use ckpt_err() in ckpt_read_obj_type()
  - Factor out objref handling from {_,}ckpt_read_obj()
Changelog[v18]:
  - Add ckpt_obj_reserve()
  - Change ref_drop() to accept a @lastref argument (useful for cleanup)
  - Disallow multiple objects with same objref in restart
  - Allow _ckpt_read_obj_type() to read object header only (w/o payload)
Changelog[v17]:
  - Add ckpt_obj->flags with CKPT_OBJ_CHECKPOINTED flag
  - Add prototype of ckpt_obj_lookup
  - Complain on attempt to add NULL ptr to objhash
  - Prepare for 'leaks detection'
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
Acked-by: Serge E. Hallyn <serue@us.ibm.com>
Tested-by: Serge E. Hallyn <serue@us.ibm.com>
---
 checkpoint/Makefile              |    1 +
 checkpoint/objhash.c             |  462 ++++++++++++++++++++++++++++++++++++++
 checkpoint/restart.c             |   81 +++++--
 checkpoint/sys.c                 |    7 +
 include/linux/checkpoint.h       |   20 ++
 include/linux/checkpoint_hdr.h   |   17 ++
 include/linux/checkpoint_types.h |    2 +
 7 files changed, 572 insertions(+), 18 deletions(-)
 create mode 100644 checkpoint/objhash.c

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
index 0000000..ada5113
--- /dev/null
+++ b/checkpoint/objhash.c
@@ -0,0 +1,462 @@
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
+	void (*ref_drop)(void *ptr, int lastref);
+	int (*ref_grab)(void *ptr);
+	int (*checkpoint)(struct ckpt_ctx *ctx, void *ptr);
+	void *(*restore)(struct ckpt_ctx *ctx);
+};
+
+struct ckpt_obj {
+	int objref;
+	int flags;
+	void *ptr;
+	struct ckpt_obj_ops *ops;
+	struct hlist_node hash;
+};
+
+/* object internal flags */
+#define CKPT_OBJ_CHECKPOINTED		0x1   /* object already checkpointed */
+
+struct ckpt_obj_hash {
+	struct hlist_head *head;
+	int next_free_objref;
+};
+
+/* helper grab/drop functions: */
+
+static void obj_no_drop(void *ptr, int lastref)
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
+			obj->ops->ref_drop(obj->ptr, 1);
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
+static inline int obj_alloc_objref(struct ckpt_ctx *ctx)
+{
+	return ctx->obj_hash->next_free_objref++;
+}
+
+/**
+ * ckpt_obj_new - add an object to the obj_hash
+ * @ctx: checkpoint context
+ * @ptr: pointer to object
+ * @objref: object unique id
+ * @ops: object operations
+ *
+ * Add the object to the obj_hash. If @objref is zero, assign a unique
+ * object id and use @ptr as a hash key [checkpoint]. Else use @objref
+ * as a key [restart].
+ */
+static struct ckpt_obj *obj_new(struct ckpt_ctx *ctx, void *ptr,
+				int objref, enum obj_type type)
+{
+	struct ckpt_obj_ops *ops = &ckpt_obj_ops[type];
+	struct ckpt_obj *obj;
+	int i, ret;
+
+	/* explicitly disallow null pointers */
+	BUG_ON(!ptr);
+	/* make sure we don't change this accidentally */
+	BUG_ON(ops->obj_type != type);
+
+	obj = kzalloc(sizeof(*obj), GFP_KERNEL);
+	if (!obj)
+		return ERR_PTR(-ENOMEM);
+
+	obj->ptr = ptr;
+	obj->ops = ops;
+
+	if (!objref) {
+		/* use @obj->ptr to index, assign objref (checkpoint) */
+		obj->objref = obj_alloc_objref(ctx);
+		i = hash_long((unsigned long) ptr, CKPT_OBJ_HASH_NBITS);
+	} else {
+		/* use @obj->objref to index (restart) */
+		obj->objref = objref;
+		i = hash_long((unsigned long) objref, CKPT_OBJ_HASH_NBITS);
+	}
+
+	ret = ops->ref_grab(obj->ptr);
+	if (ret < 0) {
+		kfree(obj);
+		obj = ERR_PTR(ret);
+	} else {
+		hlist_add_head(&obj->hash, &ctx->obj_hash->head[i]);
+	}
+
+	return obj;
+}
+
+/**************************************************************************
+ * Checkpoint
+ */
+
+/**
+ * obj_lookup_add - lookup object and add if not in objhash
+ * @ctx: checkpoint context
+ * @ptr: pointer to object
+ * @type: object type
+ * @first: [output] first encounter (added to table)
+ *
+ * Look up the object pointed to by @ptr in the hash table. If it isn't
+ * already found there, add the object, and allocate a unique object
+ * id. Grab a reference to every object that is added, and maintain the
+ * reference until the entire hash is freed.
+ */
+static struct ckpt_obj *obj_lookup_add(struct ckpt_ctx *ctx, void *ptr,
+				       enum obj_type type, int *first)
+{
+	struct ckpt_obj *obj;
+
+	obj = obj_find_by_ptr(ctx, ptr);
+	if (!obj) {
+		obj = obj_new(ctx, ptr, 0, type);
+		*first = 1;
+	} else {
+		BUG_ON(obj->ops->obj_type != type);
+		*first = 0;
+	}
+	return obj;
+}
+
+/**
+ * ckpt_obj_lookup - lookup object (by pointer) in objhash
+ * @ctx: checkpoint context
+ * @ptr: pointer to object
+ * @type: object type
+ *
+ * [used during checkpoint].
+ * Return: objref (or zero if not found)
+ */
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
+EXPORT_SYMBOL(ckpt_obj_lookup);
+
+/**
+ * ckpt_obj_lookup_add - lookup object and add if not in objhash
+ * @ctx: checkpoint context
+ * @ptr: pointer to object
+ * @type: object type
+ * @first: [output] first encoutner (added to table)
+ *
+ * [used during checkpoint].
+ * Return: objref
+ */
+int ckpt_obj_lookup_add(struct ckpt_ctx *ctx, void *ptr,
+			enum obj_type type, int *first)
+{
+	struct ckpt_obj *obj;
+
+	obj = obj_lookup_add(ctx, ptr, type, first);
+	if (IS_ERR(obj))
+		return PTR_ERR(obj);
+	ckpt_debug("%s objref %d first %d\n",
+		   obj->ops->obj_name, obj->objref, *first);
+	obj->flags |= CKPT_OBJ_CHECKPOINTED;
+	return obj->objref;
+}
+EXPORT_SYMBOL(ckpt_obj_lookup_add);
+
+/**
+ * ckpt_obj_reserve - reserve an objref
+ * @ctx: checkpoint context
+ *
+ * The reserved objref will not be used for subsequent objects. This
+ * gives an objref that can be safely used during restart without a
+ * matching object in checkpoint.  [used during checkpoint].
+ */
+int ckpt_obj_reserve(struct ckpt_ctx *ctx)
+{
+	return obj_alloc_objref(ctx);
+}
+EXPORT_SYMBOL(ckpt_obj_reserve);
+
+/**
+ * checkpoint_obj - if not already in hash, add object and checkpoint
+ * @ctx: checkpoint context
+ * @ptr: pointer to object
+ * @type: object type
+ *
+ * Use obj_lookup_add() to lookup (and possibly add) the object to the
+ * hash table. If the CKPT_OBJ_CHECKPOINTED flag isn't set, then also
+ * save the object's state using its ops->checkpoint().
+ *
+ * [This is used during checkpoint].
+ * Returns: objref
+ */
+int checkpoint_obj(struct ckpt_ctx *ctx, void *ptr, enum obj_type type)
+{
+	struct ckpt_hdr_objref *h;
+	struct ckpt_obj *obj;
+	int new, ret = 0;
+
+	obj = obj_lookup_add(ctx, ptr, type, &new);
+	if (IS_ERR(obj))
+		return PTR_ERR(obj);
+
+	if (!(obj->flags & CKPT_OBJ_CHECKPOINTED)) {
+		h = ckpt_hdr_get_type(ctx, sizeof(*h), CKPT_HDR_OBJREF);
+		if (!h)
+			return -ENOMEM;
+
+		h->objtype = type;
+		h->objref = obj->objref;
+		ret = ckpt_write_obj(ctx, &h->h);
+		ckpt_hdr_put(ctx, h);
+
+		if (ret < 0)
+			return ret;
+
+		/* invoke callback to actually dump the state */
+		if (obj->ops->checkpoint)
+			ret = obj->ops->checkpoint(ctx, ptr);
+
+		obj->flags |= CKPT_OBJ_CHECKPOINTED;
+	}
+	return (ret < 0 ? ret : obj->objref);
+}
+EXPORT_SYMBOL(checkpoint_obj);
+
+/**************************************************************************
+ * Restart
+ */
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
+	struct ckpt_obj *obj;
+	void *ptr = ERR_PTR(-EINVAL);
+
+	ckpt_debug("len %d ref %d type %d\n", h->h.len, h->objref, h->objtype);
+	if (h->objtype >= CKPT_OBJ_MAX)
+		return -EINVAL;
+	if (h->objref <= 0)
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
+	if (obj_find_by_objref(ctx, h->objref))
+		obj = ERR_PTR(-EINVAL);
+	else
+		obj = obj_new(ctx, ptr, h->objref, h->objtype);
+	/*
+	 * Drop an extra reference to the object returned by ops->restore:
+	 * On success, this clears the extra reference taken by obj_new(),
+	 * and on failure, this cleans up the object itself.
+	 */
+	ops->ref_drop(ptr, 0);
+	if (IS_ERR(obj)) {
+		ops->ref_drop(ptr, 1);
+		return PTR_ERR(obj);
+	}
+	return obj->objref;
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
+int ckpt_obj_insert(struct ckpt_ctx *ctx, void *ptr,
+		    int objref, enum obj_type type)
+{
+	struct ckpt_obj *obj;
+
+	if (objref <= 0)
+		return -EINVAL;
+	if (obj_find_by_objref(ctx, objref))
+		return -EINVAL;
+	obj = obj_new(ctx, ptr, objref, type);
+	if (IS_ERR(obj))
+		return PTR_ERR(obj);
+	ckpt_debug("%s objref %d\n", obj->ops->obj_name, objref);
+	return obj->objref;
+}
+EXPORT_SYMBOL(ckpt_obj_insert);
+
+/**
+ * ckpt_obj_try_fetch - fetch an object by its identifier
+ * @ctx: checkpoint context
+ * @objref: object id
+ * @type: object type
+ *
+ * Lookup the objref identifier by @objref in the hash table. Return
+ * an error not found.
+ *
+ * [This is used during restart].
+ */
+void *ckpt_obj_try_fetch(struct ckpt_ctx *ctx, int objref, enum obj_type type)
+{
+	struct ckpt_obj *obj;
+
+	obj = obj_find_by_objref(ctx, objref);
+	if (!obj)
+		return ERR_PTR(-EINVAL);
+	ckpt_debug("%s ref %d\n", obj->ops->obj_name, obj->objref);
+	if (obj->ops->obj_type == type)
+		return obj->ptr;
+	return ERR_PTR(-ENOMSG);
+}
+EXPORT_SYMBOL(ckpt_obj_try_fetch);
+
+void *ckpt_obj_fetch(struct ckpt_ctx *ctx, int objref, enum obj_type type)
+{
+	void *ret = ckpt_obj_try_fetch(ctx, objref, type);
+
+	if (unlikely(IS_ERR(ret)))
+		ckpt_err(ctx, PTR_ERR(ret), "%(O)Fetching object (type %d)\n",
+			 objref, type);
+	return ret;
+}
+EXPORT_SYMBOL(ckpt_obj_fetch);
diff --git a/checkpoint/restart.c b/checkpoint/restart.c
index e2ed358..d33b18a 100644
--- a/checkpoint/restart.c
+++ b/checkpoint/restart.c
@@ -210,6 +210,63 @@ static int _ckpt_read_err(struct ckpt_ctx *ctx, struct ckpt_hdr *h)
 }
 
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
+/**
+ * ckpt_read_obj_dispatch - dispatch ERRORs and OBJREFs; don't return them
+ * @ctx: checkpoint context
+ * @h: desired ckpt_hdr
+ */
+static int ckpt_read_obj_dispatch(struct ckpt_ctx *ctx, struct ckpt_hdr *h)
+{
+	int ret;
+
+	while (1) {
+		ret = ckpt_kread(ctx, h, sizeof(*h));
+		if (ret < 0)
+			return ret;
+		_ckpt_debug(CKPT_DRW, "type %d len %d\n", h->type, h->len);
+		if (h->len < sizeof(*h))
+			return -EINVAL;
+
+		if (h->type == CKPT_HDR_ERROR) {
+			ret = _ckpt_read_err(ctx, h);
+			if (ret < 0)
+				return ret;
+		} else if (h->type == CKPT_HDR_OBJREF) {
+			ret = _ckpt_read_objref(ctx, h);
+			if (ret < 0)
+				return ret;
+		} else
+			return 0;
+	}
+}
+
+/**
  * _ckpt_read_obj - read an object (ckpt_hdr followed by payload)
  * @ctx: checkpoint context
  * @h: desired ckpt_hdr
@@ -224,21 +281,11 @@ static int _ckpt_read_obj(struct ckpt_ctx *ctx, struct ckpt_hdr *h,
 {
 	int ret;
 
- again:
-	ret = ckpt_kread(ctx, h, sizeof(*h));
+	ret = ckpt_read_obj_dispatch(ctx, h);
 	if (ret < 0)
 		return ret;
 	_ckpt_debug(CKPT_DRW, "type %d len %d(%d,%d)\n",
 		    h->type, h->len, len, max);
-	if (h->len < sizeof(*h))
-		return -EINVAL;
-
-	if (h->type == CKPT_HDR_ERROR) {
-		ret = _ckpt_read_err(ctx, h);
-		if (ret < 0)
-			return ret;
-		goto again;
-	}
 
 	/* if len specified, enforce, else if maximum specified, enforce */
 	if ((len && h->len != len) || (!len && max && h->len > max))
@@ -330,13 +377,12 @@ static void *ckpt_read_obj(struct ckpt_ctx *ctx, int len, int max)
 	struct ckpt_hdr *h;
 	int ret;
 
-	ret = ckpt_kread(ctx, &hh, sizeof(hh));
+	ret = ckpt_read_obj_dispatch(ctx, &hh);
 	if (ret < 0)
 		return ERR_PTR(ret);
 	_ckpt_debug(CKPT_DRW, "type %d len %d(%d,%d)\n",
 		    hh.type, hh.len, len, max);
-	if (hh.len < sizeof(*h))
-		return ERR_PTR(-EINVAL);
+
 	/* if len specified, enforce, else if maximum specified, enforce */
 	if ((len && hh.len != len) || (!len && max && hh.len > max))
 		return ERR_PTR(-EINVAL);
@@ -372,15 +418,14 @@ void *ckpt_read_obj_type(struct ckpt_ctx *ctx, int len, int type)
 
 	h = ckpt_read_obj(ctx, len, len);
 	if (IS_ERR(h)) {
-		ckpt_err(ctx, PTR_ERR(h), "Looking for type %d in ckptfile\n",
-			 type);
+		ckpt_err(ctx, PTR_ERR(h), "Expecting to read type %d\n", type);
 		return h;
 	}
 
 	if (h->type != type) {
 		ckpt_hdr_put(ctx, h);
-		ckpt_err(ctx, -EINVAL, "Next object was type %d, not %d\n",
-			h->type, type);
+		ckpt_err(ctx, -EINVAL, "Expected type %d but got %d\n",
+			 h->type, type);
 		h = ERR_PTR(-EINVAL);
 	}
 
diff --git a/checkpoint/sys.c b/checkpoint/sys.c
index 8b142ed..926c937 100644
--- a/checkpoint/sys.c
+++ b/checkpoint/sys.c
@@ -211,6 +211,8 @@ static void ckpt_ctx_free(struct ckpt_ctx *ctx)
 	if (ctx->logfile)
 		fput(ctx->logfile);
 
+	ckpt_obj_hash_free(ctx);
+
 	if (ctx->tasks_arr)
 		task_arr_free(ctx);
 
@@ -262,7 +264,12 @@ static struct ckpt_ctx *ckpt_ctx_alloc(int fd, unsigned long uflags,
 	ctx->logfile = fget(logfd);
 	if (!ctx->logfile)
 		goto err;
+
  nolog:
+	err = -ENOMEM;
+	if (ckpt_obj_hash_alloc(ctx) < 0)
+		goto err;
+
 	atomic_inc(&ctx->refcount);
 	return ctx;
  err:
diff --git a/include/linux/checkpoint.h b/include/linux/checkpoint.h
index 61581f6..da6fd36 100644
--- a/include/linux/checkpoint.h
+++ b/include/linux/checkpoint.h
@@ -106,6 +106,25 @@ static inline int ckpt_get_error(struct ckpt_ctx *ctx)
 
 extern void restore_notify_error(struct ckpt_ctx *ctx);
 
+/* obj_hash */
+extern void ckpt_obj_hash_free(struct ckpt_ctx *ctx);
+extern int ckpt_obj_hash_alloc(struct ckpt_ctx *ctx);
+
+extern int restore_obj(struct ckpt_ctx *ctx, struct ckpt_hdr_objref *h);
+extern int checkpoint_obj(struct ckpt_ctx *ctx, void *ptr,
+			  enum obj_type type);
+extern int ckpt_obj_lookup(struct ckpt_ctx *ctx, void *ptr,
+			   enum obj_type type);
+extern int ckpt_obj_lookup_add(struct ckpt_ctx *ctx, void *ptr,
+			       enum obj_type type, int *first);
+extern void *ckpt_obj_try_fetch(struct ckpt_ctx *ctx, int objref,
+				enum obj_type type);
+extern void *ckpt_obj_fetch(struct ckpt_ctx *ctx, int objref,
+			    enum obj_type type);
+extern int ckpt_obj_insert(struct ckpt_ctx *ctx, void *ptr, int objref,
+			   enum obj_type type);
+extern int ckpt_obj_reserve(struct ckpt_ctx *ctx);
+
 extern struct ckpt_ctx *ckpt_ctx_get(struct ckpt_ctx *ctx);
 extern void ckpt_ctx_put(struct ckpt_ctx *ctx);
 
@@ -139,6 +158,7 @@ static inline int ckpt_validate_errno(int errno)
 #define CKPT_DBASE	0x1		/* anything */
 #define CKPT_DSYS	0x2		/* generic (system) */
 #define CKPT_DRW	0x4		/* image read/write */
+#define CKPT_DOBJ	0x8		/* shared objects */
 
 #define CKPT_DDEFAULT	0xffff		/* default debug level */
 
diff --git a/include/linux/checkpoint_hdr.h b/include/linux/checkpoint_hdr.h
index 651255f..cdca9e4 100644
--- a/include/linux/checkpoint_hdr.h
+++ b/include/linux/checkpoint_hdr.h
@@ -64,6 +64,8 @@ enum {
 #define CKPT_HDR_BUFFER CKPT_HDR_BUFFER
 	CKPT_HDR_STRING,
 #define CKPT_HDR_STRING CKPT_HDR_STRING
+	CKPT_HDR_OBJREF,
+#define CKPT_HDR_OBJREF CKPT_HDR_OBJREF
 
 	CKPT_HDR_TREE = 101,
 #define CKPT_HDR_TREE CKPT_HDR_TREE
@@ -93,6 +95,21 @@ enum {
 #define CKPT_ARCH_X86_64 CKPT_ARCH_X86_64
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
+#define CKPT_OBJ_IGNORE CKPT_OBJ_IGNORE
+	CKPT_OBJ_MAX
+#define CKPT_OBJ_MAX CKPT_OBJ_MAX
+};
+
 /* kernel constants */
 struct ckpt_const {
 	/* task */
diff --git a/include/linux/checkpoint_types.h b/include/linux/checkpoint_types.h
index afe76ad..90bbb16 100644
--- a/include/linux/checkpoint_types.h
+++ b/include/linux/checkpoint_types.h
@@ -39,6 +39,8 @@ struct ckpt_ctx {
 
 	atomic_t refcount;
 
+	struct ckpt_obj_hash *obj_hash;	/* repository for shared objects */
+
 	struct task_struct *tsk;/* checkpoint: current target task */
 	char err_string[256];	/* checkpoint: error string */
 
-- 
1.6.3.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

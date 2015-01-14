Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qa0-f54.google.com (mail-qa0-f54.google.com [209.85.216.54])
	by kanga.kvack.org (Postfix) with ESMTP id 7AF606B0032
	for <linux-mm@kvack.org>; Wed, 14 Jan 2015 09:37:34 -0500 (EST)
Received: by mail-qa0-f54.google.com with SMTP id w8so5963611qac.13
        for <linux-mm@kvack.org>; Wed, 14 Jan 2015 06:37:34 -0800 (PST)
Received: from mail-qc0-x230.google.com (mail-qc0-x230.google.com. [2607:f8b0:400d:c01::230])
        by mx.google.com with ESMTPS id g10si1197446qab.25.2015.01.14.06.37.33
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Wed, 14 Jan 2015 06:37:33 -0800 (PST)
Received: by mail-qc0-f176.google.com with SMTP id i17so7463249qcy.7
        for <linux-mm@kvack.org>; Wed, 14 Jan 2015 06:37:33 -0800 (PST)
Date: Wed, 14 Jan 2015 09:37:30 -0500
From: Tejun Heo <tj@kernel.org>
Subject: [PATCH 2.5/5] kernfs: remove KERNFS_STATIC_NAME
Message-ID: <20150114143730.GE3565@htj.dyndns.org>
References: <1421054323-14430-1-git-send-email-a.hajda@samsung.com>
 <1421054323-14430-3-git-send-email-a.hajda@samsung.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1421054323-14430-3-git-send-email-a.hajda@samsung.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrzej Hajda <a.hajda@samsung.com>
Cc: linux-mm@kvack.org, Marek Szyprowski <m.szyprowski@samsung.com>, Kyungmin Park <kyungmin.park@samsung.com>, linux-kernel@vger.kernel.org, andi@firstfloor.org, andi@lisas.de, Mike Turquette <mturquette@linaro.org>, Alexander Viro <viro@zeniv.linux.org.uk>, Andrew Morton <akpm@linux-foundation.org>

When a new kernfs node is created, KERNFS_STATIC_NAME is used to avoid
making a separate copy of its name.  It's currently only used for
sysfs attributes whose filenames are required to stay accessible and
unchanged.  There are rare exceptions where these names are allocated
and formatted dynamically but for the vast majority of cases they're
consts in the rodata section.

Now that kernfs is converted to use kstrdup_const() and kfree_const(),
there's little point in keeping KERNFS_STATIC_NAME around.  Remove it.

Signed-off-by: Tejun Heo <tj@kernel.org>
Cc: Andrzej Hajda <a.hajda@samsung.com>
Cc: Andrew Morton <akpm@linux-foundation.org>
---
Lightly tested.  Seems to work fine.  Please feel free to route with
the rest of the series.

Thanks.

 fs/kernfs/dir.c        |   20 ++++++++------------
 fs/kernfs/file.c       |    4 ----
 fs/sysfs/file.c        |    2 +-
 include/linux/kernfs.h |    7 ++-----
 kernel/cgroup.c        |    2 +-
 5 files changed, 12 insertions(+), 23 deletions(-)

--- a/fs/kernfs/dir.c
+++ b/fs/kernfs/dir.c
@@ -407,8 +407,9 @@ void kernfs_put(struct kernfs_node *kn)
 
 	if (kernfs_type(kn) == KERNFS_LINK)
 		kernfs_put(kn->symlink.target_kn);
-	if (!(kn->flags & KERNFS_STATIC_NAME))
-		kfree_const(kn->name);
+
+	kfree_const(kn->name);
+
 	if (kn->iattr) {
 		if (kn->iattr->ia_secdata)
 			security_release_secctx(kn->iattr->ia_secdata,
@@ -502,15 +503,12 @@ static struct kernfs_node *__kernfs_new_
 					     const char *name, umode_t mode,
 					     unsigned flags)
 {
-	const char *dup_name = NULL;
 	struct kernfs_node *kn;
 	int ret;
 
-	if (!(flags & KERNFS_STATIC_NAME)) {
-		name = dup_name = kstrdup_const(name, GFP_KERNEL);
-		if (!name)
-			return NULL;
-	}
+	name = kstrdup_const(name, GFP_KERNEL);
+	if (!name)
+		return NULL;
 
 	kn = kmem_cache_zalloc(kernfs_node_cache, GFP_KERNEL);
 	if (!kn)
@@ -534,7 +532,7 @@ static struct kernfs_node *__kernfs_new_
  err_out2:
 	kmem_cache_free(kernfs_node_cache, kn);
  err_out1:
-	kfree_const(dup_name);
+	kfree_const(name);
 	return NULL;
 }
 
@@ -1281,9 +1279,7 @@ int kernfs_rename_ns(struct kernfs_node
 
 	kn->ns = new_ns;
 	if (new_name) {
-		if (!(kn->flags & KERNFS_STATIC_NAME))
-			old_name = kn->name;
-		kn->flags &= ~KERNFS_STATIC_NAME;
+		old_name = kn->name;
 		kn->name = new_name;
 	}
 
--- a/fs/kernfs/file.c
+++ b/fs/kernfs/file.c
@@ -901,7 +901,6 @@ const struct file_operations kernfs_file
  * @ops: kernfs operations for the file
  * @priv: private data for the file
  * @ns: optional namespace tag of the file
- * @name_is_static: don't copy file name
  * @key: lockdep key for the file's active_ref, %NULL to disable lockdep
  *
  * Returns the created node on success, ERR_PTR() value on error.
@@ -911,7 +910,6 @@ struct kernfs_node *__kernfs_create_file
 					 umode_t mode, loff_t size,
 					 const struct kernfs_ops *ops,
 					 void *priv, const void *ns,
-					 bool name_is_static,
 					 struct lock_class_key *key)
 {
 	struct kernfs_node *kn;
@@ -919,8 +917,6 @@ struct kernfs_node *__kernfs_create_file
 	int rc;
 
 	flags = KERNFS_FILE;
-	if (name_is_static)
-		flags |= KERNFS_STATIC_NAME;
 
 	kn = kernfs_new_node(parent, name, (mode & S_IALLUGO) | S_IFREG, flags);
 	if (!kn)
--- a/fs/sysfs/file.c
+++ b/fs/sysfs/file.c
@@ -295,7 +295,7 @@ int sysfs_add_file_mode_ns(struct kernfs
 		key = attr->key ?: (struct lock_class_key *)&attr->skey;
 #endif
 	kn = __kernfs_create_file(parent, attr->name, mode & 0777, size, ops,
-				  (void *)attr, ns, true, key);
+				  (void *)attr, ns, key);
 	if (IS_ERR(kn)) {
 		if (PTR_ERR(kn) == -EEXIST)
 			sysfs_warn_dup(parent, attr->name);
--- a/include/linux/kernfs.h
+++ b/include/linux/kernfs.h
@@ -43,7 +43,6 @@ enum kernfs_node_flag {
 	KERNFS_HAS_SEQ_SHOW	= 0x0040,
 	KERNFS_HAS_MMAP		= 0x0080,
 	KERNFS_LOCKDEP		= 0x0100,
-	KERNFS_STATIC_NAME	= 0x0200,
 	KERNFS_SUICIDAL		= 0x0400,
 	KERNFS_SUICIDED		= 0x0800,
 };
@@ -291,7 +290,6 @@ struct kernfs_node *__kernfs_create_file
 					 umode_t mode, loff_t size,
 					 const struct kernfs_ops *ops,
 					 void *priv, const void *ns,
-					 bool name_is_static,
 					 struct lock_class_key *key);
 struct kernfs_node *kernfs_create_link(struct kernfs_node *parent,
 				       const char *name,
@@ -369,8 +367,7 @@ kernfs_create_dir_ns(struct kernfs_node
 static inline struct kernfs_node *
 __kernfs_create_file(struct kernfs_node *parent, const char *name,
 		     umode_t mode, loff_t size, const struct kernfs_ops *ops,
-		     void *priv, const void *ns, bool name_is_static,
-		     struct lock_class_key *key)
+		     void *priv, const void *ns, struct lock_class_key *key)
 { return ERR_PTR(-ENOSYS); }
 
 static inline struct kernfs_node *
@@ -439,7 +436,7 @@ kernfs_create_file_ns(struct kernfs_node
 	key = (struct lock_class_key *)&ops->lockdep_key;
 #endif
 	return __kernfs_create_file(parent, name, mode, size, ops, priv, ns,
-				    false, key);
+				    key);
 }
 
 static inline struct kernfs_node *
--- a/kernel/cgroup.c
+++ b/kernel/cgroup.c
@@ -3077,7 +3077,7 @@ static int cgroup_add_file(struct cgroup
 #endif
 	kn = __kernfs_create_file(cgrp->kn, cgroup_file_name(cgrp, cft, name),
 				  cgroup_file_mode(cft), 0, cft->kf_ops, cft,
-				  NULL, false, key);
+				  NULL, key);
 	if (IS_ERR(kn))
 		return PTR_ERR(kn);
 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f70.google.com (mail-pg0-f70.google.com [74.125.83.70])
	by kanga.kvack.org (Postfix) with ESMTP id 9C4B9280280
	for <linux-mm@kvack.org>; Wed, 17 Jan 2018 15:23:05 -0500 (EST)
Received: by mail-pg0-f70.google.com with SMTP id k6so1238973pgt.15
        for <linux-mm@kvack.org>; Wed, 17 Jan 2018 12:23:05 -0800 (PST)
Received: from bombadil.infradead.org (bombadil.infradead.org. [65.50.211.133])
        by mx.google.com with ESMTPS id t8si4490446pgf.664.2018.01.17.12.23.03
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Wed, 17 Jan 2018 12:23:03 -0800 (PST)
From: Matthew Wilcox <willy@infradead.org>
Subject: [PATCH v6 83/99] hwspinlock: Convert to XArray
Date: Wed, 17 Jan 2018 12:21:47 -0800
Message-Id: <20180117202203.19756-84-willy@infradead.org>
In-Reply-To: <20180117202203.19756-1-willy@infradead.org>
References: <20180117202203.19756-1-willy@infradead.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: Matthew Wilcox <mawilcox@microsoft.com>, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, linux-f2fs-devel@lists.sourceforge.net, linux-nilfs@vger.kernel.org, linux-btrfs@vger.kernel.org, linux-xfs@vger.kernel.org, linux-usb@vger.kernel.org, Bjorn Andersson <bjorn.andersson@linaro.org>, Stefano Stabellini <sstabellini@kernel.org>, iommu@lists.linux-foundation.org, linux-remoteproc@vger.kernel.org, linux-s390@vger.kernel.org, intel-gfx@lists.freedesktop.org, cgroups@vger.kernel.org, linux-sh@vger.kernel.org, David Howells <dhowells@redhat.com>

From: Matthew Wilcox <mawilcox@microsoft.com>

I had to mess with the locking a bit as I converted the code from a
mutex to the xa_lock.

Signed-off-by: Matthew Wilcox <mawilcox@microsoft.com>
---
 drivers/hwspinlock/hwspinlock_core.c | 151 ++++++++++++-----------------------
 1 file changed, 52 insertions(+), 99 deletions(-)

diff --git a/drivers/hwspinlock/hwspinlock_core.c b/drivers/hwspinlock/hwspinlock_core.c
index 4074441444fe..acb6e315925f 100644
--- a/drivers/hwspinlock/hwspinlock_core.c
+++ b/drivers/hwspinlock/hwspinlock_core.c
@@ -23,43 +23,32 @@
 #include <linux/types.h>
 #include <linux/err.h>
 #include <linux/jiffies.h>
-#include <linux/radix-tree.h>
+#include <linux/xarray.h>
 #include <linux/hwspinlock.h>
 #include <linux/pm_runtime.h>
-#include <linux/mutex.h>
 #include <linux/of.h>
 
 #include "hwspinlock_internal.h"
 
-/* radix tree tags */
-#define HWSPINLOCK_UNUSED	(0) /* tags an hwspinlock as unused */
+#define HWSPINLOCK_UNUSED	XA_TAG_0
 
 /*
- * A radix tree is used to maintain the available hwspinlock instances.
- * The tree associates hwspinlock pointers with their integer key id,
+ * An xarray is used to maintain the available hwspinlock instances.
+ * The array associates hwspinlock pointers with their integer key id,
  * and provides easy-to-use API which makes the hwspinlock core code simple
  * and easy to read.
  *
- * Radix trees are quick on lookups, and reasonably efficient in terms of
+ * The XArray is quick on lookups, and reasonably efficient in terms of
  * storage, especially with high density usages such as this framework
  * requires (a continuous range of integer keys, beginning with zero, is
  * used as the ID's of the hwspinlock instances).
  *
- * The radix tree API supports tagging items in the tree, which this
- * framework uses to mark unused hwspinlock instances (see the
- * HWSPINLOCK_UNUSED tag above). As a result, the process of querying the
- * tree, looking for an unused hwspinlock instance, is now reduced to a
- * single radix tree API call.
+ * The xarray API supports tagging items, which this framework uses to mark
+ * unused hwspinlock instances (see the HWSPINLOCK_UNUSED tag above). As a
+ * result, the process of querying the array, looking for an unused
+ * hwspinlock instance, is reduced to a single call.
  */
-static RADIX_TREE(hwspinlock_tree, GFP_KERNEL);
-
-/*
- * Synchronization of access to the tree is achieved using this mutex,
- * as the radix-tree API requires that users provide all synchronisation.
- * A mutex is needed because we're using non-atomic radix tree allocations.
- */
-static DEFINE_MUTEX(hwspinlock_tree_lock);
-
+static DEFINE_XARRAY(hwspinlock_xa);
 
 /**
  * __hwspin_trylock() - attempt to lock a specific hwspinlock
@@ -294,10 +283,9 @@ of_hwspin_lock_simple_xlate(const struct of_phandle_args *hwlock_spec)
  */
 int of_hwspin_lock_get_id(struct device_node *np, int index)
 {
+	XA_STATE(xas, &hwspinlock_xa, 0);
 	struct of_phandle_args args;
 	struct hwspinlock *hwlock;
-	struct radix_tree_iter iter;
-	void **slot;
 	int id;
 	int ret;
 
@@ -309,22 +297,15 @@ int of_hwspin_lock_get_id(struct device_node *np, int index)
 	/* Find the hwspinlock device: we need its base_id */
 	ret = -EPROBE_DEFER;
 	rcu_read_lock();
-	radix_tree_for_each_slot(slot, &hwspinlock_tree, &iter, 0) {
-		hwlock = radix_tree_deref_slot(slot);
-		if (unlikely(!hwlock))
-			continue;
-		if (radix_tree_deref_retry(hwlock)) {
-			slot = radix_tree_iter_retry(&iter);
+	xas_for_each(&xas, hwlock, ULONG_MAX) {
+		if (xas_retry(&xas, hwlock))
 			continue;
-		}
 
-		if (hwlock->bank->dev->of_node == args.np) {
-			ret = 0;
+		if (hwlock->bank->dev->of_node == args.np)
 			break;
-		}
 	}
 	rcu_read_unlock();
-	if (ret < 0)
+	if (!hwlock)
 		goto out;
 
 	id = of_hwspin_lock_simple_xlate(&args);
@@ -332,6 +313,7 @@ int of_hwspin_lock_get_id(struct device_node *np, int index)
 		ret = -EINVAL;
 		goto out;
 	}
+	ret = 0;
 	id += hwlock->bank->base_id;
 
 out:
@@ -342,26 +324,19 @@ EXPORT_SYMBOL_GPL(of_hwspin_lock_get_id);
 
 static int hwspin_lock_register_single(struct hwspinlock *hwlock, int id)
 {
-	struct hwspinlock *tmp;
-	int ret;
+	void *curr;
 
-	mutex_lock(&hwspinlock_tree_lock);
-
-	ret = radix_tree_insert(&hwspinlock_tree, id, hwlock);
-	if (ret) {
-		if (ret == -EEXIST)
+	curr = xa_cmpxchg(&hwspinlock_xa, id, NULL, hwlock, GFP_KERNEL);
+	if (curr) {
+		if (!xa_is_err(curr))
 			pr_err("hwspinlock id %d already exists!\n", id);
 		goto out;
 	}
 
 	/* mark this hwspinlock as available */
-	tmp = radix_tree_tag_set(&hwspinlock_tree, id, HWSPINLOCK_UNUSED);
-
-	/* self-sanity check which should never fail */
-	WARN_ON(tmp != hwlock);
+	xa_set_tag(&hwspinlock_xa, id, HWSPINLOCK_UNUSED);
 
 out:
-	mutex_unlock(&hwspinlock_tree_lock);
 	return 0;
 }
 
@@ -370,23 +345,16 @@ static struct hwspinlock *hwspin_lock_unregister_single(unsigned int id)
 	struct hwspinlock *hwlock = NULL;
 	int ret;
 
-	mutex_lock(&hwspinlock_tree_lock);
-
 	/* make sure the hwspinlock is not in use (tag is set) */
-	ret = radix_tree_tag_get(&hwspinlock_tree, id, HWSPINLOCK_UNUSED);
+	ret = xa_get_tag(&hwspinlock_xa, id, HWSPINLOCK_UNUSED);
 	if (ret == 0) {
 		pr_err("hwspinlock %d still in use (or not present)\n", id);
 		goto out;
 	}
 
-	hwlock = radix_tree_delete(&hwspinlock_tree, id);
-	if (!hwlock) {
-		pr_err("failed to delete hwspinlock %d\n", id);
-		goto out;
-	}
+	hwlock = xa_erase(&hwspinlock_xa, id);
 
 out:
-	mutex_unlock(&hwspinlock_tree_lock);
 	return hwlock;
 }
 
@@ -477,8 +445,7 @@ EXPORT_SYMBOL_GPL(hwspin_lock_unregister);
  * __hwspin_lock_request() - tag an hwspinlock as used and power it up
  *
  * This is an internal function that prepares an hwspinlock instance
- * before it is given to the user. The function assumes that
- * hwspinlock_tree_lock is taken.
+ * before it is given to the user.
  *
  * Returns 0 or positive to indicate success, and a negative value to
  * indicate an error (with the appropriate error code)
@@ -486,7 +453,6 @@ EXPORT_SYMBOL_GPL(hwspin_lock_unregister);
 static int __hwspin_lock_request(struct hwspinlock *hwlock)
 {
 	struct device *dev = hwlock->bank->dev;
-	struct hwspinlock *tmp;
 	int ret;
 
 	/* prevent underlying implementation from being removed */
@@ -501,16 +467,7 @@ static int __hwspin_lock_request(struct hwspinlock *hwlock)
 		dev_err(dev, "%s: can't power on device\n", __func__);
 		pm_runtime_put_noidle(dev);
 		module_put(dev->driver->owner);
-		return ret;
 	}
-
-	/* mark hwspinlock as used, should not fail */
-	tmp = radix_tree_tag_clear(&hwspinlock_tree, hwlock_to_id(hwlock),
-							HWSPINLOCK_UNUSED);
-
-	/* self-sanity check that should never fail */
-	WARN_ON(tmp != hwlock);
-
 	return ret;
 }
 
@@ -548,29 +505,28 @@ struct hwspinlock *hwspin_lock_request(void)
 {
 	struct hwspinlock *hwlock;
 	int ret;
+	unsigned long index = 0;
 
-	mutex_lock(&hwspinlock_tree_lock);
+	xa_lock(&hwspinlock_xa);
 
 	/* look for an unused lock */
-	ret = radix_tree_gang_lookup_tag(&hwspinlock_tree, (void **)&hwlock,
-						0, 1, HWSPINLOCK_UNUSED);
-	if (ret == 0) {
+	hwlock = xa_find(&hwspinlock_xa, &index, ULONG_MAX, HWSPINLOCK_UNUSED);
+	if (!hwlock) {
 		pr_warn("a free hwspinlock is not available\n");
-		hwlock = NULL;
-		goto out;
+		xa_unlock(&hwspinlock_xa);
+		return NULL;
 	}
 
-	/* sanity check that should never fail */
-	WARN_ON(ret > 1);
-
 	/* mark as used and power up */
+	__xa_clear_tag(&hwspinlock_xa, index, HWSPINLOCK_UNUSED);
+	xa_unlock(&hwspinlock_xa);
+
 	ret = __hwspin_lock_request(hwlock);
-	if (ret < 0)
-		hwlock = NULL;
+	if (ret == 0)
+		return hwlock;
 
-out:
-	mutex_unlock(&hwspinlock_tree_lock);
-	return hwlock;
+	xa_set_tag(&hwspinlock_xa, index, HWSPINLOCK_UNUSED);
+	return NULL;
 }
 EXPORT_SYMBOL_GPL(hwspin_lock_request);
 
@@ -592,10 +548,10 @@ struct hwspinlock *hwspin_lock_request_specific(unsigned int id)
 	struct hwspinlock *hwlock;
 	int ret;
 
-	mutex_lock(&hwspinlock_tree_lock);
+	xa_lock(&hwspinlock_xa);
 
 	/* make sure this hwspinlock exists */
-	hwlock = radix_tree_lookup(&hwspinlock_tree, id);
+	hwlock = xa_load(&hwspinlock_xa, id);
 	if (!hwlock) {
 		pr_warn("hwspinlock %u does not exist\n", id);
 		goto out;
@@ -605,21 +561,25 @@ struct hwspinlock *hwspin_lock_request_specific(unsigned int id)
 	WARN_ON(hwlock_to_id(hwlock) != id);
 
 	/* make sure this hwspinlock is unused */
-	ret = radix_tree_tag_get(&hwspinlock_tree, id, HWSPINLOCK_UNUSED);
+	ret = xa_get_tag(&hwspinlock_xa, id, HWSPINLOCK_UNUSED);
 	if (ret == 0) {
 		pr_warn("hwspinlock %u is already in use\n", id);
-		hwlock = NULL;
 		goto out;
 	}
 
 	/* mark as used and power up */
+	__xa_clear_tag(&hwspinlock_xa, id, HWSPINLOCK_UNUSED);
+	xa_unlock(&hwspinlock_xa);
+
 	ret = __hwspin_lock_request(hwlock);
-	if (ret < 0)
-		hwlock = NULL;
+	if (ret == 0)
+		return hwlock;
 
+	xa_set_tag(&hwspinlock_xa, id, HWSPINLOCK_UNUSED);
+	return NULL;
 out:
-	mutex_unlock(&hwspinlock_tree_lock);
-	return hwlock;
+	xa_unlock(&hwspinlock_xa);
+	return NULL;
 }
 EXPORT_SYMBOL_GPL(hwspin_lock_request_specific);
 
@@ -638,7 +598,6 @@ EXPORT_SYMBOL_GPL(hwspin_lock_request_specific);
 int hwspin_lock_free(struct hwspinlock *hwlock)
 {
 	struct device *dev;
-	struct hwspinlock *tmp;
 	int ret;
 
 	if (!hwlock) {
@@ -647,12 +606,11 @@ int hwspin_lock_free(struct hwspinlock *hwlock)
 	}
 
 	dev = hwlock->bank->dev;
-	mutex_lock(&hwspinlock_tree_lock);
 
 	/* make sure the hwspinlock is used */
-	ret = radix_tree_tag_get(&hwspinlock_tree, hwlock_to_id(hwlock),
+	ret = xa_get_tag(&hwspinlock_xa, hwlock_to_id(hwlock),
 							HWSPINLOCK_UNUSED);
-	if (ret == 1) {
+	if (ret) {
 		dev_err(dev, "%s: hwlock is already free\n", __func__);
 		dump_stack();
 		ret = -EINVAL;
@@ -665,16 +623,11 @@ int hwspin_lock_free(struct hwspinlock *hwlock)
 		goto out;
 
 	/* mark this hwspinlock as available */
-	tmp = radix_tree_tag_set(&hwspinlock_tree, hwlock_to_id(hwlock),
-							HWSPINLOCK_UNUSED);
-
-	/* sanity check (this shouldn't happen) */
-	WARN_ON(tmp != hwlock);
+	xa_set_tag(&hwspinlock_xa, hwlock_to_id(hwlock), HWSPINLOCK_UNUSED);
 
 	module_put(dev->driver->owner);
 
 out:
-	mutex_unlock(&hwspinlock_tree_lock);
 	return ret;
 }
 EXPORT_SYMBOL_GPL(hwspin_lock_free);
-- 
2.15.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

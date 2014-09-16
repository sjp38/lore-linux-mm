Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-we0-f174.google.com (mail-we0-f174.google.com [74.125.82.174])
	by kanga.kvack.org (Postfix) with ESMTP id 800AD6B0036
	for <linux-mm@kvack.org>; Tue, 16 Sep 2014 05:10:22 -0400 (EDT)
Received: by mail-we0-f174.google.com with SMTP id t60so5343427wes.19
        for <linux-mm@kvack.org>; Tue, 16 Sep 2014 02:10:20 -0700 (PDT)
Received: from Galois.linutronix.de (Galois.linutronix.de. [2001:470:1f0b:db:abcd:42:0:1])
        by mx.google.com with ESMTPS id dj6si1381051wib.105.2014.09.16.02.10.17
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=RC4-SHA bits=128/128);
        Tue, 16 Sep 2014 02:10:17 -0700 (PDT)
Date: Tue, 16 Sep 2014 11:10:11 +0200
From: Sebastian Andrzej Siewior <bigeasy@linutronix.de>
Subject: [PATCH v2] mm: dmapool: add/remove sysfs file outside of the pool
 lock lock
Message-ID: <20140916091011.GA1948@linutronix.de>
References: <1410463876-21265-1-git-send-email-bigeasy@linutronix.de>
 <20140912161317.f38c0d2c3b589aea94bdb870@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable
In-Reply-To: <20140912161317.f38c0d2c3b589aea94bdb870@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org

cat /sys/=E2=80=A6/pools followed by removal the device leads to:

|=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D
|[ INFO: possible circular locking dependency detected ]
|3.17.0-rc4+ #1498 Not tainted
|-------------------------------------------------------
|rmmod/2505 is trying to acquire lock:
| (s_active#28){++++.+}, at: [<c017f754>] kernfs_remove_by_name_ns+0x3c/0x88
|
|but task is already holding lock:
| (pools_lock){+.+.+.}, at: [<c011494c>] dma_pool_destroy+0x18/0x17c
|
|which lock already depends on the new lock.
|the existing dependency chain (in reverse order) is:
|
|-> #1 (pools_lock){+.+.+.}:
|   [<c0114ae8>] show_pools+0x30/0xf8
|   [<c0313210>] dev_attr_show+0x1c/0x48
|   [<c0180e84>] sysfs_kf_seq_show+0x88/0x10c
|   [<c017f960>] kernfs_seq_show+0x24/0x28
|   [<c013efc4>] seq_read+0x1b8/0x480
|   [<c011e820>] vfs_read+0x8c/0x148
|   [<c011ea10>] SyS_read+0x40/0x8c
|   [<c000e960>] ret_fast_syscall+0x0/0x48
|
|-> #0 (s_active#28){++++.+}:
|   [<c017e9ac>] __kernfs_remove+0x258/0x2ec
|   [<c017f754>] kernfs_remove_by_name_ns+0x3c/0x88
|   [<c0114a7c>] dma_pool_destroy+0x148/0x17c
|   [<c03ad288>] hcd_buffer_destroy+0x20/0x34
|   [<c03a4780>] usb_remove_hcd+0x110/0x1a4

The problem is the lock order of pools_lock and kernfs_mutex in
dma_pool_destroy() vs show_pools() call path.

This patch breaks out the creation of the sysfs file outside of the
pools_lock mutex. The newly added pools_reg_lock ensures that there is
no race of create vs destroy code path in terms whether or not the sysfs
file has to be deleted (and was it deleted before we try to create a new
one) and what to do if device_create_file() failed.

Signed-off-by: Sebastian Andrzej Siewior <bigeasy@linutronix.de>
---
 mm/dmapool.c | 43 +++++++++++++++++++++++++++++++++++--------
 1 file changed, 35 insertions(+), 8 deletions(-)

diff --git a/mm/dmapool.c b/mm/dmapool.c
index 306baa594f95..2372ed5a33d3 100644
--- a/mm/dmapool.c
+++ b/mm/dmapool.c
@@ -62,6 +62,7 @@ struct dma_page {		/* cacheable header for 'allocation' b=
ytes */
 };
=20
 static DEFINE_MUTEX(pools_lock);
+static DEFINE_MUTEX(pools_reg_lock);
=20
 static ssize_t
 show_pools(struct device *dev, struct device_attribute *attr, char *buf)
@@ -132,6 +133,7 @@ struct dma_pool *dma_pool_create(const char *name, stru=
ct device *dev,
 {
 	struct dma_pool *retval;
 	size_t allocation;
+	bool empty =3D false;
=20
 	if (align =3D=3D 0) {
 		align =3D 1;
@@ -172,15 +174,34 @@ struct dma_pool *dma_pool_create(const char *name, st=
ruct device *dev,
=20
 	INIT_LIST_HEAD(&retval->pools);
=20
+	/*
+	 * pools_lock ensures that the ->dma_pools list does not get corrupted.
+	 * pools_reg_lock ensures that there is not a race between
+	 * dma_pool_create() and dma_pool_destroy() or within dma_pool_create()
+	 * when the first invocation of dma_pool_create() failed on
+	 * device_create_file() and the second assumes that it has been done (I
+	 * know it is a short window).
+	 */
+	mutex_lock(&pools_reg_lock);
 	mutex_lock(&pools_lock);
-	if (list_empty(&dev->dma_pools) &&
-	    device_create_file(dev, &dev_attr_pools)) {
-		kfree(retval);
-		return NULL;
-	} else
-		list_add(&retval->pools, &dev->dma_pools);
+	if (list_empty(&dev->dma_pools))
+		empty =3D true;
+	list_add(&retval->pools, &dev->dma_pools);
 	mutex_unlock(&pools_lock);
-
+	if (empty) {
+		int err;
+
+		err =3D device_create_file(dev, &dev_attr_pools);
+		if (err) {
+			mutex_lock(&pools_lock);
+			list_del(&retval->pools);
+			mutex_unlock(&pools_lock);
+			mutex_unlock(&pools_reg_lock);
+			kfree(retval);
+			return NULL;
+		}
+	}
+	mutex_unlock(&pools_reg_lock);
 	return retval;
 }
 EXPORT_SYMBOL(dma_pool_create);
@@ -251,11 +272,17 @@ static void pool_free_page(struct dma_pool *pool, str=
uct dma_page *page)
  */
 void dma_pool_destroy(struct dma_pool *pool)
 {
+	bool empty =3D false;
+
+	mutex_lock(&pools_reg_lock);
 	mutex_lock(&pools_lock);
 	list_del(&pool->pools);
 	if (pool->dev && list_empty(&pool->dev->dma_pools))
-		device_remove_file(pool->dev, &dev_attr_pools);
+		empty =3D true;
 	mutex_unlock(&pools_lock);
+	if (empty)
+		device_remove_file(pool->dev, &dev_attr_pools);
+	mutex_unlock(&pools_reg_lock);
=20
 	while (!list_empty(&pool->page_list)) {
 		struct dma_page *page;
--=20
2.1.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

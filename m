Received: from e33.co.us.ibm.com (e33.boulder.ibm.com [9.17.249.43])
	by pokfb.esmtp.ibm.com (8.12.11/8.12.11) with ESMTP id k0PLbRdI010592
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=OK)
	for <linux-mm@kvack.org>; Wed, 25 Jan 2006 16:37:28 -0500
Received: from d03relay04.boulder.ibm.com (d03relay04.boulder.ibm.com [9.17.195.106])
	by e33.co.us.ibm.com (8.12.11/8.12.11) with ESMTP id k0PLbCN4003885
	for <linux-mm@kvack.org>; Wed, 25 Jan 2006 16:37:12 -0500
Received: from d03av02.boulder.ibm.com (d03av02.boulder.ibm.com [9.17.195.168])
	by d03relay04.boulder.ibm.com (8.12.10/NCO/VERS6.8) with ESMTP id k0PLdNfL175272
	for <linux-mm@kvack.org>; Wed, 25 Jan 2006 14:39:28 -0700
Received: from d03av02.boulder.ibm.com (loopback [127.0.0.1])
	by d03av02.boulder.ibm.com (8.12.11/8.13.3) with ESMTP id k0PLb7mB011437
	for <linux-mm@kvack.org>; Wed, 25 Jan 2006 14:37:07 -0700
Subject: [patch 6/9] mempool - Update kzalloc mempool users
From: Matthew Dobson <colpatch@us.ibm.com>
Reply-To: colpatch@us.ibm.com
References: <20060125161321.647368000@localhost.localdomain>
Content-Type: text/plain
Date: Wed, 25 Jan 2006 11:40:14 -0800
Message-Id: <1138218014.2092.6.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-kernel@vger.kernel.org
Cc: sri@us.ibm.com, andrea@suse.de, pavel@suse.cz, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

plain text document attachment (critical_mempools)
Fixup existing mempool users to use the new mempool API, part 3.

This mempool users which are basically just wrappers around kzalloc().  To do
this we create a new function, kzalloc_node() and change all the old mempool
allocators which were calling kzalloc() to now call kzalloc_node().

A couple of trivial whitespace fixes are included.

Signed-off-by: Matthew Dobson <colpatch@us.ibm.com>

 drivers/md/multipath.c |    6 ++----
 drivers/md/raid1.c     |    9 ++++-----
 drivers/md/raid10.c    |    8 ++++----
 include/linux/slab.h   |    2 ++
 mm/util.c              |   13 ++++++++++---
 5 files changed, 22 insertions(+), 16 deletions(-)

Index: linux-2.6.16-rc1+critical_mempools/mm/util.c
===================================================================
--- linux-2.6.16-rc1+critical_mempools.orig/mm/util.c
+++ linux-2.6.16-rc1+critical_mempools/mm/util.c
@@ -3,17 +3,24 @@
 #include <linux/module.h>
 
 /**
- * kzalloc - allocate memory. The memory is set to zero.
+ * kzalloc_node - allocate memory. The memory is set to zero.
  * @size: how many bytes of memory are required.
  * @flags: the type of memory to allocate.
+ * @node_id: where (which node) to allocate the memory
  */
-void *kzalloc(size_t size, gfp_t flags)
+void *kzalloc_node(size_t size, gfp_t flags, int node_id)
 {
-	void *ret = kmalloc(size, flags);
+	void *ret = kmalloc_node(size, flags, node_id);
 	if (ret)
 		memset(ret, 0, size);
 	return ret;
 }
+EXPORT_SYMBOL(kzalloc_node);
+
+void *kzalloc(size_t size, gfp_t flags)
+{
+	return kzalloc_node(size, flags, -1);
+}
 EXPORT_SYMBOL(kzalloc);
 
 /*
Index: linux-2.6.16-rc1+critical_mempools/include/linux/slab.h
===================================================================
--- linux-2.6.16-rc1+critical_mempools.orig/include/linux/slab.h
+++ linux-2.6.16-rc1+critical_mempools/include/linux/slab.h
@@ -101,6 +101,7 @@ found:
 	return __kmalloc(size, flags);
 }
 
+extern void *kzalloc_node(size_t, gfp_t, int);
 extern void *kzalloc(size_t, gfp_t);
 
 /**
@@ -151,6 +152,7 @@ void *kmem_cache_alloc(struct kmem_cache
 void kmem_cache_free(struct kmem_cache *c, void *b);
 const char *kmem_cache_name(struct kmem_cache *);
 void *kmalloc(size_t size, gfp_t flags);
+void *kzalloc_node(size_t size, gfp_t flags, int node_id);
 void *kzalloc(size_t size, gfp_t flags);
 void kfree(const void *m);
 unsigned int ksize(const void *m);
Index: linux-2.6.16-rc1+critical_mempools/drivers/md/multipath.c
===================================================================
--- linux-2.6.16-rc1+critical_mempools.orig/drivers/md/multipath.c
+++ linux-2.6.16-rc1+critical_mempools/drivers/md/multipath.c
@@ -35,11 +35,9 @@
 #define	NR_RESERVED_BUFS	32
 

-static void *mp_pool_alloc(gfp_t gfp_flags, void *data)
+static void *mp_pool_alloc(gfp_t gfp_flags, int node_id, void *data)
 {
-	struct multipath_bh *mpb;
-	mpb = kzalloc(sizeof(*mpb), gfp_flags);
-	return mpb;
+	return kzalloc_node(sizeof(struct multipath_bh), gfp_flags, node_id);
 }
 
 static void mp_pool_free(void *mpb, void *data)
Index: linux-2.6.16-rc1+critical_mempools/drivers/md/raid10.c
===================================================================
--- linux-2.6.16-rc1+critical_mempools.orig/drivers/md/raid10.c
+++ linux-2.6.16-rc1+critical_mempools/drivers/md/raid10.c
@@ -52,14 +52,14 @@ static void unplug_slaves(mddev_t *mddev
 static void allow_barrier(conf_t *conf);
 static void lower_barrier(conf_t *conf);
 
-static void * r10bio_pool_alloc(gfp_t gfp_flags, void *data)
+static void *r10bio_pool_alloc(gfp_t gfp_flags, int node_id, void *data)
 {
 	conf_t *conf = data;
 	r10bio_t *r10_bio;
 	int size = offsetof(struct r10bio_s, devs[conf->copies]);
 
 	/* allocate a r10bio with room for raid_disks entries in the bios array */
-	r10_bio = kzalloc(size, gfp_flags);
+	r10_bio = kzalloc_node(size, gfp_flags, node_id);
 	if (!r10_bio)
 		unplug_slaves(conf->mddev);
 
@@ -93,7 +93,7 @@ static void * r10buf_pool_alloc(gfp_t gf
 	int i, j;
 	int nalloc;
 
-	r10_bio = r10bio_pool_alloc(gfp_flags, conf);
+	r10_bio = r10bio_pool_alloc(gfp_flags, -1, conf);
 	if (!r10_bio) {
 		unplug_slaves(conf->mddev);
 		return NULL;
@@ -1949,7 +1949,7 @@ static int run(mddev_t *mddev)
 	conf->stride = stride << conf->chunk_shift;
 
 	conf->r10bio_pool = mempool_create(NR_RAID10_BIOS, r10bio_pool_alloc,
-						r10bio_pool_free, conf);
+					   r10bio_pool_free, conf);
 	if (!conf->r10bio_pool) {
 		printk(KERN_ERR "raid10: couldn't allocate memory for %s\n",
 			mdname(mddev));
Index: linux-2.6.16-rc1+critical_mempools/drivers/md/raid1.c
===================================================================
--- linux-2.6.16-rc1+critical_mempools.orig/drivers/md/raid1.c
+++ linux-2.6.16-rc1+critical_mempools/drivers/md/raid1.c
@@ -53,14 +53,14 @@ static void unplug_slaves(mddev_t *mddev
 static void allow_barrier(conf_t *conf);
 static void lower_barrier(conf_t *conf);
 
-static void * r1bio_pool_alloc(gfp_t gfp_flags, void *data)
+static void *r1bio_pool_alloc(gfp_t gfp_flags, int node_id, void *data)
 {
 	struct pool_info *pi = data;
 	r1bio_t *r1_bio;
 	int size = offsetof(r1bio_t, bios[pi->raid_disks]);
 
 	/* allocate a r1bio with room for raid_disks entries in the bios array */
-	r1_bio = kzalloc(size, gfp_flags);
+	r1_bio = kzalloc_node(size, gfp_flags, node_id);
 	if (!r1_bio)
 		unplug_slaves(pi->mddev);
 
@@ -86,7 +86,7 @@ static void * r1buf_pool_alloc(gfp_t gfp
 	struct bio *bio;
 	int i, j;
 
-	r1_bio = r1bio_pool_alloc(gfp_flags, pi);
+	r1_bio = r1bio_pool_alloc(gfp_flags, -1, pi);
 	if (!r1_bio) {
 		unplug_slaves(pi->mddev);
 		return NULL;
@@ -1811,8 +1811,7 @@ static int run(mddev_t *mddev)
 	conf->poolinfo->mddev = mddev;
 	conf->poolinfo->raid_disks = mddev->raid_disks;
 	conf->r1bio_pool = mempool_create(NR_RAID1_BIOS, r1bio_pool_alloc,
-					  r1bio_pool_free,
-					  conf->poolinfo);
+					  r1bio_pool_free, conf->poolinfo);
 	if (!conf->r1bio_pool)
 		goto out_no_mem;
 

--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

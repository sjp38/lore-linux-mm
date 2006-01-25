Received: from d03relay04.boulder.ibm.com (d03relay04.boulder.ibm.com [9.17.195.106])
	by e32.co.us.ibm.com (8.12.11/8.12.11) with ESMTP id k0PNpejL019179
	for <linux-mm@kvack.org>; Wed, 25 Jan 2006 18:51:40 -0500
Received: from d03av02.boulder.ibm.com (d03av02.boulder.ibm.com [9.17.195.168])
	by d03relay04.boulder.ibm.com (8.12.10/NCO/VERS6.8) with ESMTP id k0PNrufL178158
	for <linux-mm@kvack.org>; Wed, 25 Jan 2006 16:53:56 -0700
Received: from d03av02.boulder.ibm.com (loopback [127.0.0.1])
	by d03av02.boulder.ibm.com (8.12.11/8.13.3) with ESMTP id k0PNpe4e029982
	for <linux-mm@kvack.org>; Wed, 25 Jan 2006 16:51:40 -0700
Subject: [patch 7/9] mempool - Update other mempool users
From: Matthew Dobson <colpatch@us.ibm.com>
Reply-To: colpatch@us.ibm.com
References: <20060125161321.647368000@localhost.localdomain>
Content-Type: text/plain
Date: Wed, 25 Jan 2006 15:51:39 -0800
Message-Id: <1138233099.27293.2.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-kernel@vger.kernel.org
Cc: sri@us.ibm.com, andrea@suse.de, pavel@suse.cz, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

plain text document attachment (critical_mempools)
Fixup existing mempool users to use the new mempool API, part 4.

This patch papers over the three remaining mempool users that are non-trivial
to change over to the new API.  We simply add an UNUSED_NID argument to their
mempool_alloc functions to match the new API.  None of these mempools appear to
support NUMA in any way, so this should not cause any problems.

If anyone familiar with the code involved would like to send proper fixes,
that would be greatly appreciated.

Signed-off-by: Matthew Dobson <colpatch@us.ibm.com>

 md/raid1.c                  |    8 ++++----
 md/raid10.c                 |    7 ++++---
 scsi/scsi_transport_iscsi.c |    4 ++--
 3 files changed, 10 insertions(+), 9 deletions(-)

Index: linux-2.6.16-rc1+critical_mempools/drivers/md/raid10.c
===================================================================
--- linux-2.6.16-rc1+critical_mempools.orig/drivers/md/raid10.c
+++ linux-2.6.16-rc1+critical_mempools/drivers/md/raid10.c
@@ -84,7 +84,7 @@ static void r10bio_pool_free(void *r10_b
  * one for write (we recover only one drive per r10buf)
  *
  */
-static void * r10buf_pool_alloc(gfp_t gfp_flags, void *data)
+static void *r10buf_pool_alloc(gfp_t gfp_flags, int UNUSED_NID, void *data)
 {
 	conf_t *conf = data;
 	struct page *page;
@@ -93,7 +93,7 @@ static void * r10buf_pool_alloc(gfp_t gf
 	int i, j;
 	int nalloc;
 
-	r10_bio = r10bio_pool_alloc(gfp_flags, -1, conf);
+	r10_bio = r10bio_pool_alloc(gfp_flags, UNUSED_NID, conf);
 	if (!r10_bio) {
 		unplug_slaves(conf->mddev);
 		return NULL;
@@ -1518,7 +1518,8 @@ static int init_resync(conf_t *conf)
 	buffs = RESYNC_WINDOW / RESYNC_BLOCK_SIZE;
 	if (conf->r10buf_pool)
 		BUG();
-	conf->r10buf_pool = mempool_create(buffs, r10buf_pool_alloc, r10buf_pool_free, conf);
+	conf->r10buf_pool = mempool_create(buffs, r10buf_pool_alloc,
+					   r10buf_pool_free, conf);
 	if (!conf->r10buf_pool)
 		return -ENOMEM;
 	conf->next_resync = 0;
Index: linux-2.6.16-rc1+critical_mempools/drivers/md/raid1.c
===================================================================
--- linux-2.6.16-rc1+critical_mempools.orig/drivers/md/raid1.c
+++ linux-2.6.16-rc1+critical_mempools/drivers/md/raid1.c
@@ -78,7 +78,7 @@ static void r1bio_pool_free(void *r1_bio
 #define RESYNC_PAGES ((RESYNC_BLOCK_SIZE + PAGE_SIZE-1) / PAGE_SIZE)
 #define RESYNC_WINDOW (2048*1024)
 
-static void * r1buf_pool_alloc(gfp_t gfp_flags, void *data)
+static void *r1buf_pool_alloc(gfp_t gfp_flags, int UNUSED_NID, void *data)
 {
 	struct pool_info *pi = data;
 	struct page *page;
@@ -86,7 +86,7 @@ static void * r1buf_pool_alloc(gfp_t gfp
 	struct bio *bio;
 	int i, j;
 
-	r1_bio = r1bio_pool_alloc(gfp_flags, -1, pi);
+	r1_bio = r1bio_pool_alloc(gfp_flags, UNUSED_NID, pi);
 	if (!r1_bio) {
 		unplug_slaves(pi->mddev);
 		return NULL;
@@ -1543,8 +1543,8 @@ static int init_resync(conf_t *conf)
 	buffs = RESYNC_WINDOW / RESYNC_BLOCK_SIZE;
 	if (conf->r1buf_pool)
 		BUG();
-	conf->r1buf_pool = mempool_create(buffs, r1buf_pool_alloc, r1buf_pool_free,
-					  conf->poolinfo);
+	conf->r1buf_pool = mempool_create(buffs, r1buf_pool_alloc,
+					  r1buf_pool_free, conf->poolinfo);
 	if (!conf->r1buf_pool)
 		return -ENOMEM;
 	conf->next_resync = 0;
Index: linux-2.6.16-rc1+critical_mempools/drivers/scsi/scsi_transport_iscsi.c
===================================================================
--- linux-2.6.16-rc1+critical_mempools.orig/drivers/scsi/scsi_transport_iscsi.c
+++ linux-2.6.16-rc1+critical_mempools/drivers/scsi/scsi_transport_iscsi.c
@@ -462,8 +462,8 @@ static inline struct list_head *skb_to_l
 	return (struct list_head *)&skb->cb;
 }
 
-static void*
-mempool_zone_alloc_skb(unsigned int gfp_mask, void *pool_data)
+static void *
+mempool_zone_alloc_skb(unsigned int gfp_mask, int UNUSED_NID, void *pool_data)
 {
 	struct mempool_zone *zone = pool_data;
 

--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

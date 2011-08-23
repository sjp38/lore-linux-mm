Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id 814066B0169
	for <linux-mm@kvack.org>; Tue, 23 Aug 2011 12:06:56 -0400 (EDT)
Received: from d01relay05.pok.ibm.com (d01relay05.pok.ibm.com [9.56.227.237])
	by e5.ny.us.ibm.com (8.14.4/8.13.1) with ESMTP id p7NFatv3010616
	for <linux-mm@kvack.org>; Tue, 23 Aug 2011 11:36:55 -0400
Received: from d01av03.pok.ibm.com (d01av03.pok.ibm.com [9.56.224.217])
	by d01relay05.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id p7NG6rwh161212
	for <linux-mm@kvack.org>; Tue, 23 Aug 2011 12:06:53 -0400
Received: from d01av03.pok.ibm.com (loopback [127.0.0.1])
	by d01av03.pok.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id p7NC6dkx024926
	for <linux-mm@kvack.org>; Tue, 23 Aug 2011 09:06:40 -0300
From: Seth Jennings <sjenning@linux.vnet.ibm.com>
Subject: [PATCH] staging: zcache: fix highmem crash on 32-bit
Date: Tue, 23 Aug 2011 11:06:30 -0500
Message-Id: <1314115590-20942-1-git-send-email-sjenning@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: gregkh@suse.de
Cc: cascardo@holoscopio.com, dan.magenheimer@oracle.com, rdunlap@xenotime.net, devel@driverdev.osuosl.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Seth Jennings <sjenning@linux.vnet.ibm.com>

After commit 966b9016a1, zcache_put_page() was modified to pass
page_address(page) instead of the actual page pointer. In
combination with the function signature changes to tmem_put()
and zcache_pampd_create(), zcache_pampd_create() tries to (re)derive
the page structure from the virtual address.  However, if the
original page is a high memory page (or any unmapped page),
this virt_to_page() fails because the page_address() in
zcache_put_page() returned NULL.

This patch changes zcache_put_page() and zcache_get_page() to pass
the page structure instead of the page's virtual address, which
may or may not exist.

Signed-off-by: Seth Jennings <sjenning@linux.vnet.ibm.com>
---
 drivers/staging/zcache/zcache-main.c |    8 ++++----
 1 files changed, 4 insertions(+), 4 deletions(-)

diff --git a/drivers/staging/zcache/zcache-main.c b/drivers/staging/zcache/zcache-main.c
index 855a5bb..a3f5162 100644
--- a/drivers/staging/zcache/zcache-main.c
+++ b/drivers/staging/zcache/zcache-main.c
@@ -1158,7 +1158,7 @@ static void *zcache_pampd_create(char *data, size_t size, bool raw, int eph,
 	size_t clen;
 	int ret;
 	unsigned long count;
-	struct page *page = virt_to_page(data);
+	struct page *page = (struct page *)(data);
 	struct zcache_client *cli = pool->client;
 	uint16_t client_id = get_client_id_from_client(cli);
 	unsigned long zv_mean_zsize;
@@ -1227,7 +1227,7 @@ static int zcache_pampd_get_data(char *data, size_t *bufsize, bool raw,
 	int ret = 0;
 
 	BUG_ON(is_ephemeral(pool));
-	zv_decompress(virt_to_page(data), pampd);
+	zv_decompress((struct page *)(data), pampd);
 	return ret;
 }
 
@@ -1539,7 +1539,7 @@ static int zcache_put_page(int cli_id, int pool_id, struct tmem_oid *oidp,
 		goto out;
 	if (!zcache_freeze && zcache_do_preload(pool) == 0) {
 		/* preload does preempt_disable on success */
-		ret = tmem_put(pool, oidp, index, page_address(page),
+		ret = tmem_put(pool, oidp, index, (char *)(page),
 				PAGE_SIZE, 0, is_ephemeral(pool));
 		if (ret < 0) {
 			if (is_ephemeral(pool))
@@ -1572,7 +1572,7 @@ static int zcache_get_page(int cli_id, int pool_id, struct tmem_oid *oidp,
 	pool = zcache_get_pool_by_id(cli_id, pool_id);
 	if (likely(pool != NULL)) {
 		if (atomic_read(&pool->obj_count) > 0)
-			ret = tmem_get(pool, oidp, index, page_address(page),
+			ret = tmem_get(pool, oidp, index, (char *)(page),
 					&size, 0, is_ephemeral(pool));
 		zcache_put_pool(pool);
 	}
-- 
1.7.4.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

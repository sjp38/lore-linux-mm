Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id 0BEC7900144
	for <linux-mm@kvack.org>; Tue, 13 Sep 2011 15:19:51 -0400 (EDT)
Received: from d03relay01.boulder.ibm.com (d03relay01.boulder.ibm.com [9.17.195.226])
	by e37.co.us.ibm.com (8.14.4/8.13.1) with ESMTP id p8DJGSb8029605
	for <linux-mm@kvack.org>; Tue, 13 Sep 2011 13:16:28 -0600
Received: from d03av06.boulder.ibm.com (d03av06.boulder.ibm.com [9.17.195.245])
	by d03relay01.boulder.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id p8DJJTFd119762
	for <linux-mm@kvack.org>; Tue, 13 Sep 2011 13:19:29 -0600
Received: from d03av06.boulder.ibm.com (loopback [127.0.0.1])
	by d03av06.boulder.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id p8DJPLbd001846
	for <linux-mm@kvack.org>; Tue, 13 Sep 2011 13:25:22 -0600
From: Seth Jennings <sjenning@linux.vnet.ibm.com>
Subject: [PATCH] staging: zcache: fix cleancache crash
Date: Tue, 13 Sep 2011 14:19:22 -0500
Message-Id: <1315941562-25422-1-git-send-email-sjenning@linux.vnet.ibm.com>
In-Reply-To: <4E6FA75A.8060308@linux.vnet.ibm.com>
References: <4E6FA75A.8060308@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: gregkh@suse.de
Cc: devel@driverdev.osuosl.org, linux-mm@kvack.org, ngupta@vflare.org, linux-kernel@vger.kernel.org, francis.moro@gmail.com, dan.magenheimer@oracle.com, Seth Jennings <sjenning@linux.vnet.ibm.com>

After commit, c5f5c4db, cleancache crashes on the first
successful get. This was caused by a remaining virt_to_page()
call in zcache_pampd_get_data_and_free() that only gets
run in the cleancache path.

The patch converts the virt_to_page() to struct page
casting like was done for other instances in c5f5c4db.

Based on 3.1-rc4

Signed-off-by: Seth Jennings <sjenning@linux.vnet.ibm.com>
---
 drivers/staging/zcache/zcache-main.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/staging/zcache/zcache-main.c b/drivers/staging/zcache/zcache-main.c
index a3f5162..462fbc2 100644
--- a/drivers/staging/zcache/zcache-main.c
+++ b/drivers/staging/zcache/zcache-main.c
@@ -1242,7 +1242,7 @@ static int zcache_pampd_get_data_and_free(char *data, size_t *bufsize, bool raw,
 	int ret = 0;
 
 	BUG_ON(!is_ephemeral(pool));
-	zbud_decompress(virt_to_page(data), pampd);
+	zbud_decompress((struct page *)(data), pampd);
 	zbud_free_and_delist((struct zbud_hdr *)pampd);
 	atomic_dec(&zcache_curr_eph_pampd_count);
 	return ret;
-- 
1.7.4.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

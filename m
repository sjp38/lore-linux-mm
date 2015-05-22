Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f181.google.com (mail-pd0-f181.google.com [209.85.192.181])
	by kanga.kvack.org (Postfix) with ESMTP id 39D986B025F
	for <linux-mm@kvack.org>; Fri, 22 May 2015 04:32:08 -0400 (EDT)
Received: by pdfh10 with SMTP id h10so14143118pdf.3
        for <linux-mm@kvack.org>; Fri, 22 May 2015 01:32:08 -0700 (PDT)
Received: from mailout2.w1.samsung.com (mailout2.w1.samsung.com. [210.118.77.12])
        by mx.google.com with ESMTPS id hn9si2390800pdb.133.2015.05.22.01.32.06
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Fri, 22 May 2015 01:32:07 -0700 (PDT)
Received: from eucpsbgm1.samsung.com (unknown [203.254.199.244])
 by mailout2.w1.samsung.com
 (Oracle Communications Messaging Server 7.0.5.31.0 64bit (built May  5 2014))
 with ESMTP id <0NOQ00JVBT1F0G80@mailout2.w1.samsung.com> for
 linux-mm@kvack.org; Fri, 22 May 2015 09:32:03 +0100 (BST)
From: Marcin Jabrzyk <m.jabrzyk@samsung.com>
Subject: [PATCH] zram: check compressor name before setting it
Date: Fri, 22 May 2015 10:31:55 +0200
Message-id: <1432283515-2005-1-git-send-email-m.jabrzyk@samsung.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: minchan@kernel.org, ngupta@vflare.org, sergey.senozhatsky.work@gmail.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org
Cc: kyungmin.park@samsung.com, Marcin Jabrzyk <m.jabrzyk@samsung.com>

Zram sysfs interface was not making any check of
proper compressor name when setting it.
Any name is accepted, but further tries of device
creation would end up with not very meaningfull error.
eg.

echo lz0 > comp_algorithm
echo 200M > disksize
echo: write error: Invalid argument

This commit fixes that behaviour with returning
EINVAL and proper error message.

Signed-off-by: Marcin Jabrzyk <m.jabrzyk@samsung.com>
---
 drivers/block/zram/zcomp.c    | 22 +++++++++++-----------
 drivers/block/zram/zcomp.h    |  1 +
 drivers/block/zram/zram_drv.c |  5 +++++
 3 files changed, 17 insertions(+), 11 deletions(-)

diff --git a/drivers/block/zram/zcomp.c b/drivers/block/zram/zcomp.c
index f1ff39a3d1c1..f81a2b5fef43 100644
--- a/drivers/block/zram/zcomp.c
+++ b/drivers/block/zram/zcomp.c
@@ -51,17 +51,6 @@ static struct zcomp_backend *backends[] = {
 	NULL
 };
 
-static struct zcomp_backend *find_backend(const char *compress)
-{
-	int i = 0;
-	while (backends[i]) {
-		if (sysfs_streq(compress, backends[i]->name))
-			break;
-		i++;
-	}
-	return backends[i];
-}
-
 static void zcomp_strm_free(struct zcomp *comp, struct zcomp_strm *zstrm)
 {
 	if (zstrm->private)
@@ -267,6 +256,17 @@ static int zcomp_strm_single_create(struct zcomp *comp)
 	return 0;
 }
 
+struct zcomp_backend *find_backend(const char *compress)
+{
+	int i = 0;
+	while (backends[i]) {
+		if (sysfs_streq(compress, backends[i]->name))
+			break;
+		i++;
+	}
+	return backends[i];
+}
+
 /* show available compressors */
 ssize_t zcomp_available_show(const char *comp, char *buf)
 {
diff --git a/drivers/block/zram/zcomp.h b/drivers/block/zram/zcomp.h
index c59d1fca72c0..a531350858d0 100644
--- a/drivers/block/zram/zcomp.h
+++ b/drivers/block/zram/zcomp.h
@@ -50,6 +50,7 @@ struct zcomp {
 	void (*destroy)(struct zcomp *comp);
 };
 
+struct zcomp_backend *find_backend(const char *compress);
 ssize_t zcomp_available_show(const char *comp, char *buf);
 
 struct zcomp *zcomp_create(const char *comp, int max_strm);
diff --git a/drivers/block/zram/zram_drv.c b/drivers/block/zram/zram_drv.c
index 01ec6945c2a9..ef4acd6e52d1 100644
--- a/drivers/block/zram/zram_drv.c
+++ b/drivers/block/zram/zram_drv.c
@@ -268,6 +268,11 @@ static ssize_t comp_algorithm_store(struct device *dev,
 {
 	struct zram *zram = dev_to_zram(dev);
 	down_write(&zram->init_lock);
+	if (!find_backend(buf)) {
+		up_write(&zram->init_lock);
+		pr_info("There is no such compression algorithm\n");
+		return -EINVAL;
+	}
 	if (init_done(zram)) {
 		up_write(&zram->init_lock);
 		pr_info("Can't change algorithm for initialized device\n");
-- 
1.9.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

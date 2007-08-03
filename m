Message-Id: <20070803125236.547639000@chello.nl>
References: <20070803123712.987126000@chello.nl>
Date: Fri, 03 Aug 2007 14:37:26 +0200
From: Peter Zijlstra <a.p.zijlstra@chello.nl>
Subject: [PATCH 13/23] mtd: clean up the backing_dev_info usage
Content-Disposition: inline; filename=mtd-bdi-fixups.patch
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org, linux-kernel@vger.kernel.org
Cc: miklos@szeredi.hu, akpm@linux-foundation.org, neilb@suse.de, dgc@sgi.com, tomoki.sekiyama.qu@hitachi.com, a.p.zijlstra@chello.nl, nikita@clusterfs.com, trond.myklebust@fys.uio.no, yingchao.zhou@gmail.com, richard@rsk.demon.co.uk, torvalds@linux-foundation.org
List-ID: <linux-mm.kvack.org>

Give each mtd device its own backing_dev_info instance.

Signed-off-by: Peter Zijlstra <a.p.zijlstra@chello.nl>
---
 drivers/mtd/mtdcore.c   |    8 +++++---
 include/linux/mtd/mtd.h |    2 ++
 2 files changed, 7 insertions(+), 3 deletions(-)

Index: linux-2.6/drivers/mtd/mtdcore.c
===================================================================
--- linux-2.6.orig/drivers/mtd/mtdcore.c
+++ linux-2.6/drivers/mtd/mtdcore.c
@@ -19,6 +19,7 @@
 #include <linux/init.h>
 #include <linux/mtd/compatmac.h>
 #include <linux/proc_fs.h>
+#include <linux/backing-dev.h>
 
 #include <linux/mtd/mtd.h>
 #include "internal.h"
@@ -53,15 +54,16 @@ int add_mtd_device(struct mtd_info *mtd)
 	if (!mtd->backing_dev_info) {
 		switch (mtd->type) {
 		case MTD_RAM:
-			mtd->backing_dev_info = &mtd_bdi_rw_mappable;
+			mtd->mtd_backing_dev_info = mtd_bdi_rw_mappable;
 			break;
 		case MTD_ROM:
-			mtd->backing_dev_info = &mtd_bdi_ro_mappable;
+			mtd->mtd_backing_dev_info = mtd_bdi_ro_mappable;
 			break;
 		default:
-			mtd->backing_dev_info = &mtd_bdi_unmappable;
+			mtd->mtd_backing_dev_info = mtd_bdi_unmappable;
 			break;
 		}
+		mtd->backing_dev_info = &mtd->mtd_backing_dev_info;
 	}
 	err = bdi_init(mtd->backing_dev_info);
 	if (err)
Index: linux-2.6/include/linux/mtd/mtd.h
===================================================================
--- linux-2.6.orig/include/linux/mtd/mtd.h
+++ linux-2.6/include/linux/mtd/mtd.h
@@ -13,6 +13,7 @@
 #include <linux/module.h>
 #include <linux/uio.h>
 #include <linux/notifier.h>
+#include <linux/backing-dev.h>
 
 #include <linux/mtd/compatmac.h>
 #include <mtd/mtd-abi.h>
@@ -154,6 +155,7 @@ struct mtd_info {
 	 * - provides mmap capabilities
 	 */
 	struct backing_dev_info *backing_dev_info;
+	struct backing_dev_info mtd_backing_dev_info;
 
 
 	int (*read) (struct mtd_info *mtd, loff_t from, size_t len, size_t *retlen, u_char *buf);

--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

Message-Id: <20070911200014.972473000@chello.nl>
References: <20070911195350.825778000@chello.nl>
Date: Tue, 11 Sep 2007 21:54:05 +0200
From: Peter Zijlstra <a.p.zijlstra@chello.nl>
Subject: [PATCH 15/23] mtd: give mtdconcat devices their own backing_dev_info
Content-Disposition: inline; filename=bdi_mtdconcat.patch
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org, linux-kernel@vger.kernel.org
Cc: miklos@szeredi.hu, akpm@linux-foundation.org, neilb@suse.de, dgc@sgi.com, tomoki.sekiyama.qu@hitachi.com, a.p.zijlstra@chello.nl, nikita@clusterfs.com, trond.myklebust@fys.uio.no, yingchao.zhou@gmail.com, richard@rsk.demon.co.uk, torvalds@linux-foundation.org, David Woodhouse <dwmw2@infradead.org>, Robert Kaiser <rkaiser@sysgo.de>
List-ID: <linux-mm.kvack.org>

These are actual devices, give them their own BDI.

Signed-off-by: Peter Zijlstra <a.p.zijlstra@chello.nl>
Cc: David Woodhouse <dwmw2@infradead.org>
Cc: Robert Kaiser <rkaiser@sysgo.de>
---
 drivers/mtd/mtdconcat.c |   28 ++++++++++++++++++----------
 1 file changed, 18 insertions(+), 10 deletions(-)

Index: linux-2.6/drivers/mtd/mtdconcat.c
===================================================================
--- linux-2.6.orig/drivers/mtd/mtdconcat.c	2007-04-22 18:55:17.000000000 +0200
+++ linux-2.6/drivers/mtd/mtdconcat.c	2007-04-22 19:01:42.000000000 +0200
@@ -32,6 +32,7 @@ struct mtd_concat {
 	struct mtd_info mtd;
 	int num_subdev;
 	struct mtd_info **subdev;
+	struct backing_dev_info backing_dev_info;
 };
 
 /*
@@ -782,10 +783,9 @@ struct mtd_info *mtd_concat_create(struc
 
 	for (i = 1; i < num_devs; i++) {
 		if (concat->mtd.type != subdev[i]->type) {
-			kfree(concat);
 			printk("Incompatible device type on \"%s\"\n",
 			       subdev[i]->name);
-			return NULL;
+			goto error;
 		}
 		if (concat->mtd.flags != subdev[i]->flags) {
 			/*
@@ -794,10 +794,9 @@ struct mtd_info *mtd_concat_create(struc
 			 */
 			if ((concat->mtd.flags ^ subdev[i]->
 			     flags) & ~MTD_WRITEABLE) {
-				kfree(concat);
 				printk("Incompatible device flags on \"%s\"\n",
 				       subdev[i]->name);
-				return NULL;
+				goto error;
 			} else
 				/* if writeable attribute differs,
 				   make super device writeable */
@@ -809,9 +808,12 @@ struct mtd_info *mtd_concat_create(struc
 		 * - copy-mapping is still permitted
 		 */
 		if (concat->mtd.backing_dev_info !=
-		    subdev[i]->backing_dev_info)
+		    subdev[i]->backing_dev_info) {
+			concat->backing_dev_info = default_backing_dev_info;
+			bdi_init(&concat->backing_dev_info);
 			concat->mtd.backing_dev_info =
-				&default_backing_dev_info;
+				&concat->backing_dev_info;
+		}
 
 		concat->mtd.size += subdev[i]->size;
 		concat->mtd.ecc_stats.badblocks +=
@@ -821,10 +823,9 @@ struct mtd_info *mtd_concat_create(struc
 		    concat->mtd.oobsize    !=  subdev[i]->oobsize ||
 		    !concat->mtd.read_oob  != !subdev[i]->read_oob ||
 		    !concat->mtd.write_oob != !subdev[i]->write_oob) {
-			kfree(concat);
 			printk("Incompatible OOB or ECC data on \"%s\"\n",
 			       subdev[i]->name);
-			return NULL;
+			goto error;
 		}
 		concat->subdev[i] = subdev[i];
 
@@ -903,11 +904,10 @@ struct mtd_info *mtd_concat_create(struc
 		    kmalloc(num_erase_region *
 			    sizeof (struct mtd_erase_region_info), GFP_KERNEL);
 		if (!erase_region_p) {
-			kfree(concat);
 			printk
 			    ("memory allocation error while creating erase region list"
 			     " for device \"%s\"\n", name);
-			return NULL;
+			goto error;
 		}
 
 		/*
@@ -968,6 +968,12 @@ struct mtd_info *mtd_concat_create(struc
 	}
 
 	return &concat->mtd;
+
+error:
+	if (concat->mtd.backing_dev_info == &concat->backing_dev_info)
+		bdi_destroy(&concat->backing_dev_info);
+	kfree(concat);
+	return NULL;
 }
 
 /*
@@ -977,6 +983,8 @@ struct mtd_info *mtd_concat_create(struc
 void mtd_concat_destroy(struct mtd_info *mtd)
 {
 	struct mtd_concat *concat = CONCAT(mtd);
+	if (concat->mtd.backing_dev_info == &concat->backing_dev_info)
+		bdi_destroy(&concat->backing_dev_info);
 	if (concat->mtd.numeraseregions)
 		kfree(concat->mtd.eraseregions);
 	kfree(concat);

--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

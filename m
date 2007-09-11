Message-Id: <20070911200014.674433000@chello.nl>
References: <20070911195350.825778000@chello.nl>
Date: Tue, 11 Sep 2007 21:54:03 +0200
From: Peter Zijlstra <a.p.zijlstra@chello.nl>
Subject: [PATCH 13/23] mtd: bdi init hooks
Content-Disposition: inline; filename=bdi_init_mtd.patch
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org, linux-kernel@vger.kernel.org
Cc: miklos@szeredi.hu, akpm@linux-foundation.org, neilb@suse.de, dgc@sgi.com, tomoki.sekiyama.qu@hitachi.com, a.p.zijlstra@chello.nl, nikita@clusterfs.com, trond.myklebust@fys.uio.no, yingchao.zhou@gmail.com, richard@rsk.demon.co.uk, torvalds@linux-foundation.org, David Woodhouse <dwmw2@infradead.org>
List-ID: <linux-mm.kvack.org>

split off because the relevant mtd changes seem particular to -mm

Signed-off-by: Peter Zijlstra <a.p.zijlstra@chello.nl>
Cc: David Woodhouse <dwmw2@infradead.org>
---
 drivers/mtd/mtdcore.c |    9 +++++++++
 1 file changed, 9 insertions(+)

Index: linux-2.6/drivers/mtd/mtdcore.c
===================================================================
--- linux-2.6.orig/drivers/mtd/mtdcore.c
+++ linux-2.6/drivers/mtd/mtdcore.c
@@ -48,6 +48,7 @@ static LIST_HEAD(mtd_notifiers);
 int add_mtd_device(struct mtd_info *mtd)
 {
 	int i;
+	int err;
 
 	if (!mtd->backing_dev_info) {
 		switch (mtd->type) {
@@ -62,6 +63,9 @@ int add_mtd_device(struct mtd_info *mtd)
 			break;
 		}
 	}
+	err = bdi_init(mtd->backing_dev_info);
+	if (err)
+		return 1;
 
 	BUG_ON(mtd->writesize == 0);
 	mutex_lock(&mtd_table_mutex);
@@ -102,6 +106,7 @@ int add_mtd_device(struct mtd_info *mtd)
 		}
 
 	mutex_unlock(&mtd_table_mutex);
+	bdi_destroy(mtd->backing_dev_info);
 	return 1;
 }
 
@@ -144,6 +149,10 @@ int del_mtd_device (struct mtd_info *mtd
 	}
 
 	mutex_unlock(&mtd_table_mutex);
+
+	if (mtd->backing_dev_info)
+		bdi_destroy(mtd->backing_dev_info);
+
 	return ret;
 }
 

--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

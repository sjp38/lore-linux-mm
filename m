Message-Id: <20070614220446.853313577@chello.nl>
References: <20070614215817.389524447@chello.nl>
Date: Thu, 14 Jun 2007 23:58:25 +0200
From: Peter Zijlstra <a.p.zijlstra@chello.nl>
Subject: [PATCH 08/17] containers: bdi init hooks
Content-Disposition: inline; filename=bdi_init_container.patch
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org, linux-kernel@vger.kernel.org
Cc: miklos@szeredi.hu, akpm@linux-foundation.org, neilb@suse.de, dgc@sgi.com, tomoki.sekiyama.qu@hitachi.com, a.p.zijlstra@chello.nl, nikita@clusterfs.com, trond.myklebust@fys.uio.no, yingchao.zhou@gmail.com, andrea@suse.de
List-ID: <linux-mm.kvack.org>

split off from the large bdi_init patch because containers are not slated
for mainline any time soon.

Signed-off-by: Peter Zijlstra <a.p.zijlstra@chello.nl>
---
 kernel/container.c |    9 ++++++---
 1 file changed, 6 insertions(+), 3 deletions(-)

Index: linux-2.6/kernel/container.c
===================================================================
--- linux-2.6.orig/kernel/container.c
+++ linux-2.6/kernel/container.c
@@ -554,12 +554,13 @@ static int container_populate_dir(struct
 static struct inode_operations container_dir_inode_operations;
 static struct file_operations proc_containerstats_operations;
 
+static struct backing_dev_info container_backing_dev_info = {
+	.capabilities	= BDI_CAP_NO_ACCT_DIRTY | BDI_CAP_NO_WRITEBACK,
+};
+
 static struct inode *container_new_inode(mode_t mode, struct super_block *sb)
 {
 	struct inode *inode = new_inode(sb);
-	static struct backing_dev_info container_backing_dev_info = {
-		.capabilities	= BDI_CAP_NO_ACCT_DIRTY | BDI_CAP_NO_WRITEBACK,
-	};
 
 	if (inode) {
 		inode->i_mode = mode;
@@ -2058,6 +2059,8 @@ int __init container_init(void)
 	if (err < 0)
 		goto out;
 
+	bdi_init(&container_backing_dev_info);
+
 	entry = create_proc_entry("containers", 0, NULL);
 	if (entry)
 		entry->proc_fops = &proc_containerstats_operations;

-- 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

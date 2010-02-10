Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with ESMTP id BF6046B0071
	for <linux-mm@kvack.org>; Wed, 10 Feb 2010 12:03:51 -0500 (EST)
From: Trond Myklebust <Trond.Myklebust@netapp.com>
Subject: [PATCH 02/13] VM: Don't call bdi_stat(BDI_UNSTABLE) on non-nfs backing-devices
Date: Wed, 10 Feb 2010 12:03:22 -0500
Message-Id: <1265821413-21618-3-git-send-email-Trond.Myklebust@netapp.com>
In-Reply-To: <1265821413-21618-2-git-send-email-Trond.Myklebust@netapp.com>
References: <1265821413-21618-1-git-send-email-Trond.Myklebust@netapp.com>
 <1265821413-21618-2-git-send-email-Trond.Myklebust@netapp.com>
Sender: owner-linux-mm@kvack.org
To: linux-mm@kvack.org
Cc: Trond Myklebust <Trond.Myklebust@netapp.com>
List-ID: <linux-mm.kvack.org>

Speeds up the accounting in balance_dirty_pages() for non-nfs devices.

Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
Acked-by: Jan Kara <jack@suse.cz>
Acked-by: Peter Zijlstra <peterz@infradead.org>
Reviewed-by: Wu Fengguang <fengguang.wu@intel.com>
---
 fs/nfs/client.c             |    1 +
 include/linux/backing-dev.h |    6 ++++++
 mm/page-writeback.c         |   16 +++++++++++-----
 3 files changed, 18 insertions(+), 5 deletions(-)

diff --git a/fs/nfs/client.c b/fs/nfs/client.c
index ee77713..d0b060a 100644
--- a/fs/nfs/client.c
+++ b/fs/nfs/client.c
@@ -890,6 +890,7 @@ static void nfs_server_set_fsinfo(struct nfs_server *server, struct nfs_fsinfo *
 
 	server->backing_dev_info.name = "nfs";
 	server->backing_dev_info.ra_pages = server->rpages * NFS_MAX_READAHEAD;
+	server->backing_dev_info.capabilities |= BDI_CAP_ACCT_UNSTABLE;
 
 	if (server->wsize > max_rpc_payload)
 		server->wsize = max_rpc_payload;
diff --git a/include/linux/backing-dev.h b/include/linux/backing-dev.h
index 42c3e2a..8b45166 100644
--- a/include/linux/backing-dev.h
+++ b/include/linux/backing-dev.h
@@ -232,6 +232,7 @@ int bdi_set_max_ratio(struct backing_dev_info *bdi, unsigned int max_ratio);
 #define BDI_CAP_EXEC_MAP	0x00000040
 #define BDI_CAP_NO_ACCT_WB	0x00000080
 #define BDI_CAP_SWAP_BACKED	0x00000100
+#define BDI_CAP_ACCT_UNSTABLE	0x00000200
 
 #define BDI_CAP_VMFLAGS \
 	(BDI_CAP_READ_MAP | BDI_CAP_WRITE_MAP | BDI_CAP_EXEC_MAP)
@@ -311,6 +312,11 @@ static inline bool bdi_cap_flush_forker(struct backing_dev_info *bdi)
 	return bdi == &default_backing_dev_info;
 }
 
+static inline bool bdi_cap_account_unstable(struct backing_dev_info *bdi)
+{
+	return bdi->capabilities & BDI_CAP_ACCT_UNSTABLE;
+}
+
 static inline bool mapping_cap_writeback_dirty(struct address_space *mapping)
 {
 	return bdi_cap_writeback_dirty(mapping->backing_dev_info);
diff --git a/mm/page-writeback.c b/mm/page-writeback.c
index 23d3fc6..c06739b 100644
--- a/mm/page-writeback.c
+++ b/mm/page-writeback.c
@@ -273,8 +273,9 @@ static void clip_bdi_dirty_limit(struct backing_dev_info *bdi,
 		avail_dirty = 0;
 
 	avail_dirty += bdi_stat(bdi, BDI_DIRTY) +
-		bdi_stat(bdi, BDI_UNSTABLE) +
 		bdi_stat(bdi, BDI_WRITEBACK);
+	if (bdi_cap_account_unstable(bdi))
+		avail_dirty += bdi_stat(bdi, BDI_UNSTABLE);
 
 	*pbdi_dirty = min(*pbdi_dirty, avail_dirty);
 }
@@ -510,8 +511,9 @@ static void balance_dirty_pages(struct address_space *mapping,
 					global_page_state(NR_UNSTABLE_NFS);
 		nr_writeback = global_page_state(NR_WRITEBACK);
 
-		bdi_nr_reclaimable = bdi_stat(bdi, BDI_DIRTY) +
-				     bdi_stat(bdi, BDI_UNSTABLE);
+		bdi_nr_reclaimable = bdi_stat(bdi, BDI_DIRTY);
+		if (bdi_cap_account_unstable(bdi))
+			bdi_nr_reclaimable += bdi_stat(bdi, BDI_UNSTABLE);
 		bdi_nr_writeback = bdi_stat(bdi, BDI_WRITEBACK);
 
 		if (bdi_nr_reclaimable + bdi_nr_writeback <= bdi_thresh)
@@ -556,11 +558,15 @@ static void balance_dirty_pages(struct address_space *mapping,
 		 * deltas.
 		 */
 		if (bdi_thresh < 2*bdi_stat_error(bdi)) {
-			bdi_nr_reclaimable = bdi_stat_sum(bdi, BDI_DIRTY) +
+			bdi_nr_reclaimable = bdi_stat_sum(bdi, BDI_DIRTY);
+			if (bdi_cap_account_unstable(bdi))
+				bdi_nr_reclaimable +=
 					     bdi_stat_sum(bdi, BDI_UNSTABLE);
 			bdi_nr_writeback = bdi_stat_sum(bdi, BDI_WRITEBACK);
 		} else if (bdi_nr_reclaimable) {
-			bdi_nr_reclaimable = bdi_stat(bdi, BDI_DIRTY) +
+			bdi_nr_reclaimable = bdi_stat(bdi, BDI_DIRTY);
+			if (bdi_cap_account_unstable(bdi))
+				bdi_nr_reclaimable +=
 					     bdi_stat(bdi, BDI_UNSTABLE);
 			bdi_nr_writeback = bdi_stat(bdi, BDI_WRITEBACK);
 		}
-- 
1.6.6

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

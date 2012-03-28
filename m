Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx203.postini.com [74.125.245.203])
	by kanga.kvack.org (Postfix) with SMTP id EBC766B0118
	for <linux-mm@kvack.org>; Wed, 28 Mar 2012 18:37:38 -0400 (EDT)
Message-Id: <20120328131153.475460374@intel.com>
Date: Wed, 28 Mar 2012 20:13:13 +0800
From: Fengguang Wu <fengguang.wu@intel.com>
Subject: [PATCH 5/6] blk-cgroup: buffered write IO controller - bandwidth limit interface
References: <20120328121308.568545879@intel.com>
Content-Disposition: inline; filename=writeback-io-controller-interface.patch
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linux Memory Management List <linux-mm@kvack.org>
Cc: Vivek Goyal <vgoyal@redhat.com>, Wu Fengguang <fengguang.wu@intel.com>, Suresh Jayaraman <sjayaraman@suse.com>, Andrea Righi <andrea@betterlinux.com>, Jeff Moyer <jmoyer@redhat.com>, linux-fsdevel@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>

Add blkio controller interface "throttle.buffered_write_bps".

Signed-off-by: Wu Fengguang <fengguang.wu@intel.com>
---
 block/blk-cgroup.c         |   21 +++++++++++++++++++++
 include/linux/blk-cgroup.h |    1 +
 2 files changed, 22 insertions(+)

--- linux-next.orig/block/blk-cgroup.c	2012-03-28 15:36:16.402093131 +0800
+++ linux-next/block/blk-cgroup.c	2012-03-28 15:36:44.974092545 +0800
@@ -1355,6 +1355,12 @@ static u64 blkiocg_file_read_u64 (struct
 			return (u64)blkcg->weight;
 		}
 		break;
+	case BLKIO_POLICY_THROTL:
+		switch (name) {
+		case BLKIO_THROTL_buffered_write_bps:
+			return (u64)blkcg->buffered_write_bps;
+		}
+		break;
 	default:
 		BUG();
 	}
@@ -1377,6 +1383,13 @@ blkiocg_file_write_u64(struct cgroup *cg
 			return blkio_weight_write(blkcg, val);
 		}
 		break;
+	case BLKIO_POLICY_THROTL:
+		switch (name) {
+		case BLKIO_THROTL_buffered_write_bps:
+			blkcg->buffered_write_bps = val;
+			return 0;
+		}
+		break;
 	default:
 		BUG();
 	}
@@ -1500,6 +1513,14 @@ struct cftype blkio_files[] = {
 				BLKIO_THROTL_io_serviced),
 		.read_map = blkiocg_file_read_map,
 	},
+	{
+		.name = "throttle.buffered_write_bps",
+		.private = BLKIOFILE_PRIVATE(BLKIO_POLICY_THROTL,
+				BLKIO_THROTL_buffered_write_bps),
+		.read_u64 = blkiocg_file_read_u64,
+		.write_u64 = blkiocg_file_write_u64,
+		.max_write_len = 256,
+	},
 #endif /* CONFIG_BLK_DEV_THROTTLING */
 
 #ifdef CONFIG_DEBUG_BLK_CGROUP
--- linux-next.orig/include/linux/blk-cgroup.h	2012-03-28 15:36:16.426093131 +0800
+++ linux-next/include/linux/blk-cgroup.h	2012-03-28 15:36:44.974092545 +0800
@@ -113,6 +113,7 @@ enum blkcg_file_name_throtl {
 	BLKIO_THROTL_write_iops_device,
 	BLKIO_THROTL_io_service_bytes,
 	BLKIO_THROTL_io_serviced,
+	BLKIO_THROTL_buffered_write_bps,
 };
 
 struct blkio_cgroup {


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx108.postini.com [74.125.245.108])
	by kanga.kvack.org (Postfix) with SMTP id A185C6B0116
	for <linux-mm@kvack.org>; Wed, 28 Mar 2012 18:27:17 -0400 (EDT)
Message-Id: <20120328131153.548884752@intel.com>
Date: Wed, 28 Mar 2012 20:13:14 +0800
From: Fengguang Wu <fengguang.wu@intel.com>
Subject: [PATCH 6/6] blk-cgroup: buffered write IO controller - debug trace
References: <20120328121308.568545879@intel.com>
Content-Disposition: inline; filename=writeback-io-controller-trace.patch
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linux Memory Management List <linux-mm@kvack.org>
Cc: Vivek Goyal <vgoyal@redhat.com>, Wu Fengguang <fengguang.wu@intel.com>, Suresh Jayaraman <sjayaraman@suse.com>, Andrea Righi <andrea@betterlinux.com>, Jeff Moyer <jmoyer@redhat.com>, linux-fsdevel@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>

test-blkio-cgroup.sh

	#!/bin/sh

	mount /dev/sda7 /fs

	echo 1 > /debug/tracing/events/writeback/balance_dirty_pages/enable
	echo 1 > /debug/tracing/events/writeback/blkcg_dirty_ratelimit/enable

	rmdir /cgroup/buffered_write
	mkdir /cgroup/buffered_write
	echo $$ > /cgroup/buffered_write/tasks
	echo $((2<<20)) > /cgroup/buffered_write/blkio.throttle.buffered_write_bps

	dd if=/dev/zero of=/fs/zero1 bs=1M count=100 &
	dd if=/dev/zero of=/fs/zero2 bs=1M count=100 &

run 1:
	104857600 bytes (105 MB) copied, 97.8103 s, 1.1 MB/s
	104857600 bytes (105 MB) copied, 97.9835 s, 1.1 MB/s
run 2:
	104857600 bytes (105 MB) copied, 98.5704 s, 1.1 MB/s
	104857600 bytes (105 MB) copied, 98.6268 s, 1.1 MB/s

average bps:	100MiB / 98.248s = 1.02MiB/s

run 1 trace:
              dd-3485  [000] ....   658.737063: blkcg_dirty_ratelimit: kbps=2048 dirty_rate=1932 dirty_ratelimit=1064 balanced_dirty_ratelimit=1088
              dd-3485  [000] ....   658.976945: blkcg_dirty_ratelimit: kbps=2048 dirty_rate=2000 dirty_ratelimit=1076 balanced_dirty_ratelimit=1084
              dd-3485  [000] ....   659.212830: blkcg_dirty_ratelimit: kbps=2048 dirty_rate=2440 dirty_ratelimit=992 balanced_dirty_ratelimit=900
              dd-3485  [002] ....   659.470651: blkcg_dirty_ratelimit: kbps=2048 dirty_rate=1860 dirty_ratelimit=1044 balanced_dirty_ratelimit=1088
              dd-3485  [002] ....   659.714535: blkcg_dirty_ratelimit: kbps=2048 dirty_rate=2360 dirty_ratelimit=976 balanced_dirty_ratelimit=904
              dd-3485  [002] ....   659.976381: blkcg_dirty_ratelimit: kbps=2048 dirty_rate=1832 dirty_ratelimit=1036 balanced_dirty_ratelimit=1088
              dd-3485  [000] ....   660.222254: blkcg_dirty_ratelimit: kbps=2048 dirty_rate=2340 dirty_ratelimit=972 balanced_dirty_ratelimit=904
              dd-3485  [000] ....   660.484089: blkcg_dirty_ratelimit: kbps=2048 dirty_rate=1464 dirty_ratelimit=1164 balanced_dirty_ratelimit=1352
              dd-3485  [000] ....   660.701984: blkcg_dirty_ratelimit: kbps=2048 dirty_rate=2640 dirty_ratelimit=1036 balanced_dirty_ratelimit=900
              dd-3485  [000] ....   660.947856: blkcg_dirty_ratelimit: kbps=2048 dirty_rate=1948 dirty_ratelimit=1064 balanced_dirty_ratelimit=1084
              dd-3485  [000] ....   661.187727: blkcg_dirty_ratelimit: kbps=2048 dirty_rate=2000 dirty_ratelimit=1076 balanced_dirty_ratelimit=1084
              dd-3485  [000] ....   661.423572: blkcg_dirty_ratelimit: kbps=2048 dirty_rate=2440 dirty_ratelimit=992 balanced_dirty_ratelimit=900
              dd-3485  [000] ....   661.681431: blkcg_dirty_ratelimit: kbps=2048 dirty_rate=2232 dirty_ratelimit=952 balanced_dirty_ratelimit=908
              dd-3485  [002] ....   661.949290: blkcg_dirty_ratelimit: kbps=2048 dirty_rate=1432 dirty_ratelimit=1156 balanced_dirty_ratelimit=1356
              dd-3485  [002] ....   662.169176: blkcg_dirty_ratelimit: kbps=2048 dirty_rate=2616 dirty_ratelimit=1032 balanced_dirty_ratelimit=900
              dd-3485  [000] ....   662.417016: blkcg_dirty_ratelimit: kbps=2048 dirty_rate=2320 dirty_ratelimit=972 balanced_dirty_ratelimit=908
              dd-3485  [000] ....   662.678903: blkcg_dirty_ratelimit: kbps=2048 dirty_rate=1464 dirty_ratelimit=1164 balanced_dirty_ratelimit=1352
              dd-3485  [000] ....   662.896764: blkcg_dirty_ratelimit: kbps=2048 dirty_rate=2640 dirty_ratelimit=1036 balanced_dirty_ratelimit=900
              dd-3485  [002] ....   663.142644: blkcg_dirty_ratelimit: kbps=2048 dirty_rate=2340 dirty_ratelimit=972 balanced_dirty_ratelimit=904

It looks good enough as a proposal.  Could be made more accurate if necessary.

Signed-off-by: Wu Fengguang <fengguang.wu@intel.com>
---
 include/trace/events/writeback.h |   34 +++++++++++++++++++++++++++++
 mm/page-writeback.c              |    2 +
 2 files changed, 36 insertions(+)

--- linux-next.orig/mm/page-writeback.c	2012-03-28 15:36:16.426093131 +0800
+++ linux-next/mm/page-writeback.c	2012-03-28 15:36:47.906092485 +0800
@@ -1163,6 +1163,8 @@ static void blkcg_update_dirty_ratelimit
 	ratelimit >>= PAGE_SHIFT;
 
 	blkcg->dirty_ratelimit = (blkcg->dirty_ratelimit + ratelimit) / 2 + 1;
+	trace_blkcg_dirty_ratelimit(bps, dirty_rate,
+				    blkcg->dirty_ratelimit, ratelimit);
 }
 
 void blkcg_update_bandwidth(struct blkio_cgroup *blkcg)
--- linux-next.orig/include/trace/events/writeback.h	2012-03-28 14:25:16.026180561 +0800
+++ linux-next/include/trace/events/writeback.h	2012-03-28 15:36:47.906092485 +0800
@@ -249,6 +249,40 @@ TRACE_EVENT(global_dirty_state,
 
 #define KBps(x)			((x) << (PAGE_SHIFT - 10))
 
+TRACE_EVENT(blkcg_dirty_ratelimit,
+
+	TP_PROTO(unsigned long bps,
+		 unsigned long dirty_rate,
+		 unsigned long dirty_ratelimit,
+		 unsigned long balanced_dirty_ratelimit),
+
+	TP_ARGS(bps, dirty_rate, dirty_ratelimit, balanced_dirty_ratelimit),
+
+	TP_STRUCT__entry(
+		__field(unsigned long,	kbps)
+		__field(unsigned long,	dirty_rate)
+		__field(unsigned long,	dirty_ratelimit)
+		__field(unsigned long,	balanced_dirty_ratelimit)
+	),
+
+	TP_fast_assign(
+		__entry->kbps = bps >> 10;
+		__entry->dirty_rate = KBps(dirty_rate);
+		__entry->dirty_ratelimit = KBps(dirty_ratelimit);
+		__entry->balanced_dirty_ratelimit =
+					  KBps(balanced_dirty_ratelimit);
+	),
+
+	TP_printk("kbps=%lu dirty_rate=%lu "
+		  "dirty_ratelimit=%lu "
+		  "balanced_dirty_ratelimit=%lu",
+		  __entry->kbps,
+		  __entry->dirty_rate,
+		  __entry->dirty_ratelimit,
+		  __entry->balanced_dirty_ratelimit
+	)
+);
+
 TRACE_EVENT(bdi_dirty_ratelimit,
 
 	TP_PROTO(struct backing_dev_info *bdi,


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

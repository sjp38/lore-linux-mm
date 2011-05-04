Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with SMTP id 04BF16B0011
	for <linux-mm@kvack.org>; Wed,  4 May 2011 03:39:43 -0400 (EDT)
Date: Wed, 4 May 2011 15:39:31 +0800
From: Wu Fengguang <fengguang.wu@intel.com>
Subject: Re: [PATCH 6/6] writeback: refill b_io iff empty
Message-ID: <20110504073931.GA22675@localhost>
References: <20110420080336.441157866@intel.com>
 <20110420080918.560499032@intel.com>
MIME-Version: 1.0
Content-Type: multipart/mixed; boundary="9amGYk9869ThD9tj"
Content-Disposition: inline
In-Reply-To: <20110420080918.560499032@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Jan Kara <jack@suse.cz>, Mel Gorman <mel@linux.vnet.ibm.com>, Mel Gorman <mel@csn.ul.ie>, Dave Chinner <david@fromorbit.com>, Itaru Kitayama <kitayama@cl.bb4u.ne.jp>, Minchan Kim <minchan.kim@gmail.com>, Linux Memory Management List <linux-mm@kvack.org>, "linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>, LKML <linux-kernel@vger.kernel.org>


--9amGYk9869ThD9tj
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

To help understand the behavior change, I wrote the writeback_queue_io
trace event, and found very different patterns between
- vanilla kernel
- this patchset plus the sync livelock fixes

Basically the vanilla kernel each time pulls a random number of inodes
from b_dirty, while the patched kernel tends to pull a fixed number of
inodes (enqueue=1031) from b_dirty. The new behavior is very interesting...

The attached test script runs 1 dd and 1 tar concurrently on XFS,
whose output can be found at the start of the trace files. The
elapsed time is 289s for vanilla kernel and 270s for patched kernel.

Thanks,
Fengguang

--9amGYk9869ThD9tj
Content-Type: text/x-diff; charset=us-ascii
Content-Disposition: attachment; filename="writeback-trace-queue_io.patch"

Subject: 
Date: Sat Apr 23 12:27:27 CST 2011


Signed-off-by: Wu Fengguang <fengguang.wu@intel.com>
---
 fs/fs-writeback.c                |   16 +++++++++++-----
 include/trace/events/writeback.h |   23 +++++++++++++++++++++++
 2 files changed, 34 insertions(+), 5 deletions(-)

--- linux-next.orig/fs/fs-writeback.c	2011-05-04 14:36:48.000000000 +0800
+++ linux-next/fs/fs-writeback.c	2011-05-04 14:37:39.000000000 +0800
@@ -250,15 +250,16 @@ static bool inode_dirtied_after(struct i
 /*
  * Move expired dirty inodes from @delaying_queue to @dispatch_queue.
  */
-static void move_expired_inodes(struct list_head *delaying_queue,
-				struct list_head *dispatch_queue,
-				struct writeback_control *wbc)
+static int move_expired_inodes(struct list_head *delaying_queue,
+			       struct list_head *dispatch_queue,
+			       struct writeback_control *wbc)
 {
 	LIST_HEAD(tmp);
 	struct list_head *pos, *node;
 	struct super_block *sb = NULL;
 	struct inode *inode;
 	int do_sb_sort = 0;
+	int moved = 0;
 
 	while (!list_empty(delaying_queue)) {
 		inode = wb_inode(delaying_queue->prev);
@@ -269,12 +270,13 @@ static void move_expired_inodes(struct l
 			do_sb_sort = 1;
 		sb = inode->i_sb;
 		list_move(&inode->i_wb_list, &tmp);
+		moved++;
 	}
 
 	/* just one sb in list, splice to dispatch_queue and we're done */
 	if (!do_sb_sort) {
 		list_splice(&tmp, dispatch_queue);
-		return;
+		goto out;
 	}
 
 	/* Move inodes from one superblock together */
@@ -286,6 +288,8 @@ static void move_expired_inodes(struct l
 				list_move(&inode->i_wb_list, dispatch_queue);
 		}
 	}
+out:
+	return moved;
 }
 
 /*
@@ -301,9 +305,11 @@ static void move_expired_inodes(struct l
  */
 static void queue_io(struct bdi_writeback *wb, struct writeback_control *wbc)
 {
+	int moved;
 	assert_spin_locked(&inode_wb_list_lock);
 	list_splice_init(&wb->b_more_io, &wb->b_io);
-	move_expired_inodes(&wb->b_dirty, &wb->b_io, wbc);
+	moved = move_expired_inodes(&wb->b_dirty, &wb->b_io, wbc);
+	trace_writeback_queue_io(wb, wbc, moved);
 }
 
 static int write_inode(struct inode *inode, struct writeback_control *wbc)
--- linux-next.orig/include/trace/events/writeback.h	2011-05-02 11:07:57.000000000 +0800
+++ linux-next/include/trace/events/writeback.h	2011-05-04 14:37:35.000000000 +0800
@@ -152,6 +152,29 @@ DEFINE_WBC_EVENT(wbc_balance_dirty_writt
 DEFINE_WBC_EVENT(wbc_balance_dirty_wait);
 DEFINE_WBC_EVENT(wbc_writepage);
 
+TRACE_EVENT(writeback_queue_io,
+	TP_PROTO(struct bdi_writeback *wb,
+		 struct writeback_control *wbc,
+		 int moved),
+	TP_ARGS(wb, wbc, moved),
+	TP_STRUCT__entry(
+		__array(char,	name, 32)
+		__field(int,	older)
+		__field(int,	moved)
+	),
+	TP_fast_assign(
+		strncpy(__entry->name, dev_name(wb->bdi->dev), 32);
+		__entry->older	= wbc->older_than_this ?
+				  (jiffies - *wbc->older_than_this) * 1000 / HZ
+				  : -1;
+		__entry->moved	= moved;
+	),
+	TP_printk("bdi %s: older=%d enqueue=%d",
+		__entry->name,
+		__entry->older,
+		__entry->moved)
+);
+
 DECLARE_EVENT_CLASS(writeback_congest_waited_template,
 
 	TP_PROTO(unsigned int usec_timeout, unsigned int usec_delayed),

--9amGYk9869ThD9tj
Content-Type: application/x-sh
Content-Disposition: attachment; filename="test-tar-dd.sh"
Content-Transfer-Encoding: quoted-printable

#!/bin/zsh=0A=0A=0A# we are doing pure write tests=0Acp /c/linux-2.6.38.3.t=
ar.bz2 /dev/shm/=0A=0Aumount /dev/sda7=0Amkfs.xfs -f /dev/sda7=0A# mkfs.ext=
4 /dev/sda7=0Amount /dev/sda7 /fs=0A=0Aecho 3 > /proc/sys/vm/drop_caches=0A=
=0Aecho 1 > /debug/tracing/events/writeback/writeback_single_inode/enable=
=0Aecho 1 > /debug/tracing/events/writeback/writeback_queue_io/enable=0A# e=
cho $((100<<10)) > /proc/sys/vm/dirty_background_bytes=0A# echo $((200<<10)=
) > /proc/sys/vm/dirty_bytes=0A=0Acat /proc/uptime=0Atic=3D$(cat /proc/upti=
me|cut -d' ' -f2)=0A=0Acd /fs=0Atime tar jxf /dev/shm/linux-2.6.38.3.tar.bz=
2 &=0Atime dd if=3D/dev/zero of=3D/fs/zero bs=3D1M count=3D1000 &=0A=0Await=
=0Async=0Acat /proc/uptime=0Atac=3D$(cat /proc/uptime|cut -d' ' -f2)=0Aecho=
 elapsed: $((tac - tic))=0A
--9amGYk9869ThD9tj
Content-Type: text/plain; charset=us-ascii
Content-Disposition: attachment; filename="trace-2.6.39-rc3-dyn-expire+"

root@fat /home/wfg# bin/test-tar-dd.sh
umount: /dev/sda7: not mounted
meta-data=/dev/sda7              isize=256    agcount=4, agsize=6170464 blks
         =                       sectsz=512   attr=2
data     =                       bsize=4096   blocks=24681856, imaxpct=25
         =                       sunit=0      swidth=0 blks
naming   =version 2              bsize=4096   ascii-ci=0
log      =internal log           bsize=4096   blocks=12051, version=2
         =                       sectsz=512   sunit=0 blks, lazy-count=1
realtime =none                   extsz=4096   blocks=0, rtextents=0
bin/test-tar-dd.sh:14: no such file or directory: /debug/tracing/events/writeback/writeback_single_inode/enable
18.95 134.64
1000+0 records in
1000+0 records out
1048576000 bytes (1.0 GB) copied, 11.5855 s, 90.5 MB/s
dd if=/dev/zero of=/fs/zero bs=1M count=1000  0.00s user 2.59s system 22% cpu 11.614 total
tar jxf /dev/shm/linux-2.6.38.3.tar.bz2  12.08s user 4.43s system 55% cpu 29.862 total
59.05 401.19
elapsed: 270.38

# tracer: nop
#
#           TASK-PID    CPU#    TIMESTAMP  FUNCTION
#              | |       |          |         |
       flush-8:0-2926  [005]    19.491518: writeback_queue_io: bdi 8:0: older=30000 enqueue=0
       flush-8:0-2926  [005]    19.491521: writeback_queue_io: bdi 8:0: older=30000 enqueue=0
       flush-8:0-2926  [005]    19.491592: writeback_queue_io: bdi 8:0: older=-1 enqueue=644
       flush-8:0-2926  [005]    19.511680: writeback_queue_io: bdi 8:0: older=30000 enqueue=0
       flush-8:0-2926  [005]    19.512392: writeback_queue_io: bdi 8:0: older=30000 enqueue=0
       flush-8:0-2926  [005]    19.513408: writeback_queue_io: bdi 8:0: older=30000 enqueue=0
       flush-8:0-2926  [005]    19.514321: writeback_queue_io: bdi 8:0: older=30000 enqueue=0
       flush-8:0-2926  [005]    19.521382: writeback_queue_io: bdi 8:0: older=30000 enqueue=0
       flush-8:0-2926  [005]    19.522103: writeback_queue_io: bdi 8:0: older=30000 enqueue=0
       flush-8:0-2926  [005]    19.530078: writeback_queue_io: bdi 8:0: older=30000 enqueue=0
       flush-8:0-2926  [005]    19.530833: writeback_queue_io: bdi 8:0: older=30000 enqueue=0
       flush-8:0-2926  [005]    19.534340: writeback_queue_io: bdi 8:0: older=30000 enqueue=0
       flush-8:0-2926  [005]    19.538572: writeback_queue_io: bdi 8:0: older=30000 enqueue=0
       flush-8:0-2926  [005]    19.542839: writeback_queue_io: bdi 8:0: older=30000 enqueue=0
       flush-8:0-2926  [005]    19.547076: writeback_queue_io: bdi 8:0: older=30000 enqueue=0
       flush-8:0-2926  [005]    19.551240: writeback_queue_io: bdi 8:0: older=30000 enqueue=0
       flush-8:0-2926  [005]    19.555429: writeback_queue_io: bdi 8:0: older=30000 enqueue=0
       flush-8:0-2926  [005]    19.559650: writeback_queue_io: bdi 8:0: older=30000 enqueue=0
       flush-8:0-2926  [005]    19.563863: writeback_queue_io: bdi 8:0: older=30000 enqueue=0
       flush-8:0-2926  [005]    19.568111: writeback_queue_io: bdi 8:0: older=30000 enqueue=0
              dd-2924  [002]    19.640092: writeback_queue_io: bdi 8:0: older=-1 enqueue=1008
       flush-8:0-2926  [000]    19.934320: writeback_queue_io: bdi 8:0: older=30000 enqueue=0
       flush-8:0-2926  [004]    20.182384: writeback_queue_io: bdi 8:0: older=30000 enqueue=0
       flush-8:0-2926  [000]    20.190345: writeback_queue_io: bdi 8:0: older=30000 enqueue=0
       flush-8:0-2926  [000]    20.191834: writeback_queue_io: bdi 8:0: older=30000 enqueue=0
       flush-8:0-2926  [000]    20.192749: writeback_queue_io: bdi 8:0: older=30000 enqueue=0
              dd-2924  [003]    20.215325: writeback_queue_io: bdi 8:0: older=-1 enqueue=1031
       flush-8:0-2926  [000]    20.570616: writeback_queue_io: bdi 8:0: older=30000 enqueue=0
       flush-8:0-2926  [000]    20.571424: writeback_queue_io: bdi 8:0: older=30000 enqueue=0
       flush-8:0-2926  [000]    20.572249: writeback_queue_io: bdi 8:0: older=30000 enqueue=0
       flush-8:0-2926  [000]    20.573045: writeback_queue_io: bdi 8:0: older=30000 enqueue=0
       flush-8:0-2926  [004]    20.759429: writeback_queue_io: bdi 8:0: older=30000 enqueue=0
       flush-8:0-2926  [004]    20.760391: writeback_queue_io: bdi 8:0: older=30000 enqueue=0
       flush-8:0-2926  [004]    20.761302: writeback_queue_io: bdi 8:0: older=30000 enqueue=0
              dd-2924  [000]    20.786554: writeback_queue_io: bdi 8:0: older=-1 enqueue=1031
              dd-2924  [000]    20.790471: writeback_queue_io: bdi 8:0: older=-1 enqueue=1031
              dd-2924  [000]    20.796459: writeback_queue_io: bdi 8:0: older=-1 enqueue=1031
              dd-2924  [000]    20.814775: writeback_queue_io: bdi 8:0: older=-1 enqueue=1031
              dd-2924  [000]    20.818366: writeback_queue_io: bdi 8:0: older=-1 enqueue=1031
              dd-2924  [000]    20.822369: writeback_queue_io: bdi 8:0: older=-1 enqueue=1031
              dd-2924  [000]    20.828361: writeback_queue_io: bdi 8:0: older=-1 enqueue=1031
              dd-2924  [000]    20.838421: writeback_queue_io: bdi 8:0: older=-1 enqueue=1031
              dd-2924  [000]    20.856283: writeback_queue_io: bdi 8:0: older=-1 enqueue=1031
              dd-2924  [000]    20.894326: writeback_queue_io: bdi 8:0: older=-1 enqueue=1031
              dd-2924  [000]    20.897156: writeback_queue_io: bdi 8:0: older=-1 enqueue=1031
              dd-2924  [000]    20.901125: writeback_queue_io: bdi 8:0: older=-1 enqueue=1031
              dd-2924  [000]    20.907124: writeback_queue_io: bdi 8:0: older=-1 enqueue=1031
              dd-2924  [000]    20.918181: writeback_queue_io: bdi 8:0: older=-1 enqueue=1031
              dd-2924  [000]    20.940281: writeback_queue_io: bdi 8:0: older=-1 enqueue=1031
              dd-2924  [000]    20.942999: writeback_queue_io: bdi 8:0: older=-1 enqueue=1031
              dd-2924  [000]    20.946983: writeback_queue_io: bdi 8:0: older=-1 enqueue=1031
              dd-2924  [000]    20.952965: writeback_queue_io: bdi 8:0: older=-1 enqueue=1031
              dd-2924  [000]    20.962948: writeback_queue_io: bdi 8:0: older=-1 enqueue=1031
       flush-8:0-2926  [000]    20.968968: writeback_queue_io: bdi 8:0: older=30000 enqueue=0
       flush-8:0-2926  [000]    20.970181: writeback_queue_io: bdi 8:0: older=30000 enqueue=0
       flush-8:0-2926  [000]    20.971367: writeback_queue_io: bdi 8:0: older=30000 enqueue=0
       flush-8:0-2926  [000]    20.972552: writeback_queue_io: bdi 8:0: older=30000 enqueue=0
              dd-2924  [000]    20.985901: writeback_queue_io: bdi 8:0: older=-1 enqueue=1031
              dd-2924  [000]    20.990851: writeback_queue_io: bdi 8:0: older=-1 enqueue=1031
              dd-2924  [000]    20.997841: writeback_queue_io: bdi 8:0: older=-1 enqueue=1031
              dd-2924  [000]    21.007815: writeback_queue_io: bdi 8:0: older=-1 enqueue=1031
              dd-2924  [000]    21.025829: writeback_queue_io: bdi 8:0: older=-1 enqueue=1031
              dd-2924  [000]    21.063984: writeback_queue_io: bdi 8:0: older=-1 enqueue=1031
              dd-2924  [000]    21.066615: writeback_queue_io: bdi 8:0: older=-1 enqueue=1031
              dd-2924  [000]    21.070600: writeback_queue_io: bdi 8:0: older=-1 enqueue=1031
              dd-2924  [000]    21.076599: writeback_queue_io: bdi 8:0: older=-1 enqueue=1031
              dd-2924  [000]    21.087573: writeback_queue_io: bdi 8:0: older=-1 enqueue=1031
              dd-2924  [000]    21.109714: writeback_queue_io: bdi 8:0: older=-1 enqueue=1031
              dd-2924  [000]    21.112475: writeback_queue_io: bdi 8:0: older=-1 enqueue=1031
              dd-2924  [000]    21.116457: writeback_queue_io: bdi 8:0: older=-1 enqueue=1031
              dd-2924  [000]    21.122441: writeback_queue_io: bdi 8:0: older=-1 enqueue=1031
              dd-2924  [000]    21.132480: writeback_queue_io: bdi 8:0: older=-1 enqueue=1031
              dd-2924  [000]    21.154576: writeback_queue_io: bdi 8:0: older=-1 enqueue=1031
              dd-2924  [000]    21.157333: writeback_queue_io: bdi 8:0: older=-1 enqueue=1031
              dd-2924  [000]    21.161318: writeback_queue_io: bdi 8:0: older=-1 enqueue=1031
              dd-2924  [000]    21.167314: writeback_queue_io: bdi 8:0: older=-1 enqueue=1031
       flush-8:0-2926  [001]    21.171047: writeback_queue_io: bdi 8:0: older=30000 enqueue=0
       flush-8:0-2926  [001]    21.172293: writeback_queue_io: bdi 8:0: older=30000 enqueue=0
       flush-8:0-2926  [001]    21.173527: writeback_queue_io: bdi 8:0: older=30000 enqueue=0
              dd-2924  [000]    21.194252: writeback_queue_io: bdi 8:0: older=-1 enqueue=1031
              dd-2924  [000]    21.235402: writeback_queue_io: bdi 8:0: older=-1 enqueue=1031
              dd-2924  [000]    21.238087: writeback_queue_io: bdi 8:0: older=-1 enqueue=1031
              dd-2924  [000]    21.242104: writeback_queue_io: bdi 8:0: older=-1 enqueue=1031
              dd-2924  [000]    21.248052: writeback_queue_io: bdi 8:0: older=-1 enqueue=1031
              dd-2924  [000]    21.258124: writeback_queue_io: bdi 8:0: older=-1 enqueue=1031
              dd-2924  [000]    21.284649: writeback_queue_io: bdi 8:0: older=-1 enqueue=1031
              dd-2924  [000]    21.286932: writeback_queue_io: bdi 8:0: older=-1 enqueue=1031
              dd-2924  [000]    21.290919: writeback_queue_io: bdi 8:0: older=-1 enqueue=1031
              dd-2924  [000]    21.296899: writeback_queue_io: bdi 8:0: older=-1 enqueue=1031
              dd-2924  [000]    21.306889: writeback_queue_io: bdi 8:0: older=-1 enqueue=1031
              dd-2924  [000]    21.324897: writeback_queue_io: bdi 8:0: older=-1 enqueue=1031
              dd-2924  [000]    21.358728: writeback_queue_io: bdi 8:0: older=-1 enqueue=1031
       flush-8:0-2926  [000]    21.386536: writeback_queue_io: bdi 8:0: older=30000 enqueue=0
       flush-8:0-2926  [000]    21.387106: writeback_queue_io: bdi 8:0: older=30000 enqueue=0
       flush-8:0-2926  [000]    21.387664: writeback_queue_io: bdi 8:0: older=30000 enqueue=0
       flush-8:0-2926  [000]    21.388216: writeback_queue_io: bdi 8:0: older=30000 enqueue=0
              dd-2924  [000]    21.429514: writeback_queue_io: bdi 8:0: older=-1 enqueue=1031
              dd-2924  [000]    21.433491: writeback_queue_io: bdi 8:0: older=-1 enqueue=1031
              dd-2924  [000]    21.439458: writeback_queue_io: bdi 8:0: older=-1 enqueue=1031
              dd-2924  [000]    21.453498: writeback_queue_io: bdi 8:0: older=-1 enqueue=1031
              dd-2924  [000]    21.456406: writeback_queue_io: bdi 8:0: older=-1 enqueue=1031
              dd-2924  [000]    21.460391: writeback_queue_io: bdi 8:0: older=-1 enqueue=1031
              dd-2924  [000]    21.466386: writeback_queue_io: bdi 8:0: older=-1 enqueue=1031
              dd-2924  [000]    21.476358: writeback_queue_io: bdi 8:0: older=-1 enqueue=1031
              dd-2924  [000]    21.494301: writeback_queue_io: bdi 8:0: older=-1 enqueue=1031
              dd-2924  [000]    21.532203: writeback_queue_io: bdi 8:0: older=-1 enqueue=1031
              dd-2924  [000]    21.535163: writeback_queue_io: bdi 8:0: older=-1 enqueue=1031
              dd-2924  [000]    21.539150: writeback_queue_io: bdi 8:0: older=-1 enqueue=1031
              dd-2924  [000]    21.545141: writeback_queue_io: bdi 8:0: older=-1 enqueue=1031
              dd-2924  [000]    21.555114: writeback_queue_io: bdi 8:0: older=-1 enqueue=1031
              dd-2924  [000]    21.581393: writeback_queue_io: bdi 8:0: older=-1 enqueue=1031
              dd-2924  [000]    21.585008: writeback_queue_io: bdi 8:0: older=-1 enqueue=1031
              dd-2924  [000]    21.588993: writeback_queue_io: bdi 8:0: older=-1 enqueue=1031
              dd-2924  [000]    21.594989: writeback_queue_io: bdi 8:0: older=-1 enqueue=1031
       flush-8:0-2926  [000]    21.602369: writeback_queue_io: bdi 8:0: older=30000 enqueue=0
       flush-8:0-2926  [000]    21.602941: writeback_queue_io: bdi 8:0: older=30000 enqueue=0
       flush-8:0-2926  [000]    21.603496: writeback_queue_io: bdi 8:0: older=30000 enqueue=0
              dd-2924  [000]    21.620920: writeback_queue_io: bdi 8:0: older=-1 enqueue=1031
              dd-2924  [000]    21.663323: writeback_queue_io: bdi 8:0: older=-1 enqueue=1031
              dd-2924  [000]    21.665759: writeback_queue_io: bdi 8:0: older=-1 enqueue=1031
              dd-2924  [000]    21.669745: writeback_queue_io: bdi 8:0: older=-1 enqueue=1031
              dd-2924  [000]    21.675738: writeback_queue_io: bdi 8:0: older=-1 enqueue=1031
              dd-2924  [000]    21.693686: writeback_queue_io: bdi 8:0: older=-1 enqueue=1031
              dd-2924  [000]    21.696662: writeback_queue_io: bdi 8:0: older=-1 enqueue=1031
              dd-2924  [000]    21.700648: writeback_queue_io: bdi 8:0: older=-1 enqueue=1031
              dd-2924  [000]    21.706628: writeback_queue_io: bdi 8:0: older=-1 enqueue=1031
              dd-2924  [000]    21.716617: writeback_queue_io: bdi 8:0: older=-1 enqueue=1031
              dd-2924  [000]    21.734610: writeback_queue_io: bdi 8:0: older=-1 enqueue=1031
              dd-2924  [000]    21.774548: writeback_queue_io: bdi 8:0: older=-1 enqueue=1031
              dd-2924  [000]    21.777412: writeback_queue_io: bdi 8:0: older=-1 enqueue=1031
              dd-2924  [000]    21.781419: writeback_queue_io: bdi 8:0: older=-1 enqueue=1031
              dd-2924  [000]    21.787369: writeback_queue_io: bdi 8:0: older=-1 enqueue=1031
              dd-2924  [000]    21.797350: writeback_queue_io: bdi 8:0: older=-1 enqueue=1031
       flush-8:0-2926  [000]    21.811137: writeback_queue_io: bdi 8:0: older=30000 enqueue=0
       flush-8:0-2926  [000]    21.811708: writeback_queue_io: bdi 8:0: older=30000 enqueue=0
       flush-8:0-2926  [000]    21.812340: writeback_queue_io: bdi 8:0: older=30000 enqueue=0
       flush-8:0-2926  [000]    21.812899: writeback_queue_io: bdi 8:0: older=30000 enqueue=0
              dd-2924  [000]    21.820301: writeback_queue_io: bdi 8:0: older=-1 enqueue=1031
              dd-2924  [000]    21.824264: writeback_queue_io: bdi 8:0: older=-1 enqueue=1031
              dd-2924  [000]    21.830246: writeback_queue_io: bdi 8:0: older=-1 enqueue=1031
              dd-2924  [000]    21.840275: writeback_queue_io: bdi 8:0: older=-1 enqueue=1031
              dd-2924  [000]    21.859186: writeback_queue_io: bdi 8:0: older=-1 enqueue=1031
              dd-2924  [000]    21.899544: writeback_queue_io: bdi 8:0: older=-1 enqueue=1031
              dd-2924  [000]    21.902039: writeback_queue_io: bdi 8:0: older=-1 enqueue=1031
              dd-2924  [000]    21.906018: writeback_queue_io: bdi 8:0: older=-1 enqueue=1031
              dd-2924  [000]    21.912003: writeback_queue_io: bdi 8:0: older=-1 enqueue=1031
              dd-2924  [000]    21.931784: writeback_queue_io: bdi 8:0: older=-1 enqueue=1031
              dd-2924  [000]    21.934923: writeback_queue_io: bdi 8:0: older=-1 enqueue=1031
              dd-2924  [000]    21.938910: writeback_queue_io: bdi 8:0: older=-1 enqueue=1031
              dd-2924  [000]    21.944901: writeback_queue_io: bdi 8:0: older=-1 enqueue=1031
              dd-2924  [000]    21.954875: writeback_queue_io: bdi 8:0: older=-1 enqueue=1031
              dd-2924  [000]    21.972824: writeback_queue_io: bdi 8:0: older=-1 enqueue=1031
              dd-2924  [000]    22.011067: writeback_queue_io: bdi 8:0: older=-1 enqueue=1031
              dd-2924  [000]    22.013682: writeback_queue_io: bdi 8:0: older=-1 enqueue=1031
              dd-2924  [000]    22.017666: writeback_queue_io: bdi 8:0: older=-1 enqueue=1031
              dd-2924  [000]    22.023657: writeback_queue_io: bdi 8:0: older=-1 enqueue=1031
       flush-8:0-2926  [000]    22.026325: writeback_queue_io: bdi 8:0: older=30000 enqueue=0
       flush-8:0-2926  [000]    22.026895: writeback_queue_io: bdi 8:0: older=30000 enqueue=0
       flush-8:0-2926  [000]    22.027450: writeback_queue_io: bdi 8:0: older=30000 enqueue=0
       flush-8:0-2926  [000]    22.028007: writeback_queue_io: bdi 8:0: older=30000 enqueue=0
              dd-2924  [000]    22.054316: writeback_queue_io: bdi 8:0: older=-1 enqueue=1031
              dd-2924  [000]    22.057545: writeback_queue_io: bdi 8:0: older=-1 enqueue=1031
              dd-2924  [000]    22.061539: writeback_queue_io: bdi 8:0: older=-1 enqueue=1031
              dd-2924  [000]    22.067518: writeback_queue_io: bdi 8:0: older=-1 enqueue=1031
              dd-2924  [000]    22.077512: writeback_queue_io: bdi 8:0: older=-1 enqueue=1031
              dd-2924  [000]    22.097435: writeback_queue_io: bdi 8:0: older=-1 enqueue=1031
              dd-2924  [000]    22.139106: writeback_queue_io: bdi 8:0: older=-1 enqueue=1031
              dd-2924  [000]    22.143283: writeback_queue_io: bdi 8:0: older=-1 enqueue=1031
              dd-2924  [000]    22.147265: writeback_queue_io: bdi 8:0: older=-1 enqueue=1031
              dd-2924  [000]    22.153262: writeback_queue_io: bdi 8:0: older=-1 enqueue=1031
      flush-0:15-2236  [003]    22.163312: writeback_queue_io: bdi 0:15: older=30000 enqueue=0
      flush-0:15-2236  [003]    22.163315: writeback_queue_io: bdi 0:15: older=30000 enqueue=0
      flush-0:15-2236  [003]    22.163317: writeback_queue_io: bdi 0:15: older=-1 enqueue=7
      flush-0:15-2236  [003]    22.163478: writeback_queue_io: bdi 0:15: older=30000 enqueue=0
      flush-0:15-2236  [003]    22.163479: writeback_queue_io: bdi 0:15: older=-1 enqueue=7
              dd-2924  [000]    22.170035: writeback_queue_io: bdi 8:0: older=-1 enqueue=1031
              dd-2924  [000]    22.173185: writeback_queue_io: bdi 8:0: older=-1 enqueue=1031
              dd-2924  [000]    22.177168: writeback_queue_io: bdi 8:0: older=-1 enqueue=1031
              dd-2924  [000]    22.183192: writeback_queue_io: bdi 8:0: older=-1 enqueue=1031
              dd-2924  [000]    22.186150: writeback_queue_io: bdi 8:0: older=-1 enqueue=1031
              dd-2924  [000]    22.190132: writeback_queue_io: bdi 8:0: older=-1 enqueue=1031
              dd-2924  [000]    22.196115: writeback_queue_io: bdi 8:0: older=-1 enqueue=1031
              dd-2924  [000]    22.206099: writeback_queue_io: bdi 8:0: older=-1 enqueue=1031
       flush-8:0-2926  [004]    22.228903: writeback_queue_io: bdi 8:0: older=30000 enqueue=0
       flush-8:0-2926  [004]    22.230641: writeback_queue_io: bdi 8:0: older=30000 enqueue=0
       flush-8:0-2926  [004]    22.231589: writeback_queue_io: bdi 8:0: older=30000 enqueue=0
              dd-2924  [001]    22.240047: writeback_queue_io: bdi 8:0: older=-1 enqueue=1031
              dd-2924  [001]    22.243969: writeback_queue_io: bdi 8:0: older=-1 enqueue=1031
              dd-2924  [001]    22.249995: writeback_queue_io: bdi 8:0: older=-1 enqueue=1031
              dd-2924  [001]    22.260005: writeback_queue_io: bdi 8:0: older=-1 enqueue=1031
              dd-2924  [001]    22.282466: writeback_queue_io: bdi 8:0: older=-1 enqueue=1031
              dd-2924  [001]    22.285833: writeback_queue_io: bdi 8:0: older=-1 enqueue=1031
              dd-2924  [001]    22.289819: writeback_queue_io: bdi 8:0: older=-1 enqueue=1031
              dd-2924  [001]    22.295836: writeback_queue_io: bdi 8:0: older=-1 enqueue=1031
              dd-2924  [001]    22.305815: writeback_queue_io: bdi 8:0: older=-1 enqueue=1031
              dd-2924  [001]    22.323755: writeback_queue_io: bdi 8:0: older=-1 enqueue=1031
              dd-2924  [001]    22.362152: writeback_queue_io: bdi 8:0: older=-1 enqueue=1031
              dd-2924  [001]    22.364591: writeback_queue_io: bdi 8:0: older=-1 enqueue=1031
              dd-2924  [001]    22.368574: writeback_queue_io: bdi 8:0: older=-1 enqueue=1031
              dd-2924  [001]    22.374588: writeback_queue_io: bdi 8:0: older=-1 enqueue=1031
              dd-2924  [001]    22.384576: writeback_queue_io: bdi 8:0: older=-1 enqueue=1031
              dd-2924  [001]    22.408997: writeback_queue_io: bdi 8:0: older=-1 enqueue=1031
              dd-2924  [001]    22.411442: writeback_queue_io: bdi 8:0: older=-1 enqueue=1031
              dd-2924  [001]    22.415435: writeback_queue_io: bdi 8:0: older=-1 enqueue=1031
              dd-2924  [001]    22.421455: writeback_queue_io: bdi 8:0: older=-1 enqueue=1031
              dd-2924  [001]    22.431422: writeback_queue_io: bdi 8:0: older=-1 enqueue=1031
       flush-8:0-2926  [000]    22.436513: writeback_queue_io: bdi 8:0: older=30000 enqueue=0
       flush-8:0-2926  [000]    22.437719: writeback_queue_io: bdi 8:0: older=30000 enqueue=0
       flush-8:0-2926  [000]    22.438913: writeback_queue_io: bdi 8:0: older=30000 enqueue=0
       flush-8:0-2926  [000]    22.440097: writeback_queue_io: bdi 8:0: older=30000 enqueue=0
              dd-2924  [001]    22.454336: writeback_queue_io: bdi 8:0: older=-1 enqueue=1031
              dd-2924  [001]    22.458297: writeback_queue_io: bdi 8:0: older=-1 enqueue=1031
              dd-2924  [001]    22.464307: writeback_queue_io: bdi 8:0: older=-1 enqueue=1031
              dd-2924  [001]    22.474290: writeback_queue_io: bdi 8:0: older=-1 enqueue=1031
              dd-2924  [001]    22.492238: writeback_queue_io: bdi 8:0: older=-1 enqueue=1031
              dd-2924  [001]    22.530624: writeback_queue_io: bdi 8:0: older=-1 enqueue=1031
              dd-2924  [001]    22.533068: writeback_queue_io: bdi 8:0: older=-1 enqueue=1031
              dd-2924  [001]    22.537051: writeback_queue_io: bdi 8:0: older=-1 enqueue=1031
              dd-2924  [001]    22.543080: writeback_queue_io: bdi 8:0: older=-1 enqueue=1031
              dd-2924  [001]    22.553052: writeback_queue_io: bdi 8:0: older=-1 enqueue=1031
              dd-2924  [001]    22.575463: writeback_queue_io: bdi 8:0: older=-1 enqueue=1031
              dd-2924  [001]    22.577929: writeback_queue_io: bdi 8:0: older=-1 enqueue=1031
              dd-2924  [001]    22.581914: writeback_queue_io: bdi 8:0: older=-1 enqueue=1031
              dd-2924  [001]    22.587927: writeback_queue_io: bdi 8:0: older=-1 enqueue=1031
              dd-2924  [001]    22.597895: writeback_queue_io: bdi 8:0: older=-1 enqueue=1031
              dd-2924  [001]    22.616851: writeback_queue_io: bdi 8:0: older=-1 enqueue=1031
       flush-8:0-2926  [000]    22.645196: writeback_queue_io: bdi 8:0: older=30000 enqueue=0
       flush-8:0-2926  [000]    22.646391: writeback_queue_io: bdi 8:0: older=30000 enqueue=0
       flush-8:0-2926  [000]    22.647589: writeback_queue_io: bdi 8:0: older=30000 enqueue=0
              dd-2924  [001]    22.655710: writeback_queue_io: bdi 8:0: older=-1 enqueue=1031
              dd-2924  [001]    22.659681: writeback_queue_io: bdi 8:0: older=-1 enqueue=1031
              dd-2924  [001]    22.665687: writeback_queue_io: bdi 8:0: older=-1 enqueue=1031
              dd-2924  [001]    22.675666: writeback_queue_io: bdi 8:0: older=-1 enqueue=1031
              dd-2924  [001]    22.698097: writeback_queue_io: bdi 8:0: older=-1 enqueue=1031
              dd-2924  [001]    22.700548: writeback_queue_io: bdi 8:0: older=-1 enqueue=1031
              dd-2924  [001]    22.704533: writeback_queue_io: bdi 8:0: older=-1 enqueue=1031
              dd-2924  [001]    22.710557: writeback_queue_io: bdi 8:0: older=-1 enqueue=1031
              dd-2924  [001]    22.720506: writeback_queue_io: bdi 8:0: older=-1 enqueue=1031
              dd-2924  [001]    22.738437: writeback_queue_io: bdi 8:0: older=-1 enqueue=1031
              dd-2924  [001]    22.780324: writeback_queue_io: bdi 8:0: older=-1 enqueue=1031
              dd-2924  [001]    22.783292: writeback_queue_io: bdi 8:0: older=-1 enqueue=1031
              dd-2924  [001]    22.787280: writeback_queue_io: bdi 8:0: older=-1 enqueue=1031
              dd-2924  [001]    22.793293: writeback_queue_io: bdi 8:0: older=-1 enqueue=1031
              dd-2924  [001]    22.803331: writeback_queue_io: bdi 8:0: older=-1 enqueue=1031
              dd-2924  [001]    22.810686: writeback_queue_io: bdi 8:0: older=-1 enqueue=1031
              dd-2924  [001]    22.813198: writeback_queue_io: bdi 8:0: older=-1 enqueue=1031
              dd-2924  [001]    22.817189: writeback_queue_io: bdi 8:0: older=-1 enqueue=1031
              dd-2924  [001]    22.823201: writeback_queue_io: bdi 8:0: older=-1 enqueue=1031
              dd-2924  [001]    22.833185: writeback_queue_io: bdi 8:0: older=-1 enqueue=1031
              dd-2924  [001]    22.853122: writeback_queue_io: bdi 8:0: older=-1 enqueue=1031
       flush-8:0-2926  [000]    22.862321: writeback_queue_io: bdi 8:0: older=30000 enqueue=0
       flush-8:0-2926  [000]    22.863507: writeback_queue_io: bdi 8:0: older=30000 enqueue=0
       flush-8:0-2926  [000]    22.864689: writeback_queue_io: bdi 8:0: older=30000 enqueue=0
       flush-8:0-2926  [000]    22.865871: writeback_queue_io: bdi 8:0: older=30000 enqueue=0
              dd-2924  [001]    22.892977: writeback_queue_io: bdi 8:0: older=-1 enqueue=1031
              dd-2924  [001]    22.896937: writeback_queue_io: bdi 8:0: older=-1 enqueue=1031
              dd-2924  [001]    22.902950: writeback_queue_io: bdi 8:0: older=-1 enqueue=1031
              dd-2924  [001]    22.912930: writeback_queue_io: bdi 8:0: older=-1 enqueue=1031
              dd-2924  [001]    22.935376: writeback_queue_io: bdi 8:0: older=-1 enqueue=1031
              dd-2924  [001]    22.937812: writeback_queue_io: bdi 8:0: older=-1 enqueue=1031
              dd-2924  [001]    22.941797: writeback_queue_io: bdi 8:0: older=-1 enqueue=1031
              dd-2924  [001]    22.947807: writeback_queue_io: bdi 8:0: older=-1 enqueue=1031
              dd-2924  [001]    22.957783: writeback_queue_io: bdi 8:0: older=-1 enqueue=1031
              dd-2924  [001]    22.975742: writeback_queue_io: bdi 8:0: older=-1 enqueue=1031
              dd-2924  [001]    23.010631: writeback_queue_io: bdi 8:0: older=-1 enqueue=1031
              dd-2924  [001]    23.080903: writeback_queue_io: bdi 8:0: older=-1 enqueue=1031
              dd-2924  [001]    23.083361: writeback_queue_io: bdi 8:0: older=-1 enqueue=1031
              dd-2924  [001]    23.087346: writeback_queue_io: bdi 8:0: older=-1 enqueue=1031
              dd-2924  [001]    23.093364: writeback_queue_io: bdi 8:0: older=-1 enqueue=1031
              dd-2924  [001]    23.103343: writeback_queue_io: bdi 8:0: older=-1 enqueue=1031
              dd-2924  [001]    23.121288: writeback_queue_io: bdi 8:0: older=-1 enqueue=1031
              dd-2924  [001]    23.155180: writeback_queue_io: bdi 8:0: older=-1 enqueue=1031
              dd-2924  [001]    23.229071: writeback_queue_io: bdi 8:0: older=-1 enqueue=1031
       flush-8:0-2926  [000]    23.231074: writeback_queue_io: bdi 8:0: older=30000 enqueue=0
       flush-8:0-2926  [000]    23.231663: writeback_queue_io: bdi 8:0: older=30000 enqueue=0
       flush-8:0-2926  [000]    23.232218: writeback_queue_io: bdi 8:0: older=30000 enqueue=0
       flush-8:0-2926  [000]    23.232763: writeback_queue_io: bdi 8:0: older=30000 enqueue=0
              dd-2924  [001]    23.237897: writeback_queue_io: bdi 8:0: older=-1 enqueue=1031
              dd-2924  [001]    23.247941: writeback_queue_io: bdi 8:0: older=-1 enqueue=1031
              dd-2924  [001]    23.270407: writeback_queue_io: bdi 8:0: older=-1 enqueue=1031
              dd-2924  [001]    23.272778: writeback_queue_io: bdi 8:0: older=-1 enqueue=1031
              dd-2924  [001]    23.276759: writeback_queue_io: bdi 8:0: older=-1 enqueue=1031
              dd-2924  [001]    23.282807: writeback_queue_io: bdi 8:0: older=-1 enqueue=1031
              dd-2924  [001]    23.292806: writeback_queue_io: bdi 8:0: older=-1 enqueue=1031
              dd-2924  [001]    23.310736: writeback_queue_io: bdi 8:0: older=-1 enqueue=1031
              dd-2924  [001]    23.344636: writeback_queue_io: bdi 8:0: older=-1 enqueue=1031
              dd-2924  [001]    23.414952: writeback_queue_io: bdi 8:0: older=-1 enqueue=1031
              dd-2924  [001]    23.417336: writeback_queue_io: bdi 8:0: older=-1 enqueue=1031
              dd-2924  [001]    23.421311: writeback_queue_io: bdi 8:0: older=-1 enqueue=1031
              dd-2924  [001]    23.427381: writeback_queue_io: bdi 8:0: older=-1 enqueue=1031
              dd-2924  [001]    23.437345: writeback_queue_io: bdi 8:0: older=-1 enqueue=1031
              dd-2924  [001]    23.455290: writeback_queue_io: bdi 8:0: older=-1 enqueue=1031
              dd-2924  [001]    23.493697: writeback_queue_io: bdi 8:0: older=-1 enqueue=1031
              dd-2924  [001]    23.496082: writeback_queue_io: bdi 8:0: older=-1 enqueue=1031
              dd-2924  [001]    23.500068: writeback_queue_io: bdi 8:0: older=-1 enqueue=1031
              dd-2924  [001]    23.506121: writeback_queue_io: bdi 8:0: older=-1 enqueue=1031
              dd-2924  [001]    23.516086: writeback_queue_io: bdi 8:0: older=-1 enqueue=1031
              dd-2924  [001]    23.534046: writeback_queue_io: bdi 8:0: older=-1 enqueue=1031
              dd-2924  [001]    23.567949: writeback_queue_io: bdi 8:0: older=-1 enqueue=1031
       flush-8:0-2926  [000]    23.579537: writeback_queue_io: bdi 8:0: older=30000 enqueue=0
       flush-8:0-2926  [000]    23.580357: writeback_queue_io: bdi 8:0: older=30000 enqueue=0
       flush-8:0-2926  [000]    23.581158: writeback_queue_io: bdi 8:0: older=30000 enqueue=0
              dd-2924  [001]    23.640649: writeback_queue_io: bdi 8:0: older=-1 enqueue=1031
              dd-2924  [001]    23.644628: writeback_queue_io: bdi 8:0: older=-1 enqueue=1031
              dd-2924  [001]    23.650603: writeback_queue_io: bdi 8:0: older=-1 enqueue=1031
              dd-2924  [001]    23.660652: writeback_queue_io: bdi 8:0: older=-1 enqueue=1031
              dd-2924  [001]    23.683112: writeback_queue_io: bdi 8:0: older=-1 enqueue=1031
              dd-2924  [001]    23.685497: writeback_queue_io: bdi 8:0: older=-1 enqueue=1031
              dd-2924  [001]    23.689481: writeback_queue_io: bdi 8:0: older=-1 enqueue=1031
              dd-2924  [001]    23.695537: writeback_queue_io: bdi 8:0: older=-1 enqueue=1031
              dd-2924  [001]    23.705493: writeback_queue_io: bdi 8:0: older=-1 enqueue=1031
              dd-2924  [001]    23.723461: writeback_queue_io: bdi 8:0: older=-1 enqueue=1031
              dd-2924  [004]    23.757301: writeback_queue_io: bdi 8:0: older=-1 enqueue=1031
              dd-2924  [004]    23.829786: writeback_queue_io: bdi 8:0: older=-1 enqueue=1031
              dd-2924  [004]    23.833041: writeback_queue_io: bdi 8:0: older=-1 enqueue=1031
              dd-2924  [004]    23.837040: writeback_queue_io: bdi 8:0: older=-1 enqueue=1031
              dd-2924  [004]    23.843008: writeback_queue_io: bdi 8:0: older=-1 enqueue=1031
              dd-2924  [004]    23.853090: writeback_queue_io: bdi 8:0: older=-1 enqueue=1031
              dd-2924  [004]    23.872028: writeback_queue_io: bdi 8:0: older=-1 enqueue=1031
              dd-2924  [004]    23.910340: writeback_queue_io: bdi 8:0: older=-1 enqueue=1031
              dd-2924  [004]    23.912794: writeback_queue_io: bdi 8:0: older=-1 enqueue=1031
              dd-2924  [004]    23.916793: writeback_queue_io: bdi 8:0: older=-1 enqueue=1031
              dd-2924  [004]    23.922758: writeback_queue_io: bdi 8:0: older=-1 enqueue=1031
              dd-2924  [004]    23.932835: writeback_queue_io: bdi 8:0: older=-1 enqueue=1031
              dd-2924  [004]    23.951770: writeback_queue_io: bdi 8:0: older=-1 enqueue=1031
       flush-8:0-2926  [000]    23.968721: writeback_queue_io: bdi 8:0: older=30000 enqueue=0
       flush-8:0-2926  [000]    23.969755: writeback_queue_io: bdi 8:0: older=30000 enqueue=0
       flush-8:0-2926  [000]    23.970877: writeback_queue_io: bdi 8:0: older=30000 enqueue=0
       flush-8:0-2926  [000]    23.972034: writeback_queue_io: bdi 8:0: older=30000 enqueue=0
              dd-2924  [004]    24.056456: writeback_queue_io: bdi 8:0: older=-1 enqueue=1031
              dd-2924  [004]    24.059339: writeback_queue_io: bdi 8:0: older=-1 enqueue=1031
              dd-2924  [004]    24.063324: writeback_queue_io: bdi 8:0: older=-1 enqueue=1031
              dd-2924  [004]    24.069304: writeback_queue_io: bdi 8:0: older=-1 enqueue=1031
              dd-2924  [004]    24.079376: writeback_queue_io: bdi 8:0: older=-1 enqueue=1031
              dd-2924  [004]    24.097325: writeback_queue_io: bdi 8:0: older=-1 enqueue=1031
              dd-2924  [004]    24.137789: writeback_queue_io: bdi 8:0: older=-1 enqueue=1031
              dd-2924  [004]    24.140072: writeback_queue_io: bdi 8:0: older=-1 enqueue=1031
              dd-2924  [004]    24.144073: writeback_queue_io: bdi 8:0: older=-1 enqueue=1031
              dd-2924  [004]    24.150054: writeback_queue_io: bdi 8:0: older=-1 enqueue=1031
              dd-2924  [004]    24.160097: writeback_queue_io: bdi 8:0: older=-1 enqueue=1031
              dd-2924  [004]    24.178069: writeback_queue_io: bdi 8:0: older=-1 enqueue=1031
              dd-2924  [004]    24.211958: writeback_queue_io: bdi 8:0: older=-1 enqueue=1031
              dd-2924  [004]    24.282211: writeback_queue_io: bdi 8:0: older=-1 enqueue=1031
              dd-2924  [004]    24.284662: writeback_queue_io: bdi 8:0: older=-1 enqueue=1031
              dd-2924  [004]    24.288626: writeback_queue_io: bdi 8:0: older=-1 enqueue=1031
              dd-2924  [004]    24.294626: writeback_queue_io: bdi 8:0: older=-1 enqueue=1031
       flush-8:0-2926  [000]    24.301958: writeback_queue_io: bdi 8:0: older=30000 enqueue=0
       flush-8:0-2926  [000]    24.302684: writeback_queue_io: bdi 8:0: older=30000 enqueue=0
       flush-8:0-2926  [000]    24.303210: writeback_queue_io: bdi 8:0: older=30000 enqueue=0
              dd-2924  [004]    24.309589: writeback_queue_io: bdi 8:0: older=-1 enqueue=1031
              dd-2924  [004]    24.313550: writeback_queue_io: bdi 8:0: older=-1 enqueue=1031
              dd-2924  [004]    24.319529: writeback_queue_io: bdi 8:0: older=-1 enqueue=1031
              dd-2924  [004]    24.329598: writeback_queue_io: bdi 8:0: older=-1 enqueue=1031
              dd-2924  [004]    24.347549: writeback_queue_io: bdi 8:0: older=-1 enqueue=1031
              dd-2924  [004]    24.381440: writeback_queue_io: bdi 8:0: older=-1 enqueue=1031
              dd-2924  [004]    24.447236: writeback_queue_io: bdi 8:0: older=-1 enqueue=1031
              dd-2924  [004]    24.553256: writeback_queue_io: bdi 8:0: older=-1 enqueue=1031
              dd-2924  [004]    24.555789: writeback_queue_io: bdi 8:0: older=-1 enqueue=1031
              dd-2924  [004]    24.564191: writeback_queue_io: bdi 8:0: older=-1 enqueue=1031
              dd-2924  [004]    24.566766: writeback_queue_io: bdi 8:0: older=-1 enqueue=1031
              dd-2924  [004]    24.570763: writeback_queue_io: bdi 8:0: older=-1 enqueue=1031
              dd-2924  [004]    24.576814: writeback_queue_io: bdi 8:0: older=-1 enqueue=1031
              dd-2924  [004]    24.586806: writeback_queue_io: bdi 8:0: older=-1 enqueue=1031
              dd-2924  [004]    24.606660: writeback_queue_io: bdi 8:0: older=-1 enqueue=1031
       flush-8:0-2926  [000]    24.636914: writeback_queue_io: bdi 8:0: older=30000 enqueue=0
       flush-8:0-2926  [000]    24.637444: writeback_queue_io: bdi 8:0: older=30000 enqueue=0
       flush-8:0-2926  [000]    24.637982: writeback_queue_io: bdi 8:0: older=30000 enqueue=0
       flush-8:0-2926  [000]    24.638613: writeback_queue_io: bdi 8:0: older=30000 enqueue=0
              dd-2924  [004]    24.645545: writeback_queue_io: bdi 8:0: older=-1 enqueue=1031
              dd-2924  [004]    24.649506: writeback_queue_io: bdi 8:0: older=-1 enqueue=1031
              dd-2924  [004]    24.655502: writeback_queue_io: bdi 8:0: older=-1 enqueue=1031
              dd-2924  [004]    24.665479: writeback_queue_io: bdi 8:0: older=-1 enqueue=1031
              dd-2924  [004]    24.683413: writeback_queue_io: bdi 8:0: older=-1 enqueue=1031
              dd-2924  [004]    24.717401: writeback_queue_io: bdi 8:0: older=-1 enqueue=1031
              dd-2924  [004]    24.797288: writeback_queue_io: bdi 8:0: older=-1 enqueue=1031
              dd-2924  [004]    24.800045: writeback_queue_io: bdi 8:0: older=-1 enqueue=1031
              dd-2924  [004]    24.804041: writeback_queue_io: bdi 8:0: older=-1 enqueue=1031
              dd-2924  [004]    24.810009: writeback_queue_io: bdi 8:0: older=-1 enqueue=1031
              dd-2924  [004]    24.824422: writeback_queue_io: bdi 8:0: older=-1 enqueue=1031
              dd-2924  [004]    24.826960: writeback_queue_io: bdi 8:0: older=-1 enqueue=1031
              dd-2924  [004]    24.830943: writeback_queue_io: bdi 8:0: older=-1 enqueue=1031
              dd-2924  [004]    24.836925: writeback_queue_io: bdi 8:0: older=-1 enqueue=1031
              dd-2924  [004]    24.846992: writeback_queue_io: bdi 8:0: older=-1 enqueue=1031
              dd-2924  [004]    24.864858: writeback_queue_io: bdi 8:0: older=-1 enqueue=1031
              dd-2924  [004]    24.898838: writeback_queue_io: bdi 8:0: older=-1 enqueue=1031
       flush-8:0-2926  [000]    24.912196: writeback_queue_io: bdi 8:0: older=30000 enqueue=0
       flush-8:0-2926  [000]    24.912854: writeback_queue_io: bdi 8:0: older=30000 enqueue=0
       flush-8:0-2926  [000]    24.913378: writeback_queue_io: bdi 8:0: older=30000 enqueue=0
              dd-2924  [004]    24.969553: writeback_queue_io: bdi 8:0: older=-1 enqueue=1031
              dd-2924  [004]    24.977807: writeback_queue_io: bdi 8:0: older=-1 enqueue=1031
              dd-2924  [004]    24.980485: writeback_queue_io: bdi 8:0: older=-1 enqueue=1031
              dd-2924  [004]    24.984468: writeback_queue_io: bdi 8:0: older=-1 enqueue=1031
              dd-2924  [004]    24.990450: writeback_queue_io: bdi 8:0: older=-1 enqueue=1031
              dd-2924  [004]    25.000446: writeback_queue_io: bdi 8:0: older=-1 enqueue=1031
              dd-2924  [004]    25.019380: writeback_queue_io: bdi 8:0: older=-1 enqueue=1031
              dd-2924  [004]    25.057649: writeback_queue_io: bdi 8:0: older=-1 enqueue=1031
              dd-2924  [004]    25.060241: writeback_queue_io: bdi 8:0: older=-1 enqueue=1031
              dd-2924  [004]    25.064221: writeback_queue_io: bdi 8:0: older=-1 enqueue=1031
              dd-2924  [004]    25.070205: writeback_queue_io: bdi 8:0: older=-1 enqueue=1031
              dd-2924  [004]    25.080254: writeback_queue_io: bdi 8:0: older=-1 enqueue=1031
              dd-2924  [004]    25.102544: writeback_queue_io: bdi 8:0: older=-1 enqueue=1031
              dd-2924  [004]    25.105097: writeback_queue_io: bdi 8:0: older=-1 enqueue=1031
              dd-2924  [004]    25.109082: writeback_queue_io: bdi 8:0: older=-1 enqueue=1031
              dd-2924  [004]    25.115075: writeback_queue_io: bdi 8:0: older=-1 enqueue=1031
       flush-8:0-2926  [000]    25.124573: writeback_queue_io: bdi 8:0: older=30000 enqueue=0
       flush-8:0-2926  [000]    25.125175: writeback_queue_io: bdi 8:0: older=30000 enqueue=0
       flush-8:0-2926  [000]    25.125702: writeback_queue_io: bdi 8:0: older=30000 enqueue=0
       flush-8:0-2926  [000]    25.126270: writeback_queue_io: bdi 8:0: older=30000 enqueue=0
              dd-2924  [004]    25.180687: writeback_queue_io: bdi 8:0: older=-1 enqueue=1031
              dd-2924  [004]    25.183853: writeback_queue_io: bdi 8:0: older=-1 enqueue=1031
              dd-2924  [004]    25.187851: writeback_queue_io: bdi 8:0: older=-1 enqueue=1031
              dd-2924  [004]    25.193835: writeback_queue_io: bdi 8:0: older=-1 enqueue=1031
              dd-2924  [004]    25.204922: writeback_queue_io: bdi 8:0: older=-1 enqueue=1031
              dd-2924  [004]    25.207778: writeback_queue_io: bdi 8:0: older=-1 enqueue=1031
              dd-2924  [004]    25.211776: writeback_queue_io: bdi 8:0: older=-1 enqueue=1031
              dd-2924  [004]    25.217748: writeback_queue_io: bdi 8:0: older=-1 enqueue=1031
              dd-2924  [004]    25.227818: writeback_queue_io: bdi 8:0: older=-1 enqueue=1031
              dd-2924  [004]    25.245678: writeback_queue_io: bdi 8:0: older=-1 enqueue=1031
              dd-2924  [004]    25.284943: writeback_queue_io: bdi 8:0: older=-1 enqueue=1031
              dd-2924  [004]    25.287533: writeback_queue_io: bdi 8:0: older=-1 enqueue=1031
              dd-2924  [004]    25.291530: writeback_queue_io: bdi 8:0: older=-1 enqueue=1031
              dd-2924  [004]    25.297501: writeback_queue_io: bdi 8:0: older=-1 enqueue=1031
              dd-2924  [004]    25.307550: writeback_queue_io: bdi 8:0: older=-1 enqueue=1031
       flush-8:0-2926  [000]    25.324915: writeback_queue_io: bdi 8:0: older=30000 enqueue=0
       flush-8:0-2926  [000]    25.325688: writeback_queue_io: bdi 8:0: older=30000 enqueue=0
       flush-8:0-2926  [000]    25.326667: writeback_queue_io: bdi 8:0: older=30000 enqueue=0
              dd-2924  [004]    25.331434: writeback_queue_io: bdi 8:0: older=-1 enqueue=1031
              dd-2924  [004]    25.335381: writeback_queue_io: bdi 8:0: older=-1 enqueue=1031
              dd-2924  [004]    25.341379: writeback_queue_io: bdi 8:0: older=-1 enqueue=1031
              dd-2924  [004]    25.351403: writeback_queue_io: bdi 8:0: older=-1 enqueue=1031
              dd-2924  [004]    25.369359: writeback_queue_io: bdi 8:0: older=-1 enqueue=1031
              dd-2924  [004]    25.408223: writeback_queue_io: bdi 8:0: older=-1 enqueue=1031
              dd-2924  [004]    25.411150: writeback_queue_io: bdi 8:0: older=-1 enqueue=1031
              dd-2924  [004]    25.415133: writeback_queue_io: bdi 8:0: older=-1 enqueue=1031
              dd-2924  [004]    25.421131: writeback_queue_io: bdi 8:0: older=-1 enqueue=1031
              dd-2924  [004]    25.433167: writeback_queue_io: bdi 8:0: older=-1 enqueue=1031
              dd-2924  [004]    25.455441: writeback_queue_io: bdi 8:0: older=-1 enqueue=1031
              dd-2924  [004]    25.458004: writeback_queue_io: bdi 8:0: older=-1 enqueue=1031
              dd-2924  [004]    25.462001: writeback_queue_io: bdi 8:0: older=-1 enqueue=1031
              dd-2924  [004]    25.467969: writeback_queue_io: bdi 8:0: older=-1 enqueue=1031
              dd-2924  [004]    25.478038: writeback_queue_io: bdi 8:0: older=-1 enqueue=1031
              dd-2924  [004]    25.500270: writeback_queue_io: bdi 8:0: older=-1 enqueue=1031
              dd-2924  [004]    25.502865: writeback_queue_io: bdi 8:0: older=-1 enqueue=1031
              dd-2924  [004]    25.506849: writeback_queue_io: bdi 8:0: older=-1 enqueue=1031
              dd-2924  [004]    25.512843: writeback_queue_io: bdi 8:0: older=-1 enqueue=1031
              dd-2924  [004]    25.522892: writeback_queue_io: bdi 8:0: older=-1 enqueue=1031
       flush-8:0-2926  [000]    25.537975: writeback_queue_io: bdi 8:0: older=30000 enqueue=0
       flush-8:0-2926  [000]    25.538533: writeback_queue_io: bdi 8:0: older=30000 enqueue=0
       flush-8:0-2926  [000]    25.539482: writeback_queue_io: bdi 8:0: older=30000 enqueue=0
       flush-8:0-2926  [000]    25.540605: writeback_queue_io: bdi 8:0: older=30000 enqueue=0
              dd-2924  [004]    25.581677: writeback_queue_io: bdi 8:0: older=-1 enqueue=1031
              dd-2924  [004]    25.584612: writeback_queue_io: bdi 8:0: older=-1 enqueue=1031
              dd-2924  [004]    25.588595: writeback_queue_io: bdi 8:0: older=-1 enqueue=1031
              dd-2924  [004]    25.594577: writeback_queue_io: bdi 8:0: older=-1 enqueue=1031
              dd-2924  [004]    25.604638: writeback_queue_io: bdi 8:0: older=-1 enqueue=1031
              dd-2924  [004]    25.626905: writeback_queue_io: bdi 8:0: older=-1 enqueue=1031
              dd-2924  [004]    25.629473: writeback_queue_io: bdi 8:0: older=-1 enqueue=1031
              dd-2924  [004]    25.633457: writeback_queue_io: bdi 8:0: older=-1 enqueue=1031
              dd-2924  [004]    25.639461: writeback_queue_io: bdi 8:0: older=-1 enqueue=1031
              dd-2924  [004]    25.649418: writeback_queue_io: bdi 8:0: older=-1 enqueue=1031
              dd-2924  [004]    25.667405: writeback_queue_io: bdi 8:0: older=-1 enqueue=1031
              dd-2924  [004]    25.710301: writeback_queue_io: bdi 8:0: older=-1 enqueue=1031
              dd-2924  [004]    25.713212: writeback_queue_io: bdi 8:0: older=-1 enqueue=1031
              dd-2924  [004]    25.717199: writeback_queue_io: bdi 8:0: older=-1 enqueue=1031
              dd-2924  [004]    25.723191: writeback_queue_io: bdi 8:0: older=-1 enqueue=1031
              dd-2924  [004]    25.737539: writeback_queue_io: bdi 8:0: older=-1 enqueue=1031
              dd-2924  [004]    25.740143: writeback_queue_io: bdi 8:0: older=-1 enqueue=1031
              dd-2924  [004]    25.744113: writeback_queue_io: bdi 8:0: older=-1 enqueue=1031
       flush-8:0-2926  [000]    25.746331: writeback_queue_io: bdi 8:0: older=30000 enqueue=0
       flush-8:0-2926  [000]    25.746869: writeback_queue_io: bdi 8:0: older=30000 enqueue=0
       flush-8:0-2926  [000]    25.747404: writeback_queue_io: bdi 8:0: older=30000 enqueue=0
       flush-8:0-2926  [000]    25.747929: writeback_queue_io: bdi 8:0: older=30000 enqueue=0
              dd-2924  [004]    25.758160: writeback_queue_io: bdi 8:0: older=-1 enqueue=1031
              dd-2924  [004]    25.776117: writeback_queue_io: bdi 8:0: older=-1 enqueue=1031
              dd-2924  [004]    25.814338: writeback_queue_io: bdi 8:0: older=-1 enqueue=1031
              dd-2924  [004]    25.816892: writeback_queue_io: bdi 8:0: older=-1 enqueue=1031
              dd-2924  [004]    25.820885: writeback_queue_io: bdi 8:0: older=-1 enqueue=1031
              dd-2924  [004]    25.826846: writeback_queue_io: bdi 8:0: older=-1 enqueue=1031
              dd-2924  [004]    25.836931: writeback_queue_io: bdi 8:0: older=-1 enqueue=1031
              dd-2924  [004]    25.859270: writeback_queue_io: bdi 8:0: older=-1 enqueue=1031
              dd-2924  [004]    25.861752: writeback_queue_io: bdi 8:0: older=-1 enqueue=1031
              dd-2924  [004]    25.865740: writeback_queue_io: bdi 8:0: older=-1 enqueue=1031
              dd-2924  [004]    25.871854: writeback_queue_io: bdi 8:0: older=-1 enqueue=1031
              dd-2924  [004]    25.881706: writeback_queue_io: bdi 8:0: older=-1 enqueue=1031
              dd-2924  [004]    25.899739: writeback_queue_io: bdi 8:0: older=-1 enqueue=1031
              dd-2924  [004]    25.937853: writeback_queue_io: bdi 8:0: older=-1 enqueue=1031
              dd-2924  [004]    25.940509: writeback_queue_io: bdi 8:0: older=-1 enqueue=1031
              dd-2924  [004]    25.944492: writeback_queue_io: bdi 8:0: older=-1 enqueue=1031
              dd-2924  [004]    25.950492: writeback_queue_io: bdi 8:0: older=-1 enqueue=1031
       flush-8:0-2926  [000]    25.962050: writeback_queue_io: bdi 8:0: older=30000 enqueue=0
       flush-8:0-2926  [000]    25.962798: writeback_queue_io: bdi 8:0: older=30000 enqueue=0
       flush-8:0-2926  [000]    25.963325: writeback_queue_io: bdi 8:0: older=30000 enqueue=0
              dd-2924  [004]    25.983391: writeback_queue_io: bdi 8:0: older=-1 enqueue=1031
              dd-2924  [004]    25.987360: writeback_queue_io: bdi 8:0: older=-1 enqueue=1031
              dd-2924  [004]    25.993344: writeback_queue_io: bdi 8:0: older=-1 enqueue=1031
              dd-2924  [004]    26.003410: writeback_queue_io: bdi 8:0: older=-1 enqueue=1031
              dd-2924  [004]    26.021301: writeback_queue_io: bdi 8:0: older=-1 enqueue=1031
              dd-2924  [004]    26.061588: writeback_queue_io: bdi 8:0: older=-1 enqueue=1031
              dd-2924  [004]    26.064125: writeback_queue_io: bdi 8:0: older=-1 enqueue=1031
              dd-2924  [004]    26.068112: writeback_queue_io: bdi 8:0: older=-1 enqueue=1031
              dd-2924  [004]    26.074094: writeback_queue_io: bdi 8:0: older=-1 enqueue=1031
              dd-2924  [004]    26.084151: writeback_queue_io: bdi 8:0: older=-1 enqueue=1031
              dd-2924  [004]    26.106423: writeback_queue_io: bdi 8:0: older=-1 enqueue=1031
              dd-2924  [004]    26.109001: writeback_queue_io: bdi 8:0: older=-1 enqueue=1031
              dd-2924  [004]    26.112970: writeback_queue_io: bdi 8:0: older=-1 enqueue=1031
              dd-2924  [004]    26.118966: writeback_queue_io: bdi 8:0: older=-1 enqueue=1031
              dd-2924  [004]    26.129038: writeback_queue_io: bdi 8:0: older=-1 enqueue=1031
              dd-2924  [004]    26.146936: writeback_queue_io: bdi 8:0: older=-1 enqueue=1031
       flush-8:0-2926  [000]    26.170795: writeback_queue_io: bdi 8:0: older=30000 enqueue=0
       flush-8:0-2926  [000]    26.171389: writeback_queue_io: bdi 8:0: older=30000 enqueue=0
       flush-8:0-2926  [000]    26.172221: writeback_queue_io: bdi 8:0: older=30000 enqueue=0
       flush-8:0-2926  [000]    26.173344: writeback_queue_io: bdi 8:0: older=30000 enqueue=0
              dd-2924  [004]    26.185767: writeback_queue_io: bdi 8:0: older=-1 enqueue=1031
              dd-2924  [004]    26.189747: writeback_queue_io: bdi 8:0: older=-1 enqueue=1031
              dd-2924  [004]    26.195715: writeback_queue_io: bdi 8:0: older=-1 enqueue=1031
              dd-2924  [004]    26.205764: writeback_queue_io: bdi 8:0: older=-1 enqueue=1031
              dd-2924  [004]    26.228243: writeback_queue_io: bdi 8:0: older=-1 enqueue=1031
              dd-2924  [004]    26.230613: writeback_queue_io: bdi 8:0: older=-1 enqueue=1031
              dd-2924  [004]    26.234593: writeback_queue_io: bdi 8:0: older=-1 enqueue=1031
              dd-2924  [004]    26.240589: writeback_queue_io: bdi 8:0: older=-1 enqueue=1031
              dd-2924  [004]    26.250570: writeback_queue_io: bdi 8:0: older=-1 enqueue=1031
              dd-2924  [004]    26.272892: writeback_queue_io: bdi 8:0: older=-1 enqueue=1031
              dd-2924  [004]    26.275472: writeback_queue_io: bdi 8:0: older=-1 enqueue=1031
              dd-2924  [004]    26.279462: writeback_queue_io: bdi 8:0: older=-1 enqueue=1031
              dd-2924  [004]    26.285424: writeback_queue_io: bdi 8:0: older=-1 enqueue=1031
              dd-2924  [004]    26.295508: writeback_queue_io: bdi 8:0: older=-1 enqueue=1031
              dd-2924  [004]    26.313431: writeback_queue_io: bdi 8:0: older=-1 enqueue=1031
              dd-2924  [004]    26.351620: writeback_queue_io: bdi 8:0: older=-1 enqueue=1031
              dd-2924  [004]    26.354228: writeback_queue_io: bdi 8:0: older=-1 enqueue=1031
              dd-2924  [004]    26.358221: writeback_queue_io: bdi 8:0: older=-1 enqueue=1031
              dd-2924  [004]    26.364196: writeback_queue_io: bdi 8:0: older=-1 enqueue=1031
              dd-2924  [004]    26.374259: writeback_queue_io: bdi 8:0: older=-1 enqueue=1031
       flush-8:0-2926  [000]    26.385018: writeback_queue_io: bdi 8:0: older=30000 enqueue=0
       flush-8:0-2926  [000]    26.385567: writeback_queue_io: bdi 8:0: older=30000 enqueue=0
       flush-8:0-2926  [000]    26.386098: writeback_queue_io: bdi 8:0: older=30000 enqueue=0
              dd-2924  [004]    26.397109: writeback_queue_io: bdi 8:0: older=-1 enqueue=1031
              dd-2924  [004]    26.401081: writeback_queue_io: bdi 8:0: older=-1 enqueue=1031
              dd-2924  [004]    26.407064: writeback_queue_io: bdi 8:0: older=-1 enqueue=1031
              dd-2924  [004]    26.417090: writeback_queue_io: bdi 8:0: older=-1 enqueue=1031
              dd-2924  [004]    26.435070: writeback_queue_io: bdi 8:0: older=-1 enqueue=1031
              dd-2924  [004]    26.473260: writeback_queue_io: bdi 8:0: older=-1 enqueue=1031
              dd-2924  [004]    26.475850: writeback_queue_io: bdi 8:0: older=-1 enqueue=1031
              dd-2924  [004]    26.479834: writeback_queue_io: bdi 8:0: older=-1 enqueue=1031
              dd-2924  [004]    26.485820: writeback_queue_io: bdi 8:0: older=-1 enqueue=1031
              dd-2924  [004]    26.495863: writeback_queue_io: bdi 8:0: older=-1 enqueue=1031
              dd-2924  [004]    26.518386: writeback_queue_io: bdi 8:0: older=-1 enqueue=1031
              dd-2924  [004]    26.520713: writeback_queue_io: bdi 8:0: older=-1 enqueue=1031
              dd-2924  [004]    26.524694: writeback_queue_io: bdi 8:0: older=-1 enqueue=1031
              dd-2924  [004]    26.530686: writeback_queue_io: bdi 8:0: older=-1 enqueue=1031
              dd-2924  [004]    26.540744: writeback_queue_io: bdi 8:0: older=-1 enqueue=1031
              dd-2924  [004]    26.562973: writeback_queue_io: bdi 8:0: older=-1 enqueue=1031
              dd-2924  [004]    26.565573: writeback_queue_io: bdi 8:0: older=-1 enqueue=1031
              dd-2924  [004]    26.569557: writeback_queue_io: bdi 8:0: older=-1 enqueue=1031
              dd-2924  [004]    26.575538: writeback_queue_io: bdi 8:0: older=-1 enqueue=1031
              dd-2924  [004]    26.585577: writeback_queue_io: bdi 8:0: older=-1 enqueue=1031
       flush-8:0-2926  [000]    26.590955: writeback_queue_io: bdi 8:0: older=30000 enqueue=0
       flush-8:0-2926  [000]    26.591606: writeback_queue_io: bdi 8:0: older=30000 enqueue=0
       flush-8:0-2926  [000]    26.592223: writeback_queue_io: bdi 8:0: older=30000 enqueue=0
       flush-8:0-2926  [000]    26.592847: writeback_queue_io: bdi 8:0: older=30000 enqueue=0
              dd-2924  [004]    26.640591: writeback_queue_io: bdi 8:0: older=-1 enqueue=1031
              dd-2924  [004]    26.643331: writeback_queue_io: bdi 8:0: older=-1 enqueue=1031
              dd-2924  [004]    26.647325: writeback_queue_io: bdi 8:0: older=-1 enqueue=1031
              dd-2924  [004]    26.653296: writeback_queue_io: bdi 8:0: older=-1 enqueue=1031
              dd-2924  [004]    26.663362: writeback_queue_io: bdi 8:0: older=-1 enqueue=1031
              dd-2924  [004]    26.685519: writeback_queue_io: bdi 8:0: older=-1 enqueue=1031
              dd-2924  [004]    26.688193: writeback_queue_io: bdi 8:0: older=-1 enqueue=1031
              dd-2924  [004]    26.692179: writeback_queue_io: bdi 8:0: older=-1 enqueue=1031
              dd-2924  [004]    26.698165: writeback_queue_io: bdi 8:0: older=-1 enqueue=1031
              dd-2924  [004]    26.708220: writeback_queue_io: bdi 8:0: older=-1 enqueue=1031
              dd-2924  [004]    26.726164: writeback_queue_io: bdi 8:0: older=-1 enqueue=1031
              dd-2924  [004]    26.767942: writeback_queue_io: bdi 8:0: older=-1 enqueue=1031
              dd-2924  [004]    26.770934: writeback_queue_io: bdi 8:0: older=-1 enqueue=1031
              dd-2924  [004]    26.774918: writeback_queue_io: bdi 8:0: older=-1 enqueue=1031
              dd-2924  [004]    26.780900: writeback_queue_io: bdi 8:0: older=-1 enqueue=1031
              dd-2924  [004]    26.790949: writeback_queue_io: bdi 8:0: older=-1 enqueue=1031
       flush-8:0-2926  [000]    26.805607: writeback_queue_io: bdi 8:0: older=30000 enqueue=0
       flush-8:0-2926  [000]    26.806142: writeback_queue_io: bdi 8:0: older=30000 enqueue=0
       flush-8:0-2926  [000]    26.806664: writeback_queue_io: bdi 8:0: older=30000 enqueue=0
              dd-2924  [004]    26.813818: writeback_queue_io: bdi 8:0: older=-1 enqueue=1031
              dd-2924  [004]    26.817798: writeback_queue_io: bdi 8:0: older=-1 enqueue=1031
              dd-2924  [004]    26.823757: writeback_queue_io: bdi 8:0: older=-1 enqueue=1031
              dd-2924  [004]    26.833839: writeback_queue_io: bdi 8:0: older=-1 enqueue=1031
              dd-2924  [004]    26.851781: writeback_queue_io: bdi 8:0: older=-1 enqueue=1031
              dd-2924  [004]    26.889973: writeback_queue_io: bdi 8:0: older=-1 enqueue=1031
              dd-2924  [004]    26.892558: writeback_queue_io: bdi 8:0: older=-1 enqueue=1031
              dd-2924  [004]    26.896556: writeback_queue_io: bdi 8:0: older=-1 enqueue=1031
              dd-2924  [004]    26.902526: writeback_queue_io: bdi 8:0: older=-1 enqueue=1031
              dd-2924  [004]    26.912575: writeback_queue_io: bdi 8:0: older=-1 enqueue=1031
              dd-2924  [004]    26.936821: writeback_queue_io: bdi 8:0: older=-1 enqueue=1031
              dd-2924  [004]    26.939411: writeback_queue_io: bdi 8:0: older=-1 enqueue=1031
              dd-2924  [004]    26.943396: writeback_queue_io: bdi 8:0: older=-1 enqueue=1031
              dd-2924  [004]    26.949395: writeback_queue_io: bdi 8:0: older=-1 enqueue=1031
              dd-2924  [004]    26.960446: writeback_queue_io: bdi 8:0: older=-1 enqueue=1031
              dd-2924  [004]    26.982589: writeback_queue_io: bdi 8:0: older=-1 enqueue=1031
              dd-2924  [004]    26.985270: writeback_queue_io: bdi 8:0: older=-1 enqueue=1031
              dd-2924  [004]    26.989254: writeback_queue_io: bdi 8:0: older=-1 enqueue=1031
              dd-2924  [004]    26.995235: writeback_queue_io: bdi 8:0: older=-1 enqueue=1031
              dd-2924  [004]    27.005289: writeback_queue_io: bdi 8:0: older=-1 enqueue=1031
       flush-8:0-2926  [000]    27.020772: writeback_queue_io: bdi 8:0: older=30000 enqueue=0
       flush-8:0-2926  [000]    27.021458: writeback_queue_io: bdi 8:0: older=30000 enqueue=0
       flush-8:0-2926  [000]    27.022110: writeback_queue_io: bdi 8:0: older=30000 enqueue=0
       flush-8:0-2926  [000]    27.022756: writeback_queue_io: bdi 8:0: older=30000 enqueue=0
              dd-2924  [004]    27.059788: writeback_queue_io: bdi 8:0: older=-1 enqueue=1031
              dd-2924  [004]    27.063028: writeback_queue_io: bdi 8:0: older=-1 enqueue=1031
              dd-2924  [004]    27.067029: writeback_queue_io: bdi 8:0: older=-1 enqueue=1031
              dd-2924  [004]    27.072994: writeback_queue_io: bdi 8:0: older=-1 enqueue=1031
              dd-2924  [004]    27.083043: writeback_queue_io: bdi 8:0: older=-1 enqueue=1031
              dd-2924  [004]    27.105317: writeback_queue_io: bdi 8:0: older=-1 enqueue=1031
              dd-2924  [004]    27.107890: writeback_queue_io: bdi 8:0: older=-1 enqueue=1031
              dd-2924  [004]    27.111874: writeback_queue_io: bdi 8:0: older=-1 enqueue=1031
              dd-2924  [004]    27.117875: writeback_queue_io: bdi 8:0: older=-1 enqueue=1031
              dd-2924  [004]    27.128905: writeback_queue_io: bdi 8:0: older=-1 enqueue=1031
              dd-2924  [004]    27.146847: writeback_queue_io: bdi 8:0: older=-1 enqueue=1031
      flush-0:15-2236  [003]    27.147835: writeback_queue_io: bdi 0:15: older=30000 enqueue=0
      flush-0:15-2236  [003]    27.147837: writeback_queue_io: bdi 0:15: older=30000 enqueue=0
      flush-0:15-2236  [003]    27.147838: writeback_queue_io: bdi 0:15: older=-1 enqueue=7
              dd-2924  [004]    27.185029: writeback_queue_io: bdi 8:0: older=-1 enqueue=1031
              dd-2924  [004]    27.187642: writeback_queue_io: bdi 8:0: older=-1 enqueue=1031
              dd-2924  [004]    27.191626: writeback_queue_io: bdi 8:0: older=-1 enqueue=1031
              dd-2924  [004]    27.197624: writeback_queue_io: bdi 8:0: older=-1 enqueue=1031
              dd-2924  [004]    27.207657: writeback_queue_io: bdi 8:0: older=-1 enqueue=1031
              dd-2924  [004]    27.225619: writeback_queue_io: bdi 8:0: older=-1 enqueue=1031
              dd-2924  [004]    27.263806: writeback_queue_io: bdi 8:0: older=-1 enqueue=1031
              dd-2924  [004]    27.266398: writeback_queue_io: bdi 8:0: older=-1 enqueue=1031
       flush-8:0-2926  [000]    27.269975: writeback_queue_io: bdi 8:0: older=30000 enqueue=0
       flush-8:0-2926  [000]    27.270547: writeback_queue_io: bdi 8:0: older=30000 enqueue=0
       flush-8:0-2926  [000]    27.271073: writeback_queue_io: bdi 8:0: older=30000 enqueue=0
       flush-8:0-2926  [000]    27.271668: writeback_queue_io: bdi 8:0: older=30000 enqueue=0
              dd-2924  [004]    27.282430: writeback_queue_io: bdi 8:0: older=-1 enqueue=1031
              dd-2924  [004]    27.300327: writeback_queue_io: bdi 8:0: older=-1 enqueue=1031
              dd-2924  [004]    27.334286: writeback_queue_io: bdi 8:0: older=-1 enqueue=1031
              dd-2924  [004]    27.404365: writeback_queue_io: bdi 8:0: older=-1 enqueue=1031
              dd-2924  [004]    27.406962: writeback_queue_io: bdi 8:0: older=-1 enqueue=1031
              dd-2924  [004]    27.410946: writeback_queue_io: bdi 8:0: older=-1 enqueue=1031
              dd-2924  [004]    27.416941: writeback_queue_io: bdi 8:0: older=-1 enqueue=1031
              dd-2924  [004]    27.431265: writeback_queue_io: bdi 8:0: older=-1 enqueue=1031
              dd-2924  [004]    27.433879: writeback_queue_io: bdi 8:0: older=-1 enqueue=1031
              dd-2924  [004]    27.437864: writeback_queue_io: bdi 8:0: older=-1 enqueue=1031
              dd-2924  [004]    27.443847: writeback_queue_io: bdi 8:0: older=-1 enqueue=1031
              dd-2924  [004]    27.454915: writeback_queue_io: bdi 8:0: older=-1 enqueue=1031
              dd-2924  [004]    27.472774: writeback_queue_io: bdi 8:0: older=-1 enqueue=1031
              dd-2924  [004]    27.511740: writeback_queue_io: bdi 8:0: older=-1 enqueue=1031
              dd-2924  [004]    27.514627: writeback_queue_io: bdi 8:0: older=-1 enqueue=1031
              dd-2924  [004]    27.518613: writeback_queue_io: bdi 8:0: older=-1 enqueue=1031
              dd-2924  [004]    27.524619: writeback_queue_io: bdi 8:0: older=-1 enqueue=1031
              dd-2924  [004]    27.536642: writeback_queue_io: bdi 8:0: older=-1 enqueue=1031
              dd-2924  [000]    27.554552: writeback_queue_io: bdi 8:0: older=-1 enqueue=1031
       flush-8:0-2926  [000]    27.559462: writeback_queue_io: bdi 8:0: older=30000 enqueue=0
       flush-8:0-2926  [000]    27.560050: writeback_queue_io: bdi 8:0: older=30000 enqueue=0
       flush-8:0-2926  [000]    27.560609: writeback_queue_io: bdi 8:0: older=30000 enqueue=0
              dd-2924  [004]    27.597436: writeback_queue_io: bdi 8:0: older=-1 enqueue=1031
              dd-2924  [004]    27.601358: writeback_queue_io: bdi 8:0: older=-1 enqueue=1031
              dd-2924  [004]    27.607354: writeback_queue_io: bdi 8:0: older=-1 enqueue=1031
              dd-2924  [004]    27.617380: writeback_queue_io: bdi 8:0: older=-1 enqueue=1031
              dd-2924  [004]    27.635305: writeback_queue_io: bdi 8:0: older=-1 enqueue=1031
              dd-2924  [004]    27.669223: writeback_queue_io: bdi 8:0: older=-1 enqueue=1031
              dd-2924  [004]    27.735048: writeback_queue_io: bdi 8:0: older=-1 enqueue=1031
              dd-2924  [004]    27.840764: writeback_queue_io: bdi 8:0: older=-1 enqueue=1031
              dd-2924  [004]    27.843624: writeback_queue_io: bdi 8:0: older=-1 enqueue=1031
              dd-2924  [004]    27.847593: writeback_queue_io: bdi 8:0: older=-1 enqueue=1031
              dd-2924  [004]    27.853588: writeback_queue_io: bdi 8:0: older=-1 enqueue=1031
              dd-2924  [004]    27.863656: writeback_queue_io: bdi 8:0: older=-1 enqueue=1031
              dd-2924  [004]    27.881511: writeback_queue_io: bdi 8:0: older=-1 enqueue=1031
              dd-2924  [004]    27.919954: writeback_queue_io: bdi 8:0: older=-1 enqueue=1031
              dd-2924  [004]    27.923361: writeback_queue_io: bdi 8:0: older=-1 enqueue=1031
              dd-2924  [004]    27.927346: writeback_queue_io: bdi 8:0: older=-1 enqueue=1031
              dd-2924  [004]    27.933343: writeback_queue_io: bdi 8:0: older=-1 enqueue=1031
              dd-2924  [004]    27.945397: writeback_queue_io: bdi 8:0: older=-1 enqueue=1031
       flush-8:0-2926  [000]    27.959128: writeback_queue_io: bdi 8:0: older=30000 enqueue=0
       flush-8:0-2926  [000]    27.959970: writeback_queue_io: bdi 8:0: older=30000 enqueue=0
       flush-8:0-2926  [000]    27.960815: writeback_queue_io: bdi 8:0: older=30000 enqueue=0
       flush-8:0-2926  [000]    27.961659: writeback_queue_io: bdi 8:0: older=30000 enqueue=0
              dd-2924  [004]    27.995244: writeback_queue_io: bdi 8:0: older=-1 enqueue=1031
              dd-2924  [004]    28.066062: writeback_queue_io: bdi 8:0: older=-1 enqueue=1031
              dd-2924  [004]    28.068912: writeback_queue_io: bdi 8:0: older=-1 enqueue=1031
              dd-2924  [004]    28.072910: writeback_queue_io: bdi 8:0: older=-1 enqueue=1031
              dd-2924  [004]    28.078877: writeback_queue_io: bdi 8:0: older=-1 enqueue=1031
              dd-2924  [004]    28.088952: writeback_queue_io: bdi 8:0: older=-1 enqueue=1031
              dd-2924  [004]    28.108861: writeback_queue_io: bdi 8:0: older=-1 enqueue=1031
              dd-2924  [004]    28.146792: writeback_queue_io: bdi 8:0: older=-1 enqueue=1031
              dd-2924  [004]    28.149662: writeback_queue_io: bdi 8:0: older=-1 enqueue=1031
              dd-2924  [004]    28.153661: writeback_queue_io: bdi 8:0: older=-1 enqueue=1031
              dd-2924  [004]    28.159627: writeback_queue_io: bdi 8:0: older=-1 enqueue=1031
              dd-2924  [004]    28.169665: writeback_queue_io: bdi 8:0: older=-1 enqueue=1031
              dd-2924  [004]    28.187632: writeback_queue_io: bdi 8:0: older=-1 enqueue=1031
              dd-2924  [000]    28.221484: writeback_queue_io: bdi 8:0: older=-1 enqueue=1031
              dd-2924  [004]    28.298654: writeback_queue_io: bdi 8:0: older=-1 enqueue=1031
              dd-2924  [004]    28.303188: writeback_queue_io: bdi 8:0: older=-1 enqueue=1031
              dd-2924  [004]    28.307168: writeback_queue_io: bdi 8:0: older=-1 enqueue=1031
              dd-2924  [004]    28.313250: writeback_queue_io: bdi 8:0: older=-1 enqueue=1031
       flush-8:0-2926  [004]    28.318308: writeback_queue_io: bdi 8:0: older=30000 enqueue=0
       flush-8:0-2926  [004]    28.319040: writeback_queue_io: bdi 8:0: older=30000 enqueue=0
       flush-8:0-2926  [004]    28.319606: writeback_queue_io: bdi 8:0: older=30000 enqueue=0
              dd-2924  [004]    28.328146: writeback_queue_io: bdi 8:0: older=-1 enqueue=1031
              dd-2924  [004]    28.332107: writeback_queue_io: bdi 8:0: older=-1 enqueue=1031
              dd-2924  [004]    28.338074: writeback_queue_io: bdi 8:0: older=-1 enqueue=1031
              dd-2924  [004]    28.348142: writeback_queue_io: bdi 8:0: older=-1 enqueue=1031
              dd-2924  [004]    28.366085: writeback_queue_io: bdi 8:0: older=-1 enqueue=1031
              dd-2924  [004]    28.399983: writeback_queue_io: bdi 8:0: older=-1 enqueue=1031
              dd-2924  [004]    28.470246: writeback_queue_io: bdi 8:0: older=-1 enqueue=1031
              dd-2924  [004]    28.473655: writeback_queue_io: bdi 8:0: older=-1 enqueue=1031
              dd-2924  [004]    28.477655: writeback_queue_io: bdi 8:0: older=-1 enqueue=1031
              dd-2924  [004]    28.483634: writeback_queue_io: bdi 8:0: older=-1 enqueue=1031
              dd-2924  [004]    28.493694: writeback_queue_io: bdi 8:0: older=-1 enqueue=1031
              dd-2924  [004]    28.515558: writeback_queue_io: bdi 8:0: older=-1 enqueue=1031
              dd-2924  [004]    28.518517: writeback_queue_io: bdi 8:0: older=-1 enqueue=1031
              dd-2924  [004]    28.522515: writeback_queue_io: bdi 8:0: older=-1 enqueue=1031
              dd-2924  [004]    28.528485: writeback_queue_io: bdi 8:0: older=-1 enqueue=1031
              dd-2924  [004]    28.538567: writeback_queue_io: bdi 8:0: older=-1 enqueue=1031
              dd-2924  [004]    28.556496: writeback_queue_io: bdi 8:0: older=-1 enqueue=1031
              dd-2924  [004]    28.590391: writeback_queue_io: bdi 8:0: older=-1 enqueue=1031
              dd-2924  [004]    28.656190: writeback_queue_io: bdi 8:0: older=-1 enqueue=1031
       flush-8:0-2926  [000]    28.689116: writeback_queue_io: bdi 8:0: older=30000 enqueue=0
       flush-8:0-2926  [000]    28.690321: writeback_queue_io: bdi 8:0: older=30000 enqueue=0
       flush-8:0-2926  [000]    28.691531: writeback_queue_io: bdi 8:0: older=30000 enqueue=0
       flush-8:0-2926  [000]    28.692726: writeback_queue_io: bdi 8:0: older=30000 enqueue=0
              dd-2924  [004]    28.767809: writeback_queue_io: bdi 8:0: older=-1 enqueue=1031
              dd-2924  [004]    28.771741: writeback_queue_io: bdi 8:0: older=-1 enqueue=1031
              dd-2924  [004]    28.777711: writeback_queue_io: bdi 8:0: older=-1 enqueue=1031
              dd-2924  [004]    28.787729: writeback_queue_io: bdi 8:0: older=-1 enqueue=1031
              dd-2924  [004]    28.809691: writeback_queue_io: bdi 8:0: older=-1 enqueue=1031
              dd-2924  [004]    28.812605: writeback_queue_io: bdi 8:0: older=-1 enqueue=1031
              dd-2924  [004]    28.816589: writeback_queue_io: bdi 8:0: older=-1 enqueue=1031
              dd-2924  [004]    28.822587: writeback_queue_io: bdi 8:0: older=-1 enqueue=1031
              dd-2924  [004]    28.833640: writeback_queue_io: bdi 8:0: older=-1 enqueue=1031
              dd-2924  [004]    28.851581: writeback_queue_io: bdi 8:0: older=-1 enqueue=1031
              dd-2924  [004]    28.885485: writeback_queue_io: bdi 8:0: older=-1 enqueue=1031
       flush-8:0-2926  [000]    28.913598: writeback_queue_io: bdi 8:0: older=30000 enqueue=0
       flush-8:0-2926  [000]    28.914827: writeback_queue_io: bdi 8:0: older=30000 enqueue=0
       flush-8:0-2926  [000]    28.916034: writeback_queue_io: bdi 8:0: older=30000 enqueue=0
              dd-2924  [004]    28.960225: writeback_queue_io: bdi 8:0: older=-1 enqueue=1031
              dd-2924  [004]    28.964132: writeback_queue_io: bdi 8:0: older=-1 enqueue=1031
              dd-2924  [004]    28.970123: writeback_queue_io: bdi 8:0: older=-1 enqueue=1031
              dd-2924  [004]    28.980180: writeback_queue_io: bdi 8:0: older=-1 enqueue=1031
              dd-2924  [004]    28.998043: writeback_queue_io: bdi 8:0: older=-1 enqueue=1031
              dd-2924  [000]    29.036041: writeback_queue_io: bdi 8:0: older=-1 enqueue=1031
              dd-2924  [002]    29.038910: writeback_queue_io: bdi 8:0: older=-1 enqueue=1031
              dd-2924  [002]    29.042891: writeback_queue_io: bdi 8:0: older=-1 enqueue=1031
              dd-2924  [002]    29.049003: writeback_queue_io: bdi 8:0: older=-1 enqueue=1031
              dd-2924  [002]    29.058970: writeback_queue_io: bdi 8:0: older=-1 enqueue=1031
              dd-2924  [002]    29.077930: writeback_queue_io: bdi 8:0: older=-1 enqueue=1031
              dd-2924  [002]    29.111824: writeback_queue_io: bdi 8:0: older=-1 enqueue=1031
             tar-2923  [001]    29.151841: writeback_queue_io: bdi 8:0: older=-1 enqueue=1038
       flush-8:0-2926  [000]    29.167378: writeback_queue_io: bdi 8:0: older=30000 enqueue=0
       flush-8:0-2926  [000]    29.168022: writeback_queue_io: bdi 8:0: older=30000 enqueue=0
       flush-8:0-2926  [000]    29.168674: writeback_queue_io: bdi 8:0: older=30000 enqueue=0
       flush-8:0-2926  [000]    29.169302: writeback_queue_io: bdi 8:0: older=30000 enqueue=0
              dd-2924  [002]    29.186509: writeback_queue_io: bdi 8:0: older=-1 enqueue=1002
              dd-2924  [002]    29.190441: writeback_queue_io: bdi 8:0: older=-1 enqueue=1002
              dd-2924  [002]    29.196444: writeback_queue_io: bdi 8:0: older=-1 enqueue=1002
              dd-2924  [002]    29.206423: writeback_queue_io: bdi 8:0: older=-1 enqueue=1002
              dd-2924  [002]    29.228680: writeback_queue_io: bdi 8:0: older=-1 enqueue=1002
              dd-2924  [002]    29.231307: writeback_queue_io: bdi 8:0: older=-1 enqueue=1002
              dd-2924  [002]    29.235292: writeback_queue_io: bdi 8:0: older=-1 enqueue=1002
              dd-2924  [002]    29.241423: writeback_queue_io: bdi 8:0: older=-1 enqueue=1002
              dd-2924  [002]    29.251370: writeback_queue_io: bdi 8:0: older=-1 enqueue=1002
              dd-2924  [002]    29.273377: writeback_queue_io: bdi 8:0: older=-1 enqueue=1002
              dd-2924  [002]    29.276170: writeback_queue_io: bdi 8:0: older=-1 enqueue=1002
              dd-2924  [002]    29.280160: writeback_queue_io: bdi 8:0: older=-1 enqueue=1002
              dd-2924  [002]    29.286250: writeback_queue_io: bdi 8:0: older=-1 enqueue=1002
              dd-2924  [002]    29.296235: writeback_queue_io: bdi 8:0: older=-1 enqueue=1002
              dd-2924  [002]    29.314179: writeback_queue_io: bdi 8:0: older=-1 enqueue=1002
       flush-8:0-2926  [000]    29.344570: writeback_queue_io: bdi 8:0: older=30000 enqueue=0
       flush-8:0-2926  [000]    29.345137: writeback_queue_io: bdi 8:0: older=30000 enqueue=0
       flush-8:0-2926  [000]    29.345692: writeback_queue_io: bdi 8:0: older=30000 enqueue=0
              dd-2924  [002]    29.352985: writeback_queue_io: bdi 8:0: older=-1 enqueue=1020
       flush-8:0-2926  [004]    30.357613: writeback_queue_io: bdi 8:0: older=30000 enqueue=0
       flush-8:0-2926  [004]    30.358274: writeback_queue_io: bdi 8:0: older=30000 enqueue=0
       flush-8:0-2926  [004]    30.358910: writeback_queue_io: bdi 8:0: older=30000 enqueue=0
       flush-8:0-2926  [004]    30.359916: writeback_queue_io: bdi 8:0: older=30000 enqueue=0
       flush-8:0-2926  [004]    30.360948: writeback_queue_io: bdi 8:0: older=30000 enqueue=0
       flush-8:0-2926  [004]    30.361981: writeback_queue_io: bdi 8:0: older=30000 enqueue=0
       flush-8:0-2926  [004]    30.363002: writeback_queue_io: bdi 8:0: older=30000 enqueue=0
       flush-8:0-2926  [004]    30.363940: writeback_queue_io: bdi 8:0: older=30000 enqueue=0
       flush-8:0-2926  [004]    30.364613: writeback_queue_io: bdi 8:0: older=30000 enqueue=0
       flush-8:0-2926  [004]    30.365310: writeback_queue_io: bdi 8:0: older=30000 enqueue=0
       flush-8:0-2926  [004]    30.366024: writeback_queue_io: bdi 8:0: older=30000 enqueue=0
       flush-8:0-2926  [004]    30.366711: writeback_queue_io: bdi 8:0: older=30000 enqueue=0
       flush-8:0-2926  [004]    30.367400: writeback_queue_io: bdi 8:0: older=30000 enqueue=0
       flush-8:0-2926  [004]    30.368090: writeback_queue_io: bdi 8:0: older=30000 enqueue=0
             tar-2923  [003]    30.406614: writeback_queue_io: bdi 8:0: older=-1 enqueue=3212
      flush-0:15-2236  [000]    32.132363: writeback_queue_io: bdi 0:15: older=30000 enqueue=0
      flush-0:15-2236  [000]    32.132367: writeback_queue_io: bdi 0:15: older=30000 enqueue=0
      flush-0:15-2236  [000]    32.132370: writeback_queue_io: bdi 0:15: older=-1 enqueue=7
      flush-0:15-2236  [000]    32.132451: writeback_queue_io: bdi 0:15: older=30000 enqueue=0
      flush-0:15-2236  [000]    32.132453: writeback_queue_io: bdi 0:15: older=-1 enqueue=7
       flush-8:0-2926  [002]    32.142432: writeback_queue_io: bdi 8:0: older=30000 enqueue=0
       flush-8:0-2926  [002]    32.143079: writeback_queue_io: bdi 8:0: older=30000 enqueue=0
       flush-8:0-2926  [002]    32.143705: writeback_queue_io: bdi 8:0: older=30000 enqueue=0
       flush-8:0-2926  [002]    32.144375: writeback_queue_io: bdi 8:0: older=30000 enqueue=0
       flush-8:0-2926  [002]    32.144960: writeback_queue_io: bdi 8:0: older=30000 enqueue=0
       flush-8:0-2926  [002]    32.145543: writeback_queue_io: bdi 8:0: older=30000 enqueue=0
       flush-8:0-2926  [002]    32.146114: writeback_queue_io: bdi 8:0: older=30000 enqueue=0
       flush-8:0-2926  [002]    32.146761: writeback_queue_io: bdi 8:0: older=30000 enqueue=0
       flush-8:0-2926  [002]    32.147327: writeback_queue_io: bdi 8:0: older=30000 enqueue=0
       flush-8:0-2926  [002]    32.147899: writeback_queue_io: bdi 8:0: older=30000 enqueue=0
       flush-8:0-2926  [002]    32.148565: writeback_queue_io: bdi 8:0: older=30000 enqueue=0
       flush-8:0-2926  [002]    32.149128: writeback_queue_io: bdi 8:0: older=30000 enqueue=0
       flush-8:0-2926  [002]    32.149708: writeback_queue_io: bdi 8:0: older=30000 enqueue=0
       flush-8:0-2926  [002]    32.150306: writeback_queue_io: bdi 8:0: older=30000 enqueue=0
       flush-8:0-2926  [002]    32.150871: writeback_queue_io: bdi 8:0: older=30000 enqueue=0
       flush-8:0-2926  [002]    32.151452: writeback_queue_io: bdi 8:0: older=30000 enqueue=0
       flush-8:0-2926  [002]    32.384772: writeback_queue_io: bdi 8:0: older=30000 enqueue=0
       flush-8:0-2926  [002]    32.385781: writeback_queue_io: bdi 8:0: older=30000 enqueue=0
       flush-8:0-2926  [002]    34.108661: writeback_queue_io: bdi 8:0: older=30000 enqueue=0
       flush-8:0-2926  [002]    34.109353: writeback_queue_io: bdi 8:0: older=30000 enqueue=0
       flush-8:0-2926  [002]    34.109966: writeback_queue_io: bdi 8:0: older=30000 enqueue=0
       flush-8:0-2926  [002]    34.110583: writeback_queue_io: bdi 8:0: older=30000 enqueue=0
       flush-8:0-2926  [002]    34.111194: writeback_queue_io: bdi 8:0: older=30000 enqueue=0
       flush-8:0-2926  [002]    34.111773: writeback_queue_io: bdi 8:0: older=30000 enqueue=0
       flush-8:0-2926  [002]    34.112361: writeback_queue_io: bdi 8:0: older=30000 enqueue=0
       flush-8:0-2926  [002]    34.112941: writeback_queue_io: bdi 8:0: older=30000 enqueue=0
       flush-8:0-2926  [002]    34.113530: writeback_queue_io: bdi 8:0: older=30000 enqueue=0
       flush-8:0-2926  [002]    34.114107: writeback_queue_io: bdi 8:0: older=30000 enqueue=0
       flush-8:0-2926  [002]    34.114705: writeback_queue_io: bdi 8:0: older=30000 enqueue=0
       flush-8:0-2926  [002]    34.115289: writeback_queue_io: bdi 8:0: older=30000 enqueue=0
       flush-8:0-2926  [002]    34.115865: writeback_queue_io: bdi 8:0: older=30000 enqueue=0
       flush-8:0-2926  [002]    34.116449: writeback_queue_io: bdi 8:0: older=30000 enqueue=0
       flush-8:0-2926  [002]    34.117028: writeback_queue_io: bdi 8:0: older=30000 enqueue=0
       flush-8:0-2926  [002]    34.117614: writeback_queue_io: bdi 8:0: older=30000 enqueue=0
       flush-8:0-2926  [002]    34.118197: writeback_queue_io: bdi 8:0: older=30000 enqueue=0
       flush-8:0-2926  [002]    34.118773: writeback_queue_io: bdi 8:0: older=30000 enqueue=0
       flush-8:0-2926  [002]    34.119354: writeback_queue_io: bdi 8:0: older=30000 enqueue=0
       flush-8:0-2926  [002]    34.293855: writeback_queue_io: bdi 8:0: older=30000 enqueue=0
       flush-8:0-2926  [002]    34.294470: writeback_queue_io: bdi 8:0: older=30000 enqueue=0
       flush-8:0-2926  [002]    34.295067: writeback_queue_io: bdi 8:0: older=30000 enqueue=0
       flush-8:0-2926  [002]    34.492814: writeback_queue_io: bdi 8:0: older=30000 enqueue=0
       flush-8:0-2926  [002]    34.493443: writeback_queue_io: bdi 8:0: older=30000 enqueue=0
       flush-8:0-2926  [002]    34.494024: writeback_queue_io: bdi 8:0: older=30000 enqueue=0
       flush-8:0-2926  [002]    34.494598: writeback_queue_io: bdi 8:0: older=30000 enqueue=0
       flush-8:0-2926  [002]    34.705300: writeback_queue_io: bdi 8:0: older=30000 enqueue=0
       flush-8:0-2926  [002]    34.706149: writeback_queue_io: bdi 8:0: older=30000 enqueue=0
       flush-8:0-2926  [002]    34.706733: writeback_queue_io: bdi 8:0: older=30000 enqueue=0
       flush-8:0-2926  [002]    34.921688: writeback_queue_io: bdi 8:0: older=30000 enqueue=0
       flush-8:0-2926  [002]    34.922297: writeback_queue_io: bdi 8:0: older=30000 enqueue=0
       flush-8:0-2926  [002]    34.922873: writeback_queue_io: bdi 8:0: older=30000 enqueue=0
       flush-8:0-2926  [002]    34.923422: writeback_queue_io: bdi 8:0: older=30000 enqueue=0
       flush-8:0-2926  [002]    35.130528: writeback_queue_io: bdi 8:0: older=30000 enqueue=0
       flush-8:0-2926  [002]    35.131113: writeback_queue_io: bdi 8:0: older=30000 enqueue=0
       flush-8:0-2926  [002]    35.131663: writeback_queue_io: bdi 8:0: older=30000 enqueue=0
       flush-8:0-2926  [002]    35.132219: writeback_queue_io: bdi 8:0: older=30000 enqueue=0
       flush-8:0-2926  [002]    35.345774: writeback_queue_io: bdi 8:0: older=30000 enqueue=0
       flush-8:0-2926  [002]    35.346368: writeback_queue_io: bdi 8:0: older=30000 enqueue=0
       flush-8:0-2926  [002]    35.346914: writeback_queue_io: bdi 8:0: older=30000 enqueue=0
       flush-8:0-2926  [002]    35.660761: writeback_queue_io: bdi 8:0: older=30000 enqueue=0
       flush-8:0-2926  [002]    35.661339: writeback_queue_io: bdi 8:0: older=30000 enqueue=0
       flush-8:0-2926  [002]    35.661889: writeback_queue_io: bdi 8:0: older=30000 enqueue=0
       flush-8:0-2926  [002]    35.662474: writeback_queue_io: bdi 8:0: older=30000 enqueue=0
       flush-8:0-2926  [002]    35.868558: writeback_queue_io: bdi 8:0: older=30000 enqueue=0
       flush-8:0-2926  [002]    35.869192: writeback_queue_io: bdi 8:0: older=30000 enqueue=0
       flush-8:0-2926  [002]    35.869756: writeback_queue_io: bdi 8:0: older=30000 enqueue=0
       flush-8:0-2926  [002]    36.084358: writeback_queue_io: bdi 8:0: older=30000 enqueue=0
       flush-8:0-2926  [002]    36.084930: writeback_queue_io: bdi 8:0: older=30000 enqueue=0
       flush-8:0-2926  [002]    36.085490: writeback_queue_io: bdi 8:0: older=30000 enqueue=0
       flush-8:0-2926  [002]    36.086073: writeback_queue_io: bdi 8:0: older=30000 enqueue=0
       flush-8:0-2926  [002]    36.285689: writeback_queue_io: bdi 8:0: older=30000 enqueue=0
       flush-8:0-2926  [002]    36.286257: writeback_queue_io: bdi 8:0: older=30000 enqueue=0
       flush-8:0-2926  [002]    36.286820: writeback_queue_io: bdi 8:0: older=30000 enqueue=0
       flush-8:0-2926  [002]    36.613493: writeback_queue_io: bdi 8:0: older=30000 enqueue=0
       flush-8:0-2926  [002]    36.614062: writeback_queue_io: bdi 8:0: older=30000 enqueue=0
       flush-8:0-2926  [002]    36.614626: writeback_queue_io: bdi 8:0: older=30000 enqueue=0
       flush-8:0-2926  [002]    36.615175: writeback_queue_io: bdi 8:0: older=30000 enqueue=0
       flush-8:0-2926  [002]    37.001846: writeback_queue_io: bdi 8:0: older=30000 enqueue=0
       flush-8:0-2926  [002]    37.002698: writeback_queue_io: bdi 8:0: older=30000 enqueue=0
       flush-8:0-2926  [002]    37.003253: writeback_queue_io: bdi 8:0: older=30000 enqueue=0
       flush-8:0-2926  [002]    37.003800: writeback_queue_io: bdi 8:0: older=30000 enqueue=0
      flush-0:15-2236  [004]    37.116839: writeback_queue_io: bdi 0:15: older=30000 enqueue=0
       flush-8:0-2926  [000]    37.383966: writeback_queue_io: bdi 8:0: older=30000 enqueue=0
       flush-8:0-2926  [000]    37.384554: writeback_queue_io: bdi 8:0: older=30000 enqueue=0
       flush-8:0-2926  [000]    37.385108: writeback_queue_io: bdi 8:0: older=30000 enqueue=0
       flush-8:0-2926  [000]    37.808417: writeback_queue_io: bdi 8:0: older=30000 enqueue=0
       flush-8:0-2926  [000]    37.809034: writeback_queue_io: bdi 8:0: older=30000 enqueue=0
       flush-8:0-2926  [000]    37.809452: writeback_queue_io: bdi 8:0: older=30000 enqueue=0
      flush-0:15-2236  [004]    42.101397: writeback_queue_io: bdi 0:15: older=30000 enqueue=1
       flush-8:0-2926  [002]    42.299344: writeback_queue_io: bdi 8:0: older=30000 enqueue=0
       flush-8:0-2926  [002]    42.299346: writeback_queue_io: bdi 8:0: older=30000 enqueue=0
       flush-8:0-2926  [002]    42.301467: writeback_queue_io: bdi 8:0: older=-1 enqueue=23904
      flush-0:15-2236  [004]    47.085941: writeback_queue_io: bdi 0:15: older=30000 enqueue=6
      flush-0:15-2236  [004]    47.085979: writeback_queue_io: bdi 0:15: older=30000 enqueue=0
      flush-0:15-2236  [004]    47.085981: writeback_queue_io: bdi 0:15: older=30000 enqueue=0
      flush-0:15-2236  [004]    47.085982: writeback_queue_io: bdi 0:15: older=-1 enqueue=7
      flush-0:15-2236  [004]    48.937186: writeback_queue_io: bdi 0:15: older=-1 enqueue=7
      flush-0:15-2236  [004]    48.937304: writeback_queue_io: bdi 0:15: older=-1 enqueue=7
      flush-0:15-2236  [004]    48.937330: writeback_queue_io: bdi 0:15: older=0 enqueue=7
       flush-8:0-2926  [003]    48.947592: writeback_queue_io: bdi 8:0: older=-1 enqueue=35715
      flush-0:15-2236  [004]    53.921831: writeback_queue_io: bdi 0:15: older=30000 enqueue=0
       flush-8:0-2926  [003]    54.465097: writeback_queue_io: bdi 8:0: older=-1 enqueue=34518
       flush-8:0-2926  [003]    54.556999: writeback_queue_io: bdi 8:0: older=-1 enqueue=34271
       flush-8:0-2926  [003]    54.641888: writeback_queue_io: bdi 8:0: older=3 enqueue=34271
       flush-8:0-2926  [003]    54.733057: writeback_queue_io: bdi 8:0: older=30000 enqueue=0
      flush-0:15-2236  [004]    54.733153: writeback_queue_io: bdi 0:15: older=0 enqueue=7
      flush-0:15-2236  [004]    54.733175: writeback_queue_io: bdi 0:15: older=0 enqueue=0
       flush-8:0-2926  [003]    54.735958: writeback_queue_io: bdi 8:0: older=2 enqueue=34271
       flush-8:0-2926  [003]    57.066536: writeback_queue_io: bdi 8:0: older=2340 enqueue=3
       flush-8:0-2926  [003]    57.066544: writeback_queue_io: bdi 8:0: older=2340 enqueue=0
      flush-0:15-2236  [004]    68.683073: writeback_queue_io: bdi 0:15: older=30000 enqueue=0
      flush-0:15-2236  [004]    73.667542: writeback_queue_io: bdi 0:15: older=30000 enqueue=0
      flush-0:15-2236  [004]    78.652162: writeback_queue_io: bdi 0:15: older=30000 enqueue=0
      flush-0:15-2236  [004]    83.636732: writeback_queue_io: bdi 0:15: older=30000 enqueue=0
      flush-0:15-2236  [004]    88.621260: writeback_queue_io: bdi 0:15: older=30000 enqueue=0

--9amGYk9869ThD9tj
Content-Type: text/plain; charset=us-ascii
Content-Disposition: attachment; filename="trace-2.6.39-rc3"

root@fat /home/wfg# bin/test-tar-dd.sh
umount: /dev/sda7: not mounted
meta-data=/dev/sda7              isize=256    agcount=4, agsize=6170464 blks
         =                       sectsz=512   attr=2
data     =                       bsize=4096   blocks=24681856, imaxpct=25
         =                       sunit=0      swidth=0 blks
naming   =version 2              bsize=4096   ascii-ci=0
log      =internal log           bsize=4096   blocks=12051, version=2
         =                       sectsz=512   sunit=0 blks, lazy-count=1
realtime =none                   extsz=4096   blocks=0, rtextents=0
bin/test-tar-dd.sh:14: no such file or directory: /debug/tracing/events/writeback/writeback_single_inode/enable
280.90 2235.98
1000+0 records in
1000+0 records out
1048576000 bytes (1.0 GB) copied, 14.8681 s, 70.5 MB/s
dd if=/dev/zero of=/fs/zero bs=1M count=1000  0.00s user 1.48s system 9% cpu 14.888 total
tar jxf /dev/shm/linux-2.6.38.3.tar.bz2  12.42s user 4.33s system 49% cpu 33.563 total
322.49 2524.47
elapsed: 288.99000000000024

# tracer: nop
#
#           TASK-PID    CPU#    TIMESTAMP  FUNCTION
#              | |       |          |         |
       flush-8:0-2939  [006]   289.234869: writeback_queue_io: bdi 8:0: older=30000 enqueue=0
       flush-8:0-2939  [006]   289.234872: writeback_queue_io: bdi 8:0: older=-1 enqueue=1
       flush-8:0-2939  [000]   289.244973: writeback_queue_io: bdi 8:0: older=-1 enqueue=0
       flush-8:0-2939  [000]   289.249918: writeback_queue_io: bdi 8:0: older=-1 enqueue=0
       flush-8:0-2939  [000]   289.254722: writeback_queue_io: bdi 8:0: older=-1 enqueue=0
       flush-8:0-2939  [000]   289.259679: writeback_queue_io: bdi 8:0: older=-1 enqueue=0
       flush-8:0-2939  [000]   289.264460: writeback_queue_io: bdi 8:0: older=-1 enqueue=0
       flush-8:0-2939  [002]   289.270664: writeback_queue_io: bdi 8:0: older=-1 enqueue=0
       flush-8:0-2939  [002]   289.274682: writeback_queue_io: bdi 8:0: older=-1 enqueue=0
       flush-8:0-2939  [002]   289.279065: writeback_queue_io: bdi 8:0: older=-1 enqueue=0
       flush-8:0-2939  [002]   289.283450: writeback_queue_io: bdi 8:0: older=-1 enqueue=0
       flush-8:0-2939  [002]   289.287875: writeback_queue_io: bdi 8:0: older=-1 enqueue=0
       flush-8:0-2939  [002]   289.292278: writeback_queue_io: bdi 8:0: older=-1 enqueue=0
       flush-8:0-2939  [002]   289.297190: writeback_queue_io: bdi 8:0: older=-1 enqueue=0
       flush-8:0-2939  [002]   289.302320: writeback_queue_io: bdi 8:0: older=-1 enqueue=0
       flush-8:0-2939  [002]   289.307390: writeback_queue_io: bdi 8:0: older=-1 enqueue=4
       flush-8:0-2939  [002]   289.311641: writeback_queue_io: bdi 8:0: older=-1 enqueue=0
       flush-8:0-2939  [002]   289.315871: writeback_queue_io: bdi 8:0: older=-1 enqueue=4
       flush-8:0-2939  [002]   289.320143: writeback_queue_io: bdi 8:0: older=-1 enqueue=0
       flush-8:0-2939  [002]   289.324426: writeback_queue_io: bdi 8:0: older=-1 enqueue=4
       flush-8:0-2939  [002]   289.328687: writeback_queue_io: bdi 8:0: older=-1 enqueue=0
              dd-2938  [004]   289.399926: writeback_queue_io: bdi 8:0: older=-1 enqueue=4
              dd-2938  [004]   289.400601: writeback_queue_io: bdi 8:0: older=-1 enqueue=4
              dd-2938  [004]   289.402595: writeback_queue_io: bdi 8:0: older=-1 enqueue=4
              dd-2938  [004]   289.406672: writeback_queue_io: bdi 8:0: older=-1 enqueue=4
              dd-2938  [004]   289.414706: writeback_queue_io: bdi 8:0: older=-1 enqueue=4
              dd-2938  [004]   289.430701: writeback_queue_io: bdi 8:0: older=-1 enqueue=4
              dd-2938  [004]   289.462702: writeback_queue_io: bdi 8:0: older=-1 enqueue=4
              dd-2938  [004]   289.526711: writeback_queue_io: bdi 8:0: older=-1 enqueue=4
             tar-2937  [000]   289.618775: writeback_queue_io: bdi 8:0: older=-1 enqueue=5
              dd-2938  [004]   289.626643: writeback_queue_io: bdi 8:0: older=-1 enqueue=4
              dd-2938  [004]   289.738324: writeback_queue_io: bdi 8:0: older=-1 enqueue=4
              dd-2938  [004]   289.738611: writeback_queue_io: bdi 8:0: older=-1 enqueue=4
              dd-2938  [004]   289.740605: writeback_queue_io: bdi 8:0: older=-1 enqueue=4
              dd-2938  [004]   289.744693: writeback_queue_io: bdi 8:0: older=-1 enqueue=4
              dd-2938  [004]   289.752691: writeback_queue_io: bdi 8:0: older=-1 enqueue=4
      flush-0:15-2212  [007]   289.763781: writeback_queue_io: bdi 0:15: older=30000 enqueue=1
      flush-0:15-2212  [007]   289.763813: writeback_queue_io: bdi 0:15: older=-1 enqueue=8
              dd-2938  [004]   289.772835: writeback_queue_io: bdi 8:0: older=-1 enqueue=4
              dd-2938  [004]   289.773643: writeback_queue_io: bdi 8:0: older=-1 enqueue=4
              dd-2938  [004]   289.775615: writeback_queue_io: bdi 8:0: older=-1 enqueue=4
              dd-2938  [004]   289.779692: writeback_queue_io: bdi 8:0: older=-1 enqueue=4
              dd-2938  [004]   289.787702: writeback_queue_io: bdi 8:0: older=-1 enqueue=4
       flush-8:0-2939  [002]   289.788072: writeback_queue_io: bdi 8:0: older=-1 enqueue=4
              dd-2938  [004]   289.803711: writeback_queue_io: bdi 8:0: older=-1 enqueue=0
       flush-8:0-2939  [002]   289.891206: writeback_queue_io: bdi 8:0: older=-1 enqueue=0
              dd-2938  [004]   289.896533: writeback_queue_io: bdi 8:0: older=-1 enqueue=6
              dd-2938  [004]   290.045651: writeback_queue_io: bdi 8:0: older=-1 enqueue=6
              dd-2938  [004]   290.047619: writeback_queue_io: bdi 8:0: older=-1 enqueue=4
              dd-2938  [004]   290.051702: writeback_queue_io: bdi 8:0: older=-1 enqueue=4
              dd-2938  [004]   290.059724: writeback_queue_io: bdi 8:0: older=-1 enqueue=5
             tar-2937  [000]   290.067294: writeback_queue_io: bdi 8:0: older=-1 enqueue=5
       flush-8:0-2939  [002]   290.096955: writeback_queue_io: bdi 8:0: older=-1 enqueue=4
       flush-8:0-2939  [002]   290.175145: writeback_queue_io: bdi 8:0: older=-1 enqueue=2
              dd-2938  [004]   290.190908: writeback_queue_io: bdi 8:0: older=-1 enqueue=102
       flush-8:0-2939  [002]   290.381441: writeback_queue_io: bdi 8:0: older=-1 enqueue=24
       flush-8:0-2939  [002]   290.381576: writeback_queue_io: bdi 8:0: older=-1 enqueue=5
       flush-8:0-2939  [003]   290.424721: writeback_queue_io: bdi 8:0: older=-1 enqueue=146
              dd-2938  [000]   290.436335: writeback_queue_io: bdi 8:0: older=-1 enqueue=110
             tar-2937  [002]   290.436340: writeback_queue_io: bdi 8:0: older=-1 enqueue=0
              dd-2938  [000]   290.440647: writeback_queue_io: bdi 8:0: older=-1 enqueue=254
              dd-2938  [000]   290.442640: writeback_queue_io: bdi 8:0: older=-1 enqueue=254
              dd-2938  [000]   290.446674: writeback_queue_io: bdi 8:0: older=-1 enqueue=254
              dd-2938  [000]   290.454731: writeback_queue_io: bdi 8:0: older=-1 enqueue=254
              dd-2938  [000]   290.475084: writeback_queue_io: bdi 8:0: older=-1 enqueue=254
              dd-2938  [000]   290.476642: writeback_queue_io: bdi 8:0: older=-1 enqueue=254
              dd-2938  [000]   290.478640: writeback_queue_io: bdi 8:0: older=-1 enqueue=254
              dd-2938  [000]   290.482656: writeback_queue_io: bdi 8:0: older=-1 enqueue=254
              dd-2938  [000]   290.490670: writeback_queue_io: bdi 8:0: older=-1 enqueue=254
              dd-2938  [000]   290.506731: writeback_queue_io: bdi 8:0: older=-1 enqueue=254
       flush-8:0-2939  [003]   290.542023: writeback_queue_io: bdi 8:0: older=-1 enqueue=254
       flush-8:0-2939  [003]   290.542791: writeback_queue_io: bdi 8:0: older=-1 enqueue=0
              dd-2938  [000]   290.543801: writeback_queue_io: bdi 8:0: older=-1 enqueue=144
       flush-8:0-2939  [003]   290.645714: writeback_queue_io: bdi 8:0: older=-1 enqueue=255
              dd-2938  [000]   290.661384: writeback_queue_io: bdi 8:0: older=-1 enqueue=118
              dd-2938  [000]   290.662872: writeback_queue_io: bdi 8:0: older=-1 enqueue=145
             tar-2937  [000]   290.671348: writeback_queue_io: bdi 8:0: older=-1 enqueue=48
              dd-2938  [000]   291.093712: writeback_queue_io: bdi 8:0: older=-1 enqueue=280
              dd-2938  [000]   291.094604: writeback_queue_io: bdi 8:0: older=-1 enqueue=0
       flush-8:0-2939  [003]   291.196888: writeback_queue_io: bdi 8:0: older=-1 enqueue=254
       flush-8:0-2939  [003]   291.322189: writeback_queue_io: bdi 8:0: older=-1 enqueue=1
              dd-2938  [004]   291.344134: writeback_queue_io: bdi 8:0: older=-1 enqueue=40
             tar-2937  [000]   291.348827: writeback_queue_io: bdi 8:0: older=-1 enqueue=258
             tar-2937  [000]   291.350680: writeback_queue_io: bdi 8:0: older=-1 enqueue=297
             tar-2937  [000]   291.352682: writeback_queue_io: bdi 8:0: older=-1 enqueue=297
             tar-2937  [000]   291.356689: writeback_queue_io: bdi 8:0: older=-1 enqueue=297
             tar-2937  [000]   291.364708: writeback_queue_io: bdi 8:0: older=-1 enqueue=297
       flush-8:0-2939  [000]   291.374525: writeback_queue_io: bdi 8:0: older=-1 enqueue=298
       flush-8:0-2939  [000]   291.374613: writeback_queue_io: bdi 8:0: older=-1 enqueue=5
       flush-8:0-2939  [000]   291.374656: writeback_queue_io: bdi 8:0: older=-1 enqueue=0
       flush-8:0-2939  [000]   291.376586: writeback_queue_io: bdi 8:0: older=-1 enqueue=293
       flush-8:0-2939  [000]   291.377524: writeback_queue_io: bdi 8:0: older=-1 enqueue=5
       flush-8:0-2939  [000]   291.379490: writeback_queue_io: bdi 8:0: older=-1 enqueue=293
              dd-2938  [004]   291.386729: writeback_queue_io: bdi 8:0: older=-1 enqueue=51
       flush-8:0-2939  [000]   291.751020: writeback_queue_io: bdi 8:0: older=-1 enqueue=300
       flush-8:0-2939  [000]   291.889096: writeback_queue_io: bdi 8:0: older=-1 enqueue=2
              dd-2938  [000]   291.922994: writeback_queue_io: bdi 8:0: older=-1 enqueue=141
             tar-2937  [002]   291.923004: writeback_queue_io: bdi 8:0: older=-1 enqueue=1
       flush-8:0-2939  [000]   291.943943: writeback_queue_io: bdi 8:0: older=-1 enqueue=305
             tar-2937  [000]   291.962703: writeback_queue_io: bdi 8:0: older=-1 enqueue=432
             tar-2937  [000]   291.965711: writeback_queue_io: bdi 8:0: older=-1 enqueue=440
             tar-2937  [000]   291.970700: writeback_queue_io: bdi 8:0: older=-1 enqueue=440
             tar-2937  [000]   291.979722: writeback_queue_io: bdi 8:0: older=-1 enqueue=440
       flush-8:0-2939  [004]   291.989047: writeback_queue_io: bdi 8:0: older=-1 enqueue=440
              dd-2938  [000]   291.989082: writeback_queue_io: bdi 8:0: older=-1 enqueue=0
              dd-2938  [000]   291.990710: writeback_queue_io: bdi 8:0: older=-1 enqueue=440
              dd-2938  [000]   291.993718: writeback_queue_io: bdi 8:0: older=-1 enqueue=440
             tar-2937  [000]   291.996729: writeback_queue_io: bdi 8:0: older=-1 enqueue=440
              dd-2938  [000]   291.999700: writeback_queue_io: bdi 8:0: older=-1 enqueue=440
              dd-2938  [000]   292.009794: writeback_queue_io: bdi 8:0: older=-1 enqueue=440
              dd-2938  [003]   292.038604: writeback_queue_io: bdi 8:0: older=-1 enqueue=490
       flush-8:0-2939  [000]   292.078232: writeback_queue_io: bdi 8:0: older=-1 enqueue=142
       flush-8:0-2939  [001]   292.110171: writeback_queue_io: bdi 8:0: older=-1 enqueue=301
       flush-8:0-2939  [001]   293.075697: writeback_queue_io: bdi 8:0: older=-1 enqueue=5
       flush-8:0-2939  [001]   293.078623: writeback_queue_io: bdi 8:0: older=-1 enqueue=496
       flush-8:0-2939  [001]   293.080842: writeback_queue_io: bdi 8:0: older=-1 enqueue=12
       flush-8:0-2939  [001]   293.085045: writeback_queue_io: bdi 8:0: older=-1 enqueue=15
       flush-8:0-2939  [001]   293.088241: writeback_queue_io: bdi 8:0: older=-1 enqueue=494
       flush-8:0-2939  [001]   293.090036: writeback_queue_io: bdi 8:0: older=-1 enqueue=27
       flush-8:0-2939  [001]   293.092962: writeback_queue_io: bdi 8:0: older=-1 enqueue=494
       flush-8:0-2939  [001]   293.094561: writeback_queue_io: bdi 8:0: older=-1 enqueue=12
       flush-8:0-2939  [001]   293.095628: writeback_queue_io: bdi 8:0: older=-1 enqueue=15
       flush-8:0-2939  [001]   293.098615: writeback_queue_io: bdi 8:0: older=-1 enqueue=506
       flush-8:0-2939  [001]   293.099645: writeback_queue_io: bdi 8:0: older=-1 enqueue=15
       flush-8:0-2939  [001]   293.102537: writeback_queue_io: bdi 8:0: older=-1 enqueue=506
       flush-8:0-2939  [001]   293.103571: writeback_queue_io: bdi 8:0: older=-1 enqueue=15
       flush-8:0-2939  [001]   293.106481: writeback_queue_io: bdi 8:0: older=-1 enqueue=506
       flush-8:0-2939  [001]   293.107516: writeback_queue_io: bdi 8:0: older=-1 enqueue=15
       flush-8:0-2939  [001]   293.110467: writeback_queue_io: bdi 8:0: older=-1 enqueue=506
       flush-8:0-2939  [001]   293.111475: writeback_queue_io: bdi 8:0: older=-1 enqueue=15
              dd-2938  [003]   293.146707: writeback_queue_io: bdi 8:0: older=-1 enqueue=642
             tar-2937  [004]   293.153753: writeback_queue_io: bdi 8:0: older=-1 enqueue=277
       flush-8:0-2939  [000]   293.315851: writeback_queue_io: bdi 8:0: older=-1 enqueue=15
       flush-8:0-2939  [000]   293.338781: writeback_queue_io: bdi 8:0: older=-1 enqueue=379
              dd-2938  [004]   293.353306: writeback_queue_io: bdi 8:0: older=-1 enqueue=263
       flush-8:0-2939  [000]   293.353349: writeback_queue_io: bdi 8:0: older=-1 enqueue=8
       flush-8:0-2939  [000]   293.354913: writeback_queue_io: bdi 8:0: older=-1 enqueue=649
             tar-2937  [004]   293.356764: writeback_queue_io: bdi 8:0: older=-1 enqueue=394
       flush-8:0-2939  [000]   293.418244: writeback_queue_io: bdi 8:0: older=-1 enqueue=839
              dd-2938  [004]   293.426899: writeback_queue_io: bdi 8:0: older=-1 enqueue=0
       flush-8:0-2939  [000]   293.555279: writeback_queue_io: bdi 8:0: older=-1 enqueue=657
      flush-0:15-2212  [007]   294.763913: writeback_queue_io: bdi 0:15: older=30000 enqueue=3
      flush-0:15-2212  [007]   294.763935: writeback_queue_io: bdi 0:15: older=-1 enqueue=8
       flush-8:0-2939  [003]   295.266112: writeback_queue_io: bdi 8:0: older=30007 enqueue=0
       flush-8:0-2939  [003]   295.266716: writeback_queue_io: bdi 8:0: older=30007 enqueue=0
       flush-8:0-2939  [003]   295.267359: writeback_queue_io: bdi 8:0: older=30008 enqueue=0
       flush-8:0-2939  [003]   295.268065: writeback_queue_io: bdi 8:0: older=30009 enqueue=0
       flush-8:0-2939  [003]   295.268738: writeback_queue_io: bdi 8:0: older=30009 enqueue=0
       flush-8:0-2939  [003]   295.269423: writeback_queue_io: bdi 8:0: older=30010 enqueue=0
       flush-8:0-2939  [003]   295.270078: writeback_queue_io: bdi 8:0: older=30011 enqueue=0
       flush-8:0-2939  [003]   295.270734: writeback_queue_io: bdi 8:0: older=30011 enqueue=0
       flush-8:0-2939  [003]   295.271391: writeback_queue_io: bdi 8:0: older=30012 enqueue=0
       flush-8:0-2939  [003]   295.272063: writeback_queue_io: bdi 8:0: older=30013 enqueue=0
       flush-8:0-2939  [003]   295.272707: writeback_queue_io: bdi 8:0: older=30013 enqueue=0
       flush-8:0-2939  [003]   295.273389: writeback_queue_io: bdi 8:0: older=30014 enqueue=0
       flush-8:0-2939  [003]   295.274075: writeback_queue_io: bdi 8:0: older=30015 enqueue=0
       flush-8:0-2939  [003]   295.274733: writeback_queue_io: bdi 8:0: older=30015 enqueue=0
       flush-8:0-2939  [003]   295.275392: writeback_queue_io: bdi 8:0: older=30016 enqueue=0
              dd-2938  [002]   295.337571: writeback_queue_io: bdi 8:0: older=-1 enqueue=981
       flush-8:0-2939  [003]   295.530905: writeback_queue_io: bdi 8:0: older=-1 enqueue=600
       flush-8:0-2939  [007]   295.537538: writeback_queue_io: bdi 8:0: older=-1 enqueue=982
       flush-8:0-2939  [007]   295.545959: writeback_queue_io: bdi 8:0: older=-1 enqueue=346
       flush-8:0-2939  [007]   295.776000: writeback_queue_io: bdi 8:0: older=-1 enqueue=1452
              dd-2938  [000]   295.779745: writeback_queue_io: bdi 8:0: older=-1 enqueue=212
             tar-2937  [002]   295.779873: writeback_queue_io: bdi 8:0: older=-1 enqueue=25
              dd-2938  [000]   295.783513: writeback_queue_io: bdi 8:0: older=-1 enqueue=1355
       flush-8:0-2939  [007]   295.783516: writeback_queue_io: bdi 8:0: older=-1 enqueue=0
       flush-8:0-2939  [007]   296.071577: writeback_queue_io: bdi 8:0: older=-1 enqueue=2883
       flush-8:0-2939  [007]   296.072234: writeback_queue_io: bdi 8:0: older=-1 enqueue=0
       flush-8:0-2939  [007]   296.076483: writeback_queue_io: bdi 8:0: older=-1 enqueue=32
              dd-2938  [000]   296.090712: writeback_queue_io: bdi 8:0: older=-1 enqueue=1439
       flush-8:0-2939  [007]   297.340433: writeback_queue_io: bdi 8:0: older=-1 enqueue=2886
       flush-8:0-2939  [007]   297.341188: writeback_queue_io: bdi 8:0: older=-1 enqueue=7
       flush-8:0-2939  [007]   297.345204: writeback_queue_io: bdi 8:0: older=-1 enqueue=22
       flush-8:0-2939  [007]   297.356773: writeback_queue_io: bdi 8:0: older=-1 enqueue=2880
       flush-8:0-2939  [007]   297.358096: writeback_queue_io: bdi 8:0: older=-1 enqueue=30
       flush-8:0-2939  [007]   297.367081: writeback_queue_io: bdi 8:0: older=-1 enqueue=2920
       flush-8:0-2939  [007]   297.368869: writeback_queue_io: bdi 8:0: older=-1 enqueue=29
       flush-8:0-2939  [007]   297.369583: writeback_queue_io: bdi 8:0: older=-1 enqueue=1
              dd-2938  [002]   297.399896: writeback_queue_io: bdi 8:0: older=-1 enqueue=1368
       flush-8:0-2939  [007]   297.962997: writeback_queue_io: bdi 8:0: older=-1 enqueue=1777
       flush-8:0-2939  [007]   297.966832: writeback_queue_io: bdi 8:0: older=-1 enqueue=1263
       flush-8:0-2939  [007]   297.971540: writeback_queue_io: bdi 8:0: older=-1 enqueue=42
       flush-8:0-2939  [007]   297.978605: writeback_queue_io: bdi 8:0: older=-1 enqueue=1801
       flush-8:0-2939  [007]   297.984734: writeback_queue_io: bdi 8:0: older=-1 enqueue=1356
       flush-8:0-2939  [007]   297.985728: writeback_queue_io: bdi 8:0: older=-1 enqueue=77
              dd-2938  [002]   297.990407: writeback_queue_io: bdi 8:0: older=-1 enqueue=1307
       flush-8:0-2939  [007]   297.992031: writeback_queue_io: bdi 8:0: older=-1 enqueue=568
       flush-8:0-2939  [007]   297.998370: writeback_queue_io: bdi 8:0: older=-1 enqueue=2756
       flush-8:0-2939  [007]   297.998599: writeback_queue_io: bdi 8:0: older=-1 enqueue=0
              dd-2938  [002]   297.998646: writeback_queue_io: bdi 8:0: older=-1 enqueue=14
             tar-2937  [004]   297.999541: writeback_queue_io: bdi 8:0: older=-1 enqueue=434
       flush-8:0-2939  [007]   298.005972: writeback_queue_io: bdi 8:0: older=-1 enqueue=3030
       flush-8:0-2939  [007]   298.006175: writeback_queue_io: bdi 8:0: older=-1 enqueue=95
              dd-2938  [002]   298.006892: writeback_queue_io: bdi 8:0: older=-1 enqueue=40
       flush-8:0-2939  [007]   298.007243: writeback_queue_io: bdi 8:0: older=-1 enqueue=129
             tar-2937  [004]   298.007779: writeback_queue_io: bdi 8:0: older=-1 enqueue=280
       flush-8:0-2939  [007]   298.949789: writeback_queue_io: bdi 8:0: older=-1 enqueue=3175
       flush-8:0-2939  [007]   298.950422: writeback_queue_io: bdi 8:0: older=-1 enqueue=6
       flush-8:0-2939  [007]   298.962155: writeback_queue_io: bdi 8:0: older=-1 enqueue=2710
       flush-8:0-2939  [007]   298.964807: writeback_queue_io: bdi 8:0: older=-1 enqueue=571
       flush-8:0-2939  [007]   298.976086: writeback_queue_io: bdi 8:0: older=-1 enqueue=2798
       flush-8:0-2939  [007]   298.980770: writeback_queue_io: bdi 8:0: older=-1 enqueue=264
       flush-8:0-2939  [007]   298.982764: writeback_queue_io: bdi 8:0: older=-1 enqueue=314
       flush-8:0-2939  [007]   298.994973: writeback_queue_io: bdi 8:0: older=-1 enqueue=3099
       flush-8:0-2939  [007]   298.996633: writeback_queue_io: bdi 8:0: older=-1 enqueue=323
              dd-2938  [002]   299.004420: writeback_queue_io: bdi 8:0: older=-1 enqueue=2160
             tar-2937  [004]   299.004426: writeback_queue_io: bdi 8:0: older=-1 enqueue=1
       flush-8:0-2939  [007]   299.007812: writeback_queue_io: bdi 8:0: older=-1 enqueue=1265
             tar-2937  [004]   299.008346: writeback_queue_io: bdi 8:0: older=-1 enqueue=224
              dd-2938  [002]   299.013535: writeback_queue_io: bdi 8:0: older=-1 enqueue=2427
       flush-8:0-2939  [007]   299.015495: writeback_queue_io: bdi 8:0: older=-1 enqueue=879
       flush-8:0-2939  [007]   299.016767: writeback_queue_io: bdi 8:0: older=-1 enqueue=468
              dd-2938  [002]   299.021580: writeback_queue_io: bdi 8:0: older=-1 enqueue=1721
       flush-8:0-2939  [007]   299.024831: writeback_queue_io: bdi 8:0: older=-1 enqueue=1514
       flush-8:0-2939  [007]   299.025548: writeback_queue_io: bdi 8:0: older=-1 enqueue=357
      flush-0:15-2212  [007]   299.764129: writeback_queue_io: bdi 0:15: older=30000 enqueue=2
      flush-0:15-2212  [007]   299.764146: writeback_queue_io: bdi 0:15: older=-1 enqueue=8
       flush-8:0-2939  [007]   300.175524: writeback_queue_io: bdi 8:0: older=-1 enqueue=1
       flush-8:0-2939  [007]   300.183204: writeback_queue_io: bdi 8:0: older=-1 enqueue=1875
       flush-8:0-2939  [007]   300.189489: writeback_queue_io: bdi 8:0: older=-1 enqueue=1707
       flush-8:0-2939  [007]   300.193487: writeback_queue_io: bdi 8:0: older=-1 enqueue=145
       flush-8:0-2939  [007]   300.200647: writeback_queue_io: bdi 8:0: older=-1 enqueue=1730
       flush-8:0-2939  [007]   300.208785: writeback_queue_io: bdi 8:0: older=-1 enqueue=1916
       flush-8:0-2939  [007]   300.214815: writeback_queue_io: bdi 8:0: older=-1 enqueue=1788
       flush-8:0-2939  [007]   300.217281: writeback_queue_io: bdi 8:0: older=-1 enqueue=343
       flush-8:0-2939  [007]   300.224290: writeback_queue_io: bdi 8:0: older=-1 enqueue=1608
              dd-2938  [002]   300.231330: writeback_queue_io: bdi 8:0: older=-1 enqueue=1792
       flush-8:0-2939  [007]   300.232698: writeback_queue_io: bdi 8:0: older=-1 enqueue=490
       flush-8:0-2939  [007]   300.232729: writeback_queue_io: bdi 8:0: older=-1 enqueue=12
             tar-2937  [004]   300.234232: writeback_queue_io: bdi 8:0: older=-1 enqueue=432
       flush-8:0-2939  [007]   300.241170: writeback_queue_io: bdi 8:0: older=-1 enqueue=3096
              dd-2938  [002]   300.241173: writeback_queue_io: bdi 8:0: older=-1 enqueue=0
       flush-8:0-2939  [007]   300.243152: writeback_queue_io: bdi 8:0: older=-1 enqueue=962
             tar-2937  [004]   300.243993: writeback_queue_io: bdi 8:0: older=-1 enqueue=418
              dd-2938  [002]   300.249851: writeback_queue_io: bdi 8:0: older=-1 enqueue=2835
       flush-8:0-2939  [007]   300.256861: writeback_queue_io: bdi 8:0: older=-1 enqueue=3263
              dd-2938  [002]   300.257859: writeback_queue_io: bdi 8:0: older=-1 enqueue=0
             tar-2937  [004]   300.257975: writeback_queue_io: bdi 8:0: older=-1 enqueue=35
             tar-2937  [004]   300.260115: writeback_queue_io: bdi 8:0: older=-1 enqueue=915
              dd-2938  [002]   300.267108: writeback_queue_io: bdi 8:0: older=-1 enqueue=3302
       flush-8:0-2939  [000]   300.385222: writeback_queue_io: bdi 8:0: older=-1 enqueue=436
       flush-8:0-2939  [004]   300.398842: writeback_queue_io: bdi 8:0: older=-1 enqueue=3303
       flush-8:0-2939  [004]   300.400631: writeback_queue_io: bdi 8:0: older=-1 enqueue=436
       flush-8:0-2939  [000]   302.112115: writeback_queue_io: bdi 8:0: older=-1 enqueue=146
       flush-8:0-2939  [003]   302.125713: writeback_queue_io: bdi 8:0: older=-1 enqueue=3193
       flush-8:0-2939  [003]   302.128185: writeback_queue_io: bdi 8:0: older=-1 enqueue=582
              dd-2938  [002]   302.176685: writeback_queue_io: bdi 8:0: older=-1 enqueue=33
       flush-8:0-2939  [003]   302.310786: writeback_queue_io: bdi 8:0: older=-1 enqueue=73
       flush-8:0-2939  [003]   302.324014: writeback_queue_io: bdi 8:0: older=-1 enqueue=3100
       flush-8:0-2939  [003]   302.327425: writeback_queue_io: bdi 8:0: older=-1 enqueue=716
              dd-2938  [002]   302.328409: writeback_queue_io: bdi 8:0: older=-1 enqueue=320
             tar-2937  [004]   302.328415: writeback_queue_io: bdi 8:0: older=-1 enqueue=1
       flush-8:0-2939  [003]   302.335538: writeback_queue_io: bdi 8:0: older=-1 enqueue=3002
             tar-2937  [004]   302.335578: writeback_queue_io: bdi 8:0: older=-1 enqueue=13
       flush-8:0-2939  [003]   302.338355: writeback_queue_io: bdi 8:0: older=-1 enqueue=1141
              dd-2938  [002]   302.338357: writeback_queue_io: bdi 8:0: older=-1 enqueue=0
             tar-2937  [004]   302.345254: writeback_queue_io: bdi 8:0: older=-1 enqueue=3267
              dd-2938  [002]   302.347398: writeback_queue_io: bdi 8:0: older=-1 enqueue=1045
       flush-8:0-2939  [003]   302.352058: writeback_queue_io: bdi 8:0: older=-1 enqueue=2185
       flush-8:0-2939  [003]   302.354279: writeback_queue_io: bdi 8:0: older=-1 enqueue=588
       flush-8:0-2939  [003]   302.363556: writeback_queue_io: bdi 8:0: older=-1 enqueue=3230
       flush-8:0-2939  [003]   302.365739: writeback_queue_io: bdi 8:0: older=-1 enqueue=588
       flush-8:0-2939  [003]   303.227794: writeback_queue_io: bdi 8:0: older=-1 enqueue=1046
       flush-8:0-2939  [003]   303.238308: writeback_queue_io: bdi 8:0: older=-1 enqueue=2221
       flush-8:0-2939  [003]   303.244048: writeback_queue_io: bdi 8:0: older=-1 enqueue=1643
       flush-8:0-2939  [003]   303.244463: writeback_queue_io: bdi 8:0: older=-1 enqueue=80
       flush-8:0-2939  [003]   303.252856: writeback_queue_io: bdi 8:0: older=-1 enqueue=2141
       flush-8:0-2939  [003]   303.259314: writeback_queue_io: bdi 8:0: older=-1 enqueue=1748
       flush-8:0-2939  [003]   303.266725: writeback_queue_io: bdi 8:0: older=-1 enqueue=2193
       flush-8:0-2939  [003]   303.271326: writeback_queue_io: bdi 8:0: older=-1 enqueue=723
       flush-8:0-2939  [003]   303.275869: writeback_queue_io: bdi 8:0: older=-1 enqueue=1085
       flush-8:0-2939  [003]   303.287943: writeback_queue_io: bdi 8:0: older=-1 enqueue=2918
              dd-2938  [002]   303.288922: writeback_queue_io: bdi 8:0: older=-1 enqueue=213
             tar-2937  [001]   303.288961: writeback_queue_io: bdi 8:0: older=-1 enqueue=11
       flush-8:0-2939  [003]   303.291737: writeback_queue_io: bdi 8:0: older=-1 enqueue=1220
             tar-2937  [001]   303.291810: writeback_queue_io: bdi 8:0: older=-1 enqueue=32
       flush-8:0-2939  [003]   303.298751: writeback_queue_io: bdi 8:0: older=-1 enqueue=3199
       flush-8:0-2939  [003]   303.301163: writeback_queue_io: bdi 8:0: older=-1 enqueue=1058
              dd-2938  [002]   303.304720: writeback_queue_io: bdi 8:0: older=-1 enqueue=1715
       flush-8:0-2939  [003]   303.306021: writeback_queue_io: bdi 8:0: older=-1 enqueue=608
             tar-2937  [001]   303.306079: writeback_queue_io: bdi 8:0: older=-1 enqueue=18
       flush-8:0-2939  [003]   303.308391: writeback_queue_io: bdi 8:0: older=-1 enqueue=982
             tar-2937  [001]   303.308561: writeback_queue_io: bdi 8:0: older=-1 enqueue=76
       flush-8:0-2939  [003]   303.315582: writeback_queue_io: bdi 8:0: older=-1 enqueue=3260
              dd-2938  [002]   303.317096: writeback_queue_io: bdi 8:0: older=-1 enqueue=743
       flush-8:0-2939  [003]   303.319923: writeback_queue_io: bdi 8:0: older=-1 enqueue=623
              dd-2938  [000]   303.319959: writeback_queue_io: bdi 8:0: older=-1 enqueue=0
              dd-2938  [000]   303.332228: writeback_queue_io: bdi 8:0: older=-1 enqueue=3389
       flush-8:0-2939  [003]   303.332231: writeback_queue_io: bdi 8:0: older=-1 enqueue=0
              dd-2938  [000]   303.343272: writeback_queue_io: bdi 8:0: older=-1 enqueue=4012
              dd-2938  [000]   303.355275: writeback_queue_io: bdi 8:0: older=-1 enqueue=4012
              dd-2938  [000]   303.370342: writeback_queue_io: bdi 8:0: older=-1 enqueue=4012
       flush-8:0-2939  [003]   303.382795: writeback_queue_io: bdi 8:0: older=-1 enqueue=4012
       flush-8:0-2939  [003]   303.383462: writeback_queue_io: bdi 8:0: older=-1 enqueue=0
       flush-8:0-2939  [003]   303.388168: writeback_queue_io: bdi 8:0: older=-1 enqueue=623
              dd-2938  [000]   303.392819: writeback_queue_io: bdi 8:0: older=-1 enqueue=1579
       flush-8:0-2939  [003]   303.397128: writeback_queue_io: bdi 8:0: older=-1 enqueue=2041
              dd-2938  [000]   303.523086: writeback_queue_io: bdi 8:0: older=-1 enqueue=3781
              dd-2938  [000]   303.524717: writeback_queue_io: bdi 8:0: older=-1 enqueue=231
       flush-8:0-2939  [003]   304.574804: writeback_queue_io: bdi 8:0: older=-1 enqueue=3782
       flush-8:0-2939  [003]   304.575192: writeback_queue_io: bdi 8:0: older=-1 enqueue=0
       flush-8:0-2939  [003]   304.577811: writeback_queue_io: bdi 8:0: older=-1 enqueue=244
       flush-8:0-2939  [003]   304.592993: writeback_queue_io: bdi 8:0: older=-1 enqueue=3870
      flush-0:15-2212  [007]   304.764258: writeback_queue_io: bdi 0:15: older=30000 enqueue=1
      flush-0:15-2212  [007]   304.764272: writeback_queue_io: bdi 0:15: older=-1 enqueue=8
       flush-8:0-2939  [003]   305.435995: writeback_queue_io: bdi 8:0: older=30015 enqueue=0
       flush-8:0-2939  [003]   305.436635: writeback_queue_io: bdi 8:0: older=30016 enqueue=0
       flush-8:0-2939  [003]   305.437234: writeback_queue_io: bdi 8:0: older=30017 enqueue=0
       flush-8:0-2939  [003]   305.437824: writeback_queue_io: bdi 8:0: older=30017 enqueue=0
       flush-8:0-2939  [003]   305.438418: writeback_queue_io: bdi 8:0: older=30018 enqueue=0
       flush-8:0-2939  [003]   305.439006: writeback_queue_io: bdi 8:0: older=30018 enqueue=0
       flush-8:0-2939  [003]   305.439603: writeback_queue_io: bdi 8:0: older=30019 enqueue=0
       flush-8:0-2939  [003]   305.440198: writeback_queue_io: bdi 8:0: older=30020 enqueue=0
       flush-8:0-2939  [003]   305.440787: writeback_queue_io: bdi 8:0: older=30020 enqueue=0
       flush-8:0-2939  [003]   305.441651: writeback_queue_io: bdi 8:0: older=30021 enqueue=0
       flush-8:0-2939  [003]   305.442247: writeback_queue_io: bdi 8:0: older=30022 enqueue=0
       flush-8:0-2939  [003]   305.442839: writeback_queue_io: bdi 8:0: older=30022 enqueue=0
       flush-8:0-2939  [003]   305.443439: writeback_queue_io: bdi 8:0: older=30023 enqueue=0
       flush-8:0-2939  [003]   305.444029: writeback_queue_io: bdi 8:0: older=30023 enqueue=0
       flush-8:0-2939  [003]   305.444643: writeback_queue_io: bdi 8:0: older=30024 enqueue=0
       flush-8:0-2939  [000]   305.775150: writeback_queue_io: bdi 8:0: older=30354 enqueue=0
       flush-8:0-2939  [000]   305.775788: writeback_queue_io: bdi 8:0: older=30355 enqueue=0
       flush-8:0-2939  [000]   305.776388: writeback_queue_io: bdi 8:0: older=30356 enqueue=0
       flush-8:0-2939  [004]   306.167610: writeback_queue_io: bdi 8:0: older=30747 enqueue=0
       flush-8:0-2939  [004]   306.168516: writeback_queue_io: bdi 8:0: older=30748 enqueue=0
       flush-8:0-2939  [004]   306.169372: writeback_queue_io: bdi 8:0: older=30749 enqueue=0
       flush-8:0-2939  [004]   306.170248: writeback_queue_io: bdi 8:0: older=30750 enqueue=0
       flush-8:0-2939  [004]   306.554556: writeback_queue_io: bdi 8:0: older=31134 enqueue=0
       flush-8:0-2939  [004]   306.555794: writeback_queue_io: bdi 8:0: older=31135 enqueue=0
       flush-8:0-2939  [004]   306.556703: writeback_queue_io: bdi 8:0: older=31136 enqueue=0
       flush-8:0-2939  [004]   306.557613: writeback_queue_io: bdi 8:0: older=31137 enqueue=0
       flush-8:0-2939  [004]   306.793776: writeback_queue_io: bdi 8:0: older=31373 enqueue=0
       flush-8:0-2939  [004]   306.794939: writeback_queue_io: bdi 8:0: older=31374 enqueue=0
       flush-8:0-2939  [004]   306.795901: writeback_queue_io: bdi 8:0: older=31375 enqueue=0
       flush-8:0-2939  [004]   307.008637: writeback_queue_io: bdi 8:0: older=31588 enqueue=0
       flush-8:0-2939  [004]   307.009451: writeback_queue_io: bdi 8:0: older=31589 enqueue=0
       flush-8:0-2939  [004]   307.010196: writeback_queue_io: bdi 8:0: older=31589 enqueue=0
       flush-8:0-2939  [004]   307.011037: writeback_queue_io: bdi 8:0: older=31590 enqueue=0
       flush-8:0-2939  [004]   307.209647: writeback_queue_io: bdi 8:0: older=31789 enqueue=0
       flush-8:0-2939  [004]   307.210586: writeback_queue_io: bdi 8:0: older=31790 enqueue=0
       flush-8:0-2939  [004]   307.211503: writeback_queue_io: bdi 8:0: older=31791 enqueue=0
       flush-8:0-2939  [000]   307.439319: writeback_queue_io: bdi 8:0: older=32019 enqueue=0
       flush-8:0-2939  [000]   307.439940: writeback_queue_io: bdi 8:0: older=32019 enqueue=0
       flush-8:0-2939  [000]   307.440565: writeback_queue_io: bdi 8:0: older=32020 enqueue=0
       flush-8:0-2939  [000]   307.441152: writeback_queue_io: bdi 8:0: older=32020 enqueue=0
       flush-8:0-2939  [000]   307.648785: writeback_queue_io: bdi 8:0: older=32228 enqueue=0
       flush-8:0-2939  [000]   307.649393: writeback_queue_io: bdi 8:0: older=32229 enqueue=0
       flush-8:0-2939  [000]   307.649984: writeback_queue_io: bdi 8:0: older=32229 enqueue=0
       flush-8:0-2939  [000]   307.955109: writeback_queue_io: bdi 8:0: older=32534 enqueue=0
       flush-8:0-2939  [000]   307.955766: writeback_queue_io: bdi 8:0: older=32535 enqueue=0
       flush-8:0-2939  [000]   307.956363: writeback_queue_io: bdi 8:0: older=32536 enqueue=0
       flush-8:0-2939  [000]   307.956953: writeback_queue_io: bdi 8:0: older=32536 enqueue=0
       flush-8:0-2939  [000]   308.171085: writeback_queue_io: bdi 8:0: older=32750 enqueue=0
       flush-8:0-2939  [000]   308.171741: writeback_queue_io: bdi 8:0: older=32751 enqueue=0
       flush-8:0-2939  [000]   308.172308: writeback_queue_io: bdi 8:0: older=32752 enqueue=0
       flush-8:0-2939  [000]   308.376067: writeback_queue_io: bdi 8:0: older=32955 enqueue=0
       flush-8:0-2939  [000]   308.376700: writeback_queue_io: bdi 8:0: older=32956 enqueue=0
       flush-8:0-2939  [000]   308.377268: writeback_queue_io: bdi 8:0: older=32957 enqueue=0
       flush-8:0-2939  [000]   308.377831: writeback_queue_io: bdi 8:0: older=32957 enqueue=0
       flush-8:0-2939  [004]   308.563760: writeback_queue_io: bdi 8:0: older=33143 enqueue=0
       flush-8:0-2939  [004]   308.564571: writeback_queue_io: bdi 8:0: older=33144 enqueue=0
       flush-8:0-2939  [004]   308.565404: writeback_queue_io: bdi 8:0: older=33145 enqueue=0
       flush-8:0-2939  [004]   308.566098: writeback_queue_io: bdi 8:0: older=33145 enqueue=0
       flush-8:0-2939  [000]   308.704526: writeback_queue_io: bdi 8:0: older=33284 enqueue=0
       flush-8:0-2939  [000]   308.705118: writeback_queue_io: bdi 8:0: older=33284 enqueue=0
       flush-8:0-2939  [000]   308.705688: writeback_queue_io: bdi 8:0: older=33285 enqueue=0
       flush-8:0-2939  [004]   308.943857: writeback_queue_io: bdi 8:0: older=33523 enqueue=0
       flush-8:0-2939  [004]   308.944594: writeback_queue_io: bdi 8:0: older=33524 enqueue=0
       flush-8:0-2939  [004]   308.945156: writeback_queue_io: bdi 8:0: older=33524 enqueue=0
       flush-8:0-2939  [004]   308.945805: writeback_queue_io: bdi 8:0: older=33525 enqueue=0
       flush-8:0-2939  [000]   309.232903: writeback_queue_io: bdi 8:0: older=33812 enqueue=0
       flush-8:0-2939  [000]   309.233503: writeback_queue_io: bdi 8:0: older=33813 enqueue=0
       flush-8:0-2939  [000]   309.234070: writeback_queue_io: bdi 8:0: older=33813 enqueue=0
       flush-8:0-2939  [000]   309.583782: writeback_queue_io: bdi 8:0: older=34163 enqueue=0
       flush-8:0-2939  [000]   309.584377: writeback_queue_io: bdi 8:0: older=34164 enqueue=0
       flush-8:0-2939  [000]   309.584941: writeback_queue_io: bdi 8:0: older=34164 enqueue=0
       flush-8:0-2939  [000]   309.585514: writeback_queue_io: bdi 8:0: older=34165 enqueue=0
      flush-0:15-2212  [007]   309.764382: writeback_queue_io: bdi 0:15: older=30000 enqueue=0
       flush-8:0-2939  [000]   309.958752: writeback_queue_io: bdi 8:0: older=34538 enqueue=0
       flush-8:0-2939  [000]   309.959332: writeback_queue_io: bdi 8:0: older=34539 enqueue=0
       flush-8:0-2939  [000]   309.959895: writeback_queue_io: bdi 8:0: older=34539 enqueue=0
       flush-8:0-2939  [000]   309.960508: writeback_queue_io: bdi 8:0: older=34540 enqueue=0
       flush-8:0-2939  [000]   310.288178: writeback_queue_io: bdi 8:0: older=34867 enqueue=0
       flush-8:0-2939  [000]   310.288749: writeback_queue_io: bdi 8:0: older=34868 enqueue=0
       flush-8:0-2939  [000]   310.289309: writeback_queue_io: bdi 8:0: older=34868 enqueue=0
       flush-8:0-2939  [000]   310.793020: writeback_queue_io: bdi 8:0: older=35372 enqueue=0
       flush-8:0-2939  [000]   310.793594: writeback_queue_io: bdi 8:0: older=35373 enqueue=0
       flush-8:0-2939  [000]   310.794156: writeback_queue_io: bdi 8:0: older=35373 enqueue=0
       flush-8:0-2939  [000]   310.794769: writeback_queue_io: bdi 8:0: older=35374 enqueue=0
      flush-0:15-2212  [007]   314.764559: writeback_queue_io: bdi 0:15: older=30000 enqueue=1
       flush-8:0-2939  [004]   315.180482: writeback_queue_io: bdi 8:0: older=30000 enqueue=0
       flush-8:0-2939  [004]   315.182519: writeback_queue_io: bdi 8:0: older=-1 enqueue=24158
       flush-8:0-2939  [004]   315.305213: writeback_queue_io: bdi 8:0: older=-1 enqueue=1916
       flush-8:0-2939  [004]   315.362979: writeback_queue_io: bdi 8:0: older=-1 enqueue=674
       flush-8:0-2939  [004]   315.550202: writeback_queue_io: bdi 8:0: older=-1 enqueue=882
       flush-8:0-2939  [004]   315.627676: writeback_queue_io: bdi 8:0: older=-1 enqueue=859
       flush-8:0-2939  [004]   315.707167: writeback_queue_io: bdi 8:0: older=-1 enqueue=476
       flush-8:0-2939  [004]   315.794131: writeback_queue_io: bdi 8:0: older=-1 enqueue=689
       flush-8:0-2939  [004]   315.902549: writeback_queue_io: bdi 8:0: older=-1 enqueue=747
       flush-8:0-2939  [004]   315.983656: writeback_queue_io: bdi 8:0: older=-1 enqueue=725
       flush-8:0-2939  [004]   316.131605: writeback_queue_io: bdi 8:0: older=-1 enqueue=692
       flush-8:0-2939  [004]   316.211777: writeback_queue_io: bdi 8:0: older=-1 enqueue=749
       flush-8:0-2939  [004]   316.290287: writeback_queue_io: bdi 8:0: older=-1 enqueue=654
       flush-8:0-2939  [004]   316.393865: writeback_queue_io: bdi 8:0: older=-1 enqueue=752
       flush-8:0-2939  [004]   316.566939: writeback_queue_io: bdi 8:0: older=-1 enqueue=798
       flush-8:0-2939  [004]   316.649929: writeback_queue_io: bdi 8:0: older=-1 enqueue=734
       flush-8:0-2939  [004]   316.734868: writeback_queue_io: bdi 8:0: older=-1 enqueue=592
       flush-8:0-2939  [004]   316.896972: writeback_queue_io: bdi 8:0: older=-1 enqueue=726
       flush-8:0-2939  [004]   316.914074: writeback_queue_io: bdi 8:0: older=-1 enqueue=654
       flush-8:0-2939  [004]   317.100975: writeback_queue_io: bdi 8:0: older=-1 enqueue=887
       flush-8:0-2939  [004]   317.218250: writeback_queue_io: bdi 8:0: older=-1 enqueue=608
       flush-8:0-2939  [004]   317.306473: writeback_queue_io: bdi 8:0: older=-1 enqueue=782
       flush-8:0-2939  [004]   317.498823: writeback_queue_io: bdi 8:0: older=-1 enqueue=839
       flush-8:0-2939  [004]   317.620263: writeback_queue_io: bdi 8:0: older=-1 enqueue=661
       flush-8:0-2939  [004]   317.722236: writeback_queue_io: bdi 8:0: older=-1 enqueue=555
       flush-8:0-2939  [004]   317.794648: writeback_queue_io: bdi 8:0: older=-1 enqueue=299
       flush-8:0-2939  [004]   317.895347: writeback_queue_io: bdi 8:0: older=-1 enqueue=316
       flush-8:0-2939  [004]   317.983708: writeback_queue_io: bdi 8:0: older=-1 enqueue=398
       flush-8:0-2939  [004]   318.103976: writeback_queue_io: bdi 8:0: older=-1 enqueue=477
      flush-0:15-2212  [007]   319.764719: writeback_queue_io: bdi 0:15: older=30000 enqueue=1
      flush-0:15-2212  [007]   322.465207: writeback_queue_io: bdi 0:15: older=-1 enqueue=8
      flush-0:15-2212  [007]   322.465247: writeback_queue_io: bdi 0:15: older=-1 enqueue=8
       flush-8:0-2939  [004]   322.467453: writeback_queue_io: bdi 8:0: older=-1 enqueue=13012
       flush-8:0-2939  [004]   322.473793: writeback_queue_io: bdi 8:0: older=-1 enqueue=125
       flush-8:0-2939  [004]   322.480534: writeback_queue_io: bdi 8:0: older=-1 enqueue=221
       flush-8:0-2939  [004]   323.036278: writeback_queue_io: bdi 8:0: older=-1 enqueue=133
       flush-8:0-2939  [004]   323.050850: writeback_queue_io: bdi 8:0: older=-1 enqueue=166
       flush-8:0-2939  [004]   323.219196: writeback_queue_io: bdi 8:0: older=-1 enqueue=171
       flush-8:0-2939  [004]   323.226573: writeback_queue_io: bdi 8:0: older=-1 enqueue=208
       flush-8:0-2939  [004]   323.236098: writeback_queue_io: bdi 8:0: older=-1 enqueue=318
       flush-8:0-2939  [004]   323.401420: writeback_queue_io: bdi 8:0: older=-1 enqueue=246
       flush-8:0-2939  [004]   323.409997: writeback_queue_io: bdi 8:0: older=-1 enqueue=227
       flush-8:0-2939  [004]   323.683992: writeback_queue_io: bdi 8:0: older=-1 enqueue=229
       flush-8:0-2939  [004]   323.692427: writeback_queue_io: bdi 8:0: older=-1 enqueue=301
       flush-8:0-2939  [004]   323.697916: writeback_queue_io: bdi 8:0: older=-1 enqueue=215
       flush-8:0-2939  [004]   324.083378: writeback_queue_io: bdi 8:0: older=-1 enqueue=136
       flush-8:0-2939  [004]   324.089267: writeback_queue_io: bdi 8:0: older=-1 enqueue=172
       flush-8:0-2939  [004]   324.095232: writeback_queue_io: bdi 8:0: older=-1 enqueue=170
       flush-8:0-2939  [004]   324.102113: writeback_queue_io: bdi 8:0: older=-1 enqueue=201
       flush-8:0-2939  [004]   324.456413: writeback_queue_io: bdi 8:0: older=-1 enqueue=231
       flush-8:0-2939  [004]   324.462807: writeback_queue_io: bdi 8:0: older=-1 enqueue=209
       flush-8:0-2939  [004]   324.468340: writeback_queue_io: bdi 8:0: older=-1 enqueue=201
       flush-8:0-2939  [004]   324.743166: writeback_queue_io: bdi 8:0: older=-1 enqueue=271
       flush-8:0-2939  [004]   324.747173: writeback_queue_io: bdi 8:0: older=-1 enqueue=80
       flush-8:0-2939  [004]   324.754360: writeback_queue_io: bdi 8:0: older=-1 enqueue=220
       flush-8:0-2939  [004]   325.056758: writeback_queue_io: bdi 8:0: older=-1 enqueue=212
       flush-8:0-2939  [004]   325.063579: writeback_queue_io: bdi 8:0: older=-1 enqueue=231
       flush-8:0-2939  [004]   325.328492: writeback_queue_io: bdi 8:0: older=-1 enqueue=253
       flush-8:0-2939  [004]   325.333020: writeback_queue_io: bdi 8:0: older=-1 enqueue=152
       flush-8:0-2939  [004]   325.337244: writeback_queue_io: bdi 8:0: older=-1 enqueue=137
       flush-8:0-2939  [004]   325.627000: writeback_queue_io: bdi 8:0: older=-1 enqueue=273
       flush-8:0-2939  [004]   325.631667: writeback_queue_io: bdi 8:0: older=-1 enqueue=196
       flush-8:0-2939  [004]   325.997899: writeback_queue_io: bdi 8:0: older=-1 enqueue=477
       flush-8:0-2939  [004]   326.056377: writeback_queue_io: bdi 8:0: older=-1 enqueue=530
       flush-8:0-2939  [004]   326.179895: writeback_queue_io: bdi 8:0: older=-1 enqueue=2647
       flush-8:0-2939  [004]   326.195636: writeback_queue_io: bdi 8:0: older=-1 enqueue=2245
       flush-8:0-2939  [004]   326.250487: writeback_queue_io: bdi 8:0: older=-1 enqueue=446
       flush-8:0-2939  [004]   326.256807: writeback_queue_io: bdi 8:0: older=-1 enqueue=259
       flush-8:0-2939  [004]   326.438760: writeback_queue_io: bdi 8:0: older=-1 enqueue=787
       flush-8:0-2939  [004]   326.445477: writeback_queue_io: bdi 8:0: older=-1 enqueue=296
       flush-8:0-2939  [004]   326.451228: writeback_queue_io: bdi 8:0: older=-1 enqueue=235
       flush-8:0-2939  [004]   326.458182: writeback_queue_io: bdi 8:0: older=-1 enqueue=697
       flush-8:0-2939  [004]   326.729892: writeback_queue_io: bdi 8:0: older=-1 enqueue=305
       flush-8:0-2939  [004]   326.736946: writeback_queue_io: bdi 8:0: older=-1 enqueue=880
       flush-8:0-2939  [004]   326.795887: writeback_queue_io: bdi 8:0: older=-1 enqueue=379
       flush-8:0-2939  [004]   326.803055: writeback_queue_io: bdi 8:0: older=-1 enqueue=298
       flush-8:0-2939  [004]   326.809735: writeback_queue_io: bdi 8:0: older=-1 enqueue=842
       flush-8:0-2939  [004]   327.170602: writeback_queue_io: bdi 8:0: older=-1 enqueue=152
       flush-8:0-2939  [004]   327.179150: writeback_queue_io: bdi 8:0: older=-1 enqueue=651
       flush-8:0-2939  [004]   327.185108: writeback_queue_io: bdi 8:0: older=-1 enqueue=245
       flush-8:0-2939  [004]   327.450900: writeback_queue_io: bdi 8:0: older=-1 enqueue=539
       flush-8:0-2939  [004]   327.452250: writeback_queue_io: bdi 8:0: older=-1 enqueue=563
      flush-0:15-2212  [007]   327.465044: writeback_queue_io: bdi 0:15: older=30000 enqueue=3
       flush-8:0-2939  [004]   327.813397: writeback_queue_io: bdi 8:0: older=30000 enqueue=0
      flush-0:15-2212  [007]   327.813481: writeback_queue_io: bdi 0:15: older=-1 enqueue=8
       flush-8:0-2939  [004]   327.815030: writeback_queue_io: bdi 8:0: older=-1 enqueue=18709
       flush-8:0-2939  [004]   334.276274: writeback_queue_io: bdi 8:0: older=30000 enqueue=0
       flush-8:0-2939  [004]   339.276480: writeback_queue_io: bdi 8:0: older=30000 enqueue=0
       flush-8:0-2939  [004]   344.276650: writeback_queue_io: bdi 8:0: older=30000 enqueue=0
       flush-8:0-2939  [004]   349.276806: writeback_queue_io: bdi 8:0: older=30000 enqueue=0
       flush-8:0-2939  [004]   354.277001: writeback_queue_io: bdi 8:0: older=30000 enqueue=0
       flush-8:0-2939  [004]   359.277166: writeback_queue_io: bdi 8:0: older=30000 enqueue=22
      flush-0:15-2212  [007]   427.616627: writeback_queue_io: bdi 0:15: older=30000 enqueue=0
      flush-0:15-2212  [007]   432.616749: writeback_queue_io: bdi 0:15: older=30000 enqueue=0
      flush-0:15-2212  [007]   437.616987: writeback_queue_io: bdi 0:15: older=30000 enqueue=0
      flush-0:15-2212  [007]   442.617140: writeback_queue_io: bdi 0:15: older=30000 enqueue=0
      flush-0:15-2212  [007]   447.617320: writeback_queue_io: bdi 0:15: older=30000 enqueue=0
      flush-0:15-2212  [007]   452.617509: writeback_queue_io: bdi 0:15: older=30000 enqueue=1
      flush-0:15-2212  [007]   457.617695: writeback_queue_io: bdi 0:15: older=30000 enqueue=1
      flush-0:15-2212  [007]   462.617864: writeback_queue_io: bdi 0:15: older=30000 enqueue=1
      flush-0:15-2212  [007]   467.618021: writeback_queue_io: bdi 0:15: older=30000 enqueue=1
      flush-0:15-2212  [007]   472.618221: writeback_queue_io: bdi 0:15: older=30000 enqueue=1
      flush-0:15-2212  [007]   477.618426: writeback_queue_io: bdi 0:15: older=30000 enqueue=1
      flush-0:15-2212  [007]   482.618563: writeback_queue_io: bdi 0:15: older=30000 enqueue=1
      flush-0:15-2212  [007]   487.618753: writeback_queue_io: bdi 0:15: older=30000 enqueue=1
      flush-0:15-2212  [007]   492.618929: writeback_queue_io: bdi 0:15: older=30000 enqueue=1
      flush-0:15-2212  [007]   497.619130: writeback_queue_io: bdi 0:15: older=30000 enqueue=1
      flush-0:15-2212  [007]   502.619267: writeback_queue_io: bdi 0:15: older=30000 enqueue=1
      flush-0:15-2212  [007]   507.619428: writeback_queue_io: bdi 0:15: older=30000 enqueue=1
      flush-0:15-2212  [007]   512.619645: writeback_queue_io: bdi 0:15: older=30000 enqueue=1
      flush-0:15-2212  [007]   517.619821: writeback_queue_io: bdi 0:15: older=30000 enqueue=1
      flush-0:15-2212  [007]   522.619969: writeback_queue_io: bdi 0:15: older=30000 enqueue=1
      flush-0:15-2212  [007]   527.620173: writeback_queue_io: bdi 0:15: older=30000 enqueue=1
      flush-0:15-2212  [007]   532.620344: writeback_queue_io: bdi 0:15: older=30000 enqueue=0
      flush-0:15-2212  [007]   537.620528: writeback_queue_io: bdi 0:15: older=30000 enqueue=0
      flush-0:15-2212  [007]   542.620668: writeback_queue_io: bdi 0:15: older=30000 enqueue=0
      flush-0:15-2212  [007]   547.620863: writeback_queue_io: bdi 0:15: older=30000 enqueue=0
      flush-0:15-2212  [007]   552.621062: writeback_queue_io: bdi 0:15: older=30000 enqueue=0
      flush-0:15-2212  [007]   557.621244: writeback_queue_io: bdi 0:15: older=30000 enqueue=3
      flush-0:15-2212  [007]   562.621383: writeback_queue_io: bdi 0:15: older=30000 enqueue=3
      flush-0:15-2212  [007]   567.621558: writeback_queue_io: bdi 0:15: older=30000 enqueue=3
      flush-0:15-2212  [007]   572.621751: writeback_queue_io: bdi 0:15: older=30000 enqueue=3
      flush-0:15-2212  [007]   577.621952: writeback_queue_io: bdi 0:15: older=30000 enqueue=3
      flush-0:15-2212  [007]   582.622086: writeback_queue_io: bdi 0:15: older=30000 enqueue=3
      flush-0:15-2212  [007]   587.622272: writeback_queue_io: bdi 0:15: older=30000 enqueue=3
      flush-0:15-2212  [007]   592.622470: writeback_queue_io: bdi 0:15: older=30000 enqueue=3
      flush-0:15-2212  [007]   597.622641: writeback_queue_io: bdi 0:15: older=30000 enqueue=3
      flush-0:15-2212  [007]   602.622798: writeback_queue_io: bdi 0:15: older=30000 enqueue=3
      flush-0:15-2212  [007]   607.622996: writeback_queue_io: bdi 0:15: older=30000 enqueue=3
      flush-0:15-2212  [007]   612.623159: writeback_queue_io: bdi 0:15: older=30000 enqueue=3
      flush-0:15-2212  [007]   617.623365: writeback_queue_io: bdi 0:15: older=30000 enqueue=3
      flush-0:15-2212  [007]   622.623500: writeback_queue_io: bdi 0:15: older=30000 enqueue=3
      flush-0:15-2212  [007]   627.623714: writeback_queue_io: bdi 0:15: older=30000 enqueue=3
      flush-0:15-2212  [007]   632.623874: writeback_queue_io: bdi 0:15: older=30000 enqueue=3
      flush-0:15-2212  [007]   637.624067: writeback_queue_io: bdi 0:15: older=30000 enqueue=3
      flush-0:15-2212  [007]   642.624216: writeback_queue_io: bdi 0:15: older=30000 enqueue=3
      flush-0:15-2212  [007]   647.624399: writeback_queue_io: bdi 0:15: older=30000 enqueue=3
      flush-0:15-2212  [007]   652.624603: writeback_queue_io: bdi 0:15: older=30000 enqueue=3
      flush-0:15-2212  [007]   657.624764: writeback_queue_io: bdi 0:15: older=30000 enqueue=0

--9amGYk9869ThD9tj--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

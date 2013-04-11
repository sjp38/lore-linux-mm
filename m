Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx181.postini.com [74.125.245.181])
	by kanga.kvack.org (Postfix) with SMTP id D874E6B0036
	for <linux-mm@kvack.org>; Thu, 11 Apr 2013 13:04:07 -0400 (EDT)
Date: Thu, 11 Apr 2013 18:04:02 +0100
From: Mel Gorman <mgorman@suse.de>
Subject: Re: Excessive stall times on ext4 in 3.9-rc2
Message-ID: <20130411170402.GB11656@suse.de>
References: <20130402142717.GH32241@suse.de>
 <20130402150651.GB31577@thunk.org>
 <20130410105608.GC1910@suse.de>
 <20130410131245.GC4862@thunk.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20130410131245.GC4862@thunk.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Theodore Ts'o <tytso@mit.edu>
Cc: linux-ext4@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>, Jiri Slaby <jslaby@suse.cz>

On Wed, Apr 10, 2013 at 09:12:45AM -0400, Theodore Ts'o wrote:
> On Wed, Apr 10, 2013 at 11:56:08AM +0100, Mel Gorman wrote:
> > During major activity there is likely to be "good" behaviour
> > with stalls roughly every 30 seconds roughly corresponding to
> > dirty_expire_centiseconds. As you'd expect, the flusher thread is stuck
> > when this happens.
> > 
> >   237 ?        00:00:00 flush-8:0
> > [<ffffffff811a35b9>] sleep_on_buffer+0x9/0x10
> > [<ffffffff811a35ee>] __lock_buffer+0x2e/0x30
> > [<ffffffff8123a21f>] do_get_write_access+0x43f/0x4b0
> 
> If we're stalling on lock_buffer(), that implies that buffer was being
> written, and for some reason it was taking a very long time to
> complete.
> 

Yes.

> It might be worthwhile to put a timestamp in struct dm_crypt_io, and
> record the time when a particular I/O encryption/decryption is getting
> queued to the kcryptd workqueues, and when they finally squirt out.
> 

That somewhat assumes that dm_crypt was at fault which is not unreasonable
but I was skeptical as the workload on dm_crypt was opening a maildir
and mostly reads.

I used a tracepoint in jbd2 to get an idea of what device the buffer_head
was managing and dm did not show up on the list. This is what a trace-cmd
log of the test told me.

       flush-8:0-240   [005]   236.655363: jbd2_lock_buffer_stall: dev 8,8 stall_ms 1096
         awesome-1364  [005]   290.594396: jbd2_lock_buffer_stall: dev 8,6 stall_ms 7312
 gnome-pty-helpe-2256  [005]   290.836952: jbd2_lock_buffer_stall: dev 8,8 stall_ms 7528
       flush-8:0-240   [003]   304.012424: jbd2_lock_buffer_stall: dev 8,8 stall_ms 4472
  gnome-terminal-2332  [005]   308.290879: jbd2_lock_buffer_stall: dev 8,6 stall_ms 3060
         awesome-1364  [006]   308.291318: jbd2_lock_buffer_stall: dev 8,6 stall_ms 3048
       flush-8:0-240   [005]   331.525996: jbd2_lock_buffer_stall: dev 8,5 stall_ms 8732
       flush-8:0-240   [005]   332.353526: jbd2_lock_buffer_stall: dev 8,5 stall_ms 472
       flush-8:0-240   [005]   345.341547: jbd2_lock_buffer_stall: dev 8,5 stall_ms 10024
  gnome-terminal-2418  [005]   347.166876: jbd2_lock_buffer_stall: dev 8,6 stall_ms 11852
         awesome-1364  [005]   347.167082: jbd2_lock_buffer_stall: dev 8,6 stall_ms 11844
       flush-8:0-240   [005]   347.424520: jbd2_lock_buffer_stall: dev 8,5 stall_ms 2012
       flush-8:0-240   [005]   347.583752: jbd2_lock_buffer_stall: dev 8,5 stall_ms 156
       flush-8:0-240   [005]   390.079682: jbd2_lock_buffer_stall: dev 8,8 stall_ms 396
       flush-8:0-240   [002]   407.882385: jbd2_lock_buffer_stall: dev 8,8 stall_ms 12244
       flush-8:0-240   [005]   408.003976: jbd2_lock_buffer_stall: dev 8,8 stall_ms 124
  gnome-terminal-2610  [005]   413.613365: jbd2_lock_buffer_stall: dev 8,6 stall_ms 3400
         awesome-1364  [006]   413.613605: jbd2_lock_buffer_stall: dev 8,6 stall_ms 3736
       flush-8:0-240   [002]   430.706475: jbd2_lock_buffer_stall: dev 8,5 stall_ms 9748
       flush-8:0-240   [005]   458.188896: jbd2_lock_buffer_stall: dev 8,5 stall_ms 7748
       flush-8:0-240   [005]   458.828143: jbd2_lock_buffer_stall: dev 8,5 stall_ms 348
       flush-8:0-240   [006]   459.163814: jbd2_lock_buffer_stall: dev 8,5 stall_ms 252
       flush-8:0-240   [005]   462.340173: jbd2_lock_buffer_stall: dev 8,5 stall_ms 3160
       flush-8:0-240   [005]   469.917705: jbd2_lock_buffer_stall: dev 8,5 stall_ms 6340
       flush-8:0-240   [005]   474.434206: jbd2_lock_buffer_stall: dev 8,5 stall_ms 4512
             tar-2315  [005]   510.043613: jbd2_lock_buffer_stall: dev 8,5 stall_ms 4316
           tclsh-1780  [005]   773.336488: jbd2_lock_buffer_stall: dev 8,5 stall_ms 736
             git-3100  [005]   775.933506: jbd2_lock_buffer_stall: dev 8,5 stall_ms 3664
             git-4763  [005]   864.093317: jbd2_lock_buffer_stall: dev 8,5 stall_ms 140
       flush-8:0-240   [005]   864.242068: jbd2_lock_buffer_stall: dev 8,6 stall_ms 280
             git-4763  [005]   864.264157: jbd2_lock_buffer_stall: dev 8,5 stall_ms 148
       flush-8:0-240   [005]   865.200004: jbd2_lock_buffer_stall: dev 8,5 stall_ms 464
             git-4763  [000]   865.602469: jbd2_lock_buffer_stall: dev 8,5 stall_ms 300
       flush-8:0-240   [005]   865.705448: jbd2_lock_buffer_stall: dev 8,5 stall_ms 500
       flush-8:0-240   [005]   885.367576: jbd2_lock_buffer_stall: dev 8,8 stall_ms 11024
       flush-8:0-240   [005]   895.339697: jbd2_lock_buffer_stall: dev 8,5 stall_ms 120
       flush-8:0-240   [005]   895.765488: jbd2_lock_buffer_stall: dev 8,5 stall_ms 424
 systemd-journal-265   [005]   915.687201: jbd2_lock_buffer_stall: dev 8,8 stall_ms 14844
       flush-8:0-240   [005]   915.690529: jbd2_lock_buffer_stall: dev 8,6 stall_ms 19656
             git-5442  [005]  1034.845674: jbd2_lock_buffer_stall: dev 8,5 stall_ms 344
             git-5442  [005]  1035.157389: jbd2_lock_buffer_stall: dev 8,5 stall_ms 264
       flush-8:0-240   [005]  1035.875478: jbd2_lock_buffer_stall: dev 8,8 stall_ms 1368
       flush-8:0-240   [005]  1036.189218: jbd2_lock_buffer_stall: dev 8,8 stall_ms 312
  gnome-terminal-5592  [005]  1037.318594: jbd2_lock_buffer_stall: dev 8,6 stall_ms 2628
         awesome-1364  [000]  1037.318913: jbd2_lock_buffer_stall: dev 8,6 stall_ms 2632
             git-5789  [005]  1076.805405: jbd2_lock_buffer_stall: dev 8,5 stall_ms 184
       flush-8:0-240   [005]  1078.401721: jbd2_lock_buffer_stall: dev 8,5 stall_ms 700
       flush-8:0-240   [005]  1078.784200: jbd2_lock_buffer_stall: dev 8,5 stall_ms 356
             git-5789  [005]  1079.722683: jbd2_lock_buffer_stall: dev 8,5 stall_ms 1452
       flush-8:0-240   [005]  1109.928552: jbd2_lock_buffer_stall: dev 8,5 stall_ms 976
       flush-8:0-240   [005]  1111.762280: jbd2_lock_buffer_stall: dev 8,5 stall_ms 1832
       flush-8:0-240   [005]  1260.197720: jbd2_lock_buffer_stall: dev 8,5 stall_ms 344
       flush-8:0-240   [005]  1260.403556: jbd2_lock_buffer_stall: dev 8,5 stall_ms 204
       flush-8:0-240   [005]  1260.550904: jbd2_lock_buffer_stall: dev 8,5 stall_ms 108
             git-6598  [005]  1260.832948: jbd2_lock_buffer_stall: dev 8,5 stall_ms 1084
       flush-8:0-240   [005]  1311.736367: jbd2_lock_buffer_stall: dev 8,5 stall_ms 260
       flush-8:0-240   [005]  1313.689297: jbd2_lock_buffer_stall: dev 8,5 stall_ms 412
       flush-8:0-240   [005]  1314.230420: jbd2_lock_buffer_stall: dev 8,5 stall_ms 540
             git-7022  [006]  1314.241607: jbd2_lock_buffer_stall: dev 8,5 stall_ms 668
       flush-8:0-240   [000]  1347.980425: jbd2_lock_buffer_stall: dev 8,5 stall_ms 308
       flush-8:0-240   [005]  1348.164598: jbd2_lock_buffer_stall: dev 8,5 stall_ms 104
             git-7998  [005]  1547.755328: jbd2_lock_buffer_stall: dev 8,5 stall_ms 304
       flush-8:0-240   [006]  1547.764209: jbd2_lock_buffer_stall: dev 8,5 stall_ms 208
       flush-8:0-240   [005]  1548.653365: jbd2_lock_buffer_stall: dev 8,5 stall_ms 844
       flush-8:0-240   [005]  1549.255022: jbd2_lock_buffer_stall: dev 8,5 stall_ms 460
       flush-8:0-240   [005]  1725.036408: jbd2_lock_buffer_stall: dev 8,6 stall_ms 156
             git-8743  [005]  1740.492630: jbd2_lock_buffer_stall: dev 8,5 stall_ms 15032
             git-8743  [005]  1749.485214: jbd2_lock_buffer_stall: dev 8,5 stall_ms 8648
       flush-8:0-240   [005]  1775.937819: jbd2_lock_buffer_stall: dev 8,5 stall_ms 4268
       flush-8:0-240   [006]  1776.335682: jbd2_lock_buffer_stall: dev 8,5 stall_ms 336
       flush-8:0-240   [006]  1776.446799: jbd2_lock_buffer_stall: dev 8,5 stall_ms 112
       flush-8:0-240   [005]  1802.593183: jbd2_lock_buffer_stall: dev 8,6 stall_ms 108
       flush-8:0-240   [006]  1802.809237: jbd2_lock_buffer_stall: dev 8,8 stall_ms 208
       flush-8:0-240   [005]  2012.041976: jbd2_lock_buffer_stall: dev 8,6 stall_ms 292
           tclsh-1778  [005]  2012.055139: jbd2_lock_buffer_stall: dev 8,5 stall_ms 424
  latency-output-1933  [002]  2012.055147: jbd2_lock_buffer_stall: dev 8,5 stall_ms 136
             git-10209 [005]  2012.074584: jbd2_lock_buffer_stall: dev 8,5 stall_ms 164
       flush-8:0-240   [005]  2012.177241: jbd2_lock_buffer_stall: dev 8,5 stall_ms 128
             git-10209 [005]  2012.297472: jbd2_lock_buffer_stall: dev 8,5 stall_ms 216
       flush-8:0-240   [005]  2012.299828: jbd2_lock_buffer_stall: dev 8,5 stall_ms 120

dm is not obviously at fault there. sda5 is /usr/src (git checkout
running there with some logging), sda6 is /home and sda8 is / . This is
the tracepoint patch used.

---8<---
jbd2: Trace when lock_buffer at the start of a journal write takes a long time

While investigating interactivity problems it was clear that processes
sometimes stall for long periods of times if an attempt is made to lock
a buffer that is already part of a transaction. It would stall in a
trace looking something like

[<ffffffff811a39de>] __lock_buffer+0x2e/0x30
[<ffffffff8123a60f>] do_get_write_access+0x43f/0x4b0
[<ffffffff8123a7cb>] jbd2_journal_get_write_access+0x2b/0x50
[<ffffffff81220f79>] __ext4_journal_get_write_access+0x39/0x80
[<ffffffff811f3198>] ext4_reserve_inode_write+0x78/0xa0
[<ffffffff811f3209>] ext4_mark_inode_dirty+0x49/0x220
[<ffffffff811f57d1>] ext4_dirty_inode+0x41/0x60
[<ffffffff8119ac3e>] __mark_inode_dirty+0x4e/0x2d0
[<ffffffff8118b9b9>] update_time+0x79/0xc0
[<ffffffff8118ba98>] file_update_time+0x98/0x100
[<ffffffff81110ffc>] __generic_file_aio_write+0x17c/0x3b0
[<ffffffff811112aa>] generic_file_aio_write+0x7a/0xf0
[<ffffffff811ea853>] ext4_file_write+0x83/0xd0
[<ffffffff81172b23>] do_sync_write+0xa3/0xe0
[<ffffffff811731ae>] vfs_write+0xae/0x180
[<ffffffff8117361d>] sys_write+0x4d/0x90
[<ffffffff8159d62d>] system_call_fastpath+0x1a/0x1f
[<ffffffffffffffff>] 0xffffffffffffffff

There was a suspicion that dm_crypt might be part responsible so this
patch adds a tracepoint capturing when lock_buffer takes too long
in do_get_write_access() that logs what device is being written and
how long the stall was for.

Signed-off-by: Mel Gorman <mgorman@suse.de>
---
 fs/jbd2/transaction.c       |  8 ++++++++
 include/trace/events/jbd2.h | 21 +++++++++++++++++++++
 2 files changed, 29 insertions(+)

diff --git a/fs/jbd2/transaction.c b/fs/jbd2/transaction.c
index 325bc01..1be0ccb 100644
--- a/fs/jbd2/transaction.c
+++ b/fs/jbd2/transaction.c
@@ -640,6 +640,7 @@ do_get_write_access(handle_t *handle, struct journal_head *jh,
 	int error;
 	char *frozen_buffer = NULL;
 	int need_copy = 0;
+	unsigned long start_lock, time_lock;
 
 	if (is_handle_aborted(handle))
 		return -EROFS;
@@ -655,9 +656,16 @@ repeat:
 
 	/* @@@ Need to check for errors here at some point. */
 
+ 	start_lock = jiffies;
 	lock_buffer(bh);
 	jbd_lock_bh_state(bh);
 
+	/* If it takes too long to lock the buffer, trace it */
+	time_lock = jbd2_time_diff(start_lock, jiffies);
+	if (time_lock > HZ/10)
+		trace_jbd2_lock_buffer_stall(bh->b_bdev->bd_dev,
+			jiffies_to_msecs(time_lock));
+
 	/* We now hold the buffer lock so it is safe to query the buffer
 	 * state.  Is the buffer dirty?
 	 *
diff --git a/include/trace/events/jbd2.h b/include/trace/events/jbd2.h
index 070df49..c1d1f3e 100644
--- a/include/trace/events/jbd2.h
+++ b/include/trace/events/jbd2.h
@@ -358,6 +358,27 @@ TRACE_EVENT(jbd2_write_superblock,
 		  MINOR(__entry->dev), __entry->write_op)
 );
 
+TRACE_EVENT(jbd2_lock_buffer_stall,
+
+	TP_PROTO(dev_t dev, unsigned long stall_ms),
+
+	TP_ARGS(dev, stall_ms),
+
+	TP_STRUCT__entry(
+		__field(        dev_t, dev	)
+		__field(unsigned long, stall_ms	)
+	),
+
+	TP_fast_assign(
+		__entry->dev		= dev;
+		__entry->stall_ms	= stall_ms;
+	),
+
+	TP_printk("dev %d,%d stall_ms %lu",
+		MAJOR(__entry->dev), MINOR(__entry->dev),
+		__entry->stall_ms)
+);
+
 #endif /* _TRACE_JBD2_H */
 
 /* This part must be outside protection */

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

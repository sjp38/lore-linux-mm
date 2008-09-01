Received: by ti-out-0910.google.com with SMTP id j3so929567tid.8
        for <linux-mm@kvack.org>; Sun, 31 Aug 2008 19:28:56 -0700 (PDT)
Message-ID: <c03b90ed0808311928g43571695j2d31d8b85b73cc29@mail.gmail.com>
Date: Mon, 1 Sep 2008 10:28:55 +0800
From: "Michael Yao" <danshoe@gmail.com>
Subject: [RFC][PATCH] Simply Break in throttle_vm_writeout to prevent NetworkStorageDeadlock
MIME-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Dear List,

I have a NAS server with kernel 2.6.24.2 which has a memory deadlock
issue, and I found two related pages here:

REF1:
Storage over network has a deadlock problem, where it can take memory
to free memory.
http://linux-mm.org/NetworkStorageDeadlock

REF2:
[RFC] [PATCH] A clean approach to writeout throttling
http://marc.info/?l=linux-kernel&m=119689957014639&w=2

At first I tried the patch in REF2 (
http://marc.info/?l=linux-kernel&m=119689957014639&w=2 ),
but ran into a problem of XFS, described here
http://code.google.com/p/zumastor/issues/detail?id=146&q=xfs

The sysrq-t trace shows that many processes locked in throttle_vm_writeout,
and smbd seems to be blocked at balance_dirty_pages:

kswapd0       D 00000000     0   101      2
Call Trace:
[cfa37c40] [0000000a] 0xa (unreliable)
[cfa37d00] [c0009214] __switch_to+0x5c/0x74
[cfa37d20] [c0288a9c] schedule+0x2e8/0x320
[cfa37d50] [c0288f90] schedule_timeout+0x90/0xc0
[cfa37d90] [c0288eac] io_schedule_timeout+0x30/0x54
[cfa37db0] [c00458ec] congestion_wait+0x70/0x98
[cfa37e00] [c003f7a8] throttle_vm_writeout+0x74/0x94
[cfa37e20] [c004403c] shrink_zone+0x954/0x96c
[cfa37f20] [c004458c] kswapd+0x2d4/0x400
[cfa37fd0] [c0027f84] kthread+0x48/0x84
[cfa37ff0] [c000461c] kernel_thread+0x44/0x60

smbd          D 0fa6a450     0 11693  11511
Call Trace:
[cc789ab0] [c0007324] do_softirq+0x3c/0x54 (unreliable)
[cc789b70] [c0009214] __switch_to+0x5c/0x74
[cc789b90] [c0288a9c] schedule+0x2e8/0x320
[cc789bc0] [c0288f90] schedule_timeout+0x90/0xc0
[cc789c00] [c0288eac] io_schedule_timeout+0x30/0x54
[cc789c20] [c00458ec] congestion_wait+0x70/0x98
[cc789c70] [c003f684] balance_dirty_pages_ratelimited_nr+0x1a0/0x250
[cc789ce0] [c003acfc] generic_file_buffered_write+0x1bc/0x5d4
[cc789d80] [d1bbf874] xfs_write+0x4f4/0x748 [xfs]
[cc789e20] [d1bbab2c] xfs_file_aio_write+0x6c/0x7c [xfs]
[cc789e30] [c005c760] do_sync_write+0xb8/0x10c
[cc789ef0] [c005c87c] vfs_write+0xc8/0x15c
[cc789f10] [c005cb24] sys_pwrite64+0x64/0x98
[cc789f40] [c00022e0] ret_from_syscall+0x0/0x3c


My first thought is to break the infinite loop in throttle_vm_writeout
after 200 seconds and see what will happen after bailing out the loop.
Surprisingly, it solves the Deadlock problem after I break the loop,
so I did not try the patch in REF1 ( http://lwn.net/Articles/146652/
).

Maybe the reason is my /etc/sysctl.conf?
vm.min_free_kbytes=8192
vm.swap_token_timeout=30
vm.vfs_cache_pressure=300
vm.dirty_background_ratio=1
vm.dirty_ratio=1

Any comments is appreciated, thanks.

Michael Yao



diff -ur linux-2.6.24.2/mm/page-writeback.c
linux-2.6.24.2.my/mm/page-writeback.c
--- linux-2.6.24.2/mm/page-writeback.c	2008-09-01 09:35:58.000000000 +0800
+++ linux-2.6.24.2.my/mm/page-writeback.c	2008-09-01 09:38:21.000000000 +0800
@@ -508,7 +508,9 @@
 {
 	long background_thresh;
 	long dirty_thresh;
+	unsigned long start;

+        start = jiffies;
         for ( ; ; ) {
 		get_dirty_limits(&background_thresh, &dirty_thresh, NULL, NULL);

@@ -530,6 +532,12 @@
 		 */
 		if ((gfp_mask & (__GFP_FS|__GFP_IO)) != (__GFP_FS|__GFP_IO))
 			break;
+		/* break the loop after X seconds  */		
+		if (time_after(jiffies, (start + 200*HZ))) {
+			printk("[%lu] break throttle_vm_writeout: background_thresh=%ld
dirty_thresh=%ld NR_UNSTABLE_NFS=%ld NR_WRITEBACK=%ld\n",
+			jiffies - start, background_thresh, dirty_thresh,
global_page_state(NR_UNSTABLE_NFS), global_page_state(NR_WRITEBACK));
+			break;
+		}
         }
 }

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

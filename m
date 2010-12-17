Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id 0A6FB6B00A3
	for <linux-mm@kvack.org>; Thu, 16 Dec 2010 21:19:39 -0500 (EST)
Date: Fri, 17 Dec 2010 10:19:34 +0800
From: Wu Fengguang <fengguang.wu@intel.com>
Subject: Re: [PATCH 22/35] writeback: trace global dirty page states
Message-ID: <20101217021934.GA9525@localhost>
References: <20101213144646.341970461@intel.com>
 <20101213150329.002158963@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20101213150329.002158963@intel.com>
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Jan Kara <jack@suse.cz>, Christoph Hellwig <hch@lst.de>, Hugh Dickins <hugh.dickins@tiscali.co.uk>, Trond Myklebust <Trond.Myklebust@netapp.com>, Dave Chinner <david@fromorbit.com>, Theodore Ts'o <tytso@mit.edu>, Chris Mason <chris.mason@oracle.com>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Mel Gorman <mel@csn.ul.ie>, Rik van Riel <riel@redhat.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Greg Thelen <gthelen@google.com>, Minchan Kim <minchan.kim@gmail.com>, linux-mm <linux-mm@kvack.org>, "linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>, LKML <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

On Mon, Dec 13, 2010 at 10:47:08PM +0800, Wu, Fengguang wrote:

> +	TP_fast_assign(
> +		strlcpy(__entry->bdi,
> +			dev_name(mapping->backing_dev_info->dev), 32);
> +		__entry->ino			= mapping->host->i_ino;

I got an oops against the above line on shmem. Can be fixed by the
below patch, but still not 100% confident..

Thanks,
Fengguang
---
Subject: writeback fix dereferencing NULL shmem mapping->host
Date: Thu Dec 16 22:22:00 CST 2010

The oops happens when doing "cp /proc/vmstat /dev/shm". It seems to be
triggered on accessing host->i_ino, since the offset of i_ino is exactly
0x50. However I'm afraid the problem is not fully understand

1) it's not normal that tmpfs will have mapping->host == NULL

2) I tried removing the dereference as the below diff, however it
   didn't stop the oops. This is very weird.

TRACE_EVENT balance_dirty_state:

 	TP_fast_assign(
 		strlcpy(__entry->bdi,
 			dev_name(mapping->backing_dev_info->dev), 32);
-		__entry->ino			= mapping->host->i_ino;
 		__entry->nr_dirty		= nr_dirty;
 		__entry->nr_writeback		= nr_writeback;
 		__entry->nr_unstable		= nr_unstable;

[  337.018477] EXT3-fs (sda8): mounted filesystem with writeback data mode
[  388.126563] BUG: unable to handle kernel NULL pointer dereference at 0000000000000050
[  388.127057] IP: [<ffffffff811a8387>] ftrace_raw_event_balance_dirty_state+0x97/0x130
[  388.127506] PGD b507e067 PUD b1474067 PMD 0
[  388.127858] Oops: 0000 [#1] SMP DEBUG_PAGEALLOC
[  388.128218] last sysfs file: /sys/devices/pci0000:00/0000:00:1f.2/host0/target0:0:0/0:0:0:0/block/sda/queue/scheduler
[  388.128737] CPU 0
[  388.128846] Modules linked in:
[  388.129149]
[  388.129279] Pid: 4222, comm: cp Not tainted 2.6.37-rc5+ #361 DX58SO/
[  388.129625] RIP: 0010:[<ffffffff811a8387>]  [<ffffffff811a8387>] ftrace_raw_event_balance_dirty_state+0x97/0x130
[  388.130165] RSP: 0018:ffff8800a9ab7a98  EFLAGS: 00010202
[  388.130443] RAX: 0000000000000000 RBX: ffffffff81fc3c68 RCX: 0000000000001000
[  388.130792] RDX: 0000000000000020 RSI: 0000000000000282 RDI: ffff8800a99a74a0
[  388.131141] RBP: ffff8800a9ab7b08 R08: 000000000000001a R09: 0000000000000480
[  388.131490] R10: ffffffff81fdd660 R11: 0000000000000001 R12: 0000000000000000
[  388.131838] R13: ffff8800a99a7494 R14: ffff8800a99a7490 R15: 0000000000010ebf
[  388.132189] FS:  00007fc4b1f217a0(0000) GS:ffff8800b7400000(0000) knlGS:0000000000000000
[  388.132606] CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
[  388.132901] CR2: 0000000000000050 CR3: 00000000b268a000 CR4: 00000000000006f0
[  388.133250] DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
[  388.133598] DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7: 0000000000000400
[  388.133948] Process cp (pid: 4222, threadinfo ffff8800a9ab6000, task ffff8800b2e09900)
[  388.134359] Stack:
[  388.134508]  ffff8800a9ab7ac8 0000000000000002 0000000000000000 0000000000000005
[  388.135049]  ffff8800b1757320 0000000000000282 ffff8800a9ab7ae8 ffff8800b5f66cc0
[  388.135590]  ffff8800b1757178 0000000000021d7f ffff8800a9a7e350 0000000000010ebf
[  388.136132] Call Trace:
[  388.136303]  [<ffffffff81137f00>] balance_dirty_pages_ratelimited_nr+0x6a0/0x7f0
[  388.136698]  [<ffffffff81141c37>] ? shmem_getpage+0x777/0xa80
[  388.136996]  [<ffffffff8112c575>] generic_file_buffered_write+0x1f5/0x290
[  388.137333]  [<ffffffff8108c026>] ? current_fs_time+0x16/0x60
[  388.137631]  [<ffffffff81a815c0>] ? mutex_lock_nested+0x280/0x350
[  388.137940]  [<ffffffff8112e394>] __generic_file_aio_write+0x244/0x450
[  388.138267]  [<ffffffff81a815d2>] ? mutex_lock_nested+0x292/0x350
[  388.138576]  [<ffffffff8112e5f8>] ? generic_file_aio_write+0x58/0xd0
[  388.138896]  [<ffffffff8112e5f8>] ? generic_file_aio_write+0x58/0xd0
[  388.139216]  [<ffffffff8112e60b>] generic_file_aio_write+0x6b/0xd0
[  388.139531]  [<ffffffff81182aaa>] do_sync_write+0xda/0x120
[  388.139819]  [<ffffffff810bb55d>] ? lock_release_holdtime+0x3d/0x180
[  388.140139]  [<ffffffff81a8397b>] ? _raw_spin_unlock+0x2b/0x40
[  388.140440]  [<ffffffff811d839e>] ? proc_reg_read+0x8e/0xc0
[  388.140731]  [<ffffffff8118322e>] vfs_write+0xce/0x190
[  388.141004]  [<ffffffff81183564>] sys_write+0x54/0x90
[  388.141274]  [<ffffffff8103af42>] system_call_fastpath+0x16/0x1b
[  388.141579] Code: 84 85 00 00 00 48 89 c7 e8 27 e5 f5 ff 48 8b 55 b0 49 89 c5 48 8b 82 f8 00 00 00 49 8d 7d 0c 48 8b 80 08 04 00 00 ba 20 00 00 00 <48> 8b 70 50 48 85 f6 48 0f 44 70 10 e8 58 f8 29 00 48 8b 45 a8
[  388.144899] RIP  [<ffffffff811a8387>] ftrace_raw_event_balance_dirty_state+0x97/0x130
[  388.145346]  RSP <ffff8800a9ab7a98>
[  388.145555] CR2: 0000000000000050
[  388.146039] ---[ end trace d824f7aad3debcd9 ]---

CC: Hugh Dickins <hugh.dickins@tiscali.co.uk>
Signed-off-by: Wu Fengguang <fengguang.wu@intel.com>
---
 mm/page-writeback.c |    3 +++
 1 file changed, 3 insertions(+)

--- linux-next.orig/mm/page-writeback.c	2010-12-17 09:30:11.000000000 +0800
+++ linux-next/mm/page-writeback.c	2010-12-17 09:31:05.000000000 +0800
@@ -907,6 +907,9 @@ void balance_dirty_pages_ratelimited_nr(
 {
 	struct backing_dev_info *bdi = mapping->backing_dev_info;
 
+	if (!mapping_cap_writeback_dirty(mapping))
+		return;
+
 	current->nr_dirtied += nr_pages_dirtied;
 
 	if (unlikely(!current->nr_dirtied_pause))

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

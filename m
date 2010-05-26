Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id 2A36E6B01D0
	for <linux-mm@kvack.org>; Wed, 26 May 2010 07:13:31 -0400 (EDT)
Date: Wed, 26 May 2010 13:13:26 +0200
From: Christoph Hellwig <hch@lst.de>
Subject: writeback hang in current mainline
Message-ID: <20100526111326.GA28541@lst.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
To: jens.axboe@oracle.com
Cc: linux-fsdevel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

When running xfstests on current Linus' tree I get the following
reproducible hang during test 013:

013 76s ...[  196.150570] XFS mounting filesystem vdb5
[  360.596137] INFO: task fsstress:7898 blocked for more than 120
seconds.
[  360.598053] "echo 0 > /proc/sys/kernel/hung_task_timeout_secs"
disables this message.
[  360.600678] fsstress      D 00000006     0  7898   7897 0x00000000
[  360.602661]  f3a1beb0 00000046 f3a1be84 00000006 c1e164a0 00000282
f3a1be8c c0e5f980
[  360.606072]  f3eca340 f5c07540 c0e5f980 c0e5f980 f3eca340 c01805d9
f3a1bee4 00000000
[  360.609495]  f3a1beec f3a1beb8 c0222b38 f3a1bed4 c08fcf35 c0222b30
c1e164a0 c1e164a0
[  360.612944] Call Trace:
[  360.613918]  [<c01805d9>] ? prepare_to_wait+0x49/0x70
[  360.615432]  [<c0222b38>] bdi_sched_wait+0x8/0x10
[  360.617019]  [<c08fcf35>] __wait_on_bit+0x45/0x70
[  360.618448]  [<c0222b30>] ? bdi_sched_wait+0x0/0x10
[  360.619934]  [<c0222b30>] ? bdi_sched_wait+0x0/0x10
[  360.621520]  [<c08fd003>] out_of_line_wait_on_bit+0xa3/0xb0
[  360.623169]  [<c0180390>] ? wake_bit_function+0x0/0x50
[  360.624812]  [<c0222d1c>] bdi_alloc_queue_work+0xac/0x110
[  360.626395]  [<c0247470>] ? vfs_quota_sync+0x0/0x2b0
[  360.627961]  [<c0222dc7>] bdi_start_writeback+0x47/0x50
[  360.629632]  [<c0222e11>] writeback_inodes_sb_locked+0x41/0x50
[  360.631319]  [<c022721a>] __sync_filesystem+0x4a/0x90
[  360.632955]  [<c022727a>] sync_one_sb+0x1a/0x20
[  360.634360]  [<c020959c>] iterate_supers+0x6c/0xa0
[  360.635842]  [<c0227260>] ? sync_one_sb+0x0/0x20
[  360.637372]  [<c02272a4>] sys_sync+0x24/0x60
[  360.638751]  [<c013075c>] sysenter_do_call+0x12/0x3c
[  360.640321] 1 lock held by fsstress/7898:
[  360.641623]  #0:  (&type->s_umount_key#19){++++..}, at: [<c020958d>]
iterate_supers+0x5d/0xa0

This works fine with the xfs tree which has the same xfs code, but is
otherwise at 2.6.34 level.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

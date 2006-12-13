Received: from d03relay04.boulder.ibm.com (d03relay04.boulder.ibm.com [9.17.195.106])
	by e31.co.us.ibm.com (8.13.8/8.12.11) with ESMTP id kBDNLx9S018658
	for <linux-mm@kvack.org>; Wed, 13 Dec 2006 18:21:59 -0500
Received: from d03av04.boulder.ibm.com (d03av04.boulder.ibm.com [9.17.195.170])
	by d03relay04.boulder.ibm.com (8.13.6/8.13.6/NCO v8.1.1) with ESMTP id kBDNLwAD370816
	for <linux-mm@kvack.org>; Wed, 13 Dec 2006 16:21:59 -0700
Received: from d03av04.boulder.ibm.com (loopback [127.0.0.1])
	by d03av04.boulder.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id kBDNLwUb025482
	for <linux-mm@kvack.org>; Wed, 13 Dec 2006 16:21:58 -0700
Subject: [PATCH] Fix for shmem_truncate_range() BUG_ON() in 2.6.19
From: Badari Pulavarty <pbadari@us.ibm.com>
Content-Type: text/plain
Date: Wed, 13 Dec 2006 15:21:16 -0800
Message-Id: <1166052076.24236.27.camel@dyn9047017100.beaverton.ibm.com>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: akpm@osdl.org
Cc: lkml <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

Hi Andrew,

Ran into following BUG_ON() while testing 2.6.19 with
madvise(REMOVE). Here is the fix to the problem.
(BTW, bug has been there a for a while and ran into
it while doing distro testing and reproduced on 2.6.19).

 Kernel BUG at mm/shmem.c:521
 invalid opcode: 0000 [1] SMP
 CPU 1
 Modules linked in: sg sd_mod qla2xxx firmware_class scsi_transport_fc
scsi_mod ipv6 thermal processor fan button battery ac dm_mod floppy
parport_pc lp parport
 Pid: 6598, comm: madvise Not tainted 2.6.19 #1
 RIP: 0010:[<ffffffff80278982>]  [<ffffffff80278982>]
shmem_truncate_range+0x1c2/0x6f0
 RSP: 0018:ffff8101c947bd78  EFLAGS: 00010287
 RAX: 0000000000001000 RBX: 0000000000000000 RCX: ffff81019f571688
 RDX: ffff81019f571758 RSI: 00000000003baddd RDI: 0000000000000001
 RBP: ffff8101c947be58 R08: 000000000000000e R09: ffff81019fac8768
 R10: 000000000000000e R11: 0000000000000010 R12: 0000000000000003
 R13: ffff81019f571758 R14: 0000000000000000 R15: 0000000000002fff
 FS:  00002b25b61e76d0(0000) GS:ffff81018009ae40(0000)
knlGS:00000000f7d646b0
 CS:  0010 DS: 0000 ES: 0000 CR0: 000000008005003b
 CR2: 00002b25b6048b60 CR3: 0000000198ff7000 CR4: 00000000000006e0
 Process madvise (pid: 6598, threadinfo ffff8101c947a000, task
ffff8101df6340c0)
 Stack:  ffff81019f571868 ffff8101c947be18 ffff8101c947be58
ffffffff80261d9f
  0000000000002fff 0000000000000000 ffff81019f571758 ffff81019f571688
  ffff81019fe6d2f8 ffff81019fe066d8 ffff81019fe0dac8 ffff81019fdc75f8
 Call Trace:
  [<ffffffff802674de>] vmtruncate_range+0x9e/0xd0
  [<ffffffff8026592c>] sys_madvise+0x29c/0x480
  [<ffffffff80209c3e>] system_call+0x7e/0x83
  [<00002b25b6073587>]


Thanks,
Badari


Ran into BUG() while doing madvise(REMOVE) testing. If we are
punching a hole into shared memory segment using madvise(REMOVE)
and the entire hole is below the indirect blocks, we hit following 
assert.

	        BUG_ON(limit <= SHMEM_NR_DIRECT);

Signed-off-by: Badari Pulavarty <pbadari@us.ibm.com>

 mm/shmem.c |    7 ++++++-
 1 file changed, 6 insertions(+), 1 deletion(-)

Index: linux-2.6.19/mm/shmem.c
===================================================================
--- linux-2.6.19.orig/mm/shmem.c	2006-12-13 15:42:50.000000000 -0800
+++ linux-2.6.19/mm/shmem.c	2006-12-13 15:50:27.000000000 -0800
@@ -515,7 +515,12 @@ static void shmem_truncate_range(struct 
 			size = SHMEM_NR_DIRECT;
 		nr_swaps_freed = shmem_free_swp(ptr+idx, ptr+size);
 	}
-	if (!topdir)
+
+	/*
+	 * If there are no indirect blocks or we are punching a hole
+	 * below indirect blocks, nothing to be done.
+	 */
+	if (!topdir || (punch_hole && (limit <= SHMEM_NR_DIRECT)))
 		goto done2;
 
 	BUG_ON(limit <= SHMEM_NR_DIRECT);


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

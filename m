Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f72.google.com (mail-pg0-f72.google.com [74.125.83.72])
	by kanga.kvack.org (Postfix) with ESMTP id 78AE96B04C5
	for <linux-mm@kvack.org>; Mon,  4 Sep 2017 21:40:56 -0400 (EDT)
Received: by mail-pg0-f72.google.com with SMTP id v82so3934436pgb.5
        for <linux-mm@kvack.org>; Mon, 04 Sep 2017 18:40:56 -0700 (PDT)
Received: from ipmail06.adl2.internode.on.net (ipmail06.adl2.internode.on.net. [150.101.137.129])
        by mx.google.com with ESMTP id x188si5812684pfx.13.2017.09.04.18.40.54
        for <linux-mm@kvack.org>;
        Mon, 04 Sep 2017 18:40:55 -0700 (PDT)
From: Dave Chinner <david@fromorbit.com>
Subject: [PATCH] swapon: fix vfree() badness
Date: Tue,  5 Sep 2017 11:40:51 +1000
Message-Id: <20170905014051.11112-1-david@fromorbit.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: linux-mm@kvack.org

From: Dave Chinner <dchinner@redhat.com>

The cluster_info structure is allocated with kvzalloc(), which can
return kmalloc'd or vmalloc'd memory. It must be paired with
kvfree(), but sys_swapon uses vfree(), resultin in this warning
from xfstests generic/357:

[ 1985.294915] swapon: swapfile has holes
[ 1985.296012] Trying to vfree() bad address (ffff88011569ac00)
[ 1985.297769] ------------[ cut here ]------------
[ 1985.299017] WARNING: CPU: 4 PID: 980 at mm/vmalloc.c:1521 __vunmap+0x97/0xb0
[ 1985.300868] CPU: 4 PID: 980 Comm: swapon Tainted: G        W       4.13.0-dgc #55
[ 1985.303086] Hardware name: QEMU Standard PC (i440FX + PIIX, 1996), BIOS 1.10.2-1 04/01/2014
[ 1985.305421] task: ffff88083599c800 task.stack: ffffc90006d68000
[ 1985.306896] RIP: 0010:__vunmap+0x97/0xb0
[ 1985.307866] RSP: 0018:ffffc90006d6be68 EFLAGS: 00010296
[ 1985.309300] RAX: 0000000000000030 RBX: ffff88011569ac00 RCX: 0000000000000000
[ 1985.311066] RDX: ffff88013fc949d8 RSI: ffff88013fc8cb98 RDI: ffff88013fc8cb98
[ 1985.312803] RBP: ffffc90006d6be80 R08: 000000000004844c R09: 0000000000001578
[ 1985.314672] R10: ffffffff82271b20 R11: ffffffff8256e16d R12: 000000000000000a
[ 1985.316444] R13: 0000000000000001 R14: 00000000ffffffea R15: ffff880139a96000
[ 1985.318230] FS:  00007fb23ac0e880(0000) GS:ffff88013fc80000(0000) knlGS:0000000000000000
[ 1985.320081] CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
[ 1985.321503] CR2: 0000564cdb0c7000 CR3: 0000000137448000 CR4: 00000000000406e0
[ 1985.323140] Call Trace:
[ 1985.323727]  vfree+0x2e/0x70
[ 1985.324403]  SyS_swapon+0x433/0x1080
[ 1985.325365]  entry_SYSCALL_64_fastpath+0x1a/0xa5

Fix this as well as the memory leak caused by a missing kvfree(frontswap_map) in
the error handling code.

cc: <stable@vger.kernel.org>
Signed-Off-By: Dave Chinner <dchinner@redhat.com>
---
 mm/swapfile.c | 3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/mm/swapfile.c b/mm/swapfile.c
index 6ba4aab2db0b..a8952b6563c6 100644
--- a/mm/swapfile.c
+++ b/mm/swapfile.c
@@ -3052,7 +3052,8 @@ SYSCALL_DEFINE2(swapon, const char __user *, specialfile, int, swap_flags)
 	p->flags = 0;
 	spin_unlock(&swap_lock);
 	vfree(swap_map);
-	vfree(cluster_info);
+	kvfree(cluster_info);
+	kvfree(frontswap_map);
 	if (swap_file) {
 		if (inode && S_ISREG(inode->i_mode)) {
 			inode_unlock(inode);
-- 
2.13.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

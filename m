From: Wu Fengguang <fengguang.wu@intel.com>
Subject: [PATCH 3/8] devmem: fix kmem write bug on memory holes
Date: Wed, 13 Jan 2010 21:53:08 +0800
Message-ID: <20100113135957.545276953@intel.com>
References: <20100113135305.013124116@intel.com>
Return-path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id 0DB0D6B0088
	for <linux-mm@kvack.org>; Wed, 13 Jan 2010 09:00:50 -0500 (EST)
Content-Disposition: inline; filename=vwrite-fix.patch
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Wu Fengguang <fengguang.wu@intel.com>, LKML <linux-kernel@vger.kernel.org>, Kelly Bowa <kmb@tuxedu.org>, Andi Kleen <andi@firstfloor.org>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Christoph Lameter <cl@linux-foundation.org>, Ingo Molnar <mingo@elte.hu>, Tejun Heo <tj@kernel.org>, Nick Piggin <npiggin@suse.de>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, stable@kernel.org, Hugh Dickins <hugh.dickins@tiscali.co.uk>, Linux Memory Management List <linux-mm@kvack.org>
List-Id: linux-mm.kvack.org

write_kmem() used to assume vwrite() always return the full buffer length.
However now vwrite() could return 0 to indicate memory hole. This creates
a bug that "buf" is not advanced accordingly.

Fix it to simply ignore the return value, hence the memory hole.

CC: Kelly Bowa <kmb@tuxedu.org>
CC: Andi Kleen <andi@firstfloor.org>
CC: Benjamin Herrenschmidt <benh@kernel.crashing.org>
CC: Christoph Lameter <cl@linux-foundation.org>
CC: Ingo Molnar <mingo@elte.hu>
CC: Tejun Heo <tj@kernel.org>
CC: Nick Piggin <npiggin@suse.de>
CC: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
CC: <stable@kernel.org>
Signed-off-by: Wu Fengguang <fengguang.wu@intel.com>
---
 drivers/char/mem.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

--- linux-mm.orig/drivers/char/mem.c	2010-01-11 10:32:32.000000000 +0800
+++ linux-mm/drivers/char/mem.c	2010-01-11 10:32:34.000000000 +0800
@@ -555,7 +555,7 @@ static ssize_t write_kmem(struct file * 
 				err = -EFAULT;
 				break;
 			}
-			sz = vwrite(kbuf, (char *)p, sz);
+			vwrite(kbuf, (char *)p, sz);
 			count -= sz;
 			buf += sz;
 			virtr += sz;


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

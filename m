Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with SMTP id 0D9FC6B0047
	for <linux-mm@kvack.org>; Wed,  3 Feb 2010 22:10:13 -0500 (EST)
Date: Thu, 4 Feb 2010 10:43:54 +0800
From: Wu Fengguang <fengguang.wu@intel.com>
Subject: [stable] [PATCH] devmem: fix kmem write bug on memory holes
Message-ID: <20100204024353.GA13576@localhost>
References: <20100122045914.993668874@intel.com> <20100203234724.GA23902@kroah.com> <20100204024202.GD6343@localhost>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20100204024202.GD6343@localhost>
Sender: owner-linux-mm@kvack.org
To: Greg KH <greg@kroah.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Greg Kroah-Hartman <gregkh@suse.de>, LKML <linux-kernel@vger.kernel.org>, Linux Memory Management List <linux-mm@kvack.org>, Andi Kleen <andi@firstfloor.org>, "linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>, "stable@kernel.org" <stable@kernel.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
List-ID: <linux-mm.kvack.org>

From: Wu Fengguang <fengguang.wu@intel.com>

commit c85e9a97c4102ce2e83112da850d838cfab5ab13 upstream.

write_kmem() used to assume vwrite() always return the full buffer length.
However now vwrite() could return 0 to indicate memory hole. This creates
a bug that "buf" is not advanced accordingly.

Fix it to simply ignore the return value, hence the memory hole.

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

--- linux-2.6.32.orig/drivers/char/mem.c	2010-02-04 10:37:55.000000000 +0800
+++ linux-2.6.32/drivers/char/mem.c	2010-02-04 10:37:59.000000000 +0800
@@ -599,7 +599,7 @@ static ssize_t write_kmem(struct file * 
 					break;
 				}
 			}
-			len = vwrite(kbuf, (char *)p, len);
+			vwrite(kbuf, (char *)p, len);
 			count -= len;
 			buf += len;
 			virtr += len;

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

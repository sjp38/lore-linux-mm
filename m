Date: Mon, 1 Dec 2008 00:32:04 +0000 (GMT)
From: Hugh Dickins <hugh@veritas.com>
Subject: [PATCH 11/9] swapfile: let others seed random
In-Reply-To: <Pine.LNX.4.64.0811252146090.20455@blonde.site>
Message-ID: <Pine.LNX.4.64.0812010029550.10131@blonde.site>
References: <Pine.LNX.4.64.0811252132580.17555@blonde.site>
 <Pine.LNX.4.64.0811252140230.17555@blonde.site> <Pine.LNX.4.64.0811252146090.20455@blonde.site>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: David Woodhouse <dwmw2@infradead.org>, Jens Axboe <jens.axboe@oracle.com>, Matthew Wilcox <matthew@wil.cx>, Joern Engel <joern@logfs.org>, James Bottomley <James.Bottomley@HansenPartnership.com>, Donjun Shin <djshin90@gmail.com>, Tejun Heo <teheo@suse.de>, Arjan van de Ven <arjan@infradead.org>, Matt Mackall <mpm@selenic.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

Remove the srandom32((u32)get_seconds()) from non-rotational swapon:
there's been a coincidental discussion of earlier randomization, assume
that goes ahead, let swapon be a client rather than stirring for itself.

Signed-off-by: Hugh Dickins <hugh@veritas.com>
---
To follow 10/9

 mm/swapfile.c |    1 -
 1 file changed, 1 deletion(-)

--- swapfile10/mm/swapfile.c	2008-11-28 20:36:44.000000000 +0000
+++ swapfile11/mm/swapfile.c	2008-11-28 20:37:16.000000000 +0000
@@ -1842,7 +1842,6 @@ asmlinkage long sys_swapon(const char __
 
 	if (blk_queue_nonrot(bdev_get_queue(p->bdev))) {
 		p->flags |= SWP_SOLIDSTATE;
-		srandom32((u32)get_seconds());
 		p->cluster_next = 1 + (random32() % p->highest_bit);
 	}
 	if (discard_swap(p) == 0)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

Date: Sat, 4 Aug 2001 17:21:16 +0100 (BST)
From: Mark Hemment <markhe@veritas.com>
Subject: Re: [RFC][DATA] re "ongoing vm suckage"
In-Reply-To: <Pine.LNX.4.33.0108032330450.1193-100000@penguin.transmeta.com>
Message-ID: <Pine.LNX.4.33.0108041717540.26125-100000@alloc.wat.veritas.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Linus Torvalds <torvalds@transmeta.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, Hugh Dickins <hugh@veritas.com>
List-ID: <linux-mm.kvack.org>

On Fri, 3 Aug 2001, Linus Torvalds wrote:
> Well, I've made a 2.4.8-pre4.

  A colleague has reminded me that we this small patch against
flush_dirty_buffers() - kick the disk queues before sleeping.

Mark


--- linux-2.4.8-pre4/fs/buffer.c	Sat Aug  4 11:49:52 2001
+++ linux/fs/buffer.c	Sat Aug  4 11:56:25 2001
@@ -2568,8 +2568,11 @@
 		ll_rw_block(WRITE, 1, &bh);
 		put_bh(bh);

-		if (current->need_resched)
+		if (current->need_resched) {
+			/* kick what we've already pushed down */
+			run_task_queue(&tq_disk);
 			schedule();
+		}
 		goto restart;
 	}
  out_unlock:

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/

Received: (from sct@localhost)
	by sisko.scot.redhat.com (8.11.6/8.11.2) id gA6LxmK23126
	for linux-mm@kvack.org; Wed, 6 Nov 2002 21:59:48 GMT
Date: Wed, 6 Nov 2002 21:59:48 GMT
Resent-Message-Id: <200211062159.gA6LxmK23126@sisko.scot.redhat.com>
Message-Id: <200211062159.gA6LxmK23126@sisko.scot.redhat.com>
From: "Stephen C. Tweedie" <sct@redhat.com>
Subject: [patch] Buffers pinning inodes in icache forever
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="sHrvAb52M6C8blB9"
Content-Disposition: inline
Resent-To: linux-mm@kvack.org
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@zip.com.au>, linux-mm@kvack.org
Cc: Stephen Tweedie <sct@redhat.com>
List-ID: <linux-mm.kvack.org>

--sHrvAb52M6C8blB9
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

Hi,

In chasing a performance problem on a 2.4.9-based VM (yes, that one!),
we found a case where kswapd was consuming massive CPU time, 97% of
which was in prune_icache (and of that, about 7% was in the
inode_has_buffers() sub-function).  slabinfo showed about 100k inodes
in use.

The hypothesis is that we've got buffers in cache pinning the inodes.
It's not pages doing the pinning because if the inode page count is
zero we never perform the inode_has_buffers() test.

On buffer write, the bh goes onto BUF_LOCKED, but never gets removed
from there.  In other testing I've seen several GB of memory in
BUF_LOCKED bh'es during extensive write loads. 

That's normally no problem, except that the lack of a refile_buffer()
on those bh'es also keeps them on the inode's own buffer lists.  If
it's metadata that the buffers back (ie. it's all in low memory) and
the demand on the system is for highmem pages, then we're not
necessarily going to be aggressively doing try_to_release_page() on
the lowmem pages which would allow the bhes to be refiled.

Doing the refile really isn't hard, either.  We expect IO completion
to be happening in approximately list order on the BUF_LOCKED list, so
simply doing a refile on any unlocked buffers at the head of that list
is going to keep it under control in O(1) time per buffer.

With the patch below we've not seen this particular pathology recur.
Comments?

--Stephen

--sHrvAb52M6C8blB9
Content-Type: text/plain; charset=us-ascii
Content-Disposition: attachment; filename="io-postprocess.patch"

--- linux/fs/buffer.c.orig	Fri Oct 25 09:53:43 2002
+++ linux/fs/buffer.c	Fri Oct 25 10:15:51 2002
@@ -2835,6 +2835,30 @@
 	}
 }
 
+
+/*
+ * Do some IO post-processing here!!!
+ */
+void do_io_postprocessing(void)
+{
+	int i;
+	struct buffer_head *bh, *next;
+
+	spin_lock(&lru_list_lock);
+	bh = lru_list[BUF_LOCKED];
+	if (bh) {
+		for (i = nr_buffers_type[BUF_LOCKED]; i-- > 0; bh = next) {
+			next = bh->b_next_free;
+
+			if (!buffer_locked(bh)) 
+				__refile_buffer(bh);
+			else 
+				break;
+		}
+	}
+	spin_unlock(&lru_list_lock);
+}
+
 /*
  * This is the kernel update daemon. It was used to live in userspace
  * but since it's need to run safely we want it unkillable by mistake.
@@ -2886,6 +2910,7 @@
 #ifdef DEBUG
 		printk(KERN_DEBUG "kupdate() activated...\n");
 #endif
+		do_io_postprocessing();
 		sync_old_buffers();
 	}
 }

--sHrvAb52M6C8blB9--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/

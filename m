Received: from wli by holomorphy with local (Exim 3.34 #1 (Debian))
	id 17uRQQ-0002kr-00
	for <linux-mm@kvack.org>; Wed, 25 Sep 2002 22:42:58 -0700
Date: Wed, 25 Sep 2002 22:42:57 -0700
From: William Lee Irwin III <wli@holomorphy.com>
Subject: [7/13] use __GFP_NOKILL in sys_poll()'s top-level fd table
Message-ID: <20020926054257.GN22942@holomorphy.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Description: brief message
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

The struct pollfd allocation in sys_poll() is done in response to
a system call which may be failed instead of OOM killing other tasks.


diff -urN linux-2.5.33/fs/select.c linux-2.5.33-mm5/fs/select.c
--- linux-2.5.33/fs/select.c	2002-08-31 15:04:47.000000000 -0700
+++ linux-2.5.33-mm5/fs/select.c	2002-09-08 22:00:56.000000000 -0700
@@ -439,7 +439,7 @@
 	if (nfds != 0) {
 		fds = (struct pollfd **)kmalloc(
 			(1 + (nfds - 1) / POLLFD_PER_PAGE) * sizeof(struct pollfd *),
-			GFP_KERNEL);
+			GFP_KERNEL | __GFP_NOKILL);
 		if (fds == NULL)
 			goto out;
 	}
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/

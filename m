Received: from wli by holomorphy with local (Exim 3.34 #1 (Debian))
	id 17uRQW-0002l3-00
	for <linux-mm@kvack.org>; Wed, 25 Sep 2002 22:43:04 -0700
Date: Wed, 25 Sep 2002 22:43:04 -0700
From: William Lee Irwin III <wli@holomorphy.com>
Subject: [8/13] use __GFP_NOKILL in fd chunk allocation
Message-ID: <20020926054304.GO22942@holomorphy.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Description: brief message
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

The fdchunks are allocated in sys_poll() in response to a system call
whose allocations may be failed.


diff -urN linux-2.5.33/fs/select.c linux-2.5.33-mm5/fs/select.c
--- linux-2.5.33/fs/select.c	2002-08-31 15:04:47.000000000 -0700
+++ linux-2.5.33-mm5/fs/select.c	2002-09-08 22:00:56.000000000 -0700
@@ -447,14 +447,14 @@
 	nchunks = 0;
 	nleft = nfds;
 	while (nleft > POLLFD_PER_PAGE) { /* allocate complete PAGE_SIZE chunks */
-		fds[nchunks] = (struct pollfd *)__get_free_page(GFP_KERNEL);
+		fds[nchunks] = (struct pollfd *)__get_free_page(GFP_KERNEL | __GFP_NOKILL);
 		if (fds[nchunks] == NULL)
 			goto out_fds;
 		nchunks++;
 		nleft -= POLLFD_PER_PAGE;
 	}
 	if (nleft) { /* allocate last PAGE_SIZE chunk, only nleft elements used */
-		fds[nchunks] = (struct pollfd *)__get_free_page(GFP_KERNEL);
+		fds[nchunks] = (struct pollfd *)__get_free_page(GFP_KERNEL | __GFP_NOKILL);
 		if (fds[nchunks] == NULL)
 			goto out_fds;
 	}
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/

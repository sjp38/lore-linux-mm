Received: from wli by holomorphy with local (Exim 3.34 #1 (Debian))
	id 17uRQB-0002kK-00
	for <linux-mm@kvack.org>; Wed, 25 Sep 2002 22:42:43 -0700
Date: Wed, 25 Sep 2002 22:42:43 -0700
From: William Lee Irwin III <wli@holomorphy.com>
Subject: [5/13] use __GFP_NOKILL in poll table pages
Message-ID: <20020926054243.GL22942@holomorphy.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Description: brief message
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Poll tables are build in order to service syscalls, and failing the
poll() call is a superior alternative to invoking the OOM killer.


diff -urN linux-2.5.33/fs/select.c linux-2.5.33-mm5/fs/select.c
--- linux-2.5.33/fs/select.c	2002-08-31 15:04:47.000000000 -0700
+++ linux-2.5.33-mm5/fs/select.c	2002-09-08 22:00:56.000000000 -0700
@@ -80,7 +80,7 @@
 	if (!table || POLL_TABLE_FULL(table)) {
 		struct poll_table_page *new_table;
 
-		new_table = (struct poll_table_page *) __get_free_page(GFP_KERNEL);
+		new_table = (struct poll_table_page *) __get_free_page(GFP_KERNEL | __GFP_NOKILL);
 		if (!new_table) {
 			p->error = -ENOMEM;
 			__set_current_state(TASK_RUNNING);
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/

Received: from smtp3.akamai.com (vwall3.sanmateo.corp.akamai.com [172.23.1.73])
	by smtp3.akamai.com (8.12.10/8.12.10) with ESMTP id j2D98Z6O027204
	for <linux-mm@kvack.org>; Sun, 13 Mar 2005 01:08:35 -0800 (PST)
From: pmeda@akamai.com
Date: Sun, 13 Mar 2005 01:17:15 -0800
Message-Id: <200503130917.BAA07197@allur.sanmateo.akamai.com>
Subject: [PATCH] dcache: is_subdir missed reset after seqretry
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: akpm@osdl.org
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

dcache: is_subdir forgot to reset the result after seqretry.

Signed-Off-by: Prasanna Meda <pmeda@akamai.com>


--- aLinux/fs/dcache.c	Sun Mar 13 08:40:47 2005
+++ bLinux/fs/dcache.c	Sun Mar 13 08:56:27 2005
@@ -1532,7 +1532,6 @@
 	struct dentry * saved = new_dentry;
 	unsigned long seq;
 
-	result = 0;
 	/* need rcu_readlock to protect against the d_parent trashing due to
 	 * d_move
 	 */
@@ -1540,6 +1539,7 @@
         do {
 		/* for restarting inner loop in case of seq retry */
 		new_dentry = saved;
+		result = 0;
 		seq = read_seqbegin(&rename_lock);
 		for (;;) {
 			if (new_dentry != old_dentry) {
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>

Received: from smtp3.akamai.com (vwall1.sanmateo.corp.akamai.com [172.23.1.71])
	by smtp3.akamai.com (8.12.10/8.12.10) with ESMTP id j0C3FWNZ017927
	for <linux-mm@kvack.org>; Tue, 11 Jan 2005 19:15:33 -0800 (PST)
From: pmeda@akamai.com
Date: Tue, 11 Jan 2005 19:18:26 -0800
Message-Id: <200501120318.TAA01328@allur.sanmateo.akamai.com>
Subject: [patch] poll: minor opts
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: akpm@osdl.org
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

poll mini optimisations:
When poll returns error, we do not need to copy out the the revents.
When poll returns succeess, we can copy pollfds in units of pages, since
there is no harm in copying fds and events back.

Signed-off-by:  Prasanna Meda <pmeda@akamai.com>


--- a/fs/select.c	Wed Jan 12 01:59:08 2005
+++ b/fs/select.c	Wed Jan 12 02:31:45 2005
@@ -501,24 +501,24 @@
 		}
 		i -= pp->len;
 	}
-	fdcount = do_poll(nfds, head, &table, timeout);
+
+	err = fdcount = do_poll(nfds, head, &table, timeout);
+	if (!fdcount && signal_pending(current))
+		err = -EINTR;
+	if (err < 0)
+		goto out_fds;
 
 	/* OK, now copy the revents fields back to user space. */
 	walk = head;
 	err = -EFAULT;
 	while(walk != NULL) {
 		struct pollfd *fds = walk->entries;
-		int j;
-
-		for (j=0; j < walk->len; j++, ufds++) {
-			if(__put_user(fds[j].revents, &ufds->revents))
-				goto out_fds;
-		}
+		if (copy_to_user(ufds, fds, sizeof(struct pollfd) * walk->len))
+			goto out_fds;
+		ufds += walk->len;
 		walk = walk->next;
   	}
 	err = fdcount;
-	if (!fdcount && signal_pending(current))
-		err = -EINTR;
 out_fds:
 	walk = head;
 	while(walk!=NULL) {
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>

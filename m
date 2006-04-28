Date: Thu, 27 Apr 2006 23:42:08 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [PATCH 7/7] page migration: Add new fallback function
In-Reply-To: <20060428060333.30257.43096.sendpatchset@schroedinger.engr.sgi.com>
Message-ID: <Pine.LNX.4.64.0604272341390.30557@schroedinger.engr.sgi.com>
References: <20060428060302.30257.76871.sendpatchset@schroedinger.engr.sgi.com>
 <20060428060333.30257.43096.sendpatchset@schroedinger.engr.sgi.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: akpm@osdl.org
Cc: linux-mm@kvack.org, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Lee Schermerhorn <lee.schermerhorn@hp.com>, Hugh Dickins <hugh@veritas.com>
List-ID: <linux-mm.kvack.org>

Hmmm... We need to get rid of if(PageLocked())

This introduced another race condition since another process may have
locked the page. Simply relock the page after successfully calling
migratepages() and then retry.

Signed-off-by: Christoph Lameter <clameter@sgi.com>

Index: linux-2.6.17-rc2-mm1/mm/migrate.c
===================================================================
--- linux-2.6.17-rc2-mm1.orig/mm/migrate.c	2006-04-27 22:55:46.731119932 -0700
+++ linux-2.6.17-rc2-mm1/mm/migrate.c	2006-04-27 23:39:11.853319378 -0700
@@ -476,17 +476,20 @@
 			/* Someone else already triggered a write */
 			return -EAGAIN;
 
-		if (mapping->a_ops->writepage(page, &wbc) < 0)
+		rc = mapping->a_ops->writepage(page, &wbc);
+		if (rc < 0)
 			/* I/O Error writing */
 			return -EIO;
 
+		if (rc == AOP_WRITEPAGE_ACTIVATE)
+			return -EAGAIN;
+
+		lock_page(page);
 		/*
-		 * Retry if writepage() removed the lock or the page
-		 * is still dirty or undergoing writeback.
+		 * The lock was dropped by writepage() and so something
+		 * may have changed with the page.
 		 */
-		if (!PageLocked(page) ||
-			PageWriteback(page) || PageDirty(page))
-				return -EAGAIN;
+		return -EAGAIN;
 	}
 
 	/*
@@ -599,8 +602,7 @@
 
 		unlock_page(newpage);
 unlock_page:
-		if (PageLocked(page))	/* writepage() may unlock */
-			unlock_page(page);
+		unlock_page(page);
 
 next:
 		if (rc) {

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

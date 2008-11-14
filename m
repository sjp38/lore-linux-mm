Date: Fri, 14 Nov 2008 02:32:20 +0000 (GMT)
From: Hugh Dickins <hugh@veritas.com>
Subject: [PATCH 2.6.28?] fix migration writepage error
Message-ID: <Pine.LNX.4.64.0811140231000.5027@blonde.site>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Page migration's writeout() has got understandably confused by the nasty
AOP_WRITEPAGE_ACTIVATE case: as in normal success, a writepage() error
has unlocked the page, so writeout() then needs to relock it.

Signed-off-by: Hugh Dickins <hugh@veritas.com>
---
I'll remove AOP_WRITEPAGE_ACTIVATE later, but this fix seems more urgent.

 mm/migrate.c |    5 +----
 1 file changed, 1 insertion(+), 4 deletions(-)

--- 2.6.28-rc4/mm/migrate.c	2008-11-10 11:27:02.000000000 +0000
+++ linux/mm/migrate.c	2008-11-12 11:52:44.000000000 +0000
@@ -522,15 +522,12 @@ static int writeout(struct address_space
 	remove_migration_ptes(page, page);
 
 	rc = mapping->a_ops->writepage(page, &wbc);
-	if (rc < 0)
-		/* I/O Error writing */
-		return -EIO;
 
 	if (rc != AOP_WRITEPAGE_ACTIVATE)
 		/* unlocked. Relock */
 		lock_page(page);
 
-	return -EAGAIN;
+	return (rc < 0) ? -EIO : -EAGAIN;
 }
 
 /*

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

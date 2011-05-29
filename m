Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta12.messagelabs.com (mail6.bemta12.messagelabs.com [216.82.250.247])
	by kanga.kvack.org (Postfix) with ESMTP id 130BA6B0012
	for <linux-mm@kvack.org>; Sun, 29 May 2011 16:39:43 -0400 (EDT)
Received: from unknown (HELO localhost.localdomain) (zcndxNqBwcve2s/KpKWToZWJlF6Wp6IuYnI=@[201.23.160.70])
          (envelope-sender <cesarb@cesarb.net>)
          by smtp-02.mandic.com.br (qmail-ldap-1.03) with AES256-SHA encrypted SMTP
          for <linux-mm@kvack.org>; 29 May 2011 20:39:36 -0000
From: Cesar Eduardo Barros <cesarb@cesarb.net>
Subject: [PATCH] cleancache: use __read_mostly for cleancache_enabled
Date: Sun, 29 May 2011 17:38:18 -0300
Message-Id: <1306701498-10846-1-git-send-email-cesarb@cesarb.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: Minchan Kim <minchan.kim@gmail.com>, Jan Beulich <JBeulich@novell.com>, Andrew Morton <akpm@linux-foundation.org>, Andreas Dilger <adilger@sun.com>, Dan Magenheimer <dan.magenheimer@oracle.com>, Jeremy Fitzhardinge <jeremy@goop.org>, linux-kernel@vger.kernel.org, Cesar Eduardo Barros <cesarb@cesarb.net>

The global variable cleancache_enabled is read often but written to
rarely. Use __read_mostly to prevent it being on the same cacheline as
another variable which is written to often, which would cause cacheline
bouncing.

Signed-off-by: Cesar Eduardo Barros <cesarb@cesarb.net>
---
 include/linux/cleancache.h |    2 +-
 mm/cleancache.c            |    2 +-
 2 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/include/linux/cleancache.h b/include/linux/cleancache.h
index 04ffb2e..83fffe8 100644
--- a/include/linux/cleancache.h
+++ b/include/linux/cleancache.h
@@ -42,7 +42,7 @@ extern void __cleancache_put_page(struct page *);
 extern void __cleancache_flush_page(struct address_space *, struct page *);
 extern void __cleancache_flush_inode(struct address_space *);
 extern void __cleancache_flush_fs(struct super_block *);
-extern int cleancache_enabled;
+extern int cleancache_enabled __read_mostly;
 
 #ifdef CONFIG_CLEANCACHE
 static inline bool cleancache_fs_enabled(struct page *page)
diff --git a/mm/cleancache.c b/mm/cleancache.c
index bcaae4c..a3d7a22 100644
--- a/mm/cleancache.c
+++ b/mm/cleancache.c
@@ -24,7 +24,7 @@
  * disabled), so is preferred to the slower alternative: a function
  * call that checks a non-global.
  */
-int cleancache_enabled;
+int cleancache_enabled __read_mostly;
 EXPORT_SYMBOL(cleancache_enabled);
 
 /*
-- 
1.7.4.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

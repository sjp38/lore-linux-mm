Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx110.postini.com [74.125.245.110])
	by kanga.kvack.org (Postfix) with SMTP id 589426B0006
	for <linux-mm@kvack.org>; Wed,  6 Mar 2013 03:52:43 -0500 (EST)
Received: by mail-pb0-f46.google.com with SMTP id uo15so5694400pbc.33
        for <linux-mm@kvack.org>; Wed, 06 Mar 2013 00:52:42 -0800 (PST)
From: Bob Liu <lliubbo@gmail.com>
Subject: [PATCH V2 07/11] mm: cleancache: clean up cleancache_enabled
Date: Wed,  6 Mar 2013 16:51:26 +0800
Message-Id: <1362559890-16710-7-git-send-email-lliubbo@gmail.com>
In-Reply-To: <1362559890-16710-1-git-send-email-lliubbo@gmail.com>
References: <1362559890-16710-1-git-send-email-lliubbo@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: dan.magenheimer@oracle.com, konrad.wilk@oracle.com, sjenning@linux.vnet.ibm.com, gregkh@linuxfoundation.org, akpm@linux-foundation.org, rcj@linux.vnet.ibm.com, ngupta@vflare.org, minchan@kernel.org, ric.masonn@gmail.com, Bob Liu <lliubbo@gmail.com>

cleancache_ops is used to decide whether backend is registered.
So now cleancache_enabled is always true if defined CONFIG_CLEANCACHE.

Signed-off-by: Bob Liu <lliubbo@gmail.com>
---
 include/linux/cleancache.h |    2 +-
 mm/cleancache.c            |   11 -----------
 2 files changed, 1 insertion(+), 12 deletions(-)

diff --git a/include/linux/cleancache.h b/include/linux/cleancache.h
index 3af5ea8..4ce9056 100644
--- a/include/linux/cleancache.h
+++ b/include/linux/cleancache.h
@@ -42,9 +42,9 @@ extern void __cleancache_put_page(struct page *);
 extern void __cleancache_invalidate_page(struct address_space *, struct page *);
 extern void __cleancache_invalidate_inode(struct address_space *);
 extern void __cleancache_invalidate_fs(struct super_block *);
-extern int cleancache_enabled;
 
 #ifdef CONFIG_CLEANCACHE
+#define cleancache_enabled (1)
 static inline bool cleancache_fs_enabled(struct page *page)
 {
 	return page->mapping->host->i_sb->cleancache_poolid >= 0;
diff --git a/mm/cleancache.c b/mm/cleancache.c
index 8d8fb4e..4ac1b57 100644
--- a/mm/cleancache.c
+++ b/mm/cleancache.c
@@ -19,16 +19,6 @@
 #include <linux/cleancache.h>
 
 /*
- * This global enablement flag may be read thousands of times per second
- * by cleancache_get/put/invalidate even on systems where cleancache_ops
- * is not claimed (e.g. cleancache is config'ed on but remains
- * disabled), so is preferred to the slower alternative: a function
- * call that checks a non-global.
- */
-int cleancache_enabled __read_mostly;
-EXPORT_SYMBOL(cleancache_enabled);
-
-/*
  * cleancache_ops is set by cleancache_ops_register to contain the pointers
  * to the cleancache "backend" implementation functions.
  */
@@ -414,7 +404,6 @@ static int __init init_cleancache(void)
 		fs_poolid_map[i] = FS_UNKNOWN;
 		shared_fs_poolid_map[i] = FS_UNKNOWN;
 	}
-	cleancache_enabled = 1;
 	return 0;
 }
 module_init(init_cleancache)
-- 
1.7.10.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx188.postini.com [74.125.245.188])
	by kanga.kvack.org (Postfix) with SMTP id 859B36B002D
	for <linux-mm@kvack.org>; Fri, 15 Feb 2013 15:20:49 -0500 (EST)
From: Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>
Subject: [PATCH 08/11] cleancache: Remove the check for cleancache_enabled.
Date: Fri, 15 Feb 2013 15:20:32 -0500
Message-Id: <1360959635-18922-9-git-send-email-konrad.wilk@oracle.com>
In-Reply-To: <1360959635-18922-1-git-send-email-konrad.wilk@oracle.com>
References: <1360959635-18922-1-git-send-email-konrad.wilk@oracle.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: dan.magenheimer@oracle.com, sjenning@linux.vnet.ibm.com, gregkh@linuxfoundation.org, akpm@linux-foundation.org, ngupta@vflare.org, rcj@linux.vnet.ibm.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, devel@driverdev.osuosl.org, minchan@kernel.org
Cc: ric.masonn@gmail.com, lliubbo@gmail.com, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>

With the support for loading of backends as modules, the
cleancache_enabled is always set to true. The next subsequent patches
are going to convert the cleancache_enabled to be a bit more selective
and be on/off depending on whether the backend has registered - and not
whether the cleancache API is enabled.

The three functions: cleancache_init_[shared|]fs and
cleancache_invalidate_fs can be called anytime - they queue up which
of the filesystems are active and can use the cleancache API - and when
the backend is registered they will know which filesystem to
process.

Signed-off-by: Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>
---
 include/linux/cleancache.h | 9 +++------
 1 file changed, 3 insertions(+), 6 deletions(-)

diff --git a/include/linux/cleancache.h b/include/linux/cleancache.h
index 3af5ea8..dfa1ccb 100644
--- a/include/linux/cleancache.h
+++ b/include/linux/cleancache.h
@@ -74,14 +74,12 @@ static inline bool cleancache_fs_enabled_mapping(struct address_space *mapping)
 
 static inline void cleancache_init_fs(struct super_block *sb)
 {
-	if (cleancache_enabled)
-		__cleancache_init_fs(sb);
+	__cleancache_init_fs(sb);
 }
 
 static inline void cleancache_init_shared_fs(char *uuid, struct super_block *sb)
 {
-	if (cleancache_enabled)
-		__cleancache_init_shared_fs(uuid, sb);
+	__cleancache_init_shared_fs(uuid, sb);
 }
 
 static inline int cleancache_get_page(struct page *page)
@@ -115,8 +113,7 @@ static inline void cleancache_invalidate_inode(struct address_space *mapping)
 
 static inline void cleancache_invalidate_fs(struct super_block *sb)
 {
-	if (cleancache_enabled)
-		__cleancache_invalidate_fs(sb);
+	__cleancache_invalidate_fs(sb);
 }
 
 #endif /* _LINUX_CLEANCACHE_H */
-- 
1.8.0.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ea0-f180.google.com (mail-ea0-f180.google.com [209.85.215.180])
	by kanga.kvack.org (Postfix) with ESMTP id B6FF76B0031
	for <linux-mm@kvack.org>; Fri,  7 Feb 2014 10:20:48 -0500 (EST)
Received: by mail-ea0-f180.google.com with SMTP id o10so1640216eaj.39
        for <linux-mm@kvack.org>; Fri, 07 Feb 2014 07:20:48 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTP id k3si8922058eep.15.2014.02.07.07.20.39
        for <linux-mm@kvack.org>;
        Fri, 07 Feb 2014 07:20:43 -0800 (PST)
From: Rafael Aquini <aquini@redhat.com>
Subject: [PATCH] mm: fix page leak at nfs_symlink()
Date: Fri,  7 Feb 2014 13:19:54 -0200
Message-Id: <f4b3dc07dfa55bf7931de36b03aa9ef7e3ff0490.1391785222.git.aquini@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: trond.myklebust@primarydata.com, jstancek@redhat.com, jlayton@redhat.com, mgorman@suse.de, riel@redhat.com, linux-nfs@vger.kernel.org, akpm@linux-foundation.org, linux-mm@kvack.org

Changes committed by "a0b8cab3 mm: remove lru parameter from
__pagevec_lru_add and remove parts of pagevec API" have introduced
a call to add_to_page_cache_lru() which causes a leak in nfs_symlink() 
as now the page gets an extra refcount that is not dropped.

Jan Stancek observed and reported the leak effect while running test8 from
Connectathon Testsuite. After several iterations over the test case,
which creates several symlinks on a NFS mountpoint, the test system was
quickly getting into an out-of-memory scenario.

This patch fixes the page leak by dropping that extra refcount 
add_to_page_cache_lru() is grabbing. 

Signed-off-by: Jan Stancek <jstancek@redhat.com>
Signed-off-by: Rafael Aquini <aquini@redhat.com>
---
 fs/nfs/dir.c | 5 +++++
 1 file changed, 5 insertions(+)

diff --git a/fs/nfs/dir.c b/fs/nfs/dir.c
index be38b57..4a48fe4 100644
--- a/fs/nfs/dir.c
+++ b/fs/nfs/dir.c
@@ -1846,6 +1846,11 @@ int nfs_symlink(struct inode *dir, struct dentry *dentry, const char *symname)
 							GFP_KERNEL)) {
 		SetPageUptodate(page);
 		unlock_page(page);
+		/*
+		 * add_to_page_cache_lru() grabs an extra page refcount.
+		 * Drop it here to avoid leaking this page later.
+		 */
+		page_cache_release(page);
 	} else
 		__free_page(page);
 
-- 
1.8.5.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

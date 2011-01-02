Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id 4B42C6B0092
	for <linux-mm@kvack.org>; Sun,  2 Jan 2011 10:44:58 -0500 (EST)
Received: by mail-pv0-f169.google.com with SMTP id 30so2959819pvc.14
        for <linux-mm@kvack.org>; Sun, 02 Jan 2011 07:44:57 -0800 (PST)
From: Minchan Kim <minchan.kim@gmail.com>
Subject: [PATCH v2 2/7] fuse: Change remove_from_page_cache
Date: Mon,  3 Jan 2011 00:44:31 +0900
Message-Id: <f5a696e5b34566a2942d655f6b7e29ee63c5a12a.1293982522.git.minchan.kim@gmail.com>
In-Reply-To: <cover.1293982522.git.minchan.kim@gmail.com>
References: <cover.1293982522.git.minchan.kim@gmail.com>
In-Reply-To: <cover.1293982522.git.minchan.kim@gmail.com>
References: <cover.1293982522.git.minchan.kim@gmail.com>
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Hugh Dickins <hughd@google.com>, Minchan Kim <minchan.kim@gmail.com>, Miklos Szeredi <miklos@szeredi.hu>, fuse-devel@lists.sourceforge.net
List-ID: <linux-mm.kvack.org>

This patch series changes remove_from_page_cache's page ref counting
rule. Page cache ref count is decreased in delete_from_page_cache.
So we don't need decreasing page reference by caller.

Cc: Miklos Szeredi <miklos@szeredi.hu>
Cc: fuse-devel@lists.sourceforge.net
Acked-by: Hugh Dickins <hughd@google.com>
Reviewed-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Signed-off-by: Minchan Kim <minchan.kim@gmail.com>
---
 fs/fuse/dev.c |    3 +--
 1 files changed, 1 insertions(+), 2 deletions(-)

diff --git a/fs/fuse/dev.c b/fs/fuse/dev.c
index cf8d28d..1ef24fb 100644
--- a/fs/fuse/dev.c
+++ b/fs/fuse/dev.c
@@ -737,8 +737,7 @@ static int fuse_try_move_page(struct fuse_copy_state *cs, struct page **pagep)
 	if (WARN_ON(PageMlocked(oldpage)))
 		goto out_fallback_unlock;
 
-	remove_from_page_cache(oldpage);
-	page_cache_release(oldpage);
+	delete_from_page_cache(oldpage);
 
 	err = add_to_page_cache_locked(newpage, mapping, index, GFP_KERNEL);
 	if (err) {
-- 
1.7.0.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

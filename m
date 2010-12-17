Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id 5F0D06B009B
	for <linux-mm@kvack.org>; Fri, 17 Dec 2010 12:14:00 -0500 (EST)
Received: by pxi7 with SMTP id 7so196433pxi.8
        for <linux-mm@kvack.org>; Fri, 17 Dec 2010 09:13:58 -0800 (PST)
From: Minchan Kim <minchan.kim@gmail.com>
Subject: [RFC 2/5] fuse: Remove unnecessary page release
Date: Sat, 18 Dec 2010 02:13:37 +0900
Message-Id: <16cfab4a6cb77f47f9a632a774d8bd04b4fe9ff2.1292604745.git.minchan.kim@gmail.com>
In-Reply-To: <cover.1292604745.git.minchan.kim@gmail.com>
References: <cover.1292604745.git.minchan.kim@gmail.com>
In-Reply-To: <cover.1292604745.git.minchan.kim@gmail.com>
References: <cover.1292604745.git.minchan.kim@gmail.com>
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Minchan Kim <minchan.kim@gmail.com>, Miklos Szeredi <miklos@szeredi.hu>, fuse-devel@lists.sourceforge.net
List-ID: <linux-mm.kvack.org>

This patch series changes remove_from_page_cache's page ref counting
rule. page cache ref count is decreased in remove_from_page_cache.
So we don't need call again in caller context.

Cc: Miklos Szeredi <miklos@szeredi.hu>
Cc: fuse-devel@lists.sourceforge.net
Signed-off-by: Minchan Kim <minchan.kim@gmail.com>
---
 fs/fuse/dev.c |    1 -
 1 files changed, 0 insertions(+), 1 deletions(-)

diff --git a/fs/fuse/dev.c b/fs/fuse/dev.c
index cf8d28d..4adaf4b 100644
--- a/fs/fuse/dev.c
+++ b/fs/fuse/dev.c
@@ -738,7 +738,6 @@ static int fuse_try_move_page(struct fuse_copy_state *cs, struct page **pagep)
 		goto out_fallback_unlock;
 
 	remove_from_page_cache(oldpage);
-	page_cache_release(oldpage);
 
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

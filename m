Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx137.postini.com [74.125.245.137])
	by kanga.kvack.org (Postfix) with SMTP id 9BD706B0033
	for <linux-mm@kvack.org>; Mon, 13 May 2013 10:16:51 -0400 (EDT)
From: Oskar Andero <oskar.andero@sonymobile.com>
Subject: [RFC PATCH 1/2] mm: vmscan: let any negative return value from shrinker mean error
Date: Mon, 13 May 2013 16:16:34 +0200
Message-ID: <1368454595-5121-2-git-send-email-oskar.andero@sonymobile.com>
In-Reply-To: <1368454595-5121-1-git-send-email-oskar.andero@sonymobile.com>
References: <1368454595-5121-1-git-send-email-oskar.andero@sonymobile.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org, linux-mm@kvack.org
Cc: Hugh Dickins <hughd@google.com>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Radovan Lekanovic <radovan.lekanovic@sonymobile.com>, David Rientjes <rientjes@google.com>, Oskar Andero <oskar.andero@sonymobile.com>

The shrinkers must return -1 to indicate that it is busy. Instead of
relaying on magical numbers, let any negative value indicate error. This
opens up for using the errno.h error codes in the shrinker
implementations.

Cc: Hugh Dickins <hughd@google.com>
Cc: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Signed-off-by: Oskar Andero <oskar.andero@sonymobile.com>
---
 include/linux/shrinker.h | 5 +++--
 mm/vmscan.c              | 2 +-
 2 files changed, 4 insertions(+), 3 deletions(-)

diff --git a/include/linux/shrinker.h b/include/linux/shrinker.h
index ac6b8ee..31e9406 100644
--- a/include/linux/shrinker.h
+++ b/include/linux/shrinker.h
@@ -18,8 +18,9 @@ struct shrink_control {
  * 'sc' is passed shrink_control which includes a count 'nr_to_scan'
  * and a 'gfpmask'.  It should look through the least-recently-used
  * 'nr_to_scan' entries and attempt to free them up.  It should return
- * the number of objects which remain in the cache.  If it returns -1, it means
- * it cannot do any scanning at this time (eg. there is a risk of deadlock).
+ * the number of objects which remain in the cache.  If it returns a
+ * negative error code, it means it cannot do any scanning at this time
+ * (eg. there is a risk of deadlock).
  *
  * The 'gfpmask' refers to the allocation we are currently trying to
  * fulfil.
diff --git a/mm/vmscan.c b/mm/vmscan.c
index fa6a853..d6ac9a8 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -287,7 +287,7 @@ unsigned long shrink_slab(struct shrink_control *shrink,
 			nr_before = do_shrinker_shrink(shrinker, shrink, 0);
 			shrink_ret = do_shrinker_shrink(shrinker, shrink,
 							batch_size);
-			if (shrink_ret == -1)
+			if (shrink_ret < 0)
 				break;
 			if (shrink_ret < nr_before)
 				ret += nr_before - shrink_ret;
-- 
1.8.1.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

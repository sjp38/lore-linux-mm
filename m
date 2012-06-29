Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx161.postini.com [74.125.245.161])
	by kanga.kvack.org (Postfix) with SMTP id 6D15F6B005A
	for <linux-mm@kvack.org>; Fri, 29 Jun 2012 00:51:24 -0400 (EDT)
From: Minchan Kim <minchan@kernel.org>
Subject: [PATCH] vmscan: remove obsolete comment of shrinker
Date: Fri, 29 Jun 2012 13:51:40 +0900
Message-Id: <1340945500-14566-1-git-send-email-minchan@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, Minchan Kim <minchan@kernel.org>, Al Viro <viro@zeniv.linux.org.uk>, Mikulas Patocka <mpatocka@redhat.com>, Konstantin Khlebnikov <khlebnikov@openvz.org>

09f363c7 fixed shrinker callback returns -1 when nr_to_scan is zero
for preventing excessive the slab scanning. But 635697c6 fixed the
problem, again so we can freely return -1 although nr_to_scan is zero.
So let's revert 09f363c7 because the comment added in 09f363c7 made a
unnecessary rule shrinker user should be aware of.

Cc: Al Viro <viro@zeniv.linux.org.uk>
Cc: Mikulas Patocka <mpatocka@redhat.com>
Cc: Konstantin Khlebnikov <khlebnikov@openvz.org>
Signed-off-by: Minchan Kim <minchan@kernel.org>
---
 fs/super.c               |    2 +-
 include/linux/shrinker.h |    1 -
 2 files changed, 1 insertion(+), 2 deletions(-)

diff --git a/fs/super.c b/fs/super.c
index c2f3a1f..1c2868c 100644
--- a/fs/super.c
+++ b/fs/super.c
@@ -62,7 +62,7 @@ static int prune_super(struct shrinker *shrink, struct shrink_control *sc)
 		return -1;
 
 	if (!grab_super_passive(sb))
-		return !sc->nr_to_scan ? 0 : -1;
+		return -1;
 
 	if (sb->s_op && sb->s_op->nr_cached_objects)
 		fs_objects = sb->s_op->nr_cached_objects(sb);
diff --git a/include/linux/shrinker.h b/include/linux/shrinker.h
index 07ceb97..ac6b8ee 100644
--- a/include/linux/shrinker.h
+++ b/include/linux/shrinker.h
@@ -20,7 +20,6 @@ struct shrink_control {
  * 'nr_to_scan' entries and attempt to free them up.  It should return
  * the number of objects which remain in the cache.  If it returns -1, it means
  * it cannot do any scanning at this time (eg. there is a risk of deadlock).
- * The callback must not return -1 if nr_to_scan is zero.
  *
  * The 'gfpmask' refers to the allocation we are currently trying to
  * fulfil.
-- 
1.7.9.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx197.postini.com [74.125.245.197])
	by kanga.kvack.org (Postfix) with SMTP id C2D146B0034
	for <linux-mm@kvack.org>; Mon, 13 May 2013 10:16:52 -0400 (EDT)
From: Oskar Andero <oskar.andero@sonymobile.com>
Subject: [RFC PATCH 2/2] Clean-up shrinker return values
Date: Mon, 13 May 2013 16:16:35 +0200
Message-ID: <1368454595-5121-3-git-send-email-oskar.andero@sonymobile.com>
In-Reply-To: <1368454595-5121-1-git-send-email-oskar.andero@sonymobile.com>
References: <1368454595-5121-1-git-send-email-oskar.andero@sonymobile.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org, linux-mm@kvack.org
Cc: Hugh Dickins <hughd@google.com>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Radovan Lekanovic <radovan.lekanovic@sonymobile.com>, David Rientjes <rientjes@google.com>, Oskar Andero <oskar.andero@sonymobile.com>

Shrinkers return hardcoded -1 on error. Use errno.h values instead
to add more meaning to the errors.

Cc: Hugh Dickins <hughd@google.com>
Cc: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Signed-off-by: Oskar Andero <oskar.andero@sonymobile.com>
---
 drivers/staging/android/ashmem.c     | 2 +-
 drivers/staging/zcache/zcache-main.c | 2 +-
 fs/gfs2/glock.c                      | 2 +-
 fs/gfs2/quota.c                      | 2 +-
 fs/nfs/dir.c                         | 2 +-
 fs/ubifs/shrinker.c                  | 2 +-
 net/sunrpc/auth.c                    | 2 +-
 7 files changed, 7 insertions(+), 7 deletions(-)

diff --git a/drivers/staging/android/ashmem.c b/drivers/staging/android/ashmem.c
index e681bdd..1968d2f 100644
--- a/drivers/staging/android/ashmem.c
+++ b/drivers/staging/android/ashmem.c
@@ -359,7 +359,7 @@ static int ashmem_shrink(struct shrinker *s, struct shrink_control *sc)
 
 	/* We might recurse into filesystem code, so bail out if necessary */
 	if (sc->nr_to_scan && !(sc->gfp_mask & __GFP_FS))
-		return -1;
+		return -EBUSY;
 	if (!sc->nr_to_scan)
 		return lru_count;
 
diff --git a/drivers/staging/zcache/zcache-main.c b/drivers/staging/zcache/zcache-main.c
index 522cb8e..a38532c 100644
--- a/drivers/staging/zcache/zcache-main.c
+++ b/drivers/staging/zcache/zcache-main.c
@@ -1144,7 +1144,7 @@ static int shrink_zcache_memory(struct shrinker *shrink,
 				struct shrink_control *sc)
 {
 	static bool in_progress;
-	int ret = -1;
+	int ret = -EBUSY;
 	int nr = sc->nr_to_scan;
 	int nr_evict = 0;
 	int nr_writeback = 0;
diff --git a/fs/gfs2/glock.c b/fs/gfs2/glock.c
index 9435384..401b089 100644
--- a/fs/gfs2/glock.c
+++ b/fs/gfs2/glock.c
@@ -1459,7 +1459,7 @@ static int gfs2_shrink_glock_memory(struct shrinker *shrink,
 {
 	if (sc->nr_to_scan) {
 		if (!(sc->gfp_mask & __GFP_FS))
-			return -1;
+			return -EBUSY;
 		gfs2_scan_glock_lru(sc->nr_to_scan);
 	}
 
diff --git a/fs/gfs2/quota.c b/fs/gfs2/quota.c
index c7c840e..14acbb2 100644
--- a/fs/gfs2/quota.c
+++ b/fs/gfs2/quota.c
@@ -85,7 +85,7 @@ int gfs2_shrink_qd_memory(struct shrinker *shrink, struct shrink_control *sc)
 		goto out;
 
 	if (!(sc->gfp_mask & __GFP_FS))
-		return -1;
+		return -EBUSY;
 
 	spin_lock(&qd_lru_lock);
 	while (nr_to_scan && !list_empty(&qd_lru_list)) {
diff --git a/fs/nfs/dir.c b/fs/nfs/dir.c
index e093e73..9fee9bc 100644
--- a/fs/nfs/dir.c
+++ b/fs/nfs/dir.c
@@ -1968,7 +1968,7 @@ int nfs_access_cache_shrinker(struct shrinker *shrink,
 	gfp_t gfp_mask = sc->gfp_mask;
 
 	if ((gfp_mask & GFP_KERNEL) != GFP_KERNEL)
-		return (nr_to_scan == 0) ? 0 : -1;
+		return (nr_to_scan == 0) ? nr_to_scan : -EBUSY;
 
 	spin_lock(&nfs_access_lru_lock);
 	list_for_each_entry_safe(nfsi, next, &nfs_access_lru_list, access_cache_inode_lru) {
diff --git a/fs/ubifs/shrinker.c b/fs/ubifs/shrinker.c
index 9e1d056..294e685 100644
--- a/fs/ubifs/shrinker.c
+++ b/fs/ubifs/shrinker.c
@@ -316,7 +316,7 @@ int ubifs_shrinker(struct shrinker *shrink, struct shrink_control *sc)
 
 	if (!freed && contention) {
 		dbg_tnc("freed nothing, but contention");
-		return -1;
+		return -EBUSY;
 	}
 
 out:
diff --git a/net/sunrpc/auth.c b/net/sunrpc/auth.c
index ed2fdd2..45faea0 100644
--- a/net/sunrpc/auth.c
+++ b/net/sunrpc/auth.c
@@ -461,7 +461,7 @@ rpcauth_cache_shrinker(struct shrinker *shrink, struct shrink_control *sc)
 	gfp_t gfp_mask = sc->gfp_mask;
 
 	if ((gfp_mask & GFP_KERNEL) != GFP_KERNEL)
-		return (nr_to_scan == 0) ? 0 : -1;
+		return (nr_to_scan == 0) ? nr_to_scan : -EBUSY;
 	if (list_empty(&cred_unused))
 		return 0;
 	spin_lock(&rpc_credcache_lock);
-- 
1.8.1.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

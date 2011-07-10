Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id 8196C6B0082
	for <linux-mm@kvack.org>; Sun, 10 Jul 2011 17:26:51 -0400 (EDT)
Received: by pvc12 with SMTP id 12so2819435pvc.14
        for <linux-mm@kvack.org>; Sun, 10 Jul 2011 14:26:48 -0700 (PDT)
From: raghu.prabhu13@gmail.com
Subject: [PATCH] mm/vmscan: Remove sysctl_vfs_cache_pressure from non-vfs shrinkers
Date: Mon, 11 Jul 2011 02:56:24 +0530
Message-Id: <624844650523339d9beaf882f88cd5adf1909943.1310331583.git.rprabhu@wnohang.net>
In-Reply-To: <cover.1310331583.git.rprabhu@wnohang.net>
References: <cover.1310331583.git.rprabhu@wnohang.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org, mgorman@suse.de, kamezawa.hiroyu@jp.fujitsu.com
Cc: keithp@keithp.com, viro@zeniv.linux.org.uk, riel@redhat.com, swhiteho@redhat.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, jack@suse.cz, Raghavendra D Prabhu <rprabhu@wnohang.net>

From: Raghavendra D Prabhu <rprabhu@wnohang.net>

sysctl_vfs_cache_pressure is meant to only affect the dentries and inodes slab
caches. However, it has been used shrinkers elsewhere to trim the number of
slabs returned to shrink_slab. So, this patch removes it from those places.

Signed-off-by: Raghavendra D Prabhu <rprabhu@wnohang.net>
---
 drivers/gpu/drm/i915/i915_gem.c |    2 +-
 fs/gfs2/glock.c                 |    2 +-
 fs/gfs2/quota.c                 |    2 +-
 fs/mbcache.c                    |    2 +-
 fs/nfs/dir.c                    |    2 +-
 fs/quota/dquot.c                |    3 +--
 net/sunrpc/auth.c               |    2 +-
 7 files changed, 7 insertions(+), 8 deletions(-)

diff --git a/drivers/gpu/drm/i915/i915_gem.c b/drivers/gpu/drm/i915/i915_gem.c
index 5c0d124..ca4f6b5 100644
--- a/drivers/gpu/drm/i915/i915_gem.c
+++ b/drivers/gpu/drm/i915/i915_gem.c
@@ -4146,5 +4146,5 @@ rescan:
 			goto rescan;
 	}
 	mutex_unlock(&dev->struct_mutex);
-	return cnt / 100 * sysctl_vfs_cache_pressure;
+	return cnt;
 }
diff --git a/fs/gfs2/glock.c b/fs/gfs2/glock.c
index 1c1336e..68872ed 100644
--- a/fs/gfs2/glock.c
+++ b/fs/gfs2/glock.c
@@ -1400,7 +1400,7 @@ static int gfs2_shrink_glock_memory(struct shrinker *shrink,
 	atomic_add(nr_skipped, &lru_count);
 	spin_unlock(&lru_lock);
 out:
-	return (atomic_read(&lru_count) / 100) * sysctl_vfs_cache_pressure;
+	return atomic_read(&lru_count);
 }
 
 static struct shrinker glock_shrinker = {
diff --git a/fs/gfs2/quota.c b/fs/gfs2/quota.c
index 42e8d23..30ac1fa 100644
--- a/fs/gfs2/quota.c
+++ b/fs/gfs2/quota.c
@@ -117,7 +117,7 @@ int gfs2_shrink_qd_memory(struct shrinker *shrink, struct shrink_control *sc)
 	spin_unlock(&qd_lru_lock);
 
 out:
-	return (atomic_read(&qd_lru_count) * sysctl_vfs_cache_pressure) / 100;
+	return atomic_read(&qd_lru_count);
 }
 
 static u64 qd2offset(struct gfs2_quota_data *qd)
diff --git a/fs/mbcache.c b/fs/mbcache.c
index 8c32ef3..2a51c51 100644
--- a/fs/mbcache.c
+++ b/fs/mbcache.c
@@ -189,7 +189,7 @@ mb_cache_shrink_fn(struct shrinker *shrink, struct shrink_control *sc)
 	list_for_each_entry_safe(entry, tmp, &free_list, e_lru_list) {
 		__mb_cache_entry_forget(entry, gfp_mask);
 	}
-	return (count / 100) * sysctl_vfs_cache_pressure;
+	return count;
 }
 
 
diff --git a/fs/nfs/dir.c b/fs/nfs/dir.c
index ededdbd..700806e 100644
--- a/fs/nfs/dir.c
+++ b/fs/nfs/dir.c
@@ -2077,7 +2077,7 @@ remove_lru_entry:
 	}
 	spin_unlock(&nfs_access_lru_lock);
 	nfs_access_free_list(&head);
-	return (atomic_long_read(&nfs_access_nr_entries) / 100) * sysctl_vfs_cache_pressure;
+	return atomic_long_read(&nfs_access_nr_entries);
 }
 
 static void __nfs_access_zap_cache(struct nfs_inode *nfsi, struct list_head *head)
diff --git a/fs/quota/dquot.c b/fs/quota/dquot.c
index 5b572c8..97dd902 100644
--- a/fs/quota/dquot.c
+++ b/fs/quota/dquot.c
@@ -702,8 +702,7 @@ static int shrink_dqcache_memory(struct shrinker *shrink,
 		spin_unlock(&dq_list_lock);
 	}
 	return ((unsigned)
-		percpu_counter_read_positive(&dqstats.counter[DQST_FREE_DQUOTS])
-		/100) * sysctl_vfs_cache_pressure;
+		percpu_counter_read_positive(&dqstats.counter[DQST_FREE_DQUOTS]));
 }
 
 static struct shrinker dqcache_shrinker = {
diff --git a/net/sunrpc/auth.c b/net/sunrpc/auth.c
index cd6e4aa..8f53697 100644
--- a/net/sunrpc/auth.c
+++ b/net/sunrpc/auth.c
@@ -319,7 +319,7 @@ rpcauth_prune_expired(struct list_head *free, int nr_to_scan)
 		}
 		spin_unlock(cache_lock);
 	}
-	return (number_cred_unused / 100) * sysctl_vfs_cache_pressure;
+	return number_cred_unused;
 }
 
 /*
-- 
1.7.6

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

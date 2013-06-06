Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx178.postini.com [74.125.245.178])
	by kanga.kvack.org (Postfix) with SMTP id 5C7E76B004D
	for <linux-mm@kvack.org>; Thu,  6 Jun 2013 16:34:49 -0400 (EDT)
From: Glauber Costa <glommer@openvz.org>
Subject: [PATCH v11 02/25] super: fix calculation of shrinkable objects for small numbers
Date: Fri,  7 Jun 2013 00:34:35 +0400
Message-Id: <1370550898-26711-3-git-send-email-glommer@openvz.org>
In-Reply-To: <1370550898-26711-1-git-send-email-glommer@openvz.org>
References: <1370550898-26711-1-git-send-email-glommer@openvz.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org
Cc: linux-fsdevel@vger.kernel.org, mgorman@suse.de, david@fromorbit.com, linux-mm@kvack.org, cgroups@vger.kernel.org, kamezawa.hiroyu@jp.fujitsu.com, mhocko@suze.cz, hannes@cmpxchg.org, hughd@google.com, gthelen@google.com, Glauber Costa <glommer@openvz.org>, Theodore Ts'o <tytso@mit.edu>, Al Viro <viro@zeniv.linux.org.uk>

The sysctl knob sysctl_vfs_cache_pressure is used to determine which
percentage of the shrinkable objects in our cache we should actively try
to shrink.

It works great in situations in which we have many objects (at least
more than 100), because the aproximation errors will be negligible. But
if this is not the case, specially when total_objects < 100, we may end
up concluding that we have no objects at all (total / 100 = 0,  if total
< 100).

This is certainly not the biggest killer in the world, but may matter in
very low kernel memory situations.

[ v2: fix it for all occurrences of sysctl_vfs_cache_pressure ]

Signed-off-by: Glauber Costa <glommer@openvz.org>
Reviewed-by: Carlos Maiolino <cmaiolino@redhat.com>
Acked-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Acked-by: Mel Gorman <mgorman@suse.de>
CC: Dave Chinner <david@fromorbit.com>
CC: "Theodore Ts'o" <tytso@mit.edu>
CC: Al Viro <viro@zeniv.linux.org.uk>
---
 fs/gfs2/glock.c        |  2 +-
 fs/gfs2/quota.c        |  2 +-
 fs/mbcache.c           |  2 +-
 fs/nfs/dir.c           |  2 +-
 fs/quota/dquot.c       |  5 ++---
 fs/super.c             | 14 +++++++-------
 fs/xfs/xfs_qm.c        |  2 +-
 include/linux/dcache.h |  4 ++++
 8 files changed, 18 insertions(+), 15 deletions(-)

diff --git a/fs/gfs2/glock.c b/fs/gfs2/glock.c
index 9435384..3bd2748 100644
--- a/fs/gfs2/glock.c
+++ b/fs/gfs2/glock.c
@@ -1463,7 +1463,7 @@ static int gfs2_shrink_glock_memory(struct shrinker *shrink,
 		gfs2_scan_glock_lru(sc->nr_to_scan);
 	}
 
-	return (atomic_read(&lru_count) / 100) * sysctl_vfs_cache_pressure;
+	return vfs_pressure_ratio(atomic_read(&lru_count));
 }
 
 static struct shrinker glock_shrinker = {
diff --git a/fs/gfs2/quota.c b/fs/gfs2/quota.c
index 3768c2f..d550a5d 100644
--- a/fs/gfs2/quota.c
+++ b/fs/gfs2/quota.c
@@ -114,7 +114,7 @@ int gfs2_shrink_qd_memory(struct shrinker *shrink, struct shrink_control *sc)
 	spin_unlock(&qd_lru_lock);
 
 out:
-	return (atomic_read(&qd_lru_count) * sysctl_vfs_cache_pressure) / 100;
+	return vfs_pressure_ratio(atomic_read(&qd_lru_count));
 }
 
 static u64 qd2index(struct gfs2_quota_data *qd)
diff --git a/fs/mbcache.c b/fs/mbcache.c
index 8c32ef3..5eb0476 100644
--- a/fs/mbcache.c
+++ b/fs/mbcache.c
@@ -189,7 +189,7 @@ mb_cache_shrink_fn(struct shrinker *shrink, struct shrink_control *sc)
 	list_for_each_entry_safe(entry, tmp, &free_list, e_lru_list) {
 		__mb_cache_entry_forget(entry, gfp_mask);
 	}
-	return (count / 100) * sysctl_vfs_cache_pressure;
+	return vfs_pressure_ratio(count);
 }
 
 
diff --git a/fs/nfs/dir.c b/fs/nfs/dir.c
index 3cfd208..0d2cdad 100644
--- a/fs/nfs/dir.c
+++ b/fs/nfs/dir.c
@@ -2004,7 +2004,7 @@ remove_lru_entry:
 	}
 	spin_unlock(&nfs_access_lru_lock);
 	nfs_access_free_list(&head);
-	return (atomic_long_read(&nfs_access_nr_entries) / 100) * sysctl_vfs_cache_pressure;
+	return vfs_pressure_ratio(atomic_long_read(&nfs_access_nr_entries));
 }
 
 static void __nfs_access_zap_cache(struct nfs_inode *nfsi, struct list_head *head)
diff --git a/fs/quota/dquot.c b/fs/quota/dquot.c
index 3e64169..762b09c 100644
--- a/fs/quota/dquot.c
+++ b/fs/quota/dquot.c
@@ -719,9 +719,8 @@ static int shrink_dqcache_memory(struct shrinker *shrink,
 		prune_dqcache(nr);
 		spin_unlock(&dq_list_lock);
 	}
-	return ((unsigned)
-		percpu_counter_read_positive(&dqstats.counter[DQST_FREE_DQUOTS])
-		/100) * sysctl_vfs_cache_pressure;
+	return vfs_pressure_ratio(
+	percpu_counter_read_positive(&dqstats.counter[DQST_FREE_DQUOTS]));
 }
 
 static struct shrinker dqcache_shrinker = {
diff --git a/fs/super.c b/fs/super.c
index 7465d43..2a37fd6 100644
--- a/fs/super.c
+++ b/fs/super.c
@@ -82,13 +82,13 @@ static int prune_super(struct shrinker *shrink, struct shrink_control *sc)
 		int	inodes;
 
 		/* proportion the scan between the caches */
-		dentries = (sc->nr_to_scan * sb->s_nr_dentry_unused) /
-							total_objects;
-		inodes = (sc->nr_to_scan * sb->s_nr_inodes_unused) /
-							total_objects;
+		dentries = mult_frac(sc->nr_to_scan, sb->s_nr_dentry_unused,
+							total_objects);
+		inodes = mult_frac(sc->nr_to_scan, sb->s_nr_inodes_unused,
+							total_objects);
 		if (fs_objects)
-			fs_objects = (sc->nr_to_scan * fs_objects) /
-							total_objects;
+			fs_objects = mult_frac(sc->nr_to_scan, fs_objects,
+							total_objects);
 		/*
 		 * prune the dcache first as the icache is pinned by it, then
 		 * prune the icache, followed by the filesystem specific caches
@@ -104,7 +104,7 @@ static int prune_super(struct shrinker *shrink, struct shrink_control *sc)
 				sb->s_nr_inodes_unused + fs_objects;
 	}
 
-	total_objects = (total_objects / 100) * sysctl_vfs_cache_pressure;
+	total_objects = vfs_pressure_ratio(total_objects);
 	drop_super(sb);
 	return total_objects;
 }
diff --git a/fs/xfs/xfs_qm.c b/fs/xfs/xfs_qm.c
index b75c9bb..f10506b 100644
--- a/fs/xfs/xfs_qm.c
+++ b/fs/xfs/xfs_qm.c
@@ -1605,7 +1605,7 @@ xfs_qm_shake(
 	}
 
 out:
-	return (qi->qi_lru_count / 100) * sysctl_vfs_cache_pressure;
+	return vfs_pressure_ratio(qi->qi_lru_count);
 }
 
 /*
diff --git a/include/linux/dcache.h b/include/linux/dcache.h
index 1a82bdb..bd08285 100644
--- a/include/linux/dcache.h
+++ b/include/linux/dcache.h
@@ -411,4 +411,8 @@ static inline bool d_mountpoint(struct dentry *dentry)
 
 extern int sysctl_vfs_cache_pressure;
 
+static inline unsigned long vfs_pressure_ratio(unsigned long val)
+{
+	return mult_frac(val, sysctl_vfs_cache_pressure, 100);
+}
 #endif	/* __LINUX_DCACHE_H */
-- 
1.8.1.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

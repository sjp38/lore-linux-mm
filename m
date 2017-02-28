Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id 7C79F6B03BC
	for <linux-mm@kvack.org>; Tue, 28 Feb 2017 09:47:46 -0500 (EST)
Received: by mail-pf0-f199.google.com with SMTP id j5so16679656pfb.3
        for <linux-mm@kvack.org>; Tue, 28 Feb 2017 06:47:46 -0800 (PST)
Received: from userp1040.oracle.com (userp1040.oracle.com. [156.151.31.81])
        by mx.google.com with ESMTPS id e14si1289625pfd.150.2017.02.28.06.47.45
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 28 Feb 2017 06:47:45 -0800 (PST)
From: Pavel Tatashin <pasha.tatashin@oracle.com>
Subject: [PATCH v1 3/3] mm: Updated callers to use HASH_ZERO flag
Date: Tue, 28 Feb 2017 09:55:46 -0500
Message-Id: <1488293746-965735-4-git-send-email-pasha.tatashin@oracle.com>
In-Reply-To: <1488293746-965735-1-git-send-email-pasha.tatashin@oracle.com>
References: <1488293746-965735-1-git-send-email-pasha.tatashin@oracle.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, sparclinux@vger.kernel.org

Update dcache, inode, pid, mountpoint, and mount hash tables to use
HASH_ZERO, and remove initialization after allocations.
In case of places where HASH_EARLY was used such as in __pv_init_lock_hash
the zeroed hash table was already assumed, because memblock zeroes the
memory.

CPU: SPARC M6, Memory: 7T
Before fix:
Dentry cache hash table entries: 1073741824
Inode-cache hash table entries: 536870912
Mount-cache hash table entries: 16777216
Mountpoint-cache hash table entries: 16777216
ftrace: allocating 20414 entries in 40 pages
Total time: 11.798s

After fix:
Dentry cache hash table entries: 1073741824
Inode-cache hash table entries: 536870912
Mount-cache hash table entries: 16777216
Mountpoint-cache hash table entries: 16777216
ftrace: allocating 20414 entries in 40 pages
Total time: 3.198s

CPU: Intel Xeon E5-2630, Memory: 2.2T:
Before fix:
Dentry cache hash table entries: 536870912
Inode-cache hash table entries: 268435456
Mount-cache hash table entries: 8388608
Mountpoint-cache hash table entries: 8388608
CPU: Physical Processor ID: 0
Total time: 3.245s

After fix:
Dentry cache hash table entries: 536870912
Inode-cache hash table entries: 268435456
Mount-cache hash table entries: 8388608
Mountpoint-cache hash table entries: 8388608
CPU: Physical Processor ID: 0
Total time: 3.244s

Signed-off-by: Pavel Tatashin <pasha.tatashin@oracle.com>
Reviewed-by: Babu Moger <babu.moger@oracle.com>
---
 fs/dcache.c                         |   18 ++++--------------
 fs/inode.c                          |   14 ++------------
 fs/namespace.c                      |   10 ++--------
 kernel/locking/qspinlock_paravirt.h |    3 ++-
 kernel/pid.c                        |    7 ++-----
 5 files changed, 12 insertions(+), 40 deletions(-)

diff --git a/fs/dcache.c b/fs/dcache.c
index 95d71ed..363502f 100644
--- a/fs/dcache.c
+++ b/fs/dcache.c
@@ -3548,8 +3548,6 @@ static int __init set_dhash_entries(char *str)
 
 static void __init dcache_init_early(void)
 {
-	unsigned int loop;
-
 	/* If hashes are distributed across NUMA nodes, defer
 	 * hash allocation until vmalloc space is available.
 	 */
@@ -3561,24 +3559,19 @@ static void __init dcache_init_early(void)
 					sizeof(struct hlist_bl_head),
 					dhash_entries,
 					13,
-					HASH_EARLY,
+					HASH_EARLY | HASH_ZERO,
 					&d_hash_shift,
 					&d_hash_mask,
 					0,
 					0);
-
-	for (loop = 0; loop < (1U << d_hash_shift); loop++)
-		INIT_HLIST_BL_HEAD(dentry_hashtable + loop);
 }
 
 static void __init dcache_init(void)
 {
-	unsigned int loop;
-
-	/* 
+	/*
 	 * A constructor could be added for stable state like the lists,
 	 * but it is probably not worth it because of the cache nature
-	 * of the dcache. 
+	 * of the dcache.
 	 */
 	dentry_cache = KMEM_CACHE(dentry,
 		SLAB_RECLAIM_ACCOUNT|SLAB_PANIC|SLAB_MEM_SPREAD|SLAB_ACCOUNT);
@@ -3592,14 +3585,11 @@ static void __init dcache_init(void)
 					sizeof(struct hlist_bl_head),
 					dhash_entries,
 					13,
-					0,
+					HASH_ZERO,
 					&d_hash_shift,
 					&d_hash_mask,
 					0,
 					0);
-
-	for (loop = 0; loop < (1U << d_hash_shift); loop++)
-		INIT_HLIST_BL_HEAD(dentry_hashtable + loop);
 }
 
 /* SLAB cache for __getname() consumers */
diff --git a/fs/inode.c b/fs/inode.c
index 88110fd..1b15a7c 100644
--- a/fs/inode.c
+++ b/fs/inode.c
@@ -1916,8 +1916,6 @@ static int __init set_ihash_entries(char *str)
  */
 void __init inode_init_early(void)
 {
-	unsigned int loop;
-
 	/* If hashes are distributed across NUMA nodes, defer
 	 * hash allocation until vmalloc space is available.
 	 */
@@ -1929,20 +1927,15 @@ void __init inode_init_early(void)
 					sizeof(struct hlist_head),
 					ihash_entries,
 					14,
-					HASH_EARLY,
+					HASH_EARLY | HASH_ZERO,
 					&i_hash_shift,
 					&i_hash_mask,
 					0,
 					0);
-
-	for (loop = 0; loop < (1U << i_hash_shift); loop++)
-		INIT_HLIST_HEAD(&inode_hashtable[loop]);
 }
 
 void __init inode_init(void)
 {
-	unsigned int loop;
-
 	/* inode slab cache */
 	inode_cachep = kmem_cache_create("inode_cache",
 					 sizeof(struct inode),
@@ -1960,14 +1953,11 @@ void __init inode_init(void)
 					sizeof(struct hlist_head),
 					ihash_entries,
 					14,
-					0,
+					HASH_ZERO,
 					&i_hash_shift,
 					&i_hash_mask,
 					0,
 					0);
-
-	for (loop = 0; loop < (1U << i_hash_shift); loop++)
-		INIT_HLIST_HEAD(&inode_hashtable[loop]);
 }
 
 void init_special_inode(struct inode *inode, umode_t mode, dev_t rdev)
diff --git a/fs/namespace.c b/fs/namespace.c
index 8bfad42..275e6e2 100644
--- a/fs/namespace.c
+++ b/fs/namespace.c
@@ -3238,7 +3238,6 @@ static void __init init_mount_tree(void)
 
 void __init mnt_init(void)
 {
-	unsigned u;
 	int err;
 
 	mnt_cache = kmem_cache_create("mnt_cache", sizeof(struct mount),
@@ -3247,22 +3246,17 @@ void __init mnt_init(void)
 	mount_hashtable = alloc_large_system_hash("Mount-cache",
 				sizeof(struct hlist_head),
 				mhash_entries, 19,
-				0,
+				HASH_ZERO,
 				&m_hash_shift, &m_hash_mask, 0, 0);
 	mountpoint_hashtable = alloc_large_system_hash("Mountpoint-cache",
 				sizeof(struct hlist_head),
 				mphash_entries, 19,
-				0,
+				HASH_ZERO,
 				&mp_hash_shift, &mp_hash_mask, 0, 0);
 
 	if (!mount_hashtable || !mountpoint_hashtable)
 		panic("Failed to allocate mount hash table\n");
 
-	for (u = 0; u <= m_hash_mask; u++)
-		INIT_HLIST_HEAD(&mount_hashtable[u]);
-	for (u = 0; u <= mp_hash_mask; u++)
-		INIT_HLIST_HEAD(&mountpoint_hashtable[u]);
-
 	kernfs_init();
 
 	err = sysfs_init();
diff --git a/kernel/locking/qspinlock_paravirt.h b/kernel/locking/qspinlock_paravirt.h
index e6b2f7a..4ccfcaa 100644
--- a/kernel/locking/qspinlock_paravirt.h
+++ b/kernel/locking/qspinlock_paravirt.h
@@ -193,7 +193,8 @@ void __init __pv_init_lock_hash(void)
 	 */
 	pv_lock_hash = alloc_large_system_hash("PV qspinlock",
 					       sizeof(struct pv_hash_entry),
-					       pv_hash_size, 0, HASH_EARLY,
+					       pv_hash_size, 0,
+					       HASH_EARLY | HASH_ZERO,
 					       &pv_lock_hash_bits, NULL,
 					       pv_hash_size, pv_hash_size);
 }
diff --git a/kernel/pid.c b/kernel/pid.c
index 0291804..013e023 100644
--- a/kernel/pid.c
+++ b/kernel/pid.c
@@ -572,16 +572,13 @@ struct pid *find_ge_pid(int nr, struct pid_namespace *ns)
  */
 void __init pidhash_init(void)
 {
-	unsigned int i, pidhash_size;
+	unsigned int pidhash_size;
 
 	pid_hash = alloc_large_system_hash("PID", sizeof(*pid_hash), 0, 18,
-					   HASH_EARLY | HASH_SMALL,
+					   HASH_EARLY | HASH_SMALL | HASH_ZERO,
 					   &pidhash_shift, NULL,
 					   0, 4096);
 	pidhash_size = 1U << pidhash_shift;
-
-	for (i = 0; i < pidhash_size; i++)
-		INIT_HLIST_HEAD(&pid_hash[i]);
 }
 
 void __init pidmap_init(void)
-- 
1.7.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

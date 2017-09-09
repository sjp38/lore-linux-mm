Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f70.google.com (mail-pg0-f70.google.com [74.125.83.70])
	by kanga.kvack.org (Postfix) with ESMTP id B05F86B037F
	for <linux-mm@kvack.org>; Sat,  9 Sep 2017 08:46:29 -0400 (EDT)
Received: by mail-pg0-f70.google.com with SMTP id t3so8950038pgt.7
        for <linux-mm@kvack.org>; Sat, 09 Sep 2017 05:46:29 -0700 (PDT)
Received: from BJEXCAS001.didichuxing.com ([36.110.17.22])
        by mx.google.com with ESMTPS id q127si3015910pga.603.2017.09.09.05.46.27
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Sat, 09 Sep 2017 05:46:27 -0700 (PDT)
Date: Sat, 9 Sep 2017 20:46:20 +0800
From: weiping zhang <zhangweiping@didichuxing.com>
Subject: [PATCH] shmem: convert shmem_init_inodecache to void
Message-ID: <20170909124542.GA35224@bogon.didichuxing.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: hughd@google.com
Cc: linux-mm@kvack.org

shmem_inode_cachep was created with SLAB_PANIC flag and shmem_init_inodecache
never return non-zero, hence convert this function to void.

Signed-off-by: weiping zhang <zhangweiping@didichuxing.com>
---
 mm/shmem.c | 8 ++------
 1 file changed, 2 insertions(+), 6 deletions(-)

diff --git a/mm/shmem.c b/mm/shmem.c
index ace53a582b..d744296 100644
--- a/mm/shmem.c
+++ b/mm/shmem.c
@@ -3862,12 +3862,11 @@ static void shmem_init_inode(void *foo)
 	inode_init_once(&info->vfs_inode);
 }
 
-static int shmem_init_inodecache(void)
+static void shmem_init_inodecache(void)
 {
 	shmem_inode_cachep = kmem_cache_create("shmem_inode_cache",
 				sizeof(struct shmem_inode_info),
 				0, SLAB_PANIC|SLAB_ACCOUNT, shmem_init_inode);
-	return 0;
 }
 
 static void shmem_destroy_inodecache(void)
@@ -3991,9 +3990,7 @@ int __init shmem_init(void)
 	if (shmem_inode_cachep)
 		return 0;
 
-	error = shmem_init_inodecache();
-	if (error)
-		goto out3;
+	shmem_init_inodecache();
 
 	error = register_filesystem(&shmem_fs_type);
 	if (error) {
@@ -4020,7 +4017,6 @@ int __init shmem_init(void)
 	unregister_filesystem(&shmem_fs_type);
 out2:
 	shmem_destroy_inodecache();
-out3:
 	shm_mnt = ERR_PTR(error);
 	return error;
 }
-- 
2.9.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f70.google.com (mail-pg0-f70.google.com [74.125.83.70])
	by kanga.kvack.org (Postfix) with ESMTP id 3573D6B0033
	for <linux-mm@kvack.org>; Thu,  5 Oct 2017 18:22:03 -0400 (EDT)
Received: by mail-pg0-f70.google.com with SMTP id p5so38719036pgn.7
        for <linux-mm@kvack.org>; Thu, 05 Oct 2017 15:22:03 -0700 (PDT)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id n89sor19079pfh.19.2017.10.05.15.22.01
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 05 Oct 2017 15:22:01 -0700 (PDT)
From: Shakeel Butt <shakeelb@google.com>
Subject: [PATCH] fs, mm: account filp and names caches to kmemcg
Date: Thu,  5 Oct 2017 15:21:44 -0700
Message-Id: <20171005222144.123797-1-shakeelb@google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Alexander Viro <viro@zeniv.linux.org.uk>, Vladimir Davydov <vdavydov.dev@gmail.com>, Michal Hocko <mhocko@kernel.org>, Greg Thelen <gthelen@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org, Shakeel Butt <shakeelb@google.com>

The allocations from filp and names kmem caches can be directly
triggered by user space applications. A buggy application can
consume a significant amount of unaccounted system memory. Though
we have not noticed such buggy applications in our production
but upon close inspection, we found that a lot of machines spend
very significant amount of memory on these caches. So, these
caches should be accounted to kmemcg.

Signed-off-by: Shakeel Butt <shakeelb@google.com>
---
 fs/dcache.c     | 2 +-
 fs/file_table.c | 2 +-
 2 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/fs/dcache.c b/fs/dcache.c
index f90141387f01..fb3449161063 100644
--- a/fs/dcache.c
+++ b/fs/dcache.c
@@ -3642,7 +3642,7 @@ void __init vfs_caches_init_early(void)
 void __init vfs_caches_init(void)
 {
 	names_cachep = kmem_cache_create("names_cache", PATH_MAX, 0,
-			SLAB_HWCACHE_ALIGN|SLAB_PANIC, NULL);
+			SLAB_HWCACHE_ALIGN|SLAB_PANIC|SLAB_ACCOUNT, NULL);
 
 	dcache_init();
 	inode_init();
diff --git a/fs/file_table.c b/fs/file_table.c
index 61517f57f8ef..567888cdf7d3 100644
--- a/fs/file_table.c
+++ b/fs/file_table.c
@@ -312,7 +312,7 @@ void put_filp(struct file *file)
 void __init files_init(void)
 {
 	filp_cachep = kmem_cache_create("filp", sizeof(struct file), 0,
-			SLAB_HWCACHE_ALIGN | SLAB_PANIC, NULL);
+			SLAB_HWCACHE_ALIGN | SLAB_PANIC | SLAB_ACCOUNT, NULL);
 	percpu_counter_init(&nr_files, 0, GFP_KERNEL);
 }
 
-- 
2.14.2.920.gcf0c67979c-goog

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

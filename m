Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id 2C1EF6B0260
	for <linux-mm@kvack.org>; Wed, 11 Oct 2017 15:04:32 -0400 (EDT)
Received: by mail-pf0-f200.google.com with SMTP id z80so5773065pff.1
        for <linux-mm@kvack.org>; Wed, 11 Oct 2017 12:04:32 -0700 (PDT)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id a35sor2489898pli.137.2017.10.11.12.04.30
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 11 Oct 2017 12:04:31 -0700 (PDT)
From: Shakeel Butt <shakeelb@google.com>
Subject: [PATCH v2] fs, mm: account filp cache to kmemcg
Date: Wed, 11 Oct 2017 12:03:59 -0700
Message-Id: <20171011190359.34926-1-shakeelb@google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Alexander Viro <viro@zeniv.linux.org.uk>, Vladimir Davydov <vdavydov.dev@gmail.com>, Michal Hocko <mhocko@kernel.org>, Greg Thelen <gthelen@google.com>, Johannes Weiner <hannes@cmpxchg.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org, Shakeel Butt <shakeelb@google.com>

The allocations from filp cache can be directly triggered by user
space applications. A buggy application can consume a significant
amount of unaccounted system memory. Though we have not noticed
such buggy applications in our production but upon close inspection,
we found that a lot of machines spend very significant amount of
memory on these caches.

One way to limit allocations from filp cache is to set system level
limit of maximum number of open files. However this limit is shared
between different users on the system and one user can hog this
resource. To cater that, we can charge filp to kmemcg and set the
maximum limit very high and let the memory limit of each user limit
the number of files they can open and indirectly limiting their
allocations from filp cache.

One side effect of this change is that it will allow _sysctl() to
return ENOMEM and the man page of _sysctl() does not specify that.
However the man page also discourages to use _sysctl() at all.

Signed-off-by: Shakeel Butt <shakeelb@google.com>
---

Changelog since v1:
- removed names_cache charging to kmemcg

 fs/file_table.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

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
2.15.0.rc0.271.g36b669edcc-goog

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

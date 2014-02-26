Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-la0-f48.google.com (mail-la0-f48.google.com [209.85.215.48])
	by kanga.kvack.org (Postfix) with ESMTP id 732FE6B00AF
	for <linux-mm@kvack.org>; Wed, 26 Feb 2014 10:05:42 -0500 (EST)
Received: by mail-la0-f48.google.com with SMTP id gf5so708545lab.35
        for <linux-mm@kvack.org>; Wed, 26 Feb 2014 07:05:41 -0800 (PST)
Received: from relay.parallels.com (relay.parallels.com. [195.214.232.42])
        by mx.google.com with ESMTPS id pm4si1808209lbb.122.2014.02.26.07.05.39
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 26 Feb 2014 07:05:40 -0800 (PST)
From: Vladimir Davydov <vdavydov@parallels.com>
Subject: [PATCH -mm 09/12] fork: do not charge thread_info to kmemcg
Date: Wed, 26 Feb 2014 19:05:14 +0400
Message-ID: <14c6879ed1a974c3fe87d4b4d660bc0ac32f0a1f.1393423762.git.vdavydov@parallels.com>
In-Reply-To: <cover.1393423762.git.vdavydov@parallels.com>
References: <cover.1393423762.git.vdavydov@parallels.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org
Cc: hannes@cmpxchg.org, mhocko@suse.cz, glommer@gmail.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, devel@openvz.org, Frederic Weisbecker <fweisbec@redhat.com>

This patch reverts 2ad306b17c0a ("fork: protect architectures where
THREAD_SIZE >= PAGE_SIZE against fork bombs").

The reasoning behind this is that charging thread_info is the last piece
that prevents us from reparenting kmemcg on css offline. The point is
that we can't reliably track all thread_info pages accounted to a
particular cgroup, because (a) it is freed in __put_task_struct and (b)
on exit tasks are moved to the root cgroup. That said, given a cgroup
there is no sane way to find all tasks (including zombies) that charged
thread_info to this cgroup. Of course, we could uncharge thread_info on
task exit, but that wouldn't help us against fork bombs. So revert and
forget about this.

Signed-off-by: Vladimir Davydov <vdavydov@parallels.com>
Cc: Johannes Weiner <hannes@cmpxchg.org>
Cc: Michal Hocko <mhocko@suse.cz>
Cc: Glauber Costa <glommer@gmail.com>
Cc: Frederic Weisbecker <fweisbec@redhat.com>
---
 include/linux/thread_info.h |    2 --
 kernel/fork.c               |    4 ++--
 2 files changed, 2 insertions(+), 4 deletions(-)

diff --git a/include/linux/thread_info.h b/include/linux/thread_info.h
index fddbe2023a5d..1807bb194816 100644
--- a/include/linux/thread_info.h
+++ b/include/linux/thread_info.h
@@ -61,8 +61,6 @@ extern long do_no_restart_syscall(struct restart_block *parm);
 # define THREADINFO_GFP		(GFP_KERNEL | __GFP_NOTRACK)
 #endif
 
-#define THREADINFO_GFP_ACCOUNTED (THREADINFO_GFP | __GFP_KMEMCG)
-
 /*
  * flag set/clear/test wrappers
  * - pass TIF_xxxx constants to these functions
diff --git a/kernel/fork.c b/kernel/fork.c
index b41022f5d307..2431645d4c91 100644
--- a/kernel/fork.c
+++ b/kernel/fork.c
@@ -148,7 +148,7 @@ void __weak arch_release_thread_info(struct thread_info *ti)
 static struct thread_info *alloc_thread_info_node(struct task_struct *tsk,
 						  int node)
 {
-	struct page *page = alloc_pages_node(node, THREADINFO_GFP_ACCOUNTED,
+	struct page *page = alloc_pages_node(node, THREADINFO_GFP,
 					     THREAD_SIZE_ORDER);
 
 	return page ? page_address(page) : NULL;
@@ -156,7 +156,7 @@ static struct thread_info *alloc_thread_info_node(struct task_struct *tsk,
 
 static inline void free_thread_info(struct thread_info *ti)
 {
-	free_memcg_kmem_pages((unsigned long)ti, THREAD_SIZE_ORDER);
+	free_pages((unsigned long)ti, THREAD_SIZE_ORDER);
 }
 # else
 static struct kmem_cache *thread_info_cache;
-- 
1.7.10.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

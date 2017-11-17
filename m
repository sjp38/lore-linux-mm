Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id 12A786B0038
	for <linux-mm@kvack.org>; Thu, 16 Nov 2017 22:10:13 -0500 (EST)
Received: by mail-pf0-f198.google.com with SMTP id 26so1089643pfs.22
        for <linux-mm@kvack.org>; Thu, 16 Nov 2017 19:10:13 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id e13sor765629pgt.399.2017.11.16.19.10.11
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 16 Nov 2017 19:10:11 -0800 (PST)
From: Yafang Shao <laoar.shao@gmail.com>
Subject: [PATCH] mm/shmem: set default tmpfs size according to memcg limit
Date: Fri, 17 Nov 2017 03:09:59 +0000
Message-Id: <1510888199-5886-1-git-send-email-laoar.shao@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org, hannes@cmpxchg.org, vdavydov.dev@gmail.com, mhocko@suse.com, tj@kernel.org, guro@fb.com, khlebnikov@yandex-team.ru, mka@chromium.org, hughd@google.com
Cc: cgroups@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Yafang Shao <laoar.shao@gmail.com>

Currently the default tmpfs size is totalram_pages / 2 if mount tmpfs
without "-o size=XXX".
When we mount tmpfs in a container(i.e. docker), it is also
totalram_pages / 2 regardless of the memory limit on this container.
That may easily cause OOM if tmpfs occupied too much memory when swap is
off.
So when we mount tmpfs in a memcg, the default size should be limited by
the memcg memory.limit.

Signed-off-by: Yafang Shao <laoar.shao@gmail.com>
---
 include/linux/memcontrol.h |  1 +
 mm/memcontrol.c            |  2 +-
 mm/shmem.c                 | 20 +++++++++++++++++++-
 3 files changed, 21 insertions(+), 2 deletions(-)

diff --git a/include/linux/memcontrol.h b/include/linux/memcontrol.h
index 69966c4..79c6709 100644
--- a/include/linux/memcontrol.h
+++ b/include/linux/memcontrol.h
@@ -265,6 +265,7 @@ struct mem_cgroup {
 	/* WARNING: nodeinfo must be the last member here */
 };
 
+extern struct mutex memcg_limit_mutex;
 extern struct mem_cgroup *root_mem_cgroup;
 
 static inline bool mem_cgroup_disabled(void)
diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index 661f046..ad32f3c 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -2464,7 +2464,7 @@ static inline int mem_cgroup_move_swap_account(swp_entry_t entry,
 }
 #endif
 
-static DEFINE_MUTEX(memcg_limit_mutex);
+DEFINE_MUTEX(memcg_limit_mutex);
 
 static int mem_cgroup_resize_limit(struct mem_cgroup *memcg,
 				   unsigned long limit)
diff --git a/mm/shmem.c b/mm/shmem.c
index 07a1d22..1c320dd 100644
--- a/mm/shmem.c
+++ b/mm/shmem.c
@@ -35,6 +35,7 @@
 #include <linux/uio.h>
 #include <linux/khugepaged.h>
 #include <linux/hugetlb.h>
+#include <linux/memcontrol.h>
 
 #include <asm/tlbflush.h> /* for arch/microblaze update_mmu_cache() */
 
@@ -108,7 +109,24 @@ struct shmem_falloc {
 #ifdef CONFIG_TMPFS
 static unsigned long shmem_default_max_blocks(void)
 {
-	return totalram_pages / 2;
+	unsigned long size;
+
+#ifdef CONFIG_MEMCG
+	struct mem_cgroup *memcg = mem_cgroup_from_task(current);
+
+	if (memcg == NULL || memcg == root_mem_cgroup)
+		size = totalram_pages / 2;
+	else {
+		mutex_lock(&memcg_limit_mutex);
+		size = memcg->memory.limit > totalram_pages ?
+				 totalram_pages / 2 : memcg->memory.limit / 2;
+		mutex_unlock(&memcg_limit_mutex);
+	}
+#else
+	size = totalram_pages / 2;
+#endif
+
+	return size;
 }
 
 static unsigned long shmem_default_max_inodes(void)
-- 
1.8.3.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

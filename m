Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx165.postini.com [74.125.245.165])
	by kanga.kvack.org (Postfix) with SMTP id 0C38D6B035C
	for <linux-mm@kvack.org>; Mon, 25 Jun 2012 10:20:02 -0400 (EDT)
From: Glauber Costa <glommer@parallels.com>
Subject: [PATCH 11/11] protect architectures where THREAD_SIZE >= PAGE_SIZE against fork bombs
Date: Mon, 25 Jun 2012 18:15:28 +0400
Message-Id: <1340633728-12785-12-git-send-email-glommer@parallels.com>
In-Reply-To: <1340633728-12785-1-git-send-email-glommer@parallels.com>
References: <1340633728-12785-1-git-send-email-glommer@parallels.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: cgroups@vger.kernel.org
Cc: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, Frederic Weisbecker <fweisbec@gmail.com>, David Rientjes <rientjes@google.com>, Pekka Enberg <penberg@kernel.org>, Michal Hocko <mhocko@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>, Christoph Lameter <cl@linux.com>, devel@openvz.org, kamezawa.hiroyu@jp.fujitsu.com, Tejun Heo <tj@kernel.org>, Glauber Costa <glommer@parallels.com>, Pekka Enberg <penberg@cs.helsinki.fi>, Suleiman Souhlal <suleiman@google.com>, Frederic Weisbecker <fweisbec@redhat.com>

Because those architectures will draw their stacks directly from
the page allocator, rather than the slab cache, we can directly
pass __GFP_KMEMCG flag, and issue the corresponding free_pages.

This code path is taken when the architecture doesn't define
CONFIG_ARCH_THREAD_INFO_ALLOCATOR (only ia64 seems to), and has
THREAD_SIZE >= PAGE_SIZE. Luckily, most - if not all - of the
remaining architectures fall in this category.

This will guarantee that every stack page is accounted to the memcg
the process currently lives on, and will have the allocations to fail
if they go over limit.

For the time being, I am defining a new variant of THREADINFO_GFP, not
to mess with the other path. Once the slab is also tracked by memcg,
we can get rid of that flag.

Tested to successfully protect against :(){ :|:& };:

Signed-off-by: Glauber Costa <glommer@parallels.com>
CC: Christoph Lameter <cl@linux.com>
CC: Pekka Enberg <penberg@cs.helsinki.fi>
CC: Michal Hocko <mhocko@suse.cz>
CC: Kamezawa Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
CC: Johannes Weiner <hannes@cmpxchg.org>
CC: Suleiman Souhlal <suleiman@google.com>
CC: Frederic Weisbecker <fweisbec@redhat.com>
---
 include/linux/thread_info.h |    6 ++++++
 kernel/fork.c               |    4 ++--
 2 files changed, 8 insertions(+), 2 deletions(-)

diff --git a/include/linux/thread_info.h b/include/linux/thread_info.h
index ccc1899..914ec07 100644
--- a/include/linux/thread_info.h
+++ b/include/linux/thread_info.h
@@ -61,6 +61,12 @@ extern long do_no_restart_syscall(struct restart_block *parm);
 # define THREADINFO_GFP		(GFP_KERNEL | __GFP_NOTRACK)
 #endif
 
+#ifdef CONFIG_CGROUP_MEM_RES_CTLR_KMEM
+# define THREADINFO_GFP_ACCOUNTED (THREADINFO_GFP | __GFP_KMEMCG)
+#else
+# define THREADINFO_GFP_ACCOUNTED (THREADINFO_GFP)
+#endif
+
 /*
  * flag set/clear/test wrappers
  * - pass TIF_xxxx constants to these functions
diff --git a/kernel/fork.c b/kernel/fork.c
index ab5211b..06b414f 100644
--- a/kernel/fork.c
+++ b/kernel/fork.c
@@ -142,7 +142,7 @@ void __weak arch_release_thread_info(struct thread_info *ti) { }
 static struct thread_info *alloc_thread_info_node(struct task_struct *tsk,
 						  int node)
 {
-	struct page *page = alloc_pages_node(node, THREADINFO_GFP,
+	struct page *page = alloc_pages_node(node, THREADINFO_GFP_ACCOUNTED,
 					     THREAD_SIZE_ORDER);
 
 	return page ? page_address(page) : NULL;
@@ -151,7 +151,7 @@ static struct thread_info *alloc_thread_info_node(struct task_struct *tsk,
 static inline void free_thread_info(struct thread_info *ti)
 {
 	arch_release_thread_info(ti);
-	free_pages((unsigned long)ti, THREAD_SIZE_ORDER);
+	free_accounted_pages((unsigned long)ti, THREAD_SIZE_ORDER);
 }
 # else
 static struct kmem_cache *thread_info_cache;
-- 
1.7.10.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

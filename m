Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id 095AE6B000C
	for <linux-mm@kvack.org>; Mon, 25 Jun 2018 19:07:16 -0400 (EDT)
Received: by mail-pf0-f197.google.com with SMTP id n19-v6so7696794pff.8
        for <linux-mm@kvack.org>; Mon, 25 Jun 2018 16:07:15 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id p1-v6sor35664plq.135.2018.06.25.16.07.14
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 25 Jun 2018 16:07:14 -0700 (PDT)
From: Shakeel Butt <shakeelb@google.com>
Subject: [PATCH 2/2] fs, mm: account buffer_head to kmemcg
Date: Mon, 25 Jun 2018 16:06:59 -0700
Message-Id: <20180625230659.139822-3-shakeelb@google.com>
In-Reply-To: <20180625230659.139822-1-shakeelb@google.com>
References: <20180625230659.139822-1-shakeelb@google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Michal Hocko <mhocko@kernel.org>, Johannes Weiner <hannes@cmpxchg.org>, Vladimir Davydov <vdavydov.dev@gmail.com>, Jan Kara <jack@suse.com>, Greg Thelen <gthelen@google.com>, Amir Goldstein <amir73il@gmail.com>, Roman Gushchin <guro@fb.com>, Alexander Viro <viro@zeniv.linux.org.uk>, linux-kernel@vger.kernel.org, cgroups@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, Shakeel Butt <shakeelb@google.com>

The buffer_head can consume a significant amount of system memory and
is directly related to the amount of page cache. In our production
environment we have observed that a lot of machines are spending a
significant amount of memory as buffer_head and can not be left as
system memory overhead.

Charging buffer_head is not as simple as adding __GFP_ACCOUNT to the
allocation. The buffer_heads can be allocated in a memcg different from
the memcg of the page for which buffer_heads are being allocated. One
concrete example is memory reclaim. The reclaim can trigger I/O of pages
of any memcg on the system. So, the right way to charge buffer_head is
to extract the memcg from the page for which buffer_heads are being
allocated and then use targeted memcg charging API.

Signed-off-by: Shakeel Butt <shakeelb@google.com>
---
Changelog since v1:
- simple code cleanups

 fs/buffer.c                | 15 ++++++++++++++-
 include/linux/memcontrol.h |  7 +++++++
 mm/memcontrol.c            | 22 ++++++++++++++++++++++
 3 files changed, 43 insertions(+), 1 deletion(-)

diff --git a/fs/buffer.c b/fs/buffer.c
index 8194e3049fc5..47682cc935fb 100644
--- a/fs/buffer.c
+++ b/fs/buffer.c
@@ -45,6 +45,7 @@
 #include <linux/mpage.h>
 #include <linux/bit_spinlock.h>
 #include <linux/pagevec.h>
+#include <linux/sched/mm.h>
 #include <trace/events/block.h>
 
 static int fsync_buffers_list(spinlock_t *lock, struct list_head *list);
@@ -815,10 +816,17 @@ struct buffer_head *alloc_page_buffers(struct page *page, unsigned long size,
 	struct buffer_head *bh, *head;
 	gfp_t gfp = GFP_NOFS;
 	long offset;
+	struct mem_cgroup *old_memcg = NULL, *memcg;
 
 	if (retry)
 		gfp |= __GFP_NOFAIL;
 
+	memcg = get_mem_cgroup_from_page(page);
+	if (memcg) {
+		gfp |= __GFP_ACCOUNT;
+		old_memcg = memalloc_use_memcg(memcg);
+	}
+
 	head = NULL;
 	offset = PAGE_SIZE;
 	while ((offset -= size) >= 0) {
@@ -835,6 +843,11 @@ struct buffer_head *alloc_page_buffers(struct page *page, unsigned long size,
 		/* Link the buffer to its page */
 		set_bh_page(bh, page, offset);
 	}
+out:
+	if (memcg) {
+		memalloc_unuse_memcg(old_memcg);
+		mem_cgroup_put(memcg);
+	}
 	return head;
 /*
  * In case anything failed, we just free everything we got.
@@ -848,7 +861,7 @@ struct buffer_head *alloc_page_buffers(struct page *page, unsigned long size,
 		} while (head);
 	}
 
-	return NULL;
+	goto out;
 }
 EXPORT_SYMBOL_GPL(alloc_page_buffers);
 
diff --git a/include/linux/memcontrol.h b/include/linux/memcontrol.h
index 6c857be8a9b7..d53609978eb7 100644
--- a/include/linux/memcontrol.h
+++ b/include/linux/memcontrol.h
@@ -380,6 +380,8 @@ struct mem_cgroup *mem_cgroup_from_task(struct task_struct *p);
 
 struct mem_cgroup *get_mem_cgroup_from_mm(struct mm_struct *mm);
 
+struct mem_cgroup *get_mem_cgroup_from_page(struct page *page);
+
 static inline
 struct mem_cgroup *mem_cgroup_from_css(struct cgroup_subsys_state *css){
 	return css ? container_of(css, struct mem_cgroup, css) : NULL;
@@ -864,6 +866,11 @@ static inline struct mem_cgroup *get_mem_cgroup_from_mm(struct mm_struct *mm)
 	return NULL;
 }
 
+static inline struct mem_cgroup *get_mem_cgroup_from_page(struct page *page)
+{
+	return NULL;
+}
+
 static inline void mem_cgroup_put(struct mem_cgroup *memcg)
 {
 }
diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index 6b1a8f8e0a82..13d30b37935f 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -713,6 +713,28 @@ struct mem_cgroup *get_mem_cgroup_from_mm(struct mm_struct *mm)
 }
 EXPORT_SYMBOL(get_mem_cgroup_from_mm);
 
+/**
+ * get_mem_cgroup_from_page: Obtain a reference on given page's memcg.
+ * @page: page from which memcg should be extracted.
+ *
+ * Obtain a reference on page->memcg and returns it if successful. Otherwise
+ * NULL is returned.
+ */
+struct mem_cgroup *get_mem_cgroup_from_page(struct page *page)
+{
+	struct mem_cgroup *memcg = page->mem_cgroup;
+
+	if (mem_cgroup_disabled() || !memcg)
+		return NULL;
+
+	rcu_read_lock();
+	if (!css_tryget_online(&memcg->css))
+		memcg = NULL;
+	rcu_read_unlock();
+	return memcg;
+}
+EXPORT_SYMBOL(get_mem_cgroup_from_page);
+
 /**
  * First try to obtain reference on current->active_memcg. On failure, try to
  * obtain reference on current->mm->memcg. On further failure root_mem_cgroup
-- 
2.18.0.rc2.346.g013aa6912e-goog

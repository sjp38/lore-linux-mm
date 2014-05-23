Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ob0-f176.google.com (mail-ob0-f176.google.com [209.85.214.176])
	by kanga.kvack.org (Postfix) with ESMTP id F2F1B6B003C
	for <linux-mm@kvack.org>; Thu, 22 May 2014 23:33:46 -0400 (EDT)
Received: by mail-ob0-f176.google.com with SMTP id wo20so4794547obc.35
        for <linux-mm@kvack.org>; Thu, 22 May 2014 20:33:46 -0700 (PDT)
Received: from g4t3427.houston.hp.com (g4t3427.houston.hp.com. [15.201.208.55])
        by mx.google.com with ESMTPS id g9si2156147obt.95.2014.05.22.20.33.46
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Thu, 22 May 2014 20:33:46 -0700 (PDT)
From: Davidlohr Bueso <davidlohr@hp.com>
Subject: [PATCH 4/5] mm/rmap: share the i_mmap_rwsem
Date: Thu, 22 May 2014 20:33:25 -0700
Message-Id: <1400816006-3083-5-git-send-email-davidlohr@hp.com>
In-Reply-To: <1400816006-3083-1-git-send-email-davidlohr@hp.com>
References: <1400816006-3083-1-git-send-email-davidlohr@hp.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org
Cc: mingo@kernel.org, peterz@infradead.org, riel@redhat.com, mgorman@suse.de, davidlohr@hp.com, aswin@hp.com, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org

Similarly to rmap_walk_anon() and collect_procs_anon(),
there is opportunity to share the lock in rmap_walk_file()
and collect_procs_file() for file backed pages.

Signed-off-by: Davidlohr Bueso <davidlohr@hp.com>
---
 include/linux/fs.h  | 10 ++++++++++
 mm/memory-failure.c |  4 ++--
 mm/rmap.c           |  4 ++--
 3 files changed, 14 insertions(+), 4 deletions(-)

diff --git a/include/linux/fs.h b/include/linux/fs.h
index 60a1d7d..4c2c228 100644
--- a/include/linux/fs.h
+++ b/include/linux/fs.h
@@ -467,6 +467,16 @@ static inline void i_mmap_unlock_write(struct address_space *mapping)
 	up_write(&mapping->i_mmap_rwsem);
 }
 
+static inline void i_mmap_lock_read(struct address_space *mapping)
+{
+	down_read(&mapping->i_mmap_rwsem);
+}
+
+static inline void i_mmap_unlock_read(struct address_space *mapping)
+{
+	up_read(&mapping->i_mmap_rwsem);
+}
+
 /*
  * Might pages of this file be mapped into userspace?
  */
diff --git a/mm/memory-failure.c b/mm/memory-failure.c
index 1389a28..acbcd8e 100644
--- a/mm/memory-failure.c
+++ b/mm/memory-failure.c
@@ -434,7 +434,7 @@ static void collect_procs_file(struct page *page, struct list_head *to_kill,
 	struct task_struct *tsk;
 	struct address_space *mapping = page->mapping;
 
-	i_mmap_lock_write(mapping);
+	i_mmap_lock_read(mapping);
 	read_lock(&tasklist_lock);
 	for_each_process(tsk) {
 		pgoff_t pgoff = page_pgoff(page);
@@ -456,7 +456,7 @@ static void collect_procs_file(struct page *page, struct list_head *to_kill,
 		}
 	}
 	read_unlock(&tasklist_lock);
-	i_mmap_unlock_write(mapping);
+	i_mmap_unlock_read(mapping);
 }
 
 /*
diff --git a/mm/rmap.c b/mm/rmap.c
index 9a56e4f..5841dcb 100644
--- a/mm/rmap.c
+++ b/mm/rmap.c
@@ -1685,7 +1685,7 @@ static int rmap_walk_file(struct page *page, struct rmap_walk_control *rwc)
 
 	if (!mapping)
 		return ret;
-	i_mmap_lock_write(mapping);
+	i_mmap_lock_read(mapping);
 	vma_interval_tree_foreach(vma, &mapping->i_mmap, pgoff, pgoff) {
 		unsigned long address = vma_address(page, vma);
 
@@ -1708,7 +1708,7 @@ static int rmap_walk_file(struct page *page, struct rmap_walk_control *rwc)
 	ret = rwc->file_nonlinear(page, mapping, rwc->arg);
 
 done:
-	i_mmap_unlock_write(mapping);
+	i_mmap_unlock_read(mapping);
 	return ret;
 }
 
-- 
1.8.1.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

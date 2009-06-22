Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id 6786D6B004D
	for <linux-mm@kvack.org>; Mon, 22 Jun 2009 17:07:23 -0400 (EDT)
Received: by fxm24 with SMTP id 24so4621421fxm.38
        for <linux-mm@kvack.org>; Mon, 22 Jun 2009 14:07:34 -0700 (PDT)
Date: Tue, 23 Jun 2009 01:07:39 +0400
From: Alexey Dobriyan <adobriyan@gmail.com>
Subject: [PATCH] ifdef AIO stuff in mm_struct
Message-ID: <20090622210739.GA2331@x200.localdomain>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
To: akpm@linux-foundation.org
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

->ioctx_lock and ->ioctx_list are used only under CONFIG_AIO.

Signed-off-by: Alexey Dobriyan <adobriyan@gmail.com>
---
 include/linux/mm_types.h |    5 ++---
 kernel/fork.c            |   11 +++++++++--
 2 files changed, 11 insertions(+), 5 deletions(-)

diff --git a/include/linux/mm_types.h b/include/linux/mm_types.h
index 7acc843..f69ced6 100644
--- a/include/linux/mm_types.h
+++ b/include/linux/mm_types.h
@@ -261,11 +261,10 @@ struct mm_struct {
 	unsigned long flags; /* Must use atomic bitops to access the bits */
 
 	struct core_state *core_state; /* coredumping support */
-
-	/* aio bits */
+#ifdef CONFIG_AIO
 	spinlock_t		ioctx_lock;
 	struct hlist_head	ioctx_list;
-
+#endif
 #ifdef CONFIG_MM_OWNER
 	/*
 	 * "owner" points to a task that is regarded as the canonical
diff --git a/kernel/fork.c b/kernel/fork.c
index 467746b..8d3e47f 100644
--- a/kernel/fork.c
+++ b/kernel/fork.c
@@ -420,6 +420,14 @@ __setup("coredump_filter=", coredump_filter_setup);
 
 #include <linux/init_task.h>
 
+static void mm_init_aio(struct mm_struct *mm)
+{
+#ifdef CONFIG_AIO
+	spin_lock_init(&mm->ioctx_lock);
+	INIT_HLIST_HEAD(&mm->ioctx_list);
+#endif
+}
+
 static struct mm_struct * mm_init(struct mm_struct * mm, struct task_struct *p)
 {
 	atomic_set(&mm->mm_users, 1);
@@ -432,10 +440,9 @@ static struct mm_struct * mm_init(struct mm_struct * mm, struct task_struct *p)
 	set_mm_counter(mm, file_rss, 0);
 	set_mm_counter(mm, anon_rss, 0);
 	spin_lock_init(&mm->page_table_lock);
-	spin_lock_init(&mm->ioctx_lock);
-	INIT_HLIST_HEAD(&mm->ioctx_list);
 	mm->free_area_cache = TASK_UNMAPPED_BASE;
 	mm->cached_hole_size = ~0UL;
+	mm_init_aio(mm);
 	mm_init_owner(mm, p);
 
 	if (likely(!mm_alloc_pgd(mm))) {

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

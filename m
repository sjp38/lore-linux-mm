Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ob0-f170.google.com (mail-ob0-f170.google.com [209.85.214.170])
	by kanga.kvack.org (Postfix) with ESMTP id 7ED516B0098
	for <linux-mm@kvack.org>; Sat, 14 Mar 2015 18:39:50 -0400 (EDT)
Received: by obcxo2 with SMTP id xo2so12532750obc.0
        for <linux-mm@kvack.org>; Sat, 14 Mar 2015 15:39:50 -0700 (PDT)
Received: from smtp2.provo.novell.com (smtp2.provo.novell.com. [137.65.250.81])
        by mx.google.com with ESMTPS id ps6si3070078obb.84.2015.03.14.15.39.49
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Sat, 14 Mar 2015 15:39:49 -0700 (PDT)
From: Davidlohr Bueso <dave@stgolabs.net>
Subject: [PATCH 2/4] mm: introduce struct exe_file
Date: Sat, 14 Mar 2015 15:39:24 -0700
Message-Id: <1426372766-3029-3-git-send-email-dave@stgolabs.net>
In-Reply-To: <1426372766-3029-1-git-send-email-dave@stgolabs.net>
References: <1426372766-3029-1-git-send-email-dave@stgolabs.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org
Cc: viro@zeniv.linux.org.uk, gorcunov@openvz.org, oleg@redhat.com, koct9i@gmail.com, dave@stgolabs.net, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Davidlohr Bueso <dbueso@suse.de>

This patch isolates exe_file handling into its own data
structure, tiding up the mm_struct bits (which must remain
there as we provide prctl thread interfaces to change it).
Note that none of the interfaces have changed, users will
continue dealing with the actual backing struct file, but
internally we isolate things, serialization remaining the same.

Signed-off-by: Davidlohr Bueso <dbueso@suse.de>
Cc: Alexander Viro <viro@zeniv.linux.org.uk>
Cc: Cyrill Gorcunov <gorcunov@openvz.org>
Cc: Oleg Nesterov <oleg@redhat.com>
CC: Konstantin Khlebnikov <koct9i@gmail.com>
---
 include/linux/mm_types.h |  8 ++++++--
 kernel/fork.c            | 27 ++++++++++++++-------------
 2 files changed, 20 insertions(+), 15 deletions(-)

diff --git a/include/linux/mm_types.h b/include/linux/mm_types.h
index 5951baf..1fc994e 100644
--- a/include/linux/mm_types.h
+++ b/include/linux/mm_types.h
@@ -326,6 +326,11 @@ struct core_state {
 	struct completion startup;
 };
 
+struct exe_file {
+	rwlock_t lock;
+	struct file *file;
+};
+
 enum {
 	MM_FILEPAGES,
 	MM_ANONPAGES,
@@ -429,8 +434,7 @@ struct mm_struct {
 #endif
 
 	/* store ref to file /proc/<pid>/exe symlink points to */
-	rwlock_t exe_file_lock;
-	struct file *exe_file;
+	struct exe_file exe_file;
 #ifdef CONFIG_MMU_NOTIFIER
 	struct mmu_notifier_mm *mmu_notifier_mm;
 #endif
diff --git a/kernel/fork.c b/kernel/fork.c
index a573b18..aa0332b 100644
--- a/kernel/fork.c
+++ b/kernel/fork.c
@@ -566,7 +566,7 @@ static struct mm_struct *mm_init(struct mm_struct *mm, struct task_struct *p)
 	mm_init_owner(mm, p);
 	mmu_notifier_mm_init(mm);
 	clear_tlb_flush_pending(mm);
-	rwlock_init(&mm->exe_file_lock);
+	rwlock_init(&mm->exe_file.lock);
 #if defined(CONFIG_TRANSPARENT_HUGEPAGE) && !USE_SPLIT_PMD_PTLOCKS
 	mm->pmd_huge_pte = NULL;
 #endif
@@ -679,45 +679,46 @@ void set_mm_exe_file_locked(struct mm_struct *mm, struct file *new_exe_file)
 {
 	if (new_exe_file)
 		get_file(new_exe_file);
-	if (mm->exe_file)
-		fput(mm->exe_file);
+	if (mm->exe_file.file)
+		fput(mm->exe_file.file);
 
-	write_lock(&mm->exe_file_lock);
-	mm->exe_file = new_exe_file;
-	write_unlock(&mm->exe_file_lock);
+	write_lock(&mm->exe_file.lock);
+	mm->exe_file.file = new_exe_file;
+	write_unlock(&mm->exe_file.lock);
 }
 
 void set_mm_exe_file(struct mm_struct *mm, struct file *new_exe_file)
 {
 	if (new_exe_file)
 		get_file(new_exe_file);
-	if (mm->exe_file)
-		fput(mm->exe_file);
+	if (mm->exe_file.file)
+		fput(mm->exe_file.file);
 
-	mm->exe_file = new_exe_file;
+	mm->exe_file.file = new_exe_file;
 }
 
 struct file *get_mm_exe_file(struct mm_struct *mm)
 {
 	struct file *exe_file;
 
-	read_lock(&mm->exe_file_lock);
-	exe_file = mm->exe_file;
+	read_lock(&mm->exe_file.lock);
+	exe_file = mm->exe_file.file;
 	if (exe_file)
 		get_file(exe_file);
-	read_unlock(&mm->exe_file_lock);
+	read_unlock(&mm->exe_file.lock);
 
 	return exe_file;
 }
 EXPORT_SYMBOL(get_mm_exe_file);
 
+
 static void dup_mm_exe_file(struct mm_struct *oldmm, struct mm_struct *newmm)
 {
 	/*
 	 * It's safe to write the exe_file without the
 	 * exe_file_lock as we are just setting up the new task.
 	 */
-	newmm->exe_file = get_mm_exe_file(oldmm);
+	newmm->exe_file.file = get_mm_exe_file(oldmm);
 }
 
 /**
-- 
2.1.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id 7A1296B0343
	for <linux-mm@kvack.org>; Mon, 19 Jun 2017 19:36:55 -0400 (EDT)
Received: by mail-pf0-f200.google.com with SMTP id e26so115191812pfk.12
        for <linux-mm@kvack.org>; Mon, 19 Jun 2017 16:36:55 -0700 (PDT)
Received: from mail-pg0-x235.google.com (mail-pg0-x235.google.com. [2607:f8b0:400e:c05::235])
        by mx.google.com with ESMTPS id t69si9043702pfe.252.2017.06.19.16.36.54
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 19 Jun 2017 16:36:54 -0700 (PDT)
Received: by mail-pg0-x235.google.com with SMTP id f185so54757237pgc.0
        for <linux-mm@kvack.org>; Mon, 19 Jun 2017 16:36:54 -0700 (PDT)
From: Kees Cook <keescook@chromium.org>
Subject: [PATCH 14/23] fork: define usercopy region in thread_stack, task_struct, mm_struct slab caches
Date: Mon, 19 Jun 2017 16:36:28 -0700
Message-Id: <1497915397-93805-15-git-send-email-keescook@chromium.org>
In-Reply-To: <1497915397-93805-1-git-send-email-keescook@chromium.org>
References: <1497915397-93805-1-git-send-email-keescook@chromium.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: kernel-hardening@lists.openwall.com
Cc: Kees Cook <keescook@chromium.org>, David Windsor <dave@nullcore.net>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

From: David Windsor <dave@nullcore.net>

In support of usercopy hardening, this patch defines a region in
the thread_stack, task_struct and mm_struct slab caches in which
userspace copy operations are allowed. Since only a single whitelisted
buffer region is used, this moves the usercopyable fields next to each
other in task_struct so a single window can cover them.

This region is known as the slab cache's usercopy region.  Slab
caches can now check that each copy operation involving cache-managed
memory falls entirely within the slab's usercopy region.

This patch is modified from Brad Spengler/PaX Team's PAX_USERCOPY
whitelisting code in the last public patch of grsecurity/PaX based on my
understanding of the code. Changes or omissions from the original code are
mine and don't reflect the original grsecurity/PaX code.

Signed-off-by: David Windsor <dave@nullcore.net>
[kees: adjust commit log]
Signed-off-by: Kees Cook <keescook@chromium.org>
---
 include/linux/sched.h | 15 ++++++++++++---
 kernel/fork.c         | 18 +++++++++++++-----
 2 files changed, 25 insertions(+), 8 deletions(-)

diff --git a/include/linux/sched.h b/include/linux/sched.h
index 2b69fc650201..345db7983af1 100644
--- a/include/linux/sched.h
+++ b/include/linux/sched.h
@@ -745,10 +745,19 @@ struct task_struct {
 	/* Signal handlers: */
 	struct signal_struct		*signal;
 	struct sighand_struct		*sighand;
-	sigset_t			blocked;
 	sigset_t			real_blocked;
-	/* Restored if set_restore_sigmask() was used: */
-	sigset_t			saved_sigmask;
+
+	/*
+	 * Usercopy slab whitelisting needs blocked, saved_sigmask
+	 * to be adjacent.
+	 */
+	struct {
+		sigset_t blocked;
+
+		/* Restored if set_restore_sigmask() was used */
+		sigset_t saved_sigmask;
+	};
+
 	struct sigpending		pending;
 	unsigned long			sas_ss_sp;
 	size_t				sas_ss_size;
diff --git a/kernel/fork.c b/kernel/fork.c
index e53770d2bf95..172df19baeb5 100644
--- a/kernel/fork.c
+++ b/kernel/fork.c
@@ -282,8 +282,9 @@ static void free_thread_stack(struct task_struct *tsk)
 
 void thread_stack_cache_init(void)
 {
-	thread_stack_cache = kmem_cache_create("thread_stack", THREAD_SIZE,
-					      THREAD_SIZE, 0, NULL);
+	thread_stack_cache = kmem_cache_create_usercopy("thread_stack",
+					THREAD_SIZE, THREAD_SIZE, 0, 0,
+					THREAD_SIZE, NULL);
 	BUG_ON(thread_stack_cache == NULL);
 }
 # endif
@@ -467,9 +468,14 @@ void __init fork_init(void)
 	int align = max_t(int, L1_CACHE_BYTES, ARCH_MIN_TASKALIGN);
 
 	/* create a slab on which task_structs can be allocated */
-	task_struct_cachep = kmem_cache_create("task_struct",
+	task_struct_cachep = kmem_cache_create_usercopy("task_struct",
 			arch_task_struct_size, align,
-			SLAB_PANIC|SLAB_NOTRACK|SLAB_ACCOUNT, NULL);
+			SLAB_PANIC|SLAB_NOTRACK|SLAB_ACCOUNT,
+			offsetof(struct task_struct, blocked),
+			offsetof(struct task_struct, saved_sigmask) -
+				offsetof(struct task_struct, blocked) +
+				sizeof(init_task.saved_sigmask),
+			NULL);
 #endif
 
 	/* do the arch specific task caches init */
@@ -2208,9 +2214,11 @@ void __init proc_caches_init(void)
 	 * maximum number of CPU's we can ever have.  The cpumask_allocation
 	 * is at the end of the structure, exactly for that reason.
 	 */
-	mm_cachep = kmem_cache_create("mm_struct",
+	mm_cachep = kmem_cache_create_usercopy("mm_struct",
 			sizeof(struct mm_struct), ARCH_MIN_MMSTRUCT_ALIGN,
 			SLAB_HWCACHE_ALIGN|SLAB_PANIC|SLAB_NOTRACK|SLAB_ACCOUNT,
+			offsetof(struct mm_struct, saved_auxv),
+			sizeof_field(struct mm_struct, saved_auxv),
 			NULL);
 	vm_area_cachep = KMEM_CACHE(vm_area_struct, SLAB_PANIC|SLAB_ACCOUNT);
 	mmap_init();
-- 
2.7.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

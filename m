Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f70.google.com (mail-pg0-f70.google.com [74.125.83.70])
	by kanga.kvack.org (Postfix) with ESMTP id B3CD76B04A1
	for <linux-mm@kvack.org>; Mon, 28 Aug 2017 17:43:56 -0400 (EDT)
Received: by mail-pg0-f70.google.com with SMTP id t193so2611872pgc.4
        for <linux-mm@kvack.org>; Mon, 28 Aug 2017 14:43:56 -0700 (PDT)
Received: from mail-pf0-x22e.google.com (mail-pf0-x22e.google.com. [2607:f8b0:400e:c00::22e])
        by mx.google.com with ESMTPS id e19si1002173pgk.193.2017.08.28.14.43.55
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 28 Aug 2017 14:43:55 -0700 (PDT)
Received: by mail-pf0-x22e.google.com with SMTP id r62so4771098pfj.0
        for <linux-mm@kvack.org>; Mon, 28 Aug 2017 14:43:55 -0700 (PDT)
From: Kees Cook <keescook@chromium.org>
Subject: [PATCH v2 26/30] fork: Provide usercopy whitelisting for task_struct
Date: Mon, 28 Aug 2017 14:35:07 -0700
Message-Id: <1503956111-36652-27-git-send-email-keescook@chromium.org>
In-Reply-To: <1503956111-36652-1-git-send-email-keescook@chromium.org>
References: <1503956111-36652-1-git-send-email-keescook@chromium.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: Kees Cook <keescook@chromium.org>, Andrew Morton <akpm@linux-foundation.org>, Nicholas Piggin <npiggin@gmail.com>, Laura Abbott <labbott@redhat.com>, =?UTF-8?q?Micka=C3=ABl=20Sala=C3=BCn?= <mic@digikod.net>, Ingo Molnar <mingo@kernel.org>, Thomas Gleixner <tglx@linutronix.de>, Andy Lutomirski <luto@kernel.org>, linux-mm@kvack.org, kernel-hardening@lists.openwall.com, David Windsor <dave@nullcore.net>

While the blocked and saved_sigmask fields of task_struct are copied to
userspace (via sigmask_to_save() and setup_rt_frame()), it is always
copied with a static length (i.e. sizeof(sigset_t)).

The only portion of task_struct that is potentially dynamically sized and
may be copied to userspace is in the architecture-specific thread_struct
at the end of task_struct.

cache object allocation:
    kernel/fork.c:
        alloc_task_struct_node(...):
            return kmem_cache_alloc_node(task_struct_cachep, ...);

        dup_task_struct(...):
            ...
            tsk = alloc_task_struct_node(node);

        copy_process(...):
            ...
            dup_task_struct(...)

        _do_fork(...):
            ...
            copy_process(...)

example usage trace:

    arch/x86/kernel/fpu/signal.c:
        __fpu__restore_sig(...):
            ...
            struct task_struct *tsk = current;
            struct fpu *fpu = &tsk->thread.fpu;
            ...
            __copy_from_user(&fpu->state.xsave, ..., state_size);

        fpu__restore_sig(...):
            ...
            return __fpu__restore_sig(...);

    arch/x86/kernel/signal.c:
        restore_sigcontext(...):
            ...
            fpu__restore_sig(...)

This introduces arch_thread_struct_whitelist() to let an architecture
declare specifically where the whitelist should be within thread_struct.
If undefined, the entire thread_struct field is left whitelisted.

Cc: Andrew Morton <akpm@linux-foundation.org>
Cc: Nicholas Piggin <npiggin@gmail.com>
Cc: Laura Abbott <labbott@redhat.com>
Cc: "MickaA<<l SalaA 1/4 n" <mic@digikod.net>
Cc: Ingo Molnar <mingo@kernel.org>
Cc: Thomas Gleixner <tglx@linutronix.de>
Cc: Andy Lutomirski <luto@kernel.org>
Signed-off-by: Kees Cook <keescook@chromium.org>
---
 arch/Kconfig               | 11 +++++++++++
 include/linux/sched/task.h | 14 ++++++++++++++
 kernel/fork.c              | 22 ++++++++++++++++++++--
 3 files changed, 45 insertions(+), 2 deletions(-)

diff --git a/arch/Kconfig b/arch/Kconfig
index 21d0089117fe..380d2bc2001b 100644
--- a/arch/Kconfig
+++ b/arch/Kconfig
@@ -241,6 +241,17 @@ config ARCH_INIT_TASK
 config ARCH_TASK_STRUCT_ALLOCATOR
 	bool
 
+config HAVE_ARCH_THREAD_STRUCT_WHITELIST
+	bool
+	depends on !ARCH_TASK_STRUCT_ALLOCATOR
+	help
+	  An architecture should select this to provide hardened usercopy
+	  knowledge about what region of the thread_struct should be
+	  whitelisted for copying to userspace. Normally this is only the
+	  FPU registers. Specifically, arch_thread_struct_whitelist()
+	  should be implemented. Without this, the entire thread_struct
+	  field in task_struct will be left whitelisted.
+
 # Select if arch has its private alloc_thread_stack() function
 config ARCH_THREAD_STACK_ALLOCATOR
 	bool
diff --git a/include/linux/sched/task.h b/include/linux/sched/task.h
index c97e5f096927..60f36adaa504 100644
--- a/include/linux/sched/task.h
+++ b/include/linux/sched/task.h
@@ -104,6 +104,20 @@ extern int arch_task_struct_size __read_mostly;
 # define arch_task_struct_size (sizeof(struct task_struct))
 #endif
 
+#ifndef CONFIG_HAVE_ARCH_THREAD_STRUCT_WHITELIST
+/*
+ * If an architecture has not declared a thread_struct whitelist we
+ * must assume something there may need to be copied to userspace.
+ */
+static inline void arch_thread_struct_whitelist(unsigned long *offset,
+						unsigned long *size)
+{
+	*offset = 0;
+	/* Handle dynamically sized thread_struct. */
+	*size = arch_task_struct_size - offsetof(struct task_struct, thread);
+}
+#endif
+
 #ifdef CONFIG_VMAP_STACK
 static inline struct vm_struct *task_stack_vm_area(const struct task_struct *t)
 {
diff --git a/kernel/fork.c b/kernel/fork.c
index 0f33fb1aabbf..4fcc9cc8e108 100644
--- a/kernel/fork.c
+++ b/kernel/fork.c
@@ -452,6 +452,21 @@ static void set_max_threads(unsigned int max_threads_suggested)
 int arch_task_struct_size __read_mostly;
 #endif
 
+static void task_struct_whitelist(unsigned long *offset, unsigned long *size)
+{
+	/* Fetch thread_struct whitelist for the architecture. */
+	arch_thread_struct_whitelist(offset, size);
+
+	/*
+	 * Handle zero-sized whitelist or empty thread_struct, otherwise
+	 * adjust offset to position of thread_struct in task_struct.
+	 */
+	if (unlikely(*size == 0))
+		*offset = 0;
+	else
+		*offset += offsetof(struct task_struct, thread);
+}
+
 void __init fork_init(void)
 {
 	int i;
@@ -460,11 +475,14 @@ void __init fork_init(void)
 #define ARCH_MIN_TASKALIGN	0
 #endif
 	int align = max_t(int, L1_CACHE_BYTES, ARCH_MIN_TASKALIGN);
+	unsigned long useroffset, usersize;
 
 	/* create a slab on which task_structs can be allocated */
-	task_struct_cachep = kmem_cache_create("task_struct",
+	task_struct_whitelist(&useroffset, &usersize);
+	task_struct_cachep = kmem_cache_create_usercopy("task_struct",
 			arch_task_struct_size, align,
-			SLAB_PANIC|SLAB_NOTRACK|SLAB_ACCOUNT, NULL);
+			SLAB_PANIC|SLAB_NOTRACK|SLAB_ACCOUNT,
+			useroffset, usersize, NULL);
 #endif
 
 	/* do the arch specific task caches init */
-- 
2.7.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

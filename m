Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f69.google.com (mail-pg0-f69.google.com [74.125.83.69])
	by kanga.kvack.org (Postfix) with ESMTP id 8F8026B0276
	for <linux-mm@kvack.org>; Tue,  9 Jan 2018 15:57:11 -0500 (EST)
Received: by mail-pg0-f69.google.com with SMTP id n12so2598017pgp.11
        for <linux-mm@kvack.org>; Tue, 09 Jan 2018 12:57:11 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id h193sor3914553pfe.34.2018.01.09.12.57.10
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 09 Jan 2018 12:57:10 -0800 (PST)
From: Kees Cook <keescook@chromium.org>
Subject: [PATCH 28/36] fork: Provide usercopy whitelisting for task_struct
Date: Tue,  9 Jan 2018 12:55:57 -0800
Message-Id: <1515531365-37423-29-git-send-email-keescook@chromium.org>
In-Reply-To: <1515531365-37423-1-git-send-email-keescook@chromium.org>
References: <1515531365-37423-1-git-send-email-keescook@chromium.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: Kees Cook <keescook@chromium.org>, Andrew Morton <akpm@linux-foundation.org>, Nicholas Piggin <npiggin@gmail.com>, Laura Abbott <labbott@redhat.com>, =?UTF-8?q?Micka=C3=ABl=20Sala=C3=BCn?= <mic@digikod.net>, Ingo Molnar <mingo@kernel.org>, Thomas Gleixner <tglx@linutronix.de>, Andy Lutomirski <luto@kernel.org>, Linus Torvalds <torvalds@linux-foundation.org>, David Windsor <dave@nullcore.net>, Alexander Viro <viro@zeniv.linux.org.uk>, Christoph Hellwig <hch@infradead.org>, Christoph Lameter <cl@linux.com>, "David S. Miller" <davem@davemloft.net>, Mark Rutland <mark.rutland@arm.com>, "Martin K. Petersen" <martin.petersen@oracle.com>, Paolo Bonzini <pbonzini@redhat.com>, Christian Borntraeger <borntraeger@de.ibm.com>, Christoffer Dall <christoffer.dall@linaro.org>, Dave Kleikamp <dave.kleikamp@oracle.com>, Jan Kara <jack@suse.cz>, Luis de Bethencourt <luisbg@kernel.org>, Marc Zyngier <marc.zyngier@arm.com>, Rik van Riel <riel@redhat.com>, Matthew Garrett <mjg59@google.com>, linux-fsdevel@vger.kernel.org, linux-arch@vger.kernel.org, netdev@vger.kernel.org, linux-mm@kvack.org, kernel-hardening@lists.openwall.com

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
Acked-by: Rik van Riel <riel@redhat.com>
---
 arch/Kconfig               | 11 +++++++++++
 include/linux/sched/task.h | 14 ++++++++++++++
 kernel/fork.c              | 22 ++++++++++++++++++++--
 3 files changed, 45 insertions(+), 2 deletions(-)

diff --git a/arch/Kconfig b/arch/Kconfig
index 400b9e1b2f27..8911ff37335a 100644
--- a/arch/Kconfig
+++ b/arch/Kconfig
@@ -242,6 +242,17 @@ config ARCH_INIT_TASK
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
index 05b8650f06f5..5be31eb7b266 100644
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
index 0e086af148f2..5977e691c754 100644
--- a/kernel/fork.c
+++ b/kernel/fork.c
@@ -458,6 +458,21 @@ static void set_max_threads(unsigned int max_threads_suggested)
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
@@ -466,11 +481,14 @@ void __init fork_init(void)
 #define ARCH_MIN_TASKALIGN	0
 #endif
 	int align = max_t(int, L1_CACHE_BYTES, ARCH_MIN_TASKALIGN);
+	unsigned long useroffset, usersize;
 
 	/* create a slab on which task_structs can be allocated */
-	task_struct_cachep = kmem_cache_create("task_struct",
+	task_struct_whitelist(&useroffset, &usersize);
+	task_struct_cachep = kmem_cache_create_usercopy("task_struct",
 			arch_task_struct_size, align,
-			SLAB_PANIC|SLAB_ACCOUNT, NULL);
+			SLAB_PANIC|SLAB_ACCOUNT,
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

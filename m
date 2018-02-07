Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id 53A096B032D
	for <linux-mm@kvack.org>; Wed,  7 Feb 2018 11:14:54 -0500 (EST)
Received: by mail-pf0-f199.google.com with SMTP id e1so618675pfi.10
        for <linux-mm@kvack.org>; Wed, 07 Feb 2018 08:14:54 -0800 (PST)
Received: from EUR01-VE1-obe.outbound.protection.outlook.com (mail-ve1eur01on0132.outbound.protection.outlook.com. [104.47.1.132])
        by mx.google.com with ESMTPS id t66si1103488pgc.653.2018.02.07.08.14.52
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Wed, 07 Feb 2018 08:14:53 -0800 (PST)
Subject: [PATCH RFC] x86: KASAN: Sanitize unauthorized irq stack access
From: Kirill Tkhai <ktkhai@virtuozzo.com>
Date: Wed, 07 Feb 2018 19:14:43 +0300
Message-ID: <151802005995.4570.824586713429099710.stgit@localhost.localdomain>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: tglx@linutronix.de, mingo@redhat.com, hpa@zytor.com, aryabinin@virtuozzo.com, glider@google.com, dvyukov@google.com, luto@kernel.org, bp@alien8.de, jpoimboe@redhat.com, dave.hansen@linux.intel.com, jgross@suse.com, kirill.shutemov@linux.intel.com, keescook@chromium.org, minipli@googlemail.com, gregkh@linuxfoundation.org, kstewart@linuxfoundation.org, linux-kernel@vger.kernel.org, kasan-dev@googlegroups.com, linux-mm@kvack.org

Sometimes it is possible to meet a situation,
when irq stack is corrupted, while innocent
callback function is being executed. This may
happen because of crappy drivers irq handlers,
when they access wrong memory on the irq stack.

This patch aims to catch such the situations
and adds checks of unauthorized stack access.

Every time we enter in interrupt, we check for
irq_count, and allow irq stack usage. After
last nested irq handler is exited, we prohibit
the access back.

I did x86_unpoison_irq_stack() and x86_poison_irq_stack()
calls unconditional, because this requires
to change the order of incl PER_CPU_VAR(irq_count)
and UNWIND_HINT_REGS(), and I'm not sure it's
legitimately to do. So, irq_count is checked in
x86_unpoison_irq_stack().

Signed-off-by: Kirill Tkhai <ktkhai@virtuozzo.com>
---
 arch/x86/entry/entry_64.S        |    6 ++++++
 arch/x86/include/asm/processor.h |    6 ++++++
 arch/x86/kernel/irq_64.c         |   13 +++++++++++++
 include/linux/kasan.h            |    3 +++
 mm/kasan/kasan.c                 |   16 ++++++++++++++++
 5 files changed, 44 insertions(+)

diff --git a/arch/x86/entry/entry_64.S b/arch/x86/entry/entry_64.S
index 741d9877b357..1e9d69de2528 100644
--- a/arch/x86/entry/entry_64.S
+++ b/arch/x86/entry/entry_64.S
@@ -485,6 +485,9 @@ END(irq_entries_start)
  * The invariant is that, if irq_count != -1, then the IRQ stack is in use.
  */
 .macro ENTER_IRQ_STACK regs=1 old_rsp
+#ifdef CONFIG_KASAN
+	call	x86_unpoison_irq_stack
+#endif
 	DEBUG_ENTRY_ASSERT_IRQS_OFF
 	movq	%rsp, \old_rsp
 
@@ -552,6 +555,9 @@ END(irq_entries_start)
 	 */
 
 	decl	PER_CPU_VAR(irq_count)
+#ifdef CONFIG_KASAN
+	call	x86_poison_irq_stack
+#endif
 .endm
 
 /*
diff --git a/arch/x86/include/asm/processor.h b/arch/x86/include/asm/processor.h
index 793bae7e7ce3..4353e3a85b0b 100644
--- a/arch/x86/include/asm/processor.h
+++ b/arch/x86/include/asm/processor.h
@@ -404,6 +404,12 @@ union irq_stack_union {
 	};
 };
 
+#define KASAN_IRQ_STACK_SIZE \
+	(sizeof(union irq_stack_union) - \
+		(offsetof(union irq_stack_union, stack_canary) + 8))
+
+#define percpu_irq_stack_addr() this_cpu_ptr(irq_stack_union.irq_stack)
+
 DECLARE_PER_CPU_FIRST(union irq_stack_union, irq_stack_union) __visible;
 DECLARE_INIT_PER_CPU(irq_stack_union);
 
diff --git a/arch/x86/kernel/irq_64.c b/arch/x86/kernel/irq_64.c
index d86e344f5b3d..ad78f4b3f0b5 100644
--- a/arch/x86/kernel/irq_64.c
+++ b/arch/x86/kernel/irq_64.c
@@ -77,3 +77,16 @@ bool handle_irq(struct irq_desc *desc, struct pt_regs *regs)
 	generic_handle_irq_desc(desc);
 	return true;
 }
+
+#ifdef CONFIG_KASAN
+void __visible x86_poison_irq_stack(void)
+{
+	if (this_cpu_read(irq_count) == -1)
+		kasan_poison_irq_stack();
+}
+void __visible x86_unpoison_irq_stack(void)
+{
+	if (this_cpu_read(irq_count) == -1)
+		kasan_unpoison_irq_stack();
+}
+#endif
diff --git a/include/linux/kasan.h b/include/linux/kasan.h
index adc13474a53b..cb433f1bf178 100644
--- a/include/linux/kasan.h
+++ b/include/linux/kasan.h
@@ -40,6 +40,9 @@ void kasan_unpoison_shadow(const void *address, size_t size);
 void kasan_unpoison_task_stack(struct task_struct *task);
 void kasan_unpoison_stack_above_sp_to(const void *watermark);
 
+void kasan_poison_irq_stack(void);
+void kasan_unpoison_irq_stack(void);
+
 void kasan_alloc_pages(struct page *page, unsigned int order);
 void kasan_free_pages(struct page *page, unsigned int order);
 
diff --git a/mm/kasan/kasan.c b/mm/kasan/kasan.c
index 0d9d9d268f32..9bc150c87205 100644
--- a/mm/kasan/kasan.c
+++ b/mm/kasan/kasan.c
@@ -412,6 +412,22 @@ void kasan_poison_object_data(struct kmem_cache *cache, void *object)
 			KASAN_KMALLOC_REDZONE);
 }
 
+#ifdef KASAN_IRQ_STACK_SIZE
+void kasan_poison_irq_stack(void)
+{
+	void *stack = percpu_irq_stack_addr();
+
+	kasan_poison_shadow(stack, KASAN_IRQ_STACK_SIZE, KASAN_GLOBAL_REDZONE);
+}
+
+void kasan_unpoison_irq_stack(void)
+{
+	void *stack = percpu_irq_stack_addr();
+
+	kasan_unpoison_shadow(stack, KASAN_IRQ_STACK_SIZE);
+}
+#endif /* KASAN_IRQ_STACK_SIZE */
+
 static inline int in_irqentry_text(unsigned long ptr)
 {
 	return (ptr >= (unsigned long)&__irqentry_text_start &&

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

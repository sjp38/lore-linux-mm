Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f43.google.com (mail-pa0-f43.google.com [209.85.220.43])
	by kanga.kvack.org (Postfix) with ESMTP id 1F2DC6B0080
	for <linux-mm@kvack.org>; Wed, 21 Jan 2015 11:52:46 -0500 (EST)
Received: by mail-pa0-f43.google.com with SMTP id eu11so16652773pac.2
        for <linux-mm@kvack.org>; Wed, 21 Jan 2015 08:52:45 -0800 (PST)
Received: from mailout4.w1.samsung.com (mailout4.w1.samsung.com. [210.118.77.14])
        by mx.google.com with ESMTPS id oi7si8808283pbb.169.2015.01.21.08.52.28
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-MD5 bits=128/128);
        Wed, 21 Jan 2015 08:52:29 -0800 (PST)
Received: from eucpsbgm1.samsung.com (unknown [203.254.199.244])
 by mailout4.w1.samsung.com
 (Oracle Communications Messaging Server 7u4-24.01(7.0.4.24.0) 64bit (built Nov
 17 2011)) with ESMTP id <0NIJ00ILDDQ151A0@mailout4.w1.samsung.com> for
 linux-mm@kvack.org; Wed, 21 Jan 2015 16:56:25 +0000 (GMT)
From: Andrey Ryabinin <a.ryabinin@samsung.com>
Subject: [PATCH v9 12/17] kasan: enable stack instrumentation
Date: Wed, 21 Jan 2015 19:51:40 +0300
Message-id: <1421859105-25253-13-git-send-email-a.ryabinin@samsung.com>
In-reply-to: <1421859105-25253-1-git-send-email-a.ryabinin@samsung.com>
References: <1404905415-9046-1-git-send-email-a.ryabinin@samsung.com>
 <1421859105-25253-1-git-send-email-a.ryabinin@samsung.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: Andrey Ryabinin <a.ryabinin@samsung.com>, Dmitry Vyukov <dvyukov@google.com>, Konstantin Serebryany <kcc@google.com>, Dmitry Chernenkov <dmitryc@google.com>, Andrey Konovalov <adech.fo@gmail.com>, Yuri Gribov <tetra2005@gmail.com>, Konstantin Khlebnikov <koct9i@gmail.com>, Sasha Levin <sasha.levin@oracle.com>, Christoph Lameter <cl@linux.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Andrew Morton <akpm@linux-foundation.org>, Dave Hansen <dave.hansen@intel.com>, Andi Kleen <andi@firstfloor.org>, x86@kernel.org, linux-mm@kvack.org, Michal Marek <mmarek@suse.cz>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, "H. Peter Anvin" <hpa@zytor.com>, "open list:KERNEL BUILD + fi..." <linux-kbuild@vger.kernel.org>

Stack instrumentation allows to detect out of bounds
memory accesses for variables allocated on stack.
Compiler adds redzones around every variable on stack
and poisons redzones in function's prologue.

Such approach significantly increases stack usage,
so all in-kernel stacks size were doubled.

Signed-off-by: Andrey Ryabinin <a.ryabinin@samsung.com>
---
 Makefile                             |  1 +
 arch/x86/include/asm/page_64_types.h | 12 +++++++++---
 arch/x86/kernel/Makefile             |  2 ++
 arch/x86/mm/kasan_init_64.c          |  8 ++++++++
 include/linux/init_task.h            |  8 ++++++++
 include/linux/kasan.h                |  9 +++++++++
 mm/kasan/report.c                    |  6 ++++++
 7 files changed, 43 insertions(+), 3 deletions(-)

diff --git a/Makefile b/Makefile
index ee5830b..02530fa 100644
--- a/Makefile
+++ b/Makefile
@@ -755,6 +755,7 @@ CFLAGS_KASAN_MINIMAL := $(call cc-option, -fsanitize=kernel-address)
 
 CFLAGS_KASAN := $(call cc-option, -fsanitize=kernel-address \
 		-fasan-shadow-offset=$(CONFIG_KASAN_SHADOW_OFFSET) \
+		--param asan-stack=1 \
 		--param asan-instrumentation-with-call-threshold=$(call_threshold))
 
 ifeq ($(CFLAGS_KASAN_MINIMAL),)
diff --git a/arch/x86/include/asm/page_64_types.h b/arch/x86/include/asm/page_64_types.h
index 75450b2..4edd53b 100644
--- a/arch/x86/include/asm/page_64_types.h
+++ b/arch/x86/include/asm/page_64_types.h
@@ -1,17 +1,23 @@
 #ifndef _ASM_X86_PAGE_64_DEFS_H
 #define _ASM_X86_PAGE_64_DEFS_H
 
-#define THREAD_SIZE_ORDER	2
+#ifdef CONFIG_KASAN
+#define KASAN_STACK_ORDER 1
+#else
+#define KASAN_STACK_ORDER 0
+#endif
+
+#define THREAD_SIZE_ORDER	(2 + KASAN_STACK_ORDER)
 #define THREAD_SIZE  (PAGE_SIZE << THREAD_SIZE_ORDER)
 #define CURRENT_MASK (~(THREAD_SIZE - 1))
 
-#define EXCEPTION_STACK_ORDER 0
+#define EXCEPTION_STACK_ORDER (0 + KASAN_STACK_ORDER)
 #define EXCEPTION_STKSZ (PAGE_SIZE << EXCEPTION_STACK_ORDER)
 
 #define DEBUG_STACK_ORDER (EXCEPTION_STACK_ORDER + 1)
 #define DEBUG_STKSZ (PAGE_SIZE << DEBUG_STACK_ORDER)
 
-#define IRQ_STACK_ORDER 2
+#define IRQ_STACK_ORDER (2 + KASAN_STACK_ORDER)
 #define IRQ_STACK_SIZE (PAGE_SIZE << IRQ_STACK_ORDER)
 
 #define DOUBLEFAULT_STACK 1
diff --git a/arch/x86/kernel/Makefile b/arch/x86/kernel/Makefile
index 74d3f3e..fae4c4e 100644
--- a/arch/x86/kernel/Makefile
+++ b/arch/x86/kernel/Makefile
@@ -17,6 +17,8 @@ CFLAGS_REMOVE_early_printk.o = -pg
 endif
 
 KASAN_SANITIZE_head$(BITS).o := n
+KASAN_SANITIZE_dumpstack.o := n
+KASAN_SANITIZE_dumpstack_$(BITS).o := n
 
 CFLAGS_irq.o := -I$(src)/../include/asm/trace
 
diff --git a/arch/x86/mm/kasan_init_64.c b/arch/x86/mm/kasan_init_64.c
index 70e8082..042f404 100644
--- a/arch/x86/mm/kasan_init_64.c
+++ b/arch/x86/mm/kasan_init_64.c
@@ -207,9 +207,17 @@ void __init kasan_init(void)
 			kasan_mem_to_shadow(KASAN_SHADOW_END));
 
 	populate_zero_shadow(kasan_mem_to_shadow(KASAN_SHADOW_END),
+			kasan_mem_to_shadow(__START_KERNEL_map));
+
+	vmemmap_populate(kasan_mem_to_shadow((unsigned long)_stext),
+			kasan_mem_to_shadow((unsigned long)_end),
+			NUMA_NO_NODE);
+
+	populate_zero_shadow(kasan_mem_to_shadow(MODULES_VADDR),
 			KASAN_SHADOW_END);
 
 	memset(kasan_poisoned_page, KASAN_SHADOW_GAP, PAGE_SIZE);
 
 	load_cr3(init_level4_pgt);
+	init_task.kasan_depth = 0;
 }
diff --git a/include/linux/init_task.h b/include/linux/init_task.h
index 3037fc0..3932e0a 100644
--- a/include/linux/init_task.h
+++ b/include/linux/init_task.h
@@ -175,6 +175,13 @@ extern struct task_group root_task_group;
 # define INIT_NUMA_BALANCING(tsk)
 #endif
 
+#ifdef CONFIG_KASAN
+# define INIT_KASAN(tsk)						\
+	.kasan_depth = 1,
+#else
+# define INIT_KASAN(tsk)
+#endif
+
 /*
  *  INIT_TASK is used to set up the first task table, touch at
  * your own risk!. Base=0, limit=0x1fffff (=2MB)
@@ -247,6 +254,7 @@ extern struct task_group root_task_group;
 	INIT_RT_MUTEXES(tsk)						\
 	INIT_VTIME(tsk)							\
 	INIT_NUMA_BALANCING(tsk)					\
+	INIT_KASAN(tsk)							\
 }
 
 
diff --git a/include/linux/kasan.h b/include/linux/kasan.h
index 940fc4f..f8eca6a 100644
--- a/include/linux/kasan.h
+++ b/include/linux/kasan.h
@@ -17,6 +17,15 @@ struct page;
 #define KASAN_KMALLOC_FREE      0xFB  /* object was freed (kmem_cache_free/kfree) */
 #define KASAN_SHADOW_GAP        0xF9  /* address belongs to shadow memory */
 
+/*
+ * Stack redzone shadow values
+ * (Those are compiler's ABI, don't change them)
+ */
+#define KASAN_STACK_LEFT        0xF1
+#define KASAN_STACK_MID         0xF2
+#define KASAN_STACK_RIGHT       0xF3
+#define KASAN_STACK_PARTIAL     0xF4
+
 #include <asm/kasan.h>
 #include <linux/sched.h>
 
diff --git a/mm/kasan/report.c b/mm/kasan/report.c
index f9bc57a..faa07f0 100644
--- a/mm/kasan/report.c
+++ b/mm/kasan/report.c
@@ -67,6 +67,12 @@ static void print_error_description(struct access_info *info)
 	case KASAN_SHADOW_GAP:
 		bug_type = "wild memory access";
 		break;
+	case KASAN_STACK_LEFT:
+	case KASAN_STACK_MID:
+	case KASAN_STACK_RIGHT:
+	case KASAN_STACK_PARTIAL:
+		bug_type = "out of bounds on stack";
+		break;
 	}
 
 	pr_err("BUG: AddressSanitizer: %s in %pS at addr %p\n",
-- 
2.2.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

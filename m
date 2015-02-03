Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f41.google.com (mail-pa0-f41.google.com [209.85.220.41])
	by kanga.kvack.org (Postfix) with ESMTP id 71956900016
	for <linux-mm@kvack.org>; Tue,  3 Feb 2015 12:44:00 -0500 (EST)
Received: by mail-pa0-f41.google.com with SMTP id kq14so98966494pab.0
        for <linux-mm@kvack.org>; Tue, 03 Feb 2015 09:44:00 -0800 (PST)
Received: from mailout1.w1.samsung.com (mailout1.w1.samsung.com. [210.118.77.11])
        by mx.google.com with ESMTPS id gi4si3287530pbc.243.2015.02.03.09.43.49
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-MD5 bits=128/128);
        Tue, 03 Feb 2015 09:43:50 -0800 (PST)
Received: from eucpsbgm2.samsung.com (unknown [203.254.199.245])
 by mailout1.w1.samsung.com
 (Oracle Communications Messaging Server 7u4-24.01(7.0.4.24.0) 64bit (built Nov
 17 2011)) with ESMTP id <0NJ700KRYIRTGX50@mailout1.w1.samsung.com> for
 linux-mm@kvack.org; Tue, 03 Feb 2015 17:47:53 +0000 (GMT)
From: Andrey Ryabinin <a.ryabinin@samsung.com>
Subject: [PATCH v11 14/19] kasan: enable stack instrumentation
Date: Tue, 03 Feb 2015 20:43:07 +0300
Message-id: <1422985392-28652-15-git-send-email-a.ryabinin@samsung.com>
In-reply-to: <1422985392-28652-1-git-send-email-a.ryabinin@samsung.com>
References: <1404905415-9046-1-git-send-email-a.ryabinin@samsung.com>
 <1422985392-28652-1-git-send-email-a.ryabinin@samsung.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: Andrey Ryabinin <a.ryabinin@samsung.com>, Dmitry Vyukov <dvyukov@google.com>, Konstantin Serebryany <kcc@google.com>, Dmitry Chernenkov <dmitryc@google.com>, Andrey Konovalov <adech.fo@gmail.com>, Yuri Gribov <tetra2005@gmail.com>, Konstantin Khlebnikov <koct9i@gmail.com>, Sasha Levin <sasha.levin@oracle.com>, Christoph Lameter <cl@linux.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Andrew Morton <akpm@linux-foundation.org>, Dave Hansen <dave.hansen@intel.com>, Andi Kleen <andi@firstfloor.org>, x86@kernel.org, linux-mm@kvack.org, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, "H. Peter Anvin" <hpa@zytor.com>, Michal Marek <mmarek@suse.cz>, "open list:KERNEL BUILD + fi..." <linux-kbuild@vger.kernel.org>

Stack instrumentation allows to detect out of bounds
memory accesses for variables allocated on stack.
Compiler adds redzones around every variable on stack
and poisons redzones in function's prologue.

Such approach significantly increases stack usage,
so all in-kernel stacks size were doubled.

Signed-off-by: Andrey Ryabinin <a.ryabinin@samsung.com>
---
 arch/x86/include/asm/page_64_types.h | 12 +++++++++---
 arch/x86/kernel/Makefile             |  2 ++
 arch/x86/mm/kasan_init_64.c          | 11 +++++++++--
 include/linux/init_task.h            |  8 ++++++++
 mm/kasan/kasan.h                     |  9 +++++++++
 mm/kasan/report.c                    |  6 ++++++
 scripts/Makefile.kasan               |  1 +
 7 files changed, 44 insertions(+), 5 deletions(-)

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
index 4fc8ca7..057f6f6 100644
--- a/arch/x86/kernel/Makefile
+++ b/arch/x86/kernel/Makefile
@@ -17,6 +17,8 @@ CFLAGS_REMOVE_early_printk.o = -pg
 endif
 
 KASAN_SANITIZE_head$(BITS).o := n
+KASAN_SANITIZE_dumpstack.o := n
+KASAN_SANITIZE_dumpstack_$(BITS).o := n
 
 CFLAGS_irq.o := -I$(src)/../include/asm/trace
 
diff --git a/arch/x86/mm/kasan_init_64.c b/arch/x86/mm/kasan_init_64.c
index 3e4d9a1..5350870 100644
--- a/arch/x86/mm/kasan_init_64.c
+++ b/arch/x86/mm/kasan_init_64.c
@@ -189,11 +189,18 @@ void __init kasan_init(void)
 		if (map_range(&pfn_mapped[i]))
 			panic("kasan: unable to allocate shadow!");
 	}
-
 	populate_zero_shadow(kasan_mem_to_shadow((void *)PAGE_OFFSET + MAXMEM),
-				(void *)KASAN_SHADOW_END);
+			kasan_mem_to_shadow((void *)__START_KERNEL_map));
+
+	vmemmap_populate((unsigned long)kasan_mem_to_shadow(_stext),
+			(unsigned long)kasan_mem_to_shadow(_end),
+			NUMA_NO_NODE);
+
+	populate_zero_shadow(kasan_mem_to_shadow((void *)MODULES_VADDR),
+			(void *)KASAN_SHADOW_END);
 
 	memset(kasan_zero_page, 0, PAGE_SIZE);
 
 	load_cr3(init_level4_pgt);
+	init_task.kasan_depth = 0;
 }
diff --git a/include/linux/init_task.h b/include/linux/init_task.h
index d3d43ec..696d223 100644
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
@@ -250,6 +257,7 @@ extern struct task_group root_task_group;
 	INIT_RT_MUTEXES(tsk)						\
 	INIT_VTIME(tsk)							\
 	INIT_NUMA_BALANCING(tsk)					\
+	INIT_KASAN(tsk)							\
 }
 
 
diff --git a/mm/kasan/kasan.h b/mm/kasan/kasan.h
index 5b052ab..1fcc1d8 100644
--- a/mm/kasan/kasan.h
+++ b/mm/kasan/kasan.h
@@ -12,6 +12,15 @@
 #define KASAN_KMALLOC_REDZONE   0xFC  /* redzone inside slub object */
 #define KASAN_KMALLOC_FREE      0xFB  /* object was freed (kmem_cache_free/kfree) */
 
+/*
+ * Stack redzone shadow values
+ * (Those are compiler's ABI, don't change them)
+ */
+#define KASAN_STACK_LEFT        0xF1
+#define KASAN_STACK_MID         0xF2
+#define KASAN_STACK_RIGHT       0xF3
+#define KASAN_STACK_PARTIAL     0xF4
+
 
 struct kasan_access_info {
 	const void *access_addr;
diff --git a/mm/kasan/report.c b/mm/kasan/report.c
index 2760edb..866732e 100644
--- a/mm/kasan/report.c
+++ b/mm/kasan/report.c
@@ -64,6 +64,12 @@ static void print_error_description(struct kasan_access_info *info)
 	case 0 ... KASAN_SHADOW_SCALE_SIZE - 1:
 		bug_type = "out of bounds access";
 		break;
+	case KASAN_STACK_LEFT:
+	case KASAN_STACK_MID:
+	case KASAN_STACK_RIGHT:
+	case KASAN_STACK_PARTIAL:
+		bug_type = "out of bounds on stack";
+		break;
 	}
 
 	pr_err("BUG: KASan: %s in %pS at addr %p\n",
diff --git a/scripts/Makefile.kasan b/scripts/Makefile.kasan
index 159396a..0ac7d1d 100644
--- a/scripts/Makefile.kasan
+++ b/scripts/Makefile.kasan
@@ -9,6 +9,7 @@ CFLAGS_KASAN_MINIMAL := $(call cc-option, -fsanitize=kernel-address)
 
 CFLAGS_KASAN := $(call cc-option, -fsanitize=kernel-address \
 		-fasan-shadow-offset=$(CONFIG_KASAN_SHADOW_OFFSET) \
+		--param asan-stack=1 \
 		--param asan-instrumentation-with-call-threshold=$(call_threshold))
 
 ifeq ($(CFLAGS_KASAN_MINIMAL),)
-- 
2.2.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

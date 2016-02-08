Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ob0-f181.google.com (mail-ob0-f181.google.com [209.85.214.181])
	by kanga.kvack.org (Postfix) with ESMTP id C932C830C6
	for <linux-mm@kvack.org>; Mon,  8 Feb 2016 04:21:48 -0500 (EST)
Received: by mail-ob0-f181.google.com with SMTP id ba1so145059832obb.3
        for <linux-mm@kvack.org>; Mon, 08 Feb 2016 01:21:48 -0800 (PST)
Received: from e31.co.us.ibm.com (e31.co.us.ibm.com. [32.97.110.149])
        by mx.google.com with ESMTPS id rs10si15278797obb.62.2016.02.08.01.21.44
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Mon, 08 Feb 2016 01:21:45 -0800 (PST)
Received: from localhost
	by e31.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <aneesh.kumar@linux.vnet.ibm.com>;
	Mon, 8 Feb 2016 02:21:44 -0700
Received: from b03cxnp07029.gho.boulder.ibm.com (b03cxnp07029.gho.boulder.ibm.com [9.17.130.16])
	by d03dlp01.boulder.ibm.com (Postfix) with ESMTP id 62A501FF0041
	for <linux-mm@kvack.org>; Mon,  8 Feb 2016 02:09:52 -0700 (MST)
Received: from d03av05.boulder.ibm.com (d03av05.boulder.ibm.com [9.17.195.85])
	by b03cxnp07029.gho.boulder.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id u189LgL831326370
	for <linux-mm@kvack.org>; Mon, 8 Feb 2016 02:21:42 -0700
Received: from d03av05.boulder.ibm.com (localhost [127.0.0.1])
	by d03av05.boulder.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id u189Le9F026142
	for <linux-mm@kvack.org>; Mon, 8 Feb 2016 02:21:41 -0700
From: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
Subject: [PATCH V2 22/29] powerpc/mm: Hash linux abstraction for mmu context handling code
Date: Mon,  8 Feb 2016 14:50:34 +0530
Message-Id: <1454923241-6681-23-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
In-Reply-To: <1454923241-6681-1-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
References: <1454923241-6681-1-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: benh@kernel.crashing.org, paulus@samba.org, mpe@ellerman.id.au
Cc: linuxppc-dev@lists.ozlabs.org, linux-mm@kvack.org, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>

Signed-off-by: Aneesh Kumar K.V <aneesh.kumar@linux.vnet.ibm.com>
---
 arch/powerpc/include/asm/mmu_context.h | 63 +++++++++++++++++++++++-----------
 arch/powerpc/kernel/swsusp.c           |  2 +-
 arch/powerpc/mm/mmu_context_hash64.c   | 16 ++++-----
 arch/powerpc/mm/mmu_context_nohash.c   |  3 +-
 drivers/cpufreq/pmac32-cpufreq.c       |  2 +-
 drivers/macintosh/via-pmu.c            |  4 +--
 6 files changed, 57 insertions(+), 33 deletions(-)

diff --git a/arch/powerpc/include/asm/mmu_context.h b/arch/powerpc/include/asm/mmu_context.h
index 878c27771717..5124b721da6e 100644
--- a/arch/powerpc/include/asm/mmu_context.h
+++ b/arch/powerpc/include/asm/mmu_context.h
@@ -10,11 +10,6 @@
 #include <asm/cputable.h>
 #include <asm/cputhreads.h>
 
-/*
- * Most if the context management is out of line
- */
-extern int init_new_context(struct task_struct *tsk, struct mm_struct *mm);
-extern void destroy_context(struct mm_struct *mm);
 #ifdef CONFIG_SPAPR_TCE_IOMMU
 struct mm_iommu_table_group_mem_t;
 
@@ -33,16 +28,50 @@ extern long mm_iommu_ua_to_hpa(struct mm_iommu_table_group_mem_t *mem,
 extern long mm_iommu_mapped_inc(struct mm_iommu_table_group_mem_t *mem);
 extern void mm_iommu_mapped_dec(struct mm_iommu_table_group_mem_t *mem);
 #endif
+/*
+ * Most of the context management is out of line
+ */
+#ifdef CONFIG_PPC_BOOK3S_64
+extern int hlinit_new_context(struct task_struct *tsk, struct mm_struct *mm);
+static inline int init_new_context(struct task_struct *tsk, struct mm_struct *mm)
+{
+	return hlinit_new_context(tsk, mm);
+}
+
+extern void hldestroy_context(struct mm_struct *mm);
+static inline void destroy_context(struct mm_struct *mm)
+{
+	return hldestroy_context(mm);
+}
 
-extern void switch_mmu_context(struct mm_struct *prev, struct mm_struct *next);
 extern void switch_slb(struct task_struct *tsk, struct mm_struct *mm);
-extern void set_context(unsigned long id, pgd_t *pgd);
+static inline void switch_mmu_context(struct mm_struct *prev,
+				      struct mm_struct *next,
+				      struct task_struct *tsk)
+{
+	return switch_slb(tsk, next);
+}
 
-#ifdef CONFIG_PPC_BOOK3S_64
-extern int __init_new_context(void);
-extern void __destroy_context(int context_id);
+extern void set_context(unsigned long id, pgd_t *pgd);
+extern int __hlinit_new_context(void);
+static inline int __init_new_context(void)
+{
+	return __hlinit_new_context();
+}
+extern void __hldestroy_context(int context_id);
+static inline void __destroy_context(int context_id)
+{
+	return __hldestroy_context(context_id);
+}
 static inline void mmu_context_init(void) { }
 #else
+extern int init_new_context(struct task_struct *tsk, struct mm_struct *mm);
+extern void destroy_context(struct mm_struct *mm);
+
+extern void switch_mmu_context(struct mm_struct *prev, struct mm_struct *next,
+			       struct task_struct *tsk);
+extern void switch_slb(struct task_struct *tsk, struct mm_struct *mm);
+extern void set_context(unsigned long id, pgd_t *pgd);
 extern unsigned long __init_new_context(void);
 extern void __destroy_context(unsigned long context_id);
 extern void mmu_context_init(void);
@@ -88,17 +117,11 @@ static inline void switch_mm(struct mm_struct *prev, struct mm_struct *next,
 	if (cpu_has_feature(CPU_FTR_ALTIVEC))
 		asm volatile ("dssall");
 #endif /* CONFIG_ALTIVEC */
-
-	/* The actual HW switching method differs between the various
-	 * sub architectures.
+	/*
+	 * The actual HW switching method differs between the various
+	 * sub architectures. Out of line for now
 	 */
-#ifdef CONFIG_PPC_STD_MMU_64
-	switch_slb(tsk, next);
-#else
-	/* Out of line for now */
-	switch_mmu_context(prev, next);
-#endif
-
+	switch_mmu_context(prev, next, tsk);
 }
 
 #define deactivate_mm(tsk,mm)	do { } while (0)
diff --git a/arch/powerpc/kernel/swsusp.c b/arch/powerpc/kernel/swsusp.c
index 6669b1752512..6ae9bd5086a4 100644
--- a/arch/powerpc/kernel/swsusp.c
+++ b/arch/powerpc/kernel/swsusp.c
@@ -31,6 +31,6 @@ void save_processor_state(void)
 void restore_processor_state(void)
 {
 #ifdef CONFIG_PPC32
-	switch_mmu_context(current->active_mm, current->active_mm);
+	switch_mmu_context(current->active_mm, current->active_mm, NULL);
 #endif
 }
diff --git a/arch/powerpc/mm/mmu_context_hash64.c b/arch/powerpc/mm/mmu_context_hash64.c
index ff9baa5d2944..9c147d800760 100644
--- a/arch/powerpc/mm/mmu_context_hash64.c
+++ b/arch/powerpc/mm/mmu_context_hash64.c
@@ -30,7 +30,7 @@
 static DEFINE_SPINLOCK(mmu_context_lock);
 static DEFINE_IDA(mmu_context_ida);
 
-int __init_new_context(void)
+int __hlinit_new_context(void)
 {
 	int index;
 	int err;
@@ -59,11 +59,11 @@ again:
 }
 EXPORT_SYMBOL_GPL(__init_new_context);
 
-int init_new_context(struct task_struct *tsk, struct mm_struct *mm)
+int hlinit_new_context(struct task_struct *tsk, struct mm_struct *mm)
 {
 	int index;
 
-	index = __init_new_context();
+	index = __hlinit_new_context();
 	if (index < 0)
 		return index;
 
@@ -78,7 +78,7 @@ int init_new_context(struct task_struct *tsk, struct mm_struct *mm)
 #ifdef CONFIG_PPC_ICSWX
 	mm->context.cop_lockp = kmalloc(sizeof(spinlock_t), GFP_KERNEL);
 	if (!mm->context.cop_lockp) {
-		__destroy_context(index);
+		__hldestroy_context(index);
 		subpage_prot_free(mm);
 		mm->context.id = MMU_NO_CONTEXT;
 		return -ENOMEM;
@@ -95,13 +95,13 @@ int init_new_context(struct task_struct *tsk, struct mm_struct *mm)
 	return 0;
 }
 
-void __destroy_context(int context_id)
+void __hldestroy_context(int context_id)
 {
 	spin_lock(&mmu_context_lock);
 	ida_remove(&mmu_context_ida, context_id);
 	spin_unlock(&mmu_context_lock);
 }
-EXPORT_SYMBOL_GPL(__destroy_context);
+EXPORT_SYMBOL_GPL(__hldestroy_context);
 
 #ifdef CONFIG_PPC_64K_PAGES
 static void destroy_pagetable_page(struct mm_struct *mm)
@@ -133,7 +133,7 @@ static inline void destroy_pagetable_page(struct mm_struct *mm)
 #endif
 
 
-void destroy_context(struct mm_struct *mm)
+void hldestroy_context(struct mm_struct *mm)
 {
 #ifdef CONFIG_SPAPR_TCE_IOMMU
 	mm_iommu_cleanup(&mm->context);
@@ -146,7 +146,7 @@ void destroy_context(struct mm_struct *mm)
 #endif /* CONFIG_PPC_ICSWX */
 
 	destroy_pagetable_page(mm);
-	__destroy_context(mm->context.id);
+	__hldestroy_context(mm->context.id);
 	subpage_prot_free(mm);
 	mm->context.id = MMU_NO_CONTEXT;
 }
diff --git a/arch/powerpc/mm/mmu_context_nohash.c b/arch/powerpc/mm/mmu_context_nohash.c
index 986afbc22c76..a36c43a27893 100644
--- a/arch/powerpc/mm/mmu_context_nohash.c
+++ b/arch/powerpc/mm/mmu_context_nohash.c
@@ -226,7 +226,8 @@ static void context_check_map(void)
 static void context_check_map(void) { }
 #endif
 
-void switch_mmu_context(struct mm_struct *prev, struct mm_struct *next)
+void switch_mmu_context(struct mm_struct *prev, struct mm_struct *next,
+			struct task_struct *tsk)
 {
 	unsigned int i, id, cpu = smp_processor_id();
 	unsigned long *map;
diff --git a/drivers/cpufreq/pmac32-cpufreq.c b/drivers/cpufreq/pmac32-cpufreq.c
index 1f49d97a70ea..bde503c66945 100644
--- a/drivers/cpufreq/pmac32-cpufreq.c
+++ b/drivers/cpufreq/pmac32-cpufreq.c
@@ -298,7 +298,7 @@ static int pmu_set_cpu_speed(int low_speed)
  		_set_L3CR(save_l3cr);
 
 	/* Restore userland MMU context */
-	switch_mmu_context(NULL, current->active_mm);
+	switch_mmu_context(NULL, current->active_mm, NULL);
 
 #ifdef DEBUG_FREQ
 	printk(KERN_DEBUG "HID1, after: %x\n", mfspr(SPRN_HID1));
diff --git a/drivers/macintosh/via-pmu.c b/drivers/macintosh/via-pmu.c
index 01ee736fe0ef..f8b6d1403c16 100644
--- a/drivers/macintosh/via-pmu.c
+++ b/drivers/macintosh/via-pmu.c
@@ -1851,7 +1851,7 @@ static int powerbook_sleep_grackle(void)
  		_set_L2CR(save_l2cr);
 	
 	/* Restore userland MMU context */
-	switch_mmu_context(NULL, current->active_mm);
+	switch_mmu_context(NULL, current->active_mm, NULL);
 
 	/* Power things up */
 	pmu_unlock();
@@ -1940,7 +1940,7 @@ powerbook_sleep_Core99(void)
  		_set_L3CR(save_l3cr);
 	
 	/* Restore userland MMU context */
-	switch_mmu_context(NULL, current->active_mm);
+	switch_mmu_context(NULL, current->active_mm, NULL);
 
 	/* Tell PMU we are ready */
 	pmu_unlock();
-- 
2.5.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f198.google.com (mail-qt0-f198.google.com [209.85.216.198])
	by kanga.kvack.org (Postfix) with ESMTP id A171D6B025E
	for <linux-mm@kvack.org>; Fri, 16 Dec 2016 13:36:01 -0500 (EST)
Received: by mail-qt0-f198.google.com with SMTP id l20so62745775qta.3
        for <linux-mm@kvack.org>; Fri, 16 Dec 2016 10:36:01 -0800 (PST)
Received: from userp1040.oracle.com (userp1040.oracle.com. [156.151.31.81])
        by mx.google.com with ESMTPS id e30si3845206qte.87.2016.12.16.10.35.59
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 16 Dec 2016 10:35:59 -0800 (PST)
From: Mike Kravetz <mike.kravetz@oracle.com>
Subject: [RFC PATCH 03/14] sparc64: routines for basic mmu shared context structure management
Date: Fri, 16 Dec 2016 10:35:26 -0800
Message-Id: <1481913337-9331-4-git-send-email-mike.kravetz@oracle.com>
In-Reply-To: <1481913337-9331-1-git-send-email-mike.kravetz@oracle.com>
References: <1481913337-9331-1-git-send-email-mike.kravetz@oracle.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: sparclinux@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org
Cc: "David S . Miller" <davem@davemloft.net>, Bob Picco <bob.picco@oracle.com>, Nitin Gupta <nitin.m.gupta@oracle.com>, Vijay Kumar <vijay.ac.kumar@oracle.com>, Julian Calaby <julian.calaby@gmail.com>, Adam Buchbinder <adam.buchbinder@gmail.com>, "Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>, Michal Hocko <mhocko@suse.com>, Andrew Morton <akpm@linux-foundation.org>, Mike Kravetz <mike.kravetz@oracle.com>

Add routines for basic management of mmu shared context data structures.
These routines have to do with allocation/deallocation and get/put
of the structures.  The structures themselves will come from a new
kmem cache.

FIXMEs were added to then code where additional work is needed.

Signed-off-by: Mike Kravetz <mike.kravetz@oracle.com>
---
 arch/sparc/include/asm/mmu_context_64.h |  6 +++
 arch/sparc/include/asm/tlb_64.h         |  3 ++
 arch/sparc/include/asm/tsb.h            |  2 +
 arch/sparc/kernel/smp_64.c              | 22 +++++++++
 arch/sparc/mm/init_64.c                 | 84 +++++++++++++++++++++++++++++++--
 arch/sparc/mm/tsb.c                     | 54 +++++++++++++++++++++
 6 files changed, 168 insertions(+), 3 deletions(-)

diff --git a/arch/sparc/include/asm/mmu_context_64.h b/arch/sparc/include/asm/mmu_context_64.h
index d031799..acaea6d 100644
--- a/arch/sparc/include/asm/mmu_context_64.h
+++ b/arch/sparc/include/asm/mmu_context_64.h
@@ -18,6 +18,12 @@ extern unsigned long tlb_context_cache;
 extern unsigned long mmu_context_bmap[];
 
 void get_new_mmu_context(struct mm_struct *mm);
+#if defined(CONFIG_SHARED_MMU_CTX)
+void get_new_mmu_shared_context(struct mm_struct *mm);
+void put_shared_context(struct mm_struct *mm);
+void set_mm_shared_ctx(struct mm_struct *mm, struct shared_mmu_ctx *ctx);
+void destroy_shared_context(struct mm_struct *mm);
+#endif
 #ifdef CONFIG_SMP
 void smp_new_mmu_context_version(void);
 #else
diff --git a/arch/sparc/include/asm/tlb_64.h b/arch/sparc/include/asm/tlb_64.h
index 4cb392f..e348a1b 100644
--- a/arch/sparc/include/asm/tlb_64.h
+++ b/arch/sparc/include/asm/tlb_64.h
@@ -14,6 +14,9 @@ void smp_flush_tlb_pending(struct mm_struct *,
 
 #ifdef CONFIG_SMP
 void smp_flush_tlb_mm(struct mm_struct *mm);
+#if defined(CONFIG_SHARED_MMU_CTX)
+void smp_flush_shared_tlb_mm(struct mm_struct *mm);
+#endif
 #define do_flush_tlb_mm(mm) smp_flush_tlb_mm(mm)
 #else
 #define do_flush_tlb_mm(mm) __flush_tlb_mm(CTX_HWBITS(mm->context), SECONDARY_CONTEXT)
diff --git a/arch/sparc/include/asm/tsb.h b/arch/sparc/include/asm/tsb.h
index 32258e0..311cd4e 100644
--- a/arch/sparc/include/asm/tsb.h
+++ b/arch/sparc/include/asm/tsb.h
@@ -72,6 +72,8 @@ struct tsb_phys_patch_entry {
 	unsigned int	insn;
 };
 extern struct tsb_phys_patch_entry __tsb_phys_patch, __tsb_phys_patch_end;
+
+extern struct kmem_cache *shared_mmu_ctx_cachep __read_mostly;
 #endif
 #define TSB_LOAD_QUAD(TSB, REG)	\
 661:	ldda		[TSB] ASI_NUCLEUS_QUAD_LDD, REG; \
diff --git a/arch/sparc/kernel/smp_64.c b/arch/sparc/kernel/smp_64.c
index 8182f7c..c0f23ee 100644
--- a/arch/sparc/kernel/smp_64.c
+++ b/arch/sparc/kernel/smp_64.c
@@ -1078,6 +1078,28 @@ void smp_flush_tlb_mm(struct mm_struct *mm)
 	put_cpu();
 }
 
+#if defined(CONFIG_SHARED_MMU_CTX)
+/*
+ * Called when last reference to shared context is dropped.  Flush
+ * all TLB entries associated with the shared clontext ID.
+ *
+ * FIXME
+ * Future optimization would be to store cpumask in shared context
+ * structure and only make cross call to those cpus.
+ */
+void smp_flush_shared_tlb_mm(struct mm_struct *mm)
+{
+	u32 ctx = SHARED_CTX_HWBITS(mm->context);
+
+	(void)get_cpu();		/* prevent preemption */
+
+	smp_cross_call(&xcall_flush_tlb_mm, ctx, 0, 0);
+	__flush_tlb_mm(ctx, SECONDARY_CONTEXT);
+
+	put_cpu();
+}
+#endif
+
 struct tlb_pending_info {
 	unsigned long ctx;
 	unsigned long nr;
diff --git a/arch/sparc/mm/init_64.c b/arch/sparc/mm/init_64.c
index 37aa537..bb9a6ee 100644
--- a/arch/sparc/mm/init_64.c
+++ b/arch/sparc/mm/init_64.c
@@ -673,14 +673,24 @@ DECLARE_BITMAP(mmu_context_bmap, MAX_CTX_NR);
  *
  * Always invoked with interrupts disabled.
  */
-void get_new_mmu_context(struct mm_struct *mm)
+static void __get_new_mmu_context_common(struct mm_struct *mm, bool shared)
 {
 	unsigned long ctx, new_ctx;
 	unsigned long orig_pgsz_bits;
 	int new_version;
 
 	spin_lock(&ctx_alloc_lock);
-	orig_pgsz_bits = (mm->context.sparc64_ctx_val & CTX_PGSZ_MASK);
+#if defined(CONFIG_SHARED_MMU_CTX)
+	if (shared)
+		/*
+		 * Note that we are only called from get_new_mmu_shared_context
+		 * which guarantees the existence of shared_ctx structure.
+		 */
+		orig_pgsz_bits = (mm->context.shared_ctx->shared_ctx_val &
+				  CTX_PGSZ_MASK);
+	else
+#endif
+		orig_pgsz_bits = (mm->context.sparc64_ctx_val & CTX_PGSZ_MASK);
 	ctx = (tlb_context_cache + 1) & CTX_NR_MASK;
 	new_ctx = find_next_zero_bit(mmu_context_bmap, 1 << CTX_NR_BITS, ctx);
 	new_version = 0;
@@ -714,13 +724,81 @@ void get_new_mmu_context(struct mm_struct *mm)
 	new_ctx |= (tlb_context_cache & CTX_VERSION_MASK);
 out:
 	tlb_context_cache = new_ctx;
-	mm->context.sparc64_ctx_val = new_ctx | orig_pgsz_bits;
+#if defined(CONFIG_SHARED_MMU_CTX)
+	if (shared)
+		mm->context.shared_ctx->shared_ctx_val =
+					new_ctx | orig_pgsz_bits;
+	else
+#endif
+		mm->context.sparc64_ctx_val = new_ctx | orig_pgsz_bits;
 	spin_unlock(&ctx_alloc_lock);
 
+	/*
+	 * FIXME
+	 * Not sure if the case where a shared context ID changed (not just
+	 * newly allocated) is handled properly.  May need to modify
+	 * smp_new_mmu_context_version to handle correctly.
+	 */
 	if (unlikely(new_version))
 		smp_new_mmu_context_version();
 }
 
+void get_new_mmu_context(struct mm_struct *mm)
+{
+	__get_new_mmu_context_common(mm, false);
+}
+
+#if defined(CONFIG_SHARED_MMU_CTX)
+void get_new_mmu_shared_context(struct mm_struct *mm)
+{
+	/*
+	 * For now, we only support one shared context mapping per mm.  So,
+	 * if mm->context.shared_ctx  is already set, we have a bug
+	 *
+	 * Note that we are called from mmap with mmap_sem held.  Thus,
+	 * there can not be two threads racing to initialize.
+	 */
+	BUG_ON(mm->context.shared_ctx);
+
+	mm->context.shared_ctx = kmem_cache_alloc(shared_mmu_ctx_cachep,
+						GFP_NOWAIT);
+	if (!mm->context.shared_ctx)
+		return;
+
+	__get_new_mmu_context_common(mm, true);
+}
+
+void put_shared_context(struct mm_struct *mm)
+{
+	if (!mm->context.shared_ctx)
+		return;
+
+	if (atomic_dec_and_test(&mm->context.shared_ctx->refcount)) {
+		smp_flush_shared_tlb_mm(mm);
+		destroy_shared_context(mm);
+		kmem_cache_free(shared_mmu_ctx_cachep, mm->context.shared_ctx);
+	}
+
+	/*
+	 * For now we assume/expect only one shared context reference per mm
+	 */
+	mm->context.shared_ctx = NULL;
+}
+
+void set_mm_shared_ctx(struct mm_struct *mm, struct shared_mmu_ctx *ctx)
+{
+	BUG_ON(mm->context.shared_ctx || !ctx);
+
+	/*
+	 * Note that we are called with mmap_lock held on underlying
+	 * mapping.  Hence, the ctx structure pointed to by the matching
+	 * vma can not go away.
+	 */
+	atomic_inc(&ctx->refcount);
+	mm->context.shared_ctx = ctx;
+}
+#endif
+
 static int numa_enabled = 1;
 static int numa_debug;
 
diff --git a/arch/sparc/mm/tsb.c b/arch/sparc/mm/tsb.c
index e20fbba..8c2d148 100644
--- a/arch/sparc/mm/tsb.c
+++ b/arch/sparc/mm/tsb.c
@@ -277,6 +277,8 @@ static void setup_tsb_params(struct mm_struct *mm, unsigned long tsb_idx, unsign
 	}
 }
 
+struct kmem_cache *shared_mmu_ctx_cachep __read_mostly;
+
 struct kmem_cache *pgtable_cache __read_mostly;
 
 static struct kmem_cache *tsb_caches[8] __read_mostly;
@@ -292,6 +294,27 @@ static const char *tsb_cache_names[8] = {
 	"tsb_1MB",
 };
 
+#if defined(CONFIG_SHARED_MMU_CTX)
+static void init_once_shared_mmu_ctx(void *mem)
+{
+	struct shared_mmu_ctx *ctx = (struct shared_mmu_ctx *) mem;
+
+	ctx->shared_ctx_val = 0;
+	atomic_set(&ctx->refcount, 1);
+}
+
+static void __init sun4v_shared_mmu_ctx_init(void)
+{
+	shared_mmu_ctx_cachep = kmem_cache_create("shared_mmu_ctx_cache",
+					sizeof(struct shared_mmu_ctx),
+					0,
+					SLAB_HWCACHE_ALIGN|SLAB_PANIC,
+					init_once_shared_mmu_ctx);
+}
+#else
+static void __init sun4v_shared_mmu_ctx_init(void) { }
+#endif
+
 void __init pgtable_cache_init(void)
 {
 	unsigned long i;
@@ -317,6 +340,13 @@ void __init pgtable_cache_init(void)
 			prom_halt();
 		}
 	}
+
+	if (tlb_type == hypervisor)
+		/*
+		 * FIXME - shared context enables/supported on most
+		 * but not all sun4v priocessors
+		 */
+		sun4v_shared_mmu_ctx_init();
 }
 
 int sysctl_tsb_ratio = -2;
@@ -547,6 +577,30 @@ static void tsb_destroy_one(struct tsb_config *tp)
 	tp->tsb_reg_val = 0UL;
 }
 
+#if defined(CONFIG_SHARED_MMU_CTX)
+void destroy_shared_context(struct mm_struct *mm)
+{
+	unsigned long flags;
+
+	spin_lock_irqsave(&ctx_alloc_lock, flags);
+
+	if (SHARED_CTX_VALID(mm->context)) {
+		unsigned long nr = SHARED_CTX_NRBITS(mm->context);
+
+		mmu_context_bmap[nr>>6] &= ~(1UL << (nr & 63));
+	}
+
+	spin_unlock_irqrestore(&ctx_alloc_lock, flags);
+
+#if defined(CONFIG_SHARED_MMU_CTX)
+	/*
+	 * Any shared context should have been cleaned up by now
+	 */
+	BUG_ON(SHARED_CTX_VALID(mm->context));
+#endif
+}
+#endif
+
 void destroy_context(struct mm_struct *mm)
 {
 	unsigned long flags, i;
-- 
2.7.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

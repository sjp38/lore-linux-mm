Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f70.google.com (mail-pg0-f70.google.com [74.125.83.70])
	by kanga.kvack.org (Postfix) with ESMTP id 362366B025E
	for <linux-mm@kvack.org>; Thu, 26 Jan 2017 17:40:11 -0500 (EST)
Received: by mail-pg0-f70.google.com with SMTP id 3so75329414pgj.6
        for <linux-mm@kvack.org>; Thu, 26 Jan 2017 14:40:11 -0800 (PST)
Received: from mga07.intel.com (mga07.intel.com. [134.134.136.100])
        by mx.google.com with ESMTPS id w16si2594822plk.57.2017.01.26.14.40.09
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 26 Jan 2017 14:40:09 -0800 (PST)
Subject: [RFC][PATCH 3/4] x86, mpx: extend MPX prctl() to pass in size of bounds directory
From: Dave Hansen <dave.hansen@linux.intel.com>
Date: Thu, 26 Jan 2017 14:40:09 -0800
References: <20170126224005.A6BBEF2C@viggo.jf.intel.com>
In-Reply-To: <20170126224005.A6BBEF2C@viggo.jf.intel.com>
Message-Id: <20170126224009.ECA68304@viggo.jf.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: linux-mm@kvack.org, x86@kernel.org, Dave Hansen <dave.hansen@linux.intel.com>


The MPX bounds tables are indexed by virtual address.  A larger virtual
address space means that we need larger tables.  But, we need to ensure
that userspace and the kernel agree about the size of these tables.

To do this, we require that userspace pass in the size of the tables
if they want a non-legacy size.  They do this with a previously unused
(required to be 0) argument to the PR_MPX_ENABLE_MANAGEMENT ptctl().

This way, the kernel can make sure that the size of the tables is
consistent with the size of the address space and can return an error
if there is a mismatch.

There are essentially 3 table sizes that matter:
1. 32-bit table sized for a 32-bit address space
2. 64-bit table sized for a 48-bit address space
3. 64-bit table sized for a 57-bit address space

We cover all three of those cases.

FIXME: we also need to ensure that we check the current state of the
larger address space opt-in.  If we've opted in to larger address spaces
we can not allow a small bounds directory to be used.  Also, if we've
not opted in, we can not allow the larger bounds directory to be used.

---

 b/arch/x86/include/asm/mpx.h       |    5 +++
 b/arch/x86/include/asm/processor.h |    6 ++--
 b/arch/x86/mm/mpx.c                |   54 +++++++++++++++++++++++++++++++++++--
 b/arch/x86/mm/pgtable.c            |    2 -
 b/kernel/sys.c                     |    6 ++--
 5 files changed, 64 insertions(+), 9 deletions(-)

diff -puN arch/x86/include/asm/mpx.h~mawa-040-prctl-set-mawa arch/x86/include/asm/mpx.h
--- a/arch/x86/include/asm/mpx.h~mawa-040-prctl-set-mawa	2017-01-26 14:31:33.564714660 -0800
+++ b/arch/x86/include/asm/mpx.h	2017-01-26 14:31:33.574715109 -0800
@@ -40,6 +40,11 @@
 #define MPX_BD_LEGACY_NR_ENTRIES_64	(1UL<<28)
 
 /*
+ * We only support one value for MAWA
+ */
+#define MPX_MAWA_VALUE		9
+
+/*
  * The 32-bit directory is 4MB (2^22) in size, and with 4-byte
  * entries it has 2^20 entries.
  */
diff -puN arch/x86/include/asm/processor.h~mawa-040-prctl-set-mawa arch/x86/include/asm/processor.h
--- a/arch/x86/include/asm/processor.h~mawa-040-prctl-set-mawa	2017-01-26 14:31:33.566714750 -0800
+++ b/arch/x86/include/asm/processor.h	2017-01-26 14:31:33.575715154 -0800
@@ -863,14 +863,14 @@ extern int get_tsc_mode(unsigned long ad
 extern int set_tsc_mode(unsigned int val);
 
 /* Register/unregister a process' MPX related resource */
-#define MPX_ENABLE_MANAGEMENT()	mpx_enable_management()
+#define MPX_ENABLE_MANAGEMENT(bd_size)	mpx_enable_management(bd_size)
 #define MPX_DISABLE_MANAGEMENT()	mpx_disable_management()
 
 #ifdef CONFIG_X86_INTEL_MPX
-extern int mpx_enable_management(void);
+extern int mpx_enable_management(unsigned long bd_size);
 extern int mpx_disable_management(void);
 #else
-static inline int mpx_enable_management(void)
+static inline int mpx_enable_management(unsigned long bd_size)
 {
 	return -EINVAL;
 }
diff -puN arch/x86/mm/mpx.c~mawa-040-prctl-set-mawa arch/x86/mm/mpx.c
--- a/arch/x86/mm/mpx.c~mawa-040-prctl-set-mawa	2017-01-26 14:31:33.567714795 -0800
+++ b/arch/x86/mm/mpx.c	2017-01-26 14:31:33.575715154 -0800
@@ -339,7 +339,54 @@ static __user void *mpx_get_bounds_dir(v
 		(bndcsr->bndcfgu & MPX_BNDCFG_ADDR_MASK);
 }
 
-int mpx_enable_management(void)
+int mpx_set_mm_bd_size(unsigned long bd_size)
+{
+	struct mm_struct *mm = current->mm;
+
+	switch ((unsigned long long)bd_size) {
+	case 0:
+		/* Legacy call to prctl(): */
+		mm->context.mpx_mawa = 0;
+		return 0;
+	case MPX_BD_SIZE_BYTES_32:
+		/* 32-bit, legacy-sized bounds directory: */
+		if (is_64bit_mm(mm))
+			return -EINVAL;
+		mm->context.mpx_mawa = 0;
+		return 0;
+	case MPX_BD_BASE_SIZE_BYTES_64:
+		/* 64-bit, legacy-sized bounds directory: */
+		if (!is_64bit_mm(mm)
+		// FIXME && ! opted-in to larger address space
+		)
+			return -EINVAL;
+		mm->context.mpx_mawa = 0;
+		return 0;
+	case MPX_BD_BASE_SIZE_BYTES_64 << MPX_MAWA_VALUE:
+		/*
+		 * Non-legacy call, with larger directory.
+		 * Note that there is no 32-bit equivalent for
+		 * this case since its address space does not
+		 * change sizes.
+		 */
+		if (!is_64bit_mm(mm))
+			return -EINVAL;
+		/*
+		 * Do not let this be enabled unles we are on
+		 * 5-level hardware *and* have that feature
+		 * enabled. FIXME: need runtime check
+		 */
+		if (!cpu_feature_enabled(X86_FEATURE_LA57)
+		// FIXME && opted into larger address space
+		)
+			return -EINVAL;
+		mm->context.mpx_mawa = MPX_MAWA_VALUE;
+		return 0;
+	}
+	return -EINVAL;
+}
+
+int mpx_enable_management(unsigned long bd_size)
 {
 	void __user *bd_base = MPX_INVALID_BOUNDS_DIR;
 	struct mm_struct *mm = current->mm;
@@ -358,10 +405,13 @@ int mpx_enable_management(void)
 	 */
 	bd_base = mpx_get_bounds_dir();
 	down_write(&mm->mmap_sem);
+	ret = mpx_set_mm_bd_size(bd_size);
+	if (ret)
+		goto out;
 	mm->context.bd_addr = bd_base;
 	if (mm->context.bd_addr == MPX_INVALID_BOUNDS_DIR)
 		ret = -ENXIO;
-
+out:
 	up_write(&mm->mmap_sem);
 	return ret;
 }
diff -puN arch/x86/mm/pgtable.c~mawa-040-prctl-set-mawa arch/x86/mm/pgtable.c
--- a/arch/x86/mm/pgtable.c~mawa-040-prctl-set-mawa	2017-01-26 14:31:33.569714885 -0800
+++ b/arch/x86/mm/pgtable.c	2017-01-26 14:31:33.575715154 -0800
@@ -85,7 +85,7 @@ void ___pud_free_tlb(struct mmu_gather *
 #if CONFIG_PGTABLE_LEVELS > 4
 void ___p4d_free_tlb(struct mmu_gather *tlb, p4d_t *p4d)
 {
-	paravirt_release_p4d(__pa(p4d) >> PAGE_SHIFT);
+	//paravirt_release_p4d(__pa(p4d) >> PAGE_SHIFT);
 	tlb_remove_page(tlb, virt_to_page(p4d));
 }
 #endif	/* CONFIG_PGTABLE_LEVELS > 4 */
diff -puN kernel/sys.c~mawa-040-prctl-set-mawa kernel/sys.c
--- a/kernel/sys.c~mawa-040-prctl-set-mawa	2017-01-26 14:31:33.571714974 -0800
+++ b/kernel/sys.c	2017-01-26 14:31:33.576715199 -0800
@@ -92,7 +92,7 @@
 # define SET_TSC_CTL(a)		(-EINVAL)
 #endif
 #ifndef MPX_ENABLE_MANAGEMENT
-# define MPX_ENABLE_MANAGEMENT()	(-EINVAL)
+# define MPX_ENABLE_MANAGEMENT(bd_size)	(-EINVAL)
 #endif
 #ifndef MPX_DISABLE_MANAGEMENT
 # define MPX_DISABLE_MANAGEMENT()	(-EINVAL)
@@ -2246,9 +2246,9 @@ SYSCALL_DEFINE5(prctl, int, option, unsi
 		up_write(&me->mm->mmap_sem);
 		break;
 	case PR_MPX_ENABLE_MANAGEMENT:
-		if (arg2 || arg3 || arg4 || arg5)
+		if (arg3 || arg4 || arg5)
 			return -EINVAL;
-		error = MPX_ENABLE_MANAGEMENT();
+		error = MPX_ENABLE_MANAGEMENT(arg2);
 		break;
 	case PR_MPX_DISABLE_MANAGEMENT:
 		if (arg2 || arg3 || arg4 || arg5)
_

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

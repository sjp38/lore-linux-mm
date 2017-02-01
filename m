Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id E3DA66B025E
	for <linux-mm@kvack.org>; Wed,  1 Feb 2017 18:24:13 -0500 (EST)
Received: by mail-pf0-f197.google.com with SMTP id c73so579982536pfb.7
        for <linux-mm@kvack.org>; Wed, 01 Feb 2017 15:24:13 -0800 (PST)
Received: from mga11.intel.com (mga11.intel.com. [192.55.52.93])
        by mx.google.com with ESMTPS id g21si15701007pgj.268.2017.02.01.15.24.12
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 01 Feb 2017 15:24:12 -0800 (PST)
Subject: [RFC][PATCH 3/7] x86, mpx: extend MPX prctl() to pass in size of bounds directory
From: Dave Hansen <dave.hansen@linux.intel.com>
Date: Wed, 01 Feb 2017 15:24:12 -0800
References: <20170201232408.FA486473@viggo.jf.intel.com>
In-Reply-To: <20170201232408.FA486473@viggo.jf.intel.com>
Message-Id: <20170201232412.BB0806BA@viggo.jf.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: linux-mm@kvack.org, x86@kernel.org, kirill.shutemov@linux.intel.com, Dave Hansen <dave.hansen@linux.intel.com>


The MPX bounds tables are indexed by virtual address.  A larger virtual
address space means that we need larger tables.  But, we need to ensure
that userspace and the kernel agree about the size of these tables.

To do this, we require that userspace passes in the size of the tables
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
This can be fixed once the in-kernel API for opting in/out is settled.

---

 b/arch/x86/include/asm/mpx.h       |    7 ++++
 b/arch/x86/include/asm/processor.h |    6 ++--
 b/arch/x86/mm/mpx.c                |   54 +++++++++++++++++++++++++++++++++++--
 b/kernel/sys.c                     |    6 ++--
 4 files changed, 65 insertions(+), 8 deletions(-)

diff -puN arch/x86/include/asm/mpx.h~mawa-040-prctl-set-mawa arch/x86/include/asm/mpx.h
--- a/arch/x86/include/asm/mpx.h~mawa-040-prctl-set-mawa	2017-02-01 15:12:16.570163322 -0800
+++ b/arch/x86/include/asm/mpx.h	2017-02-01 15:12:16.578163682 -0800
@@ -40,6 +40,13 @@
 #define MPX_BD_LEGACY_NR_ENTRIES_64	(1UL<<28)
 
 /*
+ * When the hardware "MAWA" feature is enabled, we have a larger
+ * bounds directory.  There are only two sizes supported: large
+ * and small, so we only need a single value here.
+ */
+#define MPX_LARGE_BOUNDS_DIR_SHIFT 9
+
+/*
  * The 32-bit directory is 4MB (2^22) in size, and with 4-byte
  * entries it has 2^20 entries.
  */
diff -puN arch/x86/include/asm/processor.h~mawa-040-prctl-set-mawa arch/x86/include/asm/processor.h
--- a/arch/x86/include/asm/processor.h~mawa-040-prctl-set-mawa	2017-02-01 15:12:16.572163412 -0800
+++ b/arch/x86/include/asm/processor.h	2017-02-01 15:12:16.579163727 -0800
@@ -874,14 +874,14 @@ extern int get_tsc_mode(unsigned long ad
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
--- a/arch/x86/mm/mpx.c~mawa-040-prctl-set-mawa	2017-02-01 15:12:16.573163457 -0800
+++ b/arch/x86/mm/mpx.c	2017-02-01 15:12:16.580163772 -0800
@@ -344,7 +344,54 @@ static __user void *mpx_get_bounds_dir(v
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
+		mm->context.mpx_bd_shift = 0;
+		return 0;
+	case MPX_BD_SIZE_BYTES_32:
+		/* 32-bit, legacy-sized bounds directory: */
+		if (is_64bit_mm(mm))
+			return -EINVAL;
+		mm->context.mpx_bd_shift = 0;
+		return 0;
+	case MPX_BD_BASE_SIZE_BYTES_64:
+		/* 64-bit, legacy-sized bounds directory: */
+		if (!is_64bit_mm(mm)
+		// FIXME && ! opted-in to larger address space
+		)
+			return -EINVAL;
+		mm->context.mpx_bd_shift = 0;
+		return 0;
+	case MPX_BD_BASE_SIZE_BYTES_64 << MPX_LARGE_BOUNDS_DIR_SHIFT:
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
+		mm->context.mpx_bd_shift = MPX_LARGE_BOUNDS_DIR_SHIFT;
+		return 0;
+	}
+	return -EINVAL;
+}
+
+int mpx_enable_management(unsigned long bd_size)
 {
 	void __user *bd_base = MPX_INVALID_BOUNDS_DIR;
 	struct mm_struct *mm = current->mm;
@@ -363,10 +410,13 @@ int mpx_enable_management(void)
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
diff -puN kernel/sys.c~mawa-040-prctl-set-mawa kernel/sys.c
--- a/kernel/sys.c~mawa-040-prctl-set-mawa	2017-02-01 15:12:16.575163547 -0800
+++ b/kernel/sys.c	2017-02-01 15:12:16.580163772 -0800
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

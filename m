Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f70.google.com (mail-pg0-f70.google.com [74.125.83.70])
	by kanga.kvack.org (Postfix) with ESMTP id 26D456B0261
	for <linux-mm@kvack.org>; Wed,  1 Feb 2017 18:24:18 -0500 (EST)
Received: by mail-pg0-f70.google.com with SMTP id 204so507072954pge.5
        for <linux-mm@kvack.org>; Wed, 01 Feb 2017 15:24:18 -0800 (PST)
Received: from mga06.intel.com (mga06.intel.com. [134.134.136.31])
        by mx.google.com with ESMTPS id v3si20485008plb.129.2017.02.01.15.24.16
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 01 Feb 2017 15:24:16 -0800 (PST)
Subject: [RFC][PATCH 5/7] x86, mpx: shrink per-mm MPX data
From: Dave Hansen <dave.hansen@linux.intel.com>
Date: Wed, 01 Feb 2017 15:24:14 -0800
References: <20170201232408.FA486473@viggo.jf.intel.com>
In-Reply-To: <20170201232408.FA486473@viggo.jf.intel.com>
Message-Id: <20170201232414.8D9B9BAC@viggo.jf.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: linux-mm@kvack.org, x86@kernel.org, kirill.shutemov@linux.intel.com, Dave Hansen <dave.hansen@linux.intel.com>


We have three pieces of data that we need to store about MPX's operation:
1. Is kernel management on/off?
2. If it's on, where is the bounds directory located?
3. If it's on, how big is the bounds directory?

We keep all this data in the mm_context_t.  Currently, #1 and #2
are stored in 'bd_addr' and #3 in 'mpx_bd_shift'.  But, the
address in 'bd_addr' must be page-aligned, so we have plenty of
space to share with things like 'mpx_bd_shift' which is a single
bit.

We rename the 'bd_addr' field to 'mpx_directory_info' since it
now has more than just the address, move the "invalid" value to a
single bit instead of -1 so it does not collide with the "large"
bit.

Note that these new bits _start_ at bit 2.  This is explained in
a comment too, but I started at bit 2 since the hardware register
(BNDCFGU) that stores a bounds directory pointer uses the two low
bits for other purposes.  Starting at bit 2 makes it much more
obvious that these bits mean very different things than the bits
in the register.

The rest of the patch is pretty mechanical.  the one exception is the
mpx_enable_management() code.  I wanted to keep it fairly tidy and
straightforward, but the logic behind mpx_set_dir_size() is pretty
messy.  It looks strange to be passing "&mm->context.mpx_directory_info"
around instead of just the mm or the mm->context, but considering the
context:

	/* Mask out the invalid bit: */
	mm->context.mpx_directory_info &= ~MPX_INVALID_BOUNDS_DIR;
	ret = mpx_set_dir_size(bd_size, &mm->context.mpx_directory_info);

I think it makes it a lot more obvious what is going on.

---

 b/arch/x86/include/asm/mmu.h |   10 +++++--
 b/arch/x86/include/asm/mpx.h |   44 +++++++++++++++++++++-------------
 b/arch/x86/mm/mpx.c          |   55 +++++++++++++++++++++++++------------------
 3 files changed, 66 insertions(+), 43 deletions(-)

diff -puN arch/x86/include/asm/mmu.h~mawa-060-onebit arch/x86/include/asm/mmu.h
--- a/arch/x86/include/asm/mmu.h~mawa-060-onebit	2017-02-01 15:12:17.598209567 -0800
+++ b/arch/x86/include/asm/mmu.h	2017-02-01 15:12:17.605209882 -0800
@@ -32,9 +32,13 @@ typedef struct {
 	s16 execute_only_pkey;
 #endif
 #ifdef CONFIG_X86_INTEL_MPX
-	/* address of the bounds directory */
-	void __user *bd_addr;
-	int mpx_bd_shift;
+	/*
+	 * The bounds directory must be page-aligned, so we store
+	 * its address in the high bits and information about its
+	 * size in some low bits.  A bit is also used to indicate
+	 * when the directory is invalid and MPX management is off.
+	 */
+	unsigned long mpx_directory_info;
 #endif
 } mm_context_t;
 
diff -puN arch/x86/include/asm/mpx.h~mawa-060-onebit arch/x86/include/asm/mpx.h
--- a/arch/x86/include/asm/mpx.h~mawa-060-onebit	2017-02-01 15:12:17.600209657 -0800
+++ b/arch/x86/include/asm/mpx.h	2017-02-01 15:12:17.605209882 -0800
@@ -6,10 +6,14 @@
 #include <asm/insn.h>
 
 /*
- * NULL is theoretically a valid place to put the bounds
- * directory, so point this at an invalid address.
+ * These get stored into mm_context_t->mpx_directory_info.
+ * We could theoretically use bits 0 and 1, but those are
+ * used in the BNDCFGU register that also holds the bounds
+ * directory pointer.  To avoid confusion, use different bits.
  */
-#define MPX_INVALID_BOUNDS_DIR	((void __user *)-1)
+#define MPX_INVALID_BOUNDS_DIR	(1UL<<2)
+#define MPX_LARGE_BOUNDS_DIR	(1UL<<3)
+
 #define MPX_BNDCFG_ENABLE_FLAG	0x1
 #define MPX_BD_ENTRY_VALID_FLAG	0x1
 
@@ -44,7 +48,7 @@
  * bounds directory.  There are only two sizes supported: large
  * and small, so we only need a single value here.
  */
-#define MPX_LARGE_BOUNDS_DIR_SHIFT 9
+#define MPX_LARGE_BOUNDS_DIR_SHIFT	9
 
 /*
  * The 32-bit directory is 4MB (2^22) in size, and with 4-byte
@@ -79,32 +83,38 @@
 #ifdef CONFIG_X86_INTEL_MPX
 siginfo_t *mpx_generate_siginfo(struct pt_regs *regs);
 int mpx_handle_bd_fault(void);
+static inline void __user *mpx_bounds_dir_addr(struct mm_struct *mm)
+{
+	/*
+	 * The only bit that can be set in a valid bounds
+	 * directory is MPX_LARGE_BOUNDS_DIR, so only mask
+	 * it back off.
+	 */
+	return (void __user *)
+		(mm->context.mpx_directory_info & ~MPX_LARGE_BOUNDS_DIR);
+}
 static inline int kernel_managing_mpx_tables(struct mm_struct *mm)
 {
-	return (mm->context.bd_addr != MPX_INVALID_BOUNDS_DIR);
+	return (mm->context.mpx_directory_info != MPX_INVALID_BOUNDS_DIR);
 }
 static inline void mpx_mm_init(struct mm_struct *mm)
 {
 	/*
-	 * NULL is theoretically a valid place to put the bounds
-	 * directory, so point this at an invalid address.
-	 */
-	mm->context.bd_addr = MPX_INVALID_BOUNDS_DIR;
-	/*
-	 * All processes start out in "legacy" MPX mode with
-	 * the old bounds directory size.  This corresponds to
-	 * what the specs call MAWA=0.
+	 * MPX starts out off (invalid) and with a legacy-size
+	 * bounds directory (cleared MPX_LARGE_BOUNDS_DIR bit).
 	 */
-	mm->context.mpx_bd_shift = 0;
+	mm->context.mpx_directory_info = MPX_INVALID_BOUNDS_DIR;
 }
 void mpx_notify_unmap(struct mm_struct *mm, struct vm_area_struct *vma,
 		      unsigned long start, unsigned long end);
-
 static inline int mpx_bd_size_shift(struct mm_struct *mm)
 {
-	return mm->context.mpx_bd_shift;
+	if (!kernel_managing_mpx_tables(mm))
+		return 0;
+	if (mm->context.mpx_directory_info & MPX_LARGE_BOUNDS_DIR)
+		return MPX_LARGE_BOUNDS_DIR_SHIFT;
+	return 0;
 }
-#else
 static inline siginfo_t *mpx_generate_siginfo(struct pt_regs *regs)
 {
 	return NULL;
diff -puN arch/x86/mm/mpx.c~mawa-060-onebit arch/x86/mm/mpx.c
--- a/arch/x86/mm/mpx.c~mawa-060-onebit	2017-02-01 15:12:17.602209747 -0800
+++ b/arch/x86/mm/mpx.c	2017-02-01 15:12:17.606209927 -0800
@@ -339,29 +339,31 @@ static __user void *mpx_get_bounds_dir(v
 		(bndcsr->bndcfgu & MPX_BNDCFG_ADDR_MASK);
 }
 
-int mpx_set_mm_bd_size(unsigned long bd_size)
+int mpx_set_dir_size(unsigned long bd_size, unsigned long *mpx_directory_info)
 {
 	struct mm_struct *mm = current->mm;
+	int ret = 0;
+	bool large_dir = false;
 
 	switch ((unsigned long long)bd_size) {
 	case 0:
-		/* Legacy call to prctl(): */
-		mm->context.mpx_bd_shift = 0;
-		return 0;
+		/* Legacy call to prctl() */
+		break;
 	case MPX_BD_SIZE_BYTES_32:
 		/* 32-bit, legacy-sized bounds directory: */
-		if (is_64bit_mm(mm))
-			return -EINVAL;
-		mm->context.mpx_bd_shift = 0;
-		return 0;
+		if (is_64bit_mm(mm)) {
+			ret = -EINVAL;
+			break;
+		}
+		ret = 0;
+		break;
 	case MPX_BD_BASE_SIZE_BYTES_64:
 		/* 64-bit, legacy-sized bounds directory: */
 		if (!is_64bit_mm(mm)
 		// FIXME && ! opted-in to larger address space
 		)
-			return -EINVAL;
-		mm->context.mpx_bd_shift = 0;
-		return 0;
+			ret = -EINVAL;
+		break;
 	case MPX_BD_BASE_SIZE_BYTES_64 << MPX_LARGE_BOUNDS_DIR_SHIFT:
 		/*
 		 * Non-legacy call, with larger directory.
@@ -370,7 +372,7 @@ int mpx_set_mm_bd_size(unsigned long bd_
 		 * change sizes.
 		 */
 		if (!is_64bit_mm(mm))
-			return -EINVAL;
+			ret = -EINVAL;
 		/*
 		 * Do not let this be enabled unles we are on
 		 * 5-level hardware *and* have that feature
@@ -379,16 +381,20 @@ int mpx_set_mm_bd_size(unsigned long bd_
 		if (!cpu_feature_enabled(X86_FEATURE_LA57)
 		// FIXME && opted into larger address space
 		)
-			return -EINVAL;
-		mm->context.mpx_bd_shift = MPX_LARGE_BOUNDS_DIR_SHIFT;
-		return 0;
+			ret = -EINVAL;
+		if (ret)
+			break;
+		large_dir = true;
+		break;
 	}
-	return -EINVAL;
+	if (large_dir)
+		(*mpx_directory_info) |= MPX_LARGE_BOUNDS_DIR;
+	return ret;
 }
 
 int mpx_enable_management(unsigned long bd_size)
 {
-	void __user *bd_base = MPX_INVALID_BOUNDS_DIR;
+	void __user *bd_base;
 	struct mm_struct *mm = current->mm;
 	int ret = 0;
 
@@ -404,13 +410,16 @@ int mpx_enable_management(unsigned long
 	 * unmap path; we can just use mm->context.bd_addr instead.
 	 */
 	bd_base = mpx_get_bounds_dir();
+	if (bd_base == MPX_INVALID_BOUNDS_DIR)
+		return -ENXIO;
+
 	down_write(&mm->mmap_sem);
-	ret = mpx_set_mm_bd_size(bd_size);
+	/* Mask out the invalid bit: */
+	mm->context.mpx_directory_info &= ~MPX_INVALID_BOUNDS_DIR;
+	ret = mpx_set_dir_size(bd_size, &mm->context.mpx_directory_info);
 	if (ret)
 		goto out;
-	mm->context.bd_addr = bd_base;
-	if (mm->context.bd_addr == MPX_INVALID_BOUNDS_DIR)
-		ret = -ENXIO;
+	mm->context.mpx_directory_info |= bd_base;
 out:
 	up_write(&mm->mmap_sem);
 	return ret;
@@ -424,7 +433,7 @@ int mpx_disable_management(void)
 		return -ENXIO;
 
 	down_write(&mm->mmap_sem);
-	mm->context.bd_addr = MPX_INVALID_BOUNDS_DIR;
+	mm->context.mpx_directory_info = MPX_INVALID_BOUNDS_DIR;
 	up_write(&mm->mmap_sem);
 	return 0;
 }
@@ -1006,7 +1015,7 @@ static int try_unmap_single_bt(struct mm
 		end = bta_end_vaddr;
 	}
 
-	bde_vaddr = mm->context.bd_addr + mpx_get_bd_entry_offset(mm, start);
+	bde_vaddr = mpx_bounds_dir_addr(mm) + mpx_get_bd_entry_offset(mm, start);
 	ret = get_bt_addr(mm, bde_vaddr, &bt_addr);
 	/*
 	 * No bounds table there, so nothing to unmap.
_

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

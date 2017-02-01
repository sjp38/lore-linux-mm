Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id 3D1F36B0253
	for <linux-mm@kvack.org>; Wed,  1 Feb 2017 18:24:13 -0500 (EST)
Received: by mail-pf0-f198.google.com with SMTP id d123so325640885pfd.0
        for <linux-mm@kvack.org>; Wed, 01 Feb 2017 15:24:13 -0800 (PST)
Received: from mga11.intel.com (mga11.intel.com. [192.55.52.93])
        by mx.google.com with ESMTPS id g21si15701007pgj.268.2017.02.01.15.24.12
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 01 Feb 2017 15:24:12 -0800 (PST)
Subject: [RFC][PATCH 2/7] x86, mpx: update MPX to grok larger bounds tables
From: Dave Hansen <dave.hansen@linux.intel.com>
Date: Wed, 01 Feb 2017 15:24:11 -0800
References: <20170201232408.FA486473@viggo.jf.intel.com>
In-Reply-To: <20170201232408.FA486473@viggo.jf.intel.com>
Message-Id: <20170201232411.4B6B4220@viggo.jf.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: linux-mm@kvack.org, x86@kernel.org, kirill.shutemov@linux.intel.com, Dave Hansen <dave.hansen@linux.intel.com>


The MPX code in the kernel needs to walk these tables in order to
populate them on demand as well as unmap them when memory is
freed.  A larger virtual address space means larger MPX bounds
tables.

Update the bounds table walking code to understand how to walk
the larger table size.  We use the new per-mm "mpx_bd_shift"
value to determine which format to use.

The mpx_bd_size_shift() function looks like a useless abstraction
here.  But, the new 'mpx_bd_shift' field will get packed into a
single bit in 'bd_addr' later.  Keep the abstraction in place now
to make the series simpler and make it more obvious when the
complexity comes from the packing rather than the actual data
etself.

---

 b/arch/x86/include/asm/mpx.h |   27 +++++++++++++++++++++------
 b/arch/x86/mm/mpx.c          |   30 ++++++++++++++++++++++--------
 2 files changed, 43 insertions(+), 14 deletions(-)

diff -puN arch/x86/include/asm/mpx.h~mawa-030-bounds-directory-sizes arch/x86/include/asm/mpx.h
--- a/arch/x86/include/asm/mpx.h~mawa-030-bounds-directory-sizes	2017-02-01 15:12:16.114142809 -0800
+++ b/arch/x86/include/asm/mpx.h	2017-02-01 15:12:16.119143034 -0800
@@ -14,15 +14,30 @@
 #define MPX_BD_ENTRY_VALID_FLAG	0x1
 
 /*
- * The upper 28 bits [47:20] of the virtual address in 64-bit
- * are used to index into bounds directory (BD).
+ * The uppermost bits [56:20] of the virtual address in 64-bit
+ * are used to index into bounds directory (BD).  On processors
+ * with support for smaller virtual address space size, the "56"
+ * is obviously smaller.
  *
- * The directory is 2G (2^31) in size, and with 8-byte entries
- * it has 2^28 entries.
+ * When using 47-bit virtual addresses, the directory is 2G
+ * (2^31) bytes in size, and with 8-byte entries it has 2^28
+ * entries.  With 56-bit virtual addresses, it goes to 1T in size
+ * and has 2^37 entries.
+ *
+ * Needs to be ULL so we can use this in 32-bit kernels without
+ * warnings.
  */
-#define MPX_BD_SIZE_BYTES_64	(1UL<<31)
+#define MPX_BD_BASE_SIZE_BYTES_64	(1ULL<<31)
 #define MPX_BD_ENTRY_BYTES_64	8
-#define MPX_BD_NR_ENTRIES_64	(MPX_BD_SIZE_BYTES_64/MPX_BD_ENTRY_BYTES_64)
+/*
+ * Note: size of tables on 64-bit is not constant, so we have no
+ * fixed definition for MPX_BD_NR_ENTRIES_64.
+ *
+ * The 5-Level Paging Whitepaper says:  "A bound directory
+ * comprises 2^(28+MAWA) 64-bit entries."  Since MAWA=0 in
+ * legacy mode:
+ */
+#define MPX_BD_LEGACY_NR_ENTRIES_64	(1UL<<28)
 
 /*
  * The 32-bit directory is 4MB (2^22) in size, and with 4-byte
diff -puN arch/x86/mm/mpx.c~mawa-030-bounds-directory-sizes arch/x86/mm/mpx.c
--- a/arch/x86/mm/mpx.c~mawa-030-bounds-directory-sizes	2017-02-01 15:12:16.115142854 -0800
+++ b/arch/x86/mm/mpx.c	2017-02-01 15:12:16.119143034 -0800
@@ -20,12 +20,21 @@
 #define CREATE_TRACE_POINTS
 #include <asm/trace/mpx.h>
 
+static inline int mpx_bd_size_shift(struct mm_struct *mm)
+{
+	return mm->context.mpx_bd_shift;
+}
+
 static inline unsigned long mpx_bd_size_bytes(struct mm_struct *mm)
 {
-	if (is_64bit_mm(mm))
-		return MPX_BD_SIZE_BYTES_64;
-	else
+	if (!is_64bit_mm(mm))
 		return MPX_BD_SIZE_BYTES_32;
+
+	/*
+	 * The bounds directory grows with the address space size.
+	 * The "legacy" shift is 0.
+	 */
+	return MPX_BD_BASE_SIZE_BYTES_64 << mpx_bd_shift_shift(mm);
 }
 
 static inline unsigned long mpx_bt_size_bytes(struct mm_struct *mm)
@@ -724,6 +733,7 @@ static inline unsigned long bd_entry_vir
 {
 	unsigned long long virt_space;
 	unsigned long long GB = (1ULL << 30);
+	unsigned long legacy_64bit_vaddr_bits = 48;
 
 	/*
 	 * This covers 32-bit emulation as well as 32-bit kernels
@@ -733,12 +743,16 @@ static inline unsigned long bd_entry_vir
 		return (4ULL * GB) / MPX_BD_NR_ENTRIES_32;
 
 	/*
-	 * 'x86_virt_bits' returns what the hardware is capable
-	 * of, and returns the full >32-bit address space when
-	 * running 32-bit kernels on 64-bit hardware.
+	 * With 5-level paging, the virtual address space size
+	 * gets bigger.  A bounds directory entry still points to
+	 * a single bounds table and the *tables* stay the same
+	 * size.  Thus, the address space that a directory entry
+	 * covers does not change based on the paging mode or the
+	 * size of the bounds directory itself.  Just use the
+	 * legacy size.
 	 */
-	virt_space = (1ULL << boot_cpu_data.x86_virt_bits);
-	return virt_space / MPX_BD_NR_ENTRIES_64;
+	virt_space = (1ULL << legacy_64bit_vaddr_bits);
+	return virt_space / MPX_BD_LEGACY_NR_ENTRIES_64;
 }
 
 /*
_

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

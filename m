Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f71.google.com (mail-pg0-f71.google.com [74.125.83.71])
	by kanga.kvack.org (Postfix) with ESMTP id 300EC6B0253
	for <linux-mm@kvack.org>; Thu, 26 Jan 2017 17:40:10 -0500 (EST)
Received: by mail-pg0-f71.google.com with SMTP id d185so327888068pgc.2
        for <linux-mm@kvack.org>; Thu, 26 Jan 2017 14:40:10 -0800 (PST)
Received: from mga03.intel.com (mga03.intel.com. [134.134.136.65])
        by mx.google.com with ESMTPS id w127si489546pgb.313.2017.01.26.14.40.09
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 26 Jan 2017 14:40:09 -0800 (PST)
Subject: [RFC][PATCH 2/4] x86, mpx: update MPX to grok larger bounds tables
From: Dave Hansen <dave.hansen@linux.intel.com>
Date: Thu, 26 Jan 2017 14:40:07 -0800
References: <20170126224005.A6BBEF2C@viggo.jf.intel.com>
In-Reply-To: <20170126224005.A6BBEF2C@viggo.jf.intel.com>
Message-Id: <20170126224007.3E06536B@viggo.jf.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: linux-mm@kvack.org, x86@kernel.org, Dave Hansen <dave.hansen@linux.intel.com>


As mentioned repeatedly, larger address spaces mean larger MPX bounds
tables.  The MPX code in the kernel needs to walk these tables in order
to populate them on demand as well as unmap them when memory is freed.

This updates the bounds table walking code to understand how to walk
the larger table size.  It uses the new per-mm "MAWA" value to determine
which format to use.

---

 b/arch/x86/include/asm/mpx.h |   27 +++++++++++++++++++++------
 b/arch/x86/mm/mpx.c          |   25 +++++++++++++++++--------
 2 files changed, 38 insertions(+), 14 deletions(-)

diff -puN arch/x86/include/asm/mpx.h~mawa-030-bounds-directory-sizes arch/x86/include/asm/mpx.h
--- a/arch/x86/include/asm/mpx.h~mawa-030-bounds-directory-sizes	2017-01-26 14:31:33.098693731 -0800
+++ b/arch/x86/include/asm/mpx.h	2017-01-26 14:31:33.103693956 -0800
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
+ * The 5-Level Paging Whitepaper says:
+ * A bound directory comprises 2^(28+MAWA) 64-bit entries.
+ * MAWA=0 in the legacy mode, so:
+ */
+#define MPX_BD_LEGACY_NR_ENTRIES_64	(1UL<<28)
 
 /*
  * The 32-bit directory is 4MB (2^22) in size, and with 4-byte
diff -puN arch/x86/mm/mpx.c~mawa-030-bounds-directory-sizes arch/x86/mm/mpx.c
--- a/arch/x86/mm/mpx.c~mawa-030-bounds-directory-sizes	2017-01-26 14:31:33.099693776 -0800
+++ b/arch/x86/mm/mpx.c	2017-01-26 14:31:33.103693956 -0800
@@ -22,10 +22,14 @@
 
 static inline unsigned long mpx_bd_size_bytes(struct mm_struct *mm)
 {
-	if (is_64bit_mm(mm))
-		return MPX_BD_SIZE_BYTES_64;
-	else
+	if (!is_64bit_mm(mm))
 		return MPX_BD_SIZE_BYTES_32;
+
+	/*
+	 * The bounds directory grows with the MAWA value.  The
+	 * "legacy" shift is 0.
+	 */
+	return MPX_BD_BASE_SIZE_BYTES_64 << mpx_mawa_shift(mm);
 }
 
 static inline unsigned long mpx_bt_size_bytes(struct mm_struct *mm)
@@ -724,6 +728,7 @@ static inline unsigned long bd_entry_vir
 {
 	unsigned long long virt_space;
 	unsigned long long GB = (1ULL << 30);
+	unsigned long legacy_64bit_vaddr_bits = 48;
 
 	/*
 	 * This covers 32-bit emulation as well as 32-bit kernels
@@ -733,12 +738,16 @@ static inline unsigned long bd_entry_vir
 		return (4ULL * GB) / MPX_BD_NR_ENTRIES_32;
 
 	/*
-	 * 'x86_virt_bits' returns what the hardware is capable
-	 * of, and returns the full >32-bit address space when
-	 * running 32-bit kernels on 64-bit hardware.
+	 * With 5-level paging, the virtual address space size
+	 * gets bigger.  A bounds directory entry still points to
+	 * a single bounds table and the *tables* stay the same
+	 * size.  Thus, the address space that a directory entry
+	 * covers does not change based on the paging mode (or
+	 * MAWA value).  Just use the legacy calculation despite
+	 * the MAWA mode.
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

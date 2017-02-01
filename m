Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f69.google.com (mail-pg0-f69.google.com [74.125.83.69])
	by kanga.kvack.org (Postfix) with ESMTP id 08E056B0268
	for <linux-mm@kvack.org>; Wed,  1 Feb 2017 18:24:20 -0500 (EST)
Received: by mail-pg0-f69.google.com with SMTP id 194so504947966pgd.7
        for <linux-mm@kvack.org>; Wed, 01 Feb 2017 15:24:20 -0800 (PST)
Received: from mga04.intel.com (mga04.intel.com. [192.55.52.120])
        by mx.google.com with ESMTPS id k73si15714848pge.47.2017.02.01.15.24.18
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 01 Feb 2017 15:24:18 -0800 (PST)
Subject: [RFC][PATCH 7/7] x86, mpx: update MPX selftest to test larger bounds dir
From: Dave Hansen <dave.hansen@linux.intel.com>
Date: Wed, 01 Feb 2017 15:24:18 -0800
References: <20170201232408.FA486473@viggo.jf.intel.com>
In-Reply-To: <20170201232408.FA486473@viggo.jf.intel.com>
Message-Id: <20170201232418.BEE04481@viggo.jf.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: linux-mm@kvack.org, x86@kernel.org, kirill.shutemov@linux.intel.com, Dave Hansen <dave.hansen@linux.intel.com>


Since the bounds directory is changing its size, we also need to
update userspace to allocate a larger one.

This adds support to the MPX selftests to detect hardware where
we need a larger bounds directory and attempts to enable MPX
support for the larger directory.

The messiest thing here is that the hardware will not claim to
*have* a larger bounds directory until after we've enabled MPX.
But, that's after we needed to have allocated the bounds
directory.  In other words, we can't use the hardware's bounds
table size enumeration (MAWA) to tell us how large the directory
should be.

---

 b/tools/testing/selftests/x86/mpx-hw.h        |   23 +++
 b/tools/testing/selftests/x86/mpx-mini-test.c |  154 ++++++++++++++++++++------
 2 files changed, 140 insertions(+), 37 deletions(-)

diff -puN tools/testing/selftests/x86/mpx-hw.h~mawa-070-mpx-selftests tools/testing/selftests/x86/mpx-hw.h
--- a/tools/testing/selftests/x86/mpx-hw.h~mawa-070-mpx-selftests	2017-02-01 15:12:18.512250684 -0800
+++ b/tools/testing/selftests/x86/mpx-hw.h	2017-02-01 15:12:18.518250953 -0800
@@ -32,7 +32,8 @@
 #define MPX_BOUNDS_TABLE_ENTRY_SIZE_BYTES	32
 #define MPX_BOUNDS_TABLE_SIZE_BYTES		(1ULL << 22) /* 4MB */
 #define MPX_BOUNDS_DIR_ENTRY_SIZE_BYTES		8
-#define MPX_BOUNDS_DIR_SIZE_BYTES		(1ULL << 31) /* 2GB */
+#define MPX_LEGACY_BOUNDS_DIR_SIZE_BYTES	(1ULL << 31) /* 2GB */
+#define MPX_LA57_BOUNDS_DIR_SIZE_BYTES		(1ULL << 40) /* 1TB */
 
 #define MPX_BOUNDS_TABLE_BOTTOM_BIT		3
 #define MPX_BOUNDS_TABLE_TOP_BIT		19
@@ -41,8 +42,23 @@
 
 #endif
 
+/* What size should we allocate for the bounds directory? */
+extern unsigned long long mpx_bounds_dir_alloc_size_bytes(void);
+/*
+ * How large is the hardware currently expecting the bounds
+ * directory to be?
+ *
+ * Note: We have to *tell* the hardware when we want it to use
+ * a larger bounds directory.  Until that point, this will
+ * return the smaller "legacy" value.  But, we *allocate* the
+ * directory before well tell the hardware what size we want
+ * it to be.  So, we need to separate the concepts and have two
+ * different functions.
+ */
+extern unsigned long long mpx_bounds_dir_hw_size_bytes(void);
+
 #define MPX_BOUNDS_DIR_NR_ENTRIES	\
-	(MPX_BOUNDS_DIR_SIZE_BYTES/MPX_BOUNDS_DIR_ENTRY_SIZE_BYTES)
+	(mpx_bounds_dir_hw_size_bytes()/MPX_BOUNDS_DIR_ENTRY_SIZE_BYTES)
 #define MPX_BOUNDS_TABLE_NR_ENTRIES	\
 	(MPX_BOUNDS_TABLE_SIZE_BYTES/MPX_BOUNDS_TABLE_ENTRY_SIZE_BYTES)
 
@@ -63,7 +79,8 @@ struct mpx_bt_entry {
 } __attribute__((packed));
 
 struct mpx_bounds_dir {
-	struct mpx_bd_entry entries[MPX_BOUNDS_DIR_NR_ENTRIES];
+	/* This is a variable size array: */
+	struct mpx_bd_entry entries[0];
 } __attribute__((packed));
 
 struct mpx_bounds_table {
diff -puN tools/testing/selftests/x86/mpx-mini-test.c~mawa-070-mpx-selftests tools/testing/selftests/x86/mpx-mini-test.c
--- a/tools/testing/selftests/x86/mpx-mini-test.c~mawa-070-mpx-selftests	2017-02-01 15:12:18.514250773 -0800
+++ b/tools/testing/selftests/x86/mpx-mini-test.c	2017-02-01 15:12:18.518250953 -0800
@@ -462,6 +462,72 @@ static inline void cpuid_count(unsigned
 }
 
 #define XSTATE_CPUID	    0x0000000d
+#define CPUID_MAWA_LEAF	    0x00000007
+#define CPUID_MAWA_SUBLEAF  0x00000000
+#define CPUID_MAWA_BOTTOM_BIT	17
+#define CPUID_MAWA_TOP_BIT	21
+
+/*
+ * On CPUs supporting 5-level paging with a larger virtual address
+ * space, the bounds directory is also larger.  The mechanism to
+ * grow the bounds directory is called "MPX Address-Width Adjust"
+ * (MAWA) and its presence is enumerated via CPUID.
+ */
+static inline int bd_size_shift(void)
+{
+	unsigned int eax, ebx, ecx, edx;
+	unsigned int shift;
+
+	cpuid_count(CPUID_MAWA_LEAF, CPUID_MAWA_SUBLEAF,
+			&eax, &ebx, &ecx, &edx);
+
+	shift = ecx;
+	shift >>= CPUID_MAWA_BOTTOM_BIT;
+	shift &= (1U << (CPUID_MAWA_TOP_BIT - CPUID_MAWA_BOTTOM_BIT)) - 1;
+
+	return shift;
+}
+
+#define CPUID_LA57_LEAF		0x00000007
+#define CPUID_LA57_SUBLEAF	0x00000000
+#define CPUID_LA57_ECX_MASK	(1UL << 16)
+
+/* Intel-defined CPU features, CPUID level 0x00000007:0 (ecx) */
+static inline int cpu_supports_lax(void)
+{
+	unsigned int eax, ebx, ecx, edx;
+
+	cpuid_count(CPUID_LA57_LEAF, CPUID_LA57_SUBLEAF,
+			&eax, &ebx, &ecx, &edx);
+
+	return !!(ecx & CPUID_LA57_ECX_MASK);
+}
+
+unsigned long long mpx_bounds_dir_hw_size_bytes(void)
+{
+#ifdef __i386__
+	/* 32-bit has a fixed size directory: */
+	return MPX_BOUNDS_DIR_SIZE_BYTES;
+#else
+	/*
+	 * 64-bit depends on what mode the hardware is in.
+	 * Are we in LA57 mode, and has the kernel set up
+	 * the "MAWA" MSR for us?
+	 */
+	return MPX_LEGACY_BOUNDS_DIR_SIZE_BYTES << bd_size_shift();
+#endif
+}
+
+unsigned long long mpx_bounds_dir_alloc_size_bytes(void)
+{
+#ifdef __i386__
+	return mpx_bounds_dir_hw_size_bytes();
+#else
+	if (cpu_supports_lax())
+		return MPX_LA57_BOUNDS_DIR_SIZE_BYTES;
+	return MPX_LEGACY_BOUNDS_DIR_SIZE_BYTES;
+#endif
+}
 
 /*
  * List of XSAVE features Linux knows about:
@@ -601,7 +667,8 @@ struct mpx_bounds_dir *bounds_dir_ptr;
 
 unsigned long __bd_incore(const char *func, int line)
 {
-	unsigned long ret = nr_incore(bounds_dir_ptr, MPX_BOUNDS_DIR_SIZE_BYTES);
+	unsigned long ret = nr_incore(bounds_dir_ptr,
+				      mpx_bounds_dir_hw_size_bytes());
 	return ret;
 }
 #define bd_incore() __bd_incore(__func__, __LINE__)
@@ -624,43 +691,50 @@ void check_clear_bd(void)
 	check_clear(bounds_dir_ptr, 2UL << 30);
 }
 
-#define USE_MALLOC_FOR_BOUNDS_DIR 1
-bool process_specific_init(void)
+void *alloc_bounds_directory(unsigned long long size)
 {
-	unsigned long size;
-	unsigned long *dir;
+	/*
+	 * This can make debugging easier because the
+	 * address calculations are simpler:
+	 */
+	void *hint_addr = NULL; //0x200000000000;
 	/* Guarantee we have the space to align it, add padding: */
 	unsigned long pad = getpagesize();
+	unsigned long *dir;
+	int flags;
 
-	size = 2UL << 30; /* 2GB */
-	if (sizeof(unsigned long) == 4)
-		size = 4UL << 20; /* 4MB */
-	dprintf1("trying to allocate %ld MB bounds directory\n", (size >> 20));
-
-	if (USE_MALLOC_FOR_BOUNDS_DIR) {
-		unsigned long _dir;
-
-		dir = malloc(size + pad);
-		assert(dir);
-		_dir = (unsigned long)dir;
-		_dir += 0xfffUL;
-		_dir &= ~0xfffUL;
-		dir = (void *)_dir;
-	} else {
-		/*
-		 * This makes debugging easier because the address
-		 * calculations are simpler:
-		 */
-		dir = mmap((void *)0x200000000000, size + pad,
-				PROT_READ|PROT_WRITE,
-				MAP_ANONYMOUS|MAP_PRIVATE, -1, 0);
-		if (dir == (void *)-1) {
-			perror("unable to allocate bounds directory");
-			abort();
-		}
-		check_clear(dir, size);
+	/*
+	 * The bounds directory can be very large and cause us
+	 * to exceed overcommit limits.  Use MAP_NORESERVE to
+	 * avoid the overcommit limits.
+	 */
+	flags = MAP_ANONYMOUS | MAP_PRIVATE | MAP_NORESERVE;
+	dir = mmap(hint_addr, size + pad , PROT_READ|PROT_WRITE, flags, -1, 0);
+	if (dir == (void *)-1) {
+		perror("unable to allocate bounds directory");
+		abort();
 	}
-	bounds_dir_ptr = (void *)dir;
+	check_clear(dir, size);
+	return dir;
+}
+
+#define USE_MALLOC_FOR_BOUNDS_DIR 0
+bool process_specific_init(void)
+{
+	unsigned long long size;
+	unsigned long *dir;
+	int err;
+
+	size = mpx_bounds_dir_alloc_size_bytes();
+	dprintf1("trying to allocate %lld MB bounds directory\n", (size >> 20));
+
+	dir = alloc_bounds_directory(size);
+	/*
+	 * The directory is a large anonymous allocation, so it
+	 * looks like an ideal place to use transparent large pages.
+	 * But, in practice, it's usually sparsely populated and
+	 * will waste lots of memory.  Turn THP off:
+	 */
 	madvise(bounds_dir_ptr, size, MADV_NOHUGEPAGE);
 	bd_incore();
 	dprintf1("bounds directory: 0x%p -> 0x%p\n", bounds_dir_ptr,
@@ -668,7 +742,19 @@ bool process_specific_init(void)
 	check_clear(dir, size);
 	enable_mpx(dir);
 	check_clear(dir, size);
-	if (prctl(PR_MPX_ENABLE_MANAGEMENT, 0, 0, 0, 0)) {
+
+	/* Try to tell newer kernels the size of the directory: */
+	err = prctl(PR_MPX_ENABLE_MANAGEMENT, size, 0, 0, 0);
+	/*
+	 * But also handle older kernels that need argument 2 to be 0.
+	 * If the hardware supports larger bounds directories, we
+	 * allocated a large one in anticipation of needing it. But,
+	 * the kernel does not support it, so will use only a
+	 * small portion (1/512th) of it in these tests.
+	 */
+	if (err)
+		err = prctl(PR_MPX_ENABLE_MANAGEMENT, 0, 0, 0, 0);
+	if (err) {
 		printf("no MPX support\n");
 		abort();
 		return false;
_

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

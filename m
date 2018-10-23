Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lj1-f198.google.com (mail-lj1-f198.google.com [209.85.208.198])
	by kanga.kvack.org (Postfix) with ESMTP id 3C8CA6B000A
	for <linux-mm@kvack.org>; Tue, 23 Oct 2018 17:36:09 -0400 (EDT)
Received: by mail-lj1-f198.google.com with SMTP id m10-v6so142744ljj.8
        for <linux-mm@kvack.org>; Tue, 23 Oct 2018 14:36:09 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id d4-v6sor951213lfb.56.2018.10.23.14.36.06
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 23 Oct 2018 14:36:06 -0700 (PDT)
From: Igor Stoppa <igor.stoppa@gmail.com>
Subject: [PATCH 06/17] prmem: test cases for memory protection
Date: Wed, 24 Oct 2018 00:34:53 +0300
Message-Id: <20181023213504.28905-7-igor.stoppa@huawei.com>
In-Reply-To: <20181023213504.28905-1-igor.stoppa@huawei.com>
References: <20181023213504.28905-1-igor.stoppa@huawei.com>
Reply-To: Igor Stoppa <igor.stoppa@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mimi Zohar <zohar@linux.vnet.ibm.com>, Kees Cook <keescook@chromium.org>, Matthew Wilcox <willy@infradead.org>, Dave Chinner <david@fromorbit.com>, James Morris <jmorris@namei.org>, Michal Hocko <mhocko@kernel.org>, kernel-hardening@lists.openwall.com, linux-integrity@vger.kernel.org, linux-security-module@vger.kernel.org
Cc: igor.stoppa@huawei.com, Dave Hansen <dave.hansen@linux.intel.com>, Jonathan Corbet <corbet@lwn.net>, Laura Abbott <labbott@redhat.com>, Vlastimil Babka <vbabka@suse.cz>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Andrew Morton <akpm@linux-foundation.org>, Pavel Tatashin <pasha.tatashin@oracle.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

The test cases verify the various interfaces offered by both prmem.h and
prmemextra.h

The tests avoid triggering crashes, by not performing actions that would
be treated as illegal. That part is handled in the lkdtm patch.

Signed-off-by: Igor Stoppa <igor.stoppa@huawei.com>
CC: Michal Hocko <mhocko@kernel.org>
CC: Vlastimil Babka <vbabka@suse.cz>
CC: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
CC: Andrew Morton <akpm@linux-foundation.org>
CC: Pavel Tatashin <pasha.tatashin@oracle.com>
CC: linux-mm@kvack.org
CC: linux-kernel@vger.kernel.org
---
 MAINTAINERS          |   2 +
 mm/Kconfig.debug     |   9 +
 mm/Makefile          |   1 +
 mm/test_pmalloc.c    | 633 +++++++++++++++++++++++++++++++++++++++++++
 mm/test_write_rare.c | 236 ++++++++++++++++
 5 files changed, 881 insertions(+)
 create mode 100644 mm/test_pmalloc.c
 create mode 100644 mm/test_write_rare.c

diff --git a/MAINTAINERS b/MAINTAINERS
index df7221eca160..ea979a5a9ec9 100644
--- a/MAINTAINERS
+++ b/MAINTAINERS
@@ -9461,6 +9461,8 @@ S:	Maintained
 F:	include/linux/prmem.h
 F:	include/linux/prmemextra.h
 F:	mm/prmem.c
+F:	mm/test_write_rare.c
+F:	mm/test_pmalloc.c
 
 MEMORY MANAGEMENT
 L:	linux-mm@kvack.org
diff --git a/mm/Kconfig.debug b/mm/Kconfig.debug
index 9a7b8b049d04..57de5b3c0bae 100644
--- a/mm/Kconfig.debug
+++ b/mm/Kconfig.debug
@@ -94,3 +94,12 @@ config DEBUG_RODATA_TEST
     depends on STRICT_KERNEL_RWX
     ---help---
       This option enables a testcase for the setting rodata read-only.
+
+config DEBUG_PRMEM_TEST
+    tristate "Run self test for protected memory"
+    depends on STRICT_KERNEL_RWX
+    select PRMEM
+    default n
+    help
+      Tries to verify that the memory protection works correctly and that
+      the memory is effectively protected.
diff --git a/mm/Makefile b/mm/Makefile
index 215c6a6d7304..93b503d4659f 100644
--- a/mm/Makefile
+++ b/mm/Makefile
@@ -65,6 +65,7 @@ obj-$(CONFIG_SPARSEMEM_VMEMMAP) += sparse-vmemmap.o
 obj-$(CONFIG_SLOB) += slob.o
 obj-$(CONFIG_MMU_NOTIFIER) += mmu_notifier.o
 obj-$(CONFIG_PRMEM) += prmem.o
+obj-$(CONFIG_DEBUG_PRMEM_TEST) += test_write_rare.o test_pmalloc.o
 obj-$(CONFIG_KSM) += ksm.o
 obj-$(CONFIG_PAGE_POISONING) += page_poison.o
 obj-$(CONFIG_SLAB) += slab.o
diff --git a/mm/test_pmalloc.c b/mm/test_pmalloc.c
new file mode 100644
index 000000000000..f9ee8fb29eea
--- /dev/null
+++ b/mm/test_pmalloc.c
@@ -0,0 +1,633 @@
+// SPDX-License-Identifier: GPL-2.0
+/*
+ * test_pmalloc.c
+ *
+ * (C) Copyright 2018 Huawei Technologies Co. Ltd.
+ * Author: Igor Stoppa <igor.stoppa@huawei.com>
+ */
+
+#include <linux/init.h>
+#include <linux/module.h>
+#include <linux/mm.h>
+#include <linux/string.h>
+#include <linux/bug.h>
+#include <linux/prmemextra.h>
+
+#ifdef pr_fmt
+#undef pr_fmt
+#endif
+
+#define pr_fmt(fmt) KBUILD_MODNAME ": " fmt
+
+#define SIZE_1 (PAGE_SIZE * 3)
+#define SIZE_2 1000
+
+static const char MSG_NO_POOL[] = "Cannot allocate memory for the pool.";
+static const char MSG_NO_PMEM[] = "Cannot allocate memory from the pool.";
+
+#define pr_success(test_name)	\
+	pr_info(test_name " test passed")
+
+/* --------------- tests the basic life-cycle of a pool --------------- */
+
+static bool is_address_protected(void *p)
+{
+	struct page *page;
+	struct vmap_area *area;
+
+	if (unlikely(!is_vmalloc_addr(p)))
+		return false;
+	page = vmalloc_to_page(p);
+	if (unlikely(!page))
+		return false;
+	wmb(); /* Flush changes to the page table - is it needed? */
+	area = find_vmap_area((uintptr_t)p);
+	if (unlikely((!area) || (!area->vm) ||
+		     ((area->vm->flags & VM_PMALLOC_PROTECTED_MASK) !=
+		      VM_PMALLOC_PROTECTED_MASK)))
+		return false;
+	return true;
+}
+
+static bool create_and_destroy_pool(void)
+{
+	static struct pmalloc_pool *pool;
+
+	pool = pmalloc_create_pool(PMALLOC_MODE_RO);
+	if (WARN(!pool, MSG_NO_POOL))
+		return false;
+	pmalloc_destroy_pool(pool);
+	pr_success("pool creation and destruction");
+	return true;
+}
+
+/*  verifies that it's possible to allocate from the pool */
+static bool test_alloc(void)
+{
+	static struct pmalloc_pool *pool;
+	static void *p;
+
+	pool = pmalloc_create_pool(PMALLOC_MODE_RO);
+	if (WARN(!pool, MSG_NO_POOL))
+		return false;
+	p = pmalloc(pool,  SIZE_1 - 1);
+	pmalloc_destroy_pool(pool);
+	if (WARN(!p, MSG_NO_PMEM))
+		return false;
+	pr_success("allocation capability");
+	return true;
+}
+
+/* ----------------------- tests self protection ----------------------- */
+
+static bool test_auto_ro(void)
+{
+	struct pmalloc_pool *pool;
+	int *first_chunk;
+	int *second_chunk;
+	bool retval = false;
+
+	pool = pmalloc_create_pool(PMALLOC_MODE_AUTO_RO);
+	if (WARN(!pool, MSG_NO_POOL))
+		return false;
+	first_chunk = (int *)pmalloc(pool, PMALLOC_DEFAULT_REFILL_SIZE);
+	if (WARN(!first_chunk, MSG_NO_PMEM))
+		goto error;
+	second_chunk = (int *)pmalloc(pool, PMALLOC_DEFAULT_REFILL_SIZE);
+	if (WARN(!second_chunk, MSG_NO_PMEM))
+		goto error;
+	if (WARN(!is_address_protected(first_chunk),
+		 "Failed to automatically write protect exhausted vmarea"))
+		goto error;
+	pr_success("AUTO_RO");
+	retval = true;
+error:
+	pmalloc_destroy_pool(pool);
+	return retval;
+}
+
+static bool test_auto_wr(void)
+{
+	struct pmalloc_pool *pool;
+	int *first_chunk;
+	int *second_chunk;
+	bool retval = false;
+
+	pool = pmalloc_create_pool(PMALLOC_MODE_AUTO_WR);
+	if (WARN(!pool, MSG_NO_POOL))
+		return false;
+	first_chunk = (int *)pmalloc(pool, PMALLOC_DEFAULT_REFILL_SIZE);
+	if (WARN(!first_chunk, MSG_NO_PMEM))
+		goto error;
+	second_chunk = (int *)pmalloc(pool, PMALLOC_DEFAULT_REFILL_SIZE);
+	if (WARN(!second_chunk, MSG_NO_PMEM))
+		goto error;
+	if (WARN(!is_address_protected(first_chunk),
+		 "Failed to automatically write protect exhausted vmarea"))
+		goto error;
+	pr_success("AUTO_WR");
+	retval = true;
+error:
+	pmalloc_destroy_pool(pool);
+	return retval;
+}
+
+static bool test_start_wr(void)
+{
+	struct pmalloc_pool *pool;
+	int *chunks[2];
+	bool retval = false;
+	int i;
+
+	pool = pmalloc_create_pool(PMALLOC_MODE_START_WR);
+	if (WARN(!pool, MSG_NO_POOL))
+		return false;
+	for (i = 0; i < 2; i++) {
+		chunks[i] = (int *)pmalloc(pool, 1);
+		if (WARN(!chunks[i], MSG_NO_PMEM))
+			goto error;
+		if (WARN(!is_address_protected(chunks[i]),
+			 "vmarea was not protected from the start"))
+			goto error;
+	}
+	if (WARN(vmalloc_to_page(chunks[0]) != vmalloc_to_page(chunks[1]),
+		 "START_WR: mostly empty vmap area not reused"))
+		goto error;
+	pr_success("START_WR");
+	retval = true;
+error:
+	pmalloc_destroy_pool(pool);
+	return retval;
+}
+
+static bool test_self_protection(void)
+{
+	if (WARN(!(test_auto_ro() &&
+		   test_auto_wr() &&
+		   test_start_wr()),
+		 "self protection tests failed"))
+		return false;
+	pr_success("self protection");
+	return true;
+}
+
+/* ----------------- tests basic write rare functions ----------------- */
+
+#define INSERT_OFFSET (PAGE_SIZE * 3 / 2)
+#define INSERT_SIZE (PAGE_SIZE * 2)
+#define REGION_SIZE (PAGE_SIZE * 5)
+static bool test_wr_memset(void)
+{
+	struct pmalloc_pool *pool;
+	char *region;
+	unsigned int i;
+	int retval = false;
+
+	pool = pmalloc_create_pool(PMALLOC_MODE_START_WR);
+	if (WARN(!pool, MSG_NO_POOL))
+		return false;
+	region = pzalloc(pool, REGION_SIZE);
+	if (WARN(!region, MSG_NO_PMEM))
+		goto destroy_pool;
+	for (i = 0; i < REGION_SIZE; i++)
+		if (WARN(region[i], "Failed to memset wr memory"))
+			goto destroy_pool;
+	retval = !wr_memset(region + INSERT_OFFSET, 1, INSERT_SIZE);
+	if (WARN(retval, "wr_memset failed"))
+		goto destroy_pool;
+	for (i = 0; i < REGION_SIZE; i++)
+		if (i >= INSERT_OFFSET &&
+		    i < (INSERT_SIZE + INSERT_OFFSET)) {
+			if (WARN(!region[i],
+				 "Failed to alter target area"))
+				goto destroy_pool;
+		} else {
+			if (WARN(region[i] != 0,
+				 "Unexpected alteration outside region"))
+				goto destroy_pool;
+		}
+	retval = true;
+	pr_success("wr_memset");
+destroy_pool:
+	pmalloc_destroy_pool(pool);
+	return retval;
+}
+
+static bool test_wr_strdup(void)
+{
+	const char src[] = "Some text for testing pstrdup()";
+	struct pmalloc_pool *pool;
+	char *dst;
+	int retval = false;
+
+	pool = pmalloc_create_pool(PMALLOC_MODE_WR);
+	if (WARN(!pool, MSG_NO_POOL))
+		return false;
+	dst = pstrdup(pool, src);
+	if (WARN(!dst || strcmp(src, dst), "pmalloc wr strdup failed"))
+		goto destroy_pool;
+	retval = true;
+	pr_success("pmalloc wr strdup");
+destroy_pool:
+	pmalloc_destroy_pool(pool);
+	return retval;
+}
+
+/* Verify write rare across multiple pages, unaligned to PAGE_SIZE. */
+static bool test_wr_copy(void)
+{
+	struct pmalloc_pool *pool;
+	char *region;
+	char *mod;
+	unsigned int i;
+	int retval = false;
+
+	pool = pmalloc_create_pool(PMALLOC_MODE_WR);
+	if (WARN(!pool, MSG_NO_POOL))
+		return false;
+	region = pzalloc(pool, REGION_SIZE);
+	if (WARN(!region, MSG_NO_PMEM))
+		goto destroy_pool;
+	mod = vmalloc(INSERT_SIZE);
+	if (WARN(!mod, "Failed to allocate memory from vmalloc"))
+		goto destroy_pool;
+	memset(mod, 0xA5, INSERT_SIZE);
+	pmalloc_protect_pool(pool);
+	retval = !wr_memcpy(region + INSERT_OFFSET, mod, INSERT_SIZE);
+	if (WARN(retval, "wr_copy failed"))
+		goto free_mod;
+
+	for (i = 0; i < REGION_SIZE; i++)
+		if (i >= INSERT_OFFSET &&
+		    i < (INSERT_SIZE + INSERT_OFFSET)) {
+			if (WARN(region[i] != (char)0xA5,
+				 "Failed to alter target area"))
+				goto free_mod;
+		} else {
+			if (WARN(region[i] != 0,
+				 "Unexpected alteration outside region"))
+				goto free_mod;
+		}
+	retval = true;
+	pr_success("wr_copy");
+free_mod:
+	vfree(mod);
+destroy_pool:
+	pmalloc_destroy_pool(pool);
+	return retval;
+}
+
+/* ----------------- tests specialized write actions ------------------- */
+
+#define TEST_ARRAY_SIZE 5
+#define TEST_ARRAY_TARGET (TEST_ARRAY_SIZE / 2)
+
+static bool test_wr_char(void)
+{
+	struct pmalloc_pool *pool;
+	char *array;
+	unsigned int i;
+	bool retval = false;
+
+	pool = pmalloc_create_pool(PMALLOC_MODE_WR);
+	if (WARN(!pool, MSG_NO_POOL))
+		return false;
+	array = pmalloc(pool, sizeof(char) * TEST_ARRAY_SIZE);
+	if (WARN(!array, MSG_NO_PMEM))
+		goto destroy_pool;
+	for (i = 0; i < TEST_ARRAY_SIZE; i++)
+		array[i] = (char)0xA5;
+	pmalloc_protect_pool(pool);
+	if (WARN(!wr_char(array + TEST_ARRAY_TARGET, (char)0x5A),
+		 "Failed to alter char variable"))
+		goto destroy_pool;
+	for (i = 0; i < TEST_ARRAY_SIZE; i++)
+		if (WARN(array[i] != (i == TEST_ARRAY_TARGET ?
+				      (char)0x5A : (char)0xA5),
+			 "Unexpected value in test array."))
+			goto destroy_pool;
+	retval = true;
+	pr_success("wr_char");
+destroy_pool:
+	pmalloc_destroy_pool(pool);
+	return retval;
+}
+
+static bool test_wr_short(void)
+{
+	struct pmalloc_pool *pool;
+	short *array;
+	unsigned int i;
+	bool retval = false;
+
+	pool = pmalloc_create_pool(PMALLOC_MODE_WR);
+	if (WARN(!pool, MSG_NO_POOL))
+		return false;
+	array = pmalloc(pool, sizeof(short) * TEST_ARRAY_SIZE);
+	if (WARN(!array, MSG_NO_PMEM))
+		goto destroy_pool;
+	for (i = 0; i < TEST_ARRAY_SIZE; i++)
+		array[i] = (short)0xA5;
+	pmalloc_protect_pool(pool);
+	if (WARN(!wr_short(array + TEST_ARRAY_TARGET, (short)0x5A),
+		 "Failed to alter short variable"))
+		goto destroy_pool;
+	for (i = 0; i < TEST_ARRAY_SIZE; i++)
+		if (WARN(array[i] != (i == TEST_ARRAY_TARGET ?
+				      (short)0x5A : (short)0xA5),
+			 "Unexpected value in test array."))
+			goto destroy_pool;
+	retval = true;
+	pr_success("wr_short");
+destroy_pool:
+	pmalloc_destroy_pool(pool);
+	return retval;
+}
+
+static bool test_wr_ushort(void)
+{
+	struct pmalloc_pool *pool;
+	unsigned short *array;
+	unsigned int i;
+	bool retval = false;
+
+	pool = pmalloc_create_pool(PMALLOC_MODE_WR);
+	if (WARN(!pool, MSG_NO_POOL))
+		return false;
+	array = pmalloc(pool, sizeof(unsigned short) * TEST_ARRAY_SIZE);
+	if (WARN(!array, MSG_NO_PMEM))
+		goto destroy_pool;
+	for (i = 0; i < TEST_ARRAY_SIZE; i++)
+		array[i] = (unsigned short)0xA5;
+	pmalloc_protect_pool(pool);
+	if (WARN(!wr_ushort(array + TEST_ARRAY_TARGET,
+				    (unsigned short)0x5A),
+		 "Failed to alter unsigned short variable"))
+		goto destroy_pool;
+	for (i = 0; i < TEST_ARRAY_SIZE; i++)
+		if (WARN(array[i] != (i == TEST_ARRAY_TARGET ?
+				      (unsigned short)0x5A :
+				      (unsigned short)0xA5),
+			 "Unexpected value in test array."))
+			goto destroy_pool;
+	retval = true;
+	pr_success("wr_ushort");
+destroy_pool:
+	pmalloc_destroy_pool(pool);
+	return retval;
+}
+
+static bool test_wr_int(void)
+{
+	struct pmalloc_pool *pool;
+	int *array;
+	unsigned int i;
+	bool retval = false;
+
+	pool = pmalloc_create_pool(PMALLOC_MODE_WR);
+	if (WARN(!pool, MSG_NO_POOL))
+		return false;
+	array = pmalloc(pool, sizeof(int) * TEST_ARRAY_SIZE);
+	if (WARN(!array, MSG_NO_PMEM))
+		goto destroy_pool;
+	for (i = 0; i < TEST_ARRAY_SIZE; i++)
+		array[i] = 0xA5;
+	pmalloc_protect_pool(pool);
+	if (WARN(!wr_int(array + TEST_ARRAY_TARGET, 0x5A),
+		 "Failed to alter int variable"))
+		goto destroy_pool;
+	for (i = 0; i < TEST_ARRAY_SIZE; i++)
+		if (WARN(array[i] != (i == TEST_ARRAY_TARGET ? 0x5A : 0xA5),
+			 "Unexpected value in test array."))
+			goto destroy_pool;
+	retval = true;
+	pr_success("wr_int");
+destroy_pool:
+	pmalloc_destroy_pool(pool);
+	return retval;
+}
+
+static bool test_wr_uint(void)
+{
+	struct pmalloc_pool *pool;
+	unsigned int *array;
+	unsigned int i;
+	bool retval = false;
+
+	pool = pmalloc_create_pool(PMALLOC_MODE_WR);
+	if (WARN(!pool, MSG_NO_POOL))
+		return false;
+	array = pmalloc(pool, sizeof(unsigned int) * TEST_ARRAY_SIZE);
+	if (WARN(!array, MSG_NO_PMEM))
+		goto destroy_pool;
+	for (i = 0; i < TEST_ARRAY_SIZE; i++)
+		array[i] = 0xA5;
+	pmalloc_protect_pool(pool);
+	if (WARN(!wr_uint(array + TEST_ARRAY_TARGET, 0x5A),
+		 "Failed to alter unsigned int variable"))
+		goto destroy_pool;
+	for (i = 0; i < TEST_ARRAY_SIZE; i++)
+		if (WARN(array[i] != (i == TEST_ARRAY_TARGET ? 0x5A : 0xA5),
+			 "Unexpected value in test array."))
+			goto destroy_pool;
+	retval = true;
+	pr_success("wr_uint");
+destroy_pool:
+	pmalloc_destroy_pool(pool);
+	return retval;
+}
+
+static bool test_wr_long(void)
+{
+	struct pmalloc_pool *pool;
+	long *array;
+	unsigned int i;
+	bool retval = false;
+
+	pool = pmalloc_create_pool(PMALLOC_MODE_WR);
+	if (WARN(!pool, MSG_NO_POOL))
+		return false;
+	array = pmalloc(pool, sizeof(long) * TEST_ARRAY_SIZE);
+	if (WARN(!array, MSG_NO_PMEM))
+		goto destroy_pool;
+	for (i = 0; i < TEST_ARRAY_SIZE; i++)
+		array[i] = 0xA5;
+	pmalloc_protect_pool(pool);
+	if (WARN(!wr_long(array + TEST_ARRAY_TARGET, 0x5A),
+		 "Failed to alter long variable"))
+		goto destroy_pool;
+	for (i = 0; i < TEST_ARRAY_SIZE; i++)
+		if (WARN(array[i] != (i == TEST_ARRAY_TARGET ? 0x5A : 0xA5),
+			 "Unexpected value in test array."))
+			goto destroy_pool;
+	retval = true;
+	pr_success("wr_long");
+destroy_pool:
+	pmalloc_destroy_pool(pool);
+	return retval;
+}
+
+static bool test_wr_ulong(void)
+{
+	struct pmalloc_pool *pool;
+	unsigned long *array;
+	unsigned int i;
+	bool retval = false;
+
+	pool = pmalloc_create_pool(PMALLOC_MODE_WR);
+	if (WARN(!pool, MSG_NO_POOL))
+		return false;
+	array = pmalloc(pool, sizeof(unsigned long) * TEST_ARRAY_SIZE);
+	if (WARN(!array, MSG_NO_PMEM))
+		goto destroy_pool;
+	for (i = 0; i < TEST_ARRAY_SIZE; i++)
+		array[i] = 0xA5;
+	pmalloc_protect_pool(pool);
+	if (WARN(!wr_ulong(array + TEST_ARRAY_TARGET, 0x5A),
+		 "Failed to alter unsigned long variable"))
+		goto destroy_pool;
+	for (i = 0; i < TEST_ARRAY_SIZE; i++)
+		if (WARN(array[i] != (i == TEST_ARRAY_TARGET ? 0x5A : 0xA5),
+			 "Unexpected value in test array."))
+			goto destroy_pool;
+	retval = true;
+	pr_success("wr_ulong");
+destroy_pool:
+	pmalloc_destroy_pool(pool);
+	return retval;
+}
+
+static bool test_wr_longlong(void)
+{
+	struct pmalloc_pool *pool;
+	long long *array;
+	unsigned int i;
+	bool retval = false;
+
+	pool = pmalloc_create_pool(PMALLOC_MODE_WR);
+	if (WARN(!pool, MSG_NO_POOL))
+		return false;
+	array = pmalloc(pool, sizeof(long long) * TEST_ARRAY_SIZE);
+	if (WARN(!array, MSG_NO_PMEM))
+		goto destroy_pool;
+	for (i = 0; i < TEST_ARRAY_SIZE; i++)
+		array[i] = 0xA5;
+	pmalloc_protect_pool(pool);
+	if (WARN(!wr_longlong(array + TEST_ARRAY_TARGET, 0x5A),
+		 "Failed to alter long variable"))
+		goto destroy_pool;
+	for (i = 0; i < TEST_ARRAY_SIZE; i++)
+		if (WARN(array[i] != (i == TEST_ARRAY_TARGET ? 0x5A : 0xA5),
+			 "Unexpected value in test array."))
+			goto destroy_pool;
+	retval = true;
+	pr_success("wr_longlong");
+destroy_pool:
+	pmalloc_destroy_pool(pool);
+	return retval;
+}
+
+static bool test_wr_ulonglong(void)
+{
+	struct pmalloc_pool *pool;
+	unsigned long long *array;
+	unsigned int i;
+	bool retval = false;
+
+	pool = pmalloc_create_pool(PMALLOC_MODE_WR);
+	if (WARN(!pool, MSG_NO_POOL))
+		return false;
+	array = pmalloc(pool, sizeof(unsigned long long) * TEST_ARRAY_SIZE);
+	if (WARN(!array, MSG_NO_PMEM))
+		goto destroy_pool;
+	for (i = 0; i < TEST_ARRAY_SIZE; i++)
+		array[i] = 0xA5;
+	pmalloc_protect_pool(pool);
+	if (WARN(!wr_ulonglong(array + TEST_ARRAY_TARGET, 0x5A),
+		 "Failed to alter unsigned long long variable"))
+		goto destroy_pool;
+	for (i = 0; i < TEST_ARRAY_SIZE; i++)
+		if (WARN(array[i] != (i == TEST_ARRAY_TARGET ? 0x5A : 0xA5),
+			 "Unexpected value in test array."))
+			goto destroy_pool;
+	retval = true;
+	pr_success("wr_ulonglong");
+destroy_pool:
+	pmalloc_destroy_pool(pool);
+	return retval;
+}
+
+static bool test_wr_ptr(void)
+{
+	struct pmalloc_pool *pool;
+	int **array;
+	unsigned int i;
+	bool retval = false;
+
+	pool = pmalloc_create_pool(PMALLOC_MODE_WR);
+	if (WARN(!pool, MSG_NO_POOL))
+		return false;
+	array = pmalloc(pool, sizeof(int *) * TEST_ARRAY_SIZE);
+	if (WARN(!array, MSG_NO_PMEM))
+		goto destroy_pool;
+	for (i = 0; i < TEST_ARRAY_SIZE; i++)
+		array[i] = NULL;
+	pmalloc_protect_pool(pool);
+	if (WARN(!wr_ptr(array + TEST_ARRAY_TARGET, array),
+		 "Failed to alter ptr variable"))
+		goto destroy_pool;
+	for (i = 0; i < TEST_ARRAY_SIZE; i++)
+		if (WARN(array[i] != (i == TEST_ARRAY_TARGET ?
+				      (void *)array : NULL),
+			 "Unexpected value in test array."))
+			goto destroy_pool;
+	retval = true;
+	pr_success("wr_ptr");
+destroy_pool:
+	pmalloc_destroy_pool(pool);
+	return retval;
+
+}
+
+static bool test_specialized_wrs(void)
+{
+	if (WARN(!(test_wr_char() &&
+		   test_wr_short() &&
+		   test_wr_ushort() &&
+		   test_wr_int() &&
+		   test_wr_uint() &&
+		   test_wr_long() &&
+		   test_wr_ulong() &&
+		   test_wr_longlong() &&
+		   test_wr_ulonglong() &&
+		   test_wr_ptr()),
+		 "specialized write rare failed"))
+		return false;
+	pr_success("specialized write rare");
+	return true;
+
+}
+
+/*
+ * test_pmalloc()  -main entry point for running the test cases
+ */
+static int __init test_pmalloc_init_module(void)
+{
+	if (WARN(!(create_and_destroy_pool() &&
+		   test_alloc() &&
+		   test_self_protection() &&
+		   test_wr_memset() &&
+		   test_wr_strdup() &&
+		   test_wr_copy() &&
+		   test_specialized_wrs()),
+		 "protected memory allocator test failed"))
+		return -EFAULT;
+	pr_success("protected memory allocator");
+	return 0;
+}
+
+module_init(test_pmalloc_init_module);
+
+MODULE_LICENSE("GPL v2");
+MODULE_AUTHOR("Igor Stoppa <igor.stoppa@huawei.com>");
+MODULE_DESCRIPTION("Test module for pmalloc.");
diff --git a/mm/test_write_rare.c b/mm/test_write_rare.c
new file mode 100644
index 000000000000..e19473bb319b
--- /dev/null
+++ b/mm/test_write_rare.c
@@ -0,0 +1,236 @@
+// SPDX-License-Identifier: GPL-2.0
+/*
+ * test_write_rare.c
+ *
+ * (C) Copyright 2018 Huawei Technologies Co. Ltd.
+ * Author: Igor Stoppa <igor.stoppa@huawei.com>
+ *
+ * Caveat: the tests which perform modifications are run *during* init, so
+ * the memory they use could be still altered through a direct write
+ * operation. But the purpose of these tests is to confirm that the
+ * modification through remapping works correctly. This doesn't depend on
+ * the read/write status of the original mapping.
+ */
+
+#include <linux/init.h>
+#include <linux/module.h>
+#include <linux/mm.h>
+#include <linux/bug.h>
+#include <linux/prmemextra.h>
+
+#ifdef pr_fmt
+#undef pr_fmt
+#endif
+
+#define pr_fmt(fmt) KBUILD_MODNAME ": " fmt
+
+#define pr_success(test_name)	\
+	pr_info(test_name " test passed")
+
+static int scalar __wr_after_init = 0xA5A5;
+
+/* The section must occupy a non-zero number of whole pages */
+static bool test_alignment(void)
+{
+	size_t pstart = (size_t)&__start_wr_after_init;
+	size_t pend = (size_t)&__end_wr_after_init;
+
+	if (WARN((pstart & ~PAGE_MASK) || (pend & ~PAGE_MASK) ||
+		 (pstart >= pend), "Boundaries test failed."))
+		return false;
+	pr_success("Boundaries");
+	return true;
+}
+
+/* Alter a scalar value */
+static bool test_simple_write(void)
+{
+	int new_val = 0x5A5A;
+
+	if (WARN(!__is_wr_after_init(&scalar, sizeof(scalar)),
+		 "The __wr_after_init modifier did NOT work."))
+		return false;
+
+	if (WARN(!wr(&scalar, &new_val) || scalar != new_val,
+		 "Scalar write rare test failed"))
+		return false;
+
+	pr_success("Scalar write rare");
+	return true;
+}
+
+#define LARGE_SIZE (PAGE_SIZE * 5)
+#define CHANGE_SIZE (PAGE_SIZE * 2)
+#define CHANGE_OFFSET (PAGE_SIZE / 2)
+
+static char large[LARGE_SIZE] __wr_after_init;
+
+
+/* Alter data across multiple pages */
+static bool test_cross_page_write(void)
+{
+	unsigned int i;
+	char *src;
+	bool check;
+
+	src = vmalloc(PAGE_SIZE * 2);
+	if (WARN(!src, "could not allocate memory"))
+		return false;
+
+	for (i = 0; i < LARGE_SIZE; i++)
+		large[i] = 0xA5;
+
+	for (i = 0; i < CHANGE_SIZE; i++)
+		src[i] = 0x5A;
+
+	check = wr_memcpy(large + CHANGE_OFFSET, src, CHANGE_SIZE);
+	vfree(src);
+	if (WARN(!check, "The wr_memcpy() failed"))
+		return false;
+
+	for (i = CHANGE_OFFSET; i < CHANGE_OFFSET + CHANGE_SIZE; i++)
+		if (WARN(large[i] != 0x5A,
+			 "Cross-page write rare test failed"))
+			return false;
+
+	pr_success("Cross-page write rare");
+	return true;
+}
+
+static bool test_memsetting(void)
+{
+	unsigned int i;
+
+	wr_memset(large, 0, LARGE_SIZE);
+	for (i = 0; i < LARGE_SIZE; i++)
+		if (WARN(large[i], "Failed to reset memory"))
+			return false;
+	wr_memset(large + CHANGE_OFFSET, 1, CHANGE_SIZE);
+	for (i = 0; i < CHANGE_OFFSET; i++)
+		if (WARN(large[i], "Failed to set memory"))
+			return false;
+	for (i = CHANGE_OFFSET; i < CHANGE_OFFSET + CHANGE_SIZE; i++)
+		if (WARN(!large[i], "Failed to set memory"))
+			return false;
+	for (i = CHANGE_OFFSET + CHANGE_SIZE; i < LARGE_SIZE; i++)
+		if (WARN(large[i], "Failed to set memory"))
+			return false;
+	pr_success("Memsetting");
+	return true;
+}
+
+#define INIT_VAL 1
+#define END_VAL 4
+
+/* Various tests for the shorthands provided for standard types. */
+static char char_var __wr_after_init = INIT_VAL;
+static bool test_char(void)
+{
+	return wr_char(&char_var, END_VAL) && char_var == END_VAL;
+}
+
+static short short_var __wr_after_init = INIT_VAL;
+static bool test_short(void)
+{
+	return wr_short(&short_var, END_VAL) &&
+		short_var == END_VAL;
+}
+
+static unsigned short ushort_var __wr_after_init = INIT_VAL;
+static bool test_ushort(void)
+{
+	return wr_ushort(&ushort_var, END_VAL) &&
+		ushort_var == END_VAL;
+}
+
+static int int_var __wr_after_init = INIT_VAL;
+static bool test_int(void)
+{
+	return wr_int(&int_var, END_VAL) &&
+		int_var == END_VAL;
+}
+
+static unsigned int uint_var __wr_after_init = INIT_VAL;
+static bool test_uint(void)
+{
+	return wr_uint(&uint_var, END_VAL) &&
+		uint_var == END_VAL;
+}
+
+static long long_var __wr_after_init = INIT_VAL;
+static bool test_long(void)
+{
+	return wr_long(&long_var, END_VAL) &&
+		long_var == END_VAL;
+}
+
+static unsigned long ulong_var __wr_after_init = INIT_VAL;
+static bool test_ulong(void)
+{
+	return wr_ulong(&ulong_var, END_VAL) &&
+		ulong_var == END_VAL;
+}
+
+static long long longlong_var __wr_after_init = INIT_VAL;
+static bool test_longlong(void)
+{
+	return wr_longlong(&longlong_var, END_VAL) &&
+		longlong_var == END_VAL;
+}
+
+static unsigned long long ulonglong_var __wr_after_init = INIT_VAL;
+static bool test_ulonglong(void)
+{
+	return wr_ulonglong(&ulonglong_var, END_VAL) &&
+		ulonglong_var == END_VAL;
+}
+
+static int referred_value = INIT_VAL;
+static int *reference __wr_after_init;
+static bool test_ptr(void)
+{
+	return wr_ptr(&reference, &referred_value) &&
+		reference == &referred_value;
+}
+
+static int *rcu_ptr __wr_after_init __aligned(sizeof(void *));
+static bool test_rcu_ptr(void)
+{
+	uintptr_t addr = wr_rcu_assign_pointer(rcu_ptr, &referred_value);
+
+	return  (addr == (uintptr_t)&referred_value) &&
+		referred_value == *(int *)addr;
+}
+
+static bool test_specialized_write_rare(void)
+{
+	if (WARN(!(test_char() && test_short() &&
+		   test_ushort() && test_int() &&
+		   test_uint() && test_long() && test_ulong() &&
+		   test_long() && test_ulong() &&
+		   test_longlong() && test_ulonglong() &&
+		   test_ptr() && test_rcu_ptr()),
+		 "Specialized write rare test failed"))
+		return false;
+	pr_success("Specialized write rare");
+	return true;
+}
+
+static int __init test_static_wr_init_module(void)
+{
+	if (WARN(!(test_alignment() &&
+		   test_simple_write() &&
+		   test_cross_page_write() &&
+		   test_memsetting() &&
+		   test_specialized_write_rare()),
+		 "static rare-write test failed"))
+		return -EFAULT;
+	pr_success("static write_rare");
+	return 0;
+}
+
+module_init(test_static_wr_init_module);
+
+MODULE_LICENSE("GPL v2");
+MODULE_AUTHOR("Igor Stoppa <igor.stoppa@huawei.com>");
+MODULE_DESCRIPTION("Test module for static write rare.");
-- 
2.17.1

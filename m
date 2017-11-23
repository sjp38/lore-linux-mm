Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f198.google.com (mail-qk0-f198.google.com [209.85.220.198])
	by kanga.kvack.org (Postfix) with ESMTP id 3CBD36B0033
	for <linux-mm@kvack.org>; Thu, 23 Nov 2017 11:52:43 -0500 (EST)
Received: by mail-qk0-f198.google.com with SMTP id 136so11378698qkd.1
        for <linux-mm@kvack.org>; Thu, 23 Nov 2017 08:52:43 -0800 (PST)
Received: from mx0a-001b2d01.pphosted.com (mx0a-001b2d01.pphosted.com. [148.163.156.1])
        by mx.google.com with ESMTPS id i38si1163790qte.179.2017.11.23.08.52.41
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 23 Nov 2017 08:52:41 -0800 (PST)
Received: from pps.filterd (m0098394.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.21/8.16.0.21) with SMTP id vANGmxZW066592
	for <linux-mm@kvack.org>; Thu, 23 Nov 2017 11:52:40 -0500
Received: from e36.co.us.ibm.com (e36.co.us.ibm.com [32.97.110.154])
	by mx0a-001b2d01.pphosted.com with ESMTP id 2ee1bctv2c-1
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Thu, 23 Nov 2017 11:52:39 -0500
Received: from localhost
	by e36.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <aneesh.kumar@linux.vnet.ibm.com>;
	Thu, 23 Nov 2017 09:52:39 -0700
From: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
Subject: [PATCH V3] selftest/vm: Move 128TB mmap boundary test to generic directory
Date: Thu, 23 Nov 2017 22:22:26 +0530
Message-Id: <20171123165226.32582-1-aneesh.kumar@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org, "Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>, Ingo Molnar <mingo@redhat.com>, x86@kernel.org, Thomas Gleixner <tglx@linutronix.de>, "H . Peter Anvin" <hpa@zytor.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>

Architectures like ppc64 do support mmap hint addr based large address space
selection. This test can be run on those architectures too. Move the test to
selftest/vm so that other archs can use the same.

We also add a few new test scenarios in this patch. We do test few boundary
condition before we do a high address mmap. ppc64 use the addr limit to validate
addr in the fault path. We had bugs in this area w.r.t slb fault handling
before we updated the addr limit.

We also touch the allocated space to make sure we don't have any bugs in the
fault handling path.

Signed-off-by: Aneesh Kumar K.V <aneesh.kumar@linux.vnet.ibm.com>
---
Changes from V2:
* Rebase on top of -tip tree.
* update the correct license
* use memset to touch the full mmap range.

 tools/testing/selftests/vm/Makefile         |   1 +
 tools/testing/selftests/vm/run_vmtests      |  11 ++
 tools/testing/selftests/vm/va_128TBswitch.c | 297 ++++++++++++++++++++++++++++
 tools/testing/selftests/x86/5lvl.c          | 177 -----------------
 4 files changed, 309 insertions(+), 177 deletions(-)
 create mode 100644 tools/testing/selftests/vm/va_128TBswitch.c
 delete mode 100644 tools/testing/selftests/x86/5lvl.c

diff --git a/tools/testing/selftests/vm/Makefile b/tools/testing/selftests/vm/Makefile
index e49eca1915f8..f33f2d6d5014 100644
--- a/tools/testing/selftests/vm/Makefile
+++ b/tools/testing/selftests/vm/Makefile
@@ -18,6 +18,7 @@ TEST_GEN_FILES += transhuge-stress
 TEST_GEN_FILES += userfaultfd
 TEST_GEN_FILES += mlock-random-test
 TEST_GEN_FILES += virtual_address_range
+TEST_GEN_FILES += va_128TBswitch
 
 TEST_PROGS := run_vmtests
 
diff --git a/tools/testing/selftests/vm/run_vmtests b/tools/testing/selftests/vm/run_vmtests
index cc826326de87..d2561895a021 100755
--- a/tools/testing/selftests/vm/run_vmtests
+++ b/tools/testing/selftests/vm/run_vmtests
@@ -177,4 +177,15 @@ else
 	echo "[PASS]"
 fi
 
+echo "-----------------------------"
+echo "running virtual address 128TB switch test"
+echo "-----------------------------"
+./va_128TBswitch
+if [ $? -ne 0 ]; then
+    echo "[FAIL]"
+    exitcode=1
+else
+    echo "[PASS]"
+fi
+
 exit $exitcode
diff --git a/tools/testing/selftests/vm/va_128TBswitch.c b/tools/testing/selftests/vm/va_128TBswitch.c
new file mode 100644
index 000000000000..e7fe734c374f
--- /dev/null
+++ b/tools/testing/selftests/vm/va_128TBswitch.c
@@ -0,0 +1,297 @@
+/*
+ *
+ * Authors: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
+ * Authors: Aneesh Kumar K.V <aneesh.kumar@linux.vnet.ibm.com>
+ *
+ * This program is free software; you can redistribute it and/or modify
+ * it under the terms of the GNU General Public License, version 2, as
+ * published by the Free Software Foundation.
+
+ * This program is distributed in the hope that it would be useful, but
+ * WITHOUT ANY WARRANTY; without even the implied warranty of
+ * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
+ *
+ */
+
+#include <stdio.h>
+#include <sys/mman.h>
+#include <string.h>
+
+#define ARRAY_SIZE(arr) (sizeof(arr) / sizeof((arr)[0]))
+
+#ifdef __powerpc64__
+#define PAGE_SIZE	(64 << 10)
+/*
+ * This will work with 16M and 2M hugepage size
+ */
+#define HUGETLB_SIZE	(16 << 20)
+#else
+#define PAGE_SIZE	(4 << 10)
+#define HUGETLB_SIZE	(2 << 20)
+#endif
+
+/*
+ * >= 128TB is the hint addr value we used to select
+ * large address space.
+ */
+#define ADDR_SWITCH_HINT (1UL << 47)
+#define LOW_ADDR	((void *) (1UL << 30))
+#define HIGH_ADDR	((void *) (1UL << 48))
+
+struct testcase {
+	void *addr;
+	unsigned long size;
+	unsigned long flags;
+	const char *msg;
+	unsigned int low_addr_required:1;
+	unsigned int keep_mapped:1;
+};
+
+static struct testcase testcases[] = {
+	{
+		/*
+		 * If stack is moved, we could possibly allocate
+		 * this at the requested address.
+		 */
+		.addr = ((void *)(ADDR_SWITCH_HINT - PAGE_SIZE)),
+		.size = PAGE_SIZE,
+		.flags = MAP_PRIVATE | MAP_ANONYMOUS,
+		.msg = "mmap(ADDR_SWITCH_HINT - PAGE_SIZE, PAGE_SIZE)",
+		.low_addr_required = 1,
+	},
+	{
+		/*
+		 * We should never allocate at the requested address or above it
+		 * The len cross the 128TB boundary. Without MAP_FIXED
+		 * we will always search in the lower address space.
+		 */
+		.addr = ((void *)(ADDR_SWITCH_HINT - PAGE_SIZE)),
+		.size = 2 * PAGE_SIZE,
+		.flags = MAP_PRIVATE | MAP_ANONYMOUS,
+		.msg = "mmap(ADDR_SWITCH_HINT - PAGE_SIZE, (2 * PAGE_SIZE))",
+		.low_addr_required = 1,
+	},
+	{
+		/*
+		 * Exact mapping at 128TB, the area is free we should get that
+		 * even without MAP_FIXED.
+		 */
+		.addr = ((void *)(ADDR_SWITCH_HINT)),
+		.size = PAGE_SIZE,
+		.flags = MAP_PRIVATE | MAP_ANONYMOUS,
+		.msg = "mmap(ADDR_SWITCH_HINT, PAGE_SIZE)",
+		.keep_mapped = 1,
+	},
+	{
+		.addr = (void *)(ADDR_SWITCH_HINT),
+		.size = 2 * PAGE_SIZE,
+		.flags = MAP_PRIVATE | MAP_ANONYMOUS | MAP_FIXED,
+		.msg = "mmap(ADDR_SWITCH_HINT, 2 * PAGE_SIZE, MAP_FIXED)",
+	},
+	{
+		.addr = NULL,
+		.size = 2 * PAGE_SIZE,
+		.flags = MAP_PRIVATE | MAP_ANONYMOUS,
+		.msg = "mmap(NULL)",
+		.low_addr_required = 1,
+	},
+	{
+		.addr = LOW_ADDR,
+		.size = 2 * PAGE_SIZE,
+		.flags = MAP_PRIVATE | MAP_ANONYMOUS,
+		.msg = "mmap(LOW_ADDR)",
+		.low_addr_required = 1,
+	},
+	{
+		.addr = HIGH_ADDR,
+		.size = 2 * PAGE_SIZE,
+		.flags = MAP_PRIVATE | MAP_ANONYMOUS,
+		.msg = "mmap(HIGH_ADDR)",
+		.keep_mapped = 1,
+	},
+	{
+		.addr = HIGH_ADDR,
+		.size = 2 * PAGE_SIZE,
+		.flags = MAP_PRIVATE | MAP_ANONYMOUS,
+		.msg = "mmap(HIGH_ADDR) again",
+		.keep_mapped = 1,
+	},
+	{
+		.addr = HIGH_ADDR,
+		.size = 2 * PAGE_SIZE,
+		.flags = MAP_PRIVATE | MAP_ANONYMOUS | MAP_FIXED,
+		.msg = "mmap(HIGH_ADDR, MAP_FIXED)",
+	},
+	{
+		.addr = (void *) -1,
+		.size = 2 * PAGE_SIZE,
+		.flags = MAP_PRIVATE | MAP_ANONYMOUS,
+		.msg = "mmap(-1)",
+		.keep_mapped = 1,
+	},
+	{
+		.addr = (void *) -1,
+		.size = 2 * PAGE_SIZE,
+		.flags = MAP_PRIVATE | MAP_ANONYMOUS,
+		.msg = "mmap(-1) again",
+	},
+	{
+		.addr = ((void *)(ADDR_SWITCH_HINT - PAGE_SIZE)),
+		.size = PAGE_SIZE,
+		.flags = MAP_PRIVATE | MAP_ANONYMOUS,
+		.msg = "mmap(ADDR_SWITCH_HINT - PAGE_SIZE, PAGE_SIZE)",
+		.low_addr_required = 1,
+	},
+	{
+		.addr = (void *)(ADDR_SWITCH_HINT - PAGE_SIZE),
+		.size = 2 * PAGE_SIZE,
+		.flags = MAP_PRIVATE | MAP_ANONYMOUS,
+		.msg = "mmap(ADDR_SWITCH_HINT - PAGE_SIZE, 2 * PAGE_SIZE)",
+		.low_addr_required = 1,
+		.keep_mapped = 1,
+	},
+	{
+		.addr = (void *)(ADDR_SWITCH_HINT - PAGE_SIZE / 2),
+		.size = 2 * PAGE_SIZE,
+		.flags = MAP_PRIVATE | MAP_ANONYMOUS,
+		.msg = "mmap(ADDR_SWITCH_HINT - PAGE_SIZE/2 , 2 * PAGE_SIZE)",
+		.low_addr_required = 1,
+		.keep_mapped = 1,
+	},
+	{
+		.addr = ((void *)(ADDR_SWITCH_HINT)),
+		.size = PAGE_SIZE,
+		.flags = MAP_PRIVATE | MAP_ANONYMOUS,
+		.msg = "mmap(ADDR_SWITCH_HINT, PAGE_SIZE)",
+	},
+	{
+		.addr = (void *)(ADDR_SWITCH_HINT),
+		.size = 2 * PAGE_SIZE,
+		.flags = MAP_PRIVATE | MAP_ANONYMOUS | MAP_FIXED,
+		.msg = "mmap(ADDR_SWITCH_HINT, 2 * PAGE_SIZE, MAP_FIXED)",
+	},
+};
+
+static struct testcase hugetlb_testcases[] = {
+	{
+		.addr = NULL,
+		.size = HUGETLB_SIZE,
+		.flags = MAP_HUGETLB | MAP_PRIVATE | MAP_ANONYMOUS,
+		.msg = "mmap(NULL, MAP_HUGETLB)",
+		.low_addr_required = 1,
+	},
+	{
+		.addr = LOW_ADDR,
+		.size = HUGETLB_SIZE,
+		.flags = MAP_HUGETLB | MAP_PRIVATE | MAP_ANONYMOUS,
+		.msg = "mmap(LOW_ADDR, MAP_HUGETLB)",
+		.low_addr_required = 1,
+	},
+	{
+		.addr = HIGH_ADDR,
+		.size = HUGETLB_SIZE,
+		.flags = MAP_HUGETLB | MAP_PRIVATE | MAP_ANONYMOUS,
+		.msg = "mmap(HIGH_ADDR, MAP_HUGETLB)",
+		.keep_mapped = 1,
+	},
+	{
+		.addr = HIGH_ADDR,
+		.size = HUGETLB_SIZE,
+		.flags = MAP_HUGETLB | MAP_PRIVATE | MAP_ANONYMOUS,
+		.msg = "mmap(HIGH_ADDR, MAP_HUGETLB) again",
+		.keep_mapped = 1,
+	},
+	{
+		.addr = HIGH_ADDR,
+		.size = HUGETLB_SIZE,
+		.flags = MAP_HUGETLB | MAP_PRIVATE | MAP_ANONYMOUS | MAP_FIXED,
+		.msg = "mmap(HIGH_ADDR, MAP_FIXED | MAP_HUGETLB)",
+	},
+	{
+		.addr = (void *) -1,
+		.size = HUGETLB_SIZE,
+		.flags = MAP_HUGETLB | MAP_PRIVATE | MAP_ANONYMOUS,
+		.msg = "mmap(-1, MAP_HUGETLB)",
+		.keep_mapped = 1,
+	},
+	{
+		.addr = (void *) -1,
+		.size = HUGETLB_SIZE,
+		.flags = MAP_HUGETLB | MAP_PRIVATE | MAP_ANONYMOUS,
+		.msg = "mmap(-1, MAP_HUGETLB) again",
+	},
+	{
+		.addr = (void *)(ADDR_SWITCH_HINT - PAGE_SIZE),
+		.size = 2 * HUGETLB_SIZE,
+		.flags = MAP_HUGETLB | MAP_PRIVATE | MAP_ANONYMOUS,
+		.msg = "mmap(ADDR_SWITCH_HINT - PAGE_SIZE, 2*HUGETLB_SIZE, MAP_HUGETLB)",
+		.low_addr_required = 1,
+		.keep_mapped = 1,
+	},
+	{
+		.addr = (void *)(ADDR_SWITCH_HINT),
+		.size = 2 * HUGETLB_SIZE,
+		.flags = MAP_HUGETLB | MAP_PRIVATE | MAP_ANONYMOUS | MAP_FIXED,
+		.msg = "mmap(ADDR_SWITCH_HINT , 2*HUGETLB_SIZE, MAP_FIXED | MAP_HUGETLB)",
+	},
+};
+
+static int run_test(struct testcase *test, int count)
+{
+	void *p;
+	int i, ret = 0;
+
+	for (i = 0; i < count; i++) {
+		struct testcase *t = test + i;
+
+		p = mmap(t->addr, t->size, PROT_READ | PROT_WRITE, t->flags, -1, 0);
+
+		printf("%s: %p - ", t->msg, p);
+
+		if (p == MAP_FAILED) {
+			printf("FAILED\n");
+			ret = 1;
+			continue;
+		}
+
+		if (t->low_addr_required && p >= (void *)(ADDR_SWITCH_HINT)) {
+			printf("FAILED\n");
+			ret = 1;
+		} else {
+			/*
+			 * Do a dereference of the address returned so that we catch
+			 * bugs in page fault handling
+			 */
+			memset(p, 0, t->size);
+			printf("OK\n");
+		}
+		if (!t->keep_mapped)
+			munmap(p, t->size);
+	}
+
+	return ret;
+}
+
+static int supported_arch(void)
+{
+#if defined(__powerpc64__)
+	return 1;
+#elif defined(__x86_64__)
+	return 1;
+#else
+	return 0;
+#endif
+}
+
+int main(int argc, char **argv)
+{
+	int ret;
+
+	if (!supported_arch())
+		return 0;
+
+	ret = run_test(testcases, ARRAY_SIZE(testcases));
+	if (argc == 2 && !strcmp(argv[1], "--run-hugetlb"))
+		ret = run_test(hugetlb_testcases, ARRAY_SIZE(hugetlb_testcases));
+	return ret;
+}
diff --git a/tools/testing/selftests/x86/5lvl.c b/tools/testing/selftests/x86/5lvl.c
deleted file mode 100644
index 2eafdcd4c2b3..000000000000
--- a/tools/testing/selftests/x86/5lvl.c
+++ /dev/null
@@ -1,177 +0,0 @@
-#include <stdio.h>
-#include <sys/mman.h>
-
-#define ARRAY_SIZE(arr) (sizeof(arr) / sizeof((arr)[0]))
-
-#define PAGE_SIZE	4096
-#define LOW_ADDR	((void *) (1UL << 30))
-#define HIGH_ADDR	((void *) (1UL << 50))
-
-struct testcase {
-	void *addr;
-	unsigned long size;
-	unsigned long flags;
-	const char *msg;
-	unsigned int low_addr_required:1;
-	unsigned int keep_mapped:1;
-};
-
-static struct testcase testcases[] = {
-	{
-		.addr = NULL,
-		.size = 2 * PAGE_SIZE,
-		.flags = MAP_PRIVATE | MAP_ANONYMOUS,
-		.msg = "mmap(NULL)",
-		.low_addr_required = 1,
-	},
-	{
-		.addr = LOW_ADDR,
-		.size = 2 * PAGE_SIZE,
-		.flags = MAP_PRIVATE | MAP_ANONYMOUS,
-		.msg = "mmap(LOW_ADDR)",
-		.low_addr_required = 1,
-	},
-	{
-		.addr = HIGH_ADDR,
-		.size = 2 * PAGE_SIZE,
-		.flags = MAP_PRIVATE | MAP_ANONYMOUS,
-		.msg = "mmap(HIGH_ADDR)",
-		.keep_mapped = 1,
-	},
-	{
-		.addr = HIGH_ADDR,
-		.size = 2 * PAGE_SIZE,
-		.flags = MAP_PRIVATE | MAP_ANONYMOUS,
-		.msg = "mmap(HIGH_ADDR) again",
-		.keep_mapped = 1,
-	},
-	{
-		.addr = HIGH_ADDR,
-		.size = 2 * PAGE_SIZE,
-		.flags = MAP_PRIVATE | MAP_ANONYMOUS | MAP_FIXED,
-		.msg = "mmap(HIGH_ADDR, MAP_FIXED)",
-	},
-	{
-		.addr = (void*) -1,
-		.size = 2 * PAGE_SIZE,
-		.flags = MAP_PRIVATE | MAP_ANONYMOUS,
-		.msg = "mmap(-1)",
-		.keep_mapped = 1,
-	},
-	{
-		.addr = (void*) -1,
-		.size = 2 * PAGE_SIZE,
-		.flags = MAP_PRIVATE | MAP_ANONYMOUS,
-		.msg = "mmap(-1) again",
-	},
-	{
-		.addr = (void *)((1UL << 47) - PAGE_SIZE),
-		.size = 2 * PAGE_SIZE,
-		.flags = MAP_PRIVATE | MAP_ANONYMOUS,
-		.msg = "mmap((1UL << 47), 2 * PAGE_SIZE)",
-		.low_addr_required = 1,
-		.keep_mapped = 1,
-	},
-	{
-		.addr = (void *)((1UL << 47) - PAGE_SIZE / 2),
-		.size = 2 * PAGE_SIZE,
-		.flags = MAP_PRIVATE | MAP_ANONYMOUS,
-		.msg = "mmap((1UL << 47), 2 * PAGE_SIZE / 2)",
-		.low_addr_required = 1,
-		.keep_mapped = 1,
-	},
-	{
-		.addr = (void *)((1UL << 47) - PAGE_SIZE),
-		.size = 2 * PAGE_SIZE,
-		.flags = MAP_PRIVATE | MAP_ANONYMOUS | MAP_FIXED,
-		.msg = "mmap((1UL << 47) - PAGE_SIZE, 2 * PAGE_SIZE, MAP_FIXED)",
-	},
-	{
-		.addr = NULL,
-		.size = 2UL << 20,
-		.flags = MAP_HUGETLB | MAP_PRIVATE | MAP_ANONYMOUS,
-		.msg = "mmap(NULL, MAP_HUGETLB)",
-		.low_addr_required = 1,
-	},
-	{
-		.addr = LOW_ADDR,
-		.size = 2UL << 20,
-		.flags = MAP_HUGETLB | MAP_PRIVATE | MAP_ANONYMOUS,
-		.msg = "mmap(LOW_ADDR, MAP_HUGETLB)",
-		.low_addr_required = 1,
-	},
-	{
-		.addr = HIGH_ADDR,
-		.size = 2UL << 20,
-		.flags = MAP_HUGETLB | MAP_PRIVATE | MAP_ANONYMOUS,
-		.msg = "mmap(HIGH_ADDR, MAP_HUGETLB)",
-		.keep_mapped = 1,
-	},
-	{
-		.addr = HIGH_ADDR,
-		.size = 2UL << 20,
-		.flags = MAP_HUGETLB | MAP_PRIVATE | MAP_ANONYMOUS,
-		.msg = "mmap(HIGH_ADDR, MAP_HUGETLB) again",
-		.keep_mapped = 1,
-	},
-	{
-		.addr = HIGH_ADDR,
-		.size = 2UL << 20,
-		.flags = MAP_HUGETLB | MAP_PRIVATE | MAP_ANONYMOUS | MAP_FIXED,
-		.msg = "mmap(HIGH_ADDR, MAP_FIXED | MAP_HUGETLB)",
-	},
-	{
-		.addr = (void*) -1,
-		.size = 2UL << 20,
-		.flags = MAP_HUGETLB | MAP_PRIVATE | MAP_ANONYMOUS,
-		.msg = "mmap(-1, MAP_HUGETLB)",
-		.keep_mapped = 1,
-	},
-	{
-		.addr = (void*) -1,
-		.size = 2UL << 20,
-		.flags = MAP_HUGETLB | MAP_PRIVATE | MAP_ANONYMOUS,
-		.msg = "mmap(-1, MAP_HUGETLB) again",
-	},
-	{
-		.addr = (void *)((1UL << 47) - PAGE_SIZE),
-		.size = 4UL << 20,
-		.flags = MAP_HUGETLB | MAP_PRIVATE | MAP_ANONYMOUS,
-		.msg = "mmap((1UL << 47), 4UL << 20, MAP_HUGETLB)",
-		.low_addr_required = 1,
-		.keep_mapped = 1,
-	},
-	{
-		.addr = (void *)((1UL << 47) - (2UL << 20)),
-		.size = 4UL << 20,
-		.flags = MAP_HUGETLB | MAP_PRIVATE | MAP_ANONYMOUS | MAP_FIXED,
-		.msg = "mmap((1UL << 47) - (2UL << 20), 4UL << 20, MAP_FIXED | MAP_HUGETLB)",
-	},
-};
-
-int main(int argc, char **argv)
-{
-	int i;
-	void *p;
-
-	for (i = 0; i < ARRAY_SIZE(testcases); i++) {
-		struct testcase *t = testcases + i;
-
-		p = mmap(t->addr, t->size, PROT_NONE, t->flags, -1, 0);
-
-		printf("%s: %p - ", t->msg, p);
-
-		if (p == MAP_FAILED) {
-			printf("FAILED\n");
-			continue;
-		}
-
-		if (t->low_addr_required && p >= (void *)(1UL << 47))
-			printf("FAILED\n");
-		else
-			printf("OK\n");
-		if (!t->keep_mapped)
-			munmap(p, t->size);
-	}
-	return 0;
-}
-- 
2.14.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

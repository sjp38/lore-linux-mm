Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf1-f198.google.com (mail-pf1-f198.google.com [209.85.210.198])
	by kanga.kvack.org (Postfix) with ESMTP id 579F16B0003
	for <linux-mm@kvack.org>; Sat, 13 Oct 2018 09:40:08 -0400 (EDT)
Received: by mail-pf1-f198.google.com with SMTP id y73-v6so895879pfi.16
        for <linux-mm@kvack.org>; Sat, 13 Oct 2018 06:40:08 -0700 (PDT)
Received: from ozlabs.org (ozlabs.org. [203.11.71.1])
        by mx.google.com with ESMTPS id k28-v6si4508895pgf.308.2018.10.13.06.40.06
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Sat, 13 Oct 2018 06:40:06 -0700 (PDT)
From: Michael Ellerman <mpe@ellerman.id.au>
Subject: [PATCH] selftests/vm: Add a test for MAP_FIXED_NOREPLACE
Date: Sun, 14 Oct 2018 00:39:29 +1100
Message-Id: <20181013133929.28653-1-mpe@ellerman.id.au>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org
Cc: linux-kernel@vger.kernel.org, jannh@google.com, mhocko@suse.com, linux-mm@kvack.org, khalid.aziz@oracle.com, aarcange@redhat.com, fweimer@redhat.com, jhubbard@nvidia.com, willy@infradead.org, abdhalee@linux.vnet.ibm.com, joel@jms.id.au, keescook@chromium.org, jasone@google.com, davidtgoldblatt@gmail.com, trasz@freebsd.org, danielmicay@gmail.com

Add a test for MAP_FIXED_NOREPLACE, based on some code originally by
Jann Horn. This would have caught the overlap bug reported by Daniel Micay.

I originally suggested to Michal that we create MAP_FIXED_NOREPLACE, but
instead of writing a selftest I spent my time bike-shedding whether it
should be called MAP_FIXED_SAFE/NOCLOBBER/WEAK/NEW .. mea culpa.

Signed-off-by: Michael Ellerman <mpe@ellerman.id.au>
---
 tools/testing/selftests/vm/.gitignore         |   1 +
 tools/testing/selftests/vm/Makefile           |   1 +
 .../selftests/vm/map_fixed_noreplace.c        | 206 ++++++++++++++++++
 3 files changed, 208 insertions(+)
 create mode 100644 tools/testing/selftests/vm/map_fixed_noreplace.c

diff --git a/tools/testing/selftests/vm/.gitignore b/tools/testing/selftests/vm/.gitignore
index af5ff83f6d7f..31b3c98b6d34 100644
--- a/tools/testing/selftests/vm/.gitignore
+++ b/tools/testing/selftests/vm/.gitignore
@@ -13,3 +13,4 @@ mlock-random-test
 virtual_address_range
 gup_benchmark
 va_128TBswitch
+map_fixed_noreplace
diff --git a/tools/testing/selftests/vm/Makefile b/tools/testing/selftests/vm/Makefile
index e94b7b14bcb2..6e67e726e5a5 100644
--- a/tools/testing/selftests/vm/Makefile
+++ b/tools/testing/selftests/vm/Makefile
@@ -12,6 +12,7 @@ TEST_GEN_FILES += gup_benchmark
 TEST_GEN_FILES += hugepage-mmap
 TEST_GEN_FILES += hugepage-shm
 TEST_GEN_FILES += map_hugetlb
+TEST_GEN_FILES += map_fixed_noreplace
 TEST_GEN_FILES += map_populate
 TEST_GEN_FILES += mlock-random-test
 TEST_GEN_FILES += mlock2-tests
diff --git a/tools/testing/selftests/vm/map_fixed_noreplace.c b/tools/testing/selftests/vm/map_fixed_noreplace.c
new file mode 100644
index 000000000000..d91bde511268
--- /dev/null
+++ b/tools/testing/selftests/vm/map_fixed_noreplace.c
@@ -0,0 +1,206 @@
+// SPDX-License-Identifier: GPL-2.0
+
+/*
+ * Test that MAP_FIXED_NOREPLACE works.
+ *
+ * Copyright 2018, Jann Horn <jannh@google.com>
+ * Copyright 2018, Michael Ellerman, IBM Corporation.
+ */
+
+#include <sys/mman.h>
+#include <errno.h>
+#include <stdio.h>
+#include <stdlib.h>
+#include <unistd.h>
+
+#ifndef MAP_FIXED_NOREPLACE
+#define MAP_FIXED_NOREPLACE 0x100000
+#endif
+
+#define BASE_ADDRESS	(256ul * 1024 * 1024)
+
+
+static void dump_maps(void)
+{
+	char cmd[32];
+
+	snprintf(cmd, sizeof(cmd), "cat /proc/%d/maps", getpid());
+	system(cmd);
+}
+
+int main(void)
+{
+	unsigned long flags, addr, size, page_size;
+	char *p;
+
+	page_size = sysconf(_SC_PAGE_SIZE);
+
+	flags = MAP_PRIVATE | MAP_ANONYMOUS | MAP_FIXED_NOREPLACE;
+
+	// Check we can map all the areas we need below
+	errno = 0;
+	addr = BASE_ADDRESS;
+	size = 5 * page_size;
+	p = mmap((void *)addr, size, PROT_NONE, flags, -1, 0);
+
+	printf("mmap() @ 0x%lx-0x%lx p=%p result=%m\n", addr, addr + size, p);
+
+	if (p == MAP_FAILED) {
+		dump_maps();
+		printf("Error: couldn't map the space we need for the test\n");
+		return 1;
+	}
+
+	errno = 0;
+	if (munmap((void *)addr, 5 * page_size) != 0) {
+		dump_maps();
+		printf("Error: munmap failed!?\n");
+		return 1;
+	}
+	printf("unmap() successful\n");
+
+	errno = 0;
+	addr = BASE_ADDRESS + page_size;
+	size = 3 * page_size;
+	p = mmap((void *)addr, size, PROT_NONE, flags, -1, 0);
+	printf("mmap() @ 0x%lx-0x%lx p=%p result=%m\n", addr, addr + size, p);
+
+	if (p == MAP_FAILED) {
+		dump_maps();
+		printf("Error: first mmap() failed unexpectedly\n");
+		return 1;
+	}
+
+	/*
+	 * Exact same mapping again:
+	 *   base |  free  | new
+	 *     +1 | mapped | new
+	 *     +2 | mapped | new
+	 *     +3 | mapped | new
+	 *     +4 |  free  | new
+	 */
+	errno = 0;
+	addr = BASE_ADDRESS;
+	size = 5 * page_size;
+	p = mmap((void *)addr, size, PROT_NONE, flags, -1, 0);
+	printf("mmap() @ 0x%lx-0x%lx p=%p result=%m\n", addr, addr + size, p);
+
+	if (p != MAP_FAILED) {
+		dump_maps();
+		printf("Error:1: mmap() succeeded when it shouldn't have\n");
+		return 1;
+	}
+
+	/*
+	 * Second mapping contained within first:
+	 *
+	 *   base |  free  |
+	 *     +1 | mapped |
+	 *     +2 | mapped | new
+	 *     +3 | mapped |
+	 *     +4 |  free  |
+	 */
+	errno = 0;
+	addr = BASE_ADDRESS + (2 * page_size);
+	size = page_size;
+	p = mmap((void *)addr, size, PROT_NONE, flags, -1, 0);
+	printf("mmap() @ 0x%lx-0x%lx p=%p result=%m\n", addr, addr + size, p);
+
+	if (p != MAP_FAILED) {
+		dump_maps();
+		printf("Error:2: mmap() succeeded when it shouldn't have\n");
+		return 1;
+	}
+
+	/*
+	 * Overlap end of existing mapping:
+	 *   base |  free  |
+	 *     +1 | mapped |
+	 *     +2 | mapped |
+	 *     +3 | mapped | new
+	 *     +4 |  free  | new
+	 */
+	errno = 0;
+	addr = BASE_ADDRESS + (3 * page_size);
+	size = 2 * page_size;
+	p = mmap((void *)addr, size, PROT_NONE, flags, -1, 0);
+	printf("mmap() @ 0x%lx-0x%lx p=%p result=%m\n", addr, addr + size, p);
+
+	if (p != MAP_FAILED) {
+		dump_maps();
+		printf("Error:3: mmap() succeeded when it shouldn't have\n");
+		return 1;
+	}
+
+	/*
+	 * Overlap start of existing mapping:
+	 *   base |  free  | new
+	 *     +1 | mapped | new
+	 *     +2 | mapped |
+	 *     +3 | mapped |
+	 *     +4 |  free  |
+	 */
+	errno = 0;
+	addr = BASE_ADDRESS;
+	size = 2 * page_size;
+	p = mmap((void *)addr, size, PROT_NONE, flags, -1, 0);
+	printf("mmap() @ 0x%lx-0x%lx p=%p result=%m\n", addr, addr + size, p);
+
+	if (p != MAP_FAILED) {
+		dump_maps();
+		printf("Error:4: mmap() succeeded when it shouldn't have\n");
+		return 1;
+	}
+
+	/*
+	 * Adjacent to start of existing mapping:
+	 *   base |  free  | new
+	 *     +1 | mapped |
+	 *     +2 | mapped |
+	 *     +3 | mapped |
+	 *     +4 |  free  |
+	 */
+	errno = 0;
+	addr = BASE_ADDRESS;
+	size = page_size;
+	p = mmap((void *)addr, size, PROT_NONE, flags, -1, 0);
+	printf("mmap() @ 0x%lx-0x%lx p=%p result=%m\n", addr, addr + size, p);
+
+	if (p == MAP_FAILED) {
+		dump_maps();
+		printf("Error:5: mmap() failed when it shouldn't have\n");
+		return 1;
+	}
+
+	/*
+	 * Adjacent to end of existing mapping:
+	 *   base |  free  |
+	 *     +1 | mapped |
+	 *     +2 | mapped |
+	 *     +3 | mapped |
+	 *     +4 |  free  |  new
+	 */
+	errno = 0;
+	addr = BASE_ADDRESS + (4 * page_size);
+	size = page_size;
+	p = mmap((void *)addr, size, PROT_NONE, flags, -1, 0);
+	printf("mmap() @ 0x%lx-0x%lx p=%p result=%m\n", addr, addr + size, p);
+
+	if (p == MAP_FAILED) {
+		dump_maps();
+		printf("Error:6: mmap() failed when it shouldn't have\n");
+		return 1;
+	}
+
+	addr = BASE_ADDRESS;
+	size = 5 * page_size;
+	if (munmap((void *)addr, size) != 0) {
+		dump_maps();
+		printf("Error: munmap failed!?\n");
+		return 1;
+	}
+	printf("unmap() successful\n");
+
+	printf("OK\n");
+	return 0;
+}
-- 
2.17.1

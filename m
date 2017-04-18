Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id C720F6B0038
	for <linux-mm@kvack.org>; Tue, 18 Apr 2017 05:53:01 -0400 (EDT)
Received: by mail-pf0-f199.google.com with SMTP id a188so49045427pfa.3
        for <linux-mm@kvack.org>; Tue, 18 Apr 2017 02:53:01 -0700 (PDT)
Received: from mx0a-001b2d01.pphosted.com (mx0a-001b2d01.pphosted.com. [148.163.156.1])
        by mx.google.com with ESMTPS id 63si13856004pgi.231.2017.04.18.02.53.00
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 18 Apr 2017 02:53:00 -0700 (PDT)
Received: from pps.filterd (m0098410.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.20/8.16.0.20) with SMTP id v3I9o9qv081842
	for <linux-mm@kvack.org>; Tue, 18 Apr 2017 05:53:00 -0400
Received: from e28smtp03.in.ibm.com (e28smtp03.in.ibm.com [125.16.236.3])
	by mx0a-001b2d01.pphosted.com with ESMTP id 29vwn12yjw-1
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Tue, 18 Apr 2017 05:52:59 -0400
Received: from localhost
	by e28smtp03.in.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <khandual@linux.vnet.ibm.com>;
	Tue, 18 Apr 2017 15:22:56 +0530
Received: from d28av04.in.ibm.com (d28av04.in.ibm.com [9.184.220.66])
	by d28relay06.in.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id v3I9qrYm18546798
	for <linux-mm@kvack.org>; Tue, 18 Apr 2017 15:22:53 +0530
Received: from d28av04.in.ibm.com (localhost [127.0.0.1])
	by d28av04.in.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id v3I9qr5R009764
	for <linux-mm@kvack.org>; Tue, 18 Apr 2017 15:22:53 +0530
From: Anshuman Khandual <khandual@linux.vnet.ibm.com>
Subject: [PATCH] selftests/vm: Add a test for virtual address range mapping
Date: Tue, 18 Apr 2017 15:22:52 +0530
Message-Id: <20170418095252.20533-1-khandual@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org, linux-mm@kvack.org
Cc: akpm@linux-foundation.org, msuchanek@suse.de, aneesh.kumar@linux.vnet.ibm.com

This verifies virtual address mapping below and above the
128TB range and makes sure that address returned are within
the expected range depending upon the hint passed from the
user space.

Signed-off-by: Anshuman Khandual <khandual@linux.vnet.ibm.com>
---
 tools/testing/selftests/vm/Makefile                |   1 +
 tools/testing/selftests/vm/run_vmtests             |  11 ++
 tools/testing/selftests/vm/virtual_address_range.c | 122 +++++++++++++++++++++
 3 files changed, 134 insertions(+)
 create mode 100644 tools/testing/selftests/vm/virtual_address_range.c

diff --git a/tools/testing/selftests/vm/Makefile b/tools/testing/selftests/vm/Makefile
index 41642ba..367850a 100644
--- a/tools/testing/selftests/vm/Makefile
+++ b/tools/testing/selftests/vm/Makefile
@@ -18,6 +18,7 @@ TEST_GEN_FILES += userfaultfd
 TEST_GEN_FILES += userfaultfd_hugetlb
 TEST_GEN_FILES += userfaultfd_shmem
 TEST_GEN_FILES += mlock-random-test
+TEST_GEN_FILES += virtual_address_range
 
 TEST_PROGS := run_vmtests
 
diff --git a/tools/testing/selftests/vm/run_vmtests b/tools/testing/selftests/vm/run_vmtests
index c92f6cf..abd6a3d 100755
--- a/tools/testing/selftests/vm/run_vmtests
+++ b/tools/testing/selftests/vm/run_vmtests
@@ -165,4 +165,15 @@ else
 	echo "[PASS]"
 fi
 
+echo "-----------------------------"
+echo "running virtual_address_range"
+echo "-----------------------------"
+./virtual_address_range
+if [ $? -ne 0 ]; then
+	echo "[FAIL]"
+	exitcode=1
+else
+	echo "[PASS]"
+fi
+
 exit $exitcode
diff --git a/tools/testing/selftests/vm/virtual_address_range.c b/tools/testing/selftests/vm/virtual_address_range.c
new file mode 100644
index 0000000..3b02aa6
--- /dev/null
+++ b/tools/testing/selftests/vm/virtual_address_range.c
@@ -0,0 +1,122 @@
+/*
+ * Copyright 2017, Anshuman Khandual, IBM Corp.
+ * Licensed under GPLv2.
+ *
+ * Works on architectures which support 128TB virtual
+ * address range and beyond.
+ */
+#include <stdio.h>
+#include <stdlib.h>
+#include <string.h>
+#include <unistd.h>
+#include <errno.h>
+#include <numaif.h>
+#include <sys/mman.h>
+#include <sys/time.h>
+
+/*
+ * Maximum address range mapped with a single mmap()
+ * call is little bit more than 16GB. Hence 16GB is
+ * chosen as the single chunk size for address space
+ * mapping.
+ */
+#define MAP_CHUNK_SIZE   17179869184UL /* 16GB */
+
+/*
+ * Address space till 128TB is mapped without any hint
+ * and is enabled by default. Address space beyond 128TB
+ * till 512TB is obtained by passing hint address as the
+ * first argument into mmap() system call.
+ *
+ * The process heap address space is divided into two
+ * different areas one below 128TB and one above 128TB
+ * till it reaches 512TB. One with size 128TB and the
+ * other being 384TB.
+ */
+#define NR_CHUNKS_128TB   8192UL /* Number of 16GB chunks for 128TB */
+#define NR_CHUNKS_384TB  24576UL /* Number of 16GB chunks for 384TB */
+
+#define ADDR_MARK_128TB  (1UL << 47) /* First address beyond 128TB */
+
+static char *hind_addr(void)
+{
+	int bits = 48 + rand() % 15;
+
+	return (char *) (1UL << bits);
+}
+
+static int validate_addr(char *ptr, int high_addr)
+{
+	unsigned long addr = (unsigned long) ptr;
+
+	if (high_addr) {
+		if (addr < ADDR_MARK_128TB) {
+			printf("Bad address %lx\n", addr);
+			return 1;
+		}
+		return 0;
+	}
+
+	if (addr > ADDR_MARK_128TB) {
+		printf("Bad address %lx\n", addr);
+		return 1;
+	}
+	return 0;
+}
+
+static int validate_lower_address_hint(void)
+{
+	char *ptr;
+
+	ptr = mmap((void *) (1UL << 45), MAP_CHUNK_SIZE, PROT_READ |
+			PROT_WRITE, MAP_PRIVATE | MAP_ANONYMOUS, -1, 0);
+
+	if (ptr == MAP_FAILED)
+		return 0;
+
+	return 1;
+}
+
+int main(int argc, char *argv[])
+{
+	char *ptr[NR_CHUNKS_128TB];
+	char *hptr[NR_CHUNKS_384TB];
+	char *hint;
+	unsigned long i, lchunks, hchunks;
+
+	for (i = 0; i < NR_CHUNKS_128TB; i++) {
+		ptr[i] = mmap(NULL, MAP_CHUNK_SIZE, PROT_READ | PROT_WRITE,
+					MAP_PRIVATE | MAP_ANONYMOUS, -1, 0);
+
+		if (ptr[i] == MAP_FAILED) {
+			if (validate_lower_address_hint())
+				return 1;
+			break;
+		}
+
+		if (validate_addr(ptr[i], 0))
+			return 1;
+	}
+	lchunks = i;
+
+	for (i = 0; i < NR_CHUNKS_384TB; i++) {
+		hint = hind_addr();
+		hptr[i] = mmap(hint, MAP_CHUNK_SIZE, PROT_READ | PROT_WRITE,
+					MAP_PRIVATE | MAP_ANONYMOUS, -1, 0);
+
+		if (hptr[i] == MAP_FAILED)
+			break;
+
+		if (validate_addr(hptr[i], 1))
+			return 1;
+	}
+	hchunks = i;
+
+	for (i = 0; i < lchunks; i++)
+		munmap(ptr[i], MAP_CHUNK_SIZE);
+
+	for (i = 0; i < hchunks; i++)
+		munmap(hptr[i], MAP_CHUNK_SIZE);
+
+	return 0;
+}
-- 
1.8.5.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id DC0AD6B0292
	for <linux-mm@kvack.org>; Thu, 20 Jul 2017 05:37:05 -0400 (EDT)
Received: by mail-pf0-f199.google.com with SMTP id d18so24297743pfe.8
        for <linux-mm@kvack.org>; Thu, 20 Jul 2017 02:37:05 -0700 (PDT)
Received: from mx0a-001b2d01.pphosted.com (mx0a-001b2d01.pphosted.com. [148.163.156.1])
        by mx.google.com with ESMTPS id l1si1283553plb.824.2017.07.20.02.37.04
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 20 Jul 2017 02:37:04 -0700 (PDT)
Received: from pps.filterd (m0098409.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.21/8.16.0.21) with SMTP id v6K9Xe9M038709
	for <linux-mm@kvack.org>; Thu, 20 Jul 2017 05:37:04 -0400
Received: from e23smtp03.au.ibm.com (e23smtp03.au.ibm.com [202.81.31.145])
	by mx0a-001b2d01.pphosted.com with ESMTP id 2btjhmrhx3-1
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Thu, 20 Jul 2017 05:37:03 -0400
Received: from localhost
	by e23smtp03.au.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <khandual@linux.vnet.ibm.com>;
	Thu, 20 Jul 2017 19:37:01 +1000
Received: from d23av02.au.ibm.com (d23av02.au.ibm.com [9.190.235.138])
	by d23relay08.au.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id v6K9awKd24117394
	for <linux-mm@kvack.org>; Thu, 20 Jul 2017 19:36:58 +1000
Received: from d23av02.au.ibm.com (localhost [127.0.0.1])
	by d23av02.au.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id v6K9aoSU019556
	for <linux-mm@kvack.org>; Thu, 20 Jul 2017 19:36:50 +1000
From: Anshuman Khandual <khandual@linux.vnet.ibm.com>
Subject: [PATCH] selftests/vm: Add test to validate mirror functionality with mremap
Date: Thu, 20 Jul 2017 15:06:51 +0530
Message-Id: <20170720093651.22106-1-khandual@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, linux-kernel@vger.kernel.org
Cc: akpm@linux-foundation.org, mike.kravetz@oracle.com

This adds a test to validate mirror functionality with mremap()
system call on shared anon mappings.

Suggested-by: Mike Kravetz <mike.kravetz@oracle.com>
Signed-off-by: Anshuman Khandual <khandual@linux.vnet.ibm.com>
---
 tools/testing/selftests/vm/Makefile                |  1 +
 .../selftests/vm/mremap_mirror_shared_anon.c       | 54 ++++++++++++++++++++++
 2 files changed, 55 insertions(+)
 create mode 100644 tools/testing/selftests/vm/mremap_mirror_shared_anon.c

diff --git a/tools/testing/selftests/vm/Makefile b/tools/testing/selftests/vm/Makefile
index cbb29e4..11657ff5 100644
--- a/tools/testing/selftests/vm/Makefile
+++ b/tools/testing/selftests/vm/Makefile
@@ -17,6 +17,7 @@ TEST_GEN_FILES += transhuge-stress
 TEST_GEN_FILES += userfaultfd
 TEST_GEN_FILES += mlock-random-test
 TEST_GEN_FILES += virtual_address_range
+TEST_GEN_FILES += mremap_mirror_shared_anon
 
 TEST_PROGS := run_vmtests
 
diff --git a/tools/testing/selftests/vm/mremap_mirror_shared_anon.c b/tools/testing/selftests/vm/mremap_mirror_shared_anon.c
new file mode 100644
index 0000000..b0adbb2
--- /dev/null
+++ b/tools/testing/selftests/vm/mremap_mirror_shared_anon.c
@@ -0,0 +1,54 @@
+/*
+ * Test to verify mirror functionality with mremap() system
+ * call for shared anon mappings.
+ *
+ * Copyright (C) 2017 Anshuman Khandual, IBM Corporation
+ *
+ * Licensed under GPL V2
+ */
+#include <stdio.h>
+#include <string.h>
+#include <unistd.h>
+#include <errno.h>
+#include <sys/mman.h>
+#include <sys/time.h>
+
+#define PATTERN		0xbe
+#define ALLOC_SIZE	0x10000UL /* Works for 64K and 4K pages */
+
+int test_mirror(char *old, char *new, unsigned long size)
+{
+	unsigned long i;
+
+	for (i = 0; i < size; i++) {
+		if (new[i] != old[i]) {
+			printf("Mismatch at new[%lu] expected "
+				"%d received %d\n", i, old[i], new[i]);
+			return 1;
+		}
+	}
+	return 0;
+}
+
+int main(int argc, char *argv[])
+{
+	char *ptr, *mirror_ptr;
+
+	ptr = mmap(NULL, ALLOC_SIZE, PROT_READ | PROT_WRITE,
+			MAP_SHARED | MAP_ANONYMOUS, -1, 0);
+	if (ptr == MAP_FAILED) {
+		perror("map() failed");
+		return -1;
+	}
+	memset(ptr, PATTERN, ALLOC_SIZE);
+
+	mirror_ptr =  (char *) mremap(ptr, 0, ALLOC_SIZE, 1);
+	if (mirror_ptr == MAP_FAILED) {
+		perror("mremap() failed");
+		return -1;
+	}
+
+	if (test_mirror(ptr, mirror_ptr, ALLOC_SIZE))
+		return 1;
+	return 0;
+}
-- 
1.8.5.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f71.google.com (mail-wm0-f71.google.com [74.125.82.71])
	by kanga.kvack.org (Postfix) with ESMTP id 299976B0292
	for <linux-mm@kvack.org>; Tue, 25 Jul 2017 02:37:14 -0400 (EDT)
Received: by mail-wm0-f71.google.com with SMTP id m80so1898664wmd.4
        for <linux-mm@kvack.org>; Mon, 24 Jul 2017 23:37:14 -0700 (PDT)
Received: from mx0a-001b2d01.pphosted.com (mx0b-001b2d01.pphosted.com. [148.163.158.5])
        by mx.google.com with ESMTPS id k66si6826324wmg.257.2017.07.24.23.37.12
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 24 Jul 2017 23:37:12 -0700 (PDT)
Received: from pps.filterd (m0098420.ppops.net [127.0.0.1])
	by mx0b-001b2d01.pphosted.com (8.16.0.21/8.16.0.21) with SMTP id v6P6XtYx121103
	for <linux-mm@kvack.org>; Tue, 25 Jul 2017 02:37:11 -0400
Received: from e23smtp08.au.ibm.com (e23smtp08.au.ibm.com [202.81.31.141])
	by mx0b-001b2d01.pphosted.com with ESMTP id 2bwwq46yyb-1
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Tue, 25 Jul 2017 02:37:11 -0400
Received: from localhost
	by e23smtp08.au.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <khandual@linux.vnet.ibm.com>;
	Tue, 25 Jul 2017 16:37:08 +1000
Received: from d23av03.au.ibm.com (d23av03.au.ibm.com [9.190.234.97])
	by d23relay10.au.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id v6P6b5k716777434
	for <linux-mm@kvack.org>; Tue, 25 Jul 2017 16:37:05 +1000
Received: from d23av03.au.ibm.com (localhost [127.0.0.1])
	by d23av03.au.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id v6P6aveD007053
	for <linux-mm@kvack.org>; Tue, 25 Jul 2017 16:36:57 +1000
From: Anshuman Khandual <khandual@linux.vnet.ibm.com>
Subject: [PATCH V2] selftests/vm: Add tests to validate mirror functionality with mremap
Date: Tue, 25 Jul 2017 12:06:57 +0530
Message-Id: <20170725063657.3915-1-khandual@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, linux-kernel@vger.kernel.org
Cc: akpm@linux-foundation.org, mike.kravetz@oracle.com

This adds two tests to validate mirror functionality with mremap()
system call on shared and private anon mappings.

Suggested-by: Mike Kravetz <mike.kravetz@oracle.com>
Signed-off-by: Anshuman Khandual <khandual@linux.vnet.ibm.com>
---
Changes in V2:

- Added a test for private anon mappings
- Used sysconf(_SC_PAGESIZE) instead of hard coding page size
- Used MREMAP_MAYMOVE instead of hard coding the flag value 1

 tools/testing/selftests/vm/Makefile                |  2 +
 .../selftests/vm/mremap_mirror_private_anon.c      | 49 ++++++++++++++++++
 .../selftests/vm/mremap_mirror_shared_anon.c       | 58 ++++++++++++++++++++++
 3 files changed, 109 insertions(+)
 create mode 100644 tools/testing/selftests/vm/mremap_mirror_private_anon.c
 create mode 100644 tools/testing/selftests/vm/mremap_mirror_shared_anon.c

diff --git a/tools/testing/selftests/vm/Makefile b/tools/testing/selftests/vm/Makefile
index cbb29e4..6401f91 100644
--- a/tools/testing/selftests/vm/Makefile
+++ b/tools/testing/selftests/vm/Makefile
@@ -17,6 +17,8 @@ TEST_GEN_FILES += transhuge-stress
 TEST_GEN_FILES += userfaultfd
 TEST_GEN_FILES += mlock-random-test
 TEST_GEN_FILES += virtual_address_range
+TEST_GEN_FILES += mremap_mirror_shared_anon
+TEST_GEN_FILES += mremap_mirror_private_anon
 
 TEST_PROGS := run_vmtests
 
diff --git a/tools/testing/selftests/vm/mremap_mirror_private_anon.c b/tools/testing/selftests/vm/mremap_mirror_private_anon.c
new file mode 100644
index 0000000..3106809
--- /dev/null
+++ b/tools/testing/selftests/vm/mremap_mirror_private_anon.c
@@ -0,0 +1,49 @@
+/*
+ * Test to verify mirror functionality with mremap() system
+ * call for private anon mappings. The 'mirrored' buffer is
+ * a separate distinct unrelated mapping and different from
+ * that of the original one.
+ *
+ * Copyright (C) 2017 Anshuman Khandual, IBM Corporation
+ *
+ * Licensed under GPL V2
+ */
+#define _GNU_SOURCE
+#include <stdio.h>
+#include <string.h>
+#include <unistd.h>
+#include <errno.h>
+#include <sys/mman.h>
+#include <sys/time.h>
+
+#define PATTERN		0xbe
+#define NR_PAGES	10
+
+int main(int argc, char *argv[])
+{
+	unsigned long alloc_size, i;
+	char *ptr, *mirror_ptr;
+
+	alloc_size = sysconf(_SC_PAGESIZE) * NR_PAGES;
+	ptr = mmap(NULL, alloc_size, PROT_READ | PROT_WRITE,
+			MAP_PRIVATE | MAP_ANONYMOUS, -1, 0);
+	if (ptr == MAP_FAILED) {
+		perror("map() failed");
+		return -1;
+	}
+	memset(ptr, PATTERN, alloc_size);
+
+	mirror_ptr =  (char *) mremap(ptr, 0, alloc_size, MREMAP_MAYMOVE);
+	if (mirror_ptr == MAP_FAILED) {
+		perror("mremap() failed");
+		return -1;
+	}
+
+	for (i = 0; i < alloc_size; i++) {
+		if (ptr[i] == mirror_ptr[i]) {
+			printf("Mirror buffer elements matched at %lu\n", i);
+			return 1;
+		}
+	}
+	return 0;
+}
diff --git a/tools/testing/selftests/vm/mremap_mirror_shared_anon.c b/tools/testing/selftests/vm/mremap_mirror_shared_anon.c
new file mode 100644
index 0000000..f775698
--- /dev/null
+++ b/tools/testing/selftests/vm/mremap_mirror_shared_anon.c
@@ -0,0 +1,58 @@
+/*
+ * Test to verify mirror functionality with mremap() system
+ * call for shared anon mappings. The 'mirrored' buffer will
+ * match element to element with that of the original one.
+ *
+ * Copyright (C) 2017 Anshuman Khandual, IBM Corporation
+ *
+ * Licensed under GPL V2
+ */
+#define _GNU_SOURCE
+#include <stdio.h>
+#include <string.h>
+#include <unistd.h>
+#include <errno.h>
+#include <sys/mman.h>
+#include <sys/time.h>
+
+#define PATTERN		0xbe
+#define NR_PAGES	10
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
+	unsigned long alloc_size;
+	char *ptr, *mirror_ptr;
+
+	alloc_size = sysconf(_SC_PAGESIZE) * NR_PAGES;
+	ptr = mmap(NULL, alloc_size, PROT_READ | PROT_WRITE,
+			MAP_SHARED | MAP_ANONYMOUS, -1, 0);
+	if (ptr == MAP_FAILED) {
+		perror("map() failed");
+		return -1;
+	}
+	memset(ptr, PATTERN, alloc_size);
+
+	mirror_ptr =  (char *) mremap(ptr, 0, alloc_size, MREMAP_MAYMOVE);
+	if (mirror_ptr == MAP_FAILED) {
+		perror("mremap() failed");
+		return -1;
+	}
+
+	if (test_mirror(ptr, mirror_ptr, alloc_size))
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

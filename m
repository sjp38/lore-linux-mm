Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f69.google.com (mail-wm0-f69.google.com [74.125.82.69])
	by kanga.kvack.org (Postfix) with ESMTP id 703A16B0263
	for <linux-mm@kvack.org>; Thu,  4 Aug 2016 04:15:07 -0400 (EDT)
Received: by mail-wm0-f69.google.com with SMTP id p129so140884697wmp.3
        for <linux-mm@kvack.org>; Thu, 04 Aug 2016 01:15:07 -0700 (PDT)
Received: from mx0a-001b2d01.pphosted.com (mx0b-001b2d01.pphosted.com. [148.163.158.5])
        by mx.google.com with ESMTPS id i20si12351528wjs.187.2016.08.04.01.15.05
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 04 Aug 2016 01:15:06 -0700 (PDT)
Received: from pps.filterd (m0098419.ppops.net [127.0.0.1])
	by mx0b-001b2d01.pphosted.com (8.16.0.11/8.16.0.11) with SMTP id u748DrWg125104
	for <linux-mm@kvack.org>; Thu, 4 Aug 2016 04:15:05 -0400
Received: from e06smtp10.uk.ibm.com (e06smtp10.uk.ibm.com [195.75.94.106])
	by mx0b-001b2d01.pphosted.com with ESMTP id 24kxmgy90p-1
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Thu, 04 Aug 2016 04:15:04 -0400
Received: from localhost
	by e06smtp10.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <rppt@linux.vnet.ibm.com>;
	Thu, 4 Aug 2016 09:15:03 +0100
Received: from b06cxnps4074.portsmouth.uk.ibm.com (d06relay11.portsmouth.uk.ibm.com [9.149.109.196])
	by d06dlp03.portsmouth.uk.ibm.com (Postfix) with ESMTP id 044881B0804B
	for <linux-mm@kvack.org>; Thu,  4 Aug 2016 09:16:31 +0100 (BST)
Received: from d06av09.portsmouth.uk.ibm.com (d06av09.portsmouth.uk.ibm.com [9.149.37.250])
	by b06cxnps4074.portsmouth.uk.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id u748F0tp14024996
	for <linux-mm@kvack.org>; Thu, 4 Aug 2016 08:15:00 GMT
Received: from d06av09.portsmouth.uk.ibm.com (localhost [127.0.0.1])
	by d06av09.portsmouth.uk.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id u748Ex0a001953
	for <linux-mm@kvack.org>; Thu, 4 Aug 2016 02:15:00 -0600
From: Mike Rapoport <rppt@linux.vnet.ibm.com>
Subject: [PATCH 7/7] userfaultfd: shmem: add userfaultfd_shmem test
Date: Thu,  4 Aug 2016 11:14:18 +0300
In-Reply-To: <1470298458-9925-1-git-send-email-rppt@linux.vnet.ibm.com>
References: <1470298458-9925-1-git-send-email-rppt@linux.vnet.ibm.com>
Message-Id: <1470298458-9925-8-git-send-email-rppt@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrea Arcangeli <aarcange@redhat.com>
Cc: Hugh Dickins <hughd@google.com>, Pavel Emelyanov <xemul@virtuozzo.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Mike Rapoport <rppt@linux.vnet.ibm.com>

The test verifies that anonymous shared mapping can be used with userfault
using the existing testing method.
The shared memory area is allocated using mmap(..., MAP_SHARED |
MAP_ANONYMOUS, ...) and released using madvise(MADV_REMOVE)

Signed-off-by: Mike Rapoport <rppt@linux.vnet.ibm.com>
---
 tools/testing/selftests/vm/Makefile      |  3 +++
 tools/testing/selftests/vm/run_vmtests   | 11 ++++++++++
 tools/testing/selftests/vm/userfaultfd.c | 37 ++++++++++++++++++++++++++++++--
 3 files changed, 49 insertions(+), 2 deletions(-)

diff --git a/tools/testing/selftests/vm/Makefile b/tools/testing/selftests/vm/Makefile
index aaa4225..12ff211 100644
--- a/tools/testing/selftests/vm/Makefile
+++ b/tools/testing/selftests/vm/Makefile
@@ -11,6 +11,7 @@ BINARIES += thuge-gen
 BINARIES += transhuge-stress
 BINARIES += userfaultfd
 BINARIES += userfaultfd_hugetlb
+BINARIES += userfaultfd_shmem
 
 all: $(BINARIES)
 %: %.c
@@ -19,6 +20,8 @@ userfaultfd: userfaultfd.c ../../../../usr/include/linux/kernel.h
 	$(CC) $(CFLAGS) -O2 -o $@ $< -lpthread
 userfaultfd_hugetlb: userfaultfd.c ../../../../usr/include/linux/kernel.h
 	$(CC) $(CFLAGS) -DHUGETLB_TEST -O2 -o $@ $< -lpthread
+userfaultfd_shmem: userfaultfd.c ../../../../usr/include/linux/kernel.h
+	$(CC) $(CFLAGS) -DSHMEM_TEST -O2 -o $@ $< -lpthread
 
 ../../../../usr/include/linux/kernel.h:
 	make -C ../../../.. headers_install
diff --git a/tools/testing/selftests/vm/run_vmtests b/tools/testing/selftests/vm/run_vmtests
index 14d697e..c92f6cf 100755
--- a/tools/testing/selftests/vm/run_vmtests
+++ b/tools/testing/selftests/vm/run_vmtests
@@ -116,6 +116,17 @@ else
 fi
 rm -f $mnt/ufd_test_file
 
+echo "----------------------------"
+echo "running userfaultfd_shmem"
+echo "----------------------------"
+./userfaultfd_shmem 128 32
+if [ $? -ne 0 ]; then
+	echo "[FAIL]"
+	exitcode=1
+else
+	echo "[PASS]"
+fi
+
 #cleanup
 umount $mnt
 rm -rf $mnt
diff --git a/tools/testing/selftests/vm/userfaultfd.c b/tools/testing/selftests/vm/userfaultfd.c
index d753a91..a5e5808 100644
--- a/tools/testing/selftests/vm/userfaultfd.c
+++ b/tools/testing/selftests/vm/userfaultfd.c
@@ -101,8 +101,9 @@ pthread_attr_t attr;
 				 ~(unsigned long)(sizeof(unsigned long long) \
 						  -  1)))
 
-#ifndef HUGETLB_TEST
+#if !defined(HUGETLB_TEST) && !defined(SHMEM_TEST)
 
+/* Anonymous memory */
 #define EXPECTED_IOCTLS		((1 << _UFFDIO_WAKE) | \
 				 (1 << _UFFDIO_COPY) | \
 				 (1 << _UFFDIO_ZEROPAGE))
@@ -127,10 +128,13 @@ static void allocate_area(void **alloc_area)
 	}
 }
 
-#else /* HUGETLB_TEST */
+#else /* HUGETLB_TEST or SHMEM_TEST */
 
 #define EXPECTED_IOCTLS		UFFD_API_RANGE_IOCTLS_BASIC
 
+#ifdef HUGETLB_TEST
+
+/* HugeTLB memory */
 static int release_pages(char *rel_area)
 {
 	int ret = 0;
@@ -162,8 +166,37 @@ static void allocate_area(void **alloc_area)
 		huge_fd_off0 = *alloc_area;
 }
 
+#elif defined(SHMEM_TEST)
+
+/* Shared memory */
+static int release_pages(char *rel_area)
+{
+	int ret = 0;
+
+	if (madvise(rel_area, nr_pages * page_size, MADV_REMOVE)) {
+		perror("madvise");
+		ret = 1;
+	}
+
+	return ret;
+}
+
+static void allocate_area(void **alloc_area)
+{
+	*alloc_area = mmap(NULL, nr_pages * page_size, PROT_READ | PROT_WRITE,
+			   MAP_ANONYMOUS | MAP_SHARED, -1, 0);
+	if (*alloc_area == MAP_FAILED) {
+		fprintf(stderr, "shared memory mmap failed\n");
+		*alloc_area = NULL;
+	}
+}
+
+#else /* SHMEM_TEST */
+#error "Undefined test type"
 #endif /* HUGETLB_TEST */
 
+#endif /* !defined(HUGETLB_TEST) && !defined(SHMEM_TEST) */
+
 static int my_bcmp(char *str1, char *str2, size_t n)
 {
 	unsigned long i;
-- 
1.9.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

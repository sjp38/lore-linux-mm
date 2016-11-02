Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f199.google.com (mail-qk0-f199.google.com [209.85.220.199])
	by kanga.kvack.org (Postfix) with ESMTP id D4DEC6B02B8
	for <linux-mm@kvack.org>; Wed,  2 Nov 2016 15:34:12 -0400 (EDT)
Received: by mail-qk0-f199.google.com with SMTP id k201so24593383qke.6
        for <linux-mm@kvack.org>; Wed, 02 Nov 2016 12:34:12 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id s189si1940332qkh.34.2016.11.02.12.34.11
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 02 Nov 2016 12:34:12 -0700 (PDT)
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: [PATCH 27/33] userfaultfd: shmem: add userfaultfd_shmem test
Date: Wed,  2 Nov 2016 20:33:59 +0100
Message-Id: <1478115245-32090-28-git-send-email-aarcange@redhat.com>
In-Reply-To: <1478115245-32090-1-git-send-email-aarcange@redhat.com>
References: <1478115245-32090-1-git-send-email-aarcange@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, Michael Rapoport <RAPOPORT@il.ibm.com>, "Dr. David Alan Gilbert"@v2.random, " <dgilbert@redhat.com>,  Mike Kravetz <mike.kravetz@oracle.com>,  Shaohua Li <shli@fb.com>,  Pavel Emelyanov <xemul@parallels.com>"@v2.random

From: Mike Rapoport <rppt@linux.vnet.ibm.com>

The test verifies that anonymous shared mapping can be used with userfault
using the existing testing method.
The shared memory area is allocated using mmap(..., MAP_SHARED |
MAP_ANONYMOUS, ...) and released using madvise(MADV_REMOVE)

Signed-off-by: Mike Rapoport <rppt@linux.vnet.ibm.com>
Signed-off-by: Andrea Arcangeli <aarcange@redhat.com>
---
 tools/testing/selftests/vm/Makefile      |  4 ++++
 tools/testing/selftests/vm/run_vmtests   | 11 ++++++++++
 tools/testing/selftests/vm/userfaultfd.c | 37 ++++++++++++++++++++++++++++++--
 3 files changed, 50 insertions(+), 2 deletions(-)

diff --git a/tools/testing/selftests/vm/Makefile b/tools/testing/selftests/vm/Makefile
index 0114aac..900dfaf 100644
--- a/tools/testing/selftests/vm/Makefile
+++ b/tools/testing/selftests/vm/Makefile
@@ -11,6 +11,7 @@ BINARIES += thuge-gen
 BINARIES += transhuge-stress
 BINARIES += userfaultfd
 BINARIES += userfaultfd_hugetlb
+BINARIES += userfaultfd_shmem
 BINARIES += mlock-random-test
 
 all: $(BINARIES)
@@ -22,6 +23,9 @@ userfaultfd: userfaultfd.c ../../../../usr/include/linux/kernel.h
 userfaultfd_hugetlb: userfaultfd.c ../../../../usr/include/linux/kernel.h
 	$(CC) $(CFLAGS) -DHUGETLB_TEST -O2 -o $@ $< -lpthread
 
+userfaultfd_shmem: userfaultfd.c ../../../../usr/include/linux/kernel.h
+	$(CC) $(CFLAGS) -DSHMEM_TEST -O2 -o $@ $< -lpthread
+
 mlock-random-test: mlock-random-test.c
 	$(CC) $(CFLAGS) -o $@ $< -lcap
 
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
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

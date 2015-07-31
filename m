Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f52.google.com (mail-pa0-f52.google.com [209.85.220.52])
	by kanga.kvack.org (Postfix) with ESMTP id 8B32B6B0254
	for <linux-mm@kvack.org>; Thu, 30 Jul 2015 21:09:37 -0400 (EDT)
Received: by padck2 with SMTP id ck2so31643452pad.0
        for <linux-mm@kvack.org>; Thu, 30 Jul 2015 18:09:37 -0700 (PDT)
Received: from userp1040.oracle.com (userp1040.oracle.com. [156.151.31.81])
        by mx.google.com with ESMTPS id le8si6093228pab.136.2015.07.30.18.09.35
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 30 Jul 2015 18:09:36 -0700 (PDT)
From: Mike Kravetz <mike.kravetz@oracle.com>
Subject: [PATCH 1/3] Reverted "selftests: add hugetlbfstest"
Date: Thu, 30 Jul 2015 17:59:51 -0700
Message-Id: <1438304393-30413-2-git-send-email-mike.kravetz@oracle.com>
In-Reply-To: <1438304393-30413-1-git-send-email-mike.kravetz@oracle.com>
References: <1438304393-30413-1-git-send-email-mike.kravetz@oracle.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, joern@purestorage.com
Cc: Davidlohr Bueso <dave@stgolabs.net>, David Rientjes <rientjes@google.com>, Mike Kravetz <mike.kravetz@oracle.com>

This manually reverts 7e50533d4b84289e4f01de56d6f98e9c64e2229e

The hugetlbfstest test depends on hugetlb pages being counted
in a task's rss.  This functionality is not in the kernel, so
the test will always fail.  Remove test to avoid confusion.

Signed-off-by: Mike Kravetz <mike.kravetz@oracle.com>
---
 tools/testing/selftests/vm/Makefile        |  2 +-
 tools/testing/selftests/vm/hugetlbfstest.c | 86 ------------------------------
 tools/testing/selftests/vm/run_vmtests     | 11 ----
 3 files changed, 1 insertion(+), 98 deletions(-)
 delete mode 100644 tools/testing/selftests/vm/hugetlbfstest.c

diff --git a/tools/testing/selftests/vm/Makefile b/tools/testing/selftests/vm/Makefile
index f900e27..1b700f8 100644
--- a/tools/testing/selftests/vm/Makefile
+++ b/tools/testing/selftests/vm/Makefile
@@ -1,7 +1,7 @@
 # Makefile for vm selftests
 
 CFLAGS = -Wall
-BINARIES = hugepage-mmap hugepage-shm map_hugetlb thuge-gen hugetlbfstest
+BINARIES = hugepage-mmap hugepage-shm map_hugetlb thuge-gen
 BINARIES += mlock2-tests
 BINARIES += on-fault-limit
 BINARIES += transhuge-stress
diff --git a/tools/testing/selftests/vm/hugetlbfstest.c b/tools/testing/selftests/vm/hugetlbfstest.c
deleted file mode 100644
index 02e1072..0000000
--- a/tools/testing/selftests/vm/hugetlbfstest.c
+++ /dev/null
@@ -1,86 +0,0 @@
-#define _GNU_SOURCE
-#include <assert.h>
-#include <fcntl.h>
-#include <stdio.h>
-#include <stdlib.h>
-#include <string.h>
-#include <sys/mman.h>
-#include <sys/stat.h>
-#include <sys/types.h>
-#include <unistd.h>
-
-typedef unsigned long long u64;
-
-static size_t length = 1 << 24;
-
-static u64 read_rss(void)
-{
-	char buf[4096], *s = buf;
-	int i, fd;
-	u64 rss;
-
-	fd = open("/proc/self/statm", O_RDONLY);
-	assert(fd > 2);
-	memset(buf, 0, sizeof(buf));
-	read(fd, buf, sizeof(buf) - 1);
-	for (i = 0; i < 1; i++)
-		s = strchr(s, ' ') + 1;
-	rss = strtoull(s, NULL, 10);
-	return rss << 12; /* assumes 4k pagesize */
-}
-
-static void do_mmap(int fd, int extra_flags, int unmap)
-{
-	int *p;
-	int flags = MAP_PRIVATE | MAP_POPULATE | extra_flags;
-	u64 before, after;
-	int ret;
-
-	before = read_rss();
-	p = mmap(NULL, length, PROT_READ | PROT_WRITE, flags, fd, 0);
-	assert(p != MAP_FAILED ||
-			!"mmap returned an unexpected error");
-	after = read_rss();
-	assert(llabs(after - before - length) < 0x40000 ||
-			!"rss didn't grow as expected");
-	if (!unmap)
-		return;
-	ret = munmap(p, length);
-	assert(!ret || !"munmap returned an unexpected error");
-	after = read_rss();
-	assert(llabs(after - before) < 0x40000 ||
-			!"rss didn't shrink as expected");
-}
-
-static int open_file(const char *path)
-{
-	int fd, err;
-
-	unlink(path);
-	fd = open(path, O_CREAT | O_RDWR | O_TRUNC | O_EXCL
-			| O_LARGEFILE | O_CLOEXEC, 0600);
-	assert(fd > 2);
-	unlink(path);
-	err = ftruncate(fd, length);
-	assert(!err);
-	return fd;
-}
-
-int main(void)
-{
-	int hugefd, fd;
-
-	fd = open_file("/dev/shm/hugetlbhog");
-	hugefd = open_file("/hugepages/hugetlbhog");
-
-	system("echo 100 > /proc/sys/vm/nr_hugepages");
-	do_mmap(-1, MAP_ANONYMOUS, 1);
-	do_mmap(fd, 0, 1);
-	do_mmap(-1, MAP_ANONYMOUS | MAP_HUGETLB, 1);
-	do_mmap(hugefd, 0, 1);
-	do_mmap(hugefd, MAP_HUGETLB, 1);
-	/* Leak the last one to test do_exit() */
-	do_mmap(-1, MAP_ANONYMOUS | MAP_HUGETLB, 0);
-	printf("oll korrekt.\n");
-	return 0;
-}
diff --git a/tools/testing/selftests/vm/run_vmtests b/tools/testing/selftests/vm/run_vmtests
index cc5a973..9837a3f 100755
--- a/tools/testing/selftests/vm/run_vmtests
+++ b/tools/testing/selftests/vm/run_vmtests
@@ -76,17 +76,6 @@ else
 fi
 
 echo "--------------------"
-echo "running hugetlbfstest"
-echo "--------------------"
-./hugetlbfstest
-if [ $? -ne 0 ]; then
-	echo "[FAIL]"
-	exitcode=1
-else
-	echo "[PASS]"
-fi
-
-echo "--------------------"
 echo "running userfaultfd"
 echo "--------------------"
 ./userfaultfd 128 32
-- 
2.1.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

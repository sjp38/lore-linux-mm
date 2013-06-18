Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx122.postini.com [74.125.245.122])
	by kanga.kvack.org (Postfix) with SMTP id A82A26B0037
	for <linux-mm@kvack.org>; Tue, 18 Jun 2013 17:32:12 -0400 (EDT)
From: Joern Engel <joern@logfs.org>
Subject: [PATCH 3/3] selftests: add hugetlbfstest
Date: Tue, 18 Jun 2013 16:02:01 -0400
Message-Id: <1371585721-28087-4-git-send-email-joern@logfs.org>
In-Reply-To: <1371585721-28087-1-git-send-email-joern@logfs.org>
References: <1371585721-28087-1-git-send-email-joern@logfs.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org, linux-mm@kvack.org
Cc: Andrew Morton <akpm@linux-foundation.org>, Joern Engel <joern@logfs.org>

As the confusing naming indicates, this test has some overlap with
pre-existing tests.  Would be nice to merge them eventually.  But since
it is only test code, cleanliness is much less important than mere
existence.

Signed-off-by: Joern Engel <joern@logfs.org>
---
 tools/testing/selftests/vm/Makefile        |    2 +-
 tools/testing/selftests/vm/hugetlbfstest.c |   84 ++++++++++++++++++++++++++++
 tools/testing/selftests/vm/run_vmtests     |   11 ++++
 3 files changed, 96 insertions(+), 1 deletion(-)
 create mode 100644 tools/testing/selftests/vm/hugetlbfstest.c

diff --git a/tools/testing/selftests/vm/Makefile b/tools/testing/selftests/vm/Makefile
index cb3f5f2..3f94e1a 100644
--- a/tools/testing/selftests/vm/Makefile
+++ b/tools/testing/selftests/vm/Makefile
@@ -2,7 +2,7 @@
 
 CC = $(CROSS_COMPILE)gcc
 CFLAGS = -Wall
-BINARIES = hugepage-mmap hugepage-shm map_hugetlb thuge-gen
+BINARIES = hugepage-mmap hugepage-shm map_hugetlb thuge-gen hugetlbfstest
 
 all: $(BINARIES)
 %: %.c
diff --git a/tools/testing/selftests/vm/hugetlbfstest.c b/tools/testing/selftests/vm/hugetlbfstest.c
new file mode 100644
index 0000000..ea40ff8
--- /dev/null
+++ b/tools/testing/selftests/vm/hugetlbfstest.c
@@ -0,0 +1,84 @@
+#define _GNU_SOURCE
+#include <assert.h>
+#include <fcntl.h>
+#include <stdio.h>
+#include <stdlib.h>
+#include <string.h>
+#include <sys/mman.h>
+#include <sys/stat.h>
+#include <sys/types.h>
+#include <unistd.h>
+
+typedef unsigned long long u64;
+
+static size_t length = 1 << 24;
+
+static u64 read_rss(void)
+{
+	char buf[4096], *s = buf;
+	int i, fd;
+	u64 rss;
+
+	fd = open("/proc/self/statm", O_RDONLY);
+	assert(fd > 2);
+	memset(buf, 0, sizeof(buf));
+	read(fd, buf, sizeof(buf) - 1);
+	for (i = 0; i < 1; i++)
+		s = strchr(s, ' ') + 1;
+	rss = strtoull(s, NULL, 10);
+	return rss << 12; /* assumes 4k pagesize */
+}
+
+static void do_mmap(int fd, int extra_flags, int unmap)
+{
+	int *p;
+	int flags = MAP_PRIVATE | MAP_POPULATE | extra_flags;
+	u64 before, after;
+
+	before = read_rss();
+	p = mmap(NULL, length, PROT_READ | PROT_WRITE, flags, fd, 0);
+	assert(p != MAP_FAILED ||
+			!"mmap returned an unexpected error");
+	after = read_rss();
+	assert(llabs(after - before - length) < 0x40000 ||
+			!"rss didn't grow as expected");
+	if (!unmap)
+		return;
+	munmap(p, length);
+	after = read_rss();
+	assert(llabs(after - before) < 0x40000 ||
+			!"rss didn't shrink as expected");
+}
+
+static int open_file(const char *path)
+{
+	int fd, err;
+
+	unlink(path);
+	fd = open(path, O_CREAT | O_RDWR | O_TRUNC | O_EXCL
+			| O_LARGEFILE | O_CLOEXEC, 0600);
+	assert(fd > 2);
+	unlink(path);
+	err = ftruncate(fd, length);
+	assert(!err);
+	return fd;
+}
+
+int main(void)
+{
+	int hugefd, fd;
+
+	fd = open_file("/dev/shm/hugetlbhog");
+	hugefd = open_file("/hugepages/hugetlbhog");
+
+	system("echo 100 > /proc/sys/vm/nr_hugepages");
+	do_mmap(-1, MAP_ANONYMOUS, 1);
+	do_mmap(fd, 0, 1);
+	do_mmap(-1, MAP_ANONYMOUS | MAP_HUGETLB, 1);
+	do_mmap(hugefd, 0, 1);
+	do_mmap(hugefd, MAP_HUGETLB, 1);
+	/* Leak the last one to test do_exit() */
+	do_mmap(-1, MAP_ANONYMOUS | MAP_HUGETLB, 0);
+	printf("oll korrekt.\n");
+	return 0;
+}
diff --git a/tools/testing/selftests/vm/run_vmtests b/tools/testing/selftests/vm/run_vmtests
index 7a9072d..c87b681 100644
--- a/tools/testing/selftests/vm/run_vmtests
+++ b/tools/testing/selftests/vm/run_vmtests
@@ -75,6 +75,17 @@ else
 	echo "[PASS]"
 fi
 
+echo "--------------------"
+echo "running hugetlbfstest"
+echo "--------------------"
+./hugetlbfstest
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
-- 
1.7.10.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

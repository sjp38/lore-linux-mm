Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yw0-f197.google.com (mail-yw0-f197.google.com [209.85.161.197])
	by kanga.kvack.org (Postfix) with ESMTP id 821676B02B4
	for <linux-mm@kvack.org>; Fri, 11 Aug 2017 19:56:40 -0400 (EDT)
Received: by mail-yw0-f197.google.com with SMTP id v17so80566983ywh.15
        for <linux-mm@kvack.org>; Fri, 11 Aug 2017 16:56:40 -0700 (PDT)
Received: from userp1040.oracle.com (userp1040.oracle.com. [156.151.31.81])
        by mx.google.com with ESMTPS id n124si538838ybg.689.2017.08.11.16.56.38
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 11 Aug 2017 16:56:38 -0700 (PDT)
From: Mike Kravetz <mike.kravetz@oracle.com>
Subject: [PATCH 2/2] selftests/memfd: Add memfd_create hugetlbfs selftest
Date: Fri, 11 Aug 2017 16:56:12 -0700
Message-Id: <1502495772-24736-3-git-send-email-mike.kravetz@oracle.com>
In-Reply-To: <1502495772-24736-1-git-send-email-mike.kravetz@oracle.com>
References: <1502495772-24736-1-git-send-email-mike.kravetz@oracle.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, linux-kernel@vger.kernel.org, linux-api@vger.kernel.org, linux-kselftest@vger.kernel.org
Cc: Hugh Dickins <hughd@google.com>, Andrea Arcangeli <aarcange@redhat.com>, Michal Hocko <mhocko@kernel.org>, "Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>, Shuah Khan <shuah@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Mike Kravetz <mike.kravetz@oracle.com>

With the addition of hugetlbfs support in memfd_create, the memfd
selftests should verify correct functionality with hugetlbfs.

Instead of writing a separate memfd hugetlbfs test, modify the
memfd_test program to take an optional argument 'hugetlbfs'.  If
the hugetlbfs argument is specified, basic memfd_create functionality
will be exercised on hugetlbfs.  If hugetlbfs is not specified, the
current functionality of the test is unchanged.

Note that many of the tests in memfd_test test file sealing operations.
hugetlbfs does not support file sealing, therefore for hugetlbfs all
sealing related tests are skipped.

In order to test on hugetlbfs, there needs to be preallocated huge pages.
A new script (run_tests) is added.  This script will first run the
existing memfd_create tests.  It will then, attempt to allocate the
required number of huge pages before running the hugetlbfs test.  At
the end of testing, it will release any huge pages allocated for testing
purposes.

Signed-off-by: Mike Kravetz <mike.kravetz@oracle.com>
---
 tools/testing/selftests/memfd/Makefile     |   2 +-
 tools/testing/selftests/memfd/memfd_test.c | 372 ++++++++++++++++++++++-------
 tools/testing/selftests/memfd/run_tests.sh |  69 ++++++
 3 files changed, 357 insertions(+), 86 deletions(-)
 create mode 100755 tools/testing/selftests/memfd/run_tests.sh

diff --git a/tools/testing/selftests/memfd/Makefile b/tools/testing/selftests/memfd/Makefile
index ad8a089..bc9d02d 100644
--- a/tools/testing/selftests/memfd/Makefile
+++ b/tools/testing/selftests/memfd/Makefile
@@ -3,7 +3,7 @@ CFLAGS += -I../../../../include/uapi/
 CFLAGS += -I../../../../include/
 CFLAGS += -I../../../../usr/include/
 
-TEST_PROGS := run_fuse_test.sh
+TEST_PROGS := run_tests.sh
 TEST_GEN_FILES := memfd_test fuse_mnt fuse_test
 
 fuse_mnt.o: CFLAGS += $(shell pkg-config fuse --cflags)
diff --git a/tools/testing/selftests/memfd/memfd_test.c b/tools/testing/selftests/memfd/memfd_test.c
index 2654689..f94c6d1 100644
--- a/tools/testing/selftests/memfd/memfd_test.c
+++ b/tools/testing/selftests/memfd/memfd_test.c
@@ -18,12 +18,48 @@
 #include <sys/wait.h>
 #include <unistd.h>
 
+#define MEMFD_STR	"memfd:"
+#define SHARED_FT_STR	"(shared file-table)"
+
 #define MFD_DEF_SIZE 8192
 #define STACK_SIZE 65536
 
+/*
+ * Default is not to test hugetlbfs
+ */
+static int hugetlbfs_test;
+static size_t mfd_def_size = MFD_DEF_SIZE;
+
+/*
+ * Copied from mlock2-tests.c
+ */
+static unsigned long default_huge_page_size(void)
+{
+	unsigned long hps = 0;
+	char *line = NULL;
+	size_t linelen = 0;
+	FILE *f = fopen("/proc/meminfo", "r");
+
+	if (!f)
+		return 0;
+	while (getline(&line, &linelen, f) > 0) {
+		if (sscanf(line, "Hugepagesize:       %lu kB", &hps) == 1) {
+			hps <<= 10;
+			break;
+		}
+	}
+
+	free(line);
+	fclose(f);
+	return hps;
+}
+
 static int sys_memfd_create(const char *name,
 			    unsigned int flags)
 {
+	if (hugetlbfs_test)
+		flags |= MFD_HUGETLB;
+
 	return syscall(__NR_memfd_create, name, flags);
 }
 
@@ -150,7 +186,7 @@ static void *mfd_assert_mmap_shared(int fd)
 	void *p;
 
 	p = mmap(NULL,
-		 MFD_DEF_SIZE,
+		 mfd_def_size,
 		 PROT_READ | PROT_WRITE,
 		 MAP_SHARED,
 		 fd,
@@ -168,7 +204,7 @@ static void *mfd_assert_mmap_private(int fd)
 	void *p;
 
 	p = mmap(NULL,
-		 MFD_DEF_SIZE,
+		 mfd_def_size,
 		 PROT_READ,
 		 MAP_PRIVATE,
 		 fd,
@@ -223,7 +259,7 @@ static void mfd_assert_read(int fd)
 
 	/* verify PROT_READ *is* allowed */
 	p = mmap(NULL,
-		 MFD_DEF_SIZE,
+		 mfd_def_size,
 		 PROT_READ,
 		 MAP_PRIVATE,
 		 fd,
@@ -232,11 +268,11 @@ static void mfd_assert_read(int fd)
 		printf("mmap() failed: %m\n");
 		abort();
 	}
-	munmap(p, MFD_DEF_SIZE);
+	munmap(p, mfd_def_size);
 
 	/* verify MAP_PRIVATE is *always* allowed (even writable) */
 	p = mmap(NULL,
-		 MFD_DEF_SIZE,
+		 mfd_def_size,
 		 PROT_READ | PROT_WRITE,
 		 MAP_PRIVATE,
 		 fd,
@@ -245,7 +281,7 @@ static void mfd_assert_read(int fd)
 		printf("mmap() failed: %m\n");
 		abort();
 	}
-	munmap(p, MFD_DEF_SIZE);
+	munmap(p, mfd_def_size);
 }
 
 static void mfd_assert_write(int fd)
@@ -254,16 +290,22 @@ static void mfd_assert_write(int fd)
 	void *p;
 	int r;
 
-	/* verify write() succeeds */
-	l = write(fd, "\0\0\0\0", 4);
-	if (l != 4) {
-		printf("write() failed: %m\n");
-		abort();
+	/*
+	 * huegtlbfs does not support write, but we want to
+	 * verify everything else here.
+	 */
+	if (!hugetlbfs_test) {
+		/* verify write() succeeds */
+		l = write(fd, "\0\0\0\0", 4);
+		if (l != 4) {
+			printf("write() failed: %m\n");
+			abort();
+		}
 	}
 
 	/* verify PROT_READ | PROT_WRITE is allowed */
 	p = mmap(NULL,
-		 MFD_DEF_SIZE,
+		 mfd_def_size,
 		 PROT_READ | PROT_WRITE,
 		 MAP_SHARED,
 		 fd,
@@ -273,11 +315,11 @@ static void mfd_assert_write(int fd)
 		abort();
 	}
 	*(char *)p = 0;
-	munmap(p, MFD_DEF_SIZE);
+	munmap(p, mfd_def_size);
 
 	/* verify PROT_WRITE is allowed */
 	p = mmap(NULL,
-		 MFD_DEF_SIZE,
+		 mfd_def_size,
 		 PROT_WRITE,
 		 MAP_SHARED,
 		 fd,
@@ -287,12 +329,12 @@ static void mfd_assert_write(int fd)
 		abort();
 	}
 	*(char *)p = 0;
-	munmap(p, MFD_DEF_SIZE);
+	munmap(p, mfd_def_size);
 
 	/* verify PROT_READ with MAP_SHARED is allowed and a following
 	 * mprotect(PROT_WRITE) allows writing */
 	p = mmap(NULL,
-		 MFD_DEF_SIZE,
+		 mfd_def_size,
 		 PROT_READ,
 		 MAP_SHARED,
 		 fd,
@@ -302,20 +344,20 @@ static void mfd_assert_write(int fd)
 		abort();
 	}
 
-	r = mprotect(p, MFD_DEF_SIZE, PROT_READ | PROT_WRITE);
+	r = mprotect(p, mfd_def_size, PROT_READ | PROT_WRITE);
 	if (r < 0) {
 		printf("mprotect() failed: %m\n");
 		abort();
 	}
 
 	*(char *)p = 0;
-	munmap(p, MFD_DEF_SIZE);
+	munmap(p, mfd_def_size);
 
 	/* verify PUNCH_HOLE works */
 	r = fallocate(fd,
 		      FALLOC_FL_PUNCH_HOLE | FALLOC_FL_KEEP_SIZE,
 		      0,
-		      MFD_DEF_SIZE);
+		      mfd_def_size);
 	if (r < 0) {
 		printf("fallocate(PUNCH_HOLE) failed: %m\n");
 		abort();
@@ -337,7 +379,7 @@ static void mfd_fail_write(int fd)
 
 	/* verify PROT_READ | PROT_WRITE is not allowed */
 	p = mmap(NULL,
-		 MFD_DEF_SIZE,
+		 mfd_def_size,
 		 PROT_READ | PROT_WRITE,
 		 MAP_SHARED,
 		 fd,
@@ -349,7 +391,7 @@ static void mfd_fail_write(int fd)
 
 	/* verify PROT_WRITE is not allowed */
 	p = mmap(NULL,
-		 MFD_DEF_SIZE,
+		 mfd_def_size,
 		 PROT_WRITE,
 		 MAP_SHARED,
 		 fd,
@@ -362,13 +404,13 @@ static void mfd_fail_write(int fd)
 	/* Verify PROT_READ with MAP_SHARED with a following mprotect is not
 	 * allowed. Note that for r/w the kernel already prevents the mmap. */
 	p = mmap(NULL,
-		 MFD_DEF_SIZE,
+		 mfd_def_size,
 		 PROT_READ,
 		 MAP_SHARED,
 		 fd,
 		 0);
 	if (p != MAP_FAILED) {
-		r = mprotect(p, MFD_DEF_SIZE, PROT_READ | PROT_WRITE);
+		r = mprotect(p, mfd_def_size, PROT_READ | PROT_WRITE);
 		if (r >= 0) {
 			printf("mmap()+mprotect() didn't fail as expected\n");
 			abort();
@@ -379,7 +421,7 @@ static void mfd_fail_write(int fd)
 	r = fallocate(fd,
 		      FALLOC_FL_PUNCH_HOLE | FALLOC_FL_KEEP_SIZE,
 		      0,
-		      MFD_DEF_SIZE);
+		      mfd_def_size);
 	if (r >= 0) {
 		printf("fallocate(PUNCH_HOLE) didn't fail as expected\n");
 		abort();
@@ -390,13 +432,13 @@ static void mfd_assert_shrink(int fd)
 {
 	int r, fd2;
 
-	r = ftruncate(fd, MFD_DEF_SIZE / 2);
+	r = ftruncate(fd, mfd_def_size / 2);
 	if (r < 0) {
 		printf("ftruncate(SHRINK) failed: %m\n");
 		abort();
 	}
 
-	mfd_assert_size(fd, MFD_DEF_SIZE / 2);
+	mfd_assert_size(fd, mfd_def_size / 2);
 
 	fd2 = mfd_assert_open(fd,
 			      O_RDWR | O_CREAT | O_TRUNC,
@@ -410,7 +452,7 @@ static void mfd_fail_shrink(int fd)
 {
 	int r;
 
-	r = ftruncate(fd, MFD_DEF_SIZE / 2);
+	r = ftruncate(fd, mfd_def_size / 2);
 	if (r >= 0) {
 		printf("ftruncate(SHRINK) didn't fail as expected\n");
 		abort();
@@ -425,31 +467,31 @@ static void mfd_assert_grow(int fd)
 {
 	int r;
 
-	r = ftruncate(fd, MFD_DEF_SIZE * 2);
+	r = ftruncate(fd, mfd_def_size * 2);
 	if (r < 0) {
 		printf("ftruncate(GROW) failed: %m\n");
 		abort();
 	}
 
-	mfd_assert_size(fd, MFD_DEF_SIZE * 2);
+	mfd_assert_size(fd, mfd_def_size * 2);
 
 	r = fallocate(fd,
 		      0,
 		      0,
-		      MFD_DEF_SIZE * 4);
+		      mfd_def_size * 4);
 	if (r < 0) {
 		printf("fallocate(ALLOC) failed: %m\n");
 		abort();
 	}
 
-	mfd_assert_size(fd, MFD_DEF_SIZE * 4);
+	mfd_assert_size(fd, mfd_def_size * 4);
 }
 
 static void mfd_fail_grow(int fd)
 {
 	int r;
 
-	r = ftruncate(fd, MFD_DEF_SIZE * 2);
+	r = ftruncate(fd, mfd_def_size * 2);
 	if (r >= 0) {
 		printf("ftruncate(GROW) didn't fail as expected\n");
 		abort();
@@ -458,7 +500,7 @@ static void mfd_fail_grow(int fd)
 	r = fallocate(fd,
 		      0,
 		      0,
-		      MFD_DEF_SIZE * 4);
+		      mfd_def_size * 4);
 	if (r >= 0) {
 		printf("fallocate(ALLOC) didn't fail as expected\n");
 		abort();
@@ -467,25 +509,37 @@ static void mfd_fail_grow(int fd)
 
 static void mfd_assert_grow_write(int fd)
 {
-	static char buf[MFD_DEF_SIZE * 8];
+	static char *buf;
 	ssize_t l;
 
-	l = pwrite(fd, buf, sizeof(buf), 0);
-	if (l != sizeof(buf)) {
+	buf = malloc(mfd_def_size * 8);
+	if (!buf) {
+		printf("malloc(%d) failed: %m\n", mfd_def_size * 8);
+		abort();
+	}
+
+	l = pwrite(fd, buf, mfd_def_size * 8, 0);
+	if (l != (mfd_def_size * 8)) {
 		printf("pwrite() failed: %m\n");
 		abort();
 	}
 
-	mfd_assert_size(fd, MFD_DEF_SIZE * 8);
+	mfd_assert_size(fd, mfd_def_size * 8);
 }
 
 static void mfd_fail_grow_write(int fd)
 {
-	static char buf[MFD_DEF_SIZE * 8];
+	static char *buf;
 	ssize_t l;
 
-	l = pwrite(fd, buf, sizeof(buf), 0);
-	if (l == sizeof(buf)) {
+	buf = malloc(mfd_def_size * 8);
+	if (!buf) {
+		printf("malloc(%d) failed: %m\n", mfd_def_size * 8);
+		abort();
+	}
+
+	l = pwrite(fd, buf, mfd_def_size * 8, 0);
+	if (l == (mfd_def_size * 8)) {
 		printf("pwrite() didn't fail as expected\n");
 		abort();
 	}
@@ -543,6 +597,8 @@ static void test_create(void)
 	char buf[2048];
 	int fd;
 
+	printf("%s CREATE\n", MEMFD_STR);
+
 	/* test NULL name */
 	mfd_fail_new(NULL, 0);
 
@@ -570,13 +626,18 @@ static void test_create(void)
 	fd = mfd_assert_new("", 0, MFD_CLOEXEC);
 	close(fd);
 
-	/* verify MFD_ALLOW_SEALING is allowed */
-	fd = mfd_assert_new("", 0, MFD_ALLOW_SEALING);
-	close(fd);
-
-	/* verify MFD_ALLOW_SEALING | MFD_CLOEXEC is allowed */
-	fd = mfd_assert_new("", 0, MFD_ALLOW_SEALING | MFD_CLOEXEC);
-	close(fd);
+	if (!hugetlbfs_test) {
+		/* verify MFD_ALLOW_SEALING is allowed */
+		fd = mfd_assert_new("", 0, MFD_ALLOW_SEALING);
+		close(fd);
+
+		/* verify MFD_ALLOW_SEALING | MFD_CLOEXEC is allowed */
+		fd = mfd_assert_new("", 0, MFD_ALLOW_SEALING | MFD_CLOEXEC);
+		close(fd);
+	} else {
+		/* sealing is not supported on hugetlbfs */
+		mfd_fail_new("", MFD_ALLOW_SEALING);
+	}
 }
 
 /*
@@ -587,8 +648,14 @@ static void test_basic(void)
 {
 	int fd;
 
+	/* hugetlbfs does not contain sealing support */
+	if (hugetlbfs_test)
+		return;
+
+	printf("%s BASIC\n", MEMFD_STR);
+
 	fd = mfd_assert_new("kern_memfd_basic",
-			    MFD_DEF_SIZE,
+			    mfd_def_size,
 			    MFD_CLOEXEC | MFD_ALLOW_SEALING);
 
 	/* add basic seals */
@@ -619,7 +686,7 @@ static void test_basic(void)
 
 	/* verify sealing does not work without MFD_ALLOW_SEALING */
 	fd = mfd_assert_new("kern_memfd_basic",
-			    MFD_DEF_SIZE,
+			    mfd_def_size,
 			    MFD_CLOEXEC);
 	mfd_assert_has_seals(fd, F_SEAL_SEAL);
 	mfd_fail_add_seals(fd, F_SEAL_SHRINK |
@@ -630,6 +697,28 @@ static void test_basic(void)
 }
 
 /*
+ * hugetlbfs doesn't support seals or write, so just verify grow and shrink
+ * on a hugetlbfs file created via memfd_create.
+ */
+static void test_hugetlbfs_grow_shrink(void)
+{
+	int fd;
+
+	printf("%s HUGETLBFS-GROW-SHRINK\n", MEMFD_STR);
+
+	fd = mfd_assert_new("kern_memfd_seal_write",
+			    mfd_def_size,
+			    MFD_CLOEXEC);
+
+	mfd_assert_read(fd);
+	mfd_assert_write(fd);
+	mfd_assert_shrink(fd);
+	mfd_assert_grow(fd);
+
+	close(fd);
+}
+
+/*
  * Test SEAL_WRITE
  * Test whether SEAL_WRITE actually prevents modifications.
  */
@@ -637,8 +726,17 @@ static void test_seal_write(void)
 {
 	int fd;
 
+	/*
+	 * hugetlbfs does not contain sealing or write support.  Just test
+	 * basic grow and shrink via test_hugetlbfs_grow_shrink.
+	 */
+	if (hugetlbfs_test)
+		return test_hugetlbfs_grow_shrink();
+
+	printf("%s SEAL-WRITE\n", MEMFD_STR);
+
 	fd = mfd_assert_new("kern_memfd_seal_write",
-			    MFD_DEF_SIZE,
+			    mfd_def_size,
 			    MFD_CLOEXEC | MFD_ALLOW_SEALING);
 	mfd_assert_has_seals(fd, 0);
 	mfd_assert_add_seals(fd, F_SEAL_WRITE);
@@ -661,8 +759,14 @@ static void test_seal_shrink(void)
 {
 	int fd;
 
+	/* hugetlbfs does not contain sealing support */
+	if (hugetlbfs_test)
+		return;
+
+	printf("%s SEAL-SHRINK\n", MEMFD_STR);
+
 	fd = mfd_assert_new("kern_memfd_seal_shrink",
-			    MFD_DEF_SIZE,
+			    mfd_def_size,
 			    MFD_CLOEXEC | MFD_ALLOW_SEALING);
 	mfd_assert_has_seals(fd, 0);
 	mfd_assert_add_seals(fd, F_SEAL_SHRINK);
@@ -685,8 +789,14 @@ static void test_seal_grow(void)
 {
 	int fd;
 
+	/* hugetlbfs does not contain sealing support */
+	if (hugetlbfs_test)
+		return;
+
+	printf("%s SEAL-GROW\n", MEMFD_STR);
+
 	fd = mfd_assert_new("kern_memfd_seal_grow",
-			    MFD_DEF_SIZE,
+			    mfd_def_size,
 			    MFD_CLOEXEC | MFD_ALLOW_SEALING);
 	mfd_assert_has_seals(fd, 0);
 	mfd_assert_add_seals(fd, F_SEAL_GROW);
@@ -709,8 +819,14 @@ static void test_seal_resize(void)
 {
 	int fd;
 
+	/* hugetlbfs does not contain sealing support */
+	if (hugetlbfs_test)
+		return;
+
+	printf("%s SEAL-RESIZE\n", MEMFD_STR);
+
 	fd = mfd_assert_new("kern_memfd_seal_resize",
-			    MFD_DEF_SIZE,
+			    mfd_def_size,
 			    MFD_CLOEXEC | MFD_ALLOW_SEALING);
 	mfd_assert_has_seals(fd, 0);
 	mfd_assert_add_seals(fd, F_SEAL_SHRINK | F_SEAL_GROW);
@@ -726,15 +842,52 @@ static void test_seal_resize(void)
 }
 
 /*
+ * hugetlbfs does not support seals.  Basic test to dup the memfd created
+ * fd and perform some basic operations on it.
+ */
+static void hugetlbfs_dup(char *b_suffix)
+{
+	int fd, fd2;
+
+	printf("%s HUGETLBFS-DUP %s\n", MEMFD_STR, b_suffix);
+
+	fd = mfd_assert_new("kern_memfd_share_dup",
+			    mfd_def_size,
+			    MFD_CLOEXEC);
+
+	fd2 = mfd_assert_dup(fd);
+
+	mfd_assert_read(fd);
+	mfd_assert_write(fd);
+
+	mfd_assert_shrink(fd2);
+	mfd_assert_grow(fd2);
+
+	close(fd2);
+	close(fd);
+}
+
+/*
  * Test sharing via dup()
  * Test that seals are shared between dupped FDs and they're all equal.
  */
-static void test_share_dup(void)
+static void test_share_dup(char *banner, char *b_suffix)
 {
 	int fd, fd2;
 
+	/*
+	 * hugetlbfs does not contain sealing support.  Perform some
+	 * basic testing on dup'ed fd instead via hugetlbfs_dup.
+	 */
+	if (hugetlbfs_test) {
+		hugetlbfs_dup(b_suffix);
+		return;
+	}
+
+	printf("%s %s %s\n", MEMFD_STR, banner, b_suffix);
+
 	fd = mfd_assert_new("kern_memfd_share_dup",
-			    MFD_DEF_SIZE,
+			    mfd_def_size,
 			    MFD_CLOEXEC | MFD_ALLOW_SEALING);
 	mfd_assert_has_seals(fd, 0);
 
@@ -768,13 +921,19 @@ static void test_share_dup(void)
  * Test sealing with active mmap()s
  * Modifying seals is only allowed if no other mmap() refs exist.
  */
-static void test_share_mmap(void)
+static void test_share_mmap(char *banner, char *b_suffix)
 {
 	int fd;
 	void *p;
 
+	/* hugetlbfs does not contain sealing support */
+	if (hugetlbfs_test)
+		return;
+
+	printf("%s %s %s\n", MEMFD_STR,  banner, b_suffix);
+
 	fd = mfd_assert_new("kern_memfd_share_mmap",
-			    MFD_DEF_SIZE,
+			    mfd_def_size,
 			    MFD_CLOEXEC | MFD_ALLOW_SEALING);
 	mfd_assert_has_seals(fd, 0);
 
@@ -784,14 +943,40 @@ static void test_share_mmap(void)
 	mfd_assert_has_seals(fd, 0);
 	mfd_assert_add_seals(fd, F_SEAL_SHRINK);
 	mfd_assert_has_seals(fd, F_SEAL_SHRINK);
-	munmap(p, MFD_DEF_SIZE);
+	munmap(p, mfd_def_size);
 
 	/* readable ref allows sealing */
 	p = mfd_assert_mmap_private(fd);
 	mfd_assert_add_seals(fd, F_SEAL_WRITE);
 	mfd_assert_has_seals(fd, F_SEAL_WRITE | F_SEAL_SHRINK);
-	munmap(p, MFD_DEF_SIZE);
+	munmap(p, mfd_def_size);
+
+	close(fd);
+}
+
+/*
+ * Basic test to make sure we can open the hugetlbfs fd via /proc and
+ * perform some simple operations on it.
+ */
+static void hugetlbfs_proc_open(char *b_suffix)
+{
+	int fd, fd2;
+
+	printf("%s HUGETLBFS-PROC-OPEN %s\n", MEMFD_STR, b_suffix);
 
+	fd = mfd_assert_new("kern_memfd_share_open",
+			    mfd_def_size,
+			    MFD_CLOEXEC);
+
+	fd2 = mfd_assert_open(fd, O_RDWR, 0);
+
+	mfd_assert_read(fd);
+	mfd_assert_write(fd);
+
+	mfd_assert_shrink(fd2);
+	mfd_assert_grow(fd2);
+
+	close(fd2);
 	close(fd);
 }
 
@@ -801,12 +986,23 @@ static void test_share_mmap(void)
  * This is *not* like dup(), but like a real separate open(). Make sure the
  * semantics are as expected and we correctly check for RDONLY / WRONLY / RDWR.
  */
-static void test_share_open(void)
+static void test_share_open(char *banner, char *b_suffix)
 {
 	int fd, fd2;
 
+	/*
+	 * hugetlbfs does not contain sealing support.  So test basic
+	 * functionality of using /proc fd via hugetlbfs_proc_open
+	 */
+	if (hugetlbfs_test) {
+		hugetlbfs_proc_open(b_suffix);
+		return;
+	}
+
+	printf("%s %s %s\n", MEMFD_STR, banner, b_suffix);
+
 	fd = mfd_assert_new("kern_memfd_share_open",
-			    MFD_DEF_SIZE,
+			    mfd_def_size,
 			    MFD_CLOEXEC | MFD_ALLOW_SEALING);
 	mfd_assert_has_seals(fd, 0);
 
@@ -841,13 +1037,19 @@ static void test_share_open(void)
  * Test sharing via fork()
  * Test whether seal-modifications work as expected with forked childs.
  */
-static void test_share_fork(void)
+static void test_share_fork(char *banner, char *b_suffix)
 {
 	int fd;
 	pid_t pid;
 
+	/* hugetlbfs does not contain sealing support */
+	if (hugetlbfs_test)
+		return;
+
+	printf("%s %s %s\n", MEMFD_STR, banner, b_suffix);
+
 	fd = mfd_assert_new("kern_memfd_share_fork",
-			    MFD_DEF_SIZE,
+			    mfd_def_size,
 			    MFD_CLOEXEC | MFD_ALLOW_SEALING);
 	mfd_assert_has_seals(fd, 0);
 
@@ -870,40 +1072,40 @@ int main(int argc, char **argv)
 {
 	pid_t pid;
 
-	printf("memfd: CREATE\n");
+	if (argc == 2) {
+		if (!strcmp(argv[1], "hugetlbfs")) {
+			unsigned long hpage_size = default_huge_page_size();
+
+			if (!hpage_size) {
+				printf("Unable to determine huge page size\n");
+				abort();
+			}
+
+			hugetlbfs_test = 1;
+			mfd_def_size = hpage_size * 2;
+		}
+	}
+
 	test_create();
-	printf("memfd: BASIC\n");
 	test_basic();
 
-	printf("memfd: SEAL-WRITE\n");
 	test_seal_write();
-	printf("memfd: SEAL-SHRINK\n");
 	test_seal_shrink();
-	printf("memfd: SEAL-GROW\n");
 	test_seal_grow();
-	printf("memfd: SEAL-RESIZE\n");
 	test_seal_resize();
 
-	printf("memfd: SHARE-DUP\n");
-	test_share_dup();
-	printf("memfd: SHARE-MMAP\n");
-	test_share_mmap();
-	printf("memfd: SHARE-OPEN\n");
-	test_share_open();
-	printf("memfd: SHARE-FORK\n");
-	test_share_fork();
+	test_share_dup("SHARE-DUP", "");
+	test_share_mmap("SHARE-MMAP", "");
+	test_share_open("SHARE-OPEN", "");
+	test_share_fork("SHARE-FORK", "");
 
 	/* Run test-suite in a multi-threaded environment with a shared
 	 * file-table. */
 	pid = spawn_idle_thread(CLONE_FILES | CLONE_FS | CLONE_VM);
-	printf("memfd: SHARE-DUP (shared file-table)\n");
-	test_share_dup();
-	printf("memfd: SHARE-MMAP (shared file-table)\n");
-	test_share_mmap();
-	printf("memfd: SHARE-OPEN (shared file-table)\n");
-	test_share_open();
-	printf("memfd: SHARE-FORK (shared file-table)\n");
-	test_share_fork();
+	test_share_dup("SHARE-DUP", SHARED_FT_STR);
+	test_share_mmap("SHARE-MMAP", SHARED_FT_STR);
+	test_share_open("SHARE-OPEN", SHARED_FT_STR);
+	test_share_fork("SHARE-FORK", SHARED_FT_STR);
 	join_idle_thread(pid);
 
 	printf("memfd: DONE\n");
diff --git a/tools/testing/selftests/memfd/run_tests.sh b/tools/testing/selftests/memfd/run_tests.sh
new file mode 100755
index 0000000..daabb35
--- /dev/null
+++ b/tools/testing/selftests/memfd/run_tests.sh
@@ -0,0 +1,69 @@
+#!/bin/bash
+# please run as root
+
+#
+# Normal tests requiring no special resources
+#
+./run_fuse_test.sh
+./memfd_test
+
+#
+# To test memfd_create with hugetlbfs, there needs to be hpages_test
+# huge pages free.  Attempt to allocate enough pages to test.
+#
+hpages_test=8
+
+#
+# Get count of free huge pages from /proc/meminfo
+#
+while read name size unit; do
+        if [ "$name" = "HugePages_Free:" ]; then
+                freepgs=$size
+        fi
+done < /proc/meminfo
+
+#
+# If not enough free huge pages for test, attempt to increase
+#
+if [ -n "$freepgs" ] && [ $freepgs -lt $hpages_test ]; then
+	nr_hugepgs=`cat /proc/sys/vm/nr_hugepages`
+	hpages_needed=`expr $hpages_test - $freepgs`
+
+	echo 3 > /proc/sys/vm/drop_caches
+	echo $(( $hpages_needed + $nr_hugepgs )) > /proc/sys/vm/nr_hugepages
+	if [ $? -ne 0 ]; then
+		echo "Please run this test as root"
+		exit 1
+	fi
+	while read name size unit; do
+		if [ "$name" = "HugePages_Free:" ]; then
+			freepgs=$size
+		fi
+	done < /proc/meminfo
+fi
+
+#
+# If still not enough huge pages available, exit.  But, give back any huge
+# pages potentially allocated above.
+#
+if [ $freepgs -lt $hpages_test ]; then
+	# nr_hugepgs non-zero only if we attempted to increase
+	if [ -n "$nr_hugepgs" ]; then
+		echo $nr_hugepgs > /proc/sys/vm/nr_hugepages
+	fi
+	printf "Not enough huge pages available (%d < %d)\n" \
+		$freepgs $needpgs
+	exit 1
+fi
+
+#
+# Run the hugetlbfs test
+#
+./memfd_test hugetlbfs
+
+#
+# Give back any huge pages allocated for the test
+#
+if [ -n "$nr_hugepgs" ]; then
+	echo $nr_hugepgs > /proc/sys/vm/nr_hugepages
+fi
-- 
2.7.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

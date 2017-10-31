Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f70.google.com (mail-oi0-f70.google.com [209.85.218.70])
	by kanga.kvack.org (Postfix) with ESMTP id 462FF6B026E
	for <linux-mm@kvack.org>; Tue, 31 Oct 2017 14:41:24 -0400 (EDT)
Received: by mail-oi0-f70.google.com with SMTP id 82so19786201oid.11
        for <linux-mm@kvack.org>; Tue, 31 Oct 2017 11:41:24 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id 96si1203497ote.459.2017.10.31.11.41.22
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 31 Oct 2017 11:41:23 -0700 (PDT)
From: =?UTF-8?q?Marc-Andr=C3=A9=20Lureau?= <marcandre.lureau@redhat.com>
Subject: [PATCH 6/6] memfd-tests: test hugetlbfs sealing
Date: Tue, 31 Oct 2017 19:40:52 +0100
Message-Id: <20171031184052.25253-7-marcandre.lureau@redhat.com>
In-Reply-To: <20171031184052.25253-1-marcandre.lureau@redhat.com>
References: <20171031184052.25253-1-marcandre.lureau@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, linux-kernel@vger.kernel.org
Cc: aarcange@redhat.com, hughd@google.com, nyc@holomorphy.com, mike.kravetz@oracle.com, =?UTF-8?q?Marc-Andr=C3=A9=20Lureau?= <marcandre.lureau@redhat.com>

Remove most of the special-casing of hugetlbfs now that sealing
is supported.

Signed-off-by: Marc-AndrA(C) Lureau <marcandre.lureau@redhat.com>
---
 tools/testing/selftests/memfd/memfd_test.c | 150 +++--------------------------
 1 file changed, 15 insertions(+), 135 deletions(-)

diff --git a/tools/testing/selftests/memfd/memfd_test.c b/tools/testing/selftests/memfd/memfd_test.c
index f94c6d1fb46f..f5028f800107 100644
--- a/tools/testing/selftests/memfd/memfd_test.c
+++ b/tools/testing/selftests/memfd/memfd_test.c
@@ -512,6 +512,10 @@ static void mfd_assert_grow_write(int fd)
 	static char *buf;
 	ssize_t l;
 
+	/* hugetlbfs does not support write */
+	if (hugetlbfs_test)
+		return;
+
 	buf = malloc(mfd_def_size * 8);
 	if (!buf) {
 		printf("malloc(%d) failed: %m\n", mfd_def_size * 8);
@@ -532,6 +536,10 @@ static void mfd_fail_grow_write(int fd)
 	static char *buf;
 	ssize_t l;
 
+	/* hugetlbfs does not support write */
+	if (hugetlbfs_test)
+		return;
+
 	buf = malloc(mfd_def_size * 8);
 	if (!buf) {
 		printf("malloc(%d) failed: %m\n", mfd_def_size * 8);
@@ -626,18 +634,13 @@ static void test_create(void)
 	fd = mfd_assert_new("", 0, MFD_CLOEXEC);
 	close(fd);
 
-	if (!hugetlbfs_test) {
-		/* verify MFD_ALLOW_SEALING is allowed */
-		fd = mfd_assert_new("", 0, MFD_ALLOW_SEALING);
-		close(fd);
-
-		/* verify MFD_ALLOW_SEALING | MFD_CLOEXEC is allowed */
-		fd = mfd_assert_new("", 0, MFD_ALLOW_SEALING | MFD_CLOEXEC);
-		close(fd);
-	} else {
-		/* sealing is not supported on hugetlbfs */
-		mfd_fail_new("", MFD_ALLOW_SEALING);
-	}
+	/* verify MFD_ALLOW_SEALING is allowed */
+	fd = mfd_assert_new("", 0, MFD_ALLOW_SEALING);
+	close(fd);
+
+	/* verify MFD_ALLOW_SEALING | MFD_CLOEXEC is allowed */
+	fd = mfd_assert_new("", 0, MFD_ALLOW_SEALING | MFD_CLOEXEC);
+	close(fd);
 }
 
 /*
@@ -648,10 +651,6 @@ static void test_basic(void)
 {
 	int fd;
 
-	/* hugetlbfs does not contain sealing support */
-	if (hugetlbfs_test)
-		return;
-
 	printf("%s BASIC\n", MEMFD_STR);
 
 	fd = mfd_assert_new("kern_memfd_basic",
@@ -696,28 +695,6 @@ static void test_basic(void)
 	close(fd);
 }
 
-/*
- * hugetlbfs doesn't support seals or write, so just verify grow and shrink
- * on a hugetlbfs file created via memfd_create.
- */
-static void test_hugetlbfs_grow_shrink(void)
-{
-	int fd;
-
-	printf("%s HUGETLBFS-GROW-SHRINK\n", MEMFD_STR);
-
-	fd = mfd_assert_new("kern_memfd_seal_write",
-			    mfd_def_size,
-			    MFD_CLOEXEC);
-
-	mfd_assert_read(fd);
-	mfd_assert_write(fd);
-	mfd_assert_shrink(fd);
-	mfd_assert_grow(fd);
-
-	close(fd);
-}
-
 /*
  * Test SEAL_WRITE
  * Test whether SEAL_WRITE actually prevents modifications.
@@ -726,13 +703,6 @@ static void test_seal_write(void)
 {
 	int fd;
 
-	/*
-	 * hugetlbfs does not contain sealing or write support.  Just test
-	 * basic grow and shrink via test_hugetlbfs_grow_shrink.
-	 */
-	if (hugetlbfs_test)
-		return test_hugetlbfs_grow_shrink();
-
 	printf("%s SEAL-WRITE\n", MEMFD_STR);
 
 	fd = mfd_assert_new("kern_memfd_seal_write",
@@ -759,10 +729,6 @@ static void test_seal_shrink(void)
 {
 	int fd;
 
-	/* hugetlbfs does not contain sealing support */
-	if (hugetlbfs_test)
-		return;
-
 	printf("%s SEAL-SHRINK\n", MEMFD_STR);
 
 	fd = mfd_assert_new("kern_memfd_seal_shrink",
@@ -789,10 +755,6 @@ static void test_seal_grow(void)
 {
 	int fd;
 
-	/* hugetlbfs does not contain sealing support */
-	if (hugetlbfs_test)
-		return;
-
 	printf("%s SEAL-GROW\n", MEMFD_STR);
 
 	fd = mfd_assert_new("kern_memfd_seal_grow",
@@ -819,10 +781,6 @@ static void test_seal_resize(void)
 {
 	int fd;
 
-	/* hugetlbfs does not contain sealing support */
-	if (hugetlbfs_test)
-		return;
-
 	printf("%s SEAL-RESIZE\n", MEMFD_STR);
 
 	fd = mfd_assert_new("kern_memfd_seal_resize",
@@ -841,32 +799,6 @@ static void test_seal_resize(void)
 	close(fd);
 }
 
-/*
- * hugetlbfs does not support seals.  Basic test to dup the memfd created
- * fd and perform some basic operations on it.
- */
-static void hugetlbfs_dup(char *b_suffix)
-{
-	int fd, fd2;
-
-	printf("%s HUGETLBFS-DUP %s\n", MEMFD_STR, b_suffix);
-
-	fd = mfd_assert_new("kern_memfd_share_dup",
-			    mfd_def_size,
-			    MFD_CLOEXEC);
-
-	fd2 = mfd_assert_dup(fd);
-
-	mfd_assert_read(fd);
-	mfd_assert_write(fd);
-
-	mfd_assert_shrink(fd2);
-	mfd_assert_grow(fd2);
-
-	close(fd2);
-	close(fd);
-}
-
 /*
  * Test sharing via dup()
  * Test that seals are shared between dupped FDs and they're all equal.
@@ -875,15 +807,6 @@ static void test_share_dup(char *banner, char *b_suffix)
 {
 	int fd, fd2;
 
-	/*
-	 * hugetlbfs does not contain sealing support.  Perform some
-	 * basic testing on dup'ed fd instead via hugetlbfs_dup.
-	 */
-	if (hugetlbfs_test) {
-		hugetlbfs_dup(b_suffix);
-		return;
-	}
-
 	printf("%s %s %s\n", MEMFD_STR, banner, b_suffix);
 
 	fd = mfd_assert_new("kern_memfd_share_dup",
@@ -926,10 +849,6 @@ static void test_share_mmap(char *banner, char *b_suffix)
 	int fd;
 	void *p;
 
-	/* hugetlbfs does not contain sealing support */
-	if (hugetlbfs_test)
-		return;
-
 	printf("%s %s %s\n", MEMFD_STR,  banner, b_suffix);
 
 	fd = mfd_assert_new("kern_memfd_share_mmap",
@@ -954,32 +873,6 @@ static void test_share_mmap(char *banner, char *b_suffix)
 	close(fd);
 }
 
-/*
- * Basic test to make sure we can open the hugetlbfs fd via /proc and
- * perform some simple operations on it.
- */
-static void hugetlbfs_proc_open(char *b_suffix)
-{
-	int fd, fd2;
-
-	printf("%s HUGETLBFS-PROC-OPEN %s\n", MEMFD_STR, b_suffix);
-
-	fd = mfd_assert_new("kern_memfd_share_open",
-			    mfd_def_size,
-			    MFD_CLOEXEC);
-
-	fd2 = mfd_assert_open(fd, O_RDWR, 0);
-
-	mfd_assert_read(fd);
-	mfd_assert_write(fd);
-
-	mfd_assert_shrink(fd2);
-	mfd_assert_grow(fd2);
-
-	close(fd2);
-	close(fd);
-}
-
 /*
  * Test sealing with open(/proc/self/fd/%d)
  * Via /proc we can get access to a separate file-context for the same memfd.
@@ -990,15 +883,6 @@ static void test_share_open(char *banner, char *b_suffix)
 {
 	int fd, fd2;
 
-	/*
-	 * hugetlbfs does not contain sealing support.  So test basic
-	 * functionality of using /proc fd via hugetlbfs_proc_open
-	 */
-	if (hugetlbfs_test) {
-		hugetlbfs_proc_open(b_suffix);
-		return;
-	}
-
 	printf("%s %s %s\n", MEMFD_STR, banner, b_suffix);
 
 	fd = mfd_assert_new("kern_memfd_share_open",
@@ -1042,10 +926,6 @@ static void test_share_fork(char *banner, char *b_suffix)
 	int fd;
 	pid_t pid;
 
-	/* hugetlbfs does not contain sealing support */
-	if (hugetlbfs_test)
-		return;
-
 	printf("%s %s %s\n", MEMFD_STR, banner, b_suffix);
 
 	fd = mfd_assert_new("kern_memfd_share_fork",
-- 
2.15.0.rc0.40.gaefcc5f6f

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

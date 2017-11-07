Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ot0-f197.google.com (mail-ot0-f197.google.com [74.125.82.197])
	by kanga.kvack.org (Postfix) with ESMTP id F01B8280245
	for <linux-mm@kvack.org>; Tue,  7 Nov 2017 07:28:27 -0500 (EST)
Received: by mail-ot0-f197.google.com with SMTP id n19so1661317ote.23
        for <linux-mm@kvack.org>; Tue, 07 Nov 2017 04:28:27 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id s63si509681oib.128.2017.11.07.04.28.26
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 07 Nov 2017 04:28:26 -0800 (PST)
From: =?UTF-8?q?Marc-Andr=C3=A9=20Lureau?= <marcandre.lureau@redhat.com>
Subject: [PATCH v3 6/9] memfd-test: test hugetlbfs sealing
Date: Tue,  7 Nov 2017 13:27:57 +0100
Message-Id: <20171107122800.25517-7-marcandre.lureau@redhat.com>
In-Reply-To: <20171107122800.25517-1-marcandre.lureau@redhat.com>
References: <20171107122800.25517-1-marcandre.lureau@redhat.com>
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
Reviewed-by: Mike Kravetz <mike.kravetz@oracle.com>
---
 tools/testing/selftests/memfd/memfd_test.c | 150 +++--------------------------
 1 file changed, 15 insertions(+), 135 deletions(-)

diff --git a/tools/testing/selftests/memfd/memfd_test.c b/tools/testing/selftests/memfd/memfd_test.c
index 845e5f67b6f0..cca957a06525 100644
--- a/tools/testing/selftests/memfd/memfd_test.c
+++ b/tools/testing/selftests/memfd/memfd_test.c
@@ -513,6 +513,10 @@ static void mfd_assert_grow_write(int fd)
 	static char *buf;
 	ssize_t l;
 
+	/* hugetlbfs does not support write */
+	if (hugetlbfs_test)
+		return;
+
 	buf = malloc(mfd_def_size * 8);
 	if (!buf) {
 		printf("malloc(%d) failed: %m\n", mfd_def_size * 8);
@@ -533,6 +537,10 @@ static void mfd_fail_grow_write(int fd)
 	static char *buf;
 	ssize_t l;
 
+	/* hugetlbfs does not support write */
+	if (hugetlbfs_test)
+		return;
+
 	buf = malloc(mfd_def_size * 8);
 	if (!buf) {
 		printf("malloc(%d) failed: %m\n", mfd_def_size * 8);
@@ -627,18 +635,13 @@ static void test_create(void)
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
@@ -649,10 +652,6 @@ static void test_basic(void)
 {
 	int fd;
 
-	/* hugetlbfs does not contain sealing support */
-	if (hugetlbfs_test)
-		return;
-
 	printf("%s BASIC\n", MEMFD_STR);
 
 	fd = mfd_assert_new("kern_memfd_basic",
@@ -697,28 +696,6 @@ static void test_basic(void)
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
@@ -727,13 +704,6 @@ static void test_seal_write(void)
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
@@ -760,10 +730,6 @@ static void test_seal_shrink(void)
 {
 	int fd;
 
-	/* hugetlbfs does not contain sealing support */
-	if (hugetlbfs_test)
-		return;
-
 	printf("%s SEAL-SHRINK\n", MEMFD_STR);
 
 	fd = mfd_assert_new("kern_memfd_seal_shrink",
@@ -790,10 +756,6 @@ static void test_seal_grow(void)
 {
 	int fd;
 
-	/* hugetlbfs does not contain sealing support */
-	if (hugetlbfs_test)
-		return;
-
 	printf("%s SEAL-GROW\n", MEMFD_STR);
 
 	fd = mfd_assert_new("kern_memfd_seal_grow",
@@ -820,10 +782,6 @@ static void test_seal_resize(void)
 {
 	int fd;
 
-	/* hugetlbfs does not contain sealing support */
-	if (hugetlbfs_test)
-		return;
-
 	printf("%s SEAL-RESIZE\n", MEMFD_STR);
 
 	fd = mfd_assert_new("kern_memfd_seal_resize",
@@ -842,32 +800,6 @@ static void test_seal_resize(void)
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
@@ -876,15 +808,6 @@ static void test_share_dup(char *banner, char *b_suffix)
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
@@ -927,10 +850,6 @@ static void test_share_mmap(char *banner, char *b_suffix)
 	int fd;
 	void *p;
 
-	/* hugetlbfs does not contain sealing support */
-	if (hugetlbfs_test)
-		return;
-
 	printf("%s %s %s\n", MEMFD_STR,  banner, b_suffix);
 
 	fd = mfd_assert_new("kern_memfd_share_mmap",
@@ -955,32 +874,6 @@ static void test_share_mmap(char *banner, char *b_suffix)
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
@@ -991,15 +884,6 @@ static void test_share_open(char *banner, char *b_suffix)
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
@@ -1043,10 +927,6 @@ static void test_share_fork(char *banner, char *b_suffix)
 	int fd;
 	pid_t pid;
 
-	/* hugetlbfs does not contain sealing support */
-	if (hugetlbfs_test)
-		return;
-
 	printf("%s %s %s\n", MEMFD_STR, banner, b_suffix);
 
 	fd = mfd_assert_new("kern_memfd_share_fork",
-- 
2.15.0.125.g8f49766d64

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

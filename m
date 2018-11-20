Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl1-f200.google.com (mail-pl1-f200.google.com [209.85.214.200])
	by kanga.kvack.org (Postfix) with ESMTP id 49AB46B1E56
	for <linux-mm@kvack.org>; Tue, 20 Nov 2018 00:22:00 -0500 (EST)
Received: by mail-pl1-f200.google.com with SMTP id e68so545851plb.3
        for <linux-mm@kvack.org>; Mon, 19 Nov 2018 21:22:00 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id h4-v6sor49092142plk.55.2018.11.19.21.21.58
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 19 Nov 2018 21:21:58 -0800 (PST)
From: "Joel Fernandes (Google)" <joel@joelfernandes.org>
Subject: [PATCH -next 2/2] selftests/memfd: modify tests for F_SEAL_FUTURE_WRITE seal
Date: Mon, 19 Nov 2018 21:21:37 -0800
Message-Id: <20181120052137.74317-2-joel@joelfernandes.org>
In-Reply-To: <20181120052137.74317-1-joel@joelfernandes.org>
References: <20181120052137.74317-1-joel@joelfernandes.org>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: "Joel Fernandes (Google)" <joel@joelfernandes.org>, Jann Horn <jannh@google.com>, Andrew Morton <akpm@linux-foundation.org>, Andy Lutomirski <luto@kernel.org>, Hugh Dickins <hughd@google.com>, Khalid Aziz <khalid.aziz@oracle.com>, linux-api@vger.kernel.org, linux-kselftest@vger.kernel.org, linux-mm@kvack.org, =?UTF-8?q?Marc-Andr=C3=A9=20Lureau?= <marcandre.lureau@redhat.com>, Matthew Wilcox <willy@infradead.org>, Mike Kravetz <mike.kravetz@oracle.com>, Shuah Khan <shuah@kernel.org>, Stephen Rothwell <sfr@canb.auug.org.au>

Modify the tests for F_SEAL_FUTURE_WRITE based on the changes
introduced in previous patch.

Also add a test to make sure the reopen issue pointed by Jann Horn [1]
is fixed.

[1] https://lore.kernel.org/lkml/CAG48ez1h=v-JYnDw81HaYJzOfrNhwYksxmc2r=cJvdQVgYM+NA@mail.gmail.com/

Cc: Jann Horn <jannh@google.com>
Signed-off-by: Joel Fernandes (Google) <joel@joelfernandes.org>
---
 tools/testing/selftests/memfd/memfd_test.c | 88 +++++++++++-----------
 1 file changed, 44 insertions(+), 44 deletions(-)

diff --git a/tools/testing/selftests/memfd/memfd_test.c b/tools/testing/selftests/memfd/memfd_test.c
index 32b207ca7372..c67d32eeb668 100644
--- a/tools/testing/selftests/memfd/memfd_test.c
+++ b/tools/testing/selftests/memfd/memfd_test.c
@@ -54,6 +54,22 @@ static int mfd_assert_new(const char *name, loff_t sz, unsigned int flags)
 	return fd;
 }
 
+static int mfd_assert_reopen_fd(int fd_in)
+{
+	int r, fd;
+	char path[100];
+
+	sprintf(path, "/proc/self/fd/%d", fd_in);
+
+	fd = open(path, O_RDWR);
+	if (fd < 0) {
+		printf("re-open of existing fd %d failed\n", fd_in);
+		abort();
+	}
+
+	return fd;
+}
+
 static void mfd_fail_new(const char *name, unsigned int flags)
 {
 	int r;
@@ -255,6 +271,25 @@ static void mfd_assert_read(int fd)
 	munmap(p, mfd_def_size);
 }
 
+/* Test that PROT_READ + MAP_SHARED mappings work. */
+static void mfd_assert_read_shared(int fd)
+{
+	void *p;
+
+	/* verify PROT_READ and MAP_SHARED *is* allowed */
+	p = mmap(NULL,
+		 mfd_def_size,
+		 PROT_READ,
+		 MAP_SHARED,
+		 fd,
+		 0);
+	if (p == MAP_FAILED) {
+		printf("mmap() failed: %m\n");
+		abort();
+	}
+	munmap(p, mfd_def_size);
+}
+
 static void mfd_assert_write(int fd)
 {
 	ssize_t l;
@@ -698,7 +733,7 @@ static void test_seal_write(void)
  */
 static void test_seal_future_write(void)
 {
-	int fd;
+	int fd, fd2;
 	void *p;
 
 	printf("%s SEAL-FUTURE-WRITE\n", memfd_str);
@@ -710,58 +745,23 @@ static void test_seal_future_write(void)
 	p = mfd_assert_mmap_shared(fd);
 
 	mfd_assert_has_seals(fd, 0);
-	/* Not adding grow/shrink seals makes the future write
-	 * seal fail to get added
-	 */
-	mfd_fail_add_seals(fd, F_SEAL_FUTURE_WRITE);
-
-	mfd_assert_add_seals(fd, F_SEAL_GROW);
-	mfd_assert_has_seals(fd, F_SEAL_GROW);
-
-	/* Should still fail since shrink seal has
-	 * not yet been added
-	 */
-	mfd_fail_add_seals(fd, F_SEAL_FUTURE_WRITE);
-
-	mfd_assert_add_seals(fd, F_SEAL_SHRINK);
-	mfd_assert_has_seals(fd, F_SEAL_GROW |
-				 F_SEAL_SHRINK);
 
-	/* Now should succeed, also verifies that the seal
-	 * could be added with an existing writable mmap
-	 */
 	mfd_assert_add_seals(fd, F_SEAL_FUTURE_WRITE);
-	mfd_assert_has_seals(fd, F_SEAL_SHRINK |
-				 F_SEAL_GROW |
-				 F_SEAL_FUTURE_WRITE);
+	mfd_assert_has_seals(fd, F_SEAL_FUTURE_WRITE);
 
 	/* read should pass, writes should fail */
 	mfd_assert_read(fd);
+	mfd_assert_read_shared(fd);
 	mfd_fail_write(fd);
 
-	munmap(p, mfd_def_size);
-	close(fd);
-
-	/* Test adding all seals (grow, shrink, future write) at once */
-	fd = mfd_assert_new("kern_memfd_seal_future_write2",
-			    mfd_def_size,
-			    MFD_CLOEXEC | MFD_ALLOW_SEALING);
-
-	p = mfd_assert_mmap_shared(fd);
-
-	mfd_assert_has_seals(fd, 0);
-	mfd_assert_add_seals(fd, F_SEAL_SHRINK |
-				 F_SEAL_GROW |
-				 F_SEAL_FUTURE_WRITE);
-	mfd_assert_has_seals(fd, F_SEAL_SHRINK |
-				 F_SEAL_GROW |
-				 F_SEAL_FUTURE_WRITE);
-
-	/* read should pass, writes should fail */
-	mfd_assert_read(fd);
-	mfd_fail_write(fd);
+	fd2 = mfd_assert_reopen_fd(fd);
+	/* read should pass, writes should still fail */
+	mfd_assert_read(fd2);
+	mfd_assert_read_shared(fd2);
+	mfd_fail_write(fd2);
 
 	munmap(p, mfd_def_size);
+	close(fd2);
 	close(fd);
 }
 
-- 
2.19.1.1215.g8438c0b245-goog

Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk1-f198.google.com (mail-qk1-f198.google.com [209.85.222.198])
	by kanga.kvack.org (Postfix) with ESMTP id 207EE8E0002
	for <linux-mm@kvack.org>; Sat, 12 Jan 2019 15:38:36 -0500 (EST)
Received: by mail-qk1-f198.google.com with SMTP id r145so12977008qke.20
        for <linux-mm@kvack.org>; Sat, 12 Jan 2019 12:38:36 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id j5sor74321735qvj.70.2019.01.12.12.38.35
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Sat, 12 Jan 2019 12:38:35 -0800 (PST)
From: Joel Fernandes <joel@joelfernandes.org>
Subject: [PATCH v4 2/2] selftests/memfd: Add tests for F_SEAL_FUTURE_WRITE seal
Date: Sat, 12 Jan 2019 15:38:16 -0500
Message-Id: <20190112203816.85534-3-joel@joelfernandes.org>
In-Reply-To: <20190112203816.85534-1-joel@joelfernandes.org>
References: <20190112203816.85534-1-joel@joelfernandes.org>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: "Joel Fernandes (Google)" <joel@joelfernandes.org>, dancol@google.com, minchan@kernel.org, Jann Horn <jannh@google.com>, John Stultz <john.stultz@linaro.org>, Al Viro <viro@zeniv.linux.org.uk>, Andrew Morton <akpm@linux-foundation.org>, Andy Lutomirski <luto@kernel.org>, Hugh Dickins <hughd@google.com>, "J. Bruce Fields" <bfields@fieldses.org>, Jeff Layton <jlayton@kernel.org>, linux-api@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-kselftest@vger.kernel.org, linux-mm@kvack.org, =?UTF-8?q?Marc-Andr=C3=A9=20Lureau?= <marcandre.lureau@redhat.com>, Matthew Wilcox <willy@infradead.org>, Mike Kravetz <mike.kravetz@oracle.com>, Shuah Khan <shuah@kernel.org>

From: "Joel Fernandes (Google)" <joel@joelfernandes.org>

Add tests to verify sealing memfds with the F_SEAL_FUTURE_WRITE works as
expected.

Cc: dancol@google.com
Cc: minchan@kernel.org
Cc: Jann Horn <jannh@google.com>
Cc: John Stultz <john.stultz@linaro.org>
Signed-off-by: Joel Fernandes (Google) <joel@joelfernandes.org>
---
 tools/testing/selftests/memfd/memfd_test.c | 74 ++++++++++++++++++++++
 1 file changed, 74 insertions(+)

diff --git a/tools/testing/selftests/memfd/memfd_test.c b/tools/testing/selftests/memfd/memfd_test.c
index 10baa1652fc2..c67d32eeb668 100644
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
@@ -692,6 +727,44 @@ static void test_seal_write(void)
 	close(fd);
 }
 
+/*
+ * Test SEAL_FUTURE_WRITE
+ * Test whether SEAL_FUTURE_WRITE actually prevents modifications.
+ */
+static void test_seal_future_write(void)
+{
+	int fd, fd2;
+	void *p;
+
+	printf("%s SEAL-FUTURE-WRITE\n", memfd_str);
+
+	fd = mfd_assert_new("kern_memfd_seal_future_write",
+			    mfd_def_size,
+			    MFD_CLOEXEC | MFD_ALLOW_SEALING);
+
+	p = mfd_assert_mmap_shared(fd);
+
+	mfd_assert_has_seals(fd, 0);
+
+	mfd_assert_add_seals(fd, F_SEAL_FUTURE_WRITE);
+	mfd_assert_has_seals(fd, F_SEAL_FUTURE_WRITE);
+
+	/* read should pass, writes should fail */
+	mfd_assert_read(fd);
+	mfd_assert_read_shared(fd);
+	mfd_fail_write(fd);
+
+	fd2 = mfd_assert_reopen_fd(fd);
+	/* read should pass, writes should still fail */
+	mfd_assert_read(fd2);
+	mfd_assert_read_shared(fd2);
+	mfd_fail_write(fd2);
+
+	munmap(p, mfd_def_size);
+	close(fd2);
+	close(fd);
+}
+
 /*
  * Test SEAL_SHRINK
  * Test whether SEAL_SHRINK actually prevents shrinking
@@ -945,6 +1018,7 @@ int main(int argc, char **argv)
 	test_basic();
 
 	test_seal_write();
+	test_seal_future_write();
 	test_seal_shrink();
 	test_seal_grow();
 	test_seal_resize();
-- 
2.20.1.97.g81188d93c3-goog

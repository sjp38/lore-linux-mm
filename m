Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf1-f198.google.com (mail-pf1-f198.google.com [209.85.210.198])
	by kanga.kvack.org (Postfix) with ESMTP id E15016B058A
	for <linux-mm@kvack.org>; Wed,  7 Nov 2018 23:16:18 -0500 (EST)
Received: by mail-pf1-f198.google.com with SMTP id x5-v6so7393641pfn.22
        for <linux-mm@kvack.org>; Wed, 07 Nov 2018 20:16:18 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id v9-v6sor3198090pgr.13.2018.11.07.20.16.17
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 07 Nov 2018 20:16:17 -0800 (PST)
From: "Joel Fernandes (Google)" <joel@joelfernandes.org>
Subject: [PATCH v3 resend 2/2] selftests/memfd: Add tests for F_SEAL_FUTURE_WRITE seal
Date: Wed,  7 Nov 2018 20:15:37 -0800
Message-Id: <20181108041537.39694-2-joel@joelfernandes.org>
In-Reply-To: <20181108041537.39694-1-joel@joelfernandes.org>
References: <20181108041537.39694-1-joel@joelfernandes.org>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: "Joel Fernandes (Google)" <joel@joelfernandes.org>, dancol@google.com, minchan@kernel.org, John Stultz <john.stultz@linaro.org>, Al Viro <viro@zeniv.linux.org.uk>, Andrew Morton <akpm@linux-foundation.org>, gregkh@linuxfoundation.org, hch@infradead.org, "J. Bruce Fields" <bfields@fieldses.org>, Jeff Layton <jlayton@kernel.org>, jreck@google.com, Khalid Aziz <khalid.aziz@oracle.com>, Lei Yang <Lei.Yang@windriver.com>, linux-fsdevel@vger.kernel.org, linux-kselftest@vger.kernel.org, linux-mm@kvack.org, =?UTF-8?q?Marc-Andr=C3=A9=20Lureau?= <marcandre.lureau@redhat.com>, Mike Kravetz <mike.kravetz@oracle.com>, Shuah Khan <shuah@kernel.org>, tkjos@google.com, valdis.kletnieks@vt.edu

Add tests to verify sealing memfds with the F_SEAL_FUTURE_WRITE works as
expected.

Cc: dancol@google.com
Cc: minchan@kernel.org
Reviewed-by: John Stultz <john.stultz@linaro.org>
Signed-off-by: Joel Fernandes (Google) <joel@joelfernandes.org>
---
 tools/testing/selftests/memfd/memfd_test.c | 74 ++++++++++++++++++++++
 1 file changed, 74 insertions(+)

diff --git a/tools/testing/selftests/memfd/memfd_test.c b/tools/testing/selftests/memfd/memfd_test.c
index 10baa1652fc2..32b207ca7372 100644
--- a/tools/testing/selftests/memfd/memfd_test.c
+++ b/tools/testing/selftests/memfd/memfd_test.c
@@ -692,6 +692,79 @@ static void test_seal_write(void)
 	close(fd);
 }
 
+/*
+ * Test SEAL_FUTURE_WRITE
+ * Test whether SEAL_FUTURE_WRITE actually prevents modifications.
+ */
+static void test_seal_future_write(void)
+{
+	int fd;
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
+	/* Not adding grow/shrink seals makes the future write
+	 * seal fail to get added
+	 */
+	mfd_fail_add_seals(fd, F_SEAL_FUTURE_WRITE);
+
+	mfd_assert_add_seals(fd, F_SEAL_GROW);
+	mfd_assert_has_seals(fd, F_SEAL_GROW);
+
+	/* Should still fail since shrink seal has
+	 * not yet been added
+	 */
+	mfd_fail_add_seals(fd, F_SEAL_FUTURE_WRITE);
+
+	mfd_assert_add_seals(fd, F_SEAL_SHRINK);
+	mfd_assert_has_seals(fd, F_SEAL_GROW |
+				 F_SEAL_SHRINK);
+
+	/* Now should succeed, also verifies that the seal
+	 * could be added with an existing writable mmap
+	 */
+	mfd_assert_add_seals(fd, F_SEAL_FUTURE_WRITE);
+	mfd_assert_has_seals(fd, F_SEAL_SHRINK |
+				 F_SEAL_GROW |
+				 F_SEAL_FUTURE_WRITE);
+
+	/* read should pass, writes should fail */
+	mfd_assert_read(fd);
+	mfd_fail_write(fd);
+
+	munmap(p, mfd_def_size);
+	close(fd);
+
+	/* Test adding all seals (grow, shrink, future write) at once */
+	fd = mfd_assert_new("kern_memfd_seal_future_write2",
+			    mfd_def_size,
+			    MFD_CLOEXEC | MFD_ALLOW_SEALING);
+
+	p = mfd_assert_mmap_shared(fd);
+
+	mfd_assert_has_seals(fd, 0);
+	mfd_assert_add_seals(fd, F_SEAL_SHRINK |
+				 F_SEAL_GROW |
+				 F_SEAL_FUTURE_WRITE);
+	mfd_assert_has_seals(fd, F_SEAL_SHRINK |
+				 F_SEAL_GROW |
+				 F_SEAL_FUTURE_WRITE);
+
+	/* read should pass, writes should fail */
+	mfd_assert_read(fd);
+	mfd_fail_write(fd);
+
+	munmap(p, mfd_def_size);
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
2.19.1.930.g4563a0d9d0-goog

Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl1-f200.google.com (mail-pl1-f200.google.com [209.85.214.200])
	by kanga.kvack.org (Postfix) with ESMTP id 308B16B0010
	for <linux-mm@kvack.org>; Thu, 18 Oct 2018 02:59:21 -0400 (EDT)
Received: by mail-pl1-f200.google.com with SMTP id w12-v6so10572750plp.9
        for <linux-mm@kvack.org>; Wed, 17 Oct 2018 23:59:21 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id j189-v6sor1410320pgd.42.2018.10.17.23.59.19
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 17 Oct 2018 23:59:20 -0700 (PDT)
From: "Joel Fernandes (Google)" <joel@joelfernandes.org>
Subject: [PATCH v3 2/2] selftests/memfd: Add tests for F_SEAL_FS_WRITE seal
Date: Wed, 17 Oct 2018 23:59:08 -0700
Message-Id: <20181018065908.254389-2-joel@joelfernandes.org>
In-Reply-To: <20181018065908.254389-1-joel@joelfernandes.org>
References: <20181018065908.254389-1-joel@joelfernandes.org>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: kernel-team@android.com, "Joel Fernandes (Google)" <joel@joelfernandes.org>, dancol@google.com, minchan@kernel.org, Al Viro <viro@zeniv.linux.org.uk>, Andrew Morton <akpm@linux-foundation.org>, gregkh@linuxfoundation.org, "J. Bruce Fields" <bfields@fieldses.org>, Jeff Layton <jlayton@kernel.org>, John Stultz <john.stultz@linaro.org>, jreck@google.com, linux-fsdevel@vger.kernel.org, linux-kselftest@vger.kernel.org, linux-mm@kvack.org, marcandre.lureau@redhat.com, Mike Kravetz <mike.kravetz@oracle.com>, Shuah Khan <shuah@kernel.org>, Thomas Gleixner <tglx@linutronix.de>, tkjos@google.com

Add tests to verify sealing memfds with the F_SEAL_FS_WRITE works as
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
2.19.1.331.ge82ca0e54c-goog

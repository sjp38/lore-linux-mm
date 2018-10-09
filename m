Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf1-f198.google.com (mail-pf1-f198.google.com [209.85.210.198])
	by kanga.kvack.org (Postfix) with ESMTP id AB1816B026C
	for <linux-mm@kvack.org>; Tue,  9 Oct 2018 18:21:07 -0400 (EDT)
Received: by mail-pf1-f198.google.com with SMTP id r81-v6so3031826pfk.11
        for <linux-mm@kvack.org>; Tue, 09 Oct 2018 15:21:07 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id 93-v6sor13357854plf.23.2018.10.09.15.21.06
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 09 Oct 2018 15:21:06 -0700 (PDT)
From: "Joel Fernandes (Google)" <joel@joelfernandes.org>
Subject: [PATCH v2 2/2] selftests/memfd: Add tests for F_SEAL_FS_WRITE seal
Date: Tue,  9 Oct 2018 15:20:42 -0700
Message-Id: <20181009222042.9781-2-joel@joelfernandes.org>
In-Reply-To: <20181009222042.9781-1-joel@joelfernandes.org>
References: <20181009222042.9781-1-joel@joelfernandes.org>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: kernel-team@android.com, "Joel Fernandes (Google)" <joel@joelfernandes.org>, dancol@google.com, minchan@google.com, Andrew Morton <akpm@linux-foundation.org>, gregkh@linuxfoundation.org, "J. Bruce Fields" <bfields@fieldses.org>, Jeff Layton <jlayton@kernel.org>, john.stultz@linaro.org, jreck@google.com, Khalid Aziz <khalid.aziz@oracle.com>, linux-fsdevel@vger.kernel.org, linux-kselftest@vger.kernel.org, linux-mm@kvack.org, Mike Kravetz <mike.kravetz@oracle.com>, Shuah Khan <shuah@kernel.org>, tkjos@google.com

Add tests to verify sealing memfds with the F_SEAL_FS_WRITE works as
expected.

Cc: dancol@google.com
Cc: minchan@google.com
Signed-off-by: Joel Fernandes (Google) <joel@joelfernandes.org>
---
 tools/testing/selftests/memfd/memfd_test.c | 51 +++++++++++++++++++++-
 1 file changed, 50 insertions(+), 1 deletion(-)

diff --git a/tools/testing/selftests/memfd/memfd_test.c b/tools/testing/selftests/memfd/memfd_test.c
index 10baa1652fc2..4bd2b6c87bb4 100644
--- a/tools/testing/selftests/memfd/memfd_test.c
+++ b/tools/testing/selftests/memfd/memfd_test.c
@@ -27,7 +27,7 @@
 
 #define MFD_DEF_SIZE 8192
 #define STACK_SIZE 65536
-
+#define F_SEAL_FS_WRITE         0x0010
 /*
  * Default is not to test hugetlbfs
  */
@@ -170,6 +170,24 @@ static void *mfd_assert_mmap_shared(int fd)
 	return p;
 }
 
+static void *mfd_fail_mmap_shared(int fd)
+{
+	void *p;
+
+	p = mmap(NULL,
+		 mfd_def_size,
+		 PROT_READ | PROT_WRITE,
+		 MAP_SHARED,
+		 fd,
+		 0);
+	if (p != MAP_FAILED) {
+		printf("mmap() didn't fail as expected\n");
+		abort();
+	}
+
+	return p;
+}
+
 static void *mfd_assert_mmap_private(int fd)
 {
 	void *p;
@@ -692,6 +710,36 @@ static void test_seal_write(void)
 	close(fd);
 }
 
+/*
+ * Test SEAL_WRITE
+ * Test whether SEAL_WRITE actually prevents modifications.
+ */
+static void test_seal_fs_write(void)
+{
+	int fd;
+	void *p;
+
+	printf("%s SEAL-FS-WRITE\n", memfd_str);
+
+	fd = mfd_assert_new("kern_memfd_seal_fs_write",
+			    mfd_def_size,
+			    MFD_CLOEXEC | MFD_ALLOW_SEALING);
+
+	p = mfd_assert_mmap_shared(fd);
+
+	/* FS_WRITE seal can be added even with existing
+	 * writeable mappings */
+	mfd_assert_has_seals(fd, 0);
+	mfd_assert_add_seals(fd, F_SEAL_FS_WRITE);
+	mfd_assert_has_seals(fd, F_SEAL_FS_WRITE);
+
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
@@ -945,6 +993,7 @@ int main(int argc, char **argv)
 	test_basic();
 
 	test_seal_write();
+	test_seal_fs_write();
 	test_seal_shrink();
 	test_seal_grow();
 	test_seal_resize();
-- 
2.19.0.605.g01d371f741-goog

Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg1-f198.google.com (mail-pg1-f198.google.com [209.85.215.198])
	by kanga.kvack.org (Postfix) with ESMTP id 48D456B2DDF
	for <linux-mm@kvack.org>; Thu, 22 Nov 2018 18:21:56 -0500 (EST)
Received: by mail-pg1-f198.google.com with SMTP id t26so3271582pgu.18
        for <linux-mm@kvack.org>; Thu, 22 Nov 2018 15:21:56 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id k33-v6sor61036344pld.54.2018.11.22.15.21.55
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 22 Nov 2018 15:21:55 -0800 (PST)
Date: Thu, 22 Nov 2018 15:21:52 -0800
From: Joel Fernandes <joel@joelfernandes.org>
Subject: Re: [PATCH -next 2/2] selftests/memfd: modify tests for
 F_SEAL_FUTURE_WRITE seal
Message-ID: <20181122232152.GA17060@google.com>
References: <20181120052137.74317-1-joel@joelfernandes.org>
 <20181120052137.74317-2-joel@joelfernandes.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20181120052137.74317-2-joel@joelfernandes.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: Jann Horn <jannh@google.com>, Andrew Morton <akpm@linux-foundation.org>, Andy Lutomirski <luto@kernel.org>, Hugh Dickins <hughd@google.com>, Khalid Aziz <khalid.aziz@oracle.com>, linux-api@vger.kernel.org, linux-kselftest@vger.kernel.org, linux-mm@kvack.org, =?iso-8859-1?Q?Marc-Andr=E9?= Lureau <marcandre.lureau@redhat.com>, Matthew Wilcox <willy@infradead.org>, Mike Kravetz <mike.kravetz@oracle.com>, Shuah Khan <shuah@kernel.org>, Stephen Rothwell <sfr@canb.auug.org.au>

On Mon, Nov 19, 2018 at 09:21:37PM -0800, Joel Fernandes (Google) wrote:
> Modify the tests for F_SEAL_FUTURE_WRITE based on the changes
> introduced in previous patch.
> 
> Also add a test to make sure the reopen issue pointed by Jann Horn [1]
> is fixed.
> 
> [1] https://lore.kernel.org/lkml/CAG48ez1h=v-JYnDw81HaYJzOfrNhwYksxmc2r=cJvdQVgYM+NA@mail.gmail.com/
> 
> Cc: Jann Horn <jannh@google.com>
> Signed-off-by: Joel Fernandes (Google) <joel@joelfernandes.org>
> ---
>  tools/testing/selftests/memfd/memfd_test.c | 88 +++++++++++-----------
>  1 file changed, 44 insertions(+), 44 deletions(-)

Since we squashed [1] the mm/memfd patch modifications suggested by Andy into
the original patch, I also squashed the selftests modifications and appended
the patch inline below if you want to take this instead:

[1] https://lore.kernel.org/lkml/20181122230906.GA198127@google.com/T/#m8ba68f67f3ec24913a977b62bcaeafc4b194b8c8

---8<-----------------------

From: "Joel Fernandes (Google)" <joel@joelfernandes.org>
Subject: [PATCH v4] selftests/memfd: add tests for F_SEAL_FUTURE_WRITE seal

Add tests to verify sealing memfds with the F_SEAL_FUTURE_WRITE works as
expected.

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
2.19.1.1215.g8438c0b245-goog

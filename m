Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f72.google.com (mail-pg0-f72.google.com [74.125.83.72])
	by kanga.kvack.org (Postfix) with ESMTP id E4FAD6B025F
	for <linux-mm@kvack.org>; Wed, 25 Oct 2017 19:50:35 -0400 (EDT)
Received: by mail-pg0-f72.google.com with SMTP id v78so1129028pgb.18
        for <linux-mm@kvack.org>; Wed, 25 Oct 2017 16:50:35 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id a3sor927439pgc.384.2017.10.25.16.50.34
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 25 Oct 2017 16:50:34 -0700 (PDT)
From: Andrei Vagin <avagin@openvz.org>
Subject: [PATCH 3/3] test: add a test for the process_vmsplice syscall
Date: Wed, 25 Oct 2017 16:50:03 -0700
Message-Id: <20171025235003.24262-3-avagin@openvz.org>
In-Reply-To: <20171025235003.24262-1-avagin@openvz.org>
References: <20171025235003.24262-1-avagin@openvz.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Alexander Viro <viro@zeniv.linux.org.uk>
Cc: linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org, linux-api@vger.kernel.org, criu@openvz.org, Andrei Vagin <avagin@openvz.org>, Arnd Bergmann <arnd@arndb.de>, Pavel Emelyanov <xemul@virtuozzo.com>, Michael Kerrisk <mtk.manpages@gmail.com>, Thomas Gleixner <tglx@linutronix.de>, Josh Triplett <josh@joshtriplett.org>, Jann Horn <jannh@google.com>

This test checks that process_vmsplice() can splice pages from a remote
process and returns EFAULT, if process_vmsplice() tries to splice pages
by an unaccessiable address.

Signed-off-by: Andrei Vagin <avagin@openvz.org>
---
 tools/testing/selftests/process_vmsplice/Makefile  |   5 +
 .../process_vmsplice/process_vmsplice_test.c       | 188 +++++++++++++++++++++
 2 files changed, 193 insertions(+)
 create mode 100644 tools/testing/selftests/process_vmsplice/Makefile
 create mode 100644 tools/testing/selftests/process_vmsplice/process_vmsplice_test.c

diff --git a/tools/testing/selftests/process_vmsplice/Makefile b/tools/testing/selftests/process_vmsplice/Makefile
new file mode 100644
index 000000000000..246d5a7dfed6
--- /dev/null
+++ b/tools/testing/selftests/process_vmsplice/Makefile
@@ -0,0 +1,5 @@
+CFLAGS += -I../../../../usr/include/
+
+TEST_GEN_PROGS := process_vmsplice_test
+
+include ../lib.mk
diff --git a/tools/testing/selftests/process_vmsplice/process_vmsplice_test.c b/tools/testing/selftests/process_vmsplice/process_vmsplice_test.c
new file mode 100644
index 000000000000..8abf59b9c567
--- /dev/null
+++ b/tools/testing/selftests/process_vmsplice/process_vmsplice_test.c
@@ -0,0 +1,188 @@
+#define _GNU_SOURCE
+#include <stdio.h>
+#include <unistd.h>
+#include <sys/mman.h>
+#include <sys/syscall.h>
+#include <fcntl.h>
+#include <sys/uio.h>
+#include <errno.h>
+#include <signal.h>
+#include <sys/prctl.h>
+#include <sys/wait.h>
+
+#include "../kselftest.h"
+
+#ifndef __NR_process_vmsplice
+#define __NR_process_vmsplice 333
+#endif
+
+#define pr_err(fmt, ...) \
+		({ \
+			fprintf(stderr, "%s:%d:" fmt, \
+				__func__, __LINE__, ##__VA_ARGS__); \
+			KSFT_FAIL; \
+		})
+#define pr_perror(fmt, ...) pr_err(fmt ": %m\n", ##__VA_ARGS__)
+#define fail(fmt, ...) pr_err("FAIL:" fmt, ##__VA_ARGS__)
+
+static ssize_t process_vmsplice(pid_t pid, int fd, const struct iovec *iov,
+			unsigned long nr_segs, unsigned int flags)
+{
+	return syscall(__NR_process_vmsplice, pid, fd, iov, nr_segs, flags);
+
+}
+
+#define MEM_SIZE (4096 * 100)
+#define MEM_WRONLY_SIZE (4096 * 10)
+
+int main(int argc, char **argv)
+{
+	char *addr, *addr_wronly;
+	int p[2];
+	struct iovec iov[2];
+	char buf[4096];
+	int status, ret;
+	pid_t pid;
+
+	ksft_print_header();
+
+	addr = mmap(0, MEM_SIZE, PROT_READ | PROT_WRITE,
+					MAP_ANONYMOUS | MAP_PRIVATE, -1, 0);
+	if (addr == MAP_FAILED)
+		return pr_perror("Unable to create a mapping");
+
+	addr_wronly = mmap(0, MEM_WRONLY_SIZE, PROT_WRITE,
+				MAP_ANONYMOUS | MAP_PRIVATE, -1, 0);
+	if (addr_wronly == MAP_FAILED)
+		return pr_perror("Unable to create a write-only mapping");
+
+	if (pipe(p))
+		return pr_perror("Unable to create a pipe");
+
+	pid = fork();
+	if (pid < 0)
+		return pr_perror("Unable to fork");
+
+	if (pid == 0) {
+		addr[0] = 'C';
+		addr[4096 + 128] = 'A';
+		addr[4096 + 128 + 4096 - 1] = 'B';
+
+		if (prctl(PR_SET_PDEATHSIG, SIGKILL))
+			return pr_perror("Unable to set PR_SET_PDEATHSIG");
+		if (write(p[1], "c", 1) != 1)
+			return pr_perror("Unable to write data into pipe");
+
+		while (1)
+			sleep(1);
+		return 1;
+	}
+	if (read(p[0], buf, 1) != 1) {
+		pr_perror("Unable to read data from pipe");
+		kill(pid, SIGKILL);
+		wait(&status);
+		return 1;
+	}
+
+	munmap(addr, MEM_SIZE);
+	munmap(addr_wronly, MEM_WRONLY_SIZE);
+
+	iov[0].iov_base = addr;
+	iov[0].iov_len = 1;
+
+	iov[1].iov_base = addr + 4096 + 128;
+	iov[1].iov_len = 4096;
+
+	/* check one iovec */
+	if (process_vmsplice(pid, p[1], iov, 1, SPLICE_F_GIFT) != 1)
+		return pr_perror("Unable to splice pages");
+
+	if (read(p[0], buf, 1) != 1)
+		return pr_perror("Unable to read from pipe");
+
+	if (buf[0] != 'C')
+		ksft_test_result_fail("Get wrong data\n");
+	else
+		ksft_test_result_pass("Check process_vmsplice with one vec\n");
+
+	/* check two iovec-s */
+	if (process_vmsplice(pid, p[1], iov, 2, SPLICE_F_GIFT) != 4097)
+		return pr_perror("Unable to spice pages\n");
+
+	if (read(p[0], buf, 1) != 1)
+		return pr_perror("Unable to read from pipe\n");
+
+	if (buf[0] != 'C')
+		ksft_test_result_fail("Get wrong data\n");
+
+	if (read(p[0], buf, 4096) != 4096)
+		return pr_perror("Unable to read from pipe\n");
+
+	if (buf[0] != 'A' || buf[4095] != 'B')
+		ksft_test_result_fail("Get wrong data\n");
+	else
+		ksft_test_result_pass("check process_vmsplice with two vecs\n");
+
+	/* check how an unreadable region in a second vec is handled */
+	iov[0].iov_base = addr;
+	iov[0].iov_len = 1;
+
+	iov[1].iov_base = addr_wronly + 5;
+	iov[1].iov_len = 1;
+
+	if (process_vmsplice(pid, p[1], iov, 2, SPLICE_F_GIFT) != 1)
+		return pr_perror("Unable to splice data");
+
+	if (read(p[0], buf, 1) != 1)
+		return pr_perror("Unable to read form pipe");
+
+	if (buf[0] != 'C')
+		ksft_test_result_fail("Get wrong data\n");
+	else
+		ksft_test_result_pass("unreadable region in a second vec\n");
+
+	/* check how an unreadable region in a first vec is handled */
+	errno = 0;
+	if (process_vmsplice(pid, p[1], iov + 1, 1, SPLICE_F_GIFT) != -1 ||
+	    errno != EFAULT)
+		ksft_test_result_fail("Got anexpected errno %d\n", errno);
+	else
+		ksft_test_result_pass("splice as much as possible\n");
+
+	iov[0].iov_base = addr;
+	iov[0].iov_len = 1;
+
+	iov[1].iov_base = addr;
+	iov[1].iov_len = MEM_SIZE;
+
+	/* splice as much as possible */
+	ret = process_vmsplice(pid, p[1], iov, 2,
+				SPLICE_F_GIFT | SPLICE_F_NONBLOCK);
+	if (ret != 4096 * 15 + 1) /* by default a pipe can fit 16 pages */
+		return pr_perror("Unable to splice pages");
+
+	while (ret > 0) {
+		int len;
+
+		len = read(p[0], buf, 4096);
+		if (len < 0)
+			return pr_perror("Unable to read data");
+		if (len > ret)
+			return pr_err("Read more than expected\n");
+		ret -= len;
+	}
+	ksft_test_result_pass("splice as much as possible\n");
+
+	if (kill(pid, SIGTERM))
+		return pr_perror("Unable to kill a child process");
+	status = -1;
+	if (wait(&status) < 0)
+		return pr_perror("Unable to wait a child process");
+	if (!WIFSIGNALED(status) || WTERMSIG(status) != SIGTERM)
+		return pr_err("The child exited with an unexpected code %d\n",
+									status);
+
+	if (ksft_get_fail_cnt())
+		return ksft_exit_fail();
+	return ksft_exit_pass();
+}
-- 
2.13.6

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

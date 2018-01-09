Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f197.google.com (mail-qt0-f197.google.com [209.85.216.197])
	by kanga.kvack.org (Postfix) with ESMTP id 8F9A86B025F
	for <linux-mm@kvack.org>; Tue,  9 Jan 2018 01:31:19 -0500 (EST)
Received: by mail-qt0-f197.google.com with SMTP id h4so10641913qtj.0
        for <linux-mm@kvack.org>; Mon, 08 Jan 2018 22:31:19 -0800 (PST)
Received: from mx0a-001b2d01.pphosted.com (mx0b-001b2d01.pphosted.com. [148.163.158.5])
        by mx.google.com with ESMTPS id d20si3682211qtd.348.2018.01.08.22.31.18
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 08 Jan 2018 22:31:18 -0800 (PST)
Received: from pps.filterd (m0098414.ppops.net [127.0.0.1])
	by mx0b-001b2d01.pphosted.com (8.16.0.22/8.16.0.22) with SMTP id w096P5IU035588
	for <linux-mm@kvack.org>; Tue, 9 Jan 2018 01:31:18 -0500
Received: from e06smtp14.uk.ibm.com (e06smtp14.uk.ibm.com [195.75.94.110])
	by mx0b-001b2d01.pphosted.com with ESMTP id 2fcre0r92f-1
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Tue, 09 Jan 2018 01:31:17 -0500
Received: from localhost
	by e06smtp14.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <rppt@linux.vnet.ibm.com>;
	Tue, 9 Jan 2018 06:31:15 -0000
From: Mike Rapoport <rppt@linux.vnet.ibm.com>
Subject: [PATCH v5 4/4] test: add a test for the process_vmsplice syscall
Date: Tue,  9 Jan 2018 08:30:53 +0200
In-Reply-To: <1515479453-14672-1-git-send-email-rppt@linux.vnet.ibm.com>
References: <1515479453-14672-1-git-send-email-rppt@linux.vnet.ibm.com>
Message-Id: <1515479453-14672-5-git-send-email-rppt@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Alexander Viro <viro@zeniv.linux.org.uk>
Cc: linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org, linux-api@vger.kernel.org, criu@openvz.org, gdb@sourceware.org, devel@lists.open-mpi.org, rr-dev@mozilla.org, Arnd Bergmann <arnd@arndb.de>, Pavel Emelyanov <xemul@virtuozzo.com>, Michael Kerrisk <mtk.manpages@gmail.com>, Thomas Gleixner <tglx@linutronix.de>, Josh Triplett <josh@joshtriplett.org>, Jann Horn <jannh@google.com>, Greg KH <gregkh@linuxfoundation.org>, Andrei Vagin <avagin@openvz.org>, Mike Rapoport <rppt@linux.vnet.ibm.com>

From: Andrei Vagin <avagin@openvz.org>

This test checks that process_vmsplice() can splice pages from a remote
process and returns EFAULT, if process_vmsplice() tries to splice pages
by an unaccessiable address.

Signed-off-by: Andrei Vagin <avagin@openvz.org>
Signed-off-by: Mike Rapoport <rppt@linux.vnet.ibm.com>
---
 tools/testing/selftests/process_vmsplice/Makefile  |   5 +
 .../process_vmsplice/process_vmsplice_test.c       | 196 +++++++++++++++++++++
 2 files changed, 201 insertions(+)
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
index 000000000000..1682bdb32de3
--- /dev/null
+++ b/tools/testing/selftests/process_vmsplice/process_vmsplice_test.c
@@ -0,0 +1,196 @@
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
+	if (process_vmsplice(0, 0, 0, 0, 0)) {
+		if (errno == ENOSYS) {
+			ksft_exit_skip("process_vmsplice is not supported\n");
+			return 0;
+		}
+		return pr_perror("Zero-length process_vmsplice failed");
+	}
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
2.7.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

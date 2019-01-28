Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f70.google.com (mail-ed1-f70.google.com [209.85.208.70])
	by kanga.kvack.org (Postfix) with ESMTP id 14AA58E0001
	for <linux-mm@kvack.org>; Mon, 28 Jan 2019 08:50:06 -0500 (EST)
Received: by mail-ed1-f70.google.com with SMTP id c34so6493797edb.8
        for <linux-mm@kvack.org>; Mon, 28 Jan 2019 05:50:06 -0800 (PST)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id o4-v6si298364eje.73.2019.01.28.05.50.03
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 28 Jan 2019 05:50:03 -0800 (PST)
From: Cyril Hrubis <metan@ucw.cz>
Subject: [PATCH] syscalls/preadv203: Add basic RWF_NOWAIT test
Date: Mon, 28 Jan 2019 14:46:56 +0100
Message-Id: <20190128134656.27979-1-metan@ucw.cz>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: ltp@lists.linux.it
Cc: Cyril Hrubis <chrubis@suse.cz>, Jiri Kosina <jikos@kernel.org>, Linux-MM <linux-mm@kvack.org>, kernel list <linux-kernel@vger.kernel.org>, Linux API <linux-api@vger.kernel.org>

From: Cyril Hrubis <chrubis@suse.cz>

We are attempting to trigger the EAGAIN path for the RWF_NOWAIT flag.

In order to do so the test runs three threads:

* nowait_reader: reads from a random offset from a random file with
                 RWF_NOWAIT flag and expects to get EAGAIN and short
                 read sooner or later

* writer_thread: rewrites random file in order to keep the underlying device
                 bussy so that pages evicted from cache cannot be faulted
                 immediatelly

* cache_dropper: attempts to evict pages from a cache in order for reader to
                 hit evicted page sooner or later

Signed-off-by: Cyril Hrubis <chrubis@suse.cz>
CC: Jiri Kosina <jikos@kernel.org>
CC: Linux-MM <linux-mm@kvack.org>
CC: kernel list <linux-kernel@vger.kernel.org>
CC: Linux API <linux-api@vger.kernel.org>

---

I was wondering if we can do a better job at flushing the caches. Is
there an interface for flusing caches just for the device we are using
for the test?

Also the RWF_NOWAIT should probably be benchmarked as well but that is
completely out of scope for LTP.

 runtest/syscalls                              |   2 +
 testcases/kernel/syscalls/preadv2/.gitignore  |   2 +
 testcases/kernel/syscalls/preadv2/Makefile    |   4 +
 testcases/kernel/syscalls/preadv2/preadv203.c | 266 ++++++++++++++++++
 4 files changed, 274 insertions(+)
 create mode 100644 testcases/kernel/syscalls/preadv2/preadv203.c

diff --git a/runtest/syscalls b/runtest/syscalls
index 34b47f36b..a69c431f1 100644
--- a/runtest/syscalls
+++ b/runtest/syscalls
@@ -853,6 +853,8 @@ preadv201 preadv201
 preadv201_64 preadv201_64
 preadv202 preadv202
 preadv202_64 preadv202_64
+preadv203 preadv203
+preadv203_64 preadv203_64
 
 profil01 profil01
 
diff --git a/testcases/kernel/syscalls/preadv2/.gitignore b/testcases/kernel/syscalls/preadv2/.gitignore
index 759d9ef5b..98b81abea 100644
--- a/testcases/kernel/syscalls/preadv2/.gitignore
+++ b/testcases/kernel/syscalls/preadv2/.gitignore
@@ -2,3 +2,5 @@
 /preadv201_64
 /preadv202
 /preadv202_64
+/preadv203
+/preadv203_64
diff --git a/testcases/kernel/syscalls/preadv2/Makefile b/testcases/kernel/syscalls/preadv2/Makefile
index fc1fbf3c7..fbedd0287 100644
--- a/testcases/kernel/syscalls/preadv2/Makefile
+++ b/testcases/kernel/syscalls/preadv2/Makefile
@@ -11,4 +11,8 @@ include $(abs_srcdir)/../utils/newer_64.mk
 
 %_64: CPPFLAGS += -D_FILE_OFFSET_BITS=64
 
+preadv203: CFLAGS += -pthread
+preadv203_64: CFLAGS += -pthread
+preadv203_64: LDFLAGS += -pthread
+
 include $(top_srcdir)/include/mk/generic_leaf_target.mk
diff --git a/testcases/kernel/syscalls/preadv2/preadv203.c b/testcases/kernel/syscalls/preadv2/preadv203.c
new file mode 100644
index 000000000..a6d5300f9
--- /dev/null
+++ b/testcases/kernel/syscalls/preadv2/preadv203.c
@@ -0,0 +1,266 @@
+// SPDX-License-Identifier: GPL-2.0-or-later
+/*
+ * Copyright (C) 2019 Cyril Hrubis <chrubis@suse.cz>
+ */
+
+/*
+ * This is a basic functional test for RWF_NOWAIT flag, we are attempting to
+ * force preadv2() either to return a short read or EAGAIN with three
+ * concurelntly running threads:
+ *
+ *  nowait_reader: reads from a random offset from a random file with
+ *                 RWF_NOWAIT flag and expects to get EAGAIN and short
+ *                 read sooner or later
+ *
+ *  writer_thread: rewrites random file in order to keep the underlying device
+ *                 bussy so that pages evicted from cache cannot be faulted
+ *                 immediatelly
+ *
+ *  cache_dropper: attempts to evict pages from a cache in order for reader to
+ *                 hit evicted page sooner or later
+ */
+
+/*
+ * If test fails with EOPNOTSUPP you have likely hit a glibc bug:
+ *
+ * https://sourceware.org/bugzilla/show_bug.cgi?id=23579
+ *
+ * Which can be worked around by calling preadv2() directly by syscall() such as:
+ *
+ * static ssize_t sys_preadv2(int fd, const struct iovec *iov, int iovcnt,
+ *                            off_t offset, int flags)
+ * {
+ *	return syscall(SYS_preadv2, fd, iov, iovcnt, offset, offset>>32, flags);
+ * }
+ *
+ */
+
+#define _GNU_SOURCE
+#include <string.h>
+#include <sys/uio.h>
+#include <stdio.h>
+#include <stdlib.h>
+#include <ctype.h>
+#include <pthread.h>
+
+#include "tst_test.h"
+#include "tst_safe_pthread.h"
+#include "lapi/preadv2.h"
+
+#define CHUNK_SZ 4123
+#define CHUNKS 60
+#define MNTPOINT "mntpoint"
+#define FILES 1000
+
+static int fds[FILES];
+
+static volatile int stop;
+
+static void drop_caches(void)
+{
+	SAFE_FILE_PRINTF("/proc/sys/vm/drop_caches", "3");
+}
+
+/*
+ * All files are divided in chunks each filled with the same bytes starting with
+ * '0' at offset 0 and with increasing value on each next chunk.
+ *
+ * 000....000111....111.......AAA......AAA...
+ * | chunk0 || chunk1 |  ...  |  chunk17 |
+ */
+static int verify_short_read(struct iovec *iov, size_t iov_cnt,
+		             off_t off, size_t size)
+{
+	unsigned int i;
+	size_t j, checked = 0;
+
+	for (i = 0; i < iov_cnt; i++) {
+		char *buf = iov[i].iov_base;
+		for (j = 0; j < iov[i].iov_len; j++) {
+			char exp_val = '0' + (off + checked)/CHUNK_SZ;
+
+			if (exp_val != buf[j]) {
+				tst_res(TFAIL,
+				        "Wrong value read pos %zu size %zu %c (%i) %c (%i)!",
+				        checked, size, exp_val, exp_val,
+					isprint(buf[j]) ? buf[j] : ' ', buf[j]);
+				return 1;
+			}
+
+			if (++checked >= size)
+				return 0;
+		}
+	}
+
+	return 0;
+}
+
+static void *nowait_reader(void *unused LTP_ATTRIBUTE_UNUSED)
+{
+	char buf1[CHUNK_SZ/2];
+	char buf2[CHUNK_SZ];
+	unsigned int full_read_cnt = 0, eagain_cnt = 0;
+	unsigned int short_read_cnt = 0, zero_read_cnt = 0;
+
+	struct iovec rd_iovec[] = {
+		{buf1, sizeof(buf1)},
+		{buf2, sizeof(buf2)},
+	};
+
+	while (!stop) {
+		if (eagain_cnt >= 100 && short_read_cnt >= 10)
+			stop = 1;
+
+		/* Ensure short reads doesn't happen because of tripping on EOF */
+		off_t off = random() % ((CHUNKS - 2) * CHUNK_SZ);
+		int fd = fds[random() % FILES];
+
+		TEST(preadv2(fd, rd_iovec, 2, off, RWF_NOWAIT));
+
+		if (TST_RET < 0) {
+			if (TST_ERR != EAGAIN)
+				tst_brk(TBROK | TTERRNO, "preadv2() failed");
+
+			eagain_cnt++;
+			continue;
+		}
+
+
+		if (TST_RET == 0) {
+			zero_read_cnt++;
+			continue;
+		}
+
+		if (TST_RET != CHUNK_SZ + CHUNK_SZ/2) {
+			verify_short_read(rd_iovec, 2, off, TST_RET);
+			short_read_cnt++;
+			continue;
+		}
+
+		full_read_cnt++;
+	}
+
+	tst_res(TINFO,
+	        "Number of full_reads %u, short reads %u, zero len reads %u, EAGAIN(s) %u",
+		full_read_cnt, short_read_cnt, zero_read_cnt, eagain_cnt);
+
+	return (void*)(long)eagain_cnt;
+}
+
+static void *writer_thread(void *unused)
+{
+	char buf[CHUNK_SZ];
+	unsigned int j, write_cnt = 0;
+
+	struct iovec wr_iovec[] = {
+		{buf, sizeof(buf)},
+	};
+
+	while (!stop) {
+		int fd = fds[random() % FILES];
+
+		for (j = 0; j < CHUNKS; j++) {
+			memset(buf, '0' + j, sizeof(buf));
+
+			off_t off = CHUNK_SZ * j;
+
+			if (pwritev(fd, wr_iovec, 1, off) < 0) {
+				if (errno == EBADF) {
+					tst_res(TBROK | TERRNO, "FDs closed?");
+					return unused;
+				}
+
+				tst_brk(TBROK | TERRNO, "pwritev()");
+			}
+
+			write_cnt++;
+		}
+	}
+
+	tst_res(TINFO, "Number of writes %u", write_cnt);
+
+	return unused;
+}
+
+static void *cache_dropper(void *unused)
+{
+	unsigned int drop_cnt = 0;
+
+	while (!stop) {
+		drop_caches();
+		drop_cnt++;
+	}
+
+	tst_res(TINFO, "Cache dropped %u times", drop_cnt);
+
+	return unused;
+}
+
+static void verify_preadv2(void)
+{
+	pthread_t reader, dropper, writer;
+	unsigned int max_runtime = 600;
+	void *eagains;
+
+	stop = 0;
+
+	drop_caches();
+
+	SAFE_PTHREAD_CREATE(&dropper, NULL, cache_dropper, NULL);
+	SAFE_PTHREAD_CREATE(&reader, NULL, nowait_reader, NULL);
+	SAFE_PTHREAD_CREATE(&writer, NULL, writer_thread, NULL);
+
+	while (!stop && max_runtime-- > 0)
+		usleep(100000);
+
+	stop = 1;
+
+	SAFE_PTHREAD_JOIN(reader, &eagains);
+	SAFE_PTHREAD_JOIN(dropper, NULL);
+	SAFE_PTHREAD_JOIN(writer, NULL);
+
+	if (eagains)
+		tst_res(TPASS, "Got some EAGAIN");
+	else
+		tst_res(TFAIL, "Haven't got EAGAIN");
+}
+
+static void setup(void)
+{
+	char path[1024];
+	char buf[CHUNK_SZ];
+	unsigned int i;
+	char j;
+
+	for (i = 0; i < FILES; i++) {
+		snprintf(path, sizeof(path), MNTPOINT"/file_%i", i);
+
+		fds[i] = SAFE_OPEN(path, O_RDWR | O_CREAT, 0644);
+
+		for (j = 0; j < CHUNKS; j++) {
+			memset(buf, '0' + j, sizeof(buf));
+			SAFE_WRITE(1, fds[i], buf, sizeof(buf));
+		}
+	}
+}
+
+static void do_cleanup(void)
+{
+	unsigned int i;
+
+	for (i = 0; i < FILES; i++) {
+		if (fds[i] > 0)
+			SAFE_CLOSE(fds[i]);
+	}
+}
+
+TST_DECLARE_ONCE_FN(cleanup, do_cleanup);
+
+static struct tst_test test = {
+	.setup = setup,
+	.cleanup = cleanup,
+	.test_all = verify_preadv2,
+	.mntpoint = MNTPOINT,
+	.all_filesystems = 1,
+	.needs_tmpdir = 1,
+};
-- 
2.19.2

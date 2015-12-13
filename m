Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lb0-f177.google.com (mail-lb0-f177.google.com [209.85.217.177])
	by kanga.kvack.org (Postfix) with ESMTP id 311F76B0257
	for <linux-mm@kvack.org>; Sun, 13 Dec 2015 15:16:54 -0500 (EST)
Received: by lbbcs9 with SMTP id cs9so95403923lbb.1
        for <linux-mm@kvack.org>; Sun, 13 Dec 2015 12:16:53 -0800 (PST)
Received: from mail-lb0-x22d.google.com (mail-lb0-x22d.google.com. [2a00:1450:4010:c04::22d])
        by mx.google.com with ESMTPS id ad6si15484247lbc.87.2015.12.13.12.16.50
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 13 Dec 2015 12:16:50 -0800 (PST)
Received: by lbbcs9 with SMTP id cs9so95403562lbb.1
        for <linux-mm@kvack.org>; Sun, 13 Dec 2015 12:16:50 -0800 (PST)
Message-Id: <20151213201646.909312009@gmail.com>
Date: Sun, 13 Dec 2015 23:14:20 +0300
From: Cyrill Gorcunov <gorcunov@gmail.com>
Subject: [RFC 2/2] [RFC] selftests: vm -- Add rlimit data selftest
MIME-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Disposition: inline; filename=mm-rlimit-data-selftest
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: linux-mm@kvack.org, Quentin Casasnovas <quentin.casasnovas@oracle.com>, Vegard Nossum <vegard.nossum@oracle.com>, Linus Torvalds <torvalds@linux-foundation.org>, Willy Tarreau <w@1wt.eu>, Andy Lutomirski <luto@amacapital.net>, Kees Cook <keescook@google.com>, Vladimir Davydov <vdavydov@virtuozzo.com>, Konstantin Khlebnikov <koct9i@gmail.com>, Pavel Emelyanov <xemul@virtuozzo.com>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Cyrill Gorcunov <gorcunov@openvz.org>

Just setup RLIMIT_DATA limit and play with anon memory accounting.

CC: Quentin Casasnovas <quentin.casasnovas@oracle.com>
CC: Vegard Nossum <vegard.nossum@oracle.com>
CC: Linus Torvalds <torvalds@linux-foundation.org>
CC: Willy Tarreau <w@1wt.eu>
CC: Andy Lutomirski <luto@amacapital.net>
CC: Kees Cook <keescook@google.com>
CC: Vladimir Davydov <vdavydov@virtuozzo.com>
CC: Konstantin Khlebnikov <koct9i@gmail.com>
CC: Pavel Emelyanov <xemul@virtuozzo.com>
CC: Vladimir Davydov <vdavydov@virtuozzo.com>
CC: Peter Zijlstra <a.p.zijlstra@chello.nl>
Signed-off-by: Cyrill Gorcunov <gorcunov@openvz.org>
---
 tools/testing/selftests/vm/Makefile      |    1 
 tools/testing/selftests/vm/rlimit-data.c |  201 +++++++++++++++++++++++++++++++
 tools/testing/selftests/vm/run_vmtests   |    4 
 3 files changed, 204 insertions(+), 2 deletions(-)

Index: linux-ml.git/tools/testing/selftests/vm/Makefile
===================================================================
--- linux-ml.git.orig/tools/testing/selftests/vm/Makefile
+++ linux-ml.git/tools/testing/selftests/vm/Makefile
@@ -10,6 +10,7 @@ BINARIES += on-fault-limit
 BINARIES += thuge-gen
 BINARIES += transhuge-stress
 BINARIES += userfaultfd
+BINARIES += rlimit-data
 
 all: $(BINARIES)
 %: %.c
Index: linux-ml.git/tools/testing/selftests/vm/rlimit-data.c
===================================================================
--- /dev/null
+++ linux-ml.git/tools/testing/selftests/vm/rlimit-data.c
@@ -0,0 +1,201 @@
+/*
+ * rlimit-data:
+ *
+ * Test that RLIMIT_DATA accounts anonymous
+ * memory correctly.
+ */
+
+#define _GNU_SOURCE
+
+#include <stdlib.h>
+#include <stdio.h>
+#include <unistd.h>
+#include <fcntl.h>
+#include <errno.h>
+#include <string.h>
+#include <stdbool.h>
+
+#include <sys/resource.h>
+#include <sys/syscall.h>
+#include <sys/mman.h>
+
+#define pr_info(fmt, ...)					\
+	fprintf(stdout, fmt, ##__VA_ARGS__)
+#define pr_err(fmt, ...)					\
+	fprintf(stderr, "ERROR: " fmt, ##__VA_ARGS__)
+#define pr_perror(fmt, ...)					\
+	fprintf(stderr, "ERROR: " fmt ": %s\n", ##__VA_ARGS__,	\
+		strerror(errno))
+
+#define mmap_anon(__addr, __size)				\
+	mmap(__addr, __size, PROT_READ | PROT_WRITE,		\
+		   MAP_PRIVATE | MAP_ANONYMOUS, -1, 0)
+
+static const char self_status_path[] = "/proc/self/status";
+static int fd_status = -1;
+static size_t page_size;
+
+static const char tplt[] = "VmAnon:";
+static const size_t tplt_len = sizeof(tplt) - 1;
+
+static int get_self_anon_vm(int fd, unsigned long *npages)
+{
+	FILE *f = fdopen(fd, "r");
+	bool found = false;
+	char buf[1024];
+
+	if (!f) {
+		pr_perror("Can't open status");
+		return -1;
+	}
+
+	setbuffer(f, NULL, 0);
+	rewind(f);
+	while (fgets(buf, sizeof(buf), f)) {
+		if (strncmp(buf, tplt, tplt_len))
+			continue;
+		*npages = (atol(&buf[tplt_len + 1]) << 10) / page_size;
+		found = true;
+		break;
+	}
+
+	if (!found)
+		pr_err("No data found in status\n");
+	return found ? 0 : -1;
+}
+
+int main(int argc, char *argv[])
+{
+	unsigned long npages_cur = 0, npages_new = 0;
+	unsigned long npages_init = 0;
+	int ret = 1, match;
+	struct rlimit lim;
+
+	void *mem, *mem_new;
+	size_t size;
+
+	size_t shmem_size;
+	void *shmem;
+
+	page_size = getpagesize();
+
+	if (getrlimit(RLIMIT_DATA, &lim)) {
+		pr_perror("Can't get rlimit data");
+		return 1;
+	}
+
+	fd_status = open(self_status_path, O_RDONLY);
+	if (fd_status < 0) {
+		pr_perror("Can't open %s", self_status_path);
+		return 1;
+	}
+
+	if (get_self_anon_vm(fd_status, &npages_init))
+		goto err;
+	pr_info("Initial anon pages %lu\n", npages_init);
+
+	/*
+	 * Map first chunk.
+	 */
+	size = page_size * 10;
+	mem = mmap_anon(NULL, size);
+	if (mem == MAP_FAILED) {
+		pr_perror("Can't map first chunk");
+		goto err;
+	}
+	if (get_self_anon_vm(fd_status, &npages_cur))
+		goto err;
+	pr_info("Mapped %zu bytes %lu pages, parsed %lu\n",
+		size, size / page_size, npages_cur);
+
+	if (npages_cur <= (npages_init + 10)) {
+		pr_err("Parsed number of pages is too small\n");
+		goto err;
+	}
+
+	/*
+	 * Allow up to more 80K of anon data.
+	 */
+	lim.rlim_cur = (80 << 10) + npages_init * page_size;
+	lim.rlim_max = RLIM_INFINITY;
+	if (setrlimit(RLIMIT_DATA, &lim)) {
+		pr_perror("Can't setup limit to %lu bytes",
+			  (unsigned long)lim.rlim_cur);
+		goto err;
+	}
+
+	/*
+	 * This one should fail.
+	 */
+	mem_new = mmap_anon(NULL, lim.rlim_cur);
+	if (mem_new != MAP_FAILED) {
+		pr_err("RLIMIT_DATA didn't catch the overrflow\n");
+		goto err;
+	}
+
+	/*
+	 * Shrink it.
+	 */
+	mem_new = mremap(mem, size, size / 2, MREMAP_MAYMOVE);
+	if (!mem_new) {
+		pr_perror("Can't shrink memory");
+		goto err;
+	}
+	size /= 2;
+	mem = mem_new;
+
+	if (get_self_anon_vm(fd_status, &npages_cur))
+		goto err;
+	pr_info("Remapped %zu bytes %lu pages, parsed %lu\n",
+		size, size / page_size, npages_cur);
+
+	if (npages_cur <= (npages_init + 5)) {
+		pr_err("Parsed number of pages is too small\n");
+		goto err;
+	}
+
+	/*
+	 * Test via sbrk.
+	 */
+	mem_new = sbrk(0);
+	pr_info("Current brk %p\n", sbrk(0));
+	mem_new = sbrk(page_size);
+	if (mem_new != (void *)-1) {
+		if (get_self_anon_vm(fd_status, &npages_cur))
+			goto err;
+
+		/*
+		 * Allow up to two pages.
+		 */
+		lim.rlim_cur = (npages_cur + 3) * page_size;
+		lim.rlim_max = RLIM_INFINITY;
+		if (setrlimit(RLIMIT_DATA, &lim)) {
+			pr_perror("Can't setup limit to %lu bytes",
+				  (unsigned long)lim.rlim_cur);
+			goto err;
+		}
+
+		pr_info("Allocating 3 pages, must pass...");
+		mem_new = sbrk(page_size * 3);
+		if (mem_new == (void *)-1) {
+			pr_err("Can't allocate pages while should\n");
+			goto err;
+		} else
+			pr_info("OK\n");
+
+		pr_info("Allocating 1 pages, must fail...");
+		mem_new = sbrk(page_size);
+		if (mem_new != (void *)-1) {
+			pr_err("Allocated page while should not\n");
+			goto err;
+		} else
+			pr_info("OK\n");
+	}
+
+	ret = 0;
+err:
+	if (mem)
+		munmap(mem, size);
+	close(fd_status);
+	return ret;
+}
Index: linux-ml.git/tools/testing/selftests/vm/run_vmtests
===================================================================
--- linux-ml.git.orig/tools/testing/selftests/vm/run_vmtests
+++ linux-ml.git/tools/testing/selftests/vm/run_vmtests
@@ -131,9 +131,9 @@ else
 fi
 
 echo "--------------------"
-echo "running mlock2-tests"
+echo "running rlimit-data"
 echo "--------------------"
-./mlock2-tests
+./rlimit-data
 if [ $? -ne 0 ]; then
 	echo "[FAIL]"
 	exitcode=1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

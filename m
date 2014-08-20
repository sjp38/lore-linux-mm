Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f182.google.com (mail-pd0-f182.google.com [209.85.192.182])
	by kanga.kvack.org (Postfix) with ESMTP id 5DDFC6B0039
	for <linux-mm@kvack.org>; Wed, 20 Aug 2014 11:05:04 -0400 (EDT)
Received: by mail-pd0-f182.google.com with SMTP id fp1so12109133pdb.27
        for <linux-mm@kvack.org>; Wed, 20 Aug 2014 08:05:00 -0700 (PDT)
Received: from mailout3.w1.samsung.com (mailout3.w1.samsung.com. [210.118.77.13])
        by mx.google.com with ESMTPS id bc5si32175041pdb.119.2014.08.20.08.04.59
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-MD5 bits=128/128);
        Wed, 20 Aug 2014 08:05:00 -0700 (PDT)
Received: from eucpsbgm2.samsung.com (unknown [203.254.199.245])
 by mailout3.w1.samsung.com
 (Oracle Communications Messaging Server 7u4-24.01(7.0.4.24.0) 64bit (built Nov
 17 2011)) with ESMTP id <0NAM00MWH1W5CN20@mailout3.w1.samsung.com> for
 linux-mm@kvack.org; Wed, 20 Aug 2014 16:04:53 +0100 (BST)
Subject: [PATCH 4/7] selftests/vm/transhuge-stress: stress test for memory
 compaction
From: Konstantin Khlebnikov <k.khlebnikov@samsung.com>
Date: Wed, 20 Aug 2014 19:04:52 +0400
Message-id: <20140820150452.4194.85926.stgit@buzz>
In-reply-to: <20140820150435.4194.28003.stgit@buzz>
References: <20140820150435.4194.28003.stgit@buzz>
MIME-version: 1.0
Content-type: text/plain; charset=utf-8
Content-transfer-encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Rafael Aquini <aquini@redhat.com>
Cc: Sasha Levin <sasha.levin@oracle.com>, Andrey Ryabinin <ryabinin.a.a@gmail.com>, linux-kernel@vger.kernel.org

From: Konstantin Khlebnikov <koct9i@gmail.com>

This tool induces memory fragmentation via sequential allocation of transparent
huge pages and splitting off everything except their last sub-pages.

Signed-off-by: Konstantin Khlebnikov <koct9i@gmail.com>
---
 tools/testing/selftests/vm/Makefile           |    1 
 tools/testing/selftests/vm/transhuge-stress.c |  144 +++++++++++++++++++++++++
 2 files changed, 145 insertions(+)
 create mode 100644 tools/testing/selftests/vm/transhuge-stress.c

diff --git a/tools/testing/selftests/vm/Makefile b/tools/testing/selftests/vm/Makefile
index 3f94e1a..4c4b1f6 100644
--- a/tools/testing/selftests/vm/Makefile
+++ b/tools/testing/selftests/vm/Makefile
@@ -3,6 +3,7 @@
 CC = $(CROSS_COMPILE)gcc
 CFLAGS = -Wall
 BINARIES = hugepage-mmap hugepage-shm map_hugetlb thuge-gen hugetlbfstest
+BINARIES += transhuge-stress
 
 all: $(BINARIES)
 %: %.c
diff --git a/tools/testing/selftests/vm/transhuge-stress.c b/tools/testing/selftests/vm/transhuge-stress.c
new file mode 100644
index 0000000..fd7f1b4
--- /dev/null
+++ b/tools/testing/selftests/vm/transhuge-stress.c
@@ -0,0 +1,144 @@
+/*
+ * Stress test for transparent huge pages, memory compaction and migration.
+ *
+ * Authors: Konstantin Khlebnikov <koct9i@gmail.com>
+ *
+ * This is free and unencumbered software released into the public domain.
+ */
+
+#include <stdlib.h>
+#include <stdio.h>
+#include <stdint.h>
+#include <err.h>
+#include <time.h>
+#include <unistd.h>
+#include <fcntl.h>
+#include <string.h>
+#include <sys/mman.h>
+
+#define PAGE_SHIFT 12
+#define HPAGE_SHIFT 21
+
+#define PAGE_SIZE (1 << PAGE_SHIFT)
+#define HPAGE_SIZE (1 << HPAGE_SHIFT)
+
+#define PAGEMAP_PRESENT(ent)	(((ent) & (1ull << 63)) != 0)
+#define PAGEMAP_PFN(ent)	((ent) & ((1ull << 55) - 1))
+
+int pagemap_fd;
+
+int64_t allocate_transhuge(void *ptr)
+{
+	uint64_t ent[2];
+
+	/* drop pmd */
+	if (mmap(ptr, HPAGE_SIZE, PROT_READ | PROT_WRITE,
+				MAP_FIXED | MAP_ANONYMOUS |
+				MAP_NORESERVE | MAP_PRIVATE, -1, 0) != ptr)
+		errx(2, "mmap transhuge");
+
+	if (madvise(ptr, HPAGE_SIZE, MADV_HUGEPAGE))
+		err(2, "MADV_HUGEPAGE");
+
+	/* allocate transparent huge page */
+	*(volatile void **)ptr = ptr;
+
+	if (pread(pagemap_fd, ent, sizeof(ent),
+			(uintptr_t)ptr >> (PAGE_SHIFT - 3)) != sizeof(ent))
+		err(2, "read pagemap");
+
+	if (PAGEMAP_PRESENT(ent[0]) && PAGEMAP_PRESENT(ent[1]) &&
+	    PAGEMAP_PFN(ent[0]) + 1 == PAGEMAP_PFN(ent[1]) &&
+	    !(PAGEMAP_PFN(ent[0]) & ((1 << (HPAGE_SHIFT - PAGE_SHIFT)) - 1)))
+		return PAGEMAP_PFN(ent[0]);
+
+	return -1;
+}
+
+int main(int argc, char **argv)
+{
+	size_t ram, len;
+	void *ptr, *p;
+	struct timespec a, b;
+	double s;
+	uint8_t *map;
+	size_t map_len;
+
+	ram = sysconf(_SC_PHYS_PAGES);
+	if (ram > SIZE_MAX / sysconf(_SC_PAGESIZE) / 4)
+		ram = SIZE_MAX / 4;
+	else
+		ram *= sysconf(_SC_PAGESIZE);
+
+	if (argc == 1)
+		len = ram;
+	else if (!strcmp(argv[1], "-h"))
+		errx(1, "usage: %s [size in MiB]", argv[0]);
+	else
+		len = atoll(argv[1]) << 20;
+
+	warnx("allocate %zd transhuge pages, using %zd MiB virtual memory"
+	      " and %zd MiB of ram", len >> HPAGE_SHIFT, len >> 20,
+	      len >> (20 + HPAGE_SHIFT - PAGE_SHIFT - 1));
+
+	pagemap_fd = open("/proc/self/pagemap", O_RDONLY);
+	if (pagemap_fd < 0)
+		err(2, "open pagemap");
+
+	len -= len % HPAGE_SIZE;
+	ptr = mmap(NULL, len + HPAGE_SIZE, PROT_READ | PROT_WRITE,
+			MAP_ANONYMOUS | MAP_NORESERVE | MAP_PRIVATE, -1, 0);
+	if (ptr == MAP_FAILED)
+		err(2, "initial mmap");
+	ptr += HPAGE_SIZE - (uintptr_t)ptr % HPAGE_SIZE;
+
+	if (madvise(ptr, len, MADV_HUGEPAGE))
+		err(2, "MADV_HUGEPAGE");
+
+	map_len = ram >> (HPAGE_SHIFT - 1);
+	map = malloc(map_len);
+	if (!map)
+		errx(2, "map malloc");
+
+	while (1) {
+		int nr_succeed = 0, nr_failed = 0, nr_pages = 0;
+
+		memset(map, 0, map_len);
+
+		clock_gettime(CLOCK_MONOTONIC, &a);
+		for (p = ptr; p < ptr + len; p += HPAGE_SIZE) {
+			int64_t pfn;
+
+			pfn = allocate_transhuge(p);
+
+			if (pfn < 0) {
+				nr_failed++;
+			} else {
+				size_t idx = pfn >> (HPAGE_SHIFT - PAGE_SHIFT);
+
+				nr_succeed++;
+				if (idx >= map_len) {
+					map = realloc(map, idx + 1);
+					if (!map)
+						errx(2, "map realloc");
+					memset(map + map_len, 0, idx + 1 - map_len);
+					map_len = idx + 1;
+				}
+				if (!map[idx])
+					nr_pages++;
+				map[idx] = 1;
+			}
+
+			/* split transhuge page, keep last page */
+			if (madvise(p, HPAGE_SIZE - PAGE_SIZE, MADV_DONTNEED))
+				err(2, "MADV_DONTNEED");
+		}
+		clock_gettime(CLOCK_MONOTONIC, &b);
+		s = b.tv_sec - a.tv_sec + (b.tv_nsec - a.tv_nsec) / 1000000000.;
+
+		warnx("%.3f s/loop, %.3f ms/page, %10.3f MiB/s\t"
+		      "%4d succeed, %4d failed, %4d different pages",
+		      s, s * 1000 / (len >> HPAGE_SHIFT), len / s / (1 << 20),
+		      nr_succeed, nr_failed, nr_pages);
+	}
+}

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

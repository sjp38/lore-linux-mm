Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx133.postini.com [74.125.245.133])
	by kanga.kvack.org (Postfix) with SMTP id 92D5A6B0074
	for <linux-mm@kvack.org>; Thu,  8 Nov 2012 15:21:08 -0500 (EST)
From: Andi Kleen <andi@firstfloor.org>
Subject: [PATCH] Add a test program for variable page sizes in mmap/shmget
Date: Thu,  8 Nov 2012 12:21:03 -0800
Message-Id: <1352406063-3566-1-git-send-email-andi@firstfloor.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org
Cc: linux-mm@kvack.org, Andi Kleen <ak@linux.intel.com>

From: Andi Kleen <ak@linux.intel.com>

Not hooked up to the harness so far, because it usually needs
special boot options for 1GB pages.

Signed-off-by: Andi Kleen <ak@linux.intel.com>
---
 tools/testing/selftests/vm/Makefile    |    4 +-
 tools/testing/selftests/vm/thuge-gen.c |  218 ++++++++++++++++++++++++++++++++
 2 files changed, 220 insertions(+), 2 deletions(-)
 create mode 100644 tools/testing/selftests/vm/thuge-gen.c

diff --git a/tools/testing/selftests/vm/Makefile b/tools/testing/selftests/vm/Makefile
index b336b24..7300d07 100644
--- a/tools/testing/selftests/vm/Makefile
+++ b/tools/testing/selftests/vm/Makefile
@@ -1,9 +1,9 @@
 # Makefile for vm selftests
 
 CC = $(CROSS_COMPILE)gcc
-CFLAGS = -Wall -Wextra
+CFLAGS = -Wall
 
-all: hugepage-mmap hugepage-shm  map_hugetlb
+all: hugepage-mmap hugepage-shm  map_hugetlb thuge-gen
 %: %.c
 	$(CC) $(CFLAGS) -o $@ $^
 
diff --git a/tools/testing/selftests/vm/thuge-gen.c b/tools/testing/selftests/vm/thuge-gen.c
new file mode 100644
index 0000000..a633f24
--- /dev/null
+++ b/tools/testing/selftests/vm/thuge-gen.c
@@ -0,0 +1,218 @@
+/* Test selecting other page sizes for mmap/shmget.
+   
+   Before running this huge pages for each huge page size must have been 
+   reserved.
+   For large pages beyond MAX_ORDER (like 1GB on x86) boot options must be used.
+   Also shmmax must be increased.
+   And you need to run as root to work around some weird permissions in shm. 
+   And nothing using huge pages should run in parallel.
+   When the program aborts you may need to clean up the shm segments with 
+   ipcrm -m by hand */
+#define _GNU_SOURCE 1
+#include <sys/mman.h>
+#include <stdlib.h>
+#include <stdio.h>
+#include <sys/ipc.h>
+#include <sys/shm.h>
+#include <sys/stat.h>
+#include <glob.h>
+#include <assert.h>
+#include <unistd.h>
+#include <stdarg.h>
+#include <string.h>
+
+#define err(x) perror(x), exit(1)
+
+#define MAP_HUGE_2MB    (21 << MAP_HUGE_SHIFT)
+#define MAP_HUGE_1GB    (30 << MAP_HUGE_SHIFT)
+#define MAP_HUGE_SHIFT  26
+#define MAP_HUGE_MASK   0x3f
+#define MAP_HUGETLB	0x40000
+
+#define SHM_HUGETLB     04000   /* segment will use huge TLB pages */
+#define SHM_HUGE_SHIFT  26
+#define SHM_HUGE_MASK   0x3f
+#define SHM_HUGE_2MB    (21 << SHM_HUGE_SHIFT)
+#define SHM_HUGE_1GB    (30 << SHM_HUGE_SHIFT)
+
+#define NUM_PAGESIZES   5
+
+#define NUM_PAGES 2
+
+#define Dprintf(fmt...) printf(fmt)
+
+unsigned long page_sizes[NUM_PAGESIZES];
+int num_page_sizes;
+
+int ilog2(unsigned long v)
+{
+	int l = 0;
+	while ((1UL << l) < v)
+		l++;
+	return l;
+}
+
+void find_pagesizes(void)
+{
+	glob_t g;
+	int i;
+	glob("/sys/kernel/mm/hugepages/hugepages-*kB", 0, NULL, &g);
+	assert(g.gl_pathc <= NUM_PAGESIZES);
+	for (i = 0; i < g.gl_pathc; i++) {
+		sscanf(g.gl_pathv[i], "/sys/kernel/mm/hugepages/hugepages-%lukB",
+				&page_sizes[i]);
+		page_sizes[i] <<= 10;
+		printf("Found %luMB\n", page_sizes[i] >> 20);
+	}
+	num_page_sizes = g.gl_pathc;
+	globfree(&g);
+}
+
+unsigned long default_huge_page_size(void)
+{
+	unsigned long hps = 0;
+	char *line = NULL;
+	size_t linelen = 0;
+	FILE *f = fopen("/proc/meminfo", "r");
+	if (!f)
+		return 0;
+	while (getline(&line, &linelen, f) > 0) { 
+		if (sscanf(line, "Hugepagesize:       %lu kB", &hps) == 1) {
+			hps <<= 10;
+			break;
+		}
+	}
+	free(line);
+	return hps;
+}
+
+void show(unsigned long ps)
+{
+	char buf[100];
+	if (ps == getpagesize())
+		return;
+	printf("%luMB: ", ps >> 20);
+	fflush(stdout);
+	snprintf(buf, sizeof buf, 
+		"cat /sys/kernel/mm/hugepages/hugepages-%lukB/free_hugepages",
+		ps >> 10);
+	system(buf);
+}
+
+unsigned long read_sysfs(int warn, char *fmt, ...)
+{
+	char *line = NULL;
+	size_t linelen = 0;
+	char buf[100];
+	FILE *f;
+	va_list ap;
+	unsigned long val = 0;
+
+	va_start(ap, fmt);
+	vsnprintf(buf, sizeof buf, fmt, ap); 
+	va_end(ap);
+
+	f = fopen(buf, "r");
+	if (!f) { 
+		if (warn) 
+			printf("missing %s\n", buf);
+		return 0;
+	}
+	if (getline(&line, &linelen, f) > 0) {
+		sscanf(line, "%lu", &val);
+	}
+	fclose(f);
+	free(line);
+	return val;
+}
+
+unsigned long read_free(unsigned long ps)
+{
+	return read_sysfs(ps != getpagesize(),
+			"/sys/kernel/mm/hugepages/hugepages-%lukB/free_hugepages",
+			ps >> 10);
+}
+
+void test_mmap(unsigned long size, unsigned flags)
+{
+	char *map;
+	unsigned long before, after;
+	int err;
+	
+	before = read_free(size);
+	map = mmap(NULL, size*NUM_PAGES, PROT_READ|PROT_WRITE, 
+			MAP_PRIVATE|MAP_ANONYMOUS|MAP_HUGETLB|flags, 0, 0);
+
+	if (map == (char *)-1) err("mmap");
+	memset(map, 0xff, size*NUM_PAGES);
+	after = read_free(size);
+	Dprintf("before %lu after %lu diff %ld size %lu\n",
+		before, after, before - after, size);
+	assert(size == getpagesize() || (before - after) == NUM_PAGES);
+	show(size);
+	err = munmap(map, size);
+	assert(!err);
+}
+
+void test_shmget(unsigned long size, unsigned flags)
+{
+	int id;
+	unsigned long before, after;
+	int err;
+
+	before = read_free(size);
+	id = shmget(IPC_PRIVATE, size * NUM_PAGES, IPC_CREAT|0600|flags);
+	if (id < 0) err("shmget");
+
+	struct shm_info i;
+	if (shmctl(id, SHM_INFO, (void *)&i) < 0) err("shmctl");
+	Dprintf("alloc %lu res %lu\n", i.shm_tot, i.shm_rss);
+
+
+	Dprintf("id %d\n", id);
+	char *map = shmat(id, NULL, 0600);
+	if (map == (char*)-1) err("shmat");
+
+	//shmctl(id, IPC_RMID, NULL);
+
+	memset(map, 0xff, size*NUM_PAGES);
+	after = read_free(size);
+
+	Dprintf("before %lu after %lu diff %ld size %lu\n",
+		before, after, before - after, size);
+	assert(size == getpagesize() || (before - after) == NUM_PAGES);
+	show(size);
+	err = shmdt(map);
+	assert(!err);
+}
+
+int main(void)
+{
+	int i;
+	unsigned default_hps = default_huge_page_size();
+	
+	find_pagesizes();
+
+	for (i = 0; i < num_page_sizes; i++) {
+		unsigned long ps = page_sizes[i];
+		int arg = ilog2(ps) << MAP_HUGE_SHIFT;
+		printf("Testing %luMB mmap with shift %x\n", ps >> 20, arg);
+		test_mmap(ps, MAP_HUGETLB | arg);
+	}
+	printf("Testing default huge mmap\n");
+	test_mmap(default_hps, SHM_HUGETLB);
+	
+	puts("Testing non-huge shmget");
+	test_shmget(getpagesize(), 0);
+
+	for (i = 0; i < num_page_sizes; i++) {
+		unsigned long ps = page_sizes[i];
+		int arg = ilog2(ps) << SHM_HUGE_SHIFT;
+		printf("Testing %luMB shmget with shift %x\n", ps >> 20, arg);
+		test_shmget(ps, SHM_HUGETLB | arg);
+	}
+	puts("default huge shmget");
+	test_shmget(default_hps, SHM_HUGETLB);
+	
+	return 0;
+}
-- 
1.7.7.6

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

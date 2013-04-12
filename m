Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx117.postini.com [74.125.245.117])
	by kanga.kvack.org (Postfix) with SMTP id 3FC2F6B0027
	for <linux-mm@kvack.org>; Fri, 12 Apr 2013 11:53:49 -0400 (EDT)
Message-ID: <51682E08.9050107@parallels.com>
Date: Fri, 12 Apr 2013 19:53:44 +0400
From: Pavel Emelyanov <xemul@parallels.com>
MIME-Version: 1.0
Subject: [PATCH 6/5] selftest: Add simple test for soft-dirty bit
References: <51669E5F.4000801@parallels.com> <51669EB8.2020102@parallels.com>
In-Reply-To: <51669EB8.2020102@parallels.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Linux MM <linux-mm@kvack.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>

It creates a mapping of 3 pages and checks that reads, writes and clear-refs
result in present and soft-dirt bits reported from pagemap2 set as expected.

Signed-off-by: Pavel Emelyanov <xemul@parallels.com>

---

diff --git a/tools/testing/selftests/Makefile b/tools/testing/selftests/Makefile
index 575ef80..827f2c0 100644
--- a/tools/testing/selftests/Makefile
+++ b/tools/testing/selftests/Makefile
@@ -6,6 +6,7 @@ TARGETS += cpu-hotplug
 TARGETS += memory-hotplug
 TARGETS += efivarfs
 TARGETS += ptrace
+TARGETS += soft-dirty
 
 all:
 	for TARGET in $(TARGETS); do \
diff --git a/tools/testing/selftests/soft-dirty/Makefile b/tools/testing/selftests/soft-dirty/Makefile
new file mode 100644
index 0000000..a9cdc82
--- /dev/null
+++ b/tools/testing/selftests/soft-dirty/Makefile
@@ -0,0 +1,10 @@
+CFLAGS += -iquote../../../../include/uapi -Wall
+soft-dirty: soft-dirty.c
+
+all: soft-dirty
+
+clean:
+	rm -f soft-dirty
+
+run_tests: all
+	@./soft-dirty || echo "soft-dirty selftests: [FAIL]"
diff --git a/tools/testing/selftests/soft-dirty/soft-dirty.c b/tools/testing/selftests/soft-dirty/soft-dirty.c
new file mode 100644
index 0000000..aba4f87
--- /dev/null
+++ b/tools/testing/selftests/soft-dirty/soft-dirty.c
@@ -0,0 +1,114 @@
+#include <stdlib.h>
+#include <stdio.h>
+#include <sys/mman.h>
+#include <unistd.h>
+#include <fcntl.h>
+#include <sys/types.h>
+
+typedef unsigned long long u64;
+
+#define PME_PRESENT	(1ULL << 63)
+#define PME_SOFT_DIRTY	(1Ull << 55)
+
+#define PAGES_TO_TEST	3
+#ifndef PAGE_SIZE
+#define PAGE_SIZE	4096
+#endif
+
+static void get_pagemap2(char *mem, u64 *map)
+{
+	int fd;
+
+	fd = open("/proc/self/pagemap2", O_RDONLY);
+	if (fd < 0) {
+		perror("Can't open pagemap2");
+		exit(1);
+	}
+
+	lseek(fd, (unsigned long)mem / PAGE_SIZE * sizeof(u64), SEEK_SET);
+	read(fd, map, sizeof(u64) * PAGES_TO_TEST);
+	close(fd);
+}
+
+static inline char map_p(u64 map)
+{
+	return map & PME_PRESENT ? 'p' : '-';
+}
+
+static inline char map_sd(u64 map)
+{
+	return map & PME_SOFT_DIRTY ? 'd' : '-';
+}
+
+static int check_pte(int step, int page, u64 *map, u64 want)
+{
+	if ((map[page] & want) != want) {
+		printf("Step %d Page %d has %c%c, want %c%c\n",
+				step, page,
+				map_p(map[page]), map_sd(map[page]),
+				map_p(want), map_sd(want));
+		return 1;
+	}
+
+	return 0;
+}
+
+static void clear_refs(void)
+{
+	int fd;
+	char *v = "4";
+
+	fd = open("/proc/self/clear_refs", O_WRONLY);
+	if (write(fd, v, 3) < 3) {
+		perror("Can't clear soft-dirty bit");
+		exit(1);
+	}
+	close(fd);
+}
+
+int main(void)
+{
+	char *mem, x;
+	u64 map[PAGES_TO_TEST];
+
+	mem = mmap(NULL, PAGES_TO_TEST * PAGE_SIZE,
+			PROT_READ | PROT_WRITE, MAP_PRIVATE | MAP_ANON, 0, 0);
+
+	x = mem[0];
+	mem[2 * PAGE_SIZE] = 'c';
+	get_pagemap2(mem, map);
+
+	if (check_pte(1, 0, map, PME_PRESENT))
+		return 1;
+	if (check_pte(1, 1, map, 0))
+		return 1;
+	if (check_pte(1, 2, map, PME_PRESENT | PME_SOFT_DIRTY))
+		return 1;
+
+	clear_refs();
+	get_pagemap2(mem, map);
+
+	if (check_pte(2, 0, map, PME_PRESENT))
+		return 1;
+	if (check_pte(2, 1, map, 0))
+		return 1;
+	if (check_pte(2, 2, map, PME_PRESENT))
+		return 1;
+
+	mem[0] = 'a';
+	mem[PAGE_SIZE] = 'b';
+	x = mem[2 * PAGE_SIZE];
+	get_pagemap2(mem, map);
+
+	if (check_pte(3, 0, map, PME_PRESENT | PME_SOFT_DIRTY))
+		return 1;
+	if (check_pte(3, 1, map, PME_PRESENT | PME_SOFT_DIRTY))
+		return 1;
+	if (check_pte(3, 2, map, PME_PRESENT))
+		return 1;
+
+	(void)x; /* gcc warn */
+
+	printf("PASS\n");
+	return 0;
+}

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

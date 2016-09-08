Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f70.google.com (mail-pa0-f70.google.com [209.85.220.70])
	by kanga.kvack.org (Postfix) with ESMTP id 289656B025E
	for <linux-mm@kvack.org>; Thu,  8 Sep 2016 05:13:40 -0400 (EDT)
Received: by mail-pa0-f70.google.com with SMTP id hi6so90070496pac.0
        for <linux-mm@kvack.org>; Thu, 08 Sep 2016 02:13:40 -0700 (PDT)
Received: from mail-pf0-x241.google.com (mail-pf0-x241.google.com. [2607:f8b0:400e:c00::241])
        by mx.google.com with ESMTPS id h127si46205534pfb.251.2016.09.08.02.13.39
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 08 Sep 2016 02:13:39 -0700 (PDT)
Received: by mail-pf0-x241.google.com with SMTP id 128so2242111pfb.0
        for <linux-mm@kvack.org>; Thu, 08 Sep 2016 02:13:39 -0700 (PDT)
From: wei.guo.simon@gmail.com
Subject: [PATCH 3/3] selftests: expanding more mlock selftest
Date: Thu,  8 Sep 2016 17:12:50 +0800
Message-Id: <1473325970-11393-4-git-send-email-wei.guo.simon@gmail.com>
In-Reply-To: <1473325970-11393-1-git-send-email-wei.guo.simon@gmail.com>
References: <1473325970-11393-1-git-send-email-wei.guo.simon@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: Shuah Khan <shuah@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Vlastimil Babka <vbabka@suse.cz>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Michal Hocko <mhocko@suse.com>, Eric B Munson <emunson@akamai.com>, Simon Guo <wei.guo.simon@gmail.com>, Mel Gorman <mgorman@techsingularity.net>, Alexey Klimov <klimov.linux@gmail.com>, Andrea Arcangeli <aarcange@redhat.com>, Thierry Reding <treding@nvidia.com>, Mike Kravetz <mike.kravetz@oracle.com>, Geert Uytterhoeven <geert@linux-m68k.org>, linux-kernel@vger.kernel.org, linux-kselftest@vger.kernel.org

From: Simon Guo <wei.guo.simon@gmail.com>

This patch will randomly perform mlock/mlock2 on a given
memory region, and verify the RLIMIT_MEMLOCK limitation
works properly.

Suggested-by: David Rientjes <rientjes@google.com>
Signed-off-by: Simon Guo <wei.guo.simon@gmail.com>
---
 tools/testing/selftests/vm/Makefile               |   4 +-
 tools/testing/selftests/vm/mlock-intersect-test.c |  76 ------
 tools/testing/selftests/vm/mlock-random-test.c    | 293 ++++++++++++++++++++++
 3 files changed, 295 insertions(+), 78 deletions(-)
 delete mode 100644 tools/testing/selftests/vm/mlock-intersect-test.c
 create mode 100644 tools/testing/selftests/vm/mlock-random-test.c

diff --git a/tools/testing/selftests/vm/Makefile b/tools/testing/selftests/vm/Makefile
index a0412a8..bbab7f4 100644
--- a/tools/testing/selftests/vm/Makefile
+++ b/tools/testing/selftests/vm/Makefile
@@ -10,7 +10,7 @@ BINARIES += on-fault-limit
 BINARIES += thuge-gen
 BINARIES += transhuge-stress
 BINARIES += userfaultfd
-BINARIES += mlock-intersect-test
+BINARIES += mlock-random-test
 
 all: $(BINARIES)
 %: %.c
@@ -18,7 +18,7 @@ all: $(BINARIES)
 userfaultfd: userfaultfd.c ../../../../usr/include/linux/kernel.h
 	$(CC) $(CFLAGS) -O2 -o $@ $< -lpthread
 
-mlock-intersect-test: mlock-intersect-test.c
+mlock-random-test: mlock-random-test.c
 	$(CC) $(CFLAGS) -o $@ $< -lcap
 
 ../../../../usr/include/linux/kernel.h:
diff --git a/tools/testing/selftests/vm/mlock-intersect-test.c b/tools/testing/selftests/vm/mlock-intersect-test.c
deleted file mode 100644
index f78e68a..0000000
--- a/tools/testing/selftests/vm/mlock-intersect-test.c
+++ /dev/null
@@ -1,76 +0,0 @@
-/*
- * It tests the duplicate mlock result:
- * - the ulimit of lock page is 64k
- * - allocate address area 64k starting from p
- * - mlock   [p -- p + 30k]
- * - Then mlock address  [ p -- p + 40k ]
- *
- * It should succeed since totally we locked
- * 40k < 64k limitation.
- *
- * It should not be run with CAP_IPC_LOCK.
- */
-#include <stdlib.h>
-#include <stdio.h>
-#include <unistd.h>
-#include <sys/resource.h>
-#include <sys/capability.h>
-#include <sys/mman.h>
-#include "mlock2.h"
-
-int main(int argc, char **argv)
-{
-	struct rlimit new;
-	char *p = NULL;
-	cap_t cap = cap_init();
-	int i;
-
-	/* drop capabilities including CAP_IPC_LOCK */
-	if (cap_set_proc(cap))
-		return -1;
-
-	/* set mlock limits to 64k */
-	new.rlim_cur = 65536;
-	new.rlim_max = 65536;
-	setrlimit(RLIMIT_MEMLOCK, &new);
-
-	/* test VM_LOCK */
-	p = malloc(1024 * 64);
-	if (mlock(p, 1024 * 30)) {
-		printf("mlock() 30k return failure.\n");
-		return -1;
-	}
-	for (i = 0; i < 10; i++) {
-		if (mlock(p, 1024 * 40)) {
-			printf("mlock() #%d 40k returns failure.\n", i);
-			return -1;
-		}
-	}
-	for (i = 0; i < 10; i++) {
-		if (mlock2_(p, 1024 * 40, MLOCK_ONFAULT)) {
-			printf("mlock2_() #%d 40k returns failure.\n", i);
-			return -1;
-		}
-	}
-	free(p);
-
-	/* Test VM_LOCKONFAULT */
-	p = malloc(1024 * 64);
-	if (mlock2_(p, 1024 * 30, MLOCK_ONFAULT)) {
-		printf("mlock2_() 30k return failure.\n");
-		return -1;
-	}
-	for (i = 0; i < 10; i++) {
-		if (mlock2_(p, 1024 * 40, MLOCK_ONFAULT)) {
-			printf("mlock2_() #%d 40k returns failure.\n", i);
-			return -1;
-		}
-	}
-	for (i = 0; i < 10; i++) {
-		if (mlock(p, 1024 * 40)) {
-			printf("mlock() #%d 40k returns failure.\n", i);
-			return -1;
-		}
-	}
-	return 0;
-}
diff --git a/tools/testing/selftests/vm/mlock-random-test.c b/tools/testing/selftests/vm/mlock-random-test.c
new file mode 100644
index 0000000..83de4f5
--- /dev/null
+++ b/tools/testing/selftests/vm/mlock-random-test.c
@@ -0,0 +1,293 @@
+/*
+ * It tests the mlock/mlock2() when they are invoked
+ * on randomly memory region.
+ */
+#include <unistd.h>
+#include <sys/resource.h>
+#include <sys/capability.h>
+#include <sys/mman.h>
+#include <fcntl.h>
+#include <string.h>
+#include <sys/ipc.h>
+#include <sys/shm.h>
+#include <time.h>
+#include "mlock2.h"
+
+#define CHUNK_UNIT (128 * 1024)
+#define MLOCK_RLIMIT_SIZE (CHUNK_UNIT * 2)
+#define MLOCK_WITHIN_LIMIT_SIZE CHUNK_UNIT
+#define MLOCK_OUTOF_LIMIT_SIZE (CHUNK_UNIT * 3)
+
+#define TEST_LOOP 100
+#define PAGE_ALIGN(size, ps) (((size) + ((ps) - 1)) & ~((ps) - 1))
+
+int set_cap_limits(rlim_t max)
+{
+	struct rlimit new;
+	cap_t cap = cap_init();
+
+	new.rlim_cur = max;
+	new.rlim_max = max;
+	if (setrlimit(RLIMIT_MEMLOCK, &new)) {
+		perror("setrlimit() returns error\n");
+		return -1;
+	}
+
+	/* drop capabilities including CAP_IPC_LOCK */
+	if (cap_set_proc(cap)) {
+		perror("cap_set_proc() returns error\n");
+		return -2;
+	}
+
+	return 0;
+}
+
+int get_proc_locked_vm_size(void)
+{
+	FILE *f;
+	int ret = -1;
+	char line[1024] = {0};
+	unsigned long lock_size = 0;
+
+	f = fopen("/proc/self/status", "r");
+	if (!f) {
+		perror("fopen");
+		return -1;
+	}
+
+	while (fgets(line, 1024, f)) {
+		if (strstr(line, "VmLck")) {
+			ret = sscanf(line, "VmLck:\t%8lu kB", &lock_size);
+			if (ret <= 0) {
+				printf("sscanf() on VmLck error: %s: %d\n",
+						line, ret);
+				fclose(f);
+				return -1;
+			}
+			fclose(f);
+			return (int)(lock_size << 10);
+		}
+	}
+
+	perror("cann't parse VmLck in /proc/self/status\n");
+	fclose(f);
+	return -1;
+}
+
+/*
+ * Get the MMUPageSize of the memory region including input
+ * address from proc file.
+ *
+ * return value: on error case, 0 will be returned.
+ * Otherwise the page size(in bytes) is returned.
+ */
+int get_proc_page_size(unsigned long addr)
+{
+	FILE *smaps;
+	char *line;
+	unsigned long mmupage_size = 0;
+	size_t size;
+
+	smaps = seek_to_smaps_entry(addr);
+	if (!smaps) {
+		printf("Unable to parse /proc/self/smaps\n");
+		return 0;
+	}
+
+	while (getline(&line, &size, smaps) > 0) {
+		if (!strstr(line, "MMUPageSize")) {
+			free(line);
+			line = NULL;
+			size = 0;
+			continue;
+		}
+
+		/* found the MMUPageSize of this section */
+		if (sscanf(line, "MMUPageSize:    %8lu kB",
+					&mmupage_size) < 1) {
+			printf("Unable to parse smaps entry for Size:%s\n",
+					line);
+			break;
+		}
+
+	}
+	free(line);
+	if (smaps)
+		fclose(smaps);
+	return mmupage_size << 10;
+}
+
+/*
+ * Test mlock/mlock2() on provided memory chunk.
+ * It expects the mlock/mlock2() to be successful (within rlimit)
+ *
+ * With allocated memory chunk [p, p + alloc_size), this
+ * test will choose start/len randomly to perform mlock/mlock2
+ * [start, start +  len] memory range. The range is within range
+ * of the allocated chunk.
+ *
+ * The memory region size alloc_size is within the rlimit.
+ * So we always expect a success of mlock/mlock2.
+ *
+ * VmLck is assumed to be 0 before this test.
+ *
+ *    return value: 0 - success
+ *    else: failure
+ */
+int test_mlock_within_limit(char *p, int alloc_size)
+{
+	int i;
+	int ret = 0;
+	int locked_vm_size = 0;
+	struct rlimit cur;
+	int page_size = 0;
+
+	getrlimit(RLIMIT_MEMLOCK, &cur);
+	if (cur.rlim_cur < alloc_size) {
+		printf("alloc_size[%d] < %u rlimit,lead to mlock failure\n",
+				alloc_size, (unsigned int)cur.rlim_cur);
+		return -1;
+	}
+
+	srand(time(NULL));
+	for (i = 0; i < TEST_LOOP; i++) {
+		/*
+		 * - choose mlock/mlock2 randomly
+		 * - choose lock_size randomly but lock_size < alloc_size
+		 * - choose start_offset randomly but p+start_offset+lock_size
+		 *   < p+alloc_size
+		 */
+		int is_mlock = !!(rand() % 2);
+		int lock_size = rand() % alloc_size;
+		int start_offset = rand() % (alloc_size - lock_size);
+
+		if (is_mlock)
+			ret = mlock(p + start_offset, lock_size);
+		else
+			ret = mlock2_(p + start_offset, lock_size,
+				       MLOCK_ONFAULT);
+
+		if (ret) {
+			printf("%s() failure at |%p(%d)| mlock:|%p(%d)|\n",
+					is_mlock ? "mlock" : "mlock2",
+					p, alloc_size,
+					p + start_offset, lock_size);
+			return ret;
+		}
+	}
+
+	/*
+	 * Check VmLck left by the tests.
+	 */
+	locked_vm_size = get_proc_locked_vm_size();
+	page_size = get_proc_page_size((unsigned long)p);
+	if (page_size == 0) {
+		printf("cannot get proc MMUPageSize\n");
+		return -1;
+	}
+
+	if (locked_vm_size > PAGE_ALIGN(alloc_size, page_size) + page_size) {
+		printf("test_mlock_within_limit() left VmLck:%d on %d chunk\n",
+				locked_vm_size, alloc_size);
+		return -1;
+	}
+
+	return 0;
+}
+
+
+/*
+ * We expect the mlock/mlock2() to be fail (outof limitation)
+ *
+ * With allocated memory chunk [p, p + alloc_size), this
+ * test will randomly choose start/len and perform mlock/mlock2
+ * on [start, start+len] range.
+ *
+ * The memory region size alloc_size is above the rlimit.
+ * And the len to be locked is higher than rlimit.
+ * So we always expect a failure of mlock/mlock2.
+ * No locked page number should be increased as a side effect.
+ *
+ *    return value: 0 - success
+ *    else: failure
+ */
+int test_mlock_outof_limit(char *p, int alloc_size)
+{
+	int i;
+	int ret = 0;
+	int locked_vm_size = 0, old_locked_vm_size = 0;
+	struct rlimit cur;
+
+	getrlimit(RLIMIT_MEMLOCK, &cur);
+	if (cur.rlim_cur >= alloc_size) {
+		printf("alloc_size[%d] >%u rlimit, violates test condition\n",
+				alloc_size, (unsigned int)cur.rlim_cur);
+		return -1;
+	}
+
+	old_locked_vm_size = get_proc_locked_vm_size();
+	srand(time(NULL));
+	for (i = 0; i < TEST_LOOP; i++) {
+		int is_mlock = !!(rand() % 2);
+		int lock_size = (rand() % (alloc_size - cur.rlim_cur))
+			+ cur.rlim_cur;
+		int start_offset = rand() % (alloc_size - lock_size);
+
+		if (is_mlock)
+			ret = mlock(p + start_offset, lock_size);
+		else
+			ret = mlock2_(p + start_offset, lock_size,
+					MLOCK_ONFAULT);
+		if (ret == 0) {
+			printf("%s() succeeds? on %p(%d) mlock%p(%d)\n",
+					is_mlock ? "mlock" : "mlock2",
+					p, alloc_size,
+					p + start_offset, lock_size);
+			return -1;
+		}
+	}
+
+	locked_vm_size = get_proc_locked_vm_size();
+	if (locked_vm_size != old_locked_vm_size) {
+		printf("tests leads to new mlocked page: old[%d], new[%d]\n",
+				old_locked_vm_size,
+				locked_vm_size);
+		return -1;
+	}
+
+	return 0;
+}
+
+int main(int argc, char **argv)
+{
+	char *p = NULL;
+	int ret = 0;
+
+	if (set_cap_limits(MLOCK_RLIMIT_SIZE))
+		return -1;
+
+	p = malloc(MLOCK_WITHIN_LIMIT_SIZE);
+	if (p == NULL) {
+		perror("malloc() failure\n");
+		return -1;
+	}
+	ret = test_mlock_within_limit(p, MLOCK_WITHIN_LIMIT_SIZE);
+	if (ret)
+		return ret;
+	munlock(p, MLOCK_WITHIN_LIMIT_SIZE);
+	free(p);
+
+
+	p = malloc(MLOCK_OUTOF_LIMIT_SIZE);
+	if (p == NULL) {
+		perror("malloc() failure\n");
+		return -1;
+	}
+	ret = test_mlock_outof_limit(p, MLOCK_OUTOF_LIMIT_SIZE);
+	if (ret)
+		return ret;
+	munlock(p, MLOCK_OUTOF_LIMIT_SIZE);
+	free(p);
+
+	return 0;
+}
-- 
1.8.3.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

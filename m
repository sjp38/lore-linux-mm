Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qg0-f53.google.com (mail-qg0-f53.google.com [209.85.192.53])
	by kanga.kvack.org (Postfix) with ESMTP id 9C4286B0259
	for <linux-mm@kvack.org>; Tue,  7 Jul 2015 13:04:02 -0400 (EDT)
Received: by qgeg89 with SMTP id g89so87287783qge.3
        for <linux-mm@kvack.org>; Tue, 07 Jul 2015 10:04:02 -0700 (PDT)
Received: from prod-mail-xrelay02.akamai.com (prod-mail-xrelay02.akamai.com. [72.246.2.14])
        by mx.google.com with ESMTP id g196si25576148qhc.80.2015.07.07.10.03.51
        for <linux-mm@kvack.org>;
        Tue, 07 Jul 2015 10:03:52 -0700 (PDT)
From: Eric B Munson <emunson@akamai.com>
Subject: [PATCH V3 5/5] selftests: vm: Add tests for lock on fault
Date: Tue,  7 Jul 2015 13:03:43 -0400
Message-Id: <1436288623-13007-6-git-send-email-emunson@akamai.com>
In-Reply-To: <1436288623-13007-1-git-send-email-emunson@akamai.com>
References: <1436288623-13007-1-git-send-email-emunson@akamai.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Eric B Munson <emunson@akamai.com>, Shuah Khan <shuahkh@osg.samsung.com>, Michal Hocko <mhocko@suse.cz>, Vlastimil Babka <vbabka@suse.cz>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, linux-api@vger.kernel.org

Test the mmap() flag, and the mlockall() flag.  These tests ensure that
pages are not faulted in until they are accessed, that the pages are
unevictable once faulted in, and that VMA splitting and merging works
with the new VM flag.  The second test ensures that mlock limits are
respected.  Note that the limit test needs to be run a normal user.

Signed-off-by: Eric B Munson <emunson@akamai.com>
Cc: Shuah Khan <shuahkh@osg.samsung.com>
Cc: Michal Hocko <mhocko@suse.cz>
Cc: Vlastimil Babka <vbabka@suse.cz>
Cc: linux-mm@kvack.org
Cc: linux-kernel@vger.kernel.org
Cc: linux-api@vger.kernel.org
---
 tools/testing/selftests/vm/Makefile         |   2 +
 tools/testing/selftests/vm/lock-on-fault.c  | 342 ++++++++++++++++++++++++++++
 tools/testing/selftests/vm/on-fault-limit.c |  47 ++++
 tools/testing/selftests/vm/run_vmtests      |  22 ++
 4 files changed, 413 insertions(+)
 create mode 100644 tools/testing/selftests/vm/lock-on-fault.c
 create mode 100644 tools/testing/selftests/vm/on-fault-limit.c

diff --git a/tools/testing/selftests/vm/Makefile b/tools/testing/selftests/vm/Makefile
index 231b9a0..01b4a90 100644
--- a/tools/testing/selftests/vm/Makefile
+++ b/tools/testing/selftests/vm/Makefile
@@ -5,7 +5,9 @@ BINARIES = compaction_test
 BINARIES += hugepage-mmap
 BINARIES += hugepage-shm
 BINARIES += hugetlbfstest
+BINARIES += lock-on-fault
 BINARIES += map_hugetlb
+BINARIES += on-fault-limit
 BINARIES += thuge-gen
 BINARIES += transhuge-stress
 
diff --git a/tools/testing/selftests/vm/lock-on-fault.c b/tools/testing/selftests/vm/lock-on-fault.c
new file mode 100644
index 0000000..6e0cdc7
--- /dev/null
+++ b/tools/testing/selftests/vm/lock-on-fault.c
@@ -0,0 +1,342 @@
+#include <sys/mman.h>
+#include <stdio.h>
+#include <unistd.h>
+#include <string.h>
+#include <sys/time.h>
+#include <sys/resource.h>
+
+struct vm_boundaries {
+	unsigned long start;
+	unsigned long end;
+};
+
+static int get_vm_area(unsigned long addr, struct vm_boundaries *area)
+{
+	FILE *file;
+	int ret = 1;
+	char line[1024] = {0};
+	char *end_addr;
+	char *stop;
+	unsigned long start;
+	unsigned long end;
+
+	if (!area)
+		return ret;
+
+	file = fopen("/proc/self/maps", "r");
+	if (!file) {
+		perror("fopen");
+		return ret;
+	}
+
+	memset(area, 0, sizeof(struct vm_boundaries));
+
+	while(fgets(line, 1024, file)) {
+		end_addr = strchr(line, '-');
+		if (!end_addr) {
+			printf("cannot parse /proc/self/maps\n");
+			goto out;
+		}
+		*end_addr = '\0';
+		end_addr++;
+		stop = strchr(end_addr, ' ');
+		if (!stop) {
+			printf("cannot parse /proc/self/maps\n");
+			goto out;
+		}
+		stop = '\0';
+
+		sscanf(line, "%lx", &start);
+		sscanf(end_addr, "%lx", &end);
+
+		if (start <= addr && end > addr) {
+			area->start = start;
+			area->end = end;
+			ret = 0;
+			goto out;
+		}
+	}
+out:
+	fclose(file);
+	return ret;
+}
+
+static unsigned long get_pageflags(unsigned long addr)
+{
+	FILE *file;
+	unsigned long pfn;
+	unsigned long offset;
+
+	file = fopen("/proc/self/pagemap", "r");
+	if (!file) {
+		perror("fopen");
+		_exit(1);
+	}
+
+	offset = addr / getpagesize() * sizeof(unsigned long);
+	if (fseek(file, offset, SEEK_SET)) {
+		perror("fseek");
+		_exit(1);
+	}
+
+	if (fread(&pfn, sizeof(unsigned long), 1, file) != 1) {
+		perror("fread");
+		_exit(1);
+	}
+
+	fclose(file);
+	return pfn;
+}
+
+static unsigned long get_kpageflags(unsigned long pfn)
+{
+	unsigned long flags;
+	FILE *file;
+
+	file = fopen("/proc/kpageflags", "r");
+	if (!file) {
+		perror("fopen");
+		_exit(1);
+	}
+
+	if (fseek(file, pfn * sizeof(unsigned long), SEEK_SET)) {
+		perror("fseek");
+		_exit(1);
+	}
+
+	if (fread(&flags, sizeof(unsigned long), 1, file) != 1) {
+		perror("fread");
+		_exit(1);
+	}
+
+	fclose(file);
+	return flags;
+}
+
+#define PRESENT_BIT	0x8000000000000000
+#define PFN_MASK	0x007FFFFFFFFFFFFF
+#define UNEVICTABLE_BIT	(1UL << 18)
+
+static int test_mmap(int flags)
+{
+	unsigned long page1_flags;
+	unsigned long page2_flags;
+	void *map;
+	unsigned long page_size = getpagesize();
+
+	map = mmap(NULL, 2 * page_size, PROT_READ | PROT_WRITE, flags, 0, 0);
+	if (map == MAP_FAILED) {
+		perror("mmap()");
+		return 1;
+	}
+
+	/* Write something into the first page to ensure it is present */
+	*(char *)map = 1;
+
+	page1_flags = get_pageflags((unsigned long)map);
+	page2_flags = get_pageflags((unsigned long)map + page_size);
+
+	/* page2_flags should not be present */
+	if (page2_flags & PRESENT_BIT) {
+		printf("page map says 0x%lx\n", page2_flags);
+		printf("present is    0x%lx\n", PRESENT_BIT);
+		return 1;
+	}
+
+	/* page1_flags should be present */
+	if (page1_flags & PRESENT_BIT == 0) {
+		printf("page map says 0x%lx\n", page1_flags);
+		printf("present is    0x%lx\n", PRESENT_BIT);
+		return 1;
+	}
+
+	page1_flags = get_kpageflags(page1_flags & PFN_MASK);
+
+	/* page1_flags now contains the entry from kpageflags for the first
+	 * page, the unevictable bit should be set */
+	if (page1_flags & UNEVICTABLE_BIT == 0) {
+		printf("kpageflags says 0x%lx\n", page1_flags);
+		printf("unevictable is  0x%lx\n", UNEVICTABLE_BIT);
+		return 1;
+	}
+
+	munmap(map, 2 * page_size);
+	return 0;
+}
+
+static int test_munlock(int flags)
+{
+	int ret = 1;
+	void *map;
+	unsigned long page1_flags;
+	unsigned long page2_flags;
+	unsigned long page3_flags;
+	unsigned long page_size = getpagesize();
+
+	map = mmap(NULL, 3 * page_size, PROT_READ | PROT_WRITE, flags, 0, 0);
+	if (map == MAP_FAILED) {
+		perror("mmap()");
+		return ret;
+	}
+
+	if (munlock(map + page_size, page_size)) {
+		perror("munlock()");
+		goto out;
+	}
+
+	page1_flags = get_pageflags((unsigned long)map);
+	page2_flags = get_pageflags((unsigned long)map + page_size);
+	page3_flags = get_pageflags((unsigned long)map + page_size * 2);
+
+	/* No pages should be present */
+	if ((page1_flags & PRESENT_BIT) || (page2_flags & PRESENT_BIT) ||
+	    (page3_flags & PRESENT_BIT)) {
+		printf("Page was made present by munlock()\n");
+		goto out;
+	}
+
+	/* Write something to each page so that they are faulted in */
+	*(char*)map = 1;
+	*(char*)(map + page_size) = 1;
+	*(char*)(map + page_size * 2) = 1;
+
+	page1_flags = get_pageflags((unsigned long)map);
+	page2_flags = get_pageflags((unsigned long)map + page_size);
+	page3_flags = get_pageflags((unsigned long)map + page_size * 2);
+
+	page1_flags = get_kpageflags(page1_flags & PFN_MASK);
+	page2_flags = get_kpageflags(page2_flags & PFN_MASK);
+	page3_flags = get_kpageflags(page3_flags & PFN_MASK);
+
+	/* Pages 1 and 3 should be unevictable */
+	if (!(page1_flags & UNEVICTABLE_BIT)) {
+		printf("Missing unevictable bit on lock on fault page1\n");
+		goto out;
+	}
+	if (!(page3_flags & UNEVICTABLE_BIT)) {
+		printf("Missing unevictable bit on lock on fault page3\n");
+		goto out;
+	}
+
+	/* Page 2 should not be unevictable */
+	if (page2_flags & UNEVICTABLE_BIT) {
+		printf("Unlocked page is still marked unevictable\n");
+		goto out;
+	}
+
+	ret = 0;
+
+out:
+	munmap(map, 3 * page_size);
+	return ret;
+}
+
+static int test_vma_management(int flags)
+{
+	int ret = 1;
+	void *map;
+	unsigned long page_size = getpagesize();
+	struct vm_boundaries page1;
+	struct vm_boundaries page2;
+	struct vm_boundaries page3;
+
+	map = mmap(NULL, 3 * page_size, PROT_READ | PROT_WRITE, flags, 0, 0);
+	if (map == MAP_FAILED) {
+		perror("mmap()");
+		return ret;
+	}
+
+	if (get_vm_area((unsigned long)map, &page1) ||
+	    get_vm_area((unsigned long)map + page_size, &page2) ||
+	    get_vm_area((unsigned long)map + page_size * 2, &page3)) {
+		printf("couldn't find mapping in /proc/self/maps\n");
+		goto out;
+	}
+
+	/*
+	 * Before we unlock a portion, we need to that all three pages are in
+	 * the same VMA.  If they are not we abort this test (Note that this is
+	 * not a failure)
+	 */
+	if (page1.start != page2.start || page2.start != page3.start) {
+		printf("VMAs are not merged to start, aborting test\n");
+		ret = 0;
+		goto out;
+	}
+
+	if (munlock(map + page_size, page_size)) {
+		perror("munlock()");
+		goto out;
+	}
+
+	if (get_vm_area((unsigned long)map, &page1) ||
+	    get_vm_area((unsigned long)map + page_size, &page2) ||
+	    get_vm_area((unsigned long)map + page_size * 2, &page3)) {
+		printf("couldn't find mapping in /proc/self/maps\n");
+		goto out;
+	}
+
+	/* All three VMAs should be different */
+	if (page1.start == page2.start || page2.start == page3.start) {
+		printf("failed to split VMA for munlock\n");
+		goto out;
+	}
+
+	/* Now unlock the first and third page and check the VMAs again */
+	if (munlock(map, page_size * 3)) {
+		perror("munlock()");
+		goto out;
+	}
+
+	if (get_vm_area((unsigned long)map, &page1) ||
+	    get_vm_area((unsigned long)map + page_size, &page2) ||
+	    get_vm_area((unsigned long)map + page_size * 2, &page3)) {
+		printf("couldn't find mapping in /proc/self/maps\n");
+		goto out;
+	}
+
+	/* Now all three VMAs should be the same */
+	if (page1.start != page2.start || page2.start != page3.start) {
+		printf("failed to merge VMAs after munlock\n");
+		goto out;
+	}
+
+	ret = 0;
+out:
+	munmap(map, 3 * page_size);
+	return ret;
+}
+
+#ifndef MCL_ONFAULT
+#define MCL_ONFAULT (MCL_FUTURE << 1)
+#endif
+
+static int test_mlockall(int (test_function)(int flags))
+{
+	int ret = 1;
+
+	if (mlockall(MCL_ONFAULT)) {
+		perror("mlockall");
+		return ret;
+	}
+
+	ret = test_function(MAP_PRIVATE | MAP_ANONYMOUS);
+	munlockall();
+	return ret;
+}
+
+#ifndef MAP_LOCKONFAULT
+#define MAP_LOCKONFAULT (MAP_HUGETLB << 1)
+#endif
+
+int main(int argc, char **argv)
+{
+	int ret = 0;
+	ret += test_mmap(MAP_PRIVATE | MAP_ANONYMOUS | MAP_LOCKONFAULT);
+	ret += test_mlockall(test_mmap);
+	ret += test_munlock(MAP_PRIVATE | MAP_ANONYMOUS | MAP_LOCKONFAULT);
+	ret += test_mlockall(test_munlock);
+	ret += test_vma_management(MAP_PRIVATE | MAP_ANONYMOUS | MAP_LOCKONFAULT);
+	ret += test_mlockall(test_vma_management);
+	return ret;
+}
diff --git a/tools/testing/selftests/vm/on-fault-limit.c b/tools/testing/selftests/vm/on-fault-limit.c
new file mode 100644
index 0000000..ed2a109
--- /dev/null
+++ b/tools/testing/selftests/vm/on-fault-limit.c
@@ -0,0 +1,47 @@
+#include <sys/mman.h>
+#include <stdio.h>
+#include <unistd.h>
+#include <string.h>
+#include <sys/time.h>
+#include <sys/resource.h>
+
+#ifndef MCL_ONFAULT
+#define MCL_ONFAULT (MCL_FUTURE << 1)
+#endif
+
+static int test_limit(void)
+{
+	int ret = 1;
+	struct rlimit lims;
+	void *map;
+
+	if (getrlimit(RLIMIT_MEMLOCK, &lims)) {
+		perror("getrlimit");
+		return ret;
+	}
+
+	if (mlockall(MCL_ONFAULT)) {
+		perror("mlockall");
+		return ret;
+	}
+
+	map = mmap(NULL, 2 * lims.rlim_max, PROT_READ | PROT_WRITE,
+		   MAP_PRIVATE | MAP_ANONYMOUS | MAP_POPULATE, 0, 0);
+	if (map != MAP_FAILED)
+		printf("mmap should have failed, but didn't\n");
+	else {
+		ret = 0;
+		munmap(map, 2 * lims.rlim_max);
+	}
+
+	munlockall();
+	return ret;
+}
+
+int main(int argc, char **argv)
+{
+	int ret = 0;
+
+	ret += test_limit();
+	return ret;
+}
diff --git a/tools/testing/selftests/vm/run_vmtests b/tools/testing/selftests/vm/run_vmtests
index 49ece11..45241df 100755
--- a/tools/testing/selftests/vm/run_vmtests
+++ b/tools/testing/selftests/vm/run_vmtests
@@ -102,4 +102,26 @@ else
 	echo "[PASS]"
 fi
 
+echo "--------------------"
+echo "running lock-on-fault"
+echo "--------------------"
+./lock-on-fault
+if [ $? -ne 0 ]; then
+	echo "[FAIL]"
+	exitcode=1
+else
+	echo "[PASS]"
+fi
+
+echo "--------------------"
+echo "running on-fault-limit"
+echo "--------------------"
+sudo -u nobody ./on-fault-limit
+if [ $? -ne 0 ]; then
+	echo "[FAIL]"
+	exitcode=1
+else
+	echo "[PASS]"
+fi
+
 exit $exitcode
-- 
1.9.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

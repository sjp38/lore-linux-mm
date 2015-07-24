Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qg0-f44.google.com (mail-qg0-f44.google.com [209.85.192.44])
	by kanga.kvack.org (Postfix) with ESMTP id 65DF56B0258
	for <linux-mm@kvack.org>; Fri, 24 Jul 2015 17:29:01 -0400 (EDT)
Received: by qgii95 with SMTP id i95so16753622qgi.2
        for <linux-mm@kvack.org>; Fri, 24 Jul 2015 14:29:01 -0700 (PDT)
Received: from prod-mail-xrelay07.akamai.com ([23.79.238.175])
        by mx.google.com with ESMTP id f185si11679392qhc.71.2015.07.24.14.28.48
        for <linux-mm@kvack.org>;
        Fri, 24 Jul 2015 14:28:48 -0700 (PDT)
From: Eric B Munson <emunson@akamai.com>
Subject: [PATCH V5 6/7] selftests: vm: Add tests for lock on fault
Date: Fri, 24 Jul 2015 17:28:44 -0400
Message-Id: <1437773325-8623-7-git-send-email-emunson@akamai.com>
In-Reply-To: <1437773325-8623-1-git-send-email-emunson@akamai.com>
References: <1437773325-8623-1-git-send-email-emunson@akamai.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Eric B Munson <emunson@akamai.com>, Shuah Khan <shuahkh@osg.samsung.com>, Michal Hocko <mhocko@suse.cz>, Vlastimil Babka <vbabka@suse.cz>, Jonathan Corbet <corbet@lwn.net>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, linux-api@vger.kernel.org

Test the mmap() flag, and the mlockall() flag.  These tests ensure that
pages are not faulted in until they are accessed, that the pages are
unevictable once faulted in, and that VMA splitting and merging works
with the new VM flag.  The second test ensures that mlock limits are
respected.  Note that the limit test needs to be run a normal user.

Also add tests to use the new mlock2 family of system calls.

Signed-off-by: Eric B Munson <emunson@akamai.com>
Cc: Shuah Khan <shuahkh@osg.samsung.com>
Cc: Michal Hocko <mhocko@suse.cz>
Cc: Vlastimil Babka <vbabka@suse.cz>
Cc: Jonathan Corbet <corbet@lwn.net>
Cc: linux-mm@kvack.org
Cc: linux-kernel@vger.kernel.org
Cc: linux-api@vger.kernel.org
---
 tools/testing/selftests/vm/Makefile         |   3 +
 tools/testing/selftests/vm/lock-on-fault.c  | 344 +++++++++++++++++++
 tools/testing/selftests/vm/mlock2-tests.c   | 507 ++++++++++++++++++++++++++++
 tools/testing/selftests/vm/on-fault-limit.c |  47 +++
 tools/testing/selftests/vm/run_vmtests      |  33 ++
 5 files changed, 934 insertions(+)
 create mode 100644 tools/testing/selftests/vm/lock-on-fault.c
 create mode 100644 tools/testing/selftests/vm/mlock2-tests.c
 create mode 100644 tools/testing/selftests/vm/on-fault-limit.c

diff --git a/tools/testing/selftests/vm/Makefile b/tools/testing/selftests/vm/Makefile
index 231b9a0..0fe6524 100644
--- a/tools/testing/selftests/vm/Makefile
+++ b/tools/testing/selftests/vm/Makefile
@@ -5,7 +5,10 @@ BINARIES = compaction_test
 BINARIES += hugepage-mmap
 BINARIES += hugepage-shm
 BINARIES += hugetlbfstest
+BINARIES += lock-on-fault
 BINARIES += map_hugetlb
+BINARIES += mlock2-tests
+BINARIES += on-fault-limit
 BINARIES += thuge-gen
 BINARIES += transhuge-stress
 
diff --git a/tools/testing/selftests/vm/lock-on-fault.c b/tools/testing/selftests/vm/lock-on-fault.c
new file mode 100644
index 0000000..9783994
--- /dev/null
+++ b/tools/testing/selftests/vm/lock-on-fault.c
@@ -0,0 +1,344 @@
+#include <sys/mman.h>
+#include <stdio.h>
+#include <unistd.h>
+#include <string.h>
+#include <sys/time.h>
+#include <sys/resource.h>
+#include <errno.h>
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
+	if ((page1_flags & PRESENT_BIT) == 0) {
+		printf("page map says 0x%lx\n", page1_flags);
+		printf("present is    0x%lx\n", PRESENT_BIT);
+		return 1;
+	}
+
+	page1_flags = get_kpageflags(page1_flags & PFN_MASK);
+
+	/* page1_flags now contains the entry from kpageflags for the first
+	 * page, the unevictable bit should be set */
+	if ((page1_flags & UNEVICTABLE_BIT) == 0) {
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
+	if (mlockall(MCL_ONFAULT | MCL_FUTURE)) {
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
+
diff --git a/tools/testing/selftests/vm/mlock2-tests.c b/tools/testing/selftests/vm/mlock2-tests.c
new file mode 100644
index 0000000..9acf9c2
--- /dev/null
+++ b/tools/testing/selftests/vm/mlock2-tests.c
@@ -0,0 +1,507 @@
+#include <sys/mman.h>
+#include <stdio.h>
+#include <stdlib.h>
+#include <unistd.h>
+#include <string.h>
+#include <sys/time.h>
+#include <sys/resource.h>
+#include <errno.h>
+#include <stdbool.h>
+
+#ifndef MLOCK_LOCK
+#define MLOCK_LOCK 1
+#endif
+
+#ifndef MLOCK_ONFAULT
+#define MLOCK_ONFAULT 2
+#endif
+
+#ifndef MCL_ONFAULT
+#define MCL_ONFAULT (MCL_FUTURE << 1)
+#endif
+
+static int mlock2_(void *start, size_t len, int flags)
+{
+#ifdef __NR_mlock2
+	return syscall(__NR_mlock2, start, len, flags);
+#else
+	errno = ENOSYS;
+	return -1;
+#endif
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
+		perror("fopen pagemap");
+		_exit(1);
+	}
+
+	offset = addr / getpagesize() * sizeof(unsigned long);
+	if (fseek(file, offset, SEEK_SET)) {
+		perror("fseek pagemap");
+		_exit(1);
+	}
+
+	if (fread(&pfn, sizeof(unsigned long), 1, file) != 1) {
+		perror("fread pagemap");
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
+		perror("fopen kpageflags");
+		_exit(1);
+	}
+
+	if (fseek(file, pfn * sizeof(unsigned long), SEEK_SET)) {
+		perror("fseek kpageflags");
+		_exit(1);
+	}
+
+	if (fread(&flags, sizeof(unsigned long), 1, file) != 1) {
+		perror("fread kpageflags");
+		_exit(1);
+	}
+
+	fclose(file);
+	return flags;
+}
+
+#define VMFLAGS "VmFlags:"
+
+static bool find_flag(FILE *file, const char *vmflag)
+{
+	char *line = NULL;
+	char *flags;
+	size_t size = 0;
+	bool ret = false;
+
+	while (getline(&line, &size, file) > 0) {
+		if (!strstr(line, VMFLAGS)) {
+			free(line);
+			line = NULL;
+			size = 0;
+			continue;
+		}
+
+		flags = line + strlen(VMFLAGS);
+		ret = (strstr(flags, vmflag) != NULL);
+		goto out;
+	}
+
+out:
+	free(line);
+	return ret;
+}
+
+static bool is_vmflag_set(unsigned long addr, const char *vmflag)
+{
+	FILE *file;
+	char *line = NULL;
+	size_t size = 0;
+	bool ret = false;
+	unsigned long start, end;
+	char perms[5];
+	unsigned long offset;
+	char dev[32];
+	unsigned long inode;
+	char path[BUFSIZ];
+
+	file = fopen("/proc/self/smaps", "r");
+	if (!file) {
+		perror("fopen smaps");
+		_exit(1);
+	}
+
+	while (getline(&line, &size, file) > 0) {
+		if (sscanf(line, "%lx-%lx %s %lx %s %lu %s\n",
+			   &start, &end, perms, &offset, dev, &inode, path) < 6)
+			goto next;
+
+		if (start <= addr && addr < end) {
+			ret = find_flag(file, vmflag);
+			goto out;
+		}
+
+next:
+		free(line);
+		line = NULL;
+		size = 0;
+	}
+
+out:
+	free(line);
+	fclose(file);
+	return ret;
+}
+
+#define PRESENT_BIT     0x8000000000000000
+#define PFN_MASK        0x007FFFFFFFFFFFFF
+#define UNEVICTABLE_BIT (1UL << 18)
+
+#define LOCKED "lo"
+#define LOCKEDONFAULT "lf"
+
+static int lock_check(char *map)
+{
+	unsigned long page1_flags;
+	unsigned long page2_flags;
+	unsigned long page_size = getpagesize();
+
+	page1_flags = get_pageflags((unsigned long)map);
+	page2_flags = get_pageflags((unsigned long)map + page_size);
+
+	/* Both pages should be present */
+	if (((page1_flags & PRESENT_BIT) == 0) ||
+	    ((page2_flags & PRESENT_BIT) == 0)) {
+		printf("Failed to make both pages present\n");
+		return 1;
+	}
+
+	page1_flags = get_kpageflags(page1_flags & PFN_MASK);
+	page2_flags = get_kpageflags(page2_flags & PFN_MASK);
+
+	/* Both pages should be unevictable */
+	if (((page1_flags & UNEVICTABLE_BIT) == 0) ||
+	    ((page2_flags & UNEVICTABLE_BIT) == 0)) {
+		printf("Failed to make both pages unevictable\n");
+		return 1;
+	}
+
+	if (!is_vmflag_set((unsigned long)map, LOCKED) ||
+	    !is_vmflag_set((unsigned long)map + page_size, LOCKED)) {
+		printf("VMA flag %s is missing\n", LOCKED);
+		return 1;
+	}
+
+	return 0;
+}
+
+static int unlock_lock_check(char *map)
+{
+	unsigned long page1_flags;
+	unsigned long page2_flags;
+	unsigned long page_size = getpagesize();
+
+	page1_flags = get_pageflags((unsigned long)map);
+	page2_flags = get_pageflags((unsigned long)map + page_size);
+	page1_flags = get_kpageflags(page1_flags & PFN_MASK);
+	page2_flags = get_kpageflags(page2_flags & PFN_MASK);
+
+	if ((page1_flags & UNEVICTABLE_BIT) || (page2_flags & UNEVICTABLE_BIT)) {
+		printf("A page is still marked unevictable after unlock\n");
+		return 1;
+	}
+
+	if (is_vmflag_set((unsigned long)map, LOCKED) ||
+	    is_vmflag_set((unsigned long)map + page_size, LOCKED)) {
+		printf("VMA flag %s is still set after unlock\n", LOCKED);
+		return 1;
+	}
+
+	return 0;
+}
+
+static int test_mlock_lock()
+{
+	char *map;
+	int ret = 1;
+	unsigned long page_size = getpagesize();
+
+	map = mmap(NULL, 2 * page_size, PROT_READ | PROT_WRITE,
+		   MAP_ANONYMOUS | MAP_PRIVATE, 0, 0);
+	if (map == MAP_FAILED) {
+		perror("test_mlock_locked mmap");
+		goto out;
+	}
+
+	if (mlock2_(map, 2 * page_size, MLOCK_LOCK)) {
+		if (errno == ENOSYS) {
+			printf("Cannot call new mlock family, skipping test\n");
+			_exit(0);
+		}
+		perror("mlock2(MLOCK_LOCK)");
+		goto unmap;
+	}
+
+	if (lock_check(map))
+		goto unmap;
+
+	/* Now unlock and recheck attributes */
+	if (munlock(map, 2 * page_size)) {
+		perror("munlock()");
+		goto unmap;
+	}
+
+	ret = unlock_lock_check(map);
+
+unmap:
+	munmap(map, 2 * page_size);
+out:
+	return ret;
+}
+
+static int onfault_check(char *map)
+{
+	unsigned long page1_flags;
+	unsigned long page2_flags;
+	unsigned long page_size = getpagesize();
+
+	page1_flags = get_pageflags((unsigned long)map);
+	page2_flags = get_pageflags((unsigned long)map + page_size);
+
+	/* Neither page should be present */
+	if ((page1_flags & PRESENT_BIT) || (page2_flags & PRESENT_BIT)) {
+		printf("Pages were made present by MLOCK_ONFAULT\n");
+		return 1;
+	}
+
+	*map = 'a';
+	page1_flags = get_pageflags((unsigned long)map);
+	page2_flags = get_pageflags((unsigned long)map + page_size);
+
+	/* Only page 1 should be present */
+	if ((page1_flags & PRESENT_BIT) == 0) {
+		printf("Page 1 is not present after fault\n");
+		return 1;
+	} else if (page2_flags & PRESENT_BIT) {
+		printf("Page 2 was made present\n");
+		return 1;
+	}
+
+	page1_flags = get_kpageflags(page1_flags & PFN_MASK);
+
+	/* Page 1 should be unevictable */
+	if ((page1_flags & UNEVICTABLE_BIT) == 0) {
+		printf("Failed to make faulted page unevictable\n");
+		return 1;
+	}
+
+	if (!is_vmflag_set((unsigned long)map, LOCKEDONFAULT) ||
+	    !is_vmflag_set((unsigned long)map + page_size, LOCKEDONFAULT)) {
+		printf("VMA flag %s is missing\n", LOCKEDONFAULT);
+		return 1;
+	}
+
+	return 0;
+}
+
+static int unlock_onfault_check(char *map)
+{
+	unsigned long page1_flags;
+	unsigned long page2_flags;
+	unsigned long page_size = getpagesize();
+
+	page1_flags = get_pageflags((unsigned long)map);
+	page1_flags = get_kpageflags(page1_flags & PFN_MASK);
+
+	if (page1_flags & UNEVICTABLE_BIT) {
+		printf("Page 1 is still marked unevictable after unlock\n");
+		return 1;
+	}
+
+	if (is_vmflag_set((unsigned long)map, LOCKEDONFAULT) ||
+	    is_vmflag_set((unsigned long)map + page_size, LOCKEDONFAULT)) {
+		printf("VMA flag %s is still set after unlock\n", LOCKEDONFAULT);
+		return 1;
+	}
+
+	return 0;
+}
+
+static int test_mlock_onfault()
+{
+	char *map;
+	int ret = 1;
+	unsigned long page_size = getpagesize();
+
+	map = mmap(NULL, 2 * page_size, PROT_READ | PROT_WRITE,
+		   MAP_ANONYMOUS | MAP_PRIVATE, 0, 0);
+	if (map == MAP_FAILED) {
+		perror("test_mlock_locked mmap");
+		goto out;
+	}
+
+	if (mlock2_(map, 2 * page_size, MLOCK_ONFAULT)) {
+		if (errno == ENOSYS) {
+			printf("Cannot call new mlock family, skipping test\n");
+			_exit(0);
+		}
+		perror("mlock2(MLOCK_ONFAULT)");
+		goto unmap;
+	}
+
+	if (onfault_check(map))
+		goto unmap;
+
+	/* Now unlock and recheck attributes */
+	if (munlock(map, 2 * page_size)) {
+		if (errno == ENOSYS) {
+			printf("Cannot call new mlock family, skipping test\n");
+			_exit(0);
+		}
+		perror("munlock2(MLOCK_LOCK)");
+		goto unmap;
+	}
+
+	ret = unlock_onfault_check(map);
+unmap:
+	munmap(map, 2 * page_size);
+out:
+	return ret;
+}
+
+static int test_lock_onfault_of_present()
+{
+	char *map;
+	int ret = 1;
+	unsigned long page1_flags;
+	unsigned long page2_flags;
+	unsigned long page_size = getpagesize();
+
+	map = mmap(NULL, 2 * page_size, PROT_READ | PROT_WRITE,
+		   MAP_ANONYMOUS | MAP_PRIVATE, 0, 0);
+	if (map == MAP_FAILED) {
+		perror("test_mlock_locked mmap");
+		goto out;
+	}
+
+	*map = 'a';
+
+	if (mlock2_(map, 2 * page_size, MLOCK_ONFAULT)) {
+		if (errno == ENOSYS) {
+			printf("Cannot call new mlock family, skipping test\n");
+			_exit(0);
+		}
+		perror("mlock2(MLOCK_ONFAULT)");
+		goto unmap;
+	}
+
+	page1_flags = get_pageflags((unsigned long)map);
+	page2_flags = get_pageflags((unsigned long)map + page_size);
+	page1_flags = get_kpageflags(page1_flags & PFN_MASK);
+	page2_flags = get_kpageflags(page2_flags & PFN_MASK);
+
+	/* Page 1 should be unevictable */
+	if ((page1_flags & UNEVICTABLE_BIT) == 0) {
+		printf("Failed to make present page unevictable\n");
+		goto unmap;
+	}
+
+	if (!is_vmflag_set((unsigned long)map, LOCKEDONFAULT) ||
+	    !is_vmflag_set((unsigned long)map + page_size, LOCKEDONFAULT)) {
+		printf("VMA flag %s is missing for one of the pages\n", LOCKEDONFAULT);
+		goto unmap;
+	}
+	ret = 0;
+unmap:
+	munmap(map, 2 * page_size);
+out:
+	return ret;
+}
+
+static int test_munlockall()
+{
+	char *map;
+	int ret = 1;
+	unsigned long page1_flags;
+	unsigned long page2_flags;
+	unsigned long page_size = getpagesize();
+
+	map = mmap(NULL, 2 * page_size, PROT_READ | PROT_WRITE,
+		   MAP_ANONYMOUS | MAP_PRIVATE, 0, 0);
+
+	if (map == MAP_FAILED) {
+		perror("test_munlockall mmap");
+		goto out;
+	}
+
+	if (mlockall(MCL_CURRENT)) {
+		perror("mlockall(MCL_CURRENT)");
+		goto out;
+	}
+
+	if (lock_check(map))
+		goto unmap;
+
+	if (munlockall()) {
+		perror("munlockall()");
+		goto unmap;
+	}
+
+	if (unlock_lock_check(map))
+		goto unmap;
+
+	munmap(map, 2 * page_size);
+
+	map = mmap(NULL, 2 * page_size, PROT_READ | PROT_WRITE,
+		   MAP_ANONYMOUS | MAP_PRIVATE, 0, 0);
+
+	if (map == MAP_FAILED) {
+		perror("test_munlockall second mmap");
+		goto out;
+	}
+
+	if (mlockall(MCL_ONFAULT)) {
+		perror("mlockall(MCL_ONFAULT)");
+		goto unmap;
+	}
+
+	if (onfault_check(map))
+		goto unmap;
+
+	if (munlockall()) {
+		perror("munlockall()");
+		goto unmap;
+	}
+
+	if (unlock_onfault_check(map))
+		goto unmap;
+
+	if (mlockall(MCL_CURRENT | MCL_FUTURE)) {
+		perror("mlockall(MCL_CURRENT | MCL_FUTURE)");
+		goto out;
+	}
+
+	if (lock_check(map))
+		goto unmap;
+
+	if (munlockall()) {
+		perror("munlockall()");
+		goto unmap;
+	}
+
+	ret = unlock_lock_check(map);
+
+unmap:
+	munmap(map, 2 * page_size);
+out:
+	munlockall();
+	return ret;
+}
+
+int main(char **argv, int argc)
+{
+	int ret = 0;
+	ret += test_mlock_lock();
+	ret += test_mlock_onfault();
+	ret += test_munlockall();
+	ret += test_lock_onfault_of_present();
+	return ret;
+}
+
diff --git a/tools/testing/selftests/vm/on-fault-limit.c b/tools/testing/selftests/vm/on-fault-limit.c
new file mode 100644
index 0000000..0ae458f
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
+	if (mlockall(MCL_ONFAULT | MCL_FUTURE)) {
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
index 49ece11..990a61f 100755
--- a/tools/testing/selftests/vm/run_vmtests
+++ b/tools/testing/selftests/vm/run_vmtests
@@ -102,4 +102,37 @@ else
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
+echo "--------------------"
+echo "running mlock2-tests"
+echo "--------------------"
+./mlock2-tests
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

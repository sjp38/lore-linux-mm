Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qc0-f178.google.com (mail-qc0-f178.google.com [209.85.216.178])
	by kanga.kvack.org (Postfix) with ESMTP id 0C3A26B0070
	for <linux-mm@kvack.org>; Tue,  2 Jun 2015 14:13:32 -0400 (EDT)
Received: by qcmi9 with SMTP id i9so63250717qcm.0
        for <linux-mm@kvack.org>; Tue, 02 Jun 2015 11:13:31 -0700 (PDT)
Received: from prod-mail-xrelay02.akamai.com (prod-mail-xrelay02.akamai.com. [72.246.2.14])
        by mx.google.com with ESMTP id 78si16535478qkp.59.2015.06.02.11.13.28
        for <linux-mm@kvack.org>;
        Tue, 02 Jun 2015 11:13:28 -0700 (PDT)
From: Eric B Munson <emunson@akamai.com>
Subject: [PATCH V2 3/3] Add tests for lock on fault
Date: Tue,  2 Jun 2015 14:13:26 -0400
Message-Id: <1433268806-17109-4-git-send-email-emunson@akamai.com>
In-Reply-To: <1433268806-17109-1-git-send-email-emunson@akamai.com>
References: <1433268806-17109-1-git-send-email-emunson@akamai.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Eric B Munson <emunson@akamai.com>, Shuah Khan <shuahkh@osg.samsung.com>, Michal Hocko <mhocko@suse.cz>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, linux-api@vger.kernel.org

Test the mmap() flag, the mlockall() flag, and ensure that mlock limits
are respected.  Note that the limit test needs to be run a normal user.

Signed-off-by: Eric B Munson <emunson@akamai.com>
Cc: Shuah Khan <shuahkh@osg.samsung.com>
Cc: Michal Hocko <mhocko@suse.cz>
Cc: linux-mm@kvack.org
Cc: linux-kernel@vger.kernel.org
Cc: linux-api@vger.kernel.org
---
 tools/testing/selftests/vm/Makefile         |   8 +-
 tools/testing/selftests/vm/lock-on-fault.c  | 145 ++++++++++++++++++++++++++++
 tools/testing/selftests/vm/on-fault-limit.c |  47 +++++++++
 tools/testing/selftests/vm/run_vmtests      |  23 +++++
 4 files changed, 222 insertions(+), 1 deletion(-)
 create mode 100644 tools/testing/selftests/vm/lock-on-fault.c
 create mode 100644 tools/testing/selftests/vm/on-fault-limit.c

diff --git a/tools/testing/selftests/vm/Makefile b/tools/testing/selftests/vm/Makefile
index a5ce953..32f3d20 100644
--- a/tools/testing/selftests/vm/Makefile
+++ b/tools/testing/selftests/vm/Makefile
@@ -1,7 +1,13 @@
 # Makefile for vm selftests
 
 CFLAGS = -Wall
-BINARIES = hugepage-mmap hugepage-shm map_hugetlb thuge-gen hugetlbfstest
+BINARIES = hugepage-mmap
+BINARIES += hugepage-shm
+BINARIES += hugetlbfstest
+BINARIES += lock-on-fault
+BINARIES += map_hugetlb
+BINARIES += on-fault-limit
+BINARIES += thuge-gen
 BINARIES += transhuge-stress
 
 all: $(BINARIES)
diff --git a/tools/testing/selftests/vm/lock-on-fault.c b/tools/testing/selftests/vm/lock-on-fault.c
new file mode 100644
index 0000000..4659303
--- /dev/null
+++ b/tools/testing/selftests/vm/lock-on-fault.c
@@ -0,0 +1,145 @@
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
+#define PRESENT_BIT	0x8000000000000000
+#define PFN_MASK	0x007FFFFFFFFFFFFF
+#define UNEVICTABLE_BIT	(1UL << 18)
+
+static int check_pageflags(void *map)
+{
+	FILE *file;
+	unsigned long pfn1;
+	unsigned long pfn2;
+	unsigned long offset1;
+	unsigned long offset2;
+	int ret = 1;
+
+	file = fopen("/proc/self/pagemap", "r");
+	if (!file) {
+		perror("fopen");
+		return ret;
+	}
+	offset1 = (unsigned long)map / getpagesize() * sizeof(unsigned long);
+	offset2 = ((unsigned long)map + getpagesize()) / getpagesize() * sizeof(unsigned long);
+	if (fseek(file, offset1, SEEK_SET)) {
+		perror("fseek");
+		goto out;
+	}
+
+	if (fread(&pfn1, sizeof(unsigned long), 1, file) != 1) {
+		perror("fread");
+		goto out;
+	}
+
+	if (fseek(file, offset2, SEEK_SET)) {
+		perror("fseek");
+		goto out;
+	}
+
+	if (fread(&pfn2, sizeof(unsigned long), 1, file) != 1) {
+		perror("fread");
+		goto out;
+	}
+
+	/* pfn2 should not be present */
+	if (pfn2 & PRESENT_BIT) {
+		printf("page map says 0x%lx\n", pfn2);
+		printf("present is    0x%lx\n", PRESENT_BIT);
+		goto out;
+	}
+
+	/* pfn1 should be present */
+	if ((pfn1 & PRESENT_BIT) == 0) {
+		printf("page map says 0x%lx\n", pfn1);
+		printf("present is    0x%lx\n", PRESENT_BIT);
+		goto out;
+	}
+
+	pfn1 &= PFN_MASK;
+	fclose(file);
+	file = fopen("/proc/kpageflags", "r");
+	if (!file) {
+		perror("fopen");
+		munmap(map, 2 * getpagesize());
+		return ret;
+	}
+
+	if (fseek(file, pfn1 * sizeof(unsigned long), SEEK_SET)) {
+		perror("fseek");
+		goto out;
+	}
+
+	if (fread(&pfn2, sizeof(unsigned long), 1, file) != 1) {
+		perror("fread");
+		goto out;
+	}
+
+	/* pfn2 now contains the entry from kpageflags for the first page, the
+	 * unevictable bit should be set */
+	if ((pfn2 & UNEVICTABLE_BIT) == 0) {
+		printf("kpageflags says 0x%lx\n", pfn2);
+		printf("unevictable is  0x%lx\n", UNEVICTABLE_BIT);
+		goto out;
+	}
+
+	ret = 0;
+
+out:
+	fclose(file);
+	return ret;
+}
+
+static int test_mmap(int flags)
+{
+	int ret = 1;
+	void *map;
+
+	map = mmap(NULL, 2 * getpagesize(), PROT_READ | PROT_WRITE, flags, 0, 0);
+	if (map == MAP_FAILED) {
+		perror("mmap()");
+		return ret;
+	}
+
+	/* Write something into the first page to ensure it is present */
+	*(char *)map = 1;
+
+	ret = check_pageflags(map);
+
+	munmap(map, 2 * getpagesize());
+	return ret;
+}
+
+static int test_mlockall(void)
+{
+	int ret = 1;
+
+	if (mlockall(MCL_ONFAULT)) {
+		perror("mlockall");
+		return ret;
+	}
+
+	ret = test_mmap(MAP_PRIVATE | MAP_ANONYMOUS);
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
+
+	ret += test_mmap(MAP_PRIVATE | MAP_ANONYMOUS | MAP_LOCKONFAULT);
+	ret += test_mlockall();
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
index c87b681..c1aecce 100755
--- a/tools/testing/selftests/vm/run_vmtests
+++ b/tools/testing/selftests/vm/run_vmtests
@@ -90,4 +90,27 @@ fi
 umount $mnt
 rm -rf $mnt
 echo $nr_hugepgs > /proc/sys/vm/nr_hugepages
+
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

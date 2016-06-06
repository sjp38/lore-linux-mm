Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f199.google.com (mail-ig0-f199.google.com [209.85.213.199])
	by kanga.kvack.org (Postfix) with ESMTP id 1A91B6B0261
	for <linux-mm@kvack.org>; Mon,  6 Jun 2016 13:53:28 -0400 (EDT)
Received: by mail-ig0-f199.google.com with SMTP id lp2so115435947igb.3
        for <linux-mm@kvack.org>; Mon, 06 Jun 2016 10:53:28 -0700 (PDT)
Received: from userp1040.oracle.com (userp1040.oracle.com. [156.151.31.81])
        by mx.google.com with ESMTPS id l73si13616545itl.82.2016.06.06.10.53.21
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 06 Jun 2016 10:53:22 -0700 (PDT)
From: Mike Kravetz <mike.kravetz@oracle.com>
Subject: [RFC PATCH 6/6] selftests/userfaultfd: add userfaultfd_hugetlb test
Date: Mon,  6 Jun 2016 10:45:31 -0700
Message-Id: <1465235131-6112-7-git-send-email-mike.kravetz@oracle.com>
In-Reply-To: <1465235131-6112-1-git-send-email-mike.kravetz@oracle.com>
References: <1465235131-6112-1-git-send-email-mike.kravetz@oracle.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, linux-kernel@vger.kernel.org
Cc: Andrea Arcangeli <aarcange@redhat.com>, Hugh Dickins <hughd@google.com>, Dave Hansen <dave.hansen@linux.intel.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Hillf Danton <hillf.zj@alibaba-inc.com>, Michal Hocko <mhocko@suse.com>, Andrew Morton <akpm@linux-foundation.org>, Mike Kravetz <mike.kravetz@oracle.com>

Test userfaultfd hugetlb functionality by using the existing testing
method (in userfaultfd.c).  Instead of an anonymous memeory, a
hugetlbfs file is mmap'ed private.  In this way fallocate hole punch
can be used to release pages.  This is because madvise(MADV_DONTNEED)
is not supported for huge pages.

Use the same file, but create wrappers for allocating ranges and
releasing pages.  Compile userfaultfd.c with HUGETLB_TEST defined to
produce an executable to test userfaultfd hugetlb functionality.

Signed-off-by: Mike Kravetz <mike.kravetz@oracle.com>
---
 tools/testing/selftests/vm/Makefile      |   3 +
 tools/testing/selftests/vm/run_vmtests   |  13 +++
 tools/testing/selftests/vm/userfaultfd.c | 161 +++++++++++++++++++++++++++----
 3 files changed, 160 insertions(+), 17 deletions(-)

diff --git a/tools/testing/selftests/vm/Makefile b/tools/testing/selftests/vm/Makefile
index e4bb1de..aaa4225 100644
--- a/tools/testing/selftests/vm/Makefile
+++ b/tools/testing/selftests/vm/Makefile
@@ -10,12 +10,15 @@ BINARIES += on-fault-limit
 BINARIES += thuge-gen
 BINARIES += transhuge-stress
 BINARIES += userfaultfd
+BINARIES += userfaultfd_hugetlb
 
 all: $(BINARIES)
 %: %.c
 	$(CC) $(CFLAGS) -o $@ $^ -lrt
 userfaultfd: userfaultfd.c ../../../../usr/include/linux/kernel.h
 	$(CC) $(CFLAGS) -O2 -o $@ $< -lpthread
+userfaultfd_hugetlb: userfaultfd.c ../../../../usr/include/linux/kernel.h
+	$(CC) $(CFLAGS) -DHUGETLB_TEST -O2 -o $@ $< -lpthread
 
 ../../../../usr/include/linux/kernel.h:
 	make -C ../../../.. headers_install
diff --git a/tools/testing/selftests/vm/run_vmtests b/tools/testing/selftests/vm/run_vmtests
index e11968b..14d697e 100755
--- a/tools/testing/selftests/vm/run_vmtests
+++ b/tools/testing/selftests/vm/run_vmtests
@@ -103,6 +103,19 @@ else
 	echo "[PASS]"
 fi
 
+echo "----------------------------"
+echo "running userfaultfd_hugetlb"
+echo "----------------------------"
+# 258MB total huge pages == 128MB src and 128MB dst
+./userfaultfd_hugetlb 128 32 $mnt/ufd_test_file
+if [ $? -ne 0 ]; then
+	echo "[FAIL]"
+	exitcode=1
+else
+	echo "[PASS]"
+fi
+rm -f $mnt/ufd_test_file
+
 #cleanup
 umount $mnt
 rm -rf $mnt
diff --git a/tools/testing/selftests/vm/userfaultfd.c b/tools/testing/selftests/vm/userfaultfd.c
index d77ed41..3011711 100644
--- a/tools/testing/selftests/vm/userfaultfd.c
+++ b/tools/testing/selftests/vm/userfaultfd.c
@@ -76,6 +76,10 @@ static unsigned long nr_cpus, nr_pages, nr_pages_per_cpu, page_size;
 #define BOUNCE_POLL		(1<<3)
 static int bounces;
 
+#ifdef HUGETLB_TEST
+static int huge_fd;
+static char *huge_fd_off0;
+#endif
 static unsigned long long *count_verify;
 static int uffd, finished, *pipefd;
 static char *area_src, *area_dst;
@@ -97,6 +101,69 @@ pthread_attr_t attr;
 				 ~(unsigned long)(sizeof(unsigned long long) \
 						  -  1)))
 
+#ifndef HUGETLB_TEST
+
+#define EXPECTED_IOCTLS		((1 << _UFFDIO_WAKE) | \
+				 (1 << _UFFDIO_COPY) | \
+				 (1 << _UFFDIO_ZEROPAGE))
+
+static int release_pages(char *rel_area)
+{
+	int ret = 0;
+
+	if (madvise(rel_area, nr_pages * page_size, MADV_DONTNEED)) {
+		perror("madvise");
+		ret = 1;
+	}
+
+	return ret;
+}
+
+static void allocate_area(void **alloc_area)
+{
+	if (posix_memalign(alloc_area, page_size, nr_pages * page_size)) {
+		fprintf(stderr, "out of memory\n");
+		*alloc_area = NULL;
+	}
+}
+
+#else /* HUGETLB_TEST */
+
+#define EXPECTED_IOCTLS		UFFD_API_RANGE_IOCTLS_HPAGE
+
+static int release_pages(char *rel_area)
+{
+	int ret = 0;
+
+	if (fallocate(huge_fd, FALLOC_FL_PUNCH_HOLE | FALLOC_FL_KEEP_SIZE,
+				rel_area == huge_fd_off0 ? 0 :
+				nr_pages * page_size,
+				nr_pages * page_size)) {
+		perror("fallocate");
+		ret = 1;
+	}
+
+	return ret;
+}
+
+
+static void allocate_area(void **alloc_area)
+{
+	*alloc_area = mmap(NULL, nr_pages * page_size, PROT_READ | PROT_WRITE,
+				MAP_PRIVATE | MAP_HUGETLB, huge_fd,
+				*alloc_area == area_src ? 0 :
+				nr_pages * page_size);
+	if (*alloc_area == MAP_FAILED) {
+		fprintf(stderr, "mmap of hugetlbfs file failed\n");
+		*alloc_area = NULL;
+	}
+
+	if (*alloc_area == area_src)
+		huge_fd_off0 = *alloc_area;
+}
+
+#endif /* HUGETLB_TEST */
+
 static int my_bcmp(char *str1, char *str2, size_t n)
 {
 	unsigned long i;
@@ -384,10 +451,8 @@ static int stress(unsigned long *userfaults)
 	 * UFFDIO_COPY without writing zero pages into area_dst
 	 * because the background threads already completed).
 	 */
-	if (madvise(area_src, nr_pages * page_size, MADV_DONTNEED)) {
-		perror("madvise");
+	if (release_pages(area_src))
 		return 1;
-	}
 
 	for (cpu = 0; cpu < nr_cpus; cpu++) {
 		char c;
@@ -425,16 +490,12 @@ static int userfaultfd_stress(void)
 	int uffd_flags, err;
 	unsigned long userfaults[nr_cpus];
 
-	if (posix_memalign(&area, page_size, nr_pages * page_size)) {
-		fprintf(stderr, "out of memory\n");
+	allocate_area((void **)&area_src);
+	if (!area_src)
 		return 1;
-	}
-	area_src = area;
-	if (posix_memalign(&area, page_size, nr_pages * page_size)) {
-		fprintf(stderr, "out of memory\n");
+	allocate_area((void **)&area_dst);
+	if (!area_dst)
 		return 1;
-	}
-	area_dst = area;
 
 	uffd = syscall(__NR_userfaultfd, O_CLOEXEC | O_NONBLOCK);
 	if (uffd < 0) {
@@ -528,9 +589,7 @@ static int userfaultfd_stress(void)
 			fprintf(stderr, "register failure\n");
 			return 1;
 		}
-		expected_ioctls = (1 << _UFFDIO_WAKE) |
-				  (1 << _UFFDIO_COPY) |
-				  (1 << _UFFDIO_ZEROPAGE);
+		expected_ioctls = EXPECTED_IOCTLS;
 		if ((uffdio_register.ioctls & expected_ioctls) !=
 		    expected_ioctls) {
 			fprintf(stderr,
@@ -562,10 +621,8 @@ static int userfaultfd_stress(void)
 		 * MADV_DONTNEED only after the UFFDIO_REGISTER, so it's
 		 * required to MADV_DONTNEED here.
 		 */
-		if (madvise(area_dst, nr_pages * page_size, MADV_DONTNEED)) {
-			perror("madvise 2");
+		if (release_pages(area_dst))
 			return 1;
-		}
 
 		/* bounce pass */
 		if (stress(userfaults))
@@ -606,6 +663,8 @@ static int userfaultfd_stress(void)
 	return err;
 }
 
+#ifndef HUGETLB_TEST
+
 int main(int argc, char **argv)
 {
 	if (argc < 3)
@@ -632,6 +691,74 @@ int main(int argc, char **argv)
 	return userfaultfd_stress();
 }
 
+#else /* HUGETLB_TEST */
+
+/*
+ * Copied from mlock2-tests.c
+ */
+unsigned long default_huge_page_size(void)
+{
+	unsigned long hps = 0;
+	char *line = NULL;
+	size_t linelen = 0;
+	FILE *f = fopen("/proc/meminfo", "r");
+
+	if (!f)
+		return 0;
+	while (getline(&line, &linelen, f) > 0) {
+		if (sscanf(line, "Hugepagesize:       %lu kB", &hps) == 1) {
+			hps <<= 10;
+			break;
+		}
+	}
+
+	free(line);
+	fclose(f);
+	return hps;
+}
+
+int main(int argc, char **argv)
+{
+	if (argc < 4)
+		fprintf(stderr, "Usage: <MiB> <bounces> <hugetlbfs_file>\n"),
+				exit(1);
+	nr_cpus = sysconf(_SC_NPROCESSORS_ONLN);
+	page_size = default_huge_page_size();
+	if (!page_size)
+		fprintf(stderr, "Unable to determine huge page size\n"),
+				exit(2);
+	if ((unsigned long) area_count(NULL, 0) + sizeof(unsigned long long) * 2
+	    > page_size)
+		fprintf(stderr, "Impossible to run this test\n"), exit(2);
+	nr_pages_per_cpu = atol(argv[1]) * 1024*1024 / page_size /
+		nr_cpus;
+	if (!nr_pages_per_cpu) {
+		fprintf(stderr, "invalid MiB\n");
+		fprintf(stderr, "Usage: <MiB> <bounces>\n"), exit(1);
+	}
+	bounces = atoi(argv[2]);
+	if (bounces <= 0) {
+		fprintf(stderr, "invalid bounces\n");
+		fprintf(stderr, "Usage: <MiB> <bounces>\n"), exit(1);
+	}
+	nr_pages = nr_pages_per_cpu * nr_cpus;
+	huge_fd = open(argv[3], O_CREAT | O_RDWR, 0755);
+	if (huge_fd < 0) {
+		fprintf(stderr, "Open of %s failed", argv[3]);
+		perror("open");
+		exit(1);
+	}
+	if (ftruncate(huge_fd, 0)) {
+		fprintf(stderr, "ftruncate %s to size 0 failed", argv[3]);
+		perror("ftruncate");
+		exit(1);
+	}
+	printf("nr_pages: %lu, nr_pages_per_cpu: %lu\n",
+	       nr_pages, nr_pages_per_cpu);
+	return userfaultfd_stress();
+}
+
+#endif
 #else /* __NR_userfaultfd */
 
 #warning "missing __NR_userfaultfd definition"
-- 
2.4.11

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

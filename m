Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f198.google.com (mail-qk0-f198.google.com [209.85.220.198])
	by kanga.kvack.org (Postfix) with ESMTP id 977346B05ED
	for <linux-mm@kvack.org>; Wed,  2 Aug 2017 12:52:01 -0400 (EDT)
Received: by mail-qk0-f198.google.com with SMTP id q66so24628639qki.1
        for <linux-mm@kvack.org>; Wed, 02 Aug 2017 09:52:01 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id l2si11837963qki.123.2017.08.02.09.52.00
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 02 Aug 2017 09:52:00 -0700 (PDT)
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: [PATCH 2/6] userfaultfd: selftest: exercise UFFDIO_COPY/ZEROPAGE -EEXIST
Date: Wed,  2 Aug 2017 18:51:41 +0200
Message-Id: <20170802165145.22628-3-aarcange@redhat.com>
In-Reply-To: <20170802165145.22628-1-aarcange@redhat.com>
References: <20170802165145.22628-1-aarcange@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org
Cc: "Dr. David Alan Gilbert" <dgilbert@redhat.com>, Maxime Coquelin <maxime.coquelin@redhat.com>, Mike Rapoport <rppt@linux.vnet.ibm.com>, Mike Kravetz <mike.kravetz@oracle.com>, Alexey Perevalov <a.perevalov@samsung.com>

This will retry the UFFDIO_COPY/ZEROPAGE to verify it returns -EEXIST
at the first invocation and then later every 10 seconds.

In the filebacked MAP_SHARED case this also verifies the -EEXIST
triggered in the filesystem pagecache insertion, if the offset in the
file was not a hole.

shmem MAP_SHARED tries to index the newly allocated pagecache in the
radix tree before checking the pagetable so it doesn't need any
assistance to exercise that case.

hugetlbfs checks the pmd to be not none before trying to index the
hugetlbfs page in the radix tree, so it requires to run UFFDIO_COPY
into an alias mapping (the alternative would be to use MADV_DONTNEED
to only zap the pagetables, but that doesn't work on hugetlbfs).

Signed-off-by: Andrea Arcangeli <aarcange@redhat.com>
---
 tools/testing/selftests/vm/userfaultfd.c | 145 +++++++++++++++++++++++++++++--
 1 file changed, 138 insertions(+), 7 deletions(-)

diff --git a/tools/testing/selftests/vm/userfaultfd.c b/tools/testing/selftests/vm/userfaultfd.c
index 7db6299b2f0d..d07156de55e8 100644
--- a/tools/testing/selftests/vm/userfaultfd.c
+++ b/tools/testing/selftests/vm/userfaultfd.c
@@ -67,6 +67,7 @@
 #include <pthread.h>
 #include <linux/userfaultfd.h>
 #include <setjmp.h>
+#include <stdbool.h>
 
 #ifdef __NR_userfaultfd
 
@@ -83,11 +84,17 @@ static int bounces;
 #define TEST_SHMEM	3
 static int test_type;
 
+/* exercise the test_uffdio_*_eexist every ALARM_INTERVAL_SECS */
+#define ALARM_INTERVAL_SECS 10
+static volatile bool test_uffdio_copy_eexist = true;
+static volatile bool test_uffdio_zeropage_eexist = true;
+
+static bool map_shared;
 static int huge_fd;
 static char *huge_fd_off0;
 static unsigned long long *count_verify;
 static int uffd, uffd_flags, finished, *pipefd;
-static char *area_src, *area_dst;
+static char *area_src, *area_src_alias, *area_dst, *area_dst_alias;
 static char *zeropage;
 pthread_attr_t attr;
 
@@ -126,6 +133,9 @@ static void anon_allocate_area(void **alloc_area)
 	}
 }
 
+static void noop_alias_mapping(__u64 *start, size_t len, unsigned long offset)
+{
+}
 
 /* HugeTLB memory */
 static int hugetlb_release_pages(char *rel_area)
@@ -146,17 +156,51 @@ static int hugetlb_release_pages(char *rel_area)
 
 static void hugetlb_allocate_area(void **alloc_area)
 {
+	void *area_alias = NULL;
+	char **alloc_area_alias;
 	*alloc_area = mmap(NULL, nr_pages * page_size, PROT_READ | PROT_WRITE,
-				MAP_PRIVATE | MAP_HUGETLB, huge_fd,
-				*alloc_area == area_src ? 0 :
-				nr_pages * page_size);
+			   (map_shared ? MAP_SHARED : MAP_PRIVATE) |
+			   MAP_HUGETLB,
+			   huge_fd, *alloc_area == area_src ? 0 :
+			   nr_pages * page_size);
 	if (*alloc_area == MAP_FAILED) {
 		fprintf(stderr, "mmap of hugetlbfs file failed\n");
 		*alloc_area = NULL;
 	}
 
-	if (*alloc_area == area_src)
+	if (map_shared) {
+		area_alias = mmap(NULL, nr_pages * page_size, PROT_READ | PROT_WRITE,
+				  MAP_SHARED | MAP_HUGETLB,
+				  huge_fd, *alloc_area == area_src ? 0 :
+				  nr_pages * page_size);
+		if (area_alias == MAP_FAILED) {
+			if (munmap(*alloc_area, nr_pages * page_size) < 0)
+				perror("hugetlb munmap"), exit(1);
+			*alloc_area = NULL;
+			return;
+		}
+	}
+	if (*alloc_area == area_src) {
 		huge_fd_off0 = *alloc_area;
+		alloc_area_alias = &area_src_alias;
+	} else {
+		alloc_area_alias = &area_dst_alias;
+	}
+	if (area_alias)
+		*alloc_area_alias = area_alias;
+}
+
+static void hugetlb_alias_mapping(__u64 *start, size_t len, unsigned long offset)
+{
+	if (!map_shared)
+		return;
+	/*
+	 * We can't zap just the pagetable with hugetlbfs because
+	 * MADV_DONTEED won't work. So exercise -EEXIST on a alias
+	 * mapping where the pagetables are not established initially,
+	 * this way we'll exercise the -EEXEC at the fs level.
+	 */
+	*start = (unsigned long) area_dst_alias + offset;
 }
 
 /* Shared memory */
@@ -186,6 +230,7 @@ struct uffd_test_ops {
 	unsigned long expected_ioctls;
 	void (*allocate_area)(void **alloc_area);
 	int (*release_pages)(char *rel_area);
+	void (*alias_mapping)(__u64 *start, size_t len, unsigned long offset);
 };
 
 #define ANON_EXPECTED_IOCTLS		((1 << _UFFDIO_WAKE) | \
@@ -196,18 +241,21 @@ static struct uffd_test_ops anon_uffd_test_ops = {
 	.expected_ioctls = ANON_EXPECTED_IOCTLS,
 	.allocate_area	= anon_allocate_area,
 	.release_pages	= anon_release_pages,
+	.alias_mapping = noop_alias_mapping,
 };
 
 static struct uffd_test_ops shmem_uffd_test_ops = {
 	.expected_ioctls = ANON_EXPECTED_IOCTLS,
 	.allocate_area	= shmem_allocate_area,
 	.release_pages	= shmem_release_pages,
+	.alias_mapping = noop_alias_mapping,
 };
 
 static struct uffd_test_ops hugetlb_uffd_test_ops = {
 	.expected_ioctls = UFFD_API_RANGE_IOCTLS_BASIC,
 	.allocate_area	= hugetlb_allocate_area,
 	.release_pages	= hugetlb_release_pages,
+	.alias_mapping = hugetlb_alias_mapping,
 };
 
 static struct uffd_test_ops *uffd_test_ops;
@@ -332,6 +380,23 @@ static void *locking_thread(void *arg)
 	return NULL;
 }
 
+static void retry_copy_page(int ufd, struct uffdio_copy *uffdio_copy,
+			    unsigned long offset)
+{
+	uffd_test_ops->alias_mapping(&uffdio_copy->dst,
+				     uffdio_copy->len,
+				     offset);
+	if (ioctl(ufd, UFFDIO_COPY, uffdio_copy)) {
+		/* real retval in ufdio_copy.copy */
+		if (uffdio_copy->copy != -EEXIST)
+			fprintf(stderr, "UFFDIO_COPY retry error %Ld\n",
+				uffdio_copy->copy), exit(1);
+	} else {
+		fprintf(stderr,	"UFFDIO_COPY retry unexpected %Ld\n",
+			uffdio_copy->copy), exit(1);
+	}
+}
+
 static int copy_page(int ufd, unsigned long offset)
 {
 	struct uffdio_copy uffdio_copy;
@@ -352,8 +417,13 @@ static int copy_page(int ufd, unsigned long offset)
 	} else if (uffdio_copy.copy != page_size) {
 		fprintf(stderr, "UFFDIO_COPY unexpected copy %Ld\n",
 			uffdio_copy.copy), exit(1);
-	} else
+	} else {
+		if (test_uffdio_copy_eexist) {
+			test_uffdio_copy_eexist = false;
+			retry_copy_page(ufd, &uffdio_copy, offset);
+		}
 		return 1;
+	}
 	return 0;
 }
 
@@ -692,6 +762,23 @@ static int faulting_process(int signal_test)
 	return 0;
 }
 
+static void retry_uffdio_zeropage(int ufd,
+				  struct uffdio_zeropage *uffdio_zeropage,
+				  unsigned long offset)
+{
+	uffd_test_ops->alias_mapping(&uffdio_zeropage->range.start,
+				     uffdio_zeropage->range.len,
+				     offset);
+	if (ioctl(ufd, UFFDIO_ZEROPAGE, uffdio_zeropage)) {
+		if (uffdio_zeropage->zeropage != -EEXIST)
+			fprintf(stderr, "UFFDIO_ZEROPAGE retry error %Ld\n",
+				uffdio_zeropage->zeropage), exit(1);
+	} else {
+		fprintf(stderr, "UFFDIO_ZEROPAGE retry unexpected %Ld\n",
+			uffdio_zeropage->zeropage), exit(1);
+	}
+}
+
 static int uffdio_zeropage(int ufd, unsigned long offset)
 {
 	struct uffdio_zeropage uffdio_zeropage;
@@ -727,6 +814,11 @@ static int uffdio_zeropage(int ufd, unsigned long offset)
 			fprintf(stderr, "UFFDIO_ZEROPAGE unexpected %Ld\n",
 				uffdio_zeropage.zeropage), exit(1);
 		} else
+			if (test_uffdio_zeropage_eexist) {
+				test_uffdio_zeropage_eexist = false;
+				retry_uffdio_zeropage(ufd, &uffdio_zeropage,
+						      offset);
+			}
 			return 1;
 	} else {
 		fprintf(stderr,
@@ -999,6 +1091,15 @@ static int userfaultfd_stress(void)
 			return 1;
 		}
 
+		if (area_dst_alias) {
+			uffdio_register.range.start = (unsigned long)
+				area_dst_alias;
+			if (ioctl(uffd, UFFDIO_REGISTER, &uffdio_register)) {
+				fprintf(stderr, "register failure alias\n");
+				return 1;
+			}
+		}
+
 		/*
 		 * The madvise done previously isn't enough: some
 		 * uffd_thread could have read userfaults (one of
@@ -1032,9 +1133,17 @@ static int userfaultfd_stress(void)
 
 		/* unregister */
 		if (ioctl(uffd, UFFDIO_UNREGISTER, &uffdio_register.range)) {
-			fprintf(stderr, "register failure\n");
+			fprintf(stderr, "unregister failure\n");
 			return 1;
 		}
+		if (area_dst_alias) {
+			uffdio_register.range.start = (unsigned long) area_dst;
+			if (ioctl(uffd, UFFDIO_UNREGISTER,
+				  &uffdio_register.range)) {
+				fprintf(stderr, "unregister failure alias\n");
+				return 1;
+			}
+		}
 
 		/* verification */
 		if (bounces & BOUNCE_VERIFY) {
@@ -1056,6 +1165,10 @@ static int userfaultfd_stress(void)
 		area_src = area_dst;
 		area_dst = tmp_area;
 
+		tmp_area = area_src_alias;
+		area_src_alias = area_dst_alias;
+		area_dst_alias = tmp_area;
+
 		printf("userfaults:");
 		for (cpu = 0; cpu < nr_cpus; cpu++)
 			printf(" %lu", userfaults[cpu]);
@@ -1102,7 +1215,12 @@ static void set_test_type(const char *type)
 	} else if (!strcmp(type, "hugetlb")) {
 		test_type = TEST_HUGETLB;
 		uffd_test_ops = &hugetlb_uffd_test_ops;
+	} else if (!strcmp(type, "hugetlb_shared")) {
+		map_shared = true;
+		test_type = TEST_HUGETLB;
+		uffd_test_ops = &hugetlb_uffd_test_ops;
 	} else if (!strcmp(type, "shmem")) {
+		map_shared = true;
 		test_type = TEST_SHMEM;
 		uffd_test_ops = &shmem_uffd_test_ops;
 	} else {
@@ -1122,12 +1240,25 @@ static void set_test_type(const char *type)
 		fprintf(stderr, "Impossible to run this test\n"), exit(2);
 }
 
+static void sigalrm(int sig)
+{
+	if (sig != SIGALRM)
+		abort();
+	test_uffdio_copy_eexist = true;
+	test_uffdio_zeropage_eexist = true;
+	alarm(ALARM_INTERVAL_SECS);
+}
+
 int main(int argc, char **argv)
 {
 	if (argc < 4)
 		fprintf(stderr, "Usage: <test type> <MiB> <bounces> [hugetlbfs_file]\n"),
 				exit(1);
 
+	if (signal(SIGALRM, sigalrm) == SIG_ERR)
+		fprintf(stderr, "failed to arm SIGALRM"), exit(1);
+	alarm(ALARM_INTERVAL_SECS);
+
 	set_test_type(argv[1]);
 
 	nr_cpus = sysconf(_SC_NPROCESSORS_ONLN);

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt1-f200.google.com (mail-qt1-f200.google.com [209.85.160.200])
	by kanga.kvack.org (Postfix) with ESMTP id 9E8688E0001
	for <linux-mm@kvack.org>; Sun, 30 Sep 2018 03:43:13 -0400 (EDT)
Received: by mail-qt1-f200.google.com with SMTP id l22-v6so10591072qtr.3
        for <linux-mm@kvack.org>; Sun, 30 Sep 2018 00:43:13 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id d2-v6si2364505qvn.206.2018.09.30.00.43.12
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 30 Sep 2018 00:43:12 -0700 (PDT)
From: Peter Xu <peterx@redhat.com>
Subject: [PATCH v2 1/3] userfaultfd: selftest: cleanup help messages
Date: Sun, 30 Sep 2018 15:42:57 +0800
Message-Id: <20180930074259.18229-2-peterx@redhat.com>
In-Reply-To: <20180930074259.18229-1-peterx@redhat.com>
References: <20180930074259.18229-1-peterx@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: Shuah Khan <shuah@kernel.org>, Mike Kravetz <mike.kravetz@oracle.com>, Mike Rapoport <rppt@linux.vnet.ibm.com>, Jerome Glisse <jglisse@redhat.com>, peterx@redhat.com, linux-mm@kvack.org, Zi Yan <zi.yan@cs.rutgers.edu>, "Kirill A . Shutemov" <kirill@shutemov.name>, linux-kselftest@vger.kernel.org, Shaohua Li <shli@fb.com>, Andrea Arcangeli <aarcange@redhat.com>, "Dr . David Alan Gilbert" <dgilbert@redhat.com>, Andrew Morton <akpm@linux-foundation.org>

Firstly, the help in the comment region is obsolete, now we support
three parameters.  Since at it, change it and move it into the help
message of the program.

Also, the help messages dumped here and there is obsolete too.  Use a
single usage() helper.

Acked-by: Mike Rapoport <rppt@linux.vnet.ibm.com>
Signed-off-by: Peter Xu <peterx@redhat.com>
---
 tools/testing/selftests/vm/userfaultfd.c | 46 ++++++++++++++----------
 1 file changed, 28 insertions(+), 18 deletions(-)

diff --git a/tools/testing/selftests/vm/userfaultfd.c b/tools/testing/selftests/vm/userfaultfd.c
index 7b8171e3128a..5ff3a4f9173e 100644
--- a/tools/testing/selftests/vm/userfaultfd.c
+++ b/tools/testing/selftests/vm/userfaultfd.c
@@ -34,18 +34,6 @@
  * per-CPU threads 1 by triggering userfaults inside
  * pthread_mutex_lock will also verify the atomicity of the memory
  * transfer (UFFDIO_COPY).
- *
- * The program takes two parameters: the amounts of physical memory in
- * megabytes (MiB) of the area and the number of bounces to execute.
- *
- * # 100MiB 99999 bounces
- * ./userfaultfd 100 99999
- *
- * # 1GiB 99 bounces
- * ./userfaultfd 1000 99
- *
- * # 10MiB-~6GiB 999 bounces, continue forever unless an error triggers
- * while ./userfaultfd $[RANDOM % 6000 + 10] 999; do true; done
  */
 
 #define _GNU_SOURCE
@@ -115,6 +103,30 @@ pthread_attr_t attr;
 				 ~(unsigned long)(sizeof(unsigned long long) \
 						  -  1)))
 
+const char *examples =
+    "# Run anonymous memory test on 100MiB region with 99999 bounces:\n"
+    "./userfaultfd anon 100 99999\n\n"
+    "# Run share memory test on 1GiB region with 99 bounces:\n"
+    "./userfaultfd shmem 1000 99\n\n"
+    "# Run hugetlb memory test on 256MiB region with 50 bounces (using /dev/hugepages/hugefile):\n"
+    "./userfaultfd hugetlb 256 50 /dev/hugepages/hugefile\n\n"
+    "# Run the same hugetlb test but using shmem:\n"
+    "./userfaultfd hugetlb_shared 256 50 /dev/hugepages/hugefile\n\n"
+    "# 10MiB-~6GiB 999 bounces anonymous test, "
+    "continue forever unless an error triggers\n"
+    "while ./userfaultfd anon $[RANDOM % 6000 + 10] 999; do true; done\n\n";
+
+static void usage(void)
+{
+	fprintf(stderr, "\nUsage: ./userfaultfd <test type> <MiB> <bounces> "
+		"[hugetlbfs_file]\n\n");
+	fprintf(stderr, "Supported <test type>: anon, hugetlb, "
+		"hugetlb_shared, shmem\n\n");
+	fprintf(stderr, "Examples:\n\n");
+	fprintf(stderr, examples);
+	exit(1);
+}
+
 static int anon_release_pages(char *rel_area)
 {
 	int ret = 0;
@@ -1272,8 +1284,7 @@ static void sigalrm(int sig)
 int main(int argc, char **argv)
 {
 	if (argc < 4)
-		fprintf(stderr, "Usage: <test type> <MiB> <bounces> [hugetlbfs_file]\n"),
-				exit(1);
+		usage();
 
 	if (signal(SIGALRM, sigalrm) == SIG_ERR)
 		fprintf(stderr, "failed to arm SIGALRM"), exit(1);
@@ -1286,20 +1297,19 @@ int main(int argc, char **argv)
 		nr_cpus;
 	if (!nr_pages_per_cpu) {
 		fprintf(stderr, "invalid MiB\n");
-		fprintf(stderr, "Usage: <MiB> <bounces>\n"), exit(1);
+		usage();
 	}
 
 	bounces = atoi(argv[3]);
 	if (bounces <= 0) {
 		fprintf(stderr, "invalid bounces\n");
-		fprintf(stderr, "Usage: <MiB> <bounces>\n"), exit(1);
+		usage();
 	}
 	nr_pages = nr_pages_per_cpu * nr_cpus;
 
 	if (test_type == TEST_HUGETLB) {
 		if (argc < 5)
-			fprintf(stderr, "Usage: hugetlb <MiB> <bounces> <hugetlbfs_file>\n"),
-				exit(1);
+			usage();
 		huge_fd = open(argv[4], O_CREAT | O_RDWR, 0755);
 		if (huge_fd < 0) {
 			fprintf(stderr, "Open of %s failed", argv[3]);
-- 
2.17.1

Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f69.google.com (mail-it0-f69.google.com [209.85.214.69])
	by kanga.kvack.org (Postfix) with ESMTP id E2CAF6B0280
	for <linux-mm@kvack.org>; Fri, 16 Dec 2016 09:48:30 -0500 (EST)
Received: by mail-it0-f69.google.com with SMTP id b132so21281487iti.5
        for <linux-mm@kvack.org>; Fri, 16 Dec 2016 06:48:30 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id j187si2965440ith.7.2016.12.16.06.48.29
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 16 Dec 2016 06:48:30 -0800 (PST)
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: [PATCH 40/42] userfaultfd: non-cooperative: selftest: add test for FORK, MADVDONTNEED and REMAP events
Date: Fri, 16 Dec 2016 15:48:19 +0100
Message-Id: <20161216144821.5183-41-aarcange@redhat.com>
In-Reply-To: <20161216144821.5183-1-aarcange@redhat.com>
References: <20161216144821.5183-1-aarcange@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>
Cc: Michael Rapoport <RAPOPORT@il.ibm.com>, "Dr. David Alan Gilbert" <dgilbert@redhat.com>, Mike Kravetz <mike.kravetz@oracle.com>, Pavel Emelyanov <xemul@parallels.com>, Hillf Danton <hillf.zj@alibaba-inc.com>

From: Mike Rapoport <rppt@linux.vnet.ibm.com>

Add test for userfaultfd events used in non-cooperative scenario when the
process that monitors the userfaultfd and handles user faults is not the
same process that causes the page faults.

Signed-off-by: Mike Rapoport <rppt@linux.vnet.ibm.com>
Signed-off-by: Andrea Arcangeli <aarcange@redhat.com>
---
 tools/testing/selftests/vm/userfaultfd.c | 175 ++++++++++++++++++++++++++++---
 1 file changed, 163 insertions(+), 12 deletions(-)

diff --git a/tools/testing/selftests/vm/userfaultfd.c b/tools/testing/selftests/vm/userfaultfd.c
index c79c372..71b4d82 100644
--- a/tools/testing/selftests/vm/userfaultfd.c
+++ b/tools/testing/selftests/vm/userfaultfd.c
@@ -63,6 +63,7 @@
 #include <sys/mman.h>
 #include <sys/syscall.h>
 #include <sys/ioctl.h>
+#include <sys/wait.h>
 #include <pthread.h>
 #include <linux/userfaultfd.h>
 
@@ -347,6 +348,7 @@ static void *uffd_poll_thread(void *arg)
 	unsigned long cpu = (unsigned long) arg;
 	struct pollfd pollfd[2];
 	struct uffd_msg msg;
+	struct uffdio_register uffd_reg;
 	int ret;
 	unsigned long offset;
 	char tmp_chr;
@@ -378,16 +380,35 @@ static void *uffd_poll_thread(void *arg)
 				continue;
 			perror("nonblocking read error"), exit(1);
 		}
-		if (msg.event != UFFD_EVENT_PAGEFAULT)
+		switch (msg.event) {
+		default:
 			fprintf(stderr, "unexpected msg event %u\n",
 				msg.event), exit(1);
-		if (msg.arg.pagefault.flags & UFFD_PAGEFAULT_FLAG_WRITE)
-			fprintf(stderr, "unexpected write fault\n"), exit(1);
-		offset = (char *)(unsigned long)msg.arg.pagefault.address -
-			 area_dst;
-		offset &= ~(page_size-1);
-		if (copy_page(uffd, offset))
-			userfaults++;
+			break;
+		case UFFD_EVENT_PAGEFAULT:
+			if (msg.arg.pagefault.flags & UFFD_PAGEFAULT_FLAG_WRITE)
+				fprintf(stderr, "unexpected write fault\n"), exit(1);
+			offset = (char *)(unsigned long)msg.arg.pagefault.address -
+				area_dst;
+			offset &= ~(page_size-1);
+			if (copy_page(uffd, offset))
+				userfaults++;
+			break;
+		case UFFD_EVENT_FORK:
+			uffd = msg.arg.fork.ufd;
+			pollfd[0].fd = uffd;
+			break;
+		case UFFD_EVENT_MADVDONTNEED:
+			uffd_reg.range.start = msg.arg.madv_dn.start;
+			uffd_reg.range.len = msg.arg.madv_dn.end -
+				msg.arg.madv_dn.start;
+			if (ioctl(uffd, UFFDIO_UNREGISTER, &uffd_reg.range))
+				fprintf(stderr, "madv_dn failure\n"), exit(1);
+			break;
+		case UFFD_EVENT_REMAP:
+			area_dst = (char *)(unsigned long)msg.arg.remap.to;
+			break;
+		}
 	}
 	return (void *)userfaults;
 }
@@ -512,7 +533,7 @@ static int stress(unsigned long *userfaults)
 	return 0;
 }
 
-static int userfaultfd_open(void)
+static int userfaultfd_open(int features)
 {
 	struct uffdio_api uffdio_api;
 
@@ -525,7 +546,7 @@ static int userfaultfd_open(void)
 	uffd_flags = fcntl(uffd, F_GETFD, NULL);
 
 	uffdio_api.api = UFFD_API;
-	uffdio_api.features = 0;
+	uffdio_api.features = features;
 	if (ioctl(uffd, UFFDIO_API, &uffdio_api)) {
 		fprintf(stderr, "UFFDIO_API\n");
 		return 1;
@@ -538,6 +559,132 @@ static int userfaultfd_open(void)
 	return 0;
 }
 
+/*
+ * For non-cooperative userfaultfd test we fork() a process that will
+ * generate pagefaults, will mremap the area monitored by the
+ * userfaultfd and at last this process will release the monitored
+ * area.
+ * For the anonymous and shared memory the area is divided into two
+ * parts, the first part is accessed before mremap, and the second
+ * part is accessed after mremap. Since hugetlbfs does not support
+ * mremap, the entire monitored area is accessed in a single pass for
+ * HUGETLB_TEST.
+ * The release of the pages currently generates event only for
+ * anonymous memory (UFFD_EVENT_MADVDONTNEED), hence it is not checked
+ * for hugetlb and shmem.
+ */
+static int faulting_process(void)
+{
+	unsigned long nr;
+	unsigned long long count;
+
+#ifndef HUGETLB_TEST
+	unsigned long split_nr_pages = (nr_pages + 1) / 2;
+#else
+	unsigned long split_nr_pages = nr_pages;
+#endif
+
+	for (nr = 0; nr < split_nr_pages; nr++) {
+		count = *area_count(area_dst, nr);
+		if (count != count_verify[nr]) {
+			fprintf(stderr,
+				"nr %lu memory corruption %Lu %Lu\n",
+				nr, count,
+				count_verify[nr]), exit(1);
+		}
+	}
+
+#ifndef HUGETLB_TEST
+	area_dst = mremap(area_dst, nr_pages * page_size,  nr_pages * page_size,
+			  MREMAP_MAYMOVE | MREMAP_FIXED, area_src);
+	if (area_dst == MAP_FAILED)
+		perror("mremap"), exit(1);
+
+	for (; nr < nr_pages; nr++) {
+		count = *area_count(area_dst, nr);
+		if (count != count_verify[nr]) {
+			fprintf(stderr,
+				"nr %lu memory corruption %Lu %Lu\n",
+				nr, count,
+				count_verify[nr]), exit(1);
+		}
+	}
+
+#ifndef SHMEM_TEST
+	if (release_pages(area_dst))
+		return 1;
+
+	for (nr = 0; nr < nr_pages; nr++) {
+		if (my_bcmp(area_dst + nr * page_size, zeropage, page_size))
+			fprintf(stderr, "nr %lu is not zero\n", nr), exit(1);
+	}
+#endif /* SHMEM_TEST */
+
+#endif /* HUGETLB_TEST */
+
+	return 0;
+}
+
+static int userfaultfd_events_test(void)
+{
+	struct uffdio_register uffdio_register;
+	unsigned long expected_ioctls;
+	unsigned long userfaults;
+	pthread_t uffd_mon;
+	int err, features;
+	pid_t pid;
+	char c;
+
+	printf("testing events (fork, remap, madv_dn): ");
+	fflush(stdout);
+
+	if (release_pages(area_dst))
+		return 1;
+
+	features = UFFD_FEATURE_EVENT_FORK | UFFD_FEATURE_EVENT_REMAP |
+		UFFD_FEATURE_EVENT_MADVDONTNEED;
+	if (userfaultfd_open(features) < 0)
+		return 1;
+	fcntl(uffd, F_SETFL, uffd_flags | O_NONBLOCK);
+
+	uffdio_register.range.start = (unsigned long) area_dst;
+	uffdio_register.range.len = nr_pages * page_size;
+	uffdio_register.mode = UFFDIO_REGISTER_MODE_MISSING;
+	if (ioctl(uffd, UFFDIO_REGISTER, &uffdio_register))
+		fprintf(stderr, "register failure\n"), exit(1);
+
+	expected_ioctls = EXPECTED_IOCTLS;
+	if ((uffdio_register.ioctls & expected_ioctls) !=
+	    expected_ioctls)
+		fprintf(stderr,
+			"unexpected missing ioctl for anon memory\n"),
+			exit(1);
+
+	if (pthread_create(&uffd_mon, &attr, uffd_poll_thread, NULL))
+		perror("uffd_poll_thread create"), exit(1);
+
+	pid = fork();
+	if (pid < 0)
+		perror("fork"), exit(1);
+
+	if (!pid)
+		return faulting_process();
+
+	waitpid(pid, &err, 0);
+	if (err)
+		fprintf(stderr, "faulting process failed\n"), exit(1);
+
+	if (write(pipefd[1], &c, sizeof(c)) != sizeof(c))
+		perror("pipe write"), exit(1);
+	if (pthread_join(uffd_mon, (void **)&userfaults))
+		return 1;
+
+	close(uffd);
+	printf("userfaults: %ld\n", userfaults);
+
+	return userfaults != nr_pages;
+}
+
 static int userfaultfd_stress(void)
 {
 	void *area;
@@ -555,7 +702,7 @@ static int userfaultfd_stress(void)
 	if (!area_dst)
 		return 1;
 
-	if (userfaultfd_open() < 0)
+	if (userfaultfd_open(0) < 0)
 		return 1;
 
 	count_verify = malloc(nr_pages * sizeof(unsigned long long));
@@ -702,7 +849,11 @@ static int userfaultfd_stress(void)
 		printf("\n");
 	}
 
-	return err;
+	if (err)
+		return err;
+
+	close(uffd);
+	return userfaultfd_events_test();
 }
 
 #ifndef HUGETLB_TEST

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

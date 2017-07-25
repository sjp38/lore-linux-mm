Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f197.google.com (mail-qk0-f197.google.com [209.85.220.197])
	by kanga.kvack.org (Postfix) with ESMTP id 8B42E6B02B4
	for <linux-mm@kvack.org>; Mon, 24 Jul 2017 22:30:43 -0400 (EDT)
Received: by mail-qk0-f197.google.com with SMTP id o65so55209237qkl.12
        for <linux-mm@kvack.org>; Mon, 24 Jul 2017 19:30:43 -0700 (PDT)
Received: from userp1040.oracle.com (userp1040.oracle.com. [156.151.31.81])
        by mx.google.com with ESMTPS id g27si10218804qtf.423.2017.07.24.19.30.42
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 24 Jul 2017 19:30:42 -0700 (PDT)
From: prakash.sangappa@oracle.com
Subject: [PATCH 2/2] userfaultfd: selftest: Add tests for UFFD_FREATURE_SIGBUS
Date: Mon, 24 Jul 2017 22:30:22 -0400
Message-Id: <1500949822-949266-3-git-send-email-prakash.sangappa@oracle.com>
In-Reply-To: <1500949822-949266-1-git-send-email-prakash.sangappa@oracle.com>
References: <1500949822-949266-1-git-send-email-prakash.sangappa@oracle.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: inux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-api@vger.kernel.org
Cc: aarcange@redhat.com, rppt@linux.vnet.ibm.com, akpm@linux-foundation.org, xemul@parallels.com, mike.kravetz@oracle.com

From: Prakash Sangappa <prakash.sangappa@oracle.com>

Signed-off-by: Prakash Sangappa <prakash.sangappa@oracle.com>
---
 tools/testing/selftests/vm/userfaultfd.c |  121 +++++++++++++++++++++++++++++-
 1 files changed, 118 insertions(+), 3 deletions(-)

diff --git a/tools/testing/selftests/vm/userfaultfd.c b/tools/testing/selftests/vm/userfaultfd.c
index 1eae79a..6a43e84 100644
--- a/tools/testing/selftests/vm/userfaultfd.c
+++ b/tools/testing/selftests/vm/userfaultfd.c
@@ -66,6 +66,7 @@
 #include <sys/wait.h>
 #include <pthread.h>
 #include <linux/userfaultfd.h>
+#include <setjmp.h>
 
 #ifdef __NR_userfaultfd
 
@@ -408,6 +409,7 @@ static int copy_page(int ufd, unsigned long offset)
 				userfaults++;
 			break;
 		case UFFD_EVENT_FORK:
+			close(uffd);
 			uffd = msg.arg.fork.ufd;
 			pollfd[0].fd = uffd;
 			break;
@@ -572,6 +574,17 @@ static int userfaultfd_open(int features)
 	return 0;
 }
 
+sigjmp_buf jbuf, *sigbuf;
+
+static void sighndl(int sig, siginfo_t *siginfo, void *ptr)
+{
+        if (sig == SIGBUS) {
+                if (sigbuf)
+                         siglongjmp(*sigbuf, 1);
+                abort();
+        }
+}
+
 /*
  * For non-cooperative userfaultfd test we fork() a process that will
  * generate pagefaults, will mremap the area monitored by the
@@ -585,19 +598,54 @@ static int userfaultfd_open(int features)
  * The release of the pages currently generates event for shmem and
  * anonymous memory (UFFD_EVENT_REMOVE), hence it is not checked
  * for hugetlb.
+ * For signal test(UFFD_FEATURE_SIGBUS), primarily test signal
+ * delivery and ensure no userfault events are generated.
  */
-static int faulting_process(void)
+static int faulting_process(int signal_test)
 {
 	unsigned long nr;
 	unsigned long long count;
 	unsigned long split_nr_pages;
+	unsigned long lastnr;
+	struct sigaction act;
+	unsigned long signalled=0, sig_repeats = 0;
 
 	if (test_type != TEST_HUGETLB)
 		split_nr_pages = (nr_pages + 1) / 2;
 	else
 		split_nr_pages = nr_pages;
 
+	if (signal_test) {
+		sigbuf = &jbuf;
+		memset (&act, 0, sizeof(act));
+		act.sa_sigaction = sighndl;
+		act.sa_flags = SA_SIGINFO;
+		if (sigaction(SIGBUS, &act, 0)) {
+			perror("sigaction");
+			return 1;
+		}
+		lastnr = (unsigned long)-1;
+	}
+
 	for (nr = 0; nr < split_nr_pages; nr++) {
+		if (signal_test) {
+			if (sigsetjmp(*sigbuf, 1) != 0) {
+				if (nr == lastnr) {
+					sig_repeats++;
+					continue;
+				}
+
+				lastnr = nr;
+				if (signal_test == 1) {
+					if (copy_page(uffd, nr * page_size))
+						signalled++;
+				} else {
+					signalled++;
+					continue;
+				}
+			}
+		}
+
 		count = *area_count(area_dst, nr);
 		if (count != count_verify[nr]) {
 			fprintf(stderr,
@@ -607,6 +655,8 @@ static int faulting_process(void)
 		}
 	}
 
+	if (signal_test)
+		return signalled != split_nr_pages || sig_repeats != 0;
 	if (test_type == TEST_HUGETLB)
 		return 0;
 
@@ -761,7 +811,7 @@ static int userfaultfd_events_test(void)
 		perror("fork"), exit(1);
 
 	if (!pid)
-		return faulting_process();
+		return faulting_process(0);
 
 	waitpid(pid, &err, 0);
 	if (err)
@@ -778,6 +828,70 @@ static int userfaultfd_events_test(void)
 	return userfaults != nr_pages;
 }
 
+static int userfaultfd_sig_test(void)
+{
+	struct uffdio_register uffdio_register;
+	unsigned long expected_ioctls;
+	unsigned long userfaults;
+	pthread_t uffd_mon;
+	int err, features;
+	pid_t pid;
+	char c;
+
+	printf("testing signal delivery: ");
+	fflush(stdout);
+
+	if (uffd_test_ops->release_pages(area_dst))
+		return 1;
+
+	features = UFFD_FEATURE_EVENT_FORK|UFFD_FEATURE_SIGBUS;
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
+	expected_ioctls = uffd_test_ops->expected_ioctls;
+	if ((uffdio_register.ioctls & expected_ioctls) !=
+	    expected_ioctls)
+		fprintf(stderr,
+			"unexpected missing ioctl for anon memory\n"),
+			exit(1);
+
+	if (faulting_process(1))
+		fprintf(stderr, "faulting process failed\n"), exit(1);
+
+	if (uffd_test_ops->release_pages(area_dst))
+		return 1;
+
+	if (pthread_create(&uffd_mon, &attr, uffd_poll_thread, NULL))
+		perror("uffd_poll_thread create"), exit(1);
+
+	pid = fork();
+	if (pid < 0)
+		perror("fork"), exit(1);
+
+	if (!pid)
+		exit(faulting_process(2));
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
+	printf("done\n");
+	printf(" Signal test userfaults: %ld\n", userfaults);
+	close(uffd);
+	return userfaults != 0;
+}
 static int userfaultfd_stress(void)
 {
 	void *area;
@@ -946,7 +1060,8 @@ static int userfaultfd_stress(void)
 		return err;
 
 	close(uffd);
-	return userfaultfd_zeropage_test() || userfaultfd_events_test();
+	return userfaultfd_zeropage_test() || userfaultfd_sig_test()
+		|| userfaultfd_events_test();
 }
 
 /*
-- 
1.7.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

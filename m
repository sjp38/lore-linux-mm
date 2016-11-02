Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f200.google.com (mail-qk0-f200.google.com [209.85.220.200])
	by kanga.kvack.org (Postfix) with ESMTP id 4689A6B02DA
	for <linux-mm@kvack.org>; Wed,  2 Nov 2016 15:40:46 -0400 (EDT)
Received: by mail-qk0-f200.google.com with SMTP id g193so23321958qke.2
        for <linux-mm@kvack.org>; Wed, 02 Nov 2016 12:40:46 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id m26si1917199qki.199.2016.11.02.12.34.12
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 02 Nov 2016 12:34:12 -0700 (PDT)
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: [PATCH 30/33] userfaultfd: non-cooperative: selftest: introduce userfaultfd_open
Date: Wed,  2 Nov 2016 20:34:02 +0100
Message-Id: <1478115245-32090-31-git-send-email-aarcange@redhat.com>
In-Reply-To: <1478115245-32090-1-git-send-email-aarcange@redhat.com>
References: <1478115245-32090-1-git-send-email-aarcange@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, Michael Rapoport <RAPOPORT@il.ibm.com>, "Dr. David Alan Gilbert"@v2.random, " <dgilbert@redhat.com>,  Mike Kravetz <mike.kravetz@oracle.com>,  Shaohua Li <shli@fb.com>,  Pavel Emelyanov <xemul@parallels.com>"@v2.random

From: Mike Rapoport <rppt@linux.vnet.ibm.com>

userfaultfd_open will be needed by the non cooperative selftest.

Signed-off-by: Mike Rapoport <rppt@linux.vnet.ibm.com>
Signed-off-by: Andrea Arcangeli <aarcange@redhat.com>
---
 tools/testing/selftests/vm/userfaultfd.c | 41 +++++++++++++++++++-------------
 1 file changed, 25 insertions(+), 16 deletions(-)

diff --git a/tools/testing/selftests/vm/userfaultfd.c b/tools/testing/selftests/vm/userfaultfd.c
index a5e5808..75540e7 100644
--- a/tools/testing/selftests/vm/userfaultfd.c
+++ b/tools/testing/selftests/vm/userfaultfd.c
@@ -81,7 +81,7 @@ static int huge_fd;
 static char *huge_fd_off0;
 #endif
 static unsigned long long *count_verify;
-static int uffd, finished, *pipefd;
+static int uffd, uffd_flags, finished, *pipefd;
 static char *area_src, *area_dst;
 static char *zeropage;
 pthread_attr_t attr;
@@ -512,23 +512,9 @@ static int stress(unsigned long *userfaults)
 	return 0;
 }
 
-static int userfaultfd_stress(void)
+static int userfaultfd_open(void)
 {
-	void *area;
-	char *tmp_area;
-	unsigned long nr;
-	struct uffdio_register uffdio_register;
 	struct uffdio_api uffdio_api;
-	unsigned long cpu;
-	int uffd_flags, err;
-	unsigned long userfaults[nr_cpus];
-
-	allocate_area((void **)&area_src);
-	if (!area_src)
-		return 1;
-	allocate_area((void **)&area_dst);
-	if (!area_dst)
-		return 1;
 
 	uffd = syscall(__NR_userfaultfd, O_CLOEXEC | O_NONBLOCK);
 	if (uffd < 0) {
@@ -549,6 +535,29 @@ static int userfaultfd_stress(void)
 		return 1;
 	}
 
+	return 0;
+}
+
+static int userfaultfd_stress(void)
+{
+	void *area;
+	char *tmp_area;
+	unsigned long nr;
+	struct uffdio_register uffdio_register;
+	unsigned long cpu;
+	int err;
+	unsigned long userfaults[nr_cpus];
+
+	allocate_area((void **)&area_src);
+	if (!area_src)
+		return 1;
+	allocate_area((void **)&area_dst);
+	if (!area_dst)
+		return 1;
+
+	if (userfaultfd_open() < 0)
+		return 1;
+
 	count_verify = malloc(nr_pages * sizeof(unsigned long long));
 	if (!count_verify) {
 		perror("count_verify");

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

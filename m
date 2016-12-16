Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f200.google.com (mail-io0-f200.google.com [209.85.223.200])
	by kanga.kvack.org (Postfix) with ESMTP id 742CB6B027F
	for <linux-mm@kvack.org>; Fri, 16 Dec 2016 09:48:30 -0500 (EST)
Received: by mail-io0-f200.google.com with SMTP id b194so92403102ioa.6
        for <linux-mm@kvack.org>; Fri, 16 Dec 2016 06:48:30 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id 131si2952255itp.50.2016.12.16.06.48.29
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 16 Dec 2016 06:48:29 -0800 (PST)
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: [PATCH 38/42] userfaultfd: non-cooperative: selftest: introduce userfaultfd_open
Date: Fri, 16 Dec 2016 15:48:17 +0100
Message-Id: <20161216144821.5183-39-aarcange@redhat.com>
In-Reply-To: <20161216144821.5183-1-aarcange@redhat.com>
References: <20161216144821.5183-1-aarcange@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>
Cc: Michael Rapoport <RAPOPORT@il.ibm.com>, "Dr. David Alan Gilbert" <dgilbert@redhat.com>, Mike Kravetz <mike.kravetz@oracle.com>, Pavel Emelyanov <xemul@parallels.com>, Hillf Danton <hillf.zj@alibaba-inc.com>

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

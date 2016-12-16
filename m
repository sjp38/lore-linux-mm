Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f70.google.com (mail-it0-f70.google.com [209.85.214.70])
	by kanga.kvack.org (Postfix) with ESMTP id 4CBEC6B026F
	for <linux-mm@kvack.org>; Fri, 16 Dec 2016 09:48:30 -0500 (EST)
Received: by mail-it0-f70.google.com with SMTP id b132so21281272iti.5
        for <linux-mm@kvack.org>; Fri, 16 Dec 2016 06:48:30 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id w17si2960116itb.20.2016.12.16.06.48.29
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 16 Dec 2016 06:48:29 -0800 (PST)
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: [PATCH 39/42] userfaultfd: non-cooperative: selftest: add ufd parameter to copy_page
Date: Fri, 16 Dec 2016 15:48:18 +0100
Message-Id: <20161216144821.5183-40-aarcange@redhat.com>
In-Reply-To: <20161216144821.5183-1-aarcange@redhat.com>
References: <20161216144821.5183-1-aarcange@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>
Cc: Michael Rapoport <RAPOPORT@il.ibm.com>, "Dr. David Alan Gilbert" <dgilbert@redhat.com>, Mike Kravetz <mike.kravetz@oracle.com>, Pavel Emelyanov <xemul@parallels.com>, Hillf Danton <hillf.zj@alibaba-inc.com>

From: Mike Rapoport <rppt@linux.vnet.ibm.com>

With future addition of event tests, copy_page will be called with
different userfault file descriptors

Signed-off-by: Mike Rapoport <rppt@linux.vnet.ibm.com>
Signed-off-by: Andrea Arcangeli <aarcange@redhat.com>
---
 tools/testing/selftests/vm/userfaultfd.c | 10 +++++-----
 1 file changed, 5 insertions(+), 5 deletions(-)

diff --git a/tools/testing/selftests/vm/userfaultfd.c b/tools/testing/selftests/vm/userfaultfd.c
index 75540e7..c79c372 100644
--- a/tools/testing/selftests/vm/userfaultfd.c
+++ b/tools/testing/selftests/vm/userfaultfd.c
@@ -317,7 +317,7 @@ static void *locking_thread(void *arg)
 	return NULL;
 }
 
-static int copy_page(unsigned long offset)
+static int copy_page(int ufd, unsigned long offset)
 {
 	struct uffdio_copy uffdio_copy;
 
@@ -329,7 +329,7 @@ static int copy_page(unsigned long offset)
 	uffdio_copy.len = page_size;
 	uffdio_copy.mode = 0;
 	uffdio_copy.copy = 0;
-	if (ioctl(uffd, UFFDIO_COPY, &uffdio_copy)) {
+	if (ioctl(ufd, UFFDIO_COPY, &uffdio_copy)) {
 		/* real retval in ufdio_copy.copy */
 		if (uffdio_copy.copy != -EEXIST)
 			fprintf(stderr, "UFFDIO_COPY error %Ld\n",
@@ -386,7 +386,7 @@ static void *uffd_poll_thread(void *arg)
 		offset = (char *)(unsigned long)msg.arg.pagefault.address -
 			 area_dst;
 		offset &= ~(page_size-1);
-		if (copy_page(offset))
+		if (copy_page(uffd, offset))
 			userfaults++;
 	}
 	return (void *)userfaults;
@@ -424,7 +424,7 @@ static void *uffd_read_thread(void *arg)
 		offset = (char *)(unsigned long)msg.arg.pagefault.address -
 			 area_dst;
 		offset &= ~(page_size-1);
-		if (copy_page(offset))
+		if (copy_page(uffd, offset))
 			(*this_cpu_userfaults)++;
 	}
 	return (void *)NULL;
@@ -438,7 +438,7 @@ static void *background_thread(void *arg)
 	for (page_nr = cpu * nr_pages_per_cpu;
 	     page_nr < (cpu+1) * nr_pages_per_cpu;
 	     page_nr++)
-		copy_page(page_nr * page_size);
+		copy_page(uffd, page_nr * page_size);
 
 	return NULL;
 }

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

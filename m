Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f198.google.com (mail-qk0-f198.google.com [209.85.220.198])
	by kanga.kvack.org (Postfix) with ESMTP id 88AFB6B02B5
	for <linux-mm@kvack.org>; Wed,  2 Nov 2016 15:34:12 -0400 (EDT)
Received: by mail-qk0-f198.google.com with SMTP id g193so23147090qke.2
        for <linux-mm@kvack.org>; Wed, 02 Nov 2016 12:34:12 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id j44si1903484qtf.139.2016.11.02.12.34.11
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 02 Nov 2016 12:34:12 -0700 (PDT)
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: [PATCH 31/33] userfaultfd: non-cooperative: selftest: add ufd parameter to copy_page
Date: Wed,  2 Nov 2016 20:34:03 +0100
Message-Id: <1478115245-32090-32-git-send-email-aarcange@redhat.com>
In-Reply-To: <1478115245-32090-1-git-send-email-aarcange@redhat.com>
References: <1478115245-32090-1-git-send-email-aarcange@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, Michael Rapoport <RAPOPORT@il.ibm.com>, "Dr. David Alan Gilbert"@v2.random, " <dgilbert@redhat.com>,  Mike Kravetz <mike.kravetz@oracle.com>,  Shaohua Li <shli@fb.com>,  Pavel Emelyanov <xemul@parallels.com>"@v2.random

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

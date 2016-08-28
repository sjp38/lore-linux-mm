Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f198.google.com (mail-qt0-f198.google.com [209.85.216.198])
	by kanga.kvack.org (Postfix) with ESMTP id 1B896830D6
	for <linux-mm@kvack.org>; Sun, 28 Aug 2016 10:38:02 -0400 (EDT)
Received: by mail-qt0-f198.google.com with SMTP id n6so248154633qtn.2
        for <linux-mm@kvack.org>; Sun, 28 Aug 2016 07:38:02 -0700 (PDT)
Received: from mx0a-001b2d01.pphosted.com (mx0b-001b2d01.pphosted.com. [148.163.158.5])
        by mx.google.com with ESMTPS id g19si20692126qta.42.2016.08.28.07.38.01
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 28 Aug 2016 07:38:01 -0700 (PDT)
Received: from pps.filterd (m0098413.ppops.net [127.0.0.1])
	by mx0b-001b2d01.pphosted.com (8.16.0.11/8.16.0.11) with SMTP id u7SEXcZf031152
	for <linux-mm@kvack.org>; Sun, 28 Aug 2016 10:38:01 -0400
Received: from e06smtp10.uk.ibm.com (e06smtp10.uk.ibm.com [195.75.94.106])
	by mx0b-001b2d01.pphosted.com with ESMTP id 253r8secmx-1
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Sun, 28 Aug 2016 10:38:01 -0400
Received: from localhost
	by e06smtp10.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <rppt@linux.vnet.ibm.com>;
	Sun, 28 Aug 2016 15:37:59 +0100
Received: from b06cxnps4075.portsmouth.uk.ibm.com (d06relay12.portsmouth.uk.ibm.com [9.149.109.197])
	by d06dlp01.portsmouth.uk.ibm.com (Postfix) with ESMTP id 22C9917D8042
	for <linux-mm@kvack.org>; Sun, 28 Aug 2016 15:39:44 +0100 (BST)
Received: from d06av11.portsmouth.uk.ibm.com (d06av11.portsmouth.uk.ibm.com [9.149.37.252])
	by b06cxnps4075.portsmouth.uk.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id u7SEbuBO4653532
	for <linux-mm@kvack.org>; Sun, 28 Aug 2016 14:37:56 GMT
Received: from d06av11.portsmouth.uk.ibm.com (localhost [127.0.0.1])
	by d06av11.portsmouth.uk.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id u7SEbtpv011308
	for <linux-mm@kvack.org>; Sun, 28 Aug 2016 08:37:56 -0600
From: Mike Rapoport <rppt@linux.vnet.ibm.com>
Subject: [PATCH 2/3] userfaultfd: selftest: add ufd parameter to copy_page
Date: Sun, 28 Aug 2016 17:37:46 +0300
In-Reply-To: <1472395067-24538-1-git-send-email-rppt@linux.vnet.ibm.com>
References: <1472395067-24538-1-git-send-email-rppt@linux.vnet.ibm.com>
Message-Id: <1472395067-24538-3-git-send-email-rppt@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrea Arcangeli <aarcange@redhat.com>
Cc: Pavel Emelyanov <xemul@virtuozzo.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Mike Rapoport <rppt@linux.vnet.ibm.com>

With future addition of event tests, copy_page will be called with
different userfault file descriptors

Signed-off-by: Mike Rapoport <rppt@linux.vnet.ibm.com>
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
1.9.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

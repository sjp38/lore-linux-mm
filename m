Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-vk0-f71.google.com (mail-vk0-f71.google.com [209.85.213.71])
	by kanga.kvack.org (Postfix) with ESMTP id 58CF46B0253
	for <linux-mm@kvack.org>; Wed,  4 Oct 2017 13:15:46 -0400 (EDT)
Received: by mail-vk0-f71.google.com with SMTP id q75so6185488vkf.4
        for <linux-mm@kvack.org>; Wed, 04 Oct 2017 10:15:46 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id n1si4140347qte.108.2017.10.04.10.15.45
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 04 Oct 2017 10:15:45 -0700 (PDT)
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: [PATCH 1/1] userfaultfd: selftest: exercise -EEXIST only in background transfer
Date: Wed,  4 Oct 2017 19:15:41 +0200
Message-Id: <20171004171541.1495-2-aarcange@redhat.com>
In-Reply-To: <20171004171541.1495-1-aarcange@redhat.com>
References: <20171004171541.1495-1-aarcange@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org
Cc: Pavel Emelyanov <xemul@virtuozzo.com>, Mike Rapoport <rppt@linux.vnet.ibm.com>, "Dr. David Alan Gilbert" <dgilbert@redhat.com>, Mike Kravetz <mike.kravetz@oracle.com>

The fork child will quit after the last UFFDIO_COPY is run, so a
repeated UFFDIO_COPY may not return -EEXIST. This change restricts the
-EEXIST stress to the background transfer where the memory can't go
away from under it.

Also updated uffdio_zeropage, so the interface is consistent.

Signed-off-by: Andrea Arcangeli <aarcange@redhat.com>
---
 tools/testing/selftests/vm/userfaultfd.c | 25 ++++++++++++++++++++-----
 1 file changed, 20 insertions(+), 5 deletions(-)

diff --git a/tools/testing/selftests/vm/userfaultfd.c b/tools/testing/selftests/vm/userfaultfd.c
index a2c53a3d223d..de2f9ec8a87f 100644
--- a/tools/testing/selftests/vm/userfaultfd.c
+++ b/tools/testing/selftests/vm/userfaultfd.c
@@ -397,7 +397,7 @@ static void retry_copy_page(int ufd, struct uffdio_copy *uffdio_copy,
 	}
 }
 
-static int copy_page(int ufd, unsigned long offset)
+static int __copy_page(int ufd, unsigned long offset, bool retry)
 {
 	struct uffdio_copy uffdio_copy;
 
@@ -418,7 +418,7 @@ static int copy_page(int ufd, unsigned long offset)
 		fprintf(stderr, "UFFDIO_COPY unexpected copy %Ld\n",
 			uffdio_copy.copy), exit(1);
 	} else {
-		if (test_uffdio_copy_eexist) {
+		if (test_uffdio_copy_eexist && retry) {
 			test_uffdio_copy_eexist = false;
 			retry_copy_page(ufd, &uffdio_copy, offset);
 		}
@@ -427,6 +427,16 @@ static int copy_page(int ufd, unsigned long offset)
 	return 0;
 }
 
+static int copy_page_retry(int ufd, unsigned long offset)
+{
+	return __copy_page(ufd, offset, true);
+}
+
+static int copy_page(int ufd, unsigned long offset)
+{
+	return __copy_page(ufd, offset, false);
+}
+
 static void *uffd_poll_thread(void *arg)
 {
 	unsigned long cpu = (unsigned long) arg;
@@ -544,7 +554,7 @@ static void *background_thread(void *arg)
 	for (page_nr = cpu * nr_pages_per_cpu;
 	     page_nr < (cpu+1) * nr_pages_per_cpu;
 	     page_nr++)
-		copy_page(uffd, page_nr * page_size);
+		copy_page_retry(uffd, page_nr * page_size);
 
 	return NULL;
 }
@@ -779,7 +789,7 @@ static void retry_uffdio_zeropage(int ufd,
 	}
 }
 
-static int uffdio_zeropage(int ufd, unsigned long offset)
+static int __uffdio_zeropage(int ufd, unsigned long offset, bool retry)
 {
 	struct uffdio_zeropage uffdio_zeropage;
 	int ret;
@@ -814,7 +824,7 @@ static int uffdio_zeropage(int ufd, unsigned long offset)
 			fprintf(stderr, "UFFDIO_ZEROPAGE unexpected %Ld\n",
 				uffdio_zeropage.zeropage), exit(1);
 		} else {
-			if (test_uffdio_zeropage_eexist) {
+			if (test_uffdio_zeropage_eexist && retry) {
 				test_uffdio_zeropage_eexist = false;
 				retry_uffdio_zeropage(ufd, &uffdio_zeropage,
 						      offset);
@@ -830,6 +840,11 @@ static int uffdio_zeropage(int ufd, unsigned long offset)
 	return 0;
 }
 
+static int uffdio_zeropage(int ufd, unsigned long offset)
+{
+	return __uffdio_zeropage(ufd, offset, false);
+}
+
 /* exercise UFFDIO_ZEROPAGE */
 static int userfaultfd_zeropage_test(void)
 {

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

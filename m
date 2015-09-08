Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f44.google.com (mail-pa0-f44.google.com [209.85.220.44])
	by kanga.kvack.org (Postfix) with ESMTP id BB3FF6B025B
	for <linux-mm@kvack.org>; Tue,  8 Sep 2015 16:43:47 -0400 (EDT)
Received: by padhk3 with SMTP id hk3so48757845pad.3
        for <linux-mm@kvack.org>; Tue, 08 Sep 2015 13:43:47 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id i10si7469725pat.138.2015.09.08.13.43.36
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 08 Sep 2015 13:43:37 -0700 (PDT)
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: [PATCH 08/12] userfaultfd: selftest: return an error if BOUNCE_VERIFY fails
Date: Tue,  8 Sep 2015 22:43:26 +0200
Message-Id: <1441745010-14314-9-git-send-email-aarcange@redhat.com>
In-Reply-To: <1441745010-14314-1-git-send-email-aarcange@redhat.com>
References: <1441745010-14314-1-git-send-email-aarcange@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org
Cc: Pavel Emelyanov <xemul@parallels.com>, zhang.zhanghailiang@huawei.com, Dave Hansen <dave.hansen@intel.com>, Rik van Riel <riel@redhat.com>, "Dr. David Alan Gilbert" <dgilbert@redhat.com>, "Huangpeng (Peter)" <peter.huangpeng@huawei.com>, Michael Ellerman <mpe@ellerman.id.au>, Bamvor Zhang Jian <bamvor.zhangjian@linaro.org>, Bharata B Rao <bharata@linux.vnet.ibm.com>, Geert Uytterhoeven <geert@linux-m68k.org>

This will report the error in the exit code, in addition of the
fprintf.

Signed-off-by: Andrea Arcangeli <aarcange@redhat.com>
---
 tools/testing/selftests/vm/userfaultfd.c | 9 ++++++---
 1 file changed, 6 insertions(+), 3 deletions(-)

diff --git a/tools/testing/selftests/vm/userfaultfd.c b/tools/testing/selftests/vm/userfaultfd.c
index 1089709..174f2fc 100644
--- a/tools/testing/selftests/vm/userfaultfd.c
+++ b/tools/testing/selftests/vm/userfaultfd.c
@@ -422,7 +422,7 @@ static int userfaultfd_stress(void)
 	struct uffdio_register uffdio_register;
 	struct uffdio_api uffdio_api;
 	unsigned long cpu;
-	int uffd_flags;
+	int uffd_flags, err;
 	unsigned long userfaults[nr_cpus];
 
 	if (posix_memalign(&area, page_size, nr_pages * page_size)) {
@@ -499,6 +499,7 @@ static int userfaultfd_stress(void)
 	pthread_attr_init(&attr);
 	pthread_attr_setstacksize(&attr, 16*1024*1024);
 
+	err = 0;
 	while (bounces--) {
 		unsigned long expected_ioctls;
 
@@ -583,8 +584,9 @@ static int userfaultfd_stress(void)
 					    area_dst + nr * page_size,
 					    sizeof(pthread_mutex_t))) {
 					fprintf(stderr,
-						"error mutex 2 %lu\n",
+						"error mutex %lu\n",
 						nr);
+					err = 1;
 					bounces = 0;
 				}
 				if (*area_count(area_dst, nr) != count_verify[nr]) {
@@ -593,6 +595,7 @@ static int userfaultfd_stress(void)
 						*area_count(area_src, nr),
 						count_verify[nr],
 						nr);
+					err = 1;
 					bounces = 0;
 				}
 			}
@@ -609,7 +612,7 @@ static int userfaultfd_stress(void)
 		printf("\n");
 	}
 
-	return 0;
+	return err;
 }
 
 int main(int argc, char **argv)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

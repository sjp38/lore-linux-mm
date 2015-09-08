Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f51.google.com (mail-pa0-f51.google.com [209.85.220.51])
	by kanga.kvack.org (Postfix) with ESMTP id 90FAA6B0260
	for <linux-mm@kvack.org>; Tue,  8 Sep 2015 16:43:57 -0400 (EDT)
Received: by padhy16 with SMTP id hy16so131510362pad.1
        for <linux-mm@kvack.org>; Tue, 08 Sep 2015 13:43:57 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id cb5si7408882pbd.216.2015.09.08.13.43.39
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 08 Sep 2015 13:43:40 -0700 (PDT)
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: [PATCH 06/12] userfaultfd: selftest: avoid my_bcmp false positives with powerpc
Date: Tue,  8 Sep 2015 22:43:24 +0200
Message-Id: <1441745010-14314-7-git-send-email-aarcange@redhat.com>
In-Reply-To: <1441745010-14314-1-git-send-email-aarcange@redhat.com>
References: <1441745010-14314-1-git-send-email-aarcange@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org
Cc: Pavel Emelyanov <xemul@parallels.com>, zhang.zhanghailiang@huawei.com, Dave Hansen <dave.hansen@intel.com>, Rik van Riel <riel@redhat.com>, "Dr. David Alan Gilbert" <dgilbert@redhat.com>, "Huangpeng (Peter)" <peter.huangpeng@huawei.com>, Michael Ellerman <mpe@ellerman.id.au>, Bamvor Zhang Jian <bamvor.zhangjian@linaro.org>, Bharata B Rao <bharata@linux.vnet.ibm.com>, Geert Uytterhoeven <geert@linux-m68k.org>

Keep a non-zero placeholder after the count, for the my_bcmp
comparison of the page against the zeropage. The lockless increment
between 255 to 256 against a lockless my_bcmp could otherwise return
false positives on ppc32le.

Signed-off-by: Andrea Arcangeli <aarcange@redhat.com>
---
 tools/testing/selftests/vm/userfaultfd.c | 12 ++++++++++--
 1 file changed, 10 insertions(+), 2 deletions(-)

diff --git a/tools/testing/selftests/vm/userfaultfd.c b/tools/testing/selftests/vm/userfaultfd.c
index 0c7d66f..c1e4fa1 100644
--- a/tools/testing/selftests/vm/userfaultfd.c
+++ b/tools/testing/selftests/vm/userfaultfd.c
@@ -462,6 +462,14 @@ static int userfaultfd_stress(void)
 		*area_mutex(area_src, nr) = (pthread_mutex_t)
 			PTHREAD_MUTEX_INITIALIZER;
 		count_verify[nr] = *area_count(area_src, nr) = 1;
+		/*
+		 * In the transition between 255 to 256, powerpc will
+		 * read out of order in my_bcmp and see both bytes as
+		 * zero, so leave a placeholder below always non-zero
+		 * after the count, to avoid my_bcmp to trigger false
+		 * positives.
+		 */
+		*(area_count(area_src, nr) + 1) = 1;
 	}
 
 	pipefd = malloc(sizeof(int) * nr_cpus * 2);
@@ -607,8 +615,8 @@ int main(int argc, char **argv)
 		fprintf(stderr, "Usage: <MiB> <bounces>\n"), exit(1);
 	nr_cpus = sysconf(_SC_NPROCESSORS_ONLN);
 	page_size = sysconf(_SC_PAGE_SIZE);
-	if ((unsigned long) area_count(NULL, 0) + sizeof(unsigned long long) >
-	    page_size)
+	if ((unsigned long) area_count(NULL, 0) + sizeof(unsigned long long) * 2
+	    > page_size)
 		fprintf(stderr, "Impossible to run this test\n"), exit(2);
 	nr_pages_per_cpu = atol(argv[1]) * 1024*1024 / page_size /
 		nr_cpus;

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

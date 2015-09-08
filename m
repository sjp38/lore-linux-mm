Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f45.google.com (mail-pa0-f45.google.com [209.85.220.45])
	by kanga.kvack.org (Postfix) with ESMTP id 85C8C6B025F
	for <linux-mm@kvack.org>; Tue,  8 Sep 2015 16:43:55 -0400 (EDT)
Received: by pacfv12 with SMTP id fv12so136768300pac.2
        for <linux-mm@kvack.org>; Tue, 08 Sep 2015 13:43:55 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id kt9si7457853pab.169.2015.09.08.13.43.39
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 08 Sep 2015 13:43:39 -0700 (PDT)
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: [PATCH 09/12] userfaultfd: selftest: don't error out if pthread_mutex_t isn't identical
Date: Tue,  8 Sep 2015 22:43:27 +0200
Message-Id: <1441745010-14314-10-git-send-email-aarcange@redhat.com>
In-Reply-To: <1441745010-14314-1-git-send-email-aarcange@redhat.com>
References: <1441745010-14314-1-git-send-email-aarcange@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org
Cc: Pavel Emelyanov <xemul@parallels.com>, zhang.zhanghailiang@huawei.com, Dave Hansen <dave.hansen@intel.com>, Rik van Riel <riel@redhat.com>, "Dr. David Alan Gilbert" <dgilbert@redhat.com>, "Huangpeng (Peter)" <peter.huangpeng@huawei.com>, Michael Ellerman <mpe@ellerman.id.au>, Bamvor Zhang Jian <bamvor.zhangjian@linaro.org>, Bharata B Rao <bharata@linux.vnet.ibm.com>, Geert Uytterhoeven <geert@linux-m68k.org>

On ppc big endian this check fails, the mutex doesn't necessarily need
to be identical for all pages after pthread_mutex_lock/unlock
cycles. The count verification (outside of the pthread_mutex_t
structure) suffices and that is retained.

Signed-off-by: Andrea Arcangeli <aarcange@redhat.com>
---
 tools/testing/selftests/vm/userfaultfd.c | 9 ---------
 1 file changed, 9 deletions(-)

diff --git a/tools/testing/selftests/vm/userfaultfd.c b/tools/testing/selftests/vm/userfaultfd.c
index 174f2fc..d77ed41 100644
--- a/tools/testing/selftests/vm/userfaultfd.c
+++ b/tools/testing/selftests/vm/userfaultfd.c
@@ -580,15 +580,6 @@ static int userfaultfd_stress(void)
 		/* verification */
 		if (bounces & BOUNCE_VERIFY) {
 			for (nr = 0; nr < nr_pages; nr++) {
-				if (my_bcmp(area_dst,
-					    area_dst + nr * page_size,
-					    sizeof(pthread_mutex_t))) {
-					fprintf(stderr,
-						"error mutex %lu\n",
-						nr);
-					err = 1;
-					bounces = 0;
-				}
 				if (*area_count(area_dst, nr) != count_verify[nr]) {
 					fprintf(stderr,
 						"error area_count %Lu %Lu %lu\n",

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

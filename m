Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f47.google.com (mail-pa0-f47.google.com [209.85.220.47])
	by kanga.kvack.org (Postfix) with ESMTP id BD6196B025A
	for <linux-mm@kvack.org>; Tue,  8 Sep 2015 16:43:45 -0400 (EDT)
Received: by padhy16 with SMTP id hy16so131506435pad.1
        for <linux-mm@kvack.org>; Tue, 08 Sep 2015 13:43:45 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id if5si3590528pbb.200.2015.09.08.13.43.36
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 08 Sep 2015 13:43:37 -0700 (PDT)
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: [PATCH 07/12] userfaultfd: selftest: Fix compiler warnings on 32-bit
Date: Tue,  8 Sep 2015 22:43:25 +0200
Message-Id: <1441745010-14314-8-git-send-email-aarcange@redhat.com>
In-Reply-To: <1441745010-14314-1-git-send-email-aarcange@redhat.com>
References: <1441745010-14314-1-git-send-email-aarcange@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org
Cc: Pavel Emelyanov <xemul@parallels.com>, zhang.zhanghailiang@huawei.com, Dave Hansen <dave.hansen@intel.com>, Rik van Riel <riel@redhat.com>, "Dr. David Alan Gilbert" <dgilbert@redhat.com>, "Huangpeng (Peter)" <peter.huangpeng@huawei.com>, Michael Ellerman <mpe@ellerman.id.au>, Bamvor Zhang Jian <bamvor.zhangjian@linaro.org>, Bharata B Rao <bharata@linux.vnet.ibm.com>, Geert Uytterhoeven <geert@linux-m68k.org>

From: Geert Uytterhoeven <geert@linux-m68k.org>

On 32-bit:

    userfaultfd.c: In function 'locking_thread':
    userfaultfd.c:152: warning: left shift count >= width of type
    userfaultfd.c: In function 'uffd_poll_thread':
    userfaultfd.c:295: warning: cast to pointer from integer of different size
    userfaultfd.c: In function 'uffd_read_thread':
    userfaultfd.c:332: warning: cast to pointer from integer of different size

Fix the shift warning by splitting the shift in two parts, and the
integer/pointer warnigns by adding intermediate casts to "unsigned
long".

Signed-off-by: Geert Uytterhoeven <geert@linux-m68k.org>
Signed-off-by: Andrea Arcangeli <aarcange@redhat.com>
---
 tools/testing/selftests/vm/userfaultfd.c | 9 ++++++---
 1 file changed, 6 insertions(+), 3 deletions(-)

diff --git a/tools/testing/selftests/vm/userfaultfd.c b/tools/testing/selftests/vm/userfaultfd.c
index c1e4fa1..1089709 100644
--- a/tools/testing/selftests/vm/userfaultfd.c
+++ b/tools/testing/selftests/vm/userfaultfd.c
@@ -139,7 +139,8 @@ static void *locking_thread(void *arg)
 			if (sizeof(page_nr) > sizeof(rand_nr)) {
 				if (random_r(&rand, &rand_nr))
 					fprintf(stderr, "random_r 2 error\n"), exit(1);
-				page_nr |= ((unsigned long) rand_nr) << 32;
+				page_nr |= (((unsigned long) rand_nr) << 16) <<
+					   16;
 			}
 		} else
 			page_nr += 1;
@@ -282,7 +283,8 @@ static void *uffd_poll_thread(void *arg)
 				msg.event), exit(1);
 		if (msg.arg.pagefault.flags & UFFD_PAGEFAULT_FLAG_WRITE)
 			fprintf(stderr, "unexpected write fault\n"), exit(1);
-		offset = (char *)msg.arg.pagefault.address - area_dst;
+		offset = (char *)(unsigned long)msg.arg.pagefault.address -
+			 area_dst;
 		offset &= ~(page_size-1);
 		if (copy_page(offset))
 			userfaults++;
@@ -319,7 +321,8 @@ static void *uffd_read_thread(void *arg)
 		if (bounces & BOUNCE_VERIFY &&
 		    msg.arg.pagefault.flags & UFFD_PAGEFAULT_FLAG_WRITE)
 			fprintf(stderr, "unexpected write fault\n"), exit(1);
-		offset = (char *)msg.arg.pagefault.address - area_dst;
+		offset = (char *)(unsigned long)msg.arg.pagefault.address -
+			 area_dst;
 		offset &= ~(page_size-1);
 		if (copy_page(offset))
 			(*this_cpu_userfaults)++;

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

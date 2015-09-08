Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f180.google.com (mail-ig0-f180.google.com [209.85.213.180])
	by kanga.kvack.org (Postfix) with ESMTP id 782486B0038
	for <linux-mm@kvack.org>; Tue,  8 Sep 2015 16:43:35 -0400 (EDT)
Received: by igbni9 with SMTP id ni9so86899188igb.0
        for <linux-mm@kvack.org>; Tue, 08 Sep 2015 13:43:35 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id db9si6487192pdb.129.2015.09.08.13.43.34
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 08 Sep 2015 13:43:34 -0700 (PDT)
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: [PATCH 04/12] userfaultfd: selftest: headers fixup
Date: Tue,  8 Sep 2015 22:43:22 +0200
Message-Id: <1441745010-14314-5-git-send-email-aarcange@redhat.com>
In-Reply-To: <1441745010-14314-1-git-send-email-aarcange@redhat.com>
References: <1441745010-14314-1-git-send-email-aarcange@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org
Cc: Pavel Emelyanov <xemul@parallels.com>, zhang.zhanghailiang@huawei.com, Dave Hansen <dave.hansen@intel.com>, Rik van Riel <riel@redhat.com>, "Dr. David Alan Gilbert" <dgilbert@redhat.com>, "Huangpeng (Peter)" <peter.huangpeng@huawei.com>, Michael Ellerman <mpe@ellerman.id.au>, Bamvor Zhang Jian <bamvor.zhangjian@linaro.org>, Bharata B Rao <bharata@linux.vnet.ibm.com>, Geert Uytterhoeven <geert@linux-m68k.org>

Depend on "make headers_install" to create proper headers to include
and provide syscall numbers.

Signed-off-by: Andrea Arcangeli <aarcange@redhat.com>
---
 tools/testing/selftests/vm/Makefile      | 7 +++++--
 tools/testing/selftests/vm/userfaultfd.c | 8 --------
 2 files changed, 5 insertions(+), 10 deletions(-)

diff --git a/tools/testing/selftests/vm/Makefile b/tools/testing/selftests/vm/Makefile
index 33f7bbf..5b066fc 100644
--- a/tools/testing/selftests/vm/Makefile
+++ b/tools/testing/selftests/vm/Makefile
@@ -13,8 +13,11 @@ BINARIES += userfaultfd
 all: $(BINARIES)
 %: %.c
 	$(CC) $(CFLAGS) -o $@ $^ -lrt
-userfaultfd: userfaultfd.c
-	$(CC) $(CFLAGS) -O2 -o $@ $^ -lpthread
+userfaultfd: userfaultfd.c ../../../../usr/include/linux/kernel.h
+	$(CC) $(CFLAGS) -O2 -o $@ $< -lpthread
+
+../../../../usr/include/linux/kernel.h:
+	make -C ../../../.. headers_install
 
 TEST_PROGS := run_vmtests
 TEST_FILES := $(BINARIES)
diff --git a/tools/testing/selftests/vm/userfaultfd.c b/tools/testing/selftests/vm/userfaultfd.c
index 2bf1fc3..23ba5f2 100644
--- a/tools/testing/selftests/vm/userfaultfd.c
+++ b/tools/testing/selftests/vm/userfaultfd.c
@@ -67,16 +67,8 @@
 #include <linux/userfaultfd.h>
 
 #ifndef __NR_userfaultfd
-#ifdef __x86_64__
-#define __NR_userfaultfd 323
-#elif defined(__i386__)
-#define __NR_userfaultfd 374
-#elif defined(__powewrpc__)
-#define __NR_userfaultfd 364
-#else
 #error "missing __NR_userfaultfd definition"
 #endif
-#endif
 
 static unsigned long nr_cpus, nr_pages, nr_pages_per_cpu, page_size;
 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f171.google.com (mail-io0-f171.google.com [209.85.223.171])
	by kanga.kvack.org (Postfix) with ESMTP id E98CD6B0254
	for <linux-mm@kvack.org>; Tue,  8 Sep 2015 16:43:35 -0400 (EDT)
Received: by iofb144 with SMTP id b144so133654566iof.1
        for <linux-mm@kvack.org>; Tue, 08 Sep 2015 13:43:35 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id h17si7511333pdk.11.2015.09.08.13.43.34
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 08 Sep 2015 13:43:34 -0700 (PDT)
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: [PATCH 03/12] userfaultfd: selftests: vm: pick up sanitized kernel headers
Date: Tue,  8 Sep 2015 22:43:21 +0200
Message-Id: <1441745010-14314-4-git-send-email-aarcange@redhat.com>
In-Reply-To: <1441745010-14314-1-git-send-email-aarcange@redhat.com>
References: <1441745010-14314-1-git-send-email-aarcange@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org
Cc: Pavel Emelyanov <xemul@parallels.com>, zhang.zhanghailiang@huawei.com, Dave Hansen <dave.hansen@intel.com>, Rik van Riel <riel@redhat.com>, "Dr. David Alan Gilbert" <dgilbert@redhat.com>, "Huangpeng (Peter)" <peter.huangpeng@huawei.com>, Michael Ellerman <mpe@ellerman.id.au>, Bamvor Zhang Jian <bamvor.zhangjian@linaro.org>, Bharata B Rao <bharata@linux.vnet.ibm.com>, Geert Uytterhoeven <geert@linux-m68k.org>

From: Thierry Reding <treding@nvidia.com>

Add the usr/include subdirectory of the top-level tree to the include
path, and make sure to include headers without relative paths to make sure
the sanitized headers get picked up.  Otherwise the compiler will not be
able to find the linux/compiler.h header included by the non- sanitized
include/uapi/linux/userfaultfd.h.

While at it, make sure to only hardcode the syscall numbers on x86 and
PowerPC if they haven't been properly picked up from the headers.

Signed-off-by: Thierry Reding <treding@nvidia.com>
Cc: Shuah Khan <shuahkh@osg.samsung.com>
Cc: Andrea Arcangeli <aarcange@redhat.com>
Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
Signed-off-by: Andrea Arcangeli <aarcange@redhat.com>
---
 tools/testing/selftests/vm/Makefile      | 2 +-
 tools/testing/selftests/vm/userfaultfd.c | 4 +++-
 2 files changed, 4 insertions(+), 2 deletions(-)

diff --git a/tools/testing/selftests/vm/Makefile b/tools/testing/selftests/vm/Makefile
index 0d68547..33f7bbf 100644
--- a/tools/testing/selftests/vm/Makefile
+++ b/tools/testing/selftests/vm/Makefile
@@ -1,6 +1,6 @@
 # Makefile for vm selftests
 
-CFLAGS = -Wall
+CFLAGS = -Wall -I ../../../../usr/include $(EXTRA_CFLAGS)
 BINARIES = compaction_test
 BINARIES += hugepage-mmap
 BINARIES += hugepage-shm
diff --git a/tools/testing/selftests/vm/userfaultfd.c b/tools/testing/selftests/vm/userfaultfd.c
index 76071b1..2bf1fc3 100644
--- a/tools/testing/selftests/vm/userfaultfd.c
+++ b/tools/testing/selftests/vm/userfaultfd.c
@@ -64,8 +64,9 @@
 #include <sys/syscall.h>
 #include <sys/ioctl.h>
 #include <pthread.h>
-#include "../../../../include/uapi/linux/userfaultfd.h"
+#include <linux/userfaultfd.h>
 
+#ifndef __NR_userfaultfd
 #ifdef __x86_64__
 #define __NR_userfaultfd 323
 #elif defined(__i386__)
@@ -75,6 +76,7 @@
 #else
 #error "missing __NR_userfaultfd definition"
 #endif
+#endif
 
 static unsigned long nr_cpus, nr_pages, nr_pages_per_cpu, page_size;
 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

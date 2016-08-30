Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id A65B783096
	for <linux-mm@kvack.org>; Tue, 30 Aug 2016 07:00:43 -0400 (EDT)
Received: by mail-pf0-f197.google.com with SMTP id w128so37131275pfd.3
        for <linux-mm@kvack.org>; Tue, 30 Aug 2016 04:00:43 -0700 (PDT)
Received: from mail-pa0-x241.google.com (mail-pa0-x241.google.com. [2607:f8b0:400e:c03::241])
        by mx.google.com with ESMTPS id z88si44694432pff.218.2016.08.30.04.00.39
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 30 Aug 2016 04:00:42 -0700 (PDT)
Received: by mail-pa0-x241.google.com with SMTP id hh10so962665pac.1
        for <linux-mm@kvack.org>; Tue, 30 Aug 2016 04:00:39 -0700 (PDT)
From: wei.guo.simon@gmail.com
Subject: [PATCH 4/4] selftests/vm: add test for mlock() when areas are intersected.
Date: Tue, 30 Aug 2016 18:59:41 +0800
Message-Id: <1472554781-9835-5-git-send-email-wei.guo.simon@gmail.com>
In-Reply-To: <1472554781-9835-1-git-send-email-wei.guo.simon@gmail.com>
References: <1472554781-9835-1-git-send-email-wei.guo.simon@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: Alexey Klimov <klimov.linux@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, Eric B Munson <emunson@akamai.com>, Geert Uytterhoeven <geert@linux-m68k.org>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, linux-kernel@vger.kernel.org, linux-kselftest@vger.kernel.org, Mel Gorman <mgorman@techsingularity.net>, Michal Hocko <mhocko@suse.com>, Shuah Khan <shuah@kernel.org>, Simon Guo <wei.guo.simon@gmail.com>, Thierry Reding <treding@nvidia.com>, Vlastimil Babka <vbabka@suse.cz>

From: Simon Guo <wei.guo.simon@gmail.com>

This patch adds mlock() test for multiple invocation on
the same address area, and verify it doesn't mess the
rlimit mlock limitation.

Signed-off-by: Simon Guo <wei.guo.simon@gmail.com>
---
 tools/testing/selftests/vm/.gitignore             |  1 +
 tools/testing/selftests/vm/Makefile               |  4 ++
 tools/testing/selftests/vm/mlock-intersect-test.c | 76 +++++++++++++++++++++++
 3 files changed, 81 insertions(+)
 create mode 100644 tools/testing/selftests/vm/mlock-intersect-test.c

diff --git a/tools/testing/selftests/vm/.gitignore b/tools/testing/selftests/vm/.gitignore
index a937a9d..142c565 100644
--- a/tools/testing/selftests/vm/.gitignore
+++ b/tools/testing/selftests/vm/.gitignore
@@ -7,3 +7,4 @@ mlock2-tests
 on-fault-limit
 transhuge-stress
 userfaultfd
+mlock-intersect-test
diff --git a/tools/testing/selftests/vm/Makefile b/tools/testing/selftests/vm/Makefile
index e4bb1de..a0412a8 100644
--- a/tools/testing/selftests/vm/Makefile
+++ b/tools/testing/selftests/vm/Makefile
@@ -10,6 +10,7 @@ BINARIES += on-fault-limit
 BINARIES += thuge-gen
 BINARIES += transhuge-stress
 BINARIES += userfaultfd
+BINARIES += mlock-intersect-test
 
 all: $(BINARIES)
 %: %.c
@@ -17,6 +18,9 @@ all: $(BINARIES)
 userfaultfd: userfaultfd.c ../../../../usr/include/linux/kernel.h
 	$(CC) $(CFLAGS) -O2 -o $@ $< -lpthread
 
+mlock-intersect-test: mlock-intersect-test.c
+	$(CC) $(CFLAGS) -o $@ $< -lcap
+
 ../../../../usr/include/linux/kernel.h:
 	make -C ../../../.. headers_install
 
diff --git a/tools/testing/selftests/vm/mlock-intersect-test.c b/tools/testing/selftests/vm/mlock-intersect-test.c
new file mode 100644
index 0000000..f78e68a
--- /dev/null
+++ b/tools/testing/selftests/vm/mlock-intersect-test.c
@@ -0,0 +1,76 @@
+/*
+ * It tests the duplicate mlock result:
+ * - the ulimit of lock page is 64k
+ * - allocate address area 64k starting from p
+ * - mlock   [p -- p + 30k]
+ * - Then mlock address  [ p -- p + 40k ]
+ *
+ * It should succeed since totally we locked
+ * 40k < 64k limitation.
+ *
+ * It should not be run with CAP_IPC_LOCK.
+ */
+#include <stdlib.h>
+#include <stdio.h>
+#include <unistd.h>
+#include <sys/resource.h>
+#include <sys/capability.h>
+#include <sys/mman.h>
+#include "mlock2.h"
+
+int main(int argc, char **argv)
+{
+	struct rlimit new;
+	char *p = NULL;
+	cap_t cap = cap_init();
+	int i;
+
+	/* drop capabilities including CAP_IPC_LOCK */
+	if (cap_set_proc(cap))
+		return -1;
+
+	/* set mlock limits to 64k */
+	new.rlim_cur = 65536;
+	new.rlim_max = 65536;
+	setrlimit(RLIMIT_MEMLOCK, &new);
+
+	/* test VM_LOCK */
+	p = malloc(1024 * 64);
+	if (mlock(p, 1024 * 30)) {
+		printf("mlock() 30k return failure.\n");
+		return -1;
+	}
+	for (i = 0; i < 10; i++) {
+		if (mlock(p, 1024 * 40)) {
+			printf("mlock() #%d 40k returns failure.\n", i);
+			return -1;
+		}
+	}
+	for (i = 0; i < 10; i++) {
+		if (mlock2_(p, 1024 * 40, MLOCK_ONFAULT)) {
+			printf("mlock2_() #%d 40k returns failure.\n", i);
+			return -1;
+		}
+	}
+	free(p);
+
+	/* Test VM_LOCKONFAULT */
+	p = malloc(1024 * 64);
+	if (mlock2_(p, 1024 * 30, MLOCK_ONFAULT)) {
+		printf("mlock2_() 30k return failure.\n");
+		return -1;
+	}
+	for (i = 0; i < 10; i++) {
+		if (mlock2_(p, 1024 * 40, MLOCK_ONFAULT)) {
+			printf("mlock2_() #%d 40k returns failure.\n", i);
+			return -1;
+		}
+	}
+	for (i = 0; i < 10; i++) {
+		if (mlock(p, 1024 * 40)) {
+			printf("mlock() #%d 40k returns failure.\n", i);
+			return -1;
+		}
+	}
+	return 0;
+}
-- 
1.8.3.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

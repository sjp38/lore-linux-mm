Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f72.google.com (mail-pa0-f72.google.com [209.85.220.72])
	by kanga.kvack.org (Postfix) with ESMTP id 46A7383096
	for <linux-mm@kvack.org>; Tue, 30 Aug 2016 07:00:36 -0400 (EDT)
Received: by mail-pa0-f72.google.com with SMTP id ez1so32263007pab.1
        for <linux-mm@kvack.org>; Tue, 30 Aug 2016 04:00:36 -0700 (PDT)
Received: from mail-pf0-x242.google.com (mail-pf0-x242.google.com. [2607:f8b0:400e:c00::242])
        by mx.google.com with ESMTPS id d28si44756995pfb.283.2016.08.30.04.00.35
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 30 Aug 2016 04:00:35 -0700 (PDT)
Received: by mail-pf0-x242.google.com with SMTP id i6so1007352pfe.0
        for <linux-mm@kvack.org>; Tue, 30 Aug 2016 04:00:35 -0700 (PDT)
From: wei.guo.simon@gmail.com
Subject: [PATCH 3/4] selftest: split mlock2_ funcs into separate mlock2.h
Date: Tue, 30 Aug 2016 18:59:40 +0800
Message-Id: <1472554781-9835-4-git-send-email-wei.guo.simon@gmail.com>
In-Reply-To: <1472554781-9835-1-git-send-email-wei.guo.simon@gmail.com>
References: <1472554781-9835-1-git-send-email-wei.guo.simon@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: Alexey Klimov <klimov.linux@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, Eric B Munson <emunson@akamai.com>, Geert Uytterhoeven <geert@linux-m68k.org>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, linux-kernel@vger.kernel.org, linux-kselftest@vger.kernel.org, Mel Gorman <mgorman@techsingularity.net>, Michal Hocko <mhocko@suse.com>, Shuah Khan <shuah@kernel.org>, Simon Guo <wei.guo.simon@gmail.com>, Thierry Reding <treding@nvidia.com>, Vlastimil Babka <vbabka@suse.cz>

From: Simon Guo <wei.guo.simon@gmail.com>

To prepare mlock2.h whose functionality will be reused.

Signed-off-by: Simon Guo <wei.guo.simon@gmail.com>
---
 tools/testing/selftests/vm/mlock2-tests.c | 21 +--------------------
 tools/testing/selftests/vm/mlock2.h       | 20 ++++++++++++++++++++
 2 files changed, 21 insertions(+), 20 deletions(-)
 create mode 100644 tools/testing/selftests/vm/mlock2.h

diff --git a/tools/testing/selftests/vm/mlock2-tests.c b/tools/testing/selftests/vm/mlock2-tests.c
index 02ca5e0..7cb13ce 100644
--- a/tools/testing/selftests/vm/mlock2-tests.c
+++ b/tools/testing/selftests/vm/mlock2-tests.c
@@ -7,27 +7,8 @@
 #include <string.h>
 #include <sys/time.h>
 #include <sys/resource.h>
-#include <syscall.h>
-#include <errno.h>
 #include <stdbool.h>
-
-#ifndef MLOCK_ONFAULT
-#define MLOCK_ONFAULT 1
-#endif
-
-#ifndef MCL_ONFAULT
-#define MCL_ONFAULT (MCL_FUTURE << 1)
-#endif
-
-static int mlock2_(void *start, size_t len, int flags)
-{
-#ifdef __NR_mlock2
-	return syscall(__NR_mlock2, start, len, flags);
-#else
-	errno = ENOSYS;
-	return -1;
-#endif
-}
+#include "mlock2.h"
 
 struct vm_boundaries {
 	unsigned long start;
diff --git a/tools/testing/selftests/vm/mlock2.h b/tools/testing/selftests/vm/mlock2.h
new file mode 100644
index 0000000..b9c6d9f
--- /dev/null
+++ b/tools/testing/selftests/vm/mlock2.h
@@ -0,0 +1,20 @@
+#include <syscall.h>
+#include <errno.h>
+
+#ifndef MLOCK_ONFAULT
+#define MLOCK_ONFAULT 1
+#endif
+
+#ifndef MCL_ONFAULT
+#define MCL_ONFAULT (MCL_FUTURE << 1)
+#endif
+
+static int mlock2_(void *start, size_t len, int flags)
+{
+#ifdef __NR_mlock2
+	return syscall(__NR_mlock2, start, len, flags);
+#else
+	errno = ENOSYS;
+	return -1;
+#endif
+}
-- 
1.8.3.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

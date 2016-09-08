Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f71.google.com (mail-pa0-f71.google.com [209.85.220.71])
	by kanga.kvack.org (Postfix) with ESMTP id A0C386B0253
	for <linux-mm@kvack.org>; Thu,  8 Sep 2016 05:13:34 -0400 (EDT)
Received: by mail-pa0-f71.google.com with SMTP id ez1so89954632pab.1
        for <linux-mm@kvack.org>; Thu, 08 Sep 2016 02:13:34 -0700 (PDT)
Received: from mail-pf0-x243.google.com (mail-pf0-x243.google.com. [2607:f8b0:400e:c00::243])
        by mx.google.com with ESMTPS id x7si38151522pab.271.2016.09.08.02.13.33
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 08 Sep 2016 02:13:34 -0700 (PDT)
Received: by mail-pf0-x243.google.com with SMTP id x24so2230035pfa.3
        for <linux-mm@kvack.org>; Thu, 08 Sep 2016 02:13:33 -0700 (PDT)
From: wei.guo.simon@gmail.com
Subject: [PATCH 2/3] selftest: move seek_to_smaps_entry() out of mlock2-tests.c
Date: Thu,  8 Sep 2016 17:12:49 +0800
Message-Id: <1473325970-11393-3-git-send-email-wei.guo.simon@gmail.com>
In-Reply-To: <1473325970-11393-1-git-send-email-wei.guo.simon@gmail.com>
References: <1473325970-11393-1-git-send-email-wei.guo.simon@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: Shuah Khan <shuah@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Vlastimil Babka <vbabka@suse.cz>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Michal Hocko <mhocko@suse.com>, Eric B Munson <emunson@akamai.com>, Simon Guo <wei.guo.simon@gmail.com>, Mel Gorman <mgorman@techsingularity.net>, Alexey Klimov <klimov.linux@gmail.com>, Andrea Arcangeli <aarcange@redhat.com>, Thierry Reding <treding@nvidia.com>, Mike Kravetz <mike.kravetz@oracle.com>, Geert Uytterhoeven <geert@linux-m68k.org>, linux-kernel@vger.kernel.org, linux-kselftest@vger.kernel.org

From: Simon Guo <wei.guo.simon@gmail.com>

Function seek_to_smaps_entry() can be useful for other selftest
functionalities, so move it out to header file.

Signed-off-by: Simon Guo <wei.guo.simon@gmail.com>
---
 tools/testing/selftests/vm/mlock2-tests.c | 42 ------------------------------
 tools/testing/selftests/vm/mlock2.h       | 43 +++++++++++++++++++++++++++++++
 2 files changed, 43 insertions(+), 42 deletions(-)

diff --git a/tools/testing/selftests/vm/mlock2-tests.c b/tools/testing/selftests/vm/mlock2-tests.c
index 7cb13ce..ff0cda2 100644
--- a/tools/testing/selftests/vm/mlock2-tests.c
+++ b/tools/testing/selftests/vm/mlock2-tests.c
@@ -1,8 +1,6 @@
 #define _GNU_SOURCE
 #include <sys/mman.h>
 #include <stdint.h>
-#include <stdio.h>
-#include <stdlib.h>
 #include <unistd.h>
 #include <string.h>
 #include <sys/time.h>
@@ -119,46 +117,6 @@ static uint64_t get_kpageflags(unsigned long pfn)
 	return flags;
 }
 
-static FILE *seek_to_smaps_entry(unsigned long addr)
-{
-	FILE *file;
-	char *line = NULL;
-	size_t size = 0;
-	unsigned long start, end;
-	char perms[5];
-	unsigned long offset;
-	char dev[32];
-	unsigned long inode;
-	char path[BUFSIZ];
-
-	file = fopen("/proc/self/smaps", "r");
-	if (!file) {
-		perror("fopen smaps");
-		_exit(1);
-	}
-
-	while (getline(&line, &size, file) > 0) {
-		if (sscanf(line, "%lx-%lx %s %lx %s %lu %s\n",
-			   &start, &end, perms, &offset, dev, &inode, path) < 6)
-			goto next;
-
-		if (start <= addr && addr < end)
-			goto out;
-
-next:
-		free(line);
-		line = NULL;
-		size = 0;
-	}
-
-	fclose(file);
-	file = NULL;
-
-out:
-	free(line);
-	return file;
-}
-
 #define VMFLAGS "VmFlags:"
 
 static bool is_vmflag_set(unsigned long addr, const char *vmflag)
diff --git a/tools/testing/selftests/vm/mlock2.h b/tools/testing/selftests/vm/mlock2.h
index b9c6d9f..b2c09b4 100644
--- a/tools/testing/selftests/vm/mlock2.h
+++ b/tools/testing/selftests/vm/mlock2.h
@@ -1,5 +1,7 @@
 #include <syscall.h>
 #include <errno.h>
+#include <stdio.h>
+#include <stdlib.h>
 
 #ifndef MLOCK_ONFAULT
 #define MLOCK_ONFAULT 1
@@ -18,3 +20,44 @@ static int mlock2_(void *start, size_t len, int flags)
 	return -1;
 #endif
 }
+
+static FILE *seek_to_smaps_entry(unsigned long addr)
+{
+	FILE *file;
+	char *line = NULL;
+	size_t size = 0;
+	unsigned long start, end;
+	char perms[5];
+	unsigned long offset;
+	char dev[32];
+	unsigned long inode;
+	char path[BUFSIZ];
+
+	file = fopen("/proc/self/smaps", "r");
+	if (!file) {
+		perror("fopen smaps");
+		_exit(1);
+	}
+
+	while (getline(&line, &size, file) > 0) {
+		if (sscanf(line, "%lx-%lx %s %lx %s %lu %s\n",
+			   &start, &end, perms, &offset, dev, &inode, path) < 6)
+			goto next;
+
+		if (start <= addr && addr < end)
+			goto out;
+
+next:
+		free(line);
+		line = NULL;
+		size = 0;
+	}
+
+	fclose(file);
+	file = NULL;
+
+out:
+	free(line);
+	return file;
+}
+
-- 
1.8.3.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

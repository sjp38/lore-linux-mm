Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with SMTP id D71338D0039
	for <linux-mm@kvack.org>; Thu, 17 Mar 2011 23:04:41 -0400 (EDT)
From: Chen Gong <gong.chen@linux.intel.com>
Subject: [PATCH V3] page-types.c: auto debugfs mount for hwpoison operation
Date: Fri, 18 Mar 2011 11:04:50 +0800
Message-Id: <1300417490-5778-1-git-send-email-gong.chen@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org
Cc: linux-mm@kvack.org, Chen Gong <gong.chen@linux.intel.com>

page-types.c doesn't supply a way to specify the debugfs path and
the original debugfs path is not usual on most machines. This patch
supplies a way to auto mount debugfs if needed.

This patch is heavily inspired by tools/perf/utils/debugfs.c

V3 -> V2 add static definiton and prompt when debugfs is mounted
V2 -> V1 add auto debugfs mount

Signed-off-by: Chen Gong <gong.chen@linux.intel.com>
---
 Documentation/vm/page-types.c |  106 +++++++++++++++++++++++++++++++++++++++--
 1 files changed, 102 insertions(+), 4 deletions(-)

diff --git a/Documentation/vm/page-types.c b/Documentation/vm/page-types.c
index cc96ee2..c594883 100644
--- a/Documentation/vm/page-types.c
+++ b/Documentation/vm/page-types.c
@@ -32,8 +32,20 @@
 #include <sys/types.h>
 #include <sys/errno.h>
 #include <sys/fcntl.h>
+#include <sys/mount.h>
+#include <sys/statfs.h>
+#include "../../include/linux/magic.h"
 
 
+#ifndef MAX_PATH
+# define MAX_PATH 256
+#endif
+
+#ifndef STR
+# define _STR(x) #x
+# define STR(x) _STR(x)
+#endif
+
 /*
  * pagemap kernel ABI bits
  */
@@ -152,6 +164,12 @@ static const char *page_flag_names[] = {
 };
 
 
+static const char *debugfs_known_mountpoints[] = {
+	"/sys/kernel/debug",
+	"/debug",
+	0,
+};
+
 /*
  * data structures
  */
@@ -184,7 +202,7 @@ static int		kpageflags_fd;
 static int		opt_hwpoison;
 static int		opt_unpoison;
 
-static const char	hwpoison_debug_fs[] = "/debug/hwpoison";
+static char		hwpoison_debug_fs[MAX_PATH+1];
 static int		hwpoison_inject_fd;
 static int		hwpoison_forget_fd;
 
@@ -464,21 +482,101 @@ static uint64_t kpageflags_flags(uint64_t flags)
 	return flags;
 }
 
+/* verify that a mountpoint is actually a debugfs instance */
+static int debugfs_valid_mountpoint(const char *debugfs)
+{
+	struct statfs st_fs;
+
+	if (statfs(debugfs, &st_fs) < 0)
+		return -ENOENT;
+	else if (st_fs.f_type != (long) DEBUGFS_MAGIC)
+		return -ENOENT;
+
+	return 0;
+}
+
+/* find the path to the mounted debugfs */
+static const char *debugfs_find_mountpoint(void)
+{
+	const char **ptr;
+	char type[100];
+	FILE *fp;
+
+	ptr = debugfs_known_mountpoints;
+	while (*ptr) {
+		if (debugfs_valid_mountpoint(*ptr) == 0) {
+			strcpy(hwpoison_debug_fs, *ptr);
+			return hwpoison_debug_fs;
+		}
+		ptr++;
+	}
+
+	/* give up and parse /proc/mounts */
+	fp = fopen("/proc/mounts", "r");
+	if (fp == NULL)
+		perror("Can't open /proc/mounts for read");
+
+	while (fscanf(fp, "%*s %"
+		      STR(MAX_PATH)
+		      "s %99s %*s %*d %*d\n",
+		      hwpoison_debug_fs, type) == 2) {
+		if (strcmp(type, "debugfs") == 0)
+			break;
+	}
+	fclose(fp);
+
+	if (strcmp(type, "debugfs") != 0)
+		return NULL;
+
+	return hwpoison_debug_fs;
+}
+
+/* mount the debugfs somewhere if it's not mounted */
+
+static void debugfs_mount()
+{
+	const char **ptr;
+
+	/* see if it's already mounted */
+	if (debugfs_find_mountpoint())
+		return;
+
+	printf("debugfs is auto mounted\n");
+	ptr = debugfs_known_mountpoints;
+	while (*ptr) {
+		if (mount(NULL, *ptr, "debugfs", 0, NULL) == 0) {
+			/* save the mountpoint */
+			strcpy(hwpoison_debug_fs, *ptr);
+			break;
+		}
+		ptr++;
+	}
+
+	if (*ptr == NULL) {
+		perror("mount debugfs");
+		exit(EXIT_FAILURE);
+	}
+}
+
 /*
  * page actions
  */
 
 static void prepare_hwpoison_fd(void)
 {
-	char buf[100];
+	char buf[MAX_PATH + 1];
+
+	debugfs_mount();
 
 	if (opt_hwpoison && !hwpoison_inject_fd) {
-		sprintf(buf, "%s/corrupt-pfn", hwpoison_debug_fs);
+		snprintf(buf, MAX_PATH, "%s/hwpoison/corrupt-pfn",
+			hwpoison_debug_fs);
 		hwpoison_inject_fd = checked_open(buf, O_WRONLY);
 	}
 
 	if (opt_unpoison && !hwpoison_forget_fd) {
-		sprintf(buf, "%s/unpoison-pfn", hwpoison_debug_fs);
+		snprintf(buf, MAX_PATH, "%s/hwpoison/unpoison-pfn",
+			hwpoison_debug_fs);
 		hwpoison_forget_fd = checked_open(buf, O_WRONLY);
 	}
 }
-- 
1.7.3.1.120.g38a18

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

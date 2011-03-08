Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id 8C1E58D0039
	for <linux-mm@kvack.org>; Tue,  8 Mar 2011 00:01:40 -0500 (EST)
Message-ID: <4D75B815.2080603@linux.intel.com>
Date: Tue, 08 Mar 2011 13:01:09 +0800
From: Chen Gong <gong.chen@linux.intel.com>
MIME-Version: 1.0
Subject: Re: [PATCH V2] page-types.c: auto debugfs mount for hwpoison operation
References: <1299487900-7792-1-git-send-email-gong.chen@linux.intel.com> <20110307184133.8A19.A69D9226@jp.fujitsu.com> <20110307113937.GB5080@localhost>
In-Reply-To: <20110307113937.GB5080@localhost>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Wu Fengguang <fengguang.wu@intel.com>
Cc: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Ingo Molnar <mingo@elte.hu>, Clark Williams <williams@redhat.com>, Arnaldo Carvalho de Melo <acme@redhat.com>, Xiao Guangrong <xiaoguangrong@cn.fujitsu.com>

page-types.c doesn't supply a way to specify the debugfs path and
the original debugfs path is not usual on most machines. This patch
supplies a way to auto mount debugfs if needed.

This patch is heavily inspired by tools/perf/utils/debugfs.c

Signed-off-by: Chen Gong <gong.chen@linux.intel.com>
---
  Documentation/vm/page-types.c |  105 
+++++++++++++++++++++++++++++++++++++++--
  1 files changed, 101 insertions(+), 4 deletions(-)

diff --git a/Documentation/vm/page-types.c b/Documentation/vm/page-types.c
index cc96ee2..303b4ed 100644
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

@@ -464,21 +482,100 @@ static uint64_t kpageflags_flags(uint64_t flags)
  	return flags;
  }

+/* verify that a mountpoint is actually a debugfs instance */
+int debugfs_valid_mountpoint(const char *debugfs)
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
+const char *debugfs_find_mountpoint(void)
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
+void debugfs_mount()
+{
+	const char **ptr;
+
+	/* see if it's already mounted */
+	if (debugfs_find_mountpoint())
+		return;
+
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

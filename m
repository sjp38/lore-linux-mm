Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id 99B968D0039
	for <linux-mm@kvack.org>; Mon,  7 Mar 2011 03:51:33 -0500 (EST)
From: Chen Gong <gong.chen@linux.intel.com>
Subject: [PATCH] page-types.c: add a new argument of debugfs path
Date: Mon,  7 Mar 2011 16:51:40 +0800
Message-Id: <1299487900-7792-1-git-send-email-gong.chen@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: fengguang.wu@intel.com, linux-kernel@vger.kernel.org, Chen Gong <gong.chen@linux.intel.com>

page-types.c doesn't supply a way to specify the debugfs path and
the original debugfs path is not usual on most machines. Add a
new argument to set the debugfs path easily.

Signed-off-by: Chen Gong <gong.chen@linux.intel.com>
---
 Documentation/vm/page-types.c |   33 ++++++++++++++++++++++++---------
 1 files changed, 24 insertions(+), 9 deletions(-)

diff --git a/Documentation/vm/page-types.c b/Documentation/vm/page-types.c
index cc96ee2..1ebe87d 100644
--- a/Documentation/vm/page-types.c
+++ b/Documentation/vm/page-types.c
@@ -184,7 +184,7 @@ static int		kpageflags_fd;
 static int		opt_hwpoison;
 static int		opt_unpoison;
 
-static const char	hwpoison_debug_fs[] = "/debug/hwpoison";
+static char		hwpoison_debug_fs[256] = "/sys/kernel/debug";
 static int		hwpoison_inject_fd;
 static int		hwpoison_forget_fd;
 
@@ -464,28 +464,37 @@ static uint64_t kpageflags_flags(uint64_t flags)
 	return flags;
 }
 
+static void prepare_debugfs(const char *optarg)
+{
+	/*
+	 * avoid too long filename.
+	 * "/hwpoison/unpoison-pfn" occupies 22 characters
+	 */
+	strncpy(hwpoison_debug_fs, optarg, 255 - 22);
+}
+
 /*
  * page actions
  */
 
 static void prepare_hwpoison_fd(void)
 {
-	char buf[100];
+	char buf[256];
 
 	if (opt_hwpoison && !hwpoison_inject_fd) {
-		sprintf(buf, "%s/corrupt-pfn", hwpoison_debug_fs);
+		sprintf(buf, "%s/hwpoison/corrupt-pfn", hwpoison_debug_fs);
 		hwpoison_inject_fd = checked_open(buf, O_WRONLY);
 	}
 
 	if (opt_unpoison && !hwpoison_forget_fd) {
-		sprintf(buf, "%s/unpoison-pfn", hwpoison_debug_fs);
+		sprintf(buf, "%s/hwpoison/unpoison-pfn", hwpoison_debug_fs);
 		hwpoison_forget_fd = checked_open(buf, O_WRONLY);
 	}
 }
 
 static int hwpoison_page(unsigned long offset)
 {
-	char buf[100];
+	char buf[256];
 	int len;
 
 	len = sprintf(buf, "0x%lx\n", offset);
@@ -499,7 +508,7 @@ static int hwpoison_page(unsigned long offset)
 
 static int unpoison_page(unsigned long offset)
 {
-	char buf[100];
+	char buf[256];
 	int len;
 
 	len = sprintf(buf, "0x%lx\n", offset);
@@ -686,6 +695,7 @@ static void usage(void)
 "page-types [options]\n"
 "            -r|--raw                   Raw mode, for kernel developers\n"
 "            -d|--describe flags        Describe flags\n"
+"            -D|--debugfs debugfs-path  specify the debugfs path\n"
 "            -a|--addr    addr-spec     Walk a range of pages\n"
 "            -b|--bits    bits-spec     Walk pages with specified bits\n"
 "            -p|--pid     pid           Walk process address space\n"
@@ -917,6 +927,7 @@ static const struct option opts[] = {
 	{ "addr"      , 1, NULL, 'a' },
 	{ "bits"      , 1, NULL, 'b' },
 	{ "describe"  , 1, NULL, 'd' },
+	{ "debugfs"   , 1, NULL, 'D' },
 	{ "list"      , 0, NULL, 'l' },
 	{ "list-each" , 0, NULL, 'L' },
 	{ "no-summary", 0, NULL, 'N' },
@@ -933,7 +944,7 @@ int main(int argc, char *argv[])
 	page_size = getpagesize();
 
 	while ((c = getopt_long(argc, argv,
-				"rp:f:a:b:d:lLNXxh", opts, NULL)) != -1) {
+				"rp:f:a:b:d:D:lLNXxh", opts, NULL)) != -1) {
 		switch (c) {
 		case 'r':
 			opt_raw = 1;
@@ -953,6 +964,9 @@ int main(int argc, char *argv[])
 		case 'd':
 			describe_flags(optarg);
 			exit(0);
+		case 'D':
+			prepare_debugfs(optarg);
+			break;
 		case 'l':
 			opt_list = 1;
 			break;
@@ -964,11 +978,9 @@ int main(int argc, char *argv[])
 			break;
 		case 'X':
 			opt_hwpoison = 1;
-			prepare_hwpoison_fd();
 			break;
 		case 'x':
 			opt_unpoison = 1;
-			prepare_hwpoison_fd();
 			break;
 		case 'h':
 			usage();
@@ -979,6 +991,9 @@ int main(int argc, char *argv[])
 		}
 	}
 
+	if (opt_hwpoison == 1 || opt_unpoison == 1)
+		prepare_hwpoison_fd();
+
 	if (opt_list && opt_pid)
 		printf("voffset\t");
 	if (opt_list == 1)
-- 
1.7.3.1.120.g38a18

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

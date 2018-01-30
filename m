Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f200.google.com (mail-io0-f200.google.com [209.85.223.200])
	by kanga.kvack.org (Postfix) with ESMTP id 00CD46B0005
	for <linux-mm@kvack.org>; Tue, 30 Jan 2018 18:01:05 -0500 (EST)
Received: by mail-io0-f200.google.com with SMTP id k76so12595303iod.12
        for <linux-mm@kvack.org>; Tue, 30 Jan 2018 15:01:04 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id o141sor7025065itb.89.2018.01.30.15.01.03
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 30 Jan 2018 15:01:03 -0800 (PST)
Date: Tue, 30 Jan 2018 15:01:01 -0800 (PST)
From: David Rientjes <rientjes@google.com>
Subject: [patch] tools, vm: new option to specify kpageflags file
Message-ID: <alpine.DEB.2.10.1801301458180.153857@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Konstantin Khlebnikov <koct9i@gmail.com>, Vladimir Davydov <vdavydov@virtuozzo.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

page-types currently hardcodes /proc/kpageflags as the file to parse.  
This works when using the tool to examine the state of pageflags on the 
same system, but does not allow storing a snapshot of pageflags at a given 
time to debug issues nor on a different system.

This allows the user to specify a saved version of kpageflags with a new 
page-types -F option.

Signed-off-by: David Rientjes <rientjes@google.com>
---
 tools/vm/page-types.c | 26 ++++++++++++++++++++------
 1 file changed, 20 insertions(+), 6 deletions(-)

diff --git a/tools/vm/page-types.c b/tools/vm/page-types.c
--- a/tools/vm/page-types.c
+++ b/tools/vm/page-types.c
@@ -172,6 +172,7 @@ static pid_t		opt_pid;	/* process to walk */
 const char *		opt_file;	/* file or directory path */
 static uint64_t		opt_cgroup;	/* cgroup inode */
 static int		opt_list_cgroup;/* list page cgroup */
+static const char *	opt_kpageflags;	/* kpageflags file to parse */
 
 #define MAX_ADDR_RANGES	1024
 static int		nr_addr_ranges;
@@ -258,7 +259,7 @@ static int checked_open(const char *pathname, int flags)
  * pagemap/kpageflags routines
  */
 
-static unsigned long do_u64_read(int fd, char *name,
+static unsigned long do_u64_read(int fd, const char *name,
 				 uint64_t *buf,
 				 unsigned long index,
 				 unsigned long count)
@@ -283,7 +284,7 @@ static unsigned long kpageflags_read(uint64_t *buf,
 				     unsigned long index,
 				     unsigned long pages)
 {
-	return do_u64_read(kpageflags_fd, PROC_KPAGEFLAGS, buf, index, pages);
+	return do_u64_read(kpageflags_fd, opt_kpageflags, buf, index, pages);
 }
 
 static unsigned long kpagecgroup_read(uint64_t *buf,
@@ -293,7 +294,7 @@ static unsigned long kpagecgroup_read(uint64_t *buf,
 	if (kpagecgroup_fd < 0)
 		return pages;
 
-	return do_u64_read(kpagecgroup_fd, PROC_KPAGEFLAGS, buf, index, pages);
+	return do_u64_read(kpagecgroup_fd, opt_kpageflags, buf, index, pages);
 }
 
 static unsigned long pagemap_read(uint64_t *buf,
@@ -743,7 +744,7 @@ static void walk_addr_ranges(void)
 {
 	int i;
 
-	kpageflags_fd = checked_open(PROC_KPAGEFLAGS, O_RDONLY);
+	kpageflags_fd = checked_open(opt_kpageflags, O_RDONLY);
 
 	if (!nr_addr_ranges)
 		add_addr_range(0, ULONG_MAX);
@@ -790,6 +791,7 @@ static void usage(void)
 "            -N|--no-summary            Don't show summary info\n"
 "            -X|--hwpoison              hwpoison pages\n"
 "            -x|--unpoison              unpoison pages\n"
+"            -F|--kpageflags            kpageflags file to parse\n"
 "            -h|--help                  Show this usage message\n"
 "flags:\n"
 "            0x10                       bitfield format, e.g.\n"
@@ -1013,7 +1015,7 @@ static void walk_page_cache(void)
 {
 	struct stat st;
 
-	kpageflags_fd = checked_open(PROC_KPAGEFLAGS, O_RDONLY);
+	kpageflags_fd = checked_open(opt_kpageflags, O_RDONLY);
 	pagemap_fd = checked_open("/proc/self/pagemap", O_RDONLY);
 	sigaction(SIGBUS, &sigbus_action, NULL);
 
@@ -1164,6 +1166,11 @@ static void parse_bits_mask(const char *optarg)
 	add_bits_filter(mask, bits);
 }
 
+static void parse_kpageflags(const char *name)
+{
+	opt_kpageflags = name;
+}
+
 static void describe_flags(const char *optarg)
 {
 	uint64_t flags = parse_flag_names(optarg, 0);
@@ -1188,6 +1195,7 @@ static const struct option opts[] = {
 	{ "no-summary", 0, NULL, 'N' },
 	{ "hwpoison"  , 0, NULL, 'X' },
 	{ "unpoison"  , 0, NULL, 'x' },
+	{ "kpageflags", 0, NULL, 'F' },
 	{ "help"      , 0, NULL, 'h' },
 	{ NULL        , 0, NULL, 0 }
 };
@@ -1199,7 +1207,7 @@ int main(int argc, char *argv[])
 	page_size = getpagesize();
 
 	while ((c = getopt_long(argc, argv,
-				"rp:f:a:b:d:c:ClLNXxh", opts, NULL)) != -1) {
+				"rp:f:a:b:d:c:ClLNXxF:h", opts, NULL)) != -1) {
 		switch (c) {
 		case 'r':
 			opt_raw = 1;
@@ -1242,6 +1250,9 @@ int main(int argc, char *argv[])
 			opt_unpoison = 1;
 			prepare_hwpoison_fd();
 			break;
+		case 'F':
+			parse_kpageflags(optarg);
+			break;
 		case 'h':
 			usage();
 			exit(0);
@@ -1251,6 +1262,9 @@ int main(int argc, char *argv[])
 		}
 	}
 
+	if (!opt_kpageflags)
+		opt_kpageflags = PROC_KPAGEFLAGS;
+
 	if (opt_cgroup || opt_list_cgroup)
 		kpagecgroup_fd = checked_open(PROC_KPAGECGROUP, O_RDONLY);
 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

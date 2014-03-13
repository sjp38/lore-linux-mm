Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-we0-f178.google.com (mail-we0-f178.google.com [74.125.82.178])
	by kanga.kvack.org (Postfix) with ESMTP id 49CA86B003B
	for <linux-mm@kvack.org>; Thu, 13 Mar 2014 17:40:41 -0400 (EDT)
Received: by mail-we0-f178.google.com with SMTP id u56so1384305wes.37
        for <linux-mm@kvack.org>; Thu, 13 Mar 2014 14:40:40 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTP id v4si2437318wjq.174.2014.03.13.14.40.38
        for <linux-mm@kvack.org>;
        Thu, 13 Mar 2014 14:40:39 -0700 (PDT)
From: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Subject: [PATCH 5/6] tools/vm/page-types.c: add file scanning mode
Date: Thu, 13 Mar 2014 17:39:45 -0400
Message-Id: <1394746786-6397-6-git-send-email-n-horiguchi@ah.jp.nec.com>
In-Reply-To: <1394746786-6397-1-git-send-email-n-horiguchi@ah.jp.nec.com>
References: <1394746786-6397-1-git-send-email-n-horiguchi@ah.jp.nec.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: Andrew Morton <akpm@linux-foundation.org>, Andi Kleen <andi@firstfloor.org>, Wu Fengguang <fengguang.wu@intel.com>, Tony Luck <tony.luck@intel.com>, Wanpeng Li <liwanp@linux.vnet.ibm.com>, Dave Chinner <david@fromorbit.com>, Jun'ichi Nomura <j-nomura@ce.jp.nec.com>, linux-mm@kvack.org

This patch introduces a new mode for file scanning, where when page-types
is called with -f <filepath>, it registers a given file to /proc/kpagecache,
and scans pages in the pagecache of the file.

Signed-off-by: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
---
 tools/vm/page-types.c | 117 +++++++++++++++++++++++++++++++++++++++++++-------
 1 file changed, 101 insertions(+), 16 deletions(-)

diff --git v3.14-rc6.orig/tools/vm/page-types.c v3.14-rc6/tools/vm/page-types.c
index f9be24d9efac..e9f1882378c7 100644
--- v3.14-rc6.orig/tools/vm/page-types.c
+++ v3.14-rc6/tools/vm/page-types.c
@@ -33,6 +33,7 @@
 #include <sys/errno.h>
 #include <sys/fcntl.h>
 #include <sys/mount.h>
+#include <sys/stat.h>
 #include <sys/statfs.h>
 #include "../../include/uapi/linux/magic.h"
 #include "../../include/uapi/linux/kernel-page-flags.h"
@@ -75,6 +76,7 @@
 
 #define KPF_BYTES		8
 #define PROC_KPAGEFLAGS		"/proc/kpageflags"
+#define PROC_KPAGECACHE		"/proc/kpagecache"
 
 /* [32-] kernel hacking assistances */
 #define KPF_RESERVED		32
@@ -158,6 +160,7 @@ static int		opt_raw;	/* for kernel developers */
 static int		opt_list;	/* list pages (in ranges) */
 static int		opt_no_summary;	/* don't show summary */
 static pid_t		opt_pid;	/* process to walk */
+static int		opt_file;	/* walk over pagecache of file */
 
 #define MAX_ADDR_RANGES	1024
 static int		nr_addr_ranges;
@@ -178,6 +181,7 @@ static int		page_size;
 
 static int		pagemap_fd;
 static int		kpageflags_fd;
+static int		kpagecache_fd;
 
 static int		opt_hwpoison;
 static int		opt_unpoison;
@@ -276,6 +280,13 @@ static unsigned long kpageflags_read(uint64_t *buf,
 	return do_u64_read(kpageflags_fd, PROC_KPAGEFLAGS, buf, index, pages);
 }
 
+static unsigned long kpagecache_read(uint64_t *buf,
+				     unsigned long index,
+				     unsigned long pages)
+{
+	return do_u64_read(kpagecache_fd, PROC_KPAGECACHE, buf, index, pages);
+}
+
 static unsigned long pagemap_read(uint64_t *buf,
 				  unsigned long index,
 				  unsigned long pages)
@@ -358,7 +369,7 @@ static void show_page_range(unsigned long voffset,
 	}
 
 	if (count) {
-		if (opt_pid)
+		if (opt_pid || opt_file)
 			printf("%lx\t", voff);
 		printf("%lx\t%lx\t%s\n",
 				index, count, page_flag_name(flags0));
@@ -378,6 +389,19 @@ static void show_page(unsigned long voffset,
 	printf("%lx\t%s\n", offset, page_flag_name(flags));
 }
 
+#define __NR_PAGECACHE_TAGS	4
+#define KPC_TAGS_BITS	__NR_PAGECACHE_TAGS
+#define KPC_TAGS_OFFSET	(64 - KPC_TAGS_BITS)
+#define KPC_TAGS_MASK	(((1ULL << KPC_TAGS_BITS) - 1) << KPC_TAGS_OFFSET)
+#define KPC_TAGS(entry)	((entry & KPC_TAGS_MASK) >> KPC_TAGS_OFFSET)
+
+static void show_file_page(unsigned long voffset,
+			   unsigned long offset, uint64_t flags, uint64_t entry)
+{
+	printf("%lx\t%lx\t%llx\t%s\n",
+	       voffset, offset, KPC_TAGS(entry), page_flag_name(flags));
+}
+
 static void show_summary(void)
 {
 	size_t i;
@@ -564,10 +588,15 @@ static void add_page(unsigned long voffset,
 	if (opt_unpoison)
 		unpoison_page(offset);
 
-	if (opt_list == 1)
-		show_page_range(voffset, offset, flags);
-	else if (opt_list == 2)
-		show_page(voffset, offset, flags);
+	if (opt_pid || !opt_file) {
+		if (opt_list == 1)
+			show_page_range(voffset, offset, flags);
+		else if (opt_list == 2)
+			show_page(voffset, offset, flags);
+	} else {
+		if (opt_list)
+			show_file_page(voffset, offset, flags, pme);
+	}
 
 	nr_pages[hash_slot(flags)]++;
 	total_pages++;
@@ -646,6 +675,41 @@ static void walk_task(unsigned long index, unsigned long count)
 	}
 }
 
+char *kpagecache_path;
+struct stat kpagecache_stat;
+
+#define KPAGECACHE_BATCH	(64 << 10)	/* 64k pages */
+static void walk_file(unsigned long index, unsigned long count)
+{
+	uint64_t buf[KPAGECACHE_BATCH];
+	unsigned long batch;
+	unsigned long pages;
+	unsigned long pfn;
+	unsigned long i;
+	unsigned long end_index = count;
+	unsigned long size;
+
+	stat(kpagecache_path, &kpagecache_stat);
+	size = kpagecache_stat.st_size;
+	if (size > 0)
+		size = (size - 1) / 4096;
+	end_index = min_t(unsigned long, index + count - 1, size);
+	while (index <= end_index) {
+		batch = min_t(unsigned long, count, PAGEMAP_BATCH);
+		pages = kpagecache_read(buf, index, batch);
+		if (pages == 0)
+			break;
+		for (i = 0; i < pages; i++) {
+			pfn = buf[i] & ((1UL << 52) - 1UL);
+			if (pfn)
+				walk_pfn(index + i, pfn, 1, buf[i]);
+		}
+
+		index += pages;
+		count -= pages;
+	}
+}
+
 static void add_addr_range(unsigned long offset, unsigned long size)
 {
 	if (nr_addr_ranges >= MAX_ADDR_RANGES)
@@ -666,10 +730,12 @@ static void walk_addr_ranges(void)
 		add_addr_range(0, ULONG_MAX);
 
 	for (i = 0; i < nr_addr_ranges; i++)
-		if (!opt_pid)
-			walk_pfn(0, opt_offset[i], opt_size[i], 0);
-		else
+		if (opt_pid)
 			walk_task(opt_offset[i], opt_size[i]);
+		else if (opt_file)
+			walk_file(opt_offset[i], opt_size[i]);
+		else
+			walk_pfn(0, opt_offset[i], opt_size[i], 0);
 
 	close(kpageflags_fd);
 }
@@ -699,9 +765,7 @@ static void usage(void)
 "            -a|--addr    addr-spec     Walk a range of pages\n"
 "            -b|--bits    bits-spec     Walk pages with specified bits\n"
 "            -p|--pid     pid           Walk process address space\n"
-#if 0 /* planned features */
 "            -f|--file    filename      Walk file address space\n"
-#endif
 "            -l|--list                  Show page details in ranges\n"
 "            -L|--list-each             Show page details one by one\n"
 "            -N|--no-summary            Don't show summary info\n"
@@ -801,6 +865,18 @@ static void parse_pid(const char *str)
 
 static void parse_file(const char *name)
 {
+	int ret;
+	kpagecache_path = (char *)name;
+	kpagecache_fd = checked_open(PROC_KPAGECACHE, O_RDWR);
+	ret = write(kpagecache_fd, name, strlen(name));
+	if (ret != (int)strlen(name))
+		fatal("Failed to set file on %s\n", PROC_KPAGECACHE);
+}
+
+static void close_kpagecache(void)
+{
+	write(kpagecache_fd, NULL, 1);
+	close(kpagecache_fd);
 }
 
 static void parse_addr_range(const char *optarg)
@@ -953,6 +1029,7 @@ int main(int argc, char *argv[])
 			break;
 		case 'f':
 			parse_file(optarg);
+			opt_file = 1;
 			break;
 		case 'a':
 			parse_addr_range(optarg);
@@ -989,18 +1066,26 @@ int main(int argc, char *argv[])
 		}
 	}
 
-	if (opt_list && opt_pid)
-		printf("voffset\t");
-	if (opt_list == 1)
-		printf("offset\tlen\tflags\n");
-	if (opt_list == 2)
-		printf("offset\tflags\n");
+	if (opt_pid || !opt_file) {
+		if (opt_pid)
+			printf("voffset\t");
+		if (opt_list == 1)
+			printf("offset\tlen\tflags\n");
+		if (opt_list == 2)
+			printf("offset\tflags\n");
+	} else {
+		if (opt_list)
+			printf("pgoff\tpfn\ttags\tflags\n");
+	}
 
 	walk_addr_ranges();
 
 	if (opt_list == 1)
 		show_page_range(0, 0, 0);  /* drain the buffer */
 
+	if (opt_file == 1)
+		close_kpagecache();
+
 	if (opt_no_summary)
 		return 0;
 
-- 
1.8.5.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

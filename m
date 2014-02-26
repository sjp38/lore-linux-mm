Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lb0-f176.google.com (mail-lb0-f176.google.com [209.85.217.176])
	by kanga.kvack.org (Postfix) with ESMTP id D10F56B0073
	for <linux-mm@kvack.org>; Wed, 26 Feb 2014 02:57:28 -0500 (EST)
Received: by mail-lb0-f176.google.com with SMTP id 10so351434lbg.21
        for <linux-mm@kvack.org>; Tue, 25 Feb 2014 23:57:28 -0800 (PST)
Received: from mail-la0-x229.google.com (mail-la0-x229.google.com [2a00:1450:4010:c03::229])
        by mx.google.com with ESMTPS id x2si96036lad.177.2014.02.25.23.57.26
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Tue, 25 Feb 2014 23:57:27 -0800 (PST)
Received: by mail-la0-f41.google.com with SMTP id gl10so356249lab.14
        for <linux-mm@kvack.org>; Tue, 25 Feb 2014 23:57:26 -0800 (PST)
Subject: [PATCH] tools/vm/page-types.c: page-cache sniffing feature
From: Konstantin Khlebnikov <koct9i@gmail.com>
Date: Wed, 26 Feb 2014 11:57:23 +0400
Message-ID: <20140226075723.29820.26427.stgit@zurg>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org
Cc: acme@redhat.com, akpm@linux-foundation.org, fengguang.wu@intel.com, bp@suse.de

After this patch 'page-types' can walk on filesystem mappings and analize
populated page cache pages mostly without disturbing its state.

It maps chunk of file, marks VMA as MADV_RANDOM to turn off readahead,
pokes VMA via mincore() to determine cached pages, triggers page-fault
only for them, and finally gathers information via pagemap/kpageflags.
Before unmap it marks VMA as MADV_SEQUENTIAL for ignoring reference bits.

usage: page-types -f <path>

If <path> is directory it will analyse all files in all subdirectories.

Symlinks are not followed as well as mount points. Hardlinks aren't handled,
they'll be dumbed as many times as they are found. Recursive walk brings all
dentries into dcache and populates page cache of block-devices aka 'Buffers'.

Probably it's worth to add ioctl for dumping file page cache as array of PFNs
as a replacement for this hackish juggling with mmap/madvise/mincore/pagemap.
Also recursive walk could be replaced with dumping cached inodes via some ioctl
or debugfs interface followed by openning them via open_by_handle_at, this
would fix hardlinks handling and unneeded population of dcache and buffers.
This interface might be used as data source for constructing readahead plans
and for background optimizations of actively used files.

collateral changes:
+ fix 64-bit LFS: define _FILE_OFFSET_BITS instead of _LARGEFILE64_SOURCE
+ replace lseek + read with single pread
+ make show_page_range() reusable after flush

usage example:

~/src/linux/tools/vm$ sudo ./page-types -L -f page-types
foffset	offset	flags
page-types	Inode: 2229277	Size: 89065 (22 pages)
Modify: Tue Feb 25 12:00:59 2014 (162 seconds ago)
Access: Tue Feb 25 12:01:00 2014 (161 seconds ago)
0	3cbf3b	__RU_lA____M________________________
1	38946a	__RU_lA____M________________________
2	1a3cec	__RU_lA____M________________________
3	1a8321	__RU_lA____M________________________
4	3af7cc	__RU_lA____M________________________
5	1ed532	__RU_lA_____________________________
6	2e436a	__RU_lA_____________________________
7	29a35e	___U_lA_____________________________
8	2de86e	___U_lA_____________________________
9	3bdfb4	___U_lA_____________________________
10	3cd8a3	___U_lA_____________________________
11	2afa50	___U_lA_____________________________
12	2534c2	___U_lA_____________________________
13	1b7a40	___U_lA_____________________________
14	17b0be	___U_lA_____________________________
15	392b0c	___U_lA_____________________________
16	3ba46a	__RU_lA_____________________________
17	397dc8	___U_lA_____________________________
18	1f2a36	___U_lA_____________________________
19	21fd30	__RU_lA_____________________________
20	2c35ba	__RU_l______________________________
21	20f181	__RU_l______________________________


             flags	page-count       MB  symbolic-flags			long-symbolic-flags
0x000000000000002c	         2        0  __RU_l______________________________	referenced,uptodate,lru
0x0000000000000068	        11        0  ___U_lA_____________________________	uptodate,lru,active
0x000000000000006c	         4        0  __RU_lA_____________________________	referenced,uptodate,lru,active
0x000000000000086c	         5        0  __RU_lA____M________________________	referenced,uptodate,lru,active,mmap
             total	        22        0



~/src/linux/tools/vm$ sudo ./page-types -f /
             flags	page-count       MB  symbolic-flags			long-symbolic-flags
0x0000000000000028	     21761       85  ___U_l______________________________	uptodate,lru
0x000000000000002c	    127279      497  __RU_l______________________________	referenced,uptodate,lru
0x0000000000000068	     74160      289  ___U_lA_____________________________	uptodate,lru,active
0x000000000000006c	     84469      329  __RU_lA_____________________________	referenced,uptodate,lru,active
0x000000000000007c	         1        0  __RUDlA_____________________________	referenced,uptodate,dirty,lru,active
0x0000000000000228	       370        1  ___U_l___I__________________________	uptodate,lru,reclaim
0x0000000000000828	        49        0  ___U_l_____M________________________	uptodate,lru,mmap
0x000000000000082c	       126        0  __RU_l_____M________________________	referenced,uptodate,lru,mmap
0x0000000000000868	       137        0  ___U_lA____M________________________	uptodate,lru,active,mmap
0x000000000000086c	     12890       50  __RU_lA____M________________________	referenced,uptodate,lru,active,mmap
             total	    321242     1254

Signed-off-by: Konstantin Khlebnikov <koct9i@gmail.com>
---
 tools/vm/page-types.c |  170 ++++++++++++++++++++++++++++++++++++++++++++-----
 1 file changed, 152 insertions(+), 18 deletions(-)

diff --git a/tools/vm/page-types.c b/tools/vm/page-types.c
index f9be24d..05654f5 100644
--- a/tools/vm/page-types.c
+++ b/tools/vm/page-types.c
@@ -19,7 +19,8 @@
  * Authors: Wu Fengguang <fengguang.wu@intel.com>
  */
 
-#define _LARGEFILE64_SOURCE
+#define _FILE_OFFSET_BITS 64
+#define _GNU_SOURCE
 #include <stdio.h>
 #include <stdlib.h>
 #include <unistd.h>
@@ -29,11 +30,14 @@
 #include <getopt.h>
 #include <limits.h>
 #include <assert.h>
+#include <ftw.h>
+#include <time.h>
 #include <sys/types.h>
 #include <sys/errno.h>
 #include <sys/fcntl.h>
 #include <sys/mount.h>
 #include <sys/statfs.h>
+#include <sys/mman.h>
 #include "../../include/uapi/linux/magic.h"
 #include "../../include/uapi/linux/kernel-page-flags.h"
 #include <api/fs/debugfs.h>
@@ -158,6 +162,7 @@ static int		opt_raw;	/* for kernel developers */
 static int		opt_list;	/* list pages (in ranges) */
 static int		opt_no_summary;	/* don't show summary */
 static pid_t		opt_pid;	/* process to walk */
+const char *		opt_file;
 
 #define MAX_ADDR_RANGES	1024
 static int		nr_addr_ranges;
@@ -253,12 +258,7 @@ static unsigned long do_u64_read(int fd, char *name,
 	if (index > ULONG_MAX / 8)
 		fatal("index overflow: %lu\n", index);
 
-	if (lseek(fd, index * 8, SEEK_SET) < 0) {
-		perror(name);
-		exit(EXIT_FAILURE);
-	}
-
-	bytes = read(fd, buf, count * 8);
+	bytes = pread(fd, buf, count * 8, (off_t)index * 8);
 	if (bytes < 0) {
 		perror(name);
 		exit(EXIT_FAILURE);
@@ -343,8 +343,8 @@ static char *page_flag_longname(uint64_t flags)
  * page list and summary
  */
 
-static void show_page_range(unsigned long voffset,
-			    unsigned long offset, uint64_t flags)
+static void show_page_range(unsigned long voffset, unsigned long offset,
+			    unsigned long size, uint64_t flags)
 {
 	static uint64_t      flags0;
 	static unsigned long voff;
@@ -352,14 +352,16 @@ static void show_page_range(unsigned long voffset,
 	static unsigned long count;
 
 	if (flags == flags0 && offset == index + count &&
-	    (!opt_pid || voffset == voff + count)) {
-		count++;
+	    size && voffset == voff + count) {
+		count += size;
 		return;
 	}
 
 	if (count) {
 		if (opt_pid)
 			printf("%lx\t", voff);
+		if (opt_file)
+			printf("%lu\t", voff);
 		printf("%lx\t%lx\t%s\n",
 				index, count, page_flag_name(flags0));
 	}
@@ -367,7 +369,12 @@ static void show_page_range(unsigned long voffset,
 	flags0 = flags;
 	index  = offset;
 	voff   = voffset;
-	count  = 1;
+	count  = size;
+}
+
+static void flush_page_range(void)
+{
+	show_page_range(0, 0, 0, 0);
 }
 
 static void show_page(unsigned long voffset,
@@ -375,6 +382,8 @@ static void show_page(unsigned long voffset,
 {
 	if (opt_pid)
 		printf("%lx\t", voffset);
+	if (opt_file)
+		printf("%lu\t", voffset);
 	printf("%lx\t%s\n", offset, page_flag_name(flags));
 }
 
@@ -565,7 +574,7 @@ static void add_page(unsigned long voffset,
 		unpoison_page(offset);
 
 	if (opt_list == 1)
-		show_page_range(voffset, offset, flags);
+		show_page_range(voffset, offset, 1, flags);
 	else if (opt_list == 2)
 		show_page(voffset, offset, flags);
 
@@ -667,7 +676,7 @@ static void walk_addr_ranges(void)
 
 	for (i = 0; i < nr_addr_ranges; i++)
 		if (!opt_pid)
-			walk_pfn(0, opt_offset[i], opt_size[i], 0);
+			walk_pfn(opt_offset[i], opt_offset[i], opt_size[i], 0);
 		else
 			walk_task(opt_offset[i], opt_size[i]);
 
@@ -699,9 +708,7 @@ static void usage(void)
 "            -a|--addr    addr-spec     Walk a range of pages\n"
 "            -b|--bits    bits-spec     Walk pages with specified bits\n"
 "            -p|--pid     pid           Walk process address space\n"
-#if 0 /* planned features */
 "            -f|--file    filename      Walk file address space\n"
-#endif
 "            -l|--list                  Show page details in ranges\n"
 "            -L|--list-each             Show page details one by one\n"
 "            -N|--no-summary            Don't show summary info\n"
@@ -799,8 +806,130 @@ static void parse_pid(const char *str)
 	fclose(file);
 }
 
+static void show_file(const char *name, const struct stat *st)
+{
+	unsigned long long size = st->st_size;
+	char atime[64], mtime[64];
+	long now = time(NULL);
+
+	printf("%s\tInode: %u\tSize: %llu (%llu pages)\n",
+			name, (unsigned)st->st_ino,
+			size, (size + page_size - 1) / page_size);
+
+	strftime(atime, sizeof(atime), "%c", localtime(&st->st_atime));
+	strftime(mtime, sizeof(mtime), "%c", localtime(&st->st_mtime));
+
+	printf("Modify: %s (%ld seconds ago)\nAccess: %s (%ld seconds ago)\n",
+			mtime, now - st->st_mtime,
+			atime, now - st->st_atime);
+}
+
+static void walk_file(const char *name, const struct stat *st)
+{
+	uint8_t vec[PAGEMAP_BATCH];
+	uint64_t buf[PAGEMAP_BATCH], flags;
+	unsigned long nr_pages, pfn, i;
+	int fd;
+	off_t off;
+	ssize_t len;
+	void *ptr;
+	int first = 1;
+
+	fd = checked_open(name, O_RDONLY|O_NOATIME|O_NOFOLLOW);
+
+	for (off = 0; off < st->st_size; off += len) {
+		nr_pages = (st->st_size - off + page_size - 1) / page_size;
+		if (nr_pages > PAGEMAP_BATCH)
+			nr_pages = PAGEMAP_BATCH;
+		len = nr_pages * page_size;
+
+		ptr = mmap(NULL, len, PROT_READ, MAP_SHARED, fd, off);
+		if (ptr == MAP_FAILED)
+			fatal("mmap failed: %s", name);
+
+		/* determine cached pages */
+		if (mincore(ptr, len, vec))
+			fatal("mincore failed: %s", name);
+
+		/* turn off readahead */
+		if (madvise(ptr, len, MADV_RANDOM))
+			fatal("madvice failed: %s", name);
+
+		/* populate ptes */
+		for (i = 0; i < nr_pages ; i++) {
+			if (vec[i] & 1)
+				(void)*(volatile int *)(ptr + i * page_size);
+		}
+
+		/* turn off harvesting reference bits */
+		if (madvise(ptr, len, MADV_SEQUENTIAL))
+			fatal("madvice failed: %s", name);
+
+		if (pagemap_read(buf, (unsigned long)ptr / page_size,
+					nr_pages) != nr_pages)
+			fatal("cannot read pagemap");
+
+		munmap(ptr, len);
+
+		for (i = 0; i < nr_pages; i++) {
+			pfn = pagemap_pfn(buf[i]);
+			if (!pfn)
+				continue;
+			if (!kpageflags_read(&flags, pfn, 1))
+				continue;
+			if (first && opt_list) {
+				first = 0;
+				flush_page_range();
+				show_file(name, st);
+			}
+			add_page(off / page_size + i, pfn, flags, buf[i]);
+		}
+	}
+
+	close(fd);
+}
+
+int walk_tree(const char *name, const struct stat *st, int type, struct FTW *f)
+{
+	(void)f;
+	switch (type) {
+	case FTW_F:
+		if (S_ISREG(st->st_mode))
+			walk_file(name, st);
+		break;
+	case FTW_DNR:
+		fprintf(stderr, "cannot read dir: %s\n", name);
+		break;
+	}
+	return 0;
+}
+
+static void walk_page_cache(void)
+{
+	struct stat st;
+
+	kpageflags_fd = checked_open(PROC_KPAGEFLAGS, O_RDONLY);
+	pagemap_fd = checked_open("/proc/self/pagemap", O_RDONLY);
+
+	if (stat(opt_file, &st))
+		fatal("stat failed: %s\n", opt_file);
+
+	if (S_ISREG(st.st_mode)) {
+		walk_file(opt_file, &st);
+	} else if (S_ISDIR(st.st_mode)) {
+		/* do not follow symlinks and mountpoints */
+		if (nftw(opt_file, walk_tree, 64, FTW_MOUNT | FTW_PHYS) < 0)
+			fatal("nftw failed: %s\n", opt_file);
+	} else
+		fatal("unhandled file type: %s\n", opt_file);
+
+	close(kpageflags_fd);
+	close(pagemap_fd);
+}
+
 static void parse_file(const char *name)
 {
+	opt_file = name;
 }
 
 static void parse_addr_range(const char *optarg)
@@ -991,15 +1120,20 @@ int main(int argc, char *argv[])
 
 	if (opt_list && opt_pid)
 		printf("voffset\t");
+	if (opt_list && opt_file)
+		printf("foffset\t");
 	if (opt_list == 1)
 		printf("offset\tlen\tflags\n");
 	if (opt_list == 2)
 		printf("offset\tflags\n");
 
-	walk_addr_ranges();
+	if (opt_file)
+		walk_page_cache();
+	else
+		walk_addr_ranges();
 
 	if (opt_list == 1)
-		show_page_range(0, 0, 0);  /* drain the buffer */
+		flush_page_range();
 
 	if (opt_no_summary)
 		return 0;

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-la0-f43.google.com (mail-la0-f43.google.com [209.85.215.43])
	by kanga.kvack.org (Postfix) with ESMTP id EA4AD6B0038
	for <linux-mm@kvack.org>; Tue, 20 May 2014 22:27:16 -0400 (EDT)
Received: by mail-la0-f43.google.com with SMTP id mc6so1081580lab.16
        for <linux-mm@kvack.org>; Tue, 20 May 2014 19:27:16 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTP id js8si1942274lbc.9.2014.05.20.19.27.14
        for <linux-mm@kvack.org>;
        Tue, 20 May 2014 19:27:15 -0700 (PDT)
From: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Subject: [PATCH 3/4] tools/vm/page-types.c: rework on file cache scanning mode
Date: Tue, 20 May 2014 22:26:33 -0400
Message-Id: <1400639194-3743-4-git-send-email-n-horiguchi@ah.jp.nec.com>
In-Reply-To: <1400639194-3743-1-git-send-email-n-horiguchi@ah.jp.nec.com>
References: <1400639194-3743-1-git-send-email-n-horiguchi@ah.jp.nec.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org, linux-mm@kvack.org
Cc: Andrew Morton <akpm@linux-foundation.org>, Konstantin Khlebnikov <koct9i@gmail.com>, Wu Fengguang <fengguang.wu@intel.com>, Arnaldo Carvalho de Melo <acme@redhat.com>, Borislav Petkov <bp@alien8.de>

This patch reworks on the file cache scanning mode of page-types tool,
where when page-types is called with -f <filepath>, it can scan pages
in page cache tree of the specified file via /proc/kpagecache interface.

In the original implementation, it did mmap/madvise/mincore/pagemap over
page cache of the target file(s), so it gives us much measurement-disturbance.
This patch avoids this by using /proc/kpagecache.
And page-types does recursive walking when -f option specifies a directory,
which is too much, so let's keep it compact for code maintenability.
We can do the similar thing more flexibly for example by the following:

  find /tmp | \
      while read f ; do tools/vm/page-types -f $f ; done | \
      grep 0x | tr -s '\t' ' ' | awk '
    {
      label = $4;
      arr[label] = arr[label] + $2;
    }
    END {
      for ( a in arr ) {
        printf("%s %ld\n", a, arr[a]);
      }
    }
  '

This code gets page status summary of all files under /tmp, whose output
is like this:

  __RUDl________b_____________________ 2   # page count
  __RUDlA_______b_____________________ 4

ChangeLog:
- rebased onto v3.15-rc5 (resolved conflict with Konstantins patch
  commit 65a6a4105f "tools/vm/page-types.c: page-cache sniffing feature")

Signed-off-by: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
---
 tools/vm/page-types.c | 276 +++++++++++++++++++++-----------------------------
 1 file changed, 114 insertions(+), 162 deletions(-)

diff --git v3.15-rc5.orig/tools/vm/page-types.c v3.15-rc5/tools/vm/page-types.c
index 05654f5e48d5..a0fb55489ea7 100644
--- v3.15-rc5.orig/tools/vm/page-types.c
+++ v3.15-rc5/tools/vm/page-types.c
@@ -30,14 +30,12 @@
 #include <getopt.h>
 #include <limits.h>
 #include <assert.h>
-#include <ftw.h>
-#include <time.h>
 #include <sys/types.h>
 #include <sys/errno.h>
 #include <sys/fcntl.h>
 #include <sys/mount.h>
+#include <sys/stat.h>
 #include <sys/statfs.h>
-#include <sys/mman.h>
 #include "../../include/uapi/linux/magic.h"
 #include "../../include/uapi/linux/kernel-page-flags.h"
 #include <api/fs/debugfs.h>
@@ -79,6 +77,7 @@
 
 #define KPF_BYTES		8
 #define PROC_KPAGEFLAGS		"/proc/kpageflags"
+#define PROC_KPAGECACHE		"/proc/kpagecache"
 
 /* [32-] kernel hacking assistances */
 #define KPF_RESERVED		32
@@ -162,7 +161,7 @@ static int		opt_raw;	/* for kernel developers */
 static int		opt_list;	/* list pages (in ranges) */
 static int		opt_no_summary;	/* don't show summary */
 static pid_t		opt_pid;	/* process to walk */
-const char *		opt_file;
+static char		*opt_file;	/* walk over pagecache of file */
 
 #define MAX_ADDR_RANGES	1024
 static int		nr_addr_ranges;
@@ -183,6 +182,7 @@ static int		page_size;
 
 static int		pagemap_fd;
 static int		kpageflags_fd;
+static int		kpagecache_fd;
 
 static int		opt_hwpoison;
 static int		opt_unpoison;
@@ -276,6 +276,13 @@ static unsigned long kpageflags_read(uint64_t *buf,
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
@@ -338,53 +345,62 @@ static char *page_flag_longname(uint64_t flags)
 	return buf;
 }
 
+#define __NR_PAGECACHE_TAGS	3
+#define KPC_TAGS_BITS	__NR_PAGECACHE_TAGS
+#define KPC_TAGS_OFFSET	(64 - KPC_TAGS_BITS)
+#define KPC_TAGS_MASK	(((1ULL << KPC_TAGS_BITS) - 1) << KPC_TAGS_OFFSET)
+#define KPC_TAGS(entry)	((entry & KPC_TAGS_MASK) >> KPC_TAGS_OFFSET)
 
 /*
  * page list and summary
  */
 
-static void show_page_range(unsigned long voffset, unsigned long offset,
-			    unsigned long size, uint64_t flags)
+static void show_page_range(unsigned long voffset,
+			unsigned long offset, uint64_t flags, uint64_t entry)
 {
 	static uint64_t      flags0;
 	static unsigned long voff;
 	static unsigned long index;
 	static unsigned long count;
+	static uint64_t	     entry0;
 
 	if (flags == flags0 && offset == index + count &&
-	    size && voffset == voff + count) {
-		count += size;
+	    (!opt_pid || voffset == voff + count) &&
+	    (!opt_file || (voffset == voff + count && entry == entry0))) {
+		count++;
 		return;
 	}
 
 	if (count) {
 		if (opt_pid)
-			printf("%lx\t", voff);
-		if (opt_file)
-			printf("%lu\t", voff);
-		printf("%lx\t%lx\t%s\n",
-				index, count, page_flag_name(flags0));
+			printf("%lx\t%lx\t%lx\t%s\n",
+			       voff, index, count, page_flag_name(flags0));
+		else if (opt_file)
+			printf("%lx\t%lx\t%lx\t%llx\t%s\n",
+			       voff, index, count, KPC_TAGS(entry0), page_flag_name(flags0));
+		else
+			printf("%lx\t%lx\t%s\n",
+			       index, count, page_flag_name(flags0));
 	}
 
 	flags0 = flags;
 	index  = offset;
 	voff   = voffset;
-	count  = size;
-}
-
-static void flush_page_range(void)
-{
-	show_page_range(0, 0, 0, 0);
+	count  = 1;
+	entry0 = entry;
 }
 
 static void show_page(unsigned long voffset,
-		      unsigned long offset, uint64_t flags)
+		      unsigned long offset, uint64_t flags, uint64_t entry)
 {
 	if (opt_pid)
-		printf("%lx\t", voffset);
-	if (opt_file)
-		printf("%lu\t", voffset);
-	printf("%lx\t%s\n", offset, page_flag_name(flags));
+		printf("%lx\t%lx\t%s\n",
+		       voffset, offset, page_flag_name(flags));
+	else if (opt_file)
+		printf("%lx\t%lx\t%llx\t%s\n",
+		       voffset, offset, KPC_TAGS(entry), page_flag_name(flags));
+	else
+		printf("%lx\t%s\n", offset, page_flag_name(flags));
 }
 
 static void show_summary(void)
@@ -574,9 +590,9 @@ static void add_page(unsigned long voffset,
 		unpoison_page(offset);
 
 	if (opt_list == 1)
-		show_page_range(voffset, offset, 1, flags);
+		show_page_range(voffset, offset, flags, pme);
 	else if (opt_list == 2)
-		show_page(voffset, offset, flags);
+		show_page(voffset, offset, flags, pme);
 
 	nr_pages[hash_slot(flags)]++;
 	total_pages++;
@@ -655,6 +671,40 @@ static void walk_task(unsigned long index, unsigned long count)
 	}
 }
 
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
+	stat(opt_file, &kpagecache_stat);
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
@@ -675,10 +725,12 @@ static void walk_addr_ranges(void)
 		add_addr_range(0, ULONG_MAX);
 
 	for (i = 0; i < nr_addr_ranges; i++)
-		if (!opt_pid)
-			walk_pfn(opt_offset[i], opt_offset[i], opt_size[i], 0);
-		else
+		if (opt_pid)
 			walk_task(opt_offset[i], opt_size[i]);
+		else if (opt_file)
+			walk_file(opt_offset[i], opt_size[i]);
+		else
+			walk_pfn(0, opt_offset[i], opt_size[i], 0);
 
 	close(kpageflags_fd);
 }
@@ -806,130 +858,21 @@ static void parse_pid(const char *str)
 	fclose(file);
 }
 
-static void show_file(const char *name, const struct stat *st)
-{
-	unsigned long long size = st->st_size;
-	char atime[64], mtime[64];
-	long now = time(NULL);
-
-	printf("%s\tInode: %u\tSize: %llu (%llu pages)\n",
-			name, (unsigned)st->st_ino,
-			size, (size + page_size - 1) / page_size);
-
-	strftime(atime, sizeof(atime), "%c", localtime(&st->st_atime));
-	strftime(mtime, sizeof(mtime), "%c", localtime(&st->st_mtime));
-
-	printf("Modify: %s (%ld seconds ago)\nAccess: %s (%ld seconds ago)\n",
-			mtime, now - st->st_mtime,
-			atime, now - st->st_atime);
-}
-
-static void walk_file(const char *name, const struct stat *st)
-{
-	uint8_t vec[PAGEMAP_BATCH];
-	uint64_t buf[PAGEMAP_BATCH], flags;
-	unsigned long nr_pages, pfn, i;
-	int fd;
-	off_t off;
-	ssize_t len;
-	void *ptr;
-	int first = 1;
-
-	fd = checked_open(name, O_RDONLY|O_NOATIME|O_NOFOLLOW);
-
-	for (off = 0; off < st->st_size; off += len) {
-		nr_pages = (st->st_size - off + page_size - 1) / page_size;
-		if (nr_pages > PAGEMAP_BATCH)
-			nr_pages = PAGEMAP_BATCH;
-		len = nr_pages * page_size;
-
-		ptr = mmap(NULL, len, PROT_READ, MAP_SHARED, fd, off);
-		if (ptr == MAP_FAILED)
-			fatal("mmap failed: %s", name);
-
-		/* determine cached pages */
-		if (mincore(ptr, len, vec))
-			fatal("mincore failed: %s", name);
-
-		/* turn off readahead */
-		if (madvise(ptr, len, MADV_RANDOM))
-			fatal("madvice failed: %s", name);
-
-		/* populate ptes */
-		for (i = 0; i < nr_pages ; i++) {
-			if (vec[i] & 1)
-				(void)*(volatile int *)(ptr + i * page_size);
-		}
-
-		/* turn off harvesting reference bits */
-		if (madvise(ptr, len, MADV_SEQUENTIAL))
-			fatal("madvice failed: %s", name);
-
-		if (pagemap_read(buf, (unsigned long)ptr / page_size,
-					nr_pages) != nr_pages)
-			fatal("cannot read pagemap");
-
-		munmap(ptr, len);
-
-		for (i = 0; i < nr_pages; i++) {
-			pfn = pagemap_pfn(buf[i]);
-			if (!pfn)
-				continue;
-			if (!kpageflags_read(&flags, pfn, 1))
-				continue;
-			if (first && opt_list) {
-				first = 0;
-				flush_page_range();
-				show_file(name, st);
-			}
-			add_page(off / page_size + i, pfn, flags, buf[i]);
-		}
-	}
-
-	close(fd);
-}
-
-int walk_tree(const char *name, const struct stat *st, int type, struct FTW *f)
-{
-	(void)f;
-	switch (type) {
-	case FTW_F:
-		if (S_ISREG(st->st_mode))
-			walk_file(name, st);
-		break;
-	case FTW_DNR:
-		fprintf(stderr, "cannot read dir: %s\n", name);
-		break;
-	}
-	return 0;
-}
-
-static void walk_page_cache(void)
+static void parse_file(const char *name)
 {
-	struct stat st;
-
-	kpageflags_fd = checked_open(PROC_KPAGEFLAGS, O_RDONLY);
-	pagemap_fd = checked_open("/proc/self/pagemap", O_RDONLY);
-
-	if (stat(opt_file, &st))
-		fatal("stat failed: %s\n", opt_file);
-
-	if (S_ISREG(st.st_mode)) {
-		walk_file(opt_file, &st);
-	} else if (S_ISDIR(st.st_mode)) {
-		/* do not follow symlinks and mountpoints */
-		if (nftw(opt_file, walk_tree, 64, FTW_MOUNT | FTW_PHYS) < 0)
-			fatal("nftw failed: %s\n", opt_file);
-	} else
-		fatal("unhandled file type: %s\n", opt_file);
-
-	close(kpageflags_fd);
-	close(pagemap_fd);
+	int ret;
+	opt_file = (char *)name;
+	kpagecache_fd = checked_open(PROC_KPAGECACHE, O_RDWR);
+	ret = write(kpagecache_fd, name, strlen(name));
+	if (ret != (int)strlen(name))
+		fatal("Failed to set file on %s\n", PROC_KPAGECACHE);
 }
 
-static void parse_file(const char *name)
+static void close_kpagecache(void)
 {
-	opt_file = name;
+	/* Reset in-kernel configuration. */
+	write(kpagecache_fd, NULL, 1);
+	close(kpagecache_fd);
 }
 
 static void parse_addr_range(const char *optarg)
@@ -1118,22 +1061,31 @@ int main(int argc, char *argv[])
 		}
 	}
 
-	if (opt_list && opt_pid)
-		printf("voffset\t");
-	if (opt_list && opt_file)
-		printf("foffset\t");
-	if (opt_list == 1)
-		printf("offset\tlen\tflags\n");
-	if (opt_list == 2)
-		printf("offset\tflags\n");
+	if (opt_pid && opt_file) {
+		fprintf(stderr,
+		"Option -p and -f are mutually exclusive. Don't set both.\n");
+		exit(1);
+	}
 
-	if (opt_file)
-		walk_page_cache();
-	else
-		walk_addr_ranges();
+	if (opt_pid) {
+		if (opt_list == 1)
+			printf("voffset\toffset\tlen\tflags\n");
+		if (opt_list == 2)
+			printf("voffset\toffset\tflags\n");
+	} else if (opt_file) {
+		if (opt_list == 1)
+			printf("voffset\toffset\tlen\ttag\tflags\n");
+		if (opt_list == 2)
+			printf("voffset\toffset\ttag\tflags\n");
+	}
+
+	walk_addr_ranges();
 
 	if (opt_list == 1)
-		flush_page_range();
+		show_page_range(0, 0, 0, 0);  /* drain the buffer */
+
+	if (opt_file)
+		close_kpagecache();
 
 	if (opt_no_summary)
 		return 0;
-- 
1.9.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

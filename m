Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lb0-f178.google.com (mail-lb0-f178.google.com [209.85.217.178])
	by kanga.kvack.org (Postfix) with ESMTP id 43E94440441
	for <linux-mm@kvack.org>; Sat,  6 Feb 2016 05:06:37 -0500 (EST)
Received: by mail-lb0-f178.google.com with SMTP id cw1so61704030lbb.1
        for <linux-mm@kvack.org>; Sat, 06 Feb 2016 02:06:37 -0800 (PST)
Received: from mail-lb0-x231.google.com (mail-lb0-x231.google.com. [2a00:1450:4010:c04::231])
        by mx.google.com with ESMTPS id a127si11635368lfe.86.2016.02.06.02.06.35
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sat, 06 Feb 2016 02:06:35 -0800 (PST)
Received: by mail-lb0-x231.google.com with SMTP id cw1so61703901lbb.1
        for <linux-mm@kvack.org>; Sat, 06 Feb 2016 02:06:35 -0800 (PST)
Subject: [PATCH] tools/vm/page-types.c: add memory cgroup dumping and
 filtering
From: Konstantin Khlebnikov <koct9i@gmail.com>
Date: Sat, 06 Feb 2016 13:06:29 +0300
Message-ID: <145475318946.9321.5193007062423922667.stgit@zurg>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Cc: Vladimir Davydov <vdavydov@virtuozzo.com>, linux-kernel@vger.kernel.org

This adds two command line keys:

 -c|--cgroup path|@inode	Walk only pages owned by this memory cgroup
 -C|--list-cgroup		Show memory cgroup inodes

Signed-off-by: Konstantin Khlebnikov <koct9i@gmail.com>
---
 tools/vm/page-types.c |   92 ++++++++++++++++++++++++++++++++++++++++++-------
 1 file changed, 79 insertions(+), 13 deletions(-)

diff --git a/tools/vm/page-types.c b/tools/vm/page-types.c
index 5a6016224bb9..a444741fa95d 100644
--- a/tools/vm/page-types.c
+++ b/tools/vm/page-types.c
@@ -73,6 +73,7 @@
 
 #define KPF_BYTES		8
 #define PROC_KPAGEFLAGS		"/proc/kpageflags"
+#define PROC_KPAGECGROUP	"/proc/kpagecgroup"
 
 /* [32-] kernel hacking assistances */
 #define KPF_RESERVED		32
@@ -164,7 +165,9 @@ static int		opt_raw;	/* for kernel developers */
 static int		opt_list;	/* list pages (in ranges) */
 static int		opt_no_summary;	/* don't show summary */
 static pid_t		opt_pid;	/* process to walk */
-const char *		opt_file;
+const char *		opt_file;	/* file or directory path */
+static int64_t		opt_cgroup = -1;/* cgroup inode */
+static int		opt_list_cgroup;/* list page cgroup */
 
 #define MAX_ADDR_RANGES	1024
 static int		nr_addr_ranges;
@@ -185,6 +188,7 @@ static int		page_size;
 
 static int		pagemap_fd;
 static int		kpageflags_fd;
+static int		kpagecgroup_fd = -1;
 
 static int		opt_hwpoison;
 static int		opt_unpoison;
@@ -278,6 +282,16 @@ static unsigned long kpageflags_read(uint64_t *buf,
 	return do_u64_read(kpageflags_fd, PROC_KPAGEFLAGS, buf, index, pages);
 }
 
+static unsigned long kpagecgroup_read(uint64_t *buf,
+				      unsigned long index,
+				      unsigned long pages)
+{
+	if (kpagecgroup_fd < 0)
+		return pages;
+
+	return do_u64_read(kpagecgroup_fd, PROC_KPAGEFLAGS, buf, index, pages);
+}
+
 static unsigned long pagemap_read(uint64_t *buf,
 				  unsigned long index,
 				  unsigned long pages)
@@ -346,14 +360,15 @@ static char *page_flag_longname(uint64_t flags)
  */
 
 static void show_page_range(unsigned long voffset, unsigned long offset,
-			    unsigned long size, uint64_t flags)
+			    unsigned long size, uint64_t flags, uint64_t cgroup)
 {
 	static uint64_t      flags0;
+	static uint64_t	     cgroup0;
 	static unsigned long voff;
 	static unsigned long index;
 	static unsigned long count;
 
-	if (flags == flags0 && offset == index + count &&
+	if (flags == flags0 && cgroup == cgroup0 && offset == index + count &&
 	    size && voffset == voff + count) {
 		count += size;
 		return;
@@ -364,11 +379,14 @@ static void show_page_range(unsigned long voffset, unsigned long offset,
 			printf("%lx\t", voff);
 		if (opt_file)
 			printf("%lu\t", voff);
+		if (opt_list_cgroup)
+			printf("@%llu\t", (unsigned long long)cgroup0);
 		printf("%lx\t%lx\t%s\n",
 				index, count, page_flag_name(flags0));
 	}
 
 	flags0 = flags;
+	cgroup0= cgroup;
 	index  = offset;
 	voff   = voffset;
 	count  = size;
@@ -376,16 +394,18 @@ static void show_page_range(unsigned long voffset, unsigned long offset,
 
 static void flush_page_range(void)
 {
-	show_page_range(0, 0, 0, 0);
+	show_page_range(0, 0, 0, 0, 0);
 }
 
-static void show_page(unsigned long voffset,
-		      unsigned long offset, uint64_t flags)
+static void show_page(unsigned long voffset, unsigned long offset,
+		      uint64_t flags, uint64_t cgroup)
 {
 	if (opt_pid)
 		printf("%lx\t", voffset);
 	if (opt_file)
 		printf("%lu\t", voffset);
+	if (opt_list_cgroup)
+		printf("@%llu\t", (unsigned long long)cgroup);
 	printf("%lx\t%s\n", offset, page_flag_name(flags));
 }
 
@@ -566,23 +586,26 @@ static size_t hash_slot(uint64_t flags)
 	exit(EXIT_FAILURE);
 }
 
-static void add_page(unsigned long voffset,
-		     unsigned long offset, uint64_t flags, uint64_t pme)
+static void add_page(unsigned long voffset, unsigned long offset,
+		     uint64_t flags, uint64_t cgroup, uint64_t pme)
 {
 	flags = kpageflags_flags(flags, pme);
 
 	if (!bit_mask_ok(flags))
 		return;
 
+	if (opt_cgroup >= 0 && cgroup != (uint64_t)opt_cgroup)
+		return;
+
 	if (opt_hwpoison)
 		hwpoison_page(offset);
 	if (opt_unpoison)
 		unpoison_page(offset);
 
 	if (opt_list == 1)
-		show_page_range(voffset, offset, 1, flags);
+		show_page_range(voffset, offset, 1, flags, cgroup);
 	else if (opt_list == 2)
-		show_page(voffset, offset, flags);
+		show_page(voffset, offset, flags, cgroup);
 
 	nr_pages[hash_slot(flags)]++;
 	total_pages++;
@@ -595,18 +618,24 @@ static void walk_pfn(unsigned long voffset,
 		     uint64_t pme)
 {
 	uint64_t buf[KPAGEFLAGS_BATCH];
+	uint64_t cgi[KPAGEFLAGS_BATCH];
 	unsigned long batch;
 	unsigned long pages;
 	unsigned long i;
 
+	memset(cgi, 0, sizeof cgi);
+
 	while (count) {
 		batch = min_t(unsigned long, count, KPAGEFLAGS_BATCH);
 		pages = kpageflags_read(buf, index, batch);
 		if (pages == 0)
 			break;
 
+		if (kpagecgroup_read(cgi, index, pages) != pages)
+			fatal("kpagecgroup returned fewer pages than expected");
+
 		for (i = 0; i < pages; i++)
-			add_page(voffset + i, index + i, buf[i], pme);
+			add_page(voffset + i, index + i, buf[i], cgi[i], pme);
 
 		index += pages;
 		count -= pages;
@@ -713,10 +742,12 @@ static void usage(void)
 "            -d|--describe flags        Describe flags\n"
 "            -a|--addr    addr-spec     Walk a range of pages\n"
 "            -b|--bits    bits-spec     Walk pages with specified bits\n"
+"            -c|--cgroup  path|@inode   Walk pages within memory cgroup\n"
 "            -p|--pid     pid           Walk process address space\n"
 "            -f|--file    filename      Walk file address space\n"
 "            -l|--list                  Show page details in ranges\n"
 "            -L|--list-each             Show page details one by one\n"
+"            -C|--list-cgroup           Show cgroup inode for pages\n"
 "            -N|--no-summary            Don't show summary info\n"
 "            -X|--hwpoison              hwpoison pages\n"
 "            -x|--unpoison              unpoison pages\n"
@@ -851,6 +882,7 @@ static void walk_file(const char *name, const struct stat *st)
 {
 	uint8_t vec[PAGEMAP_BATCH];
 	uint64_t buf[PAGEMAP_BATCH], flags;
+	uint64_t cgroup = 0;
 	unsigned long nr_pages, pfn, i;
 	off_t off, end = st->st_size;
 	int fd;
@@ -908,12 +940,15 @@ got_sigbus:
 				continue;
 			if (!kpageflags_read(&flags, pfn, 1))
 				continue;
+			if (!kpagecgroup_read(&cgroup, pfn, 1))
+				fatal("kpagecgroup_read failed");
 			if (first && opt_list) {
 				first = 0;
 				flush_page_range();
 				show_file(name, st);
 			}
-			add_page(off / page_size + i, pfn, flags, buf[i]);
+			add_page(off / page_size + i, pfn,
+				 flags, cgroup, buf[i]);
 		}
 	}
 
@@ -965,6 +1000,24 @@ static void parse_file(const char *name)
 	opt_file = name;
 }
 
+static void parse_cgroup(const char *path)
+{
+	if (path[0] == '@') {
+		opt_cgroup = parse_number(path + 1);
+		return;
+	}
+
+	struct stat st;
+
+	if (stat(path, &st))
+		fatal("stat failed: %s: %m\n", path);
+
+	if (!S_ISDIR(st.st_mode))
+		fatal("cgroup supposed to be a directory: %s\n", path);
+
+	opt_cgroup = st.st_ino;
+}
+
 static void parse_addr_range(const char *optarg)
 {
 	unsigned long offset;
@@ -1088,9 +1141,11 @@ static const struct option opts[] = {
 	{ "file"      , 1, NULL, 'f' },
 	{ "addr"      , 1, NULL, 'a' },
 	{ "bits"      , 1, NULL, 'b' },
+	{ "cgroup"    , 1, NULL, 'c' },
 	{ "describe"  , 1, NULL, 'd' },
 	{ "list"      , 0, NULL, 'l' },
 	{ "list-each" , 0, NULL, 'L' },
+	{ "list-cgroup", 0, NULL, 'C' },
 	{ "no-summary", 0, NULL, 'N' },
 	{ "hwpoison"  , 0, NULL, 'X' },
 	{ "unpoison"  , 0, NULL, 'x' },
@@ -1105,7 +1160,7 @@ int main(int argc, char *argv[])
 	page_size = getpagesize();
 
 	while ((c = getopt_long(argc, argv,
-				"rp:f:a:b:d:lLNXxh", opts, NULL)) != -1) {
+				"rp:f:a:b:d:c:ClLNXxh", opts, NULL)) != -1) {
 		switch (c) {
 		case 'r':
 			opt_raw = 1;
@@ -1122,6 +1177,12 @@ int main(int argc, char *argv[])
 		case 'b':
 			parse_bits_mask(optarg);
 			break;
+		case 'c':
+			parse_cgroup(optarg);
+			break;
+		case 'C':
+			opt_list_cgroup = 1;
+			break;
 		case 'd':
 			describe_flags(optarg);
 			exit(0);
@@ -1151,10 +1212,15 @@ int main(int argc, char *argv[])
 		}
 	}
 
+	if (opt_cgroup >= 0 || opt_list_cgroup)
+		kpagecgroup_fd = checked_open(PROC_KPAGECGROUP, O_RDONLY);
+
 	if (opt_list && opt_pid)
 		printf("voffset\t");
 	if (opt_list && opt_file)
 		printf("foffset\t");
+	if (opt_list && opt_list_cgroup)
+		printf("cgroup\t");
 	if (opt_list == 1)
 		printf("offset\tlen\tflags\n");
 	if (opt_list == 2)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

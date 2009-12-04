Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id 338876B003D
	for <linux-mm@kvack.org>; Fri,  4 Dec 2009 16:30:48 -0500 (EST)
Subject: [PATCH] page-types: kernel pageflags mode
From: Alex Chiang <achiang@hp.com>
Date: Fri, 04 Dec 2009 14:29:48 -0700
Message-ID: <20091204212606.29258.98531.stgit@bob.kio>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: akpm@linux-foundation.org
Cc: Haicheng Li <haicheng.li@intel.com>, Randy Dunlap <randy.dunlap@oracle.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Andi Kleen <andi@firstfloor.org>, fengguang.wu@intel.com
List-ID: <linux-mm.kvack.org>

An earlier commit taught page-types the -d|--describe argument, which
allows the user to describe page flags passed on the command line:

  # ./Documentation/vm/page-types -d 0x4000
  0x0000000000004000  ______________b___________________  swapbacked

In -d mode, page-types expects the page flag bits in the order generated
by the kernel function get_uflags().

However, those bits are rearranged compared to what is actually stored
in struct page->flags. A kernel developer dumping a page's flags
using printk, e.g., may get misleading results in -d mode.

Teach page-types the -k mode, which parses and describes the bits in
the internal kernel order:

  # ./Documentation/vm/page-types -k 0x4000
  0x0000000000004000  ______________H_________  compound_head

Note that the recommended way to build page-types is from the top-level
kernel source directory. This ensures that it will get the same CONFIG_*
defines used to build the kernel source.

  # make Documentation/vm/

The implication is that attempting to use page-types -k on a kernel
with different CONFIG_* settings may lead to surprising and misleading
results. To retain sanity, always use the page-types built out of the
kernel tree you are actually testing.

Cc: fengguang.wu@intel.com
Cc: Haicheng Li <haicheng.li@intel.com>
Cc: Andi Kleen <andi@firstfloor.org>
Cc: Randy Dunlap <randy.dunlap@oracle.com>
Signed-off-by: Alex Chiang <achiang@hp.com>
---

Applies on top of mmotm.

 Documentation/vm/Makefile     |    2 +
 Documentation/vm/page-types.c |  117 +++++++++++++++++++++++++++++++++++++++--
 2 files changed, 113 insertions(+), 6 deletions(-)

diff --git a/Documentation/vm/Makefile b/Documentation/vm/Makefile
index 5bd269b..1bebc43 100644
--- a/Documentation/vm/Makefile
+++ b/Documentation/vm/Makefile
@@ -1,6 +1,8 @@
 # kbuild trick to avoid linker error. Can be omitted if a module is built.
 obj- := dummy.o
 
+HOSTCFLAGS_page-types.o += $(LINUXINCLUDE)
+
 # List of programs to build
 hostprogs-y := slabinfo page-types
 
diff --git a/Documentation/vm/page-types.c b/Documentation/vm/page-types.c
index 7a7d9ba..b0f129c 100644
--- a/Documentation/vm/page-types.c
+++ b/Documentation/vm/page-types.c
@@ -100,7 +100,7 @@
 #define BIT(name)		(1ULL << KPF_##name)
 #define BITS_COMPOUND		(BIT(COMPOUND_HEAD) | BIT(COMPOUND_TAIL))
 
-static const char *page_flag_names[] = {
+static const char *page_flag_names_proc[] = {
 	[KPF_LOCKED]		= "L:locked",
 	[KPF_ERROR]		= "E:error",
 	[KPF_REFERENCED]	= "R:referenced",
@@ -140,6 +140,103 @@ static const char *page_flag_names[] = {
 	[KPF_SLUB_DEBUG]	= "E:slub_debug",
 };
 
+enum pageflags {
+	PG_locked,              /* Page is locked. Don't touch. */
+	PG_error,
+	PG_referenced,
+	PG_uptodate,
+	PG_dirty,
+	PG_lru,
+	PG_active,
+	PG_slab,
+	PG_owner_priv_1,        /* Owner use. If pagecache, fs may use*/
+	PG_arch_1,
+	PG_reserved,
+	PG_private,             /* If pagecache, has fs-private data */
+	PG_private_2,           /* If pagecache, has fs aux data */
+	PG_writeback,           /* Page is under writeback */
+#ifdef CONFIG_PAGEFLAGS_EXTENDED
+	PG_head,                /* A head page */
+	PG_tail,                /* A tail page */
+#else
+	PG_compound,            /* A compound page */
+#endif
+	PG_swapcache,           /* Swap page: swp_entry_t in private */
+	PG_mappedtodisk,        /* Has blocks allocated on-disk */
+	PG_reclaim,             /* To be reclaimed asap */
+	PG_buddy,               /* Page is free, on buddy lists */
+	PG_swapbacked,          /* Page is backed by RAM/swap */
+	PG_unevictable,         /* Page is "unevictable"  */
+#ifdef CONFIG_MMU
+	PG_mlocked,             /* Page is vma mlocked */
+#endif
+#ifdef CONFIG_ARCH_USES_PG_UNCACHED
+	PG_uncached,            /* Page has been mapped as uncached */
+#endif
+#ifdef CONFIG_MEMORY_FAILURE
+	PG_hwpoison,            /* hardware poisoned page. Don't touch */
+#endif
+	__NR_PAGEFLAGS,
+
+	/* Filesystems */
+	PG_checked = PG_owner_priv_1,
+
+	/* Two page bits are conscripted by FS-Cache to maintain local caching
+	 * state.  These bits are set on pages belonging to the netfs's inodes
+	 * when those inodes are being locally cached.
+	 */
+	PG_fscache = PG_private_2,      /* page backed by cache */
+
+	/* XEN */
+	PG_pinned = PG_owner_priv_1,
+	PG_savepinned = PG_dirty,
+
+	/* SLOB */
+	PG_slob_free = PG_private,
+
+	/* SLUB */
+	PG_slub_frozen = PG_active,
+	PG_slub_debug = PG_error,
+};
+
+static const char *page_flag_names_kernel[] = {
+	[PG_locked]		= "L:locked",
+	[PG_error]		= "E:error",
+	[PG_referenced]		= "R:referenced",
+	[PG_uptodate]		= "U:uptodate",
+	[PG_dirty]		= "D:dirty",
+	[PG_lru]		= "l:lru",
+	[PG_active]		= "A:active",
+	[PG_slab]		= "S:slab",
+	[PG_owner_priv_1]	= "O:owner_private",
+	[PG_arch_1]		= "h:arch",
+	[PG_reserved]		= "r:reserved",
+	[PG_private]		= "P:private",
+	[PG_private_2]		= "p:private_2",
+	[PG_writeback]		= "W:writeback",
+#ifdef CONFIG_PAGEFLAGS_EXTENDED
+	[PG_head]		= "H:compound_head",
+	[PG_tail]		= "T:compound_tail",
+#else
+	[PG_compound]		= "C:compound",
+#endif
+	[PG_swapcache]		= "s:swapcache",
+	[PG_mappedtodisk]	= "d:mappedtodisk",
+	[PG_reclaim]		= "I:reclaim",
+	[PG_buddy]		= "B:buddy",
+	[PG_swapbacked]		= "b:swapbacked",
+	[PG_unevictable]	= "u:unevictable",
+#ifdef CONFIG_MMU
+	[PG_mlocked]		= "m:mlocked",
+#endif
+#ifdef CONFIG_ARCH_USES_PG_UNCACHED
+	[PG_uncached]		= "c:uncached",
+#endif
+#ifdef CONFIG_MEMORY_FAILURE
+	[PG_hwpoison]		= "X:hwpoison",
+#endif
+};
+
 
 /*
  * data structures
@@ -186,6 +283,8 @@ static unsigned long	total_pages;
 static unsigned long	nr_pages[HASH_SIZE];
 static uint64_t 	page_flags[HASH_SIZE];
 
+static char **page_flag_names = (char **)page_flag_names_proc;
+static int page_flag_nr = KPF_SLUB_DEBUG + 1;
 
 /*
  * helper functions
@@ -297,7 +396,7 @@ static char *page_flag_name(uint64_t flags)
 	int present;
 	int i, j;
 
-	for (i = 0, j = 0; i < ARRAY_SIZE(page_flag_names); i++) {
+	for (i = 0, j = 0; i < page_flag_nr; i++) {
 		present = (flags >> i) & 1;
 		if (!page_flag_names[i]) {
 			if (present)
@@ -315,7 +414,7 @@ static char *page_flag_longname(uint64_t flags)
 	static char buf[1024];
 	int i, n;
 
-	for (i = 0, n = 0; i < ARRAY_SIZE(page_flag_names); i++) {
+	for (i = 0, n = 0; i < page_flag_nr; i++) {
 		if (!page_flag_names[i])
 			continue;
 		if ((flags >> i) & 1)
@@ -675,6 +774,7 @@ static void usage(void)
 "page-types [options]\n"
 "            -r|--raw                   Raw mode, for kernel developers\n"
 "            -d|--describe flags        Describe flags\n"
+"            -k|--kernel describe flags Describe flags, kernel internal order\n"
 "            -a|--addr    addr-spec     Walk a range of pages\n"
 "            -b|--bits    bits-spec     Walk pages with specified bits\n"
 "            -p|--pid     pid           Walk process address space\n"
@@ -705,7 +805,7 @@ static void usage(void)
 "bit-names:\n"
 	);
 
-	for (i = 0, j = 0; i < ARRAY_SIZE(page_flag_names); i++) {
+	for (i = 0, j = 0; i < page_flag_nr; i++) {
 		if (!page_flag_names[i])
 			continue;
 		printf("%16s%s", page_flag_names[i] + 2,
@@ -836,7 +936,7 @@ static uint64_t parse_flag_name(const char *str, int len)
 	if (len <= 8 && !strncmp(str, "compound", len))
 		return BITS_COMPOUND;
 
-	for (i = 0; i < ARRAY_SIZE(page_flag_names); i++) {
+	for (i = 0; i < page_flag_nr; i++) {
 		if (!page_flag_names[i])
 			continue;
 		if (!strncmp(str, page_flag_names[i] + 2, len))
@@ -906,6 +1006,7 @@ static const struct option opts[] = {
 	{ "addr"      , 1, NULL, 'a' },
 	{ "bits"      , 1, NULL, 'b' },
 	{ "describe"  , 1, NULL, 'd' },
+	{ "kernel"    , 1, NULL, 'k' },
 	{ "list"      , 0, NULL, 'l' },
 	{ "list-each" , 0, NULL, 'L' },
 	{ "no-summary", 0, NULL, 'N' },
@@ -922,7 +1023,7 @@ int main(int argc, char *argv[])
 	page_size = getpagesize();
 
 	while ((c = getopt_long(argc, argv,
-				"rp:f:a:b:d:lLNXxh", opts, NULL)) != -1) {
+				"rp:f:a:b:d:k:lLNXxh", opts, NULL)) != -1) {
 		switch (c) {
 		case 'r':
 			opt_raw = 1;
@@ -939,6 +1040,10 @@ int main(int argc, char *argv[])
 		case 'b':
 			parse_bits_mask(optarg);
 			break;
+		case 'k':
+			/* Fall-through to case 'd' */
+			page_flag_names = (char **)page_flag_names_kernel;
+			page_flag_nr = __NR_PAGEFLAGS;
 		case 'd':
 			describe_flags(optarg);
 			exit(0);

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

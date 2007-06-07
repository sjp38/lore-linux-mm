Date: Wed, 6 Jun 2007 22:15:34 -0700
From: Randy Dunlap <randy.dunlap@oracle.com>
Subject: [PATCH] hugetlbfs: use lib/parser, fix docs.
Message-Id: <20070606221534.0d09711d.randy.dunlap@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
From: Randy Dunlap <randy.dunlap@oracle.com>
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
Cc: wli@holomorphy.com, akpm <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

Use lib/parser.c to parse hugetlbfs mount options.
Correct docs in hugetlbpage.txt.

old size of hugetlbfs_fill_super:  675 bytes
new size of hugetlbfs_fill_super:  686 bytes
(hugetlbfs_parse_options() is inlined)

Signed-off-by: Randy Dunlap <randy.dunlap@oracle.com>
---
 Documentation/vm/hugetlbpage.txt |   10 ++--
 fs/hugetlbfs/inode.c             |   94 ++++++++++++++++++++++++++++-----------
 2 files changed, 73 insertions(+), 31 deletions(-)

--- linux-2622-rc4.orig/fs/hugetlbfs/inode.c
+++ linux-2622-rc4/fs/hugetlbfs/inode.c
@@ -13,15 +13,18 @@
 #include <linux/fs.h>
 #include <linux/mount.h>
 #include <linux/file.h>
+#include <linux/kernel.h>
 #include <linux/writeback.h>
 #include <linux/pagemap.h>
 #include <linux/highmem.h>
 #include <linux/init.h>
 #include <linux/string.h>
 #include <linux/capability.h>
+#include <linux/ctype.h>
 #include <linux/backing-dev.h>
 #include <linux/hugetlb.h>
 #include <linux/pagevec.h>
+#include <linux/parser.h>
 #include <linux/mman.h>
 #include <linux/quotaops.h>
 #include <linux/slab.h>
@@ -47,6 +50,21 @@ static struct backing_dev_info hugetlbfs
 
 int sysctl_hugetlb_shm_group;
 
+enum {
+	Opt_size, Opt_nr_inodes,
+	Opt_mode, Opt_uid, Opt_gid,
+	Opt_err,
+};
+
+static match_table_t tokens = {
+	{Opt_size,	"size=%s"},
+	{Opt_nr_inodes,	"nr_inodes=%s"},
+	{Opt_mode,	"mode=%o"},
+	{Opt_uid,	"uid=%u"},
+	{Opt_gid,	"gid=%u"},
+	{Opt_err,	NULL},
+};
+
 static void huge_pagevec_release(struct pagevec *pvec)
 {
 	int i;
@@ -594,46 +612,70 @@ static const struct super_operations hug
 static int
 hugetlbfs_parse_options(char *options, struct hugetlbfs_config *pconfig)
 {
-	char *opt, *value, *rest;
+	char *p, *rest;
+	substring_t args[MAX_OPT_ARGS];
+	int option;
 
 	if (!options)
 		return 0;
-	while ((opt = strsep(&options, ",")) != NULL) {
-		if (!*opt)
-			continue;
 
-		value = strchr(opt, '=');
-		if (!value || !*value)
-			return -EINVAL;
-		else
-			*value++ = '\0';
+	while ((p = strsep(&options, ",")) != NULL) {
+		int token;
+
+		token = match_token(p, tokens, args);
+		switch (token) {
+		case Opt_uid:
+			if (match_int(&args[0], &option))
+ 				goto bad_val;
+			pconfig->uid = option;
+			break;
+
+		case Opt_gid:
+			if (match_int(&args[0], &option))
+ 				goto bad_val;
+			pconfig->gid = option;
+			break;
+
+		case Opt_mode:
+			if (match_octal(&args[0], &option))
+ 				goto bad_val;
+			pconfig->mode = option & 0777U;
+			break;
 
-		if (!strcmp(opt, "uid"))
-			pconfig->uid = simple_strtoul(value, &value, 0);
-		else if (!strcmp(opt, "gid"))
-			pconfig->gid = simple_strtoul(value, &value, 0);
-		else if (!strcmp(opt, "mode"))
-			pconfig->mode = simple_strtoul(value,&value,0) & 0777U;
-		else if (!strcmp(opt, "size")) {
-			unsigned long long size = memparse(value, &rest);
+		case Opt_size: {
+ 			unsigned long long size;
+			/* memparse() will accept a K/M/G without a digit */
+			if (!isdigit(*args[0].from))
+				goto bad_val;
+			size = memparse(args[0].from, &rest);
 			if (*rest == '%') {
 				size <<= HPAGE_SHIFT;
 				size *= max_huge_pages;
 				do_div(size, 100);
-				rest++;
 			}
 			pconfig->nr_blocks = (size >> HPAGE_SHIFT);
-			value = rest;
-		} else if (!strcmp(opt,"nr_inodes")) {
-			pconfig->nr_inodes = memparse(value, &rest);
-			value = rest;
-		} else
-			return -EINVAL;
+			break;
+		}
 
-		if (*value)
-			return -EINVAL;
+		case Opt_nr_inodes:
+			/* memparse() will accept a K/M/G without a digit */
+			if (!isdigit(*args[0].from))
+				goto bad_val;
+			pconfig->nr_inodes = memparse(args[0].from, &rest);
+			break;
+
+		default:
+			printk(KERN_ERR "hugetlbfs: Bad mount option: %s\n", p);
+ 			return 1;
+			break;
+		}
 	}
 	return 0;
+
+bad_val:
+ 	printk(KERN_ERR "hugetlbfs: Bad value '%s' for mount option '%s'\n",
+	       args[0].from, p);
+ 	return 1;
 }
 
 static int
--- linux-2622-rc4.orig/Documentation/vm/hugetlbpage.txt
+++ linux-2622-rc4/Documentation/vm/hugetlbpage.txt
@@ -77,8 +77,9 @@ If the user applications are going to re
 call, then it is required that system administrator mount a file system of
 type hugetlbfs:
 
-	mount none /mnt/huge -t hugetlbfs <uid=value> <gid=value> <mode=value>
-		 <size=value> <nr_inodes=value>
+  mount -t hugetlbfs \
+	-o uid=<value>,gid=<value>,mode=<value>,size=<value>,nr_inodes=<value> \
+	none /mnt/huge
 
 This command mounts a (pseudo) filesystem of type hugetlbfs on the directory
 /mnt/huge.  Any files created on /mnt/huge uses hugepages.  The uid and gid
@@ -88,11 +89,10 @@ mode of root of file system to value & 0
 By default the value 0755 is picked. The size option sets the maximum value of
 memory (huge pages) allowed for that filesystem (/mnt/huge). The size is
 rounded down to HPAGE_SIZE.  The option nr_inodes sets the maximum number of
-inodes that /mnt/huge can use.  If the size or nr_inodes options are not
+inodes that /mnt/huge can use.  If the size or nr_inodes option is not
 provided on command line then no limits are set.  For size and nr_inodes
 options, you can use [G|g]/[M|m]/[K|k] to represent giga/mega/kilo. For
-example, size=2K has the same meaning as size=2048. An example is given at
-the end of this document.
+example, size=2K has the same meaning as size=2048.
 
 read and write system calls are not supported on files that reside on hugetlb
 file systems.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

Date: Tue, 5 Jun 2007 15:35:32 -0700
From: Randy Dunlap <randy.dunlap@oracle.com>
Subject: [RFC/PATCH v2] shmem: use lib/parser for mount options
Message-Id: <20070605153532.7b88e529.randy.dunlap@oracle.com>
In-Reply-To: <20070524000044.b62a0792.randy.dunlap@oracle.com>
References: <20070524000044.b62a0792.randy.dunlap@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
From: Randy Dunlap <randy.dunlap@oracle.com>
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
Cc: hugh@veritas.com, akpm <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

Convert shmem (tmpfs) to use the in-kernel mount options parsing library.

Old size: 0x368 = 872 bytes
New size: 0x3b6 = 950 bytes

If you feel that there is no significant advantage to this, that's OK,
I can just drop it.

Signed-off-by: Randy Dunlap <randy.dunlap@oracle.com>
---
 mm/shmem.c |  179 ++++++++++++++++++++++++++++++++++++++++---------------------
 1 file changed, 120 insertions(+), 59 deletions(-)

--- linux-2622-rc4.orig/mm/shmem.c
+++ linux-2622-rc4/mm/shmem.c
@@ -32,6 +32,7 @@
 #include <linux/mman.h>
 #include <linux/file.h>
 #include <linux/swap.h>
+#include <linux/parser.h>
 #include <linux/pagemap.h>
 #include <linux/string.h>
 #include <linux/slab.h>
@@ -84,6 +85,23 @@ enum sgp_type {
 	SGP_WRITE,	/* may exceed i_size, may allocate page */
 };
 
+enum {
+	Opt_size, Opt_nr_blocks, Opt_nr_inodes,
+	Opt_mode, Opt_uid, Opt_gid,
+	Opt_mpol, Opt_err,
+};
+
+static match_table_t tokens = {
+	{Opt_size,	"size=%s"},
+	{Opt_nr_blocks,	"nr_blocks=%s"},
+	{Opt_nr_inodes,	"nr_inodes=%s"},
+	{Opt_mode,	"mode=%o"},	/* not for remount */
+	{Opt_uid,	"uid=%u"},	/* not for remount */
+	{Opt_gid,	"gid=%u"},	/* not for remount */
+	{Opt_mpol,	"mpol=%s"},	/* various NUMA memory policy options */
+	{Opt_err,	NULL},
+};
+
 static int shmem_getpage(struct inode *inode, unsigned long idx,
 			 struct page **pagep, enum sgp_type sgp, int *type);
 
@@ -2113,92 +2131,135 @@ static struct export_operations shmem_ex
 
 static int shmem_parse_options(char *options, int *mode, uid_t *uid,
 	gid_t *gid, unsigned long *blocks, unsigned long *inodes,
-	int *policy, nodemask_t *policy_nodes)
+	int *policy, nodemask_t *policy_nodes, int is_remount)
 {
-	char *this_char, *value, *rest;
+	char *rest;
+	substring_t args[MAX_OPT_ARGS];
+	char *p, *prev_opt = NULL;
+	int option;
 
-	while (options != NULL) {
-		this_char = options;
-		for (;;) {
-			/*
-			 * NUL-terminate this option: unfortunately,
-			 * mount options form a comma-separated list,
-			 * but mpol's nodelist may also contain commas.
-			 */
-			options = strchr(options, ',');
-			if (options == NULL)
-				break;
-			options++;
-			if (!isdigit(*options)) {
-				options[-1] = '\0';
-				break;
-			}
-		}
-		if (!*this_char)
+	if (!options)
+		return 0;
+
+	while ((p = strsep(&options, ",")) != NULL) {
+		int token;
+
+		if (!*p) {
+			prev_opt = options;
 			continue;
-		if ((value = strchr(this_char,'=')) != NULL) {
-			*value++ = 0;
-		} else {
-			printk(KERN_ERR
-			    "tmpfs: No value for mount option '%s'\n",
-			    this_char);
-			return 1;
 		}
-
-		if (!strcmp(this_char,"size")) {
+		token = match_token(p, tokens, args);
+		switch (token) {
+		case Opt_size: {
 			unsigned long long size;
-			size = memparse(value,&rest);
+			/* memparse() will accept a K/M/G without a digit */
+			if (!isdigit(*args[0].from))
+				goto bad_val;
+			size = memparse(args[0].from, &rest);
 			if (*rest == '%') {
 				size <<= PAGE_SHIFT;
 				size *= totalram_pages;
 				do_div(size, 100);
 				rest++;
 			}
-			if (*rest)
-				goto bad_val;
 			*blocks = size >> PAGE_CACHE_SHIFT;
-		} else if (!strcmp(this_char,"nr_blocks")) {
-			*blocks = memparse(value,&rest);
-			if (*rest)
+			break;
+		}
+		case Opt_nr_blocks:
+			/* memparse() will accept a K/M/G without a digit */
+			if (!isdigit(*args[0].from))
 				goto bad_val;
-		} else if (!strcmp(this_char,"nr_inodes")) {
-			*inodes = memparse(value,&rest);
-			if (*rest)
+			*blocks = memparse(args[0].from, &rest);
+			break;
+		case Opt_nr_inodes:
+			/* memparse() will accept a K/M/G without a digit */
+			if (!isdigit(*args[0].from))
 				goto bad_val;
-		} else if (!strcmp(this_char,"mode")) {
+			*inodes = memparse(args[0].from, &rest);
+			break;
+		case Opt_mode:
+			if (is_remount)		/* not valid on remount */
+				break;
 			if (!mode)
-				continue;
-			*mode = simple_strtoul(value,&rest,8);
-			if (*rest)
+				break;
+			if (match_octal(&args[0], &option))
 				goto bad_val;
-		} else if (!strcmp(this_char,"uid")) {
+			*mode = option;
+			break;
+		case Opt_uid:
+			if (is_remount)		/* not valid on remount */
+				break;
 			if (!uid)
-				continue;
-			*uid = simple_strtoul(value,&rest,0);
-			if (*rest)
+				break;
+			if (match_int(&args[0], &option))
 				goto bad_val;
-		} else if (!strcmp(this_char,"gid")) {
+			*uid = option;
+			break;
+		case Opt_gid:
+			if (is_remount)		/* not valid on remount */
+				break;
 			if (!gid)
-				continue;
-			*gid = simple_strtoul(value,&rest,0);
-			if (*rest)
+				break;
+			if (match_int(&args[0], &option))
 				goto bad_val;
-		} else if (!strcmp(this_char,"mpol")) {
-			if (shmem_parse_mpol(value,policy,policy_nodes))
+			*gid = option;
+			break;
+		case Opt_mpol: {
+			/*
+			 * strsep() broke the mount options string at a comma,
+			 * but tmpfs accepts "mpol=type:nodelist", where
+			 * nodelist may contain commas, so restore the
+			 * comma and then insert a nul char at the end of
+			 * the nodelist. Also update 'options' so that the
+			 * next call to strsep() points to the next mount
+			 * option(s).
+			 */
+			char *delim, *opt = prev_opt + 5; /* skip "mpol=" */
+			char *fixup = NULL; /* temp change nul char to comma */
+
+			if (!options)	/* no fixups needed */
+				goto do_mpol;
+
+			/* there are more options, so put the comma back */
+			fixup = prev_opt + strlen(prev_opt);
+			*fixup = ',';	/* this lets (mpol=)policy[:nodelist] be parsed */
+			/* now find the end of the mpol= option */
+			delim = strchr(prev_opt, ':');
+			if (!delim) { /* no colon, restore nul char, done */
+				*fixup = '\0';
+				goto do_mpol;
+			}
+			/* scan over the node(list) & insert nul char at its end */
+			delim++;	/* past colon */
+			while (*delim) {
+				if (*delim == ',' || isdigit(*delim) || *delim == '-')
+					delim++;
+				else
+					break;
+			}
+			options = delim;	/* for next time in main loop */
+			if (*delim)	/* not end of string */
+				delim[-1] = '\0';
+do_mpol:
+			if (shmem_parse_mpol(opt, policy, policy_nodes))
 				goto bad_val;
-		} else {
-			printk(KERN_ERR "tmpfs: Bad mount option %s\n",
-			       this_char);
+
+			break;
+		}
+		default:
+			printk(KERN_ERR "tmpfs: Bad mount option: %s\n", p);
 			return 1;
+			break;
 		}
+
+		prev_opt = options;
 	}
 	return 0;
 
 bad_val:
 	printk(KERN_ERR "tmpfs: Bad value '%s' for mount option '%s'\n",
-	       value, this_char);
+	       args[0].from, p);
 	return 1;
-
 }
 
 static int shmem_remount_fs(struct super_block *sb, int *flags, char *data)
@@ -2213,7 +2274,7 @@ static int shmem_remount_fs(struct super
 	int error = -EINVAL;
 
 	if (shmem_parse_options(data, NULL, NULL, NULL, &max_blocks,
-				&max_inodes, &policy, &policy_nodes))
+				&max_inodes, &policy, &policy_nodes, 1))
 		return error;
 
 	spin_lock(&sbinfo->stat_lock);
@@ -2280,7 +2341,7 @@ static int shmem_fill_super(struct super
 		if (inodes > blocks)
 			inodes = blocks;
 		if (shmem_parse_options(data, &mode, &uid, &gid, &blocks,
-					&inodes, &policy, &policy_nodes))
+					&inodes, &policy, &policy_nodes, 0))
 			return -EINVAL;
 	}
 	sb->s_export_op = &shmem_export_ops;

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

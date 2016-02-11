Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f178.google.com (mail-pf0-f178.google.com [209.85.192.178])
	by kanga.kvack.org (Postfix) with ESMTP id BD1FC6B0263
	for <linux-mm@kvack.org>; Thu, 11 Feb 2016 09:23:03 -0500 (EST)
Received: by mail-pf0-f178.google.com with SMTP id q63so30195373pfb.0
        for <linux-mm@kvack.org>; Thu, 11 Feb 2016 06:23:03 -0800 (PST)
Received: from mga02.intel.com (mga02.intel.com. [134.134.136.20])
        by mx.google.com with ESMTP id o4si12946166pfo.19.2016.02.11.06.22.14
        for <linux-mm@kvack.org>;
        Thu, 11 Feb 2016 06:22:14 -0800 (PST)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: [PATCHv2 26/28] shmem: prepare huge=N mount option and /proc/sys/vm/shmem_huge
Date: Thu, 11 Feb 2016 17:21:54 +0300
Message-Id: <1455200516-132137-27-git-send-email-kirill.shutemov@linux.intel.com>
In-Reply-To: <1455200516-132137-1-git-send-email-kirill.shutemov@linux.intel.com>
References: <1455200516-132137-1-git-send-email-kirill.shutemov@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hugh Dickins <hughd@google.com>, Andrea Arcangeli <aarcange@redhat.com>, Andrew Morton <akpm@linux-foundation.org>
Cc: Dave Hansen <dave.hansen@intel.com>, Vlastimil Babka <vbabka@suse.cz>, Christoph Lameter <cl@gentwo.org>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Jerome Marchand <jmarchan@redhat.com>, Yang Shi <yang.shi@linaro.org>, Sasha Levin <sasha.levin@oracle.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, "Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>

From: Hugh Dickins <hughd@google.com>

Plumb in a new "huge=1" or "huge=0" mount option to tmpfs: I don't
want to get into a maze of boot options, madvises and fadvises at
this stage, nor extend the use of the existing THP tuning to tmpfs;
though either might be pursued later on.  We just want a way to ask
a tmpfs filesystem to favor huge pages, and a way to turn that off
again when it doesn't work out so well.  Default of course is off.

"mount -o remount,huge=N /mountpoint" works fine after mount:
remounting from huge=1 (on) to huge=0 (off) will not attempt to
break up huge pages at all, just stop more from being allocated.

It's possible that we shall allow more values for the option later,
to select different strategies (e.g. how hard to try when allocating
huge pages, or when to map hugely and when not, or how sparse a huge
page should be before it is split up), either for experiments, or well
baked in: so use an unsigned char in the superblock rather than a bool.

No new config option: put this under CONFIG_TRANSPARENT_HUGEPAGE,
which is the appropriate option to protect those who don't want
the new bloat, and with which we shall share some pmd code.  Use a
"name=numeric_value" format like most other tmpfs options.  Prohibit
the option when !CONFIG_TRANSPARENT_HUGEPAGE, just as mpol is invalid
without CONFIG_NUMA (was hidden in mpol_parse_str(): make it explicit).
Allow setting >0 only if the machine has_transparent_hugepage().

But what about Shmem with no user-visible mount?  SysV SHM, memfds,
shared anonymous mmaps (of /dev/zero or MAP_ANONYMOUS), GPU drivers'
DRM objects, Ashmem.  Though unlikely to suit all usages, provide
sysctl /proc/sys/vm/shmem_huge to experiment with huge on those.

And allow shmem_huge two further values: -1 for use in emergencies,
to force the huge option off from all mounts; and (currently) 2,
to force the huge option on for all - very useful for testing.

Signed-off-by: Hugh Dickins <hughd@google.com>
Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
---
 include/linux/shmem_fs.h | 16 +++++++++----
 kernel/sysctl.c          | 12 ++++++++++
 mm/shmem.c               | 59 ++++++++++++++++++++++++++++++++++++++++++++++++
 3 files changed, 82 insertions(+), 5 deletions(-)

diff --git a/include/linux/shmem_fs.h b/include/linux/shmem_fs.h
index a43f41cb3c43..c35482b1dd24 100644
--- a/include/linux/shmem_fs.h
+++ b/include/linux/shmem_fs.h
@@ -31,9 +31,10 @@ struct shmem_sb_info {
 	unsigned long max_inodes;   /* How many inodes are allowed */
 	unsigned long free_inodes;  /* How many are left for allocation */
 	spinlock_t stat_lock;	    /* Serialize shmem_sb_info changes */
+	umode_t mode;		    /* Mount mode for root directory */
+	unsigned char huge;	    /* Whether to try for hugepages */
 	kuid_t uid;		    /* Mount uid for root directory */
 	kgid_t gid;		    /* Mount gid for root directory */
-	umode_t mode;		    /* Mount mode for root directory */
 	struct mempolicy *mpol;     /* default memory policy for mappings */
 };
 
@@ -72,18 +73,23 @@ static inline struct page *shmem_read_mapping_page(
 }
 
 #ifdef CONFIG_TMPFS
-
 extern int shmem_add_seals(struct file *file, unsigned int seals);
 extern int shmem_get_seals(struct file *file);
 extern long shmem_fcntl(struct file *file, unsigned int cmd, unsigned long arg);
-
 #else
-
 static inline long shmem_fcntl(struct file *f, unsigned int c, unsigned long a)
 {
 	return -EINVAL;
 }
+#endif /* CONFIG_TMPFS */
 
-#endif
+#if defined(CONFIG_TRANSPARENT_HUGEPAGE) && defined(CONFIG_SHMEM)
+# ifdef CONFIG_SYSCTL
+struct ctl_table;
+extern int shmem_huge, shmem_huge_min, shmem_huge_max;
+extern int shmem_huge_sysctl(struct ctl_table *table, int write,
+			     void __user *buffer, size_t *lenp, loff_t *ppos);
+# endif /* CONFIG_SYSCTL */
+#endif /* CONFIG_TRANSPARENT_HUGEPAGE && CONFIG_SHMEM */
 
 #endif
diff --git a/kernel/sysctl.c b/kernel/sysctl.c
index d5e7e24b85a9..be75efd865cd 100644
--- a/kernel/sysctl.c
+++ b/kernel/sysctl.c
@@ -43,6 +43,7 @@
 #include <linux/ratelimit.h>
 #include <linux/compaction.h>
 #include <linux/hugetlb.h>
+#include <linux/shmem_fs.h>
 #include <linux/initrd.h>
 #include <linux/key.h>
 #include <linux/times.h>
@@ -1301,6 +1302,17 @@ static struct ctl_table vm_table[] = {
 		.extra1		= &zero,
 		.extra2		= &one_hundred,
 	},
+#if defined(CONFIG_TRANSPARENT_HUGEPAGE) && defined(CONFIG_SHMEM)
+	{
+		.procname	= "shmem_huge",
+		.data		= &shmem_huge,
+		.maxlen		= sizeof(shmem_huge),
+		.mode		= 0644,
+		.proc_handler	= shmem_huge_sysctl,
+		.extra1		= &shmem_huge_min,
+		.extra2		= &shmem_huge_max,
+	},
+#endif
 #ifdef CONFIG_HUGETLB_PAGE
 	{
 		.procname	= "nr_hugepages",
diff --git a/mm/shmem.c b/mm/shmem.c
index d60d6335a253..0ba46c92ccc8 100644
--- a/mm/shmem.c
+++ b/mm/shmem.c
@@ -58,6 +58,7 @@ static struct vfsmount *shm_mnt;
 #include <linux/falloc.h>
 #include <linux/splice.h>
 #include <linux/security.h>
+#include <linux/sysctl.h>
 #include <linux/swapops.h>
 #include <linux/mempolicy.h>
 #include <linux/namei.h>
@@ -289,6 +290,25 @@ static bool shmem_confirm_swap(struct address_space *mapping,
 }
 
 /*
+ * Definitions for "huge tmpfs": tmpfs mounted with the huge=1 option
+ */
+
+/* Special values for /proc/sys/vm/shmem_huge */
+#define SHMEM_HUGE_DENY		(-1)
+#define SHMEM_HUGE_FORCE	(2)
+
+#ifdef CONFIG_TRANSPARENT_HUGEPAGE
+/* ifdef here to avoid bloating shmem.o when not necessary */
+
+int shmem_huge __read_mostly;
+
+#else /* !CONFIG_TRANSPARENT_HUGEPAGE */
+
+#define shmem_huge SHMEM_HUGE_DENY
+
+#endif /* CONFIG_TRANSPARENT_HUGEPAGE */
+
+/*
  * Like add_to_page_cache_locked, but error if expected item has gone.
  */
 static int shmem_add_to_page_cache(struct page *page,
@@ -2915,11 +2935,21 @@ static int shmem_parse_options(char *options, struct shmem_sb_info *sbinfo,
 			sbinfo->gid = make_kgid(current_user_ns(), gid);
 			if (!gid_valid(sbinfo->gid))
 				goto bad_val;
+#ifdef CONFIG_TRANSPARENT_HUGEPAGE
+		} else if (!strcmp(this_char, "huge")) {
+			if (kstrtou8(value, 10, &sbinfo->huge) < 0 ||
+			    sbinfo->huge >= SHMEM_HUGE_FORCE)
+				goto bad_val;
+			if (sbinfo->huge && !has_transparent_hugepage())
+				goto bad_val;
+#endif
+#ifdef CONFIG_NUMA
 		} else if (!strcmp(this_char,"mpol")) {
 			mpol_put(mpol);
 			mpol = NULL;
 			if (mpol_parse_str(value, &mpol))
 				goto bad_val;
+#endif
 		} else {
 			printk(KERN_ERR "tmpfs: Bad mount option %s\n",
 			       this_char);
@@ -2966,6 +2996,7 @@ static int shmem_remount_fs(struct super_block *sb, int *flags, char *data)
 		goto out;
 
 	error = 0;
+	sbinfo->huge = config.huge;
 	sbinfo->max_blocks  = config.max_blocks;
 	sbinfo->max_inodes  = config.max_inodes;
 	sbinfo->free_inodes = config.max_inodes - inodes;
@@ -2999,6 +3030,9 @@ static int shmem_show_options(struct seq_file *seq, struct dentry *root)
 	if (!gid_eq(sbinfo->gid, GLOBAL_ROOT_GID))
 		seq_printf(seq, ",gid=%u",
 				from_kgid_munged(&init_user_ns, sbinfo->gid));
+	/* Rightly or wrongly, show huge mount option unmasked by shmem_huge */
+	if (sbinfo->huge)
+		seq_printf(seq, ",huge=%u", sbinfo->huge);
 	shmem_show_mpol(seq, sbinfo->mpol);
 	return 0;
 }
@@ -3347,6 +3381,31 @@ out3:
 	return error;
 }
 
+#if defined(CONFIG_TRANSPARENT_HUGEPAGE) && defined(CONFIG_SYSCTL)
+int shmem_huge_min = SHMEM_HUGE_DENY;
+int shmem_huge_max = SHMEM_HUGE_FORCE;
+/*
+ * /proc/sys/vm/shmem_huge sysctl for internal shm_mnt, and mount override:
+ * -1 disables huge on shm_mnt and all mounts, for emergency use
+ *  0 disables huge on internal shm_mnt (which has no way to be remounted)
+ *  1  enables huge on internal shm_mnt (which has no way to be remounted)
+ *  2  enables huge on shm_mnt and all mounts, w/o needing option, for testing
+ *     (but we may add more huge options, and push that 2 for testing upwards)
+ */
+int shmem_huge_sysctl(struct ctl_table *table, int write,
+		      void __user *buffer, size_t *lenp, loff_t *ppos)
+{
+	int err;
+
+	if (!has_transparent_hugepage())
+		shmem_huge_max = 0;
+	err = proc_dointvec_minmax(table, write, buffer, lenp, ppos);
+	if (write && !err && !IS_ERR(shm_mnt))
+		SHMEM_SB(shm_mnt->mnt_sb)->huge = (shmem_huge > 0);
+	return err;
+}
+#endif /* CONFIG_TRANSPARENT_HUGEPAGE && CONFIG_SYSCTL */
+
 #else /* !CONFIG_SHMEM */
 
 /*
-- 
2.7.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f181.google.com (mail-pd0-f181.google.com [209.85.192.181])
	by kanga.kvack.org (Postfix) with ESMTP id 50D146B0070
	for <linux-mm@kvack.org>; Fri, 20 Feb 2015 23:05:07 -0500 (EST)
Received: by pdjz10 with SMTP id z10so12087473pdj.0
        for <linux-mm@kvack.org>; Fri, 20 Feb 2015 20:05:07 -0800 (PST)
Received: from mail-pa0-x230.google.com (mail-pa0-x230.google.com. [2607:f8b0:400e:c03::230])
        by mx.google.com with ESMTPS id bh5si19757558pbb.199.2015.02.20.20.05.06
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 20 Feb 2015 20:05:06 -0800 (PST)
Received: by padfa1 with SMTP id fa1so12907491pad.2
        for <linux-mm@kvack.org>; Fri, 20 Feb 2015 20:05:06 -0800 (PST)
Date: Fri, 20 Feb 2015 20:05:04 -0800 (PST)
From: Hugh Dickins <hughd@google.com>
Subject: [PATCH 08/24] huge tmpfs: prepare huge=N mount option and
 /proc/sys/vm/shmem_huge
In-Reply-To: <alpine.LSU.2.11.1502201941340.14414@eggly.anvils>
Message-ID: <alpine.LSU.2.11.1502202003250.14414@eggly.anvils>
References: <alpine.LSU.2.11.1502201941340.14414@eggly.anvils>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Cc: Andrea Arcangeli <aarcange@redhat.com>, Ning Qu <quning@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

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
---
 include/linux/shmem_fs.h |   16 ++++++----
 kernel/sysctl.c          |   12 +++++++
 mm/shmem.c               |   59 +++++++++++++++++++++++++++++++++++++
 3 files changed, 82 insertions(+), 5 deletions(-)

--- thpfs.orig/include/linux/shmem_fs.h	2014-10-05 12:23:04.000000000 -0700
+++ thpfs/include/linux/shmem_fs.h	2015-02-20 19:34:01.464015631 -0800
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
 
@@ -68,18 +69,23 @@ static inline struct page *shmem_read_ma
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
--- thpfs.orig/kernel/sysctl.c	2015-02-08 18:54:22.000000000 -0800
+++ thpfs/kernel/sysctl.c	2015-02-20 19:34:01.464015631 -0800
@@ -42,6 +42,7 @@
 #include <linux/ratelimit.h>
 #include <linux/compaction.h>
 #include <linux/hugetlb.h>
+#include <linux/shmem_fs.h>
 #include <linux/initrd.h>
 #include <linux/key.h>
 #include <linux/times.h>
@@ -1241,6 +1242,17 @@ static struct ctl_table vm_table[] = {
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
--- thpfs.orig/mm/shmem.c	2015-02-20 19:33:46.116050724 -0800
+++ thpfs/mm/shmem.c	2015-02-20 19:34:01.464015631 -0800
@@ -58,6 +58,7 @@ static struct vfsmount *shm_mnt;
 #include <linux/falloc.h>
 #include <linux/splice.h>
 #include <linux/security.h>
+#include <linux/sysctl.h>
 #include <linux/swapops.h>
 #include <linux/mempolicy.h>
 #include <linux/namei.h>
@@ -291,6 +292,25 @@ static bool shmem_confirm_swap(struct ad
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
@@ -2802,11 +2822,21 @@ static int shmem_parse_options(char *opt
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
@@ -2853,6 +2883,7 @@ static int shmem_remount_fs(struct super
 		goto out;
 
 	error = 0;
+	sbinfo->huge = config.huge;
 	sbinfo->max_blocks  = config.max_blocks;
 	sbinfo->max_inodes  = config.max_inodes;
 	sbinfo->free_inodes = config.max_inodes - inodes;
@@ -2886,6 +2917,9 @@ static int shmem_show_options(struct seq
 	if (!gid_eq(sbinfo->gid, GLOBAL_ROOT_GID))
 		seq_printf(seq, ",gid=%u",
 				from_kgid_munged(&init_user_ns, sbinfo->gid));
+	/* Rightly or wrongly, show huge mount option unmasked by shmem_huge */
+	if (sbinfo->huge)
+		seq_printf(seq, ",huge=%u", sbinfo->huge);
 	shmem_show_mpol(seq, sbinfo->mpol);
 	return 0;
 }
@@ -3242,6 +3276,31 @@ out4:
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
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

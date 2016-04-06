Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f176.google.com (mail-pf0-f176.google.com [209.85.192.176])
	by kanga.kvack.org (Postfix) with ESMTP id EC3456B0296
	for <linux-mm@kvack.org>; Wed,  6 Apr 2016 18:58:28 -0400 (EDT)
Received: by mail-pf0-f176.google.com with SMTP id e128so42394283pfe.3
        for <linux-mm@kvack.org>; Wed, 06 Apr 2016 15:58:28 -0700 (PDT)
Received: from mga03.intel.com (mga03.intel.com. [134.134.136.65])
        by mx.google.com with ESMTP id sa8si7277677pac.61.2016.04.06.15.51.36
        for <linux-mm@kvack.org>;
        Wed, 06 Apr 2016 15:51:36 -0700 (PDT)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: [PATCHv6 23/30] shmem: prepare huge= mount option and sysfs knob
Date: Thu,  7 Apr 2016 01:51:13 +0300
Message-Id: <1459983080-106718-24-git-send-email-kirill.shutemov@linux.intel.com>
In-Reply-To: <1459983080-106718-1-git-send-email-kirill.shutemov@linux.intel.com>
References: <1459983080-106718-1-git-send-email-kirill.shutemov@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hugh Dickins <hughd@google.com>, Andrea Arcangeli <aarcange@redhat.com>, Andrew Morton <akpm@linux-foundation.org>
Cc: Dave Hansen <dave.hansen@intel.com>, Vlastimil Babka <vbabka@suse.cz>, Christoph Lameter <cl@gentwo.org>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Jerome Marchand <jmarchan@redhat.com>, Yang Shi <yang.shi@linaro.org>, Sasha Levin <sasha.levin@oracle.com>, Andres Lagar-Cavilla <andreslc@google.com>, Ning Qu <quning@gmail.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

This patch adds new mount option "huge=". It can have following values:

  - "always":
	Attempt to allocate huge pages every time we need a new page;

  - "never":
	Do not allocate huge pages;

  - "within_size":
	Only allocate huge page if it will be fully within i_size.
	Also respect fadvise()/madvise() hints;

  - "advise:
	Only allocate huge pages if requested with fadvise()/madvise();

Default is "never" for now.

"mount -o remount,huge= /mountpoint" works fine after mount: remounting
huge=never will not attempt to break up huge pages at all, just stop
more from being allocated.

No new config option: put this under CONFIG_TRANSPARENT_HUGEPAGE,
which is the appropriate option to protect those who don't want
the new bloat, and with which we shall share some pmd code.

Prohibit the option when !CONFIG_TRANSPARENT_HUGEPAGE, just as mpol is
invalid without CONFIG_NUMA (was hidden in mpol_parse_str(): make it
explicit).

Allow enabling THP only if the machine has_transparent_hugepage().

But what about Shmem with no user-visible mount?  SysV SHM, memfds,
shared anonymous mmaps (of /dev/zero or MAP_ANONYMOUS), GPU drivers'
DRM objects, Ashmem.  Though unlikely to suit all usages, provide
sysfs knob /sys/kernel/mm/transparent_hugepage/shmem_enabled to
experiment with huge on those.

And allow shmem_enabled two further values:

  - "deny":
	For use in emergencies, to force the huge option off from
	all mounts;
  - "force":
	Force the huge option on for all - very useful for testing;

Based on patch by Hugh Dickins.

Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
---
 include/linux/huge_mm.h  |   2 +
 include/linux/shmem_fs.h |   3 +-
 mm/huge_memory.c         |   3 +
 mm/shmem.c               | 161 +++++++++++++++++++++++++++++++++++++++++++++++
 4 files changed, 168 insertions(+), 1 deletion(-)

diff --git a/include/linux/huge_mm.h b/include/linux/huge_mm.h
index 8a0da3317402..80afdcbb9080 100644
--- a/include/linux/huge_mm.h
+++ b/include/linux/huge_mm.h
@@ -43,6 +43,8 @@ enum transparent_hugepage_flag {
 #endif
 };
 
+extern struct kobj_attribute shmem_enabled_attr;
+
 #define HPAGE_PMD_ORDER (HPAGE_PMD_SHIFT-PAGE_SHIFT)
 #define HPAGE_PMD_NR (1<<HPAGE_PMD_ORDER)
 
diff --git a/include/linux/shmem_fs.h b/include/linux/shmem_fs.h
index 4d4780c00d34..466f18c73a49 100644
--- a/include/linux/shmem_fs.h
+++ b/include/linux/shmem_fs.h
@@ -28,9 +28,10 @@ struct shmem_sb_info {
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
 
diff --git a/mm/huge_memory.c b/mm/huge_memory.c
index ea7ad6cb0893..b9788468e50b 100644
--- a/mm/huge_memory.c
+++ b/mm/huge_memory.c
@@ -442,6 +442,9 @@ static struct attribute *hugepage_attr[] = {
 	&enabled_attr.attr,
 	&defrag_attr.attr,
 	&use_zero_page_attr.attr,
+#ifdef CONFIG_SHMEM
+	&shmem_enabled_attr.attr,
+#endif
 #ifdef CONFIG_DEBUG_VM
 	&debug_cow_attr.attr,
 #endif
diff --git a/mm/shmem.c b/mm/shmem.c
index 719bd6b88d98..8dec1c8500fe 100644
--- a/mm/shmem.c
+++ b/mm/shmem.c
@@ -289,6 +289,87 @@ static bool shmem_confirm_swap(struct address_space *mapping,
 }
 
 /*
+ * Definitions for "huge tmpfs": tmpfs mounted with the huge= option
+ *
+ * SHMEM_HUGE_NEVER:
+ *	disables huge pages for the mount;
+ * SHMEM_HUGE_ALWAYS:
+ *	enables huge pages for the mount;
+ * SHMEM_HUGE_WITHIN_SIZE:
+ *	only allocate huge pages if the page will be fully within i_size,
+ *	also respect fadvise()/madvise() hints;
+ * SHMEM_HUGE_ADVISE:
+ *	only allocate huge pages if requested with fadvise()/madvise();
+ */
+
+#define SHMEM_HUGE_NEVER	0
+#define SHMEM_HUGE_ALWAYS	1
+#define SHMEM_HUGE_WITHIN_SIZE	2
+#define SHMEM_HUGE_ADVISE	3
+
+/*
+ * Special values.
+ * Only can be set via /sys/kernel/mm/transparent_hugepage/shmem_enabled:
+ *
+ * SHMEM_HUGE_DENY:
+ *	disables huge on shm_mnt and all mounts, for emergency use;
+ * SHMEM_HUGE_FORCE:
+ *	enables huge on shm_mnt and all mounts, w/o needing option, for testing;
+ *
+ */
+#define SHMEM_HUGE_DENY		(-1)
+#define SHMEM_HUGE_FORCE	(-2)
+
+#ifdef CONFIG_TRANSPARENT_HUGEPAGE
+/* ifdef here to avoid bloating shmem.o when not necessary */
+
+int shmem_huge __read_mostly;
+
+static int shmem_parse_huge(const char *str)
+{
+	if (!strcmp(str, "never"))
+		return SHMEM_HUGE_NEVER;
+	if (!strcmp(str, "always"))
+		return SHMEM_HUGE_ALWAYS;
+	if (!strcmp(str, "within_size"))
+		return SHMEM_HUGE_WITHIN_SIZE;
+	if (!strcmp(str, "advise"))
+		return SHMEM_HUGE_ADVISE;
+	if (!strcmp(str, "deny"))
+		return SHMEM_HUGE_DENY;
+	if (!strcmp(str, "force"))
+		return SHMEM_HUGE_FORCE;
+	return -EINVAL;
+}
+
+static const char *shmem_format_huge(int huge)
+{
+	switch (huge) {
+	case SHMEM_HUGE_NEVER:
+		return "never";
+	case SHMEM_HUGE_ALWAYS:
+		return "always";
+	case SHMEM_HUGE_WITHIN_SIZE:
+		return "within_size";
+	case SHMEM_HUGE_ADVISE:
+		return "advise";
+	case SHMEM_HUGE_DENY:
+		return "deny";
+	case SHMEM_HUGE_FORCE:
+		return "force";
+	default:
+		VM_BUG_ON(1);
+		return "bad_val";
+	}
+}
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
@@ -2868,11 +2949,24 @@ static int shmem_parse_options(char *options, struct shmem_sb_info *sbinfo,
 			sbinfo->gid = make_kgid(current_user_ns(), gid);
 			if (!gid_valid(sbinfo->gid))
 				goto bad_val;
+#ifdef CONFIG_TRANSPARENT_HUGEPAGE
+		} else if (!strcmp(this_char, "huge")) {
+			int huge;
+			huge = shmem_parse_huge(value);
+			if (huge < 0)
+				goto bad_val;
+			if (!has_transparent_hugepage() &&
+					huge != SHMEM_HUGE_NEVER)
+				goto bad_val;
+			sbinfo->huge = huge;
+#endif
+#ifdef CONFIG_NUMA
 		} else if (!strcmp(this_char,"mpol")) {
 			mpol_put(mpol);
 			mpol = NULL;
 			if (mpol_parse_str(value, &mpol))
 				goto bad_val;
+#endif
 		} else {
 			pr_err("tmpfs: Bad mount option %s\n", this_char);
 			goto error;
@@ -2918,6 +3012,7 @@ static int shmem_remount_fs(struct super_block *sb, int *flags, char *data)
 		goto out;
 
 	error = 0;
+	sbinfo->huge = config.huge;
 	sbinfo->max_blocks  = config.max_blocks;
 	sbinfo->max_inodes  = config.max_inodes;
 	sbinfo->free_inodes = config.max_inodes - inodes;
@@ -2951,6 +3046,11 @@ static int shmem_show_options(struct seq_file *seq, struct dentry *root)
 	if (!gid_eq(sbinfo->gid, GLOBAL_ROOT_GID))
 		seq_printf(seq, ",gid=%u",
 				from_kgid_munged(&init_user_ns, sbinfo->gid));
+#ifdef CONFIG_TRANSPARENT_HUGEPAGE
+	/* Rightly or wrongly, show huge mount option unmasked by shmem_huge */
+	if (sbinfo->huge)
+		seq_printf(seq, ",huge=%s", shmem_format_huge(sbinfo->huge));
+#endif
 	shmem_show_mpol(seq, sbinfo->mpol);
 	return 0;
 }
@@ -3289,6 +3389,13 @@ int __init shmem_init(void)
 		pr_err("Could not kern_mount tmpfs\n");
 		goto out1;
 	}
+
+#ifdef CONFIG_TRANSPARENT_HUGEPAGE
+	if (has_transparent_hugepage() && shmem_huge < SHMEM_HUGE_DENY)
+		SHMEM_SB(shm_mnt->mnt_sb)->huge = shmem_huge;
+	else
+		shmem_huge = 0; /* just in case it was patched */
+#endif
 	return 0;
 
 out1:
@@ -3300,6 +3407,60 @@ out3:
 	return error;
 }
 
+#if defined(CONFIG_TRANSPARENT_HUGEPAGE) && defined(CONFIG_SYSFS)
+static ssize_t shmem_enabled_show(struct kobject *kobj,
+		struct kobj_attribute *attr, char *buf)
+{
+	int values[] = {
+		SHMEM_HUGE_ALWAYS,
+		SHMEM_HUGE_WITHIN_SIZE,
+		SHMEM_HUGE_ADVISE,
+		SHMEM_HUGE_NEVER,
+		SHMEM_HUGE_DENY,
+		SHMEM_HUGE_FORCE,
+	};
+	int i, count;
+
+	for (i = 0, count = 0; i < ARRAY_SIZE(values); i++) {
+		const char *fmt = shmem_huge == values[i] ? "[%s] " : "%s ";
+
+		count += sprintf(buf + count, fmt,
+				shmem_format_huge(values[i]));
+	}
+	buf[count - 1] = '\n';
+	return count;
+}
+
+static ssize_t shmem_enabled_store(struct kobject *kobj,
+		struct kobj_attribute *attr, const char *buf, size_t count)
+{
+	char tmp[16];
+	int huge;
+
+	if (count + 1 > sizeof(tmp))
+		return -EINVAL;
+	memcpy(tmp, buf, count);
+	tmp[count] = '\0';
+	if (count && tmp[count - 1] == '\n')
+		tmp[count - 1] = '\0';
+
+	huge = shmem_parse_huge(tmp);
+	if (huge == -EINVAL)
+		return -EINVAL;
+	if (!has_transparent_hugepage() &&
+			huge != SHMEM_HUGE_NEVER && huge != SHMEM_HUGE_DENY)
+		return -EINVAL;
+
+	shmem_huge = huge;
+	if (shmem_huge < SHMEM_HUGE_DENY)
+		SHMEM_SB(shm_mnt->mnt_sb)->huge = shmem_huge;
+	return count;
+}
+
+struct kobj_attribute shmem_enabled_attr =
+	__ATTR(shmem_enabled, 0644, shmem_enabled_show, shmem_enabled_store);
+#endif /* CONFIG_TRANSPARENT_HUGEPAGE && CONFIG_SYSFS */
+
 #else /* !CONFIG_SHMEM */
 
 /*
-- 
2.8.0.rc3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

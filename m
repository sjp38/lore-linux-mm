Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx190.postini.com [74.125.245.190])
	by kanga.kvack.org (Postfix) with SMTP id 1A4BE6B005C
	for <linux-mm@kvack.org>; Mon,  4 Jun 2012 12:47:11 -0400 (EDT)
Received: from euspt1 (mailout1.w1.samsung.com [210.118.77.11])
 by mailout1.w1.samsung.com
 (Oracle Communications Messaging Server 7u4-24.01(7.0.4.24.0) 64bit (built Nov
 17 2011)) with ESMTP id <0M53001ZGQNHUV30@mailout1.w1.samsung.com> for
 linux-mm@kvack.org; Mon, 04 Jun 2012 17:47:41 +0100 (BST)
Received: from linux.samsung.com ([106.116.38.10])
 by spt1.w1.samsung.com (iPlanet Messaging Server 5.2 Patch 2 (built Jul 14
 2004)) with ESMTPA id <0M53005ATQML93@spt1.w1.samsung.com> for
 linux-mm@kvack.org; Mon, 04 Jun 2012 17:47:09 +0100 (BST)
Date: Mon, 04 Jun 2012 18:46:29 +0200
From: Bartlomiej Zolnierkiewicz <b.zolnierkie@samsung.com>
Subject: Re: [PATCH 2/3] proc: add /proc/kpagetype interface
In-reply-to: <201206011854.31625.b.zolnierkie@samsung.com>
Message-id: <201206041846.29387.b.zolnierkie@samsung.com>
MIME-version: 1.0
Content-type: Text/Plain; charset=iso-8859-1
Content-transfer-encoding: 7BIT
References: <201206011854.31625.b.zolnierkie@samsung.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: Kyungmin Park <kyungmin.park@samsung.com>, Matt Mackall <mpm@selenic.com>

From: Bartlomiej Zolnierkiewicz <b.zolnierkie@samsung.com>
Subject: [PATCH v2] proc: add /proc/kpagetype interface

This makes page pageblock type information available to the user-space.

Cc: Matt Mackall <mpm@selenic.com>
Signed-off-by: Bartlomiej Zolnierkiewicz <b.zolnierkie@samsung.com>
Signed-off-by: Kyungmin Park <kyungmin.park@samsung.com>
---
v2:
- fix the "no pageblock migratetype available" case defaulting to
  MIGRATE_UNMOVABLE
- fix MIGRATE_ISOLATE and MIGRATE_CMA handling

 fs/proc/page.c                                |   80 ++++++++++++++++++++++++++
 include/linux/kernel-pageblock-migratetypes.h |   12 +++
 2 files changed, 92 insertions(+)

Index: b/fs/proc/page.c
===================================================================
--- a/fs/proc/page.c	2012-06-04 18:25:54.081310797 +0200
+++ b/fs/proc/page.c	2012-06-04 18:32:39.409310913 +0200
@@ -9,6 +9,7 @@
 #include <linux/seq_file.h>
 #include <linux/hugetlb.h>
 #include <linux/kernel-page-flags.h>
+#include <linux/kernel-pageblock-migratetypes.h>
 #include <asm/uaccess.h>
 #include "internal.h"
 
@@ -254,11 +255,90 @@ static const struct file_operations proc
 	.read = kpageorder_read,
 };
 
+static u64 stable_pageblock_migratetypes(struct page *page)
+{
+	int mt = get_pageblock_migratetype(page);
+	u64 u = 0;
+
+	switch (mt) {
+	case MIGRATE_UNMOVABLE:
+		u = KPM_UNMOVABLE;
+		break;
+	case MIGRATE_RECLAIMABLE:
+		u = KPM_RECLAIMABLE;
+		break;
+	case MIGRATE_MOVABLE:
+		u = KPM_MOVABLE;
+		break;
+	case MIGRATE_PCPTYPES:
+		u = KPM_PCPTYPES;
+		break;
+	case MIGRATE_ISOLATE:
+		u = KPM_ISOLATE;
+		break;
+#ifdef CONFIG_CMA
+	case MIGRATE_CMA:
+		u = KPM_CMA;
+		break;
+#endif
+	}
+
+	return u;
+}
+
+static ssize_t kpagetype_read(struct file *file, char __user *buf,
+			     size_t count, loff_t *ppos)
+{
+	u64 __user *out = (u64 __user *)buf;
+	struct page *ppage;
+	unsigned long src = *ppos;
+	unsigned long pfn;
+	ssize_t ret = 0;
+	u64 ptype;
+
+	pfn = src / KPMSIZE;
+	count = min_t(unsigned long, count,
+		      ((ARCH_PFN_OFFSET + max_pfn) * KPMSIZE) - src);
+	if (src & KPMMASK || count & KPMMASK)
+		return -EINVAL;
+
+	while (count > 0) {
+		if (pfn_valid(pfn))
+			ppage = pfn_to_page(pfn);
+		else
+			ppage = NULL;
+		if (!ppage)
+			ptype = 0;
+		else
+			ptype = stable_pageblock_migratetypes(ppage);
+
+		if (put_user(ptype, out)) {
+			ret = -EFAULT;
+			break;
+		}
+
+		pfn++;
+		out++;
+		count -= KPMSIZE;
+	}
+
+	*ppos += (char __user *)out - buf;
+	if (!ret)
+		ret = (char __user *)out - buf;
+	return ret;
+}
+
+static const struct file_operations proc_kpagetype_operations = {
+	.llseek = mem_lseek,
+	.read = kpagetype_read,
+};
+
 static int __init proc_page_init(void)
 {
 	proc_create("kpagecount", S_IRUSR, NULL, &proc_kpagecount_operations);
 	proc_create("kpageflags", S_IRUSR, NULL, &proc_kpageflags_operations);
 	proc_create("kpageorder", S_IRUSR, NULL, &proc_kpageorder_operations);
+	proc_create("kpagetype", S_IRUSR, NULL, &proc_kpagetype_operations);
 	return 0;
 }
 module_init(proc_page_init);
Index: b/include/linux/kernel-pageblock-migratetypes.h
===================================================================
--- /dev/null	1970-01-01 00:00:00.000000000 +0000
+++ b/include/linux/kernel-pageblock-migratetypes.h	2012-06-04 18:33:49.001310951 +0200
@@ -0,0 +1,12 @@
+#ifndef LINUX_KERNEL_PAGEBLOCK_MIGRATETYPES_H
+#define LINUX_KERNEL_PAGEBLOCK_MIGRATETYPES_H
+
+#define KPM_UNMOVABLE		1
+#define KPM_RECLAIMABLE		2
+#define KPM_MOVABLE		3
+#define KPM_PCPTYPES		4
+#define KPM_RESERVE		KPM_PCPTYPES
+#define KPM_ISOLATE		5
+#define KPM_CMA			6
+
+#endif /* LINUX_KERNEL_PAGEBLOCK_MIGRATETYPES_H */

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

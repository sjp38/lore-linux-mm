Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx159.postini.com [74.125.245.159])
	by kanga.kvack.org (Postfix) with SMTP id 9B4156B006E
	for <linux-mm@kvack.org>; Fri,  1 Jun 2012 12:55:51 -0400 (EDT)
Received: from euspt1 (mailout4.w1.samsung.com [210.118.77.14])
 by mailout4.w1.samsung.com
 (Oracle Communications Messaging Server 7u4-24.01(7.0.4.24.0) 64bit (built Nov
 17 2011)) with ESMTP id <0M4Y00IDG726Y6B0@mailout4.w1.samsung.com> for
 linux-mm@kvack.org; Fri, 01 Jun 2012 17:56:30 +0100 (BST)
Received: from linux.samsung.com ([106.116.38.10])
 by spt1.w1.samsung.com (iPlanet Messaging Server 5.2 Patch 2 (built Jul 14
 2004)) with ESMTPA id <0M4Y0007Q71070@spt1.w1.samsung.com> for
 linux-mm@kvack.org; Fri, 01 Jun 2012 17:55:48 +0100 (BST)
Date: Fri, 01 Jun 2012 18:54:31 +0200
From: Bartlomiej Zolnierkiewicz <b.zolnierkie@samsung.com>
Subject: [PATCH 2/3] proc: add /proc/kpagetype interface
Message-id: <201206011854.31625.b.zolnierkie@samsung.com>
MIME-version: 1.0
Content-type: Text/Plain; charset=us-ascii
Content-transfer-encoding: 7BIT
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: Kyungmin Park <kyungmin.park@samsung.com>, Matt Mackall <mpm@selenic.com>

From: Bartlomiej Zolnierkiewicz <b.zolnierkie@samsung.com>
Subject: [PATCH] proc: add /proc/kpagetype interface

This makes page pageblock type information available to the user-space.

Cc: Matt Mackall <mpm@selenic.com>
Signed-off-by: Bartlomiej Zolnierkiewicz <b.zolnierkie@samsung.com>
Signed-off-by: Kyungmin Park <kyungmin.park@samsung.com>
---
 fs/proc/page.c |   48 ++++++++++++++++++++++++++++++++++++++++++++++++
 1 file changed, 48 insertions(+)

Index: b/fs/proc/page.c
===================================================================
--- a/fs/proc/page.c	2012-05-31 16:30:49.215109568 +0200
+++ b/fs/proc/page.c	2012-05-31 16:30:50.559109495 +0200
@@ -254,11 +254,59 @@ static const struct file_operations proc
 	.read = kpageorder_read,
 };
 
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
+			ptype = get_pageblock_migratetype(ppage);
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

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

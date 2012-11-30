Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx115.postini.com [74.125.245.115])
	by kanga.kvack.org (Postfix) with SMTP id 3BBC16B0096
	for <linux-mm@kvack.org>; Fri, 30 Nov 2012 06:07:33 -0500 (EST)
Received: from epcpsbgm2.samsung.com (epcpsbgm2 [203.254.230.27])
 by mailout3.samsung.com
 (Oracle Communications Messaging Server 7u4-24.01(7.0.4.24.0) 64bit (built Nov
 17 2011)) with ESMTP id <0MEA00HK6S8DBU30@mailout3.samsung.com> for
 linux-mm@kvack.org; Fri, 30 Nov 2012 20:07:31 +0900 (KST)
Received: from amdc1032.localnet ([106.116.147.136])
 by mmp2.samsung.com (Oracle Communications Messaging Server 7u4-24.01
 (7.0.4.24.0) 64bit (built Nov 17 2011))
 with ESMTPA id <0MEA004USS8ATP60@mmp2.samsung.com> for linux-mm@kvack.org;
 Fri, 30 Nov 2012 20:07:31 +0900 (KST)
From: Bartlomiej Zolnierkiewicz <b.zolnierkie@samsung.com>
Subject: [PATCH] proc: add /proc/kpagecskip interface
Date: Fri, 30 Nov 2012 12:06:10 +0100
MIME-version: 1.0
Content-type: Text/Plain; charset=us-ascii
Content-transfer-encoding: 7bit
Message-id: <201211301206.10545.b.zolnierkie@samsung.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: Matt Mackall <mpm@selenic.com>

From: Bartlomiej Zolnierkiewicz <b.zolnierkie@samsung.com>
Subject: [PATCH] proc: add /proc/kpagecskip interface

This makes page pageblock skip on compaction information available
to the user-space.

Cc: Matt Mackall <mpm@selenic.com>
Signed-off-by: Bartlomiej Zolnierkiewicz <b.zolnierkie@samsung.com>
Signed-off-by: Kyungmin Park <kyungmin.park@samsung.com>
---
Based on top of http://www.spinics.net/lists/linux-mm/msg35528.html
patch.

Example user-space usage has been added to:
https://github.com/bzolnier/pagemap-demo-ng

 fs/proc/page.c |   52 ++++++++++++++++++++++++++++++++++++++++++++++++++++
 1 file changed, 52 insertions(+)

Index: b/fs/proc/page.c
===================================================================
--- a/fs/proc/page.c	2012-11-29 12:06:10.408621309 +0100
+++ b/fs/proc/page.c	2012-11-29 12:11:19.760621273 +0100
@@ -339,12 +339,64 @@ static const struct file_operations proc
 	.read = kpagetype_read,
 };
 
+#ifdef CONFIG_COMPACTION
+static ssize_t kpagecskip_read(struct file *file, char __user *buf,
+			       size_t count, loff_t *ppos)
+{
+	u64 __user *out = (u64 __user *)buf;
+	struct page *ppage;
+	unsigned long src = *ppos;
+	unsigned long pfn;
+	ssize_t ret = 0;
+	u64 pcskip;
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
+			pcskip = 0;
+		else
+			pcskip = get_pageblock_skip(ppage);
+
+		if (put_user(pcskip, out)) {
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
+static const struct file_operations proc_kpagecskip_operations = {
+	.llseek = mem_lseek,
+	.read = kpagecskip_read,
+};
+#endif
+
 static int __init proc_page_init(void)
 {
 	proc_create("kpagecount", S_IRUSR, NULL, &proc_kpagecount_operations);
 	proc_create("kpageflags", S_IRUSR, NULL, &proc_kpageflags_operations);
 	proc_create("kpageorder", S_IRUSR, NULL, &proc_kpageorder_operations);
 	proc_create("kpagetype", S_IRUSR, NULL, &proc_kpagetype_operations);
+#ifdef CONFIG_COMPACTION
+	proc_create("kpagecskip", S_IRUSR, NULL, &proc_kpagecskip_operations);
+#endif
 	return 0;
 }
 module_init(proc_page_init);

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

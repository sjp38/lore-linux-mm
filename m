Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id 5F7E86E0002
	for <linux-mm@kvack.org>; Mon, 10 May 2010 05:46:54 -0400 (EDT)
From: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Subject: [PATCH 25/25] lmb: Add debugfs files to dump the arrays content
Date: Mon, 10 May 2010 19:46:05 +1000
Message-Id: <1273484765-29055-25-git-send-email-benh@kernel.crashing.org>
In-Reply-To: <1273484765-29055-24-git-send-email-benh@kernel.crashing.org>
References: <1273484765-29055-1-git-send-email-benh@kernel.crashing.org>
 <1273484765-29055-2-git-send-email-benh@kernel.crashing.org>
 <1273484765-29055-3-git-send-email-benh@kernel.crashing.org>
 <1273484765-29055-4-git-send-email-benh@kernel.crashing.org>
 <1273484765-29055-5-git-send-email-benh@kernel.crashing.org>
 <1273484765-29055-6-git-send-email-benh@kernel.crashing.org>
 <1273484765-29055-7-git-send-email-benh@kernel.crashing.org>
 <1273484765-29055-8-git-send-email-benh@kernel.crashing.org>
 <1273484765-29055-9-git-send-email-benh@kernel.crashing.org>
 <1273484765-29055-10-git-send-email-benh@kernel.crashing.org>
 <1273484765-29055-11-git-send-email-benh@kernel.crashing.org>
 <1273484765-29055-12-git-send-email-benh@kernel.crashing.org>
 <1273484765-29055-13-git-send-email-benh@kernel.crashing.org>
 <1273484765-29055-14-git-send-email-benh@kernel.crashing.org>
 <1273484765-29055-15-git-send-email-benh@kernel.crashing.org>
 <1273484765-29055-16-git-send-email-benh@kernel.crashing.org>
 <1273484765-29055-17-git-send-email-benh@kernel.crashing.org>
 <1273484765-29055-18-git-send-email-benh@kernel.crashing.org>
 <1273484765-29055-19-git-send-email-benh@kernel.crashing.org>
 <1273484765-29055-20-git-send-email-benh@kernel.crashing.org>
 <1273484765-29055-21-git-send-email-benh@kernel.crashing.org>
 <1273484765-29055-22-git-send-email-benh@kernel.crashing.org>
 <1273484765-29055-23-git-send-email-benh@kernel.crashing.org>
 <1273484765-29055-24-git-send-email-benh@kernel.crashing.org>
Sender: owner-linux-mm@kvack.org
To: linux-mm@kvack.org
Cc: linux-kernel@vger.kernel.org, tglx@linutronix.de, mingo@elte.hu, davem@davemloft.net, lethal@linux-sh.org, Benjamin Herrenschmidt <benh@kernel.crashing.org>
List-ID: <linux-mm.kvack.org>

Signed-off-by: Benjamin Herrenschmidt <benh@kernel.crashing.org>
---
 lib/lmb.c |   51 +++++++++++++++++++++++++++++++++++++++++++++++++++
 1 files changed, 51 insertions(+), 0 deletions(-)

diff --git a/lib/lmb.c b/lib/lmb.c
index 6c38c87..1e11891 100644
--- a/lib/lmb.c
+++ b/lib/lmb.c
@@ -16,6 +16,8 @@
 #include <linux/bitops.h>
 #include <linux/poison.h>
 #include <linux/pfn.h>
+#include <linux/debugfs.h>
+#include <linux/seq_file.h>
 #include <linux/lmb.h>
 
 struct lmb lmb;
@@ -696,3 +698,52 @@ static int __init early_lmb(char *p)
 }
 early_param("lmb", early_lmb);
 
+#ifdef CONFIG_DEBUG_FS
+
+static int lmb_debug_show(struct seq_file *m, void *private)
+{
+	struct lmb_type *type = m->private;
+	struct lmb_region *reg;
+	int i;
+
+	for (i = 0; i < type->cnt; i++) {
+		reg = &type->regions[i];
+		seq_printf(m, "%4d: ", i);
+		if (sizeof(phys_addr_t) == 4)
+			seq_printf(m, "0x%08lx..0x%08lx\n",
+				   (unsigned long)reg->base,
+				   (unsigned long)(reg->base + reg->size - 1));
+		else
+			seq_printf(m, "0x%016llx..0x%016llx\n",
+				   (unsigned long long)reg->base,
+				   (unsigned long long)(reg->base + reg->size - 1));
+
+	}
+	return 0;
+}
+
+static int lmb_debug_open(struct inode *inode, struct file *file)
+{
+	return single_open(file, lmb_debug_show, inode->i_private);
+}
+
+static const struct file_operations lmb_debug_fops = {
+	.open = lmb_debug_open,
+	.read = seq_read,
+	.llseek = seq_lseek,
+	.release = single_release,
+};
+
+static int __init lmb_init_debugfs(void)
+{
+	struct dentry *root = debugfs_create_dir("lmb", NULL);
+	if (!root)
+		return -ENXIO;
+	debugfs_create_file("memory", S_IRUGO, root, &lmb.memory, &lmb_debug_fops);
+	debugfs_create_file("reserved", S_IRUGO, root, &lmb.reserved, &lmb_debug_fops);
+	
+	return 0;
+}
+__initcall(lmb_init_debugfs);
+
+#endif /* CONFIG_DEBUG_FS */
-- 
1.6.3.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

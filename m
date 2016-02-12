Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ob0-f180.google.com (mail-ob0-f180.google.com [209.85.214.180])
	by kanga.kvack.org (Postfix) with ESMTP id F09726B0009
	for <linux-mm@kvack.org>; Fri, 12 Feb 2016 15:14:42 -0500 (EST)
Received: by mail-ob0-f180.google.com with SMTP id xk3so136513161obc.2
        for <linux-mm@kvack.org>; Fri, 12 Feb 2016 12:14:42 -0800 (PST)
Received: from alln-iport-7.cisco.com (alln-iport-7.cisco.com. [173.37.142.94])
        by mx.google.com with ESMTPS id o203si5131938oig.87.2016.02.12.12.14.42
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 12 Feb 2016 12:14:42 -0800 (PST)
From: Daniel Walker <danielwa@cisco.com>
Subject: [PATCH] kernel: fs: drop_caches: add dds drop_caches_count
Date: Fri, 12 Feb 2016 12:14:39 -0800
Message-Id: <1455308080-27238-1-git-send-email-danielwa@cisco.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Alexander Viro <viro@zeniv.linux.org.uk>
Cc: Khalid Mughal <khalidm@cisco.com>, xe-kernel@external.cisco.com, dave.hansen@intel.com, hannes@cmpxchg.org, riel@redhat.com, Jonathan Corbet <corbet@lwn.net>, linux-doc@vger.kernel.org, linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org

From: Khalid Mughal <khalidm@cisco.com>

Currently there is no way to figure out the droppable pagecache size
from the meminfo output. The MemFree size can shrink during normal
system operation, when some of the memory pages get cached and is
reflected in "Cached" field. Similarly for file operations some of
the buffer memory gets cached and it is reflected in "Buffers" field.
The kernel automatically reclaims all this cached & buffered memory,
when it is needed elsewhere on the system. The only way to manually
reclaim this memory is by writing 1 to /proc/sys/vm/drop_caches. But
this can have performance impact. Since it discards cached objects,
it may cause high CPU & I/O utilization to recreate the dropped
objects during heavy system load.
This patch computes the droppable pagecache count, using same
algorithm as "vm/drop_caches". It is non-destructive and does not
drop any pages. Therefore it does not have any impact on system
performance. The computation does not include the size of
reclaimable slab.

Cc: xe-kernel@external.cisco.com
Cc: dave.hansen@intel.com
Cc: hannes@cmpxchg.org
Cc: riel@redhat.com
Signed-off-by: Khalid Mughal <khalidm@cisco.com>
Signed-off-by: Daniel Walker <danielwa@cisco.com>
---
 Documentation/sysctl/vm.txt | 12 +++++++
 fs/drop_caches.c            | 80 +++++++++++++++++++++++++++++++++++++++++++--
 include/linux/mm.h          |  3 ++
 kernel/sysctl.c             |  7 ++++
 4 files changed, 100 insertions(+), 2 deletions(-)

diff --git a/Documentation/sysctl/vm.txt b/Documentation/sysctl/vm.txt
index 89a887c..13a501c 100644
--- a/Documentation/sysctl/vm.txt
+++ b/Documentation/sysctl/vm.txt
@@ -29,6 +29,7 @@ Currently, these files are in /proc/sys/vm:
 - dirty_ratio
 - dirty_writeback_centisecs
 - drop_caches
+- drop_caches_count
 - extfrag_threshold
 - hugepages_treat_as_movable
 - hugetlb_shm_group
@@ -224,6 +225,17 @@ with your system.  To disable them, echo 4 (bit 3) into drop_caches.
 
 ==============================================================
 
+drop_caches_count
+
+The amount of droppable pagecache (in kilobytes). Reading this file
+performs same calculation as writing 1 to /proc/sys/vm/drop_caches.
+The actual pages are not dropped during computation of this value.
+
+To read the value:
+	cat /proc/sys/vm/drop_caches_count
+
+==============================================================
+
 extfrag_threshold
 
 This parameter affects whether the kernel will compact memory or direct
diff --git a/fs/drop_caches.c b/fs/drop_caches.c
index d72d52b..0cb2186 100644
--- a/fs/drop_caches.c
+++ b/fs/drop_caches.c
@@ -8,12 +8,73 @@
 #include <linux/writeback.h>
 #include <linux/sysctl.h>
 #include <linux/gfp.h>
+#include <linux/init.h>
+#include <linux/mman.h>
+#include <linux/pagemap.h>
+#include <linux/pagevec.h>
+#include <linux/proc_fs.h>
+#include <linux/seq_file.h>
+#include <linux/vmstat.h>
+#include <linux/blkdev.h>
+
 #include "internal.h"
 
 /* A global variable is a bit ugly, but it keeps the code simple */
+
 int sysctl_drop_caches;
+unsigned int sysctl_drop_caches_count;
+
+static int is_page_droppable(struct page *page)
+{
+	struct address_space *mapping = page_mapping(page);
+
+	if (!mapping)
+		return 0;
+	if (PageDirty(page))
+		return 0;
+	if (PageWriteback(page))
+		return 0;
+	if (page_mapped(page))
+		return 0;
+	if (page->mapping != mapping)
+		return 0;
+	if (page_has_private(page))
+		return 0;
+	return 1;
+}
+
+static unsigned long count_unlocked_pages(struct address_space *mapping)
+{
+	struct pagevec pvec;
+	pgoff_t start = 0;
+	pgoff_t end = -1;
+	unsigned long count = 0;
+	int i;
+	int rc;
+
+	pagevec_init(&pvec, 0);
+	while (start <= end && pagevec_lookup(&pvec, mapping, start,
+		min(end - start, (pgoff_t)PAGEVEC_SIZE - 1) + 1)) {
+		for (i = 0; i < pagevec_count(&pvec); i++) {
+			struct page *page = pvec.pages[i];
+			start = page->index;
+			if (start > end)
+				break;
+			if (!trylock_page(page))
+				continue;
+			WARN_ON(page->index != start);
+			rc = is_page_droppable(page);
+			unlock_page(page);
+			count += rc;
+		}
+		pagevec_release(&pvec);
+		cond_resched();
+		start++;
+	}
+	return count;
+}
 
-static void drop_pagecache_sb(struct super_block *sb, void *unused)
+static void drop_pagecache_sb(struct super_block *sb, void *count)
 {
 	struct inode *inode, *toput_inode = NULL;
 
@@ -29,7 +90,11 @@ static void drop_pagecache_sb(struct super_block *sb, void *unused)
 		spin_unlock(&inode->i_lock);
 		spin_unlock(&sb->s_inode_list_lock);
 
-		invalidate_mapping_pages(inode->i_mapping, 0, -1);
+		if (count)
+			sysctl_drop_caches_count += count_unlocked_pages(inode->i_mapping);
+		else
+			invalidate_mapping_pages(inode->i_mapping, 0, -1);
+
 		iput(toput_inode);
 		toput_inode = inode;
 
@@ -67,3 +132,14 @@ int drop_caches_sysctl_handler(struct ctl_table *table, int write,
 	}
 	return 0;
 }
+
+int drop_caches_count_sysctl_handler(struct ctl_table *table, int write,
+	void __user *buffer, size_t *length, loff_t *ppos)
+{
+	int ret = 0;
+	sysctl_drop_caches_count = nr_blockdev_pages();
+	iterate_supers(drop_pagecache_sb, &sysctl_drop_caches_count);
+	sysctl_drop_caches_count <<= (PAGE_SHIFT - 10); /* count in KBytes */
+	ret = proc_dointvec_minmax(table, write, buffer, length, ppos);
+	return ret;
+}
diff --git a/include/linux/mm.h b/include/linux/mm.h
index f1cd22f..02ebd41 100644
--- a/include/linux/mm.h
+++ b/include/linux/mm.h
@@ -2220,8 +2220,11 @@ static inline int in_gate_area(struct mm_struct *mm, unsigned long addr)
 
 #ifdef CONFIG_SYSCTL
 extern int sysctl_drop_caches;
+extern unsigned int sysctl_drop_caches_count;
 int drop_caches_sysctl_handler(struct ctl_table *, int,
 					void __user *, size_t *, loff_t *);
+int drop_caches_count_sysctl_handler(struct ctl_table *, int,
+					void __user *, size_t *, loff_t *);
 #endif
 
 void drop_slab(void);
diff --git a/kernel/sysctl.c b/kernel/sysctl.c
index 97715fd..c043175 100644
--- a/kernel/sysctl.c
+++ b/kernel/sysctl.c
@@ -1356,6 +1356,13 @@ static struct ctl_table vm_table[] = {
 		.extra1		= &one,
 		.extra2		= &four,
 	},
+	{
+		.procname	= "drop_caches_count",
+		.data		= &sysctl_drop_caches_count,
+		.maxlen		= sizeof(unsigned int),
+		.mode		= 0444,
+		.proc_handler	= drop_caches_count_sysctl_handler,
+	},
 #ifdef CONFIG_COMPACTION
 	{
 		.procname	= "compact_memory",
-- 
2.5.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

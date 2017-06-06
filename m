Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f72.google.com (mail-wm0-f72.google.com [74.125.82.72])
	by kanga.kvack.org (Postfix) with ESMTP id A656F6B0317
	for <linux-mm@kvack.org>; Tue,  6 Jun 2017 14:26:42 -0400 (EDT)
Received: by mail-wm0-f72.google.com with SMTP id 204so26892281wmy.1
        for <linux-mm@kvack.org>; Tue, 06 Jun 2017 11:26:42 -0700 (PDT)
Received: from lhrrgout.huawei.com (lhrrgout.huawei.com. [194.213.3.17])
        by mx.google.com with ESMTPS id l7si23392978wrb.95.2017.06.06.11.26.41
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 06 Jun 2017 11:26:41 -0700 (PDT)
From: Igor Stoppa <igor.stoppa@huawei.com>
Subject: [PATCH 3/4] Protectable Memory Allocator - Debug interface
Date: Tue, 6 Jun 2017 21:24:52 +0300
Message-ID: <20170606182453.32688-4-igor.stoppa@huawei.com>
In-Reply-To: <20170606182453.32688-1-igor.stoppa@huawei.com>
References: <20170606182453.32688-1-igor.stoppa@huawei.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: keescook@chromium.org, mhocko@kernel.org, jmorris@namei.org
Cc: penguin-kernel@I-love.SAKURA.ne.jp, paul@paul-moore.com, sds@tycho.nsa.gov, casey@schaufler-ca.com, hch@infradead.org, labbott@redhat.com, linux-security-module@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, kernel-hardening@lists.openwall.com, Igor Stoppa <igor.stoppa@huawei.com>

Debugfs interface: it creates the file

/sys/kernel/debug/pmalloc/pools

which exposes statistics about all the pools and memory nodes in use.

Signed-off-by: Igor Stoppa <igor.stoppa@huawei.com>
---
 mm/Kconfig   |  11 ++++++
 mm/pmalloc.c | 113 +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
 2 files changed, 124 insertions(+)

diff --git a/mm/Kconfig b/mm/Kconfig
index beb7a45..dfbdc07 100644
--- a/mm/Kconfig
+++ b/mm/Kconfig
@@ -539,6 +539,17 @@ config CMA_AREAS
 
 	  If unsure, leave the default value "7".
 
+config PMALLOC_DEBUG
+        bool "Protectable Memory Allocator debugging"
+        depends on DEBUG_KERNEL
+        default y
+        help
+          Debugfs support for dumping information about memory pools.
+          It shows internal stats: free/used/total space, protection
+          status, data overhead, etc.
+
+          If unsure, say "y".
+
 config MEM_SOFT_DIRTY
 	bool "Track memory changes"
 	depends on CHECKPOINT_RESTORE && HAVE_ARCH_SOFT_DIRTY && PROC_FS
diff --git a/mm/pmalloc.c b/mm/pmalloc.c
index 4ca1e4a..636169c 100644
--- a/mm/pmalloc.c
+++ b/mm/pmalloc.c
@@ -225,3 +225,116 @@ int __init pmalloc_init(void)
 	atomic_set(&pmalloc_data->pools_count, 0);
 	return 0;
 }
+
+#ifdef CONFIG_PMALLOC_DEBUG
+#include <linux/debugfs.h>
+static struct dentry *pmalloc_root;
+
+static void *__pmalloc_seq_start(struct seq_file *s, loff_t *pos)
+{
+	if (*pos)
+		return NULL;
+	return pos;
+}
+
+static void *__pmalloc_seq_next(struct seq_file *s, void *v, loff_t *pos)
+{
+	return NULL;
+}
+
+static void __pmalloc_seq_stop(struct seq_file *s, void *v)
+{
+}
+
+static __always_inline
+void __seq_printf_node(struct seq_file *s, struct pmalloc_node *node)
+{
+	unsigned long total_space, node_pages, end_of_node,
+		      used_space, available_space;
+	int total_words, used_words, available_words;
+
+	used_words = atomic_read(&node->used_words);
+	total_words = node->total_words;
+	available_words = total_words - used_words;
+	used_space = used_words * WORD_SIZE;
+	total_space = total_words * WORD_SIZE;
+	available_space = total_space - used_space;
+	node_pages = (total_space + HEADER_SIZE) / PAGE_SIZE;
+	end_of_node = total_space + HEADER_SIZE + (unsigned long) node;
+	seq_printf(s, " - node:\t\t%pK\n", node);
+	seq_printf(s, "   - start of data ptr:\t%pK\n", node->data);
+	seq_printf(s, "   - end of node ptr:\t%pK\n", (void *)end_of_node);
+	seq_printf(s, "   - total words:\t%d\n", total_words);
+	seq_printf(s, "   - used words:\t%d\n", used_words);
+	seq_printf(s, "   - available words:\t%d\n", available_words);
+	seq_printf(s, "   - pages:\t\t%lu\n", node_pages);
+	seq_printf(s, "   - total space:\t%lu\n", total_space);
+	seq_printf(s, "   - used space:\t%lu\n", used_space);
+	seq_printf(s, "   - available space:\t%lu\n", available_space);
+}
+
+static __always_inline
+void __seq_printf_pool(struct seq_file *s, struct pmalloc_pool *pool)
+{
+	struct pmalloc_node *node;
+
+	seq_printf(s, "pool:\t\t\t%pK\n", pool);
+	seq_printf(s, " - name:\t\t%s\n", pool->name);
+	seq_printf(s, " - protected:\t\t%u\n", atomic_read(&pool->protected));
+	seq_printf(s, " - nodes count:\t\t%u\n",
+		   atomic_read(&pool->nodes_count));
+	rcu_read_lock();
+	hlist_for_each_entry_rcu(node, &pool->nodes_list_head, nodes_list)
+		__seq_printf_node(s, node);
+	rcu_read_unlock();
+}
+
+static int __pmalloc_seq_show(struct seq_file *s, void *v)
+{
+	struct pmalloc_pool *pool;
+
+	seq_printf(s, "pools count:\t\t%u\n",
+		   atomic_read(&pmalloc_data->pools_count));
+	seq_printf(s, "page size:\t\t%lu\n", PAGE_SIZE);
+	seq_printf(s, "word size:\t\t%lu\n", WORD_SIZE);
+	seq_printf(s, "node header size:\t%lu\n", HEADER_SIZE);
+	rcu_read_lock();
+	hlist_for_each_entry_rcu(pool, &pmalloc_data->pools_list_head,
+				 pools_list)
+		__seq_printf_pool(s, pool);
+	rcu_read_unlock();
+	return 0;
+}
+
+static const struct seq_operations pmalloc_seq_ops = {
+	.start = __pmalloc_seq_start,
+	.next  = __pmalloc_seq_next,
+	.stop  = __pmalloc_seq_stop,
+	.show  = __pmalloc_seq_show,
+};
+
+static int __pmalloc_open(struct inode *inode, struct file *file)
+{
+	return seq_open(file, &pmalloc_seq_ops);
+}
+
+static const struct file_operations pmalloc_file_ops = {
+	.owner   = THIS_MODULE,
+	.open    = __pmalloc_open,
+	.read    = seq_read,
+	.llseek  = seq_lseek,
+	.release = seq_release
+};
+
+
+static int __init __pmalloc_init_track_pool(void)
+{
+	struct dentry *de = NULL;
+
+	pmalloc_root = debugfs_create_dir("pmalloc", NULL);
+	debugfs_create_file("pools", 0644, pmalloc_root, NULL,
+			    &pmalloc_file_ops);
+	return 0;
+}
+late_initcall(__pmalloc_init_track_pool);
+#endif
-- 
2.9.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

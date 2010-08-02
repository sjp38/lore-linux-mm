Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id D9D6E600429
	for <linux-mm@kvack.org>; Mon,  2 Aug 2010 16:22:22 -0400 (EDT)
From: Thadeu Lima de Souza Cascardo <cascardo@holoscopio.com>
Subject: [PATCH] mm: only build per-node scan_unevictable when NUMA is enabled
Date: Mon,  2 Aug 2010 17:23:32 -0300
Message-Id: <1280780612-10548-1-git-send-email-cascardo@holoscopio.com>
Sender: owner-linux-mm@kvack.org
To: Lee Schermerhorn <lee.schermerhorn@hp.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, Thadeu Lima de Souza Cascardo <cascardo@holoscopio.com>
List-ID: <linux-mm.kvack.org>

Non-NUMA systems do never create these files anyway, since they are only
created by driver subsystem when NUMA is configured.

Signed-off-by: Thadeu Lima de Souza Cascardo <cascardo@holoscopio.com>
---
 include/linux/swap.h |    5 +++++
 mm/vmscan.c          |    3 ++-
 2 files changed, 7 insertions(+), 1 deletions(-)

diff --git a/include/linux/swap.h b/include/linux/swap.h
index ff4acea..3c0876d 100644
--- a/include/linux/swap.h
+++ b/include/linux/swap.h
@@ -271,8 +271,13 @@ extern void scan_mapping_unevictable_pages(struct address_space *);
 extern unsigned long scan_unevictable_pages;
 extern int scan_unevictable_handler(struct ctl_table *, int,
 					void __user *, size_t *, loff_t *);
+#ifdef CONFIG_NUMA
 extern int scan_unevictable_register_node(struct node *node);
 extern void scan_unevictable_unregister_node(struct node *node);
+#else
+static inline int scan_unevictable_register_node(struct node *node) {return 0;}
+static inline void scan_unevictable_unregister_node(struct node *node) {}
+#endif
 
 extern int kswapd_run(int nid);
 extern void kswapd_stop(int nid);
diff --git a/mm/vmscan.c b/mm/vmscan.c
index b94fe1b..ba8f6fd 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -2898,6 +2898,7 @@ int scan_unevictable_handler(struct ctl_table *table, int write,
 	return 0;
 }
 
+#ifdef CONFIG_NUMA
 /*
  * per node 'scan_unevictable_pages' attribute.  On demand re-scan of
  * a specified node's per zone unevictable lists for evictable pages.
@@ -2944,4 +2945,4 @@ void scan_unevictable_unregister_node(struct node *node)
 {
 	sysdev_remove_file(&node->sysdev, &attr_scan_unevictable_pages);
 }
-
+#endif
-- 
1.7.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

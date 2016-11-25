Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f71.google.com (mail-pg0-f71.google.com [74.125.83.71])
	by kanga.kvack.org (Postfix) with ESMTP id 96EF46B025E
	for <linux-mm@kvack.org>; Fri, 25 Nov 2016 03:26:11 -0500 (EST)
Received: by mail-pg0-f71.google.com with SMTP id y71so155985995pgd.0
        for <linux-mm@kvack.org>; Fri, 25 Nov 2016 00:26:11 -0800 (PST)
Received: from xiaomi.com (outboundhk.mxmail.xiaomi.com. [207.226.244.122])
        by mx.google.com with ESMTPS id h8si15057729pli.261.2016.11.25.00.26.10
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Fri, 25 Nov 2016 00:26:10 -0800 (PST)
From: Hui Zhu <zhuhui@xiaomi.com>
Subject: [RFC 1/2] SWAP: add interface to let disk close swap cache
Date: Fri, 25 Nov 2016 16:25:12 +0800
Message-ID: <1480062313-7361-2-git-send-email-zhuhui@xiaomi.com>
In-Reply-To: <1480062313-7361-1-git-send-email-zhuhui@xiaomi.com>
References: <1480062313-7361-1-git-send-email-zhuhui@xiaomi.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: minchan@kernel.org, ngupta@vflare.org, sergey.senozhatsky.work@gmail.com, dan.j.williams@intel.com, jthumshirn@suse.de, akpm@linux-foundation.org, zhuhui@xiaomi.com, re.emese@gmail.com, andriy.shevchenko@linux.intel.com, vishal.l.verma@intel.com, hannes@cmpxchg.org, mhocko@suse.com, mgorman@techsingularity.net, vbabka@suse.cz, vdavydov.dev@gmail.com, kirill.shutemov@linux.intel.com, ying.huang@intel.com, yang.shi@linaro.org, dave.hansen@linux.intel.com, willy@linux.intel.com, vkuznets@redhat.com, vitalywool@gmail.com, jmarchan@redhat.com, lstoakes@gmail.com, geliangtang@163.com, viro@zeniv.linux.org.uk, hughd@google.com, riel@redhat.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org
Cc: teawater@gmail.com

This patch add a interface to gendisk that SWAP device can use it to
control the swap cache rule.

Signed-off-by: Hui Zhu <zhuhui@xiaomi.com>
---
 include/linux/genhd.h |  3 +++
 include/linux/swap.h  |  8 ++++++
 mm/Kconfig            | 10 +++++++
 mm/memory.c           |  2 +-
 mm/swapfile.c         | 74 ++++++++++++++++++++++++++++++++++++++++++++++++++-
 mm/vmscan.c           |  2 +-
 6 files changed, 96 insertions(+), 3 deletions(-)

diff --git a/include/linux/genhd.h b/include/linux/genhd.h
index e0341af..6baec46 100644
--- a/include/linux/genhd.h
+++ b/include/linux/genhd.h
@@ -215,6 +215,9 @@ struct gendisk {
 #endif	/* CONFIG_BLK_DEV_INTEGRITY */
 	int node_id;
 	struct badblocks *bb;
+#ifdef CONFIG_SWAP_CACHE_RULE
+	bool swap_cache_not_keep;
+#endif
 };
 
 static inline struct gendisk *part_to_disk(struct hd_struct *part)
diff --git a/include/linux/swap.h b/include/linux/swap.h
index a56523c..6fa11ca 100644
--- a/include/linux/swap.h
+++ b/include/linux/swap.h
@@ -582,5 +582,13 @@ static inline bool mem_cgroup_swap_full(struct page *page)
 }
 #endif
 
+#ifdef CONFIG_SWAP_CACHE_RULE
+extern bool swap_not_keep_cache(struct page *page);
+extern void swap_cache_rule_update(void);
+#else
+#define swap_not_keep_cache(p)		mem_cgroup_swap_full(p)
+#define swap_cache_rule_update()
+#endif
+
 #endif /* __KERNEL__*/
 #endif /* _LINUX_SWAP_H */
diff --git a/mm/Kconfig b/mm/Kconfig
index 86e3e0e..6623e87 100644
--- a/mm/Kconfig
+++ b/mm/Kconfig
@@ -711,3 +711,13 @@ config ARCH_USES_HIGH_VMA_FLAGS
 	bool
 config ARCH_HAS_PKEYS
 	bool
+
+config SWAP_CACHE_RULE
+	bool "Swap cache rule support"
+	depends on SWAP
+	default n
+	help
+	  add a interface to gendisk that SWAP device can use it to
+	  control the swap cache rule.
+
+	  If unsure, say "n".
diff --git a/mm/memory.c b/mm/memory.c
index e18c57b..099cb5b 100644
--- a/mm/memory.c
+++ b/mm/memory.c
@@ -2654,7 +2654,7 @@ int do_swap_page(struct fault_env *fe, pte_t orig_pte)
 	}
 
 	swap_free(entry);
-	if (mem_cgroup_swap_full(page) ||
+	if (swap_not_keep_cache(page) ||
 	    (vma->vm_flags & VM_LOCKED) || PageMlocked(page))
 		try_to_free_swap(page);
 	unlock_page(page);
diff --git a/mm/swapfile.c b/mm/swapfile.c
index f304389..9837261 100644
--- a/mm/swapfile.c
+++ b/mm/swapfile.c
@@ -1019,7 +1019,7 @@ int free_swap_and_cache(swp_entry_t entry)
 		 * Also recheck PageSwapCache now page is locked (above).
 		 */
 		if (PageSwapCache(page) && !PageWriteback(page) &&
-		    (!page_mapped(page) || mem_cgroup_swap_full(page))) {
+		    (!page_mapped(page) || swap_not_keep_cache(page))) {
 			delete_from_swap_cache(page);
 			SetPageDirty(page);
 		}
@@ -1992,6 +1992,8 @@ static void reinsert_swap_info(struct swap_info_struct *p)
 	filp_close(victim, NULL);
 out:
 	putname(pathname);
+	if (!err)
+		swap_cache_rule_update();
 	return err;
 }
 
@@ -2576,6 +2578,8 @@ static bool swap_discardable(struct swap_info_struct *si)
 		putname(name);
 	if (inode && S_ISREG(inode->i_mode))
 		inode_unlock(inode);
+	if (!error)
+		swap_cache_rule_update();
 	return error;
 }
 
@@ -2954,3 +2958,71 @@ static void free_swap_count_continuations(struct swap_info_struct *si)
 		}
 	}
 }
+
+#ifdef CONFIG_SWAP_CACHE_RULE
+enum swap_cache_rule_type {
+	SWAP_CACHE_UNKNOWN = 0,
+	SWAP_CACHE_SPECIAL_RULE,
+	SWAP_CACHE_NOT_KEEP,
+	SWAP_CACHE_NEED_CHECK,
+};
+
+static enum swap_cache_rule_type swap_cache_rule __read_mostly;
+
+bool swap_not_keep_cache(struct page *page)
+{
+	enum swap_cache_rule_type rule = READ_ONCE(swap_cache_rule);
+
+	if (rule == SWAP_CACHE_NOT_KEEP)
+		return true;
+
+	if (unlikely(rule == SWAP_CACHE_SPECIAL_RULE)) {
+		struct swap_info_struct *sis;
+
+		BUG_ON(!PageSwapCache(page));
+
+		sis = page_swap_info(page);
+		if (sis->flags & SWP_BLKDEV) {
+			struct gendisk *disk = sis->bdev->bd_disk;
+
+			if (READ_ONCE(disk->swap_cache_not_keep))
+				return true;
+		}
+	}
+
+	return mem_cgroup_swap_full(page);
+}
+
+void swap_cache_rule_update(void)
+{
+	enum swap_cache_rule_type rule = SWAP_CACHE_UNKNOWN;
+	int type;
+
+	spin_lock(&swap_lock);
+	for (type = 0; type < nr_swapfiles; type++) {
+		struct swap_info_struct *sis = swap_info[type];
+		enum swap_cache_rule_type current_rule = SWAP_CACHE_NEED_CHECK;
+
+		if (!(sis->flags & SWP_USED))
+			continue;
+
+		if (sis->flags & SWP_BLKDEV) {
+			struct gendisk *disk = sis->bdev->bd_disk;
+
+			if (READ_ONCE(disk->swap_cache_not_keep))
+				current_rule = SWAP_CACHE_NOT_KEEP;
+		}
+
+		if (rule == SWAP_CACHE_UNKNOWN)
+			rule = current_rule;
+		else if (rule != current_rule) {
+			rule = SWAP_CACHE_SPECIAL_RULE;
+			break;
+		}
+	}
+	spin_unlock(&swap_lock);
+
+	WRITE_ONCE(swap_cache_rule, rule);
+}
+EXPORT_SYMBOL(swap_cache_rule_update);
+#endif
diff --git a/mm/vmscan.c b/mm/vmscan.c
index 76fda22..52c67fe 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -1239,7 +1239,7 @@ static unsigned long shrink_page_list(struct list_head *page_list,
 
 activate_locked:
 		/* Not a candidate for swapping, so reclaim swap space. */
-		if (PageSwapCache(page) && mem_cgroup_swap_full(page))
+		if (PageSwapCache(page) && swap_not_keep_cache(page))
 			try_to_free_swap(page);
 		VM_BUG_ON_PAGE(PageActive(page), page);
 		SetPageActive(page);
-- 
1.9.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx137.postini.com [74.125.245.137])
	by kanga.kvack.org (Postfix) with SMTP id 625E96B0070
	for <linux-mm@kvack.org>; Tue, 11 Dec 2012 22:35:46 -0500 (EST)
Message-ID: <50C7FB85.8040008@huawei.com>
Date: Wed, 12 Dec 2012 11:35:33 +0800
From: Xishi Qiu <qiuxishi@huawei.com>
MIME-Version: 1.0
Subject: [PATCH V4 3/3] MCE: fix an error of mce_bad_pages statistics
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: WuJianguo <wujianguo@huawei.com>, Xishi Qiu <qiuxishi@huawei.com>, Liujiang <jiang.liu@huawei.com>, Simon Jeons <simon.jeons@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, Borislav Petkov <bp@alien8.de>, Andi Kleen <andi@firstfloor.org>, Fengguang Wu <fengguang.wu@intel.com>, Wanpeng Li <liwanp@linux.vnet.ibm.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

Since MCE is an x86 concept, and this code is in mm/, it would be
better to use the name num_poisoned_pages instead of mce_bad_pages.

Signed-off-by: Xishi Qiu <qiuxishi@huawei.com>
Signed-off-by: Jiang Liu <jiang.liu@huawei.com>
Signed-off-by: Borislav Petkov <bp@alien8.de>
---
 fs/proc/meminfo.c   |    2 +-
 include/linux/mm.h  |    2 +-
 mm/memory-failure.c |   16 ++++++++--------
 3 files changed, 10 insertions(+), 10 deletions(-)

diff --git a/fs/proc/meminfo.c b/fs/proc/meminfo.c
index 80e4645..c3dac61 100644
--- a/fs/proc/meminfo.c
+++ b/fs/proc/meminfo.c
@@ -158,7 +158,7 @@ static int meminfo_proc_show(struct seq_file *m, void *v)
 		vmi.used >> 10,
 		vmi.largest_chunk >> 10
 #ifdef CONFIG_MEMORY_FAILURE
-		,atomic_long_read(&mce_bad_pages) << (PAGE_SHIFT - 10)
+		,atomic_long_read(&num_poisoned_pages) << (PAGE_SHIFT - 10)
 #endif
 #ifdef CONFIG_TRANSPARENT_HUGEPAGE
 		,K(global_page_state(NR_ANON_TRANSPARENT_HUGEPAGES) *
diff --git a/include/linux/mm.h b/include/linux/mm.h
index 5432a3e..8ccc477 100644
--- a/include/linux/mm.h
+++ b/include/linux/mm.h
@@ -1653,7 +1653,7 @@ extern int unpoison_memory(unsigned long pfn);
 extern int sysctl_memory_failure_early_kill;
 extern int sysctl_memory_failure_recovery;
 extern void shake_page(struct page *p, int access);
-extern atomic_long_t mce_bad_pages;
+extern atomic_long_t num_poisoned_pages;
 extern int soft_offline_page(struct page *page, int flags);

 extern void dump_page(struct page *page);
diff --git a/mm/memory-failure.c b/mm/memory-failure.c
index e513a7b..ff5e611 100644
--- a/mm/memory-failure.c
+++ b/mm/memory-failure.c
@@ -61,7 +61,7 @@ int sysctl_memory_failure_early_kill __read_mostly = 0;

 int sysctl_memory_failure_recovery __read_mostly = 1;

-atomic_long_t mce_bad_pages __read_mostly = ATOMIC_LONG_INIT(0);
+atomic_long_t num_poisoned_pages __read_mostly = ATOMIC_LONG_INIT(0);

 #if defined(CONFIG_HWPOISON_INJECT) || defined(CONFIG_HWPOISON_INJECT_MODULE)

@@ -1040,7 +1040,7 @@ int memory_failure(unsigned long pfn, int trapno, int flags)
 	}

 	nr_pages = 1 << compound_trans_order(hpage);
-	atomic_long_add(nr_pages, &mce_bad_pages);
+	atomic_long_add(nr_pages, &num_poisoned_pages);

 	/*
 	 * We need/can do nothing about count=0 pages.
@@ -1070,7 +1070,7 @@ int memory_failure(unsigned long pfn, int trapno, int flags)
 			if (!PageHWPoison(hpage)
 			    || (hwpoison_filter(p) && TestClearPageHWPoison(p))
 			    || (p != hpage && TestSetPageHWPoison(hpage))) {
-				atomic_long_sub(nr_pages, &mce_bad_pages);
+				atomic_long_sub(nr_pages, &num_poisoned_pages);
 				return 0;
 			}
 			set_page_hwpoison_huge_page(hpage);
@@ -1128,7 +1128,7 @@ int memory_failure(unsigned long pfn, int trapno, int flags)
 	}
 	if (hwpoison_filter(p)) {
 		if (TestClearPageHWPoison(p))
-			atomic_long_sub(nr_pages, &mce_bad_pages);
+			atomic_long_sub(nr_pages, &num_poisoned_pages);
 		unlock_page(hpage);
 		put_page(hpage);
 		return 0;
@@ -1323,7 +1323,7 @@ int unpoison_memory(unsigned long pfn)
 			return 0;
 		}
 		if (TestClearPageHWPoison(p))
-			atomic_long_sub(nr_pages, &mce_bad_pages);
+			atomic_long_sub(nr_pages, &num_poisoned_pages);
 		pr_info("MCE: Software-unpoisoned free page %#lx\n", pfn);
 		return 0;
 	}
@@ -1337,7 +1337,7 @@ int unpoison_memory(unsigned long pfn)
 	 */
 	if (TestClearPageHWPoison(page)) {
 		pr_info("MCE: Software-unpoisoned page %#lx\n", pfn);
-		atomic_long_sub(nr_pages, &mce_bad_pages);
+		atomic_long_sub(nr_pages, &num_poisoned_pages);
 		freeit = 1;
 		if (PageHuge(page))
 			clear_page_hwpoison_huge_page(page);
@@ -1442,7 +1442,7 @@ static int soft_offline_huge_page(struct page *page, int flags)
 	}
 done:
 	/* keep elevated page count for bad page */
-	atomic_long_add(1 << compound_trans_order(hpage), &mce_bad_pages);
+	atomic_long_add(1 << compound_trans_order(hpage), &num_poisoned_pages);
 	set_page_hwpoison_huge_page(hpage);
 	dequeue_hwpoisoned_huge_page(hpage);
 out:
@@ -1584,7 +1584,7 @@ int soft_offline_page(struct page *page, int flags)

 done:
 	/* keep elevated page count for bad page */
-	atomic_long_inc(&mce_bad_pages);
+	atomic_long_inc(&num_poisoned_pages);
 	SetPageHWPoison(page);
 out:
 	return ret;
-- 
1.7.1


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

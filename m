Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yh0-f52.google.com (mail-yh0-f52.google.com [209.85.213.52])
	by kanga.kvack.org (Postfix) with ESMTP id 8028B6B0037
	for <linux-mm@kvack.org>; Thu, 12 Dec 2013 13:00:54 -0500 (EST)
Received: by mail-yh0-f52.google.com with SMTP id i7so605908yha.11
        for <linux-mm@kvack.org>; Thu, 12 Dec 2013 10:00:54 -0800 (PST)
Date: Thu, 12 Dec 2013 12:00:50 -0600
From: Alex Thorlton <athorlton@sgi.com>
Subject: [RFC PATCH 2/3] Add tunable to control THP behavior
Message-ID: <20131212180050.GC134240@sgi.com>
References: <cover.1386790423.git.athorlton@sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <cover.1386790423.git.athorlton@sgi.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: Andrew Morton <akpm@linux-foundation.org>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Rik van Riel <riel@redhat.com>, Wanpeng Li <liwanp@linux.vnet.ibm.com>, Mel Gorman <mgorman@suse.de>, Michel Lespinasse <walken@google.com>, Benjamin LaHaise <bcrl@kvack.org>, Oleg Nesterov <oleg@redhat.com>, "Eric W. Biederman" <ebiederm@xmission.com>, Andy Lutomirski <luto@amacapital.net>, Al Viro <viro@zeniv.linux.org.uk>, David Rientjes <rientjes@google.com>, Zhang Yanfei <zhangyanfei@cn.fujitsu.com>, Peter Zijlstra <peterz@infradead.org>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>, Jiang Liu <jiang.liu@huawei.com>, Cody P Schafer <cody@linux.vnet.ibm.com>, Glauber Costa <glommer@parallels.com>, Kamezawa Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, linux-kernel@vger.kernel.org

This part of the patch adds a tunable to
/sys/kernel/mm/transparent_hugepage called threshold.  This threshold
determines how many pages a user must fault in from a single node before
a temporary compound page is turned into a THP.

Signed-off-by: Alex Thorlton <athorlton@sgi.com>
Cc: Andrew Morton <akpm@linux-foundation.org>
Cc: Nate Zimmer <nzimmer@sgi.com>
Cc: Cliff Wickman <cpw@sgi.com>
Cc: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Cc: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Cc: Rik van Riel <riel@redhat.com>
Cc: Wanpeng Li <liwanp@linux.vnet.ibm.com>
Cc: Mel Gorman <mgorman@suse.de>
Cc: Michel Lespinasse <walken@google.com>
Cc: Benjamin LaHaise <bcrl@kvack.org>
Cc: Oleg Nesterov <oleg@redhat.com>
Cc: "Eric W. Biederman" <ebiederm@xmission.com>
Cc: Andy Lutomirski <luto@amacapital.net>
Cc: Al Viro <viro@zeniv.linux.org.uk>
Cc: David Rientjes <rientjes@google.com>
Cc: Zhang Yanfei <zhangyanfei@cn.fujitsu.com>
Cc: Peter Zijlstra <peterz@infradead.org>
Cc: Johannes Weiner <hannes@cmpxchg.org>
Cc: Michal Hocko <mhocko@suse.cz>
Cc: Jiang Liu <jiang.liu@huawei.com>
Cc: Cody P Schafer <cody@linux.vnet.ibm.com>
Cc: Glauber Costa <glommer@parallels.com>
Cc: Kamezawa Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: David Rientjes <rientjes@google.com>
Cc: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Cc: linux-kernel@vger.kernel.org
Cc: linux-mm@kvack.org

---
 include/linux/huge_mm.h  |  2 ++
 include/linux/mm_types.h |  1 +
 mm/huge_memory.c         | 30 ++++++++++++++++++++++++++++++
 3 files changed, 33 insertions(+)

diff --git a/include/linux/huge_mm.h b/include/linux/huge_mm.h
index 3935428..0943b1b6 100644
--- a/include/linux/huge_mm.h
+++ b/include/linux/huge_mm.h
@@ -177,6 +177,8 @@ static inline struct page *compound_trans_head(struct page *page)
 extern int do_huge_pmd_numa_page(struct mm_struct *mm, struct vm_area_struct *vma,
 				unsigned long addr, pmd_t pmd, pmd_t *pmdp);
 
+extern int thp_threshold_check(void);
+
 #else /* CONFIG_TRANSPARENT_HUGEPAGE */
 #define HPAGE_PMD_SHIFT ({ BUILD_BUG(); 0; })
 #define HPAGE_PMD_MASK ({ BUILD_BUG(); 0; })
diff --git a/include/linux/mm_types.h b/include/linux/mm_types.h
index d9851ee..b5efa23 100644
--- a/include/linux/mm_types.h
+++ b/include/linux/mm_types.h
@@ -408,6 +408,7 @@ struct mm_struct {
 #endif
 #ifdef CONFIG_TRANSPARENT_HUGEPAGE
 	pgtable_t pmd_huge_pte; /* protected by page_table_lock */
+	int thp_threshold;
 #endif
 #ifdef CONFIG_CPUMASK_OFFSTACK
 	struct cpumask cpumask_allocation;
diff --git a/mm/huge_memory.c b/mm/huge_memory.c
index cca80d9..5d388e4 100644
--- a/mm/huge_memory.c
+++ b/mm/huge_memory.c
@@ -44,6 +44,9 @@ unsigned long transparent_hugepage_flags __read_mostly =
 	(1<<TRANSPARENT_HUGEPAGE_DEFRAG_KHUGEPAGED_FLAG)|
 	(1<<TRANSPARENT_HUGEPAGE_USE_ZERO_PAGE_FLAG);
 
+/* default to 1 page threshold for handing out thps; maintains old behavior */
+static int transparent_hugepage_threshold = 1;
+
 /* default scan 8*512 pte (or vmas) every 30 second */
 static unsigned int khugepaged_pages_to_scan __read_mostly = HPAGE_PMD_NR*8;
 static unsigned int khugepaged_pages_collapsed;
@@ -237,6 +240,11 @@ static struct shrinker huge_zero_page_shrinker = {
 	.seeks = DEFAULT_SEEKS,
 };
 
+int thp_threshold_check()
+{
+	return transparent_hugepage_threshold;
+}
+
 #ifdef CONFIG_SYSFS
 
 static ssize_t double_flag_show(struct kobject *kobj,
@@ -376,6 +384,27 @@ static ssize_t use_zero_page_store(struct kobject *kobj,
 }
 static struct kobj_attribute use_zero_page_attr =
 	__ATTR(use_zero_page, 0644, use_zero_page_show, use_zero_page_store);
+static ssize_t threshold_show(struct kobject *kobj,
+			      struct kobj_attribute *attr, char *buf)
+{
+	return sprintf(buf, "%d\n", transparent_hugepage_threshold);
+}
+static ssize_t threshold_store(struct kobject *kobj,
+			       struct kobj_attribute *attr,
+			       const char *buf, size_t count)
+{
+	int err, value;
+
+	err = kstrtoint(buf, 10, &value);
+	if (err || value < 1 || value > HPAGE_PMD_NR)
+		return -EINVAL;
+
+	transparent_hugepage_threshold = value;
+
+	return count;
+}
+static struct kobj_attribute threshold_attr =
+	__ATTR(threshold, 0644, threshold_show, threshold_store);
 #ifdef CONFIG_DEBUG_VM
 static ssize_t debug_cow_show(struct kobject *kobj,
 				struct kobj_attribute *attr, char *buf)
@@ -397,6 +426,7 @@ static struct kobj_attribute debug_cow_attr =
 static struct attribute *hugepage_attr[] = {
 	&enabled_attr.attr,
 	&defrag_attr.attr,
+	&threshold_attr.attr,
 	&use_zero_page_attr.attr,
 #ifdef CONFIG_DEBUG_VM
 	&debug_cow_attr.attr,
-- 
1.7.12.4


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

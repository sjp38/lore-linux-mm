Return-Path: <owner-linux-mm@kvack.org>
From: Minchan Kim <minchan@kernel.org>
Subject: [RFC 2/3] pinpage control subsystem
Date: Tue, 13 Aug 2013 16:05:01 +0900
Message-Id: <1376377502-28207-3-git-send-email-minchan@kernel.org>
In-Reply-To: <1376377502-28207-1-git-send-email-minchan@kernel.org>
References: <1376377502-28207-1-git-send-email-minchan@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: linux-mm@kvack.org, k.kozlowski@samsung.com, Seth Jennings <sjenning@linux.vnet.ibm.com>, Mel Gorman <mgorman@suse.de>, guz.fnst@cn.fujitsu.com, Benjamin LaHaise <bcrl@kvack.org>, Dave Hansen <dave.hansen@intel.com>, lliubbo@gmail.com, aquini@redhat.com, Rik van Riel <riel@redhat.com>, Minchan Kim <minchan@kernel.org>

Signed-off-by: Minchan Kim <minchan@kernel.org>
---
 include/linux/pinpage.h |   39 ++++++++++++++
 mm/Makefile             |    2 +-
 mm/pinpage.c            |  134 +++++++++++++++++++++++++++++++++++++++++++++++
 3 files changed, 174 insertions(+), 1 deletion(-)
 create mode 100644 include/linux/pinpage.h
 create mode 100644 mm/pinpage.c

diff --git a/include/linux/pinpage.h b/include/linux/pinpage.h
new file mode 100644
index 0000000..42fbdc7
--- /dev/null
+++ b/include/linux/pinpage.h
@@ -0,0 +1,39 @@
+#ifndef _LINUX_PINPAGE_H
+#define _LINUX_PINPAGE_H
+
+#include <linux/radix-tree.h>
+
+/*
+ * NOTE : pinpage_system user shouldn't use page->lru and page->flags
+ * fields.
+ */
+struct pinpage_system {
+	struct radix_tree_root page_tree;
+	spinlock_t tree_lock;
+
+	int (*create_subsys)(struct pinpage_system *psys);
+	int (*destroy_subsys)(struct pinpage_system *psys);
+	int (*migrate)(struct pinpage_system *psys, struct page *page,
+			struct page *newpage);
+	int (*add_page)(struct pinpage_system *psys, struct page *page,
+			void *private);
+	int (*del_page)(struct pinpage_system *psys, struct page *page);
+	int (*find_page)(struct pinpage_system *psys, struct page *page);
+
+	struct list_head list;
+};
+
+extern int general_create_subsys(struct pinpage_system *psys);
+extern int general_destroy_subsys(struct pinpage_system *psys);
+extern int general_add_page(struct pinpage_system *psys, struct page *page,
+			void *private);
+extern int general_del_page(struct pinpage_system *psys, struct page *page);
+extern int general_find_page(struct pinpage_system *psys, struct page *page);
+
+extern int set_pinpage(struct pinpage_system *psys, struct page *page,
+		void *private);
+extern int register_pinpage(struct pinpage_system *psys);
+extern int migrate_pinpage(struct page *page, struct page *newpage);
+
+#endif
+
diff --git a/mm/Makefile b/mm/Makefile
index f008033..bf4a2d9 100644
--- a/mm/Makefile
+++ b/mm/Makefile
@@ -5,7 +5,7 @@
 mmu-y			:= nommu.o
 mmu-$(CONFIG_MMU)	:= fremap.o highmem.o madvise.o memory.o mincore.o \
 			   mlock.o mmap.o mprotect.o mremap.o msync.o rmap.o \
-			   vmalloc.o pagewalk.o pgtable-generic.o
+			   vmalloc.o pagewalk.o pgtable-generic.o pinpage.o
 
 ifdef CONFIG_CROSS_MEMORY_ATTACH
 mmu-$(CONFIG_MMU)	+= process_vm_access.o
diff --git a/mm/pinpage.c b/mm/pinpage.c
new file mode 100644
index 0000000..0833204
--- /dev/null
+++ b/mm/pinpage.c
@@ -0,0 +1,134 @@
+#include <linux/mm.h>
+#include <linux/slab.h>
+#include <linux/pinpage.h>
+#include <linux/pagemap.h>
+
+static DEFINE_SPINLOCK(pinpage_system_lock);
+static LIST_HEAD(pinpage_system_list);
+
+struct pinpage_info {
+	unsigned long pfn;
+	void *private;
+};
+
+int general_create_subsys(struct pinpage_system *psys)
+{
+	INIT_RADIX_TREE(&psys->page_tree, GFP_KERNEL);
+	spin_lock_init(&psys->tree_lock);
+	return 0;
+}
+EXPORT_SYMBOL(general_create_subsys);
+
+int general_destroy_subsys(struct pinpage_system *psys)
+{
+	return 0;
+}
+EXPORT_SYMBOL(general_destroy_subsys);
+
+int general_add_page(struct pinpage_system *psys, struct page *page,
+			void *private)
+{
+	int ret = -ENOMEM;
+	unsigned long pfn = page_to_pfn(page);
+	struct pinpage_info *pinfo = kmalloc(sizeof(pinfo), GFP_KERNEL);
+	if (!pinfo)
+		return ret;
+
+	pinfo->pfn = pfn;
+	pinfo->private = private;
+
+	spin_lock(&psys->tree_lock);
+	ret = radix_tree_insert(&psys->page_tree, pfn, pinfo);
+	spin_unlock(&psys->tree_lock);
+	return ret;
+}
+EXPORT_SYMBOL(general_add_page);
+
+int general_del_page(struct pinpage_system *psys, struct page *page)
+{
+	struct pinpage_info *pinfo;
+	spin_lock(&psys->tree_lock);
+	pinfo = radix_tree_lookup(&psys->page_tree, page_to_pfn(page));
+	if (!pinfo) {
+		spin_unlock(&psys->tree_lock);
+		return -EINVAL;
+	}
+	radix_tree_delete(&psys->page_tree, page_to_pfn(page));
+	spin_unlock(&psys->tree_lock);
+	return 0;
+}
+EXPORT_SYMBOL(general_del_page);
+
+int general_find_page(struct pinpage_system *psys, struct page *page)
+{
+	struct pinpage_info *pinfo;
+	spin_lock(&psys->tree_lock);
+	pinfo = radix_tree_lookup(&psys->page_tree, page_to_pfn(page));
+	spin_unlock(&psys->tree_lock);
+	return pinfo ? 1 : 0;
+}
+EXPORT_SYMBOL(general_find_page);
+
+int set_pinpage(struct pinpage_system *psys, struct page *page, void *private)
+{
+	int ret;
+	ret = psys->add_page(psys, page, private);
+	if (!ret) {
+		lock_page(page);
+		/* Doesn't allow nesting */
+		VM_BUG_ON(PagePin(page));
+		SetPagePin(page);
+		unlock_page(page);
+	}
+	return ret;
+}
+EXPORT_SYMBOL(set_pinpage);
+
+int clear_pinpage(struct pinpage_system *psys, struct page *page)
+{
+	int ret;
+	ret = psys->del_page(psys, page);
+	if (!ret) {
+		lock_page(page);
+		ClearPagePin(page);
+		unlock_page(page);
+	}
+	return ret;
+}
+EXPORT_SYMBOL(clear_pinpage);
+
+int register_pinpage(struct pinpage_system *psys)
+{
+	/* register pinpage_subsystem to global list */	
+	spin_lock(&pinpage_system_lock);
+	list_add(&psys->list, &pinpage_system_list);
+	spin_unlock(&pinpage_system_lock);
+	return psys->create_subsys(psys);
+}
+EXPORT_SYMBOL(register_pinpage);
+
+int unregister_pinpage(struct pinpage_system *psys)
+{
+	/* register pinpage_subsystem to global list */	
+	spin_lock(&pinpage_system_lock);
+	list_del(&psys->list);
+	spin_unlock(&pinpage_system_lock);
+	return psys->destroy_subsys(psys);
+}
+EXPORT_SYMBOL(unregister_pinpage);
+
+int migrate_pinpage(struct page *page, struct page *newpage)
+{
+	int err = 0;
+	struct pinpage_system *psys;
+
+	spin_lock(&pinpage_system_lock);
+	list_for_each_entry(psys, &pinpage_system_list, list) {
+		if (psys->find_page(psys, page)) {
+			err = psys->migrate(psys, page, newpage);
+			break;
+		}
+	}
+	spin_unlock(&pinpage_system_lock);
+	return err;
+}
-- 
1.7.9.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

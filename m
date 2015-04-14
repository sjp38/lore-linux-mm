Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-vn0-f44.google.com (mail-vn0-f44.google.com [209.85.216.44])
	by kanga.kvack.org (Postfix) with ESMTP id 67BA26B0073
	for <linux-mm@kvack.org>; Tue, 14 Apr 2015 16:56:53 -0400 (EDT)
Received: by vnbg7 with SMTP id g7so8122171vnb.10
        for <linux-mm@kvack.org>; Tue, 14 Apr 2015 13:56:53 -0700 (PDT)
Received: from aserp1040.oracle.com (aserp1040.oracle.com. [141.146.126.69])
        by mx.google.com with ESMTPS id f46si1168009yhc.205.2015.04.14.13.56.43
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Tue, 14 Apr 2015 13:56:43 -0700 (PDT)
From: Sasha Levin <sasha.levin@oracle.com>
Subject: [RFC 05/11] mm: debug: dump page into a string rather than directly on screen
Date: Tue, 14 Apr 2015 16:56:27 -0400
Message-Id: <1429044993-1677-6-git-send-email-sasha.levin@oracle.com>
In-Reply-To: <1429044993-1677-1-git-send-email-sasha.levin@oracle.com>
References: <1429044993-1677-1-git-send-email-sasha.levin@oracle.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: akpm@linux-foundation.org, kirill@shutemov.name, linux-mm@kvack.org

This lets us use regular string formatting code to dump VMAs, use it
in VM_BUG_ON_PAGE instead of just printing it to screen as well.

Signed-off-by: Sasha Levin <sasha.levin@oracle.com>
---
 include/linux/mmdebug.h |    6 ++----
 lib/vsprintf.c          |    5 ++++-
 mm/balloon_compaction.c |    4 ++--
 mm/debug.c              |   28 +++++++++++-----------------
 mm/kasan/report.c       |    2 +-
 mm/memory.c             |    2 +-
 mm/memory_hotplug.c     |    2 +-
 mm/page_alloc.c         |    2 +-
 8 files changed, 23 insertions(+), 28 deletions(-)

diff --git a/include/linux/mmdebug.h b/include/linux/mmdebug.h
index 202ebdf..8b3f5a0 100644
--- a/include/linux/mmdebug.h
+++ b/include/linux/mmdebug.h
@@ -7,9 +7,7 @@ struct page;
 struct vm_area_struct;
 struct mm_struct;
 
-extern void dump_page(struct page *page, const char *reason);
-extern void dump_page_badflags(struct page *page, const char *reason,
-			       unsigned long badflags);
+char *format_page(struct page *page, char *buf, char *end);
 
 #ifdef CONFIG_DEBUG_VM
 char *format_vma(const struct vm_area_struct *vma, char *buf, char *end);
@@ -18,7 +16,7 @@ char *format_mm(const struct mm_struct *mm, char *buf, char *end);
 #define VM_BUG_ON_PAGE(cond, page)					\
 	do {								\
 		if (unlikely(cond)) {					\
-			dump_page(page, "VM_BUG_ON_PAGE(" __stringify(cond)")");\
+			pr_emerg("%pZp", page);				\
 			BUG();						\
 		}							\
 	} while (0)
diff --git a/lib/vsprintf.c b/lib/vsprintf.c
index 1ca3114..8511be7 100644
--- a/lib/vsprintf.c
+++ b/lib/vsprintf.c
@@ -1384,6 +1384,8 @@ char *mm_pointer(char *buf, char *end, const void *ptr,
 		return format_vma(ptr, buf, end);
 	case 'm':
 		return format_mm(ptr, buf, end);
+	case 'p':
+		return format_page(ptr, buf, end);
 	}
 
 	return buf;
@@ -1477,9 +1479,10 @@ int kptr_restrict __read_mostly;
  *        (legacy clock framework) of the clock
  * - 'Cr' For a clock, it prints the current rate of the clock
  * - 'T' task_struct->comm
- * - 'Z[mv]' Outputs a readable version of a type of memory management struct:
+ * - 'Z[mpv]' Outputs a readable version of a type of memory management struct:
  *		v struct vm_area_struct
  *		m struct mm_struct
+ *		p struct page
  *
  * Note: The difference between 'S' and 'F' is that on ia64 and ppc64
  * function pointers are really function descriptors, which contain a
diff --git a/mm/balloon_compaction.c b/mm/balloon_compaction.c
index fcad832..88b3cae 100644
--- a/mm/balloon_compaction.c
+++ b/mm/balloon_compaction.c
@@ -187,7 +187,7 @@ void balloon_page_putback(struct page *page)
 		put_page(page);
 	} else {
 		WARN_ON(1);
-		dump_page(page, "not movable balloon page");
+		pr_alert("Not movable balloon page:\n%pZp", page);
 	}
 	unlock_page(page);
 }
@@ -207,7 +207,7 @@ int balloon_page_migrate(struct page *newpage,
 	BUG_ON(!trylock_page(newpage));
 
 	if (WARN_ON(!__is_movable_balloon_page(page))) {
-		dump_page(page, "not movable balloon page");
+		pr_alert("Not movable balloon page:\n%pZp", page);
 		unlock_page(newpage);
 		return rc;
 	}
diff --git a/mm/debug.c b/mm/debug.c
index dff65ff..f64bb6e 100644
--- a/mm/debug.c
+++ b/mm/debug.c
@@ -115,32 +115,26 @@ static char *format_flags(unsigned long flags,
 	return buf;
 }
 
-void dump_page_badflags(struct page *page, const char *reason,
-		unsigned long badflags)
+char *format_page(struct page *page, char *buf, char *end)
 {
-	pr_emerg("page:%p count:%d mapcount:%d mapping:%p index:%#lx\n",
+	buf += snprintf(buf, (buf > end ? 0 : end - buf),
+		"page:%p count:%d mapcount:%d mapping:%p index:%#lx\n",
 		  page, atomic_read(&page->_count), page_mapcount(page),
 		  page->mapping, page->index);
+
 	BUILD_BUG_ON(ARRAY_SIZE(pageflag_names) != __NR_PAGEFLAGS);
-	dump_flags(page->flags, pageflag_names, ARRAY_SIZE(pageflag_names));
-	if (reason)
-		pr_alert("page dumped because: %s\n", reason);
-	if (page->flags & badflags) {
-		pr_alert("bad because of flags:\n");
-		dump_flags(page->flags & badflags,
-				pageflag_names, ARRAY_SIZE(pageflag_names));
-	}
+
+	buf = format_flags(page->flags, pageflag_names,
+			ARRAY_SIZE(pageflag_names), buf, end);
 #ifdef CONFIG_MEMCG
 	if (page->mem_cgroup)
-		pr_alert("page->mem_cgroup:%p\n", page->mem_cgroup);
+		buf += snprintf(buf, (buf > end ? 0 : end - buf),
+			"page->mem_cgroup:%p\n", page->mem_cgroup);
 #endif
-}
 
-void dump_page(struct page *page, const char *reason)
-{
-	dump_page_badflags(page, reason, 0);
+	return buf;
 }
-EXPORT_SYMBOL(dump_page);
+EXPORT_SYMBOL(format_page);
 
 #ifdef CONFIG_DEBUG_VM
 
diff --git a/mm/kasan/report.c b/mm/kasan/report.c
index 680ceed..272a282 100644
--- a/mm/kasan/report.c
+++ b/mm/kasan/report.c
@@ -121,7 +121,7 @@ static void print_address_description(struct kasan_access_info *info)
 				"kasan: bad access detected");
 			return;
 		}
-		dump_page(page, "kasan: bad access detected");
+		pr_emerg("kasan: bad access detected:\n%pZp", page);
 	}
 
 	if (kernel_or_module_addr(addr)) {
diff --git a/mm/memory.c b/mm/memory.c
index d1fa0c1..6e5d4bd 100644
--- a/mm/memory.c
+++ b/mm/memory.c
@@ -683,7 +683,7 @@ static void print_bad_pte(struct vm_area_struct *vma, unsigned long addr,
 		current->comm,
 		(long long)pte_val(pte), (long long)pmd_val(*pmd));
 	if (page)
-		dump_page(page, "bad pte");
+		pr_alert("Bad pte:\n%pZp", page);
 	printk(KERN_ALERT
 		"addr:%p vm_flags:%08lx anon_vma:%p mapping:%p index:%lx\n",
 		(void *)addr, vma->vm_flags, vma->anon_vma, mapping, index);
diff --git a/mm/memory_hotplug.c b/mm/memory_hotplug.c
index c6a8d95..366fba0 100644
--- a/mm/memory_hotplug.c
+++ b/mm/memory_hotplug.c
@@ -1431,7 +1431,7 @@ do_migrate_range(unsigned long start_pfn, unsigned long end_pfn)
 #ifdef CONFIG_DEBUG_VM
 			printk(KERN_ALERT "removing pfn %lx from LRU failed\n",
 			       pfn);
-			dump_page(page, "failed to remove from LRU");
+			pr_alert("Failed to remove from LRU:\n%pZp", page);
 #endif
 			put_page(page);
 			/* Because we don't have big zone->lock. we should
diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 5bd9711..4887731 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -332,7 +332,7 @@ static void bad_page(struct page *page, const char *reason,
 
 	printk(KERN_ALERT "BUG: Bad page state in process %s  pfn:%05lx\n",
 		current->comm, page_to_pfn(page));
-	dump_page_badflags(page, reason, bad_flags);
+	pr_alert("%s:\n%pZpBad flags: %lX", reason, page, bad_flags);
 
 	print_modules();
 	dump_stack();
-- 
1.7.10.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

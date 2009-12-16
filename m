Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id 441F66B0044
	for <linux-mm@kvack.org>; Wed, 16 Dec 2009 07:27:56 -0500 (EST)
Date: Wed, 16 Dec 2009 20:26:40 +0800
From: Wu Fengguang <fengguang.wu@intel.com>
Subject: [PATCH] mm: introduce dump_page() and print symbolic flag names
Message-ID: <20091216122640.GA13817@localhost>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
To: Mel Gorman <mel@csn.ul.ie>
Cc: Alex Chiang <achiang@hp.com>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "Li, Haicheng" <haicheng.li@intel.com>, Randy Dunlap <randy.dunlap@oracle.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Andi Kleen <andi@firstfloor.org>, Ingo Molnar <mingo@elte.hu>, Christoph Lameter <cl@linux-foundation.org>, Rik van Riel <riel@redhat.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
List-ID: <linux-mm.kvack.org>

- introduce dump_page() to print the page info for debugging some error condition.
- convert three mm users: bad_page(), print_bad_pte() and memory offline failure. 
- print an extra field: the symbolic names of page->flags

Example dump_page() output:

[  157.521694] page:ffffea0000a7cba8 count:2 mapcount:1 mapping:ffff88001c901791 index:147
[  157.525570] page flags: 100000000100068(uptodate|lru|active|swapbacked)

CC: Ingo Molnar <mingo@elte.hu> 
CC: Alex Chiang <achiang@hp.com>
CC: Rik van Riel <riel@redhat.com>
CC: Andi Kleen <andi@firstfloor.org> 
CC: Mel Gorman <mel@linux.vnet.ibm.com> 
CC: Christoph Lameter <cl@linux-foundation.org> 
Signed-off-by: Wu Fengguang <fengguang.wu@intel.com>
---
 include/linux/mm.h  |    2 +
 mm/memory.c         |    8 +---
 mm/memory_hotplug.c |    6 +--
 mm/page_alloc.c     |   83 +++++++++++++++++++++++++++++++++++++++---
 4 files changed, 86 insertions(+), 13 deletions(-)

--- linux-mm.orig/mm/page_alloc.c	2009-12-11 10:01:25.000000000 +0800
+++ linux-mm/mm/page_alloc.c	2009-12-16 20:17:18.000000000 +0800
@@ -49,6 +49,7 @@
 #include <linux/debugobjects.h>
 #include <linux/kmemleak.h>
 #include <trace/events/kmem.h>
+#include <linux/ftrace_event.h>
 
 #include <asm/tlbflush.h>
 #include <asm/div64.h>
@@ -262,10 +263,7 @@ static void bad_page(struct page *page)
 
 	printk(KERN_ALERT "BUG: Bad page state in process %s  pfn:%05lx\n",
 		current->comm, page_to_pfn(page));
-	printk(KERN_ALERT
-		"page:%p flags:%p count:%d mapcount:%d mapping:%p index:%lx\n",
-		page, (void *)page->flags, page_count(page),
-		page_mapcount(page), page->mapping, page->index);
+	dump_page(page);
 
 	dump_stack();
 out:
@@ -5106,3 +5104,80 @@ bool is_free_buddy_page(struct page *pag
 	return order < MAX_ORDER;
 }
 #endif
+
+static struct trace_print_flags pageflag_names[] = {
+	{1UL << PG_locked,		"locked"	},
+	{1UL << PG_error,		"error"		},
+	{1UL << PG_referenced,		"referenced"	},
+	{1UL << PG_uptodate,		"uptodate"	},
+	{1UL << PG_dirty,		"dirty"		},
+	{1UL << PG_lru,			"lru"		},
+	{1UL << PG_active,		"active"	},
+	{1UL << PG_slab,		"slab"		},
+	{1UL << PG_owner_priv_1,	"owner_priv_1"	},
+	{1UL << PG_arch_1,		"arch_1"	},
+	{1UL << PG_reserved,		"reserved"	},
+	{1UL << PG_private,		"private"	},
+	{1UL << PG_private_2,		"private_2"	},
+	{1UL << PG_writeback,		"writeback"	},
+#ifdef CONFIG_PAGEFLAGS_EXTENDED
+	{1UL << PG_head,		"head"		},
+	{1UL << PG_tail,		"tail"		},
+#else
+	{1UL << PG_compound,		"compound"	},
+#endif
+	{1UL << PG_swapcache,		"swapcache"	},
+	{1UL << PG_mappedtodisk,	"mappedtodisk"	},
+	{1UL << PG_reclaim,		"reclaim"	},
+	{1UL << PG_buddy,		"buddy"		},
+	{1UL << PG_swapbacked,		"swapbacked"	},
+	{1UL << PG_unevictable,		"unevictable"	},
+#ifdef CONFIG_MMU
+	{1UL << PG_mlocked,		"mlocked"	},
+#endif
+#ifdef CONFIG_ARCH_USES_PG_UNCACHED
+	{1UL << PG_uncached,		"uncached"	},
+#endif
+#ifdef CONFIG_MEMORY_FAILURE
+	{1UL << PG_hwpoison,		"hwpoison"	},
+#endif
+	{-1UL,				NULL		},
+};
+
+static void dump_page_flags(unsigned long flags)
+{
+	const char *delim = "";
+	unsigned long mask;
+	int i;
+
+	printk(KERN_ALERT "page flags: %lx(", flags);
+
+	/* remove zone id */
+	flags &= (1UL << NR_PAGEFLAGS) - 1;
+
+	for (i = 0; pageflag_names[i].name && flags; i++) {
+
+		mask = pageflag_names[i].mask;
+		if ((flags & mask) != mask)
+			continue;
+
+		flags &= ~mask;
+		printk("%s%s", delim, pageflag_names[i].name);
+		delim = "|";
+	}
+
+	/* check for left over flags */
+	if (flags)
+		printk("%s%#lx", delim, flags);
+
+	printk(")\n");
+}
+
+void dump_page(struct page *page)
+{
+	printk(KERN_ALERT
+	       "page:%p count:%d mapcount:%d mapping:%p index:%lx\n",
+		page, page_count(page), page_mapcount(page),
+		page->mapping, page->index);
+	dump_page_flags(page->flags);
+}
--- linux-mm.orig/mm/memory.c	2009-12-11 10:01:25.000000000 +0800
+++ linux-mm/mm/memory.c	2009-12-14 19:21:22.000000000 +0800
@@ -430,12 +430,8 @@ static void print_bad_pte(struct vm_area
 		"BUG: Bad page map in process %s  pte:%08llx pmd:%08llx\n",
 		current->comm,
 		(long long)pte_val(pte), (long long)pmd_val(*pmd));
-	if (page) {
-		printk(KERN_ALERT
-		"page:%p flags:%p count:%d mapcount:%d mapping:%p index:%lx\n",
-		page, (void *)page->flags, page_count(page),
-		page_mapcount(page), page->mapping, page->index);
-	}
+	if (page)
+		dump_page(page);
 	printk(KERN_ALERT
 		"addr:%p vm_flags:%08lx anon_vma:%p mapping:%p index:%lx\n",
 		(void *)addr, vma->vm_flags, vma->anon_vma, mapping, index);
--- linux-mm.orig/mm/memory_hotplug.c	2009-12-11 10:01:25.000000000 +0800
+++ linux-mm/mm/memory_hotplug.c	2009-12-14 19:21:22.000000000 +0800
@@ -678,9 +678,9 @@ do_migrate_range(unsigned long start_pfn
 			if (page_count(page))
 				not_managed++;
 #ifdef CONFIG_DEBUG_VM
-			printk(KERN_INFO "removing from LRU failed"
-					 " %lx/%d/%lx\n",
-				pfn, page_count(page), page->flags);
+			printk(KERN_ALERT "removing pfn %lx from LRU failed\n",
+			       pfn);
+			dump_page(page);
 #endif
 		}
 	}
--- linux-mm.orig/include/linux/mm.h	2009-12-11 10:01:25.000000000 +0800
+++ linux-mm/include/linux/mm.h	2009-12-14 19:21:22.000000000 +0800
@@ -1328,5 +1328,7 @@ extern void shake_page(struct page *p, i
 extern atomic_long_t mce_bad_pages;
 extern int soft_offline_page(struct page *page, int flags);
 
+extern void dump_page(struct page *page);
+
 #endif /* __KERNEL__ */
 #endif /* _LINUX_MM_H */

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

Return-Path: <linux-kernel-owner@vger.kernel.org>
From: Roman Gushchin <guroan@gmail.com>
Subject: [PATCH 3/3] mm: show number of vmalloc pages in /proc/meminfo
Date: Wed, 19 Dec 2018 09:37:51 -0800
Message-Id: <20181219173751.28056-4-guro@fb.com>
In-Reply-To: <20181219173751.28056-1-guro@fb.com>
References: <20181219173751.28056-1-guro@fb.com>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
Sender: linux-kernel-owner@vger.kernel.org
To: linux-mm@kvack.org
Cc: Matthew Wilcox <willy@infradead.org>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.com>, linux-kernel@vger.kernel.org, kernel-team@fb.com, Roman Gushchin <guro@fb.com>
List-ID: <linux-mm.kvack.org>

Vmalloc() is getting more and more used these days (kernel stacks,
bpf and percpu allocator are new top users), and the total %
of memory consumed by vmalloc() can be pretty significant
and changes dynamically.

/proc/meminfo is the best place to display this information:
its top goal is to show top consumers of the memory.

Since the VmallocUsed field in /proc/meminfo is not in use
for quite a long time (it has been defined to 0 by the
commit a5ad88ce8c7f ("mm: get rid of 'vmalloc_info' from
/proc/meminfo")), let's reuse it for showing the actual
physical memory consumption of vmalloc().

Signed-off-by: Roman Gushchin <guro@fb.com>
Acked-by: Johannes Weiner <hannes@cmpxchg.org>
---
 fs/proc/meminfo.c       |  2 +-
 include/linux/vmalloc.h |  2 ++
 mm/vmalloc.c            | 10 ++++++++++
 3 files changed, 13 insertions(+), 1 deletion(-)

diff --git a/fs/proc/meminfo.c b/fs/proc/meminfo.c
index 568d90e17c17..465ea0153b2a 100644
--- a/fs/proc/meminfo.c
+++ b/fs/proc/meminfo.c
@@ -120,7 +120,7 @@ static int meminfo_proc_show(struct seq_file *m, void *v)
 	show_val_kb(m, "Committed_AS:   ", committed);
 	seq_printf(m, "VmallocTotal:   %8lu kB\n",
 		   (unsigned long)VMALLOC_TOTAL >> 10);
-	show_val_kb(m, "VmallocUsed:    ", 0ul);
+	show_val_kb(m, "VmallocUsed:    ", vmalloc_nr_pages());
 	show_val_kb(m, "VmallocChunk:   ", 0ul);
 	show_val_kb(m, "Percpu:         ", pcpu_nr_pages());
 
diff --git a/include/linux/vmalloc.h b/include/linux/vmalloc.h
index 398e9c95cd61..0b497408272b 100644
--- a/include/linux/vmalloc.h
+++ b/include/linux/vmalloc.h
@@ -63,10 +63,12 @@ extern void vm_unmap_aliases(void);
 
 #ifdef CONFIG_MMU
 extern void __init vmalloc_init(void);
+extern unsigned long vmalloc_nr_pages(void);
 #else
 static inline void vmalloc_init(void)
 {
 }
+static inline unsigned long vmalloc_nr_pages(void) { return 0; }
 #endif
 
 extern void *vmalloc(unsigned long size);
diff --git a/mm/vmalloc.c b/mm/vmalloc.c
index 042175d7d95f..efca916940e9 100644
--- a/mm/vmalloc.c
+++ b/mm/vmalloc.c
@@ -340,6 +340,13 @@ static unsigned long cached_align;
 
 static unsigned long vmap_area_pcpu_hole;
 
+static atomic_long_t nr_vmalloc_pages;
+
+unsigned long vmalloc_nr_pages(void)
+{
+	return atomic_long_read(&nr_vmalloc_pages);
+}
+
 static struct vmap_area *__find_vmap_area(unsigned long addr)
 {
 	struct rb_node *n = vmap_area_root.rb_node;
@@ -1549,6 +1556,7 @@ static void __vunmap(const void *addr, int deallocate_pages)
 			BUG_ON(!page);
 			__free_pages(page, 0);
 		}
+		atomic_long_sub(area->nr_pages, &nr_vmalloc_pages);
 
 		kvfree(area->pages);
 	}
@@ -1717,12 +1725,14 @@ static void *__vmalloc_area_node(struct vm_struct *area, gfp_t gfp_mask,
 		if (unlikely(!page)) {
 			/* Successfully allocated i pages, free them in __vunmap() */
 			area->nr_pages = i;
+			atomic_long_add(area->nr_pages, &nr_vmalloc_pages);
 			goto fail;
 		}
 		area->pages[i] = page;
 		if (gfpflags_allow_blocking(gfp_mask|highmem_mask))
 			cond_resched();
 	}
+	atomic_long_add(area->nr_pages, &nr_vmalloc_pages);
 
 	if (map_vm_area(area, prot, pages))
 		goto fail;
-- 
2.19.2

Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f69.google.com (mail-lf0-f69.google.com [209.85.215.69])
	by kanga.kvack.org (Postfix) with ESMTP id 183216B0253
	for <linux-mm@kvack.org>; Fri, 19 Aug 2016 06:13:11 -0400 (EDT)
Received: by mail-lf0-f69.google.com with SMTP id e7so28639636lfe.0
        for <linux-mm@kvack.org>; Fri, 19 Aug 2016 03:13:11 -0700 (PDT)
Received: from mail-wm0-f67.google.com (mail-wm0-f67.google.com. [74.125.82.67])
        by mx.google.com with ESMTPS id e18si5670775wjz.212.2016.08.19.03.13.09
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 19 Aug 2016 03:13:09 -0700 (PDT)
Received: by mail-wm0-f67.google.com with SMTP id i5so2819105wmg.2
        for <linux-mm@kvack.org>; Fri, 19 Aug 2016 03:13:09 -0700 (PDT)
From: Michal Hocko <mhocko@kernel.org>
Subject: [PATCH 1/2] proc, meminfo: abstract show_val_kb
Date: Fri, 19 Aug 2016 12:12:59 +0200
Message-Id: <1471601580-17999-2-git-send-email-mhocko@kernel.org>
In-Reply-To: <1471601580-17999-1-git-send-email-mhocko@kernel.org>
References: <1471519888-13829-1-git-send-email-mhocko@kernel.org>
 <1471601580-17999-1-git-send-email-mhocko@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Joe Perches <joe@perches.com>, Jann Horn <jann@thejh.net>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>, Michal Hocko <mhocko@suse.com>

From: Michal Hocko <mhocko@suse.com>

show_val_kb is currently tight meminfo usage but we would like to reuse
it for other proc files. Let's pull it out to proc internal header,
rename to show_name_pages_kb to be explicit that it operates on page
units and change show_val_kb to only print the value.

Signed-off-by: Michal Hocko <mhocko@suse.com>
---
 fs/proc/internal.h | 10 ++++++
 fs/proc/meminfo.c  | 93 ++++++++++++++++++++++++++----------------------------
 2 files changed, 55 insertions(+), 48 deletions(-)

diff --git a/fs/proc/internal.h b/fs/proc/internal.h
index 7931c558c192..10492701f4c1 100644
--- a/fs/proc/internal.h
+++ b/fs/proc/internal.h
@@ -304,3 +304,13 @@ extern unsigned long task_statm(struct mm_struct *,
 				unsigned long *, unsigned long *,
 				unsigned long *, unsigned long *);
 extern void task_mem(struct seq_file *, struct mm_struct *);
+
+/* prints given value (in kB) padded properly to 8 spaces */
+extern void show_val_kb(struct seq_file *m, unsigned long num);
+
+#define show_name_pages_kb(seq, name, pages)	\
+({						\
+ 	BUILD_BUG_ON(!__builtin_constant_p(name));\
+ 	seq_write(seq, name, sizeof(name));	\
+ 	show_val_kb(seq, (pages) << (PAGE_SHIFT - 10));\
+ })
diff --git a/fs/proc/meminfo.c b/fs/proc/meminfo.c
index 8a428498d6b2..65e0bc6213e2 100644
--- a/fs/proc/meminfo.c
+++ b/fs/proc/meminfo.c
@@ -23,16 +23,13 @@ void __attribute__((weak)) arch_report_meminfo(struct seq_file *m)
 {
 }
 
-static void show_val_kb(struct seq_file *m, const char *s, unsigned long num)
+void show_val_kb(struct seq_file *m, unsigned long num)
 {
 	char v[32];
 	static const char blanks[7] = {' ', ' ', ' ', ' ',' ', ' ', ' '};
 	int len;
 
-	len = num_to_str(v, sizeof(v), num << (PAGE_SHIFT - 10));
-
-	seq_write(m, s, 16);
-
+	len = num_to_str(v, sizeof(v), num);
 	if (len > 0) {
 		if (len < 8)
 			seq_write(m, blanks, 8 - len);
@@ -65,74 +62,74 @@ static int meminfo_proc_show(struct seq_file *m, void *v)
 
 	available = si_mem_available();
 
-	show_val_kb(m, "MemTotal:       ", i.totalram);
-	show_val_kb(m, "MemFree:        ", i.freeram);
-	show_val_kb(m, "MemAvailable:   ", available);
-	show_val_kb(m, "Buffers:        ", i.bufferram);
-	show_val_kb(m, "Cached:         ", cached);
-	show_val_kb(m, "SwapCached:     ", total_swapcache_pages());
-	show_val_kb(m, "Active:         ", pages[LRU_ACTIVE_ANON] +
+	show_name_pages_kb(m, "MemTotal:       ", i.totalram);
+	show_name_pages_kb(m, "MemFree:        ", i.freeram);
+	show_name_pages_kb(m, "MemAvailable:   ", available);
+	show_name_pages_kb(m, "Buffers:        ", i.bufferram);
+	show_name_pages_kb(m, "Cached:         ", cached);
+	show_name_pages_kb(m, "SwapCached:     ", total_swapcache_pages());
+	show_name_pages_kb(m, "Active:         ", pages[LRU_ACTIVE_ANON] +
 					   pages[LRU_ACTIVE_FILE]);
-	show_val_kb(m, "Inactive:       ", pages[LRU_INACTIVE_ANON] +
+	show_name_pages_kb(m, "Inactive:       ", pages[LRU_INACTIVE_ANON] +
 					   pages[LRU_INACTIVE_FILE]);
-	show_val_kb(m, "Active(anon):   ", pages[LRU_ACTIVE_ANON]);
-	show_val_kb(m, "Inactive(anon): ", pages[LRU_INACTIVE_ANON]);
-	show_val_kb(m, "Active(file):   ", pages[LRU_ACTIVE_FILE]);
-	show_val_kb(m, "Inactive(file): ", pages[LRU_INACTIVE_FILE]);
-	show_val_kb(m, "Unevictable:    ", pages[LRU_UNEVICTABLE]);
-	show_val_kb(m, "Mlocked:        ", global_page_state(NR_MLOCK));
+	show_name_pages_kb(m, "Active(anon):   ", pages[LRU_ACTIVE_ANON]);
+	show_name_pages_kb(m, "Inactive(anon): ", pages[LRU_INACTIVE_ANON]);
+	show_name_pages_kb(m, "Active(file):   ", pages[LRU_ACTIVE_FILE]);
+	show_name_pages_kb(m, "Inactive(file): ", pages[LRU_INACTIVE_FILE]);
+	show_name_pages_kb(m, "Unevictable:    ", pages[LRU_UNEVICTABLE]);
+	show_name_pages_kb(m, "Mlocked:        ", global_page_state(NR_MLOCK));
 
 #ifdef CONFIG_HIGHMEM
-	show_val_kb(m, "HighTotal:      ", i.totalhigh);
-	show_val_kb(m, "HighFree:       ", i.freehigh);
-	show_val_kb(m, "LowTotal:       ", i.totalram - i.totalhigh);
-	show_val_kb(m, "LowFree:        ", i.freeram - i.freehigh);
+	show_name_pages_kb(m, "HighTotal:      ", i.totalhigh);
+	show_name_pages_kb(m, "HighFree:       ", i.freehigh);
+	show_name_pages_kb(m, "LowTotal:       ", i.totalram - i.totalhigh);
+	show_name_pages_kb(m, "LowFree:        ", i.freeram - i.freehigh);
 #endif
 
 #ifndef CONFIG_MMU
-	show_val_kb(m, "MmapCopy:       ",
+	show_name_pages_kb(m, "MmapCopy:       ",
 		    (unsigned long)atomic_long_read(&mmap_pages_allocated));
 #endif
 
-	show_val_kb(m, "SwapTotal:      ", i.totalswap);
-	show_val_kb(m, "SwapFree:       ", i.freeswap);
-	show_val_kb(m, "Dirty:          ",
+	show_name_pages_kb(m, "SwapTotal:      ", i.totalswap);
+	show_name_pages_kb(m, "SwapFree:       ", i.freeswap);
+	show_name_pages_kb(m, "Dirty:          ",
 		    global_node_page_state(NR_FILE_DIRTY));
-	show_val_kb(m, "Writeback:      ",
+	show_name_pages_kb(m, "Writeback:      ",
 		    global_node_page_state(NR_WRITEBACK));
-	show_val_kb(m, "AnonPages:      ",
+	show_name_pages_kb(m, "AnonPages:      ",
 		    global_node_page_state(NR_ANON_MAPPED));
-	show_val_kb(m, "Mapped:         ",
+	show_name_pages_kb(m, "Mapped:         ",
 		    global_node_page_state(NR_FILE_MAPPED));
-	show_val_kb(m, "Shmem:          ", i.sharedram);
-	show_val_kb(m, "Slab:           ",
+	show_name_pages_kb(m, "Shmem:          ", i.sharedram);
+	show_name_pages_kb(m, "Slab:           ",
 		    global_page_state(NR_SLAB_RECLAIMABLE) +
 		    global_page_state(NR_SLAB_UNRECLAIMABLE));
 
-	show_val_kb(m, "SReclaimable:   ",
+	show_name_pages_kb(m, "SReclaimable:   ",
 		    global_page_state(NR_SLAB_RECLAIMABLE));
-	show_val_kb(m, "SUnreclaim:     ",
+	show_name_pages_kb(m, "SUnreclaim:     ",
 		    global_page_state(NR_SLAB_UNRECLAIMABLE));
 	seq_printf(m, "KernelStack:    %8lu kB\n",
 		   global_page_state(NR_KERNEL_STACK_KB));
-	show_val_kb(m, "PageTables:     ",
+	show_name_pages_kb(m, "PageTables:     ",
 		    global_page_state(NR_PAGETABLE));
 #ifdef CONFIG_QUICKLIST
-	show_val_kb(m, "Quicklists:     ", quicklist_total_size());
+	show_name_pages_kb(m, "Quicklists:     ", quicklist_total_size());
 #endif
 
-	show_val_kb(m, "NFS_Unstable:   ",
+	show_name_pages_kb(m, "NFS_Unstable:   ",
 		    global_node_page_state(NR_UNSTABLE_NFS));
-	show_val_kb(m, "Bounce:         ",
+	show_name_pages_kb(m, "Bounce:         ",
 		    global_page_state(NR_BOUNCE));
-	show_val_kb(m, "WritebackTmp:   ",
+	show_name_pages_kb(m, "WritebackTmp:   ",
 		    global_node_page_state(NR_WRITEBACK_TEMP));
-	show_val_kb(m, "CommitLimit:    ", vm_commit_limit());
-	show_val_kb(m, "Committed_AS:   ", committed);
+	show_name_pages_kb(m, "CommitLimit:    ", vm_commit_limit());
+	show_name_pages_kb(m, "Committed_AS:   ", committed);
 	seq_printf(m, "VmallocTotal:   %8lu kB\n",
 		   (unsigned long)VMALLOC_TOTAL >> 10);
-	show_val_kb(m, "VmallocUsed:    ", 0ul);
-	show_val_kb(m, "VmallocChunk:   ", 0ul);
+	show_name_pages_kb(m, "VmallocUsed:    ", 0ul);
+	show_name_pages_kb(m, "VmallocChunk:   ", 0ul);
 
 #ifdef CONFIG_MEMORY_FAILURE
 	seq_printf(m, "HardwareCorrupted: %5lu kB\n",
@@ -140,17 +137,17 @@ static int meminfo_proc_show(struct seq_file *m, void *v)
 #endif
 
 #ifdef CONFIG_TRANSPARENT_HUGEPAGE
-	show_val_kb(m, "AnonHugePages:  ",
+	show_name_pages_kb(m, "AnonHugePages:  ",
 		    global_node_page_state(NR_ANON_THPS) * HPAGE_PMD_NR);
-	show_val_kb(m, "ShmemHugePages: ",
+	show_name_pages_kb(m, "ShmemHugePages: ",
 		    global_node_page_state(NR_SHMEM_THPS) * HPAGE_PMD_NR);
-	show_val_kb(m, "ShmemPmdMapped: ",
+	show_name_pages_kb(m, "ShmemPmdMapped: ",
 		    global_node_page_state(NR_SHMEM_PMDMAPPED) * HPAGE_PMD_NR);
 #endif
 
 #ifdef CONFIG_CMA
-	show_val_kb(m, "CmaTotal:       ", totalcma_pages);
-	show_val_kb(m, "CmaFree:        ",
+	show_name_pages_kb(m, "CmaTotal:       ", totalcma_pages);
+	show_name_pages_kb(m, "CmaFree:        ",
 		    global_page_state(NR_FREE_CMA_PAGES));
 #endif
 
-- 
2.8.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

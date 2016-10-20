Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f72.google.com (mail-lf0-f72.google.com [209.85.215.72])
	by kanga.kvack.org (Postfix) with ESMTP id BA5D66B0038
	for <linux-mm@kvack.org>; Thu, 20 Oct 2016 08:12:04 -0400 (EDT)
Received: by mail-lf0-f72.google.com with SMTP id f134so3150316lfg.6
        for <linux-mm@kvack.org>; Thu, 20 Oct 2016 05:12:04 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id q6si48811683wjr.172.2016.10.20.05.12.03
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 20 Oct 2016 05:12:03 -0700 (PDT)
From: Vlastimil Babka <vbabka@suse.cz>
Subject: [RFC] fs/proc/meminfo: introduce Unaccounted statistic
Date: Thu, 20 Oct 2016 14:11:49 +0200
Message-Id: <20161020121149.9935-1-vbabka@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Vlastimil Babka <vbabka@suse.cz>, Michal Hocko <mhocko@suse.com>, Mel Gorman <mgorman@techsingularity.net>, Johannes Weiner <hannes@cmpxchg.org>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Hugh Dickins <hughd@google.com>, David Rientjes <rientjes@google.com>

The /proc/meminfo virtual file is a collection of various system-wide memory
usage statistics. One of the use cases for looking at the output is to see
whether the kernel might be leaking memory by direct allocations that are not
counted among any of the statistics. This is hovewer not immediately obvious,
because some fields are meant to add up to the MemTotal value, and others not.
Subtle changes also happen over time, e.g. the AnonPages field started
including THP's since commit 3cd14fcd3f12 ("thp: account anon transparent
huge pages into NR_ANON_PAGES") and the Cached field used to include hugetlb
until commit 4165b9b46181 ("hugetlb: do not account hugetlb pages as
NR_FILE_PAGES").

To make kernel memory leaks more obvious, this patch adds an Unaccounted field
whose value is calculated by subtracting a sum of fields that are supposed to
add up to MemTotal without overlap, from the MeTotal value. This should also
help anyone looking at the code to determine these fields easily.

Not-yet-signed-off-by: Vlastimil Babka <vbabka@suse.cz>
Cc: Michal Hocko <mhocko@suse.com>
Cc: Mel Gorman <mgorman@techsingularity.net>
Cc: Johannes Weiner <hannes@cmpxchg.org>
Cc: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Cc: Hugh Dickins <hughd@google.com>
Cc: David Rientjes <rientjes@google.com>
---
Hi, I'm wondering if people would find this useful. If you think it is, and
to not make performance worse, I could also make sure in proper submission
that values are not read via global_page_state() multiple times etc...

 fs/proc/meminfo.c | 18 ++++++++++++++++++
 1 file changed, 18 insertions(+)

diff --git a/fs/proc/meminfo.c b/fs/proc/meminfo.c
index 8a428498d6b2..3fcd71d4d805 100644
--- a/fs/proc/meminfo.c
+++ b/fs/proc/meminfo.c
@@ -48,6 +48,7 @@ static int meminfo_proc_show(struct seq_file *m, void *v)
 	unsigned long committed;
 	long cached;
 	long available;
+	long unaccounted;
 	unsigned long pages[NR_LRU_LISTS];
 	int lru;
 
@@ -65,6 +66,18 @@ static int meminfo_proc_show(struct seq_file *m, void *v)
 
 	available = si_mem_available();
 
+	unaccounted = i.totalram - i.freeram
+			- global_node_page_state(NR_ANON_MAPPED)
+			- global_node_page_state(NR_FILE_PAGES)
+			- global_page_state(NR_PAGETABLE)
+			- global_page_state(NR_SLAB_RECLAIMABLE)
+			- global_page_state(NR_SLAB_UNRECLAIMABLE)
+			- (global_page_state(NR_KERNEL_STACK_KB)
+							>> (PAGE_SHIFT - 10))
+			- global_page_state(NR_BOUNCE)
+			- global_node_page_state(NR_WRITEBACK_TEMP)
+			- hugetlb_total_pages();
+
 	show_val_kb(m, "MemTotal:       ", i.totalram);
 	show_val_kb(m, "MemFree:        ", i.freeram);
 	show_val_kb(m, "MemAvailable:   ", available);
@@ -119,6 +132,7 @@ static int meminfo_proc_show(struct seq_file *m, void *v)
 		    global_page_state(NR_PAGETABLE));
 #ifdef CONFIG_QUICKLIST
 	show_val_kb(m, "Quicklists:     ", quicklist_total_size());
+	unaccounted -= quicklist_total_size();
 #endif
 
 	show_val_kb(m, "NFS_Unstable:   ",
@@ -156,6 +170,10 @@ static int meminfo_proc_show(struct seq_file *m, void *v)
 
 	hugetlb_report_meminfo(m);
 
+	if (unaccounted < 0)
+		unaccounted = 0;
+	show_val_kb(m, "Unaccounted:    ", unaccounted);
+
 	arch_report_meminfo(m);
 
 	return 0;
-- 
2.10.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

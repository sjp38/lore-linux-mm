Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf1-f198.google.com (mail-pf1-f198.google.com [209.85.210.198])
	by kanga.kvack.org (Postfix) with ESMTP id 763AB8E0001
	for <linux-mm@kvack.org>; Fri, 11 Jan 2019 00:13:55 -0500 (EST)
Received: by mail-pf1-f198.google.com with SMTP id i3so9496944pfj.4
        for <linux-mm@kvack.org>; Thu, 10 Jan 2019 21:13:55 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id w11sor1629716ply.14.2019.01.10.21.13.54
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 10 Jan 2019 21:13:54 -0800 (PST)
From: Pingfan Liu <kernelfans@gmail.com>
Subject: [PATCHv2 5/7] x86/mm: set allowed range for memblock allocator
Date: Fri, 11 Jan 2019 13:12:55 +0800
Message-Id: <1547183577-20309-6-git-send-email-kernelfans@gmail.com>
In-Reply-To: <1547183577-20309-1-git-send-email-kernelfans@gmail.com>
References: <1547183577-20309-1-git-send-email-kernelfans@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: Pingfan Liu <kernelfans@gmail.com>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, Borislav Petkov <bp@alien8.de>, "H. Peter Anvin" <hpa@zytor.com>, Dave Hansen <dave.hansen@linux.intel.com>, Andy Lutomirski <luto@kernel.org>, Peter Zijlstra <peterz@infradead.org>, "Rafael J. Wysocki" <rjw@rjwysocki.net>, Len Brown <lenb@kernel.org>, Yinghai Lu <yinghai@kernel.org>, Tejun Heo <tj@kernel.org>, Chao Fan <fanc.fnst@cn.fujitsu.com>, Baoquan He <bhe@redhat.com>, Juergen Gross <jgross@suse.com>, Andrew Morton <akpm@linux-foundation.org>, Mike Rapoport <rppt@linux.vnet.ibm.com>, Vlastimil Babka <vbabka@suse.cz>, Michal Hocko <mhocko@suse.com>, x86@kernel.org, linux-acpi@vger.kernel.org, linux-mm@kvack.org

Due to the incoming divergence of x86_32 and x86_64, there is requirement
to set the allowed allocating range at the early boot stage.
This patch also includes minor change to remove redundat cond check, refer
to memblock_find_in_range_node(), memblock_find_in_range() has already
protect itself from the case: start > end.

Signed-off-by: Pingfan Liu <kernelfans@gmail.com>
Cc: Thomas Gleixner <tglx@linutronix.de>
Cc: Ingo Molnar <mingo@redhat.com>
Cc: Borislav Petkov <bp@alien8.de>
Cc: "H. Peter Anvin" <hpa@zytor.com>
Cc: Dave Hansen <dave.hansen@linux.intel.com>
Cc: Andy Lutomirski <luto@kernel.org>
Cc: Peter Zijlstra <peterz@infradead.org>
Cc: "Rafael J. Wysocki" <rjw@rjwysocki.net>
Cc: Len Brown <lenb@kernel.org>
Cc: Yinghai Lu <yinghai@kernel.org>
Cc: Tejun Heo <tj@kernel.org>
Cc: Chao Fan <fanc.fnst@cn.fujitsu.com>
Cc: Baoquan He <bhe@redhat.com>
Cc: Juergen Gross <jgross@suse.com>
Cc: Andrew Morton <akpm@linux-foundation.org>
Cc: Mike Rapoport <rppt@linux.vnet.ibm.com>
Cc: Vlastimil Babka <vbabka@suse.cz>
Cc: Michal Hocko <mhocko@suse.com>
Cc: x86@kernel.org
Cc: linux-acpi@vger.kernel.org
Cc: linux-mm@kvack.org
---
 arch/x86/mm/init.c | 24 +++++++++++++++++-------
 1 file changed, 17 insertions(+), 7 deletions(-)

diff --git a/arch/x86/mm/init.c b/arch/x86/mm/init.c
index ef99f38..385b9cd 100644
--- a/arch/x86/mm/init.c
+++ b/arch/x86/mm/init.c
@@ -76,6 +76,14 @@ static unsigned long min_pfn_mapped;
 
 static bool __initdata can_use_brk_pgt = true;
 
+static unsigned long min_pfn_allowed;
+static unsigned long max_pfn_allowed;
+void set_alloc_range(unsigned long low, unsigned long high)
+{
+	min_pfn_allowed = low;
+	max_pfn_allowed = high;
+}
+
 /*
  * Pages returned are already directly mapped.
  *
@@ -100,12 +108,10 @@ __ref void *alloc_low_pages(unsigned int num)
 	if ((pgt_buf_end + num) > pgt_buf_top || !can_use_brk_pgt) {
 		unsigned long ret = 0;
 
-		if (min_pfn_mapped < max_pfn_mapped) {
-			ret = memblock_find_in_range(
-					min_pfn_mapped << PAGE_SHIFT,
-					max_pfn_mapped << PAGE_SHIFT,
-					PAGE_SIZE * num , PAGE_SIZE);
-		}
+		ret = memblock_find_in_range(
+			min_pfn_allowed << PAGE_SHIFT,
+			max_pfn_allowed << PAGE_SHIFT,
+			PAGE_SIZE * num, PAGE_SIZE);
 		if (ret)
 			memblock_reserve(ret, PAGE_SIZE * num);
 		else if (can_use_brk_pgt)
@@ -588,14 +594,17 @@ static void __init memory_map_top_down(unsigned long map_start,
 			start = map_start;
 		mapped_ram_size += init_range_memory_mapping(start,
 							last_start);
+		set_alloc_range(min_pfn_mapped, max_pfn_mapped);
 		last_start = start;
 		min_pfn_mapped = last_start >> PAGE_SHIFT;
 		if (mapped_ram_size >= step_size)
 			step_size = get_new_step_size(step_size);
 	}
 
-	if (real_end < map_end)
+	if (real_end < map_end) {
 		init_range_memory_mapping(real_end, map_end);
+		set_alloc_range(min_pfn_mapped, max_pfn_mapped);
+	}
 }
 
 /**
@@ -636,6 +645,7 @@ static void __init memory_map_bottom_up(unsigned long map_start,
 		}
 
 		mapped_ram_size += init_range_memory_mapping(start, next);
+		set_alloc_range(min_pfn_mapped, max_pfn_mapped);
 		start = next;
 
 		if (mapped_ram_size >= step_size)
-- 
2.7.4

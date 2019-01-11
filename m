Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl1-f200.google.com (mail-pl1-f200.google.com [209.85.214.200])
	by kanga.kvack.org (Postfix) with ESMTP id 245958E0001
	for <linux-mm@kvack.org>; Fri, 11 Jan 2019 00:14:03 -0500 (EST)
Received: by mail-pl1-f200.google.com with SMTP id m13so7604959pls.15
        for <linux-mm@kvack.org>; Thu, 10 Jan 2019 21:14:03 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id l189sor53290759pgd.51.2019.01.10.21.14.01
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 10 Jan 2019 21:14:01 -0800 (PST)
From: Pingfan Liu <kernelfans@gmail.com>
Subject: [PATCHv2 6/7] x86/mm: remove bottom-up allocation style for x86_64
Date: Fri, 11 Jan 2019 13:12:56 +0800
Message-Id: <1547183577-20309-7-git-send-email-kernelfans@gmail.com>
In-Reply-To: <1547183577-20309-1-git-send-email-kernelfans@gmail.com>
References: <1547183577-20309-1-git-send-email-kernelfans@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: Pingfan Liu <kernelfans@gmail.com>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, Borislav Petkov <bp@alien8.de>, "H. Peter Anvin" <hpa@zytor.com>, Dave Hansen <dave.hansen@linux.intel.com>, Andy Lutomirski <luto@kernel.org>, Peter Zijlstra <peterz@infradead.org>, "Rafael J. Wysocki" <rjw@rjwysocki.net>, Len Brown <lenb@kernel.org>, Yinghai Lu <yinghai@kernel.org>, Tejun Heo <tj@kernel.org>, Chao Fan <fanc.fnst@cn.fujitsu.com>, Baoquan He <bhe@redhat.com>, Juergen Gross <jgross@suse.com>, Andrew Morton <akpm@linux-foundation.org>, Mike Rapoport <rppt@linux.vnet.ibm.com>, Vlastimil Babka <vbabka@suse.cz>, Michal Hocko <mhocko@suse.com>, x86@kernel.org, linux-acpi@vger.kernel.org, linux-mm@kvack.org

Although kaslr-kernel can avoid to stain the movable node. [1] But the
pgtable can still stain the movable node. That is a probability problem,
although low, but exist. This patch tries to make it certainty by
allocating pgtable on unmovable node, instead of following kernel end.
There are two acheivements by this patch:
-1st. keep the subtree of pgtable away from movable node.
With the previous patch, at the point of init_mem_mapping(),
memblock allocator can work with the knowledge of acpi memory hotmovable
info, and avoid to stain the movable node. As a result,
memory_map_bottom_up() is not needed any more.
The following figure show the defection of current bottom-up style:
  [startA, endA][startB, "kaslr kernel verly close to" endB][startC, endC]
If nodeA,B is unmovable, while nodeC is movable, then init_mem_mapping()
can generate pgtable on nodeC, which stain movable node.
For more lengthy background, please refer to Background section

-2nd. simplify the logic of memory_map_top_down()
Thanks to the help of early_make_pgtable(), x86_64 can directly set up the
subtree of pgtable at any place, hence the careful iteration in
memory_map_top_down() can be discard.

*Background section*
When kaslr kernel can be guaranteed to sit inside unmovable node
after [1]. But if kaslr kernel is located near the end of the movable node,
then bottom-up allocator may create pagetable which crosses the boundary
between unmovable node and movable node.  It is a probability issue,
two factors include -1. how big the gap between kernel end and
unmovable node's end.  -2. how many memory does the system own.
Alternative way to fix this issue is by increasing the gap by
boot/compressed/kaslr*. But taking the scenario of PB level memory,
the pagetable will take server MB even if using 1GB page, different page
attr and fragment will make things worse. So it is hard to decide how much
should the gap increase.

[1]: https://lore.kernel.org/patchwork/patch/1029376/
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
 arch/x86/kernel/setup.c |  4 ++--
 arch/x86/mm/init.c      | 56 ++++++++++++++++++++++++++++++-------------------
 2 files changed, 36 insertions(+), 24 deletions(-)

diff --git a/arch/x86/kernel/setup.c b/arch/x86/kernel/setup.c
index 9b57e01..00a1b84 100644
--- a/arch/x86/kernel/setup.c
+++ b/arch/x86/kernel/setup.c
@@ -827,7 +827,7 @@ static void early_acpi_parse(void)
 	early_acpi_boot_init();
 	initmem_init();
 	/* check whether memory is returned or not */
-	start = memblock_find_in_range(start, end, 1<<24, 1);
+	start = memblock_find_in_range(start, end, 1 << 24, 1);
 	if (!start)
 		pr_warn("the above acpi routines change and consume memory\n");
 	memblock_set_current_limit(orig_start, orig_end, enforcing);
@@ -1135,7 +1135,7 @@ void __init setup_arch(char **cmdline_p)
 	trim_platform_memory_ranges();
 	trim_low_memory_range();
 
-#ifdef CONFIG_MEMORY_HOTPLUG
+#if defined(CONFIG_MEMORY_HOTPLUG) && defined(CONFIG_X86_32)
 	/*
 	 * Memory used by the kernel cannot be hot-removed because Linux
 	 * cannot migrate the kernel pages. When memory hotplug is
diff --git a/arch/x86/mm/init.c b/arch/x86/mm/init.c
index 385b9cd..003ad77 100644
--- a/arch/x86/mm/init.c
+++ b/arch/x86/mm/init.c
@@ -72,8 +72,6 @@ static unsigned long __initdata pgt_buf_start;
 static unsigned long __initdata pgt_buf_end;
 static unsigned long __initdata pgt_buf_top;
 
-static unsigned long min_pfn_mapped;
-
 static bool __initdata can_use_brk_pgt = true;
 
 static unsigned long min_pfn_allowed;
@@ -532,6 +530,10 @@ static unsigned long __init init_range_memory_mapping(
 	return mapped_ram_size;
 }
 
+#ifdef CONFIG_X86_32
+
+static unsigned long min_pfn_mapped;
+
 static unsigned long __init get_new_step_size(unsigned long step_size)
 {
 	/*
@@ -653,6 +655,32 @@ static void __init memory_map_bottom_up(unsigned long map_start,
 	}
 }
 
+static unsigned long __init init_range_memory_mapping32(
+	unsigned long r_start, unsigned long r_end)
+{
+	/*
+	 * If the allocation is in bottom-up direction, we setup direct mapping
+	 * in bottom-up, otherwise we setup direct mapping in top-down.
+	 */
+	if (memblock_bottom_up()) {
+		unsigned long kernel_end = __pa_symbol(_end);
+
+		/*
+		 * we need two separate calls here. This is because we want to
+		 * allocate page tables above the kernel. So we first map
+		 * [kernel_end, end) to make memory above the kernel be mapped
+		 * as soon as possible. And then use page tables allocated above
+		 * the kernel to map [ISA_END_ADDRESS, kernel_end).
+		 */
+		memory_map_bottom_up(kernel_end, r_end);
+		memory_map_bottom_up(r_start, kernel_end);
+	} else {
+		memory_map_top_down(r_start, r_end);
+	}
+}
+
+#endif
+
 void __init init_mem_mapping(void)
 {
 	unsigned long end;
@@ -663,6 +691,8 @@ void __init init_mem_mapping(void)
 
 #ifdef CONFIG_X86_64
 	end = max_pfn << PAGE_SHIFT;
+	/* allow alloc_low_pages() to allocate from memblock */
+	set_alloc_range(ISA_END_ADDRESS, end);
 #else
 	end = max_low_pfn << PAGE_SHIFT;
 #endif
@@ -673,32 +703,14 @@ void __init init_mem_mapping(void)
 	/* Init the trampoline, possibly with KASLR memory offset */
 	init_trampoline();
 
-	/*
-	 * If the allocation is in bottom-up direction, we setup direct mapping
-	 * in bottom-up, otherwise we setup direct mapping in top-down.
-	 */
-	if (memblock_bottom_up()) {
-		unsigned long kernel_end = __pa_symbol(_end);
-
-		/*
-		 * we need two separate calls here. This is because we want to
-		 * allocate page tables above the kernel. So we first map
-		 * [kernel_end, end) to make memory above the kernel be mapped
-		 * as soon as possible. And then use page tables allocated above
-		 * the kernel to map [ISA_END_ADDRESS, kernel_end).
-		 */
-		memory_map_bottom_up(kernel_end, end);
-		memory_map_bottom_up(ISA_END_ADDRESS, kernel_end);
-	} else {
-		memory_map_top_down(ISA_END_ADDRESS, end);
-	}
-
 #ifdef CONFIG_X86_64
+	init_range_memory_mapping(ISA_END_ADDRESS, end);
 	if (max_pfn > max_low_pfn) {
 		/* can we preseve max_low_pfn ?*/
 		max_low_pfn = max_pfn;
 	}
 #else
+	init_range_memory_mapping32(ISA_END_ADDRESS, end);
 	early_ioremap_page_table_range_init();
 #endif
 
-- 
2.7.4

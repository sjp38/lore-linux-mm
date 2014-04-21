Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pb0-f51.google.com (mail-pb0-f51.google.com [209.85.160.51])
	by kanga.kvack.org (Postfix) with ESMTP id 6271A6B003A
	for <linux-mm@kvack.org>; Mon, 21 Apr 2014 14:24:28 -0400 (EDT)
Received: by mail-pb0-f51.google.com with SMTP id uo5so3964893pbc.24
        for <linux-mm@kvack.org>; Mon, 21 Apr 2014 11:24:23 -0700 (PDT)
Received: from mga09.intel.com (mga09.intel.com. [134.134.136.24])
        by mx.google.com with ESMTP id se7si21291423pbb.139.2014.04.21.11.24.22
        for <linux-mm@kvack.org>;
        Mon, 21 Apr 2014 11:24:22 -0700 (PDT)
Subject: [PATCH 2/6] x86: mm: rip out complicated, out-of-date, buggy TLB flushing
From: Dave Hansen <dave@sr71.net>
Date: Mon, 21 Apr 2014 11:24:21 -0700
References: <20140421182418.81CF7519@viggo.jf.intel.com>
In-Reply-To: <20140421182418.81CF7519@viggo.jf.intel.com>
Message-Id: <20140421182421.DFAAD16A@viggo.jf.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: x86@kernel.org
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, akpm@linux-foundation.org, kirill.shutemov@linux.intel.com, mgorman@suse.de, ak@linux.intel.com, riel@redhat.com, alex.shi@linaro.org, Dave Hansen <dave@sr71.net>, dave.hansen@linux.intel.com


From: Dave Hansen <dave.hansen@linux.intel.com>

I think the flush_tlb_mm_range() code that tries to tune the
flush sizes based on the CPU needs to get ripped out for
several reasons:

1. It is obviously buggy.  It uses mm->total_vm to judge the
   task's footprint in the TLB.  It should certainly be using
   some measure of RSS, *NOT* ->total_vm since only resident
   memory can populate the TLB.
2. Haswell, and several other CPUs are missing from the
   intel_tlb_flushall_shift_set() function.  Thus, it has been
   demonstrated to bitrot quickly in practice.
3. It is plain wrong in my vm:
	[    0.037444] Last level iTLB entries: 4KB 0, 2MB 0, 4MB 0
	[    0.037444] Last level dTLB entries: 4KB 0, 2MB 0, 4MB 0
	[    0.037444] tlb_flushall_shift: 6
   Which leads to it to never use invlpg.
4. The assumptions about TLB refill costs are wrong:
	http://lkml.kernel.org/r/1337782555-8088-3-git-send-email-alex.shi@intel.com
    (more on this in later patches)
5. I can not reproduce the original data: https://lkml.org/lkml/2012/5/17/59
   I believe the sample times were too short.  Running the
   benchmark in a loop yields times that vary quite a bit.

Note that this leaves us with a static ceiling of 1 page.  This
is a conservative, dumb setting, and will be revised in a later
patch.

Signed-off-by: Dave Hansen <dave.hansen@linux.intel.com>
---

 b/arch/x86/include/asm/processor.h |    1 
 b/arch/x86/kernel/cpu/amd.c        |    7 --
 b/arch/x86/kernel/cpu/common.c     |   13 -----
 b/arch/x86/kernel/cpu/intel.c      |   26 ----------
 b/arch/x86/mm/tlb.c                |   91 ++++++-------------------------------
 5 files changed, 19 insertions(+), 119 deletions(-)

diff -puN arch/x86/include/asm/processor.h~x8x-mm-rip-out-complicated-tlb-flushing arch/x86/include/asm/processor.h
--- a/arch/x86/include/asm/processor.h~x8x-mm-rip-out-complicated-tlb-flushing	2014-04-21 11:10:34.813835861 -0700
+++ b/arch/x86/include/asm/processor.h	2014-04-21 11:10:34.823836313 -0700
@@ -72,7 +72,6 @@ extern u16 __read_mostly tlb_lld_4k[NR_I
 extern u16 __read_mostly tlb_lld_2m[NR_INFO];
 extern u16 __read_mostly tlb_lld_4m[NR_INFO];
 extern u16 __read_mostly tlb_lld_1g[NR_INFO];
-extern s8  __read_mostly tlb_flushall_shift;
 
 /*
  *  CPU type and hardware bug flags. Kept separately for each CPU.
diff -puN arch/x86/kernel/cpu/amd.c~x8x-mm-rip-out-complicated-tlb-flushing arch/x86/kernel/cpu/amd.c
--- a/arch/x86/kernel/cpu/amd.c~x8x-mm-rip-out-complicated-tlb-flushing	2014-04-21 11:10:34.814835907 -0700
+++ b/arch/x86/kernel/cpu/amd.c	2014-04-21 11:10:34.824836358 -0700
@@ -741,11 +741,6 @@ static unsigned int amd_size_cache(struc
 }
 #endif
 
-static void cpu_set_tlb_flushall_shift(struct cpuinfo_x86 *c)
-{
-	tlb_flushall_shift = 6;
-}
-
 static void cpu_detect_tlb_amd(struct cpuinfo_x86 *c)
 {
 	u32 ebx, eax, ecx, edx;
@@ -793,8 +788,6 @@ static void cpu_detect_tlb_amd(struct cp
 		tlb_lli_2m[ENTRIES] = eax & mask;
 
 	tlb_lli_4m[ENTRIES] = tlb_lli_2m[ENTRIES] >> 1;
-
-	cpu_set_tlb_flushall_shift(c);
 }
 
 static const struct cpu_dev amd_cpu_dev = {
diff -puN arch/x86/kernel/cpu/common.c~x8x-mm-rip-out-complicated-tlb-flushing arch/x86/kernel/cpu/common.c
--- a/arch/x86/kernel/cpu/common.c~x8x-mm-rip-out-complicated-tlb-flushing	2014-04-21 11:10:34.816835998 -0700
+++ b/arch/x86/kernel/cpu/common.c	2014-04-21 11:10:34.825836403 -0700
@@ -479,26 +479,17 @@ u16 __read_mostly tlb_lld_2m[NR_INFO];
 u16 __read_mostly tlb_lld_4m[NR_INFO];
 u16 __read_mostly tlb_lld_1g[NR_INFO];
 
-/*
- * tlb_flushall_shift shows the balance point in replacing cr3 write
- * with multiple 'invlpg'. It will do this replacement when
- *   flush_tlb_lines <= active_lines/2^tlb_flushall_shift.
- * If tlb_flushall_shift is -1, means the replacement will be disabled.
- */
-s8  __read_mostly tlb_flushall_shift = -1;
-
 void cpu_detect_tlb(struct cpuinfo_x86 *c)
 {
 	if (this_cpu->c_detect_tlb)
 		this_cpu->c_detect_tlb(c);
 
 	printk(KERN_INFO "Last level iTLB entries: 4KB %d, 2MB %d, 4MB %d\n"
-		"Last level dTLB entries: 4KB %d, 2MB %d, 4MB %d, 1GB %d\n"
-		"tlb_flushall_shift: %d\n",
+		"Last level dTLB entries: 4KB %d, 2MB %d, 4MB %d, 1GB %d\n",
 		tlb_lli_4k[ENTRIES], tlb_lli_2m[ENTRIES],
 		tlb_lli_4m[ENTRIES], tlb_lld_4k[ENTRIES],
 		tlb_lld_2m[ENTRIES], tlb_lld_4m[ENTRIES],
-		tlb_lld_1g[ENTRIES], tlb_flushall_shift);
+		tlb_lld_1g[ENTRIES]);
 }
 
 void detect_ht(struct cpuinfo_x86 *c)
diff -puN arch/x86/kernel/cpu/intel.c~x8x-mm-rip-out-complicated-tlb-flushing arch/x86/kernel/cpu/intel.c
--- a/arch/x86/kernel/cpu/intel.c~x8x-mm-rip-out-complicated-tlb-flushing	2014-04-21 11:10:34.818836088 -0700
+++ b/arch/x86/kernel/cpu/intel.c	2014-04-21 11:10:34.825836403 -0700
@@ -634,31 +634,6 @@ static void intel_tlb_lookup(const unsig
 	}
 }
 
-static void intel_tlb_flushall_shift_set(struct cpuinfo_x86 *c)
-{
-	switch ((c->x86 << 8) + c->x86_model) {
-	case 0x60f: /* original 65 nm celeron/pentium/core2/xeon, "Merom"/"Conroe" */
-	case 0x616: /* single-core 65 nm celeron/core2solo "Merom-L"/"Conroe-L" */
-	case 0x617: /* current 45 nm celeron/core2/xeon "Penryn"/"Wolfdale" */
-	case 0x61d: /* six-core 45 nm xeon "Dunnington" */
-		tlb_flushall_shift = -1;
-		break;
-	case 0x63a: /* Ivybridge */
-		tlb_flushall_shift = 2;
-		break;
-	case 0x61a: /* 45 nm nehalem, "Bloomfield" */
-	case 0x61e: /* 45 nm nehalem, "Lynnfield" */
-	case 0x625: /* 32 nm nehalem, "Clarkdale" */
-	case 0x62c: /* 32 nm nehalem, "Gulftown" */
-	case 0x62e: /* 45 nm nehalem-ex, "Beckton" */
-	case 0x62f: /* 32 nm Xeon E7 */
-	case 0x62a: /* SandyBridge */
-	case 0x62d: /* SandyBridge, "Romely-EP" */
-	default:
-		tlb_flushall_shift = 6;
-	}
-}
-
 static void intel_detect_tlb(struct cpuinfo_x86 *c)
 {
 	int i, j, n;
@@ -683,7 +658,6 @@ static void intel_detect_tlb(struct cpui
 		for (j = 1 ; j < 16 ; j++)
 			intel_tlb_lookup(desc[j]);
 	}
-	intel_tlb_flushall_shift_set(c);
 }
 
 static const struct cpu_dev intel_cpu_dev = {
diff -puN arch/x86/mm/tlb.c~x8x-mm-rip-out-complicated-tlb-flushing arch/x86/mm/tlb.c
--- a/arch/x86/mm/tlb.c~x8x-mm-rip-out-complicated-tlb-flushing	2014-04-21 11:10:34.820836178 -0700
+++ b/arch/x86/mm/tlb.c	2014-04-21 11:10:34.826836449 -0700
@@ -158,13 +158,22 @@ void flush_tlb_current_task(void)
 	preempt_enable();
 }
 
+/*
+ * See Documentation/x86/tlb.txt for details.  We choose 33
+ * because it is large enough to cover the vast majority (at
+ * least 95%) of allocations, and is small enough that we are
+ * confident it will not cause too much overhead.  Each single
+ * flush is about 100 cycles, so this caps the maximum overhead
+ * at _about_ 3,000 cycles.
+ */
+/* in units of pages */
+unsigned long tlb_single_page_flush_ceiling = 1;
+
 void flush_tlb_mm_range(struct mm_struct *mm, unsigned long start,
 				unsigned long end, unsigned long vmflag)
 {
 	int need_flush_others_all = 1;
 	unsigned long addr;
-	unsigned act_entries, tlb_entries = 0;
-	unsigned long nr_base_pages;
 
 	preempt_disable();
 	if (current->active_mm != mm)
@@ -175,25 +184,12 @@ void flush_tlb_mm_range(struct mm_struct
 		goto out;
 	}
 
-	if (end == TLB_FLUSH_ALL || tlb_flushall_shift == -1
-					|| vmflag & VM_HUGETLB) {
+	if (end == TLB_FLUSH_ALL || vmflag & VM_HUGETLB) {
 		local_flush_tlb();
 		goto out;
 	}
 
-	/* In modern CPU, last level tlb used for both data/ins */
-	if (vmflag & VM_EXEC)
-		tlb_entries = tlb_lli_4k[ENTRIES];
-	else
-		tlb_entries = tlb_lld_4k[ENTRIES];
-
-	/* Assume all of TLB entries was occupied by this task */
-	act_entries = tlb_entries >> tlb_flushall_shift;
-	act_entries = mm->total_vm > act_entries ? act_entries : mm->total_vm;
-	nr_base_pages = (end - start) >> PAGE_SHIFT;
-
-	/* tlb_flushall_shift is on balance point, details in commit log */
-	if (nr_base_pages > act_entries) {
+	if ((end - start) > tlb_single_page_flush_ceiling * PAGE_SIZE) {
 		count_vm_tlb_event(NR_TLB_LOCAL_FLUSH_ALL);
 		local_flush_tlb();
 	} else {
@@ -259,68 +255,15 @@ static void do_kernel_range_flush(void *
 
 void flush_tlb_kernel_range(unsigned long start, unsigned long end)
 {
-	unsigned act_entries;
-	struct flush_tlb_info info;
-
-	/* In modern CPU, last level tlb used for both data/ins */
-	act_entries = tlb_lld_4k[ENTRIES];
 
 	/* Balance as user space task's flush, a bit conservative */
-	if (end == TLB_FLUSH_ALL || tlb_flushall_shift == -1 ||
-		(end - start) >> PAGE_SHIFT > act_entries >> tlb_flushall_shift)
-
+	if (end == TLB_FLUSH_ALL ||
+	    (end - start) > tlb_single_page_flush_ceiling * PAGE_SIZE) {
 		on_each_cpu(do_flush_tlb_all, NULL, 1);
-	else {
+	} else {
+		struct flush_tlb_info info;
 		info.flush_start = start;
 		info.flush_end = end;
 		on_each_cpu(do_kernel_range_flush, &info, 1);
 	}
 }
-
-#ifdef CONFIG_DEBUG_TLBFLUSH
-static ssize_t tlbflush_read_file(struct file *file, char __user *user_buf,
-			     size_t count, loff_t *ppos)
-{
-	char buf[32];
-	unsigned int len;
-
-	len = sprintf(buf, "%hd\n", tlb_flushall_shift);
-	return simple_read_from_buffer(user_buf, count, ppos, buf, len);
-}
-
-static ssize_t tlbflush_write_file(struct file *file,
-		 const char __user *user_buf, size_t count, loff_t *ppos)
-{
-	char buf[32];
-	ssize_t len;
-	s8 shift;
-
-	len = min(count, sizeof(buf) - 1);
-	if (copy_from_user(buf, user_buf, len))
-		return -EFAULT;
-
-	buf[len] = '\0';
-	if (kstrtos8(buf, 0, &shift))
-		return -EINVAL;
-
-	if (shift < -1 || shift >= BITS_PER_LONG)
-		return -EINVAL;
-
-	tlb_flushall_shift = shift;
-	return count;
-}
-
-static const struct file_operations fops_tlbflush = {
-	.read = tlbflush_read_file,
-	.write = tlbflush_write_file,
-	.llseek = default_llseek,
-};
-
-static int __init create_tlb_flushall_shift(void)
-{
-	debugfs_create_file("tlb_flushall_shift", S_IRUSR | S_IWUSR,
-			    arch_debugfs_dir, NULL, &fops_tlbflush);
-	return 0;
-}
-late_initcall(create_tlb_flushall_shift);
-#endif
_

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

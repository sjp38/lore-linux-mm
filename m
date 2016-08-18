Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f69.google.com (mail-lf0-f69.google.com [209.85.215.69])
	by kanga.kvack.org (Postfix) with ESMTP id D0B7282F5F
	for <linux-mm@kvack.org>; Thu, 18 Aug 2016 07:31:38 -0400 (EDT)
Received: by mail-lf0-f69.google.com with SMTP id p85so10653033lfg.3
        for <linux-mm@kvack.org>; Thu, 18 Aug 2016 04:31:38 -0700 (PDT)
Received: from mail-wm0-f67.google.com (mail-wm0-f67.google.com. [74.125.82.67])
        by mx.google.com with ESMTPS id x17si29586439wma.104.2016.08.18.04.31.36
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 18 Aug 2016 04:31:37 -0700 (PDT)
Received: by mail-wm0-f67.google.com with SMTP id q128so5213541wma.1
        for <linux-mm@kvack.org>; Thu, 18 Aug 2016 04:31:36 -0700 (PDT)
From: Michal Hocko <mhocko@kernel.org>
Subject: [PATCH] proc, smaps: reduce printing overhead
Date: Thu, 18 Aug 2016 13:31:28 +0200
Message-Id: <1471519888-13829-1-git-send-email-mhocko@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>, Jann Horn <jann@thejh.net>, Michal Hocko <mhocko@suse.com>

From: Michal Hocko <mhocko@suse.com>

seq_printf (used by show_smap) can be pretty expensive when dumping a
lot of numbers.  Say we would like to get Rss and Pss from a particular
process.  In order to measure a pathological case let's generate as many
mappings as possible:

$ cat max_mmap.c
int main()
{
	while (mmap(NULL, 4096, PROT_READ|PROT_WRITE, MAP_ANON|MAP_SHARED|MAP_POPULATE, -1, 0) != MAP_FAILED)
		;

	printf("pid:%d\n", getpid());
	pause();
	return 0;
}

$ awk '/^Rss/{rss+=$2} /^Pss/{pss+=$2} END {printf "rss:%d pss:%d\n", rss, pss}' /proc/$pid/smaps

would do a trick. The whole runtime is in the kernel space which is not
that that unexpected because smaps is not the cheapest one (we have to
do rmap walk etc.).

        Command being timed: "awk /^Rss/{rss+=$2} /^Pss/{pss+=$2} END {printf "rss:%d pss:%d\n", rss, pss} /proc/3050/smaps"
        User time (seconds): 0.01
        System time (seconds): 0.44
        Percent of CPU this job got: 99%
        Elapsed (wall clock) time (h:mm:ss or m:ss): 0:00.47

But the perf says:
    22.55%  awk      [kernel.kallsyms]  [k] format_decode
    14.65%  awk      [kernel.kallsyms]  [k] vsnprintf
     6.40%  awk      [kernel.kallsyms]  [k] number
     2.53%  awk      [kernel.kallsyms]  [k] shmem_mapping
     2.53%  awk      [kernel.kallsyms]  [k] show_smap
     1.81%  awk      [kernel.kallsyms]  [k] lock_acquire

we are spending most of the time actually generating the output which is
quite lame. Let's replace seq_printf by seq_puts and seq_put_decimal_ull.
This will give us:
        Command being timed: "awk /^Rss/{rss+=$2} /^Pss/{pss+=$2} END {printf "rss:%d pss:%d\n", rss, pss} /proc/3067/smaps"
        User time (seconds): 0.00
        System time (seconds): 0.41
        Percent of CPU this job got: 99%
        Elapsed (wall clock) time (h:mm:ss or m:ss): 0:00.42

which will give us ~7% improvement. Perf says:
    28.87%  awk      [kernel.kallsyms]  [k] seq_puts
     5.30%  awk      [kernel.kallsyms]  [k] vsnprintf
     4.54%  awk      [kernel.kallsyms]  [k] format_decode
     3.73%  awk      [kernel.kallsyms]  [k] show_smap
     2.56%  awk      [kernel.kallsyms]  [k] shmem_mapping
     1.92%  awk      [kernel.kallsyms]  [k] number
     1.80%  awk      [kernel.kallsyms]  [k] lock_acquire
     1.75%  awk      [kernel.kallsyms]  [k] print_name_value_kb

Reported-by: Jann Horn <jann@thejh.net>
Signed-off-by: Michal Hocko <mhocko@suse.com>
---
 fs/proc/task_mmu.c | 63 ++++++++++++++++++++++--------------------------------
 1 file changed, 25 insertions(+), 38 deletions(-)

diff --git a/fs/proc/task_mmu.c b/fs/proc/task_mmu.c
index 187d84ef9de9..41c24c0811da 100644
--- a/fs/proc/task_mmu.c
+++ b/fs/proc/task_mmu.c
@@ -721,6 +721,13 @@ void __weak arch_show_smap(struct seq_file *m, struct vm_area_struct *vma)
 {
 }
 
+static void print_name_value_kb(struct seq_file *m, const char *name, unsigned long val)
+{
+	seq_puts(m, name);
+	seq_put_decimal_ull(m, 0, val);
+	seq_puts(m, " kB\n");
+}
+
 static int show_smap(struct seq_file *m, void *v, int is_pid)
 {
 	struct vm_area_struct *vma = v;
@@ -765,45 +772,25 @@ static int show_smap(struct seq_file *m, void *v, int is_pid)
 
 	show_map_vma(m, vma, is_pid);
 
-	seq_printf(m,
-		   "Size:           %8lu kB\n"
-		   "Rss:            %8lu kB\n"
-		   "Pss:            %8lu kB\n"
-		   "Shared_Clean:   %8lu kB\n"
-		   "Shared_Dirty:   %8lu kB\n"
-		   "Private_Clean:  %8lu kB\n"
-		   "Private_Dirty:  %8lu kB\n"
-		   "Referenced:     %8lu kB\n"
-		   "Anonymous:      %8lu kB\n"
-		   "AnonHugePages:  %8lu kB\n"
-		   "ShmemPmdMapped: %8lu kB\n"
-		   "Shared_Hugetlb: %8lu kB\n"
-		   "Private_Hugetlb: %7lu kB\n"
-		   "Swap:           %8lu kB\n"
-		   "SwapPss:        %8lu kB\n"
-		   "KernelPageSize: %8lu kB\n"
-		   "MMUPageSize:    %8lu kB\n"
-		   "Locked:         %8lu kB\n",
-		   (vma->vm_end - vma->vm_start) >> 10,
-		   mss.resident >> 10,
-		   (unsigned long)(mss.pss >> (10 + PSS_SHIFT)),
-		   mss.shared_clean  >> 10,
-		   mss.shared_dirty  >> 10,
-		   mss.private_clean >> 10,
-		   mss.private_dirty >> 10,
-		   mss.referenced >> 10,
-		   mss.anonymous >> 10,
-		   mss.anonymous_thp >> 10,
-		   mss.shmem_thp >> 10,
-		   mss.shared_hugetlb >> 10,
-		   mss.private_hugetlb >> 10,
-		   mss.swap >> 10,
-		   (unsigned long)(mss.swap_pss >> (10 + PSS_SHIFT)),
-		   vma_kernel_pagesize(vma) >> 10,
-		   vma_mmu_pagesize(vma) >> 10,
-		   (vma->vm_flags & VM_LOCKED) ?
+	print_name_value_kb(m, "Size:           ", (vma->vm_end - vma->vm_start) >> 10);
+	print_name_value_kb(m, "Rss:            ", mss.resident >> 10);
+	print_name_value_kb(m, "Pss:            ", (unsigned long)(mss.pss >> (10 + PSS_SHIFT)));
+	print_name_value_kb(m, "Shared_Clean:   ", mss.shared_clean  >> 10);
+	print_name_value_kb(m, "Shared_Dirty:   ", mss.shared_dirty  >> 10);
+	print_name_value_kb(m, "Private_Clean:  ", mss.private_clean >> 10);
+	print_name_value_kb(m, "Private_Dirty:  ", mss.private_dirty >> 10);
+	print_name_value_kb(m, "Referenced:     ", mss.referenced >> 10);
+	print_name_value_kb(m, "Anonymous:      ", mss.anonymous >> 10);
+	print_name_value_kb(m, "AnonHugePages:  ", mss.anonymous_thp >> 10);
+	print_name_value_kb(m, "ShmemPmdMapped: ", mss.shmem_thp >> 10);
+	print_name_value_kb(m, "Shared_Hugetlb: ", mss.shared_hugetlb >> 10);
+	print_name_value_kb(m, "Private_Hugetlb: ", mss.private_hugetlb >> 10);
+	print_name_value_kb(m, "Swap:           ", mss.swap >> 10);
+	print_name_value_kb(m, "SwapPss:        ", (unsigned long)(mss.swap_pss >> (10 + PSS_SHIFT)));
+	print_name_value_kb(m, "KernelPageSize: ", vma_kernel_pagesize(vma) >> 10);
+	print_name_value_kb(m, "MMUPageSize:    ", vma_mmu_pagesize(vma) >> 10);
+	print_name_value_kb(m, "Locked:         ", (vma->vm_flags & VM_LOCKED) ?
 			(unsigned long)(mss.pss >> (10 + PSS_SHIFT)) : 0);
-
 	arch_show_smap(m, vma);
 	show_smap_vma_flags(m, vma);
 	m_cache_vma(m, vma);
-- 
2.8.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

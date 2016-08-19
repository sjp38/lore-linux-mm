Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f71.google.com (mail-wm0-f71.google.com [74.125.82.71])
	by kanga.kvack.org (Postfix) with ESMTP id 4F8006B025E
	for <linux-mm@kvack.org>; Fri, 19 Aug 2016 06:13:13 -0400 (EDT)
Received: by mail-wm0-f71.google.com with SMTP id l4so14940018wml.0
        for <linux-mm@kvack.org>; Fri, 19 Aug 2016 03:13:13 -0700 (PDT)
Received: from mail-wm0-f68.google.com (mail-wm0-f68.google.com. [74.125.82.68])
        by mx.google.com with ESMTPS id xy4si5680043wjb.136.2016.08.19.03.13.10
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 19 Aug 2016 03:13:10 -0700 (PDT)
Received: by mail-wm0-f68.google.com with SMTP id o80so2831993wme.0
        for <linux-mm@kvack.org>; Fri, 19 Aug 2016 03:13:10 -0700 (PDT)
From: Michal Hocko <mhocko@kernel.org>
Subject: [PATCH 2/2] proc, smaps: reduce printing overhead
Date: Fri, 19 Aug 2016 12:13:00 +0200
Message-Id: <1471601580-17999-3-git-send-email-mhocko@kernel.org>
In-Reply-To: <1471601580-17999-1-git-send-email-mhocko@kernel.org>
References: <1471519888-13829-1-git-send-email-mhocko@kernel.org>
 <1471601580-17999-1-git-send-email-mhocko@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Joe Perches <joe@perches.com>, Jann Horn <jann@thejh.net>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>, Michal Hocko <mhocko@suse.com>

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
do pte walk etc.).

        Command being timed: "awk /^Rss/{rss+=$2} /^Pss/{pss+=$2} END {printf "rss:%d pss:%d\n", rss, pss} /proc/3050/smaps"
        User time (seconds): 0.01
        System time (seconds): 0.44
        Percent of CPU this job got: 99%
        Elapsed (wall clock) time (h:mm:ss or m:ss): 0:00.47

This seems to be quite consistent (10 runs)
min: 0.44 max: 0.46 avg: 0.45 std: 0.01

perf says:
    22.55%  awk      [kernel.kallsyms]  [k] format_decode
    14.65%  awk      [kernel.kallsyms]  [k] vsnprintf
     6.40%  awk      [kernel.kallsyms]  [k] number
     2.53%  awk      [kernel.kallsyms]  [k] shmem_mapping
     2.53%  awk      [kernel.kallsyms]  [k] show_smap
     1.81%  awk      [kernel.kallsyms]  [k] lock_acquire

we are spending most of the time actually generating the output which
is quite lame. Let's replace seq_printf by a cheaper seq_write and
show_val_kb which are much cheaper because they are doing the bare
minimum. show_name_pages_kb already does that so mimic it and define a
helper for values given in bytes. This will give us (10 runs):
min: 0.31 max: 0.32 avg: 0.31 std: 0.00

Reported-by: Jann Horn <jann@thejh.net>
Signed-off-by: Michal Hocko <mhocko@suse.com>
---
 fs/proc/internal.h |  7 +++++++
 fs/proc/task_mmu.c | 58 ++++++++++++++++++------------------------------------
 2 files changed, 26 insertions(+), 39 deletions(-)

diff --git a/fs/proc/internal.h b/fs/proc/internal.h
index 10492701f4c1..6a369fc1949d 100644
--- a/fs/proc/internal.h
+++ b/fs/proc/internal.h
@@ -314,3 +314,10 @@ extern void show_val_kb(struct seq_file *m, unsigned long num);
  	seq_write(seq, name, sizeof(name));	\
  	show_val_kb(seq, (pages) << (PAGE_SHIFT - 10));\
  })
+
+#define show_name_bytes_kb(seq, name, val)	\
+({						\
+ 	BUILD_BUG_ON(!__builtin_constant_p(name));\
+ 	seq_write(seq, name, sizeof(name));	\
+ 	show_val_kb(seq, (val) >> 10);		\
+})
diff --git a/fs/proc/task_mmu.c b/fs/proc/task_mmu.c
index 187d84ef9de9..eebb91d44a58 100644
--- a/fs/proc/task_mmu.c
+++ b/fs/proc/task_mmu.c
@@ -765,45 +765,25 @@ static int show_smap(struct seq_file *m, void *v, int is_pid)
 
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
-			(unsigned long)(mss.pss >> (10 + PSS_SHIFT)) : 0);
-
+	show_name_bytes_kb(m, "Size:           ", vma->vm_end - vma->vm_start);
+	show_name_bytes_kb(m, "Rss:            ", mss.resident);
+	show_name_bytes_kb(m, "Pss:            ", (unsigned long)(mss.pss >> PSS_SHIFT));
+	show_name_bytes_kb(m, "Shared_Clean:   ", mss.shared_clean);
+	show_name_bytes_kb(m, "Shared_Dirty:   ", mss.shared_dirty);
+	show_name_bytes_kb(m, "Private_Clean:  ", mss.private_clean);
+	show_name_bytes_kb(m, "Private_Dirty:  ", mss.private_dirty);
+	show_name_bytes_kb(m, "Referenced:     ", mss.referenced);
+	show_name_bytes_kb(m, "Anonymous:      ", mss.anonymous);
+	show_name_bytes_kb(m, "AnonHugePages:  ", mss.anonymous_thp);
+	show_name_bytes_kb(m, "ShmemPmdMapped: ", mss.shmem_thp);
+	show_name_bytes_kb(m, "Shared_Hugetlb: ", mss.shared_hugetlb);
+	show_name_bytes_kb(m, "Private_Hugetlb: ", mss.private_hugetlb);
+	show_name_bytes_kb(m, "Swap:           ", mss.swap);
+	show_name_bytes_kb(m, "SwapPss:        ", (unsigned long)(mss.swap_pss >> PSS_SHIFT));
+	show_name_bytes_kb(m, "KernelPageSize: ", vma_kernel_pagesize(vma));
+	show_name_bytes_kb(m, "MMUPageSize:    ", vma_mmu_pagesize(vma));
+	show_name_bytes_kb(m, "Locked:         ", (vma->vm_flags & VM_LOCKED) ?
+			(unsigned long)(mss.pss >> PSS_SHIFT) : 0);
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

Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f72.google.com (mail-lf0-f72.google.com [209.85.215.72])
	by kanga.kvack.org (Postfix) with ESMTP id 4EBBD830A3
	for <linux-mm@kvack.org>; Thu, 18 Aug 2016 12:42:44 -0400 (EDT)
Received: by mail-lf0-f72.google.com with SMTP id 33so15851749lfw.1
        for <linux-mm@kvack.org>; Thu, 18 Aug 2016 09:42:44 -0700 (PDT)
Received: from mail-wm0-f65.google.com (mail-wm0-f65.google.com. [74.125.82.65])
        by mx.google.com with ESMTPS id d186si329885wmc.125.2016.08.18.09.42.42
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 18 Aug 2016 09:42:42 -0700 (PDT)
Received: by mail-wm0-f65.google.com with SMTP id i138so349934wmf.3
        for <linux-mm@kvack.org>; Thu, 18 Aug 2016 09:42:42 -0700 (PDT)
Date: Thu, 18 Aug 2016 18:42:40 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH] proc, smaps: reduce printing overhead
Message-ID: <20160818164240.GR30162@dhcp22.suse.cz>
References: <1471519888-13829-1-git-send-email-mhocko@kernel.org>
 <1471526765.4319.31.camel@perches.com>
 <20160818142616.GN30162@dhcp22.suse.cz>
 <20160818144149.GO30162@dhcp22.suse.cz>
 <1471531563.4319.41.camel@perches.com>
 <20160818145835.GP30162@dhcp22.suse.cz>
 <1471533810.4319.50.camel@perches.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <1471533810.4319.50.camel@perches.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Joe Perches <joe@perches.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>, Jann Horn <jann@thejh.net>

On Thu 18-08-16 08:23:30, Joe Perches wrote:
> On Thu, 2016-08-18 at 16:58 +0200, Michal Hocko wrote:
> > On Thu 18-08-16 07:46:03, Joe Perches wrote:
> > > 
> > > On Thu, 2016-08-18 at 16:41 +0200, Michal Hocko wrote:
> > > > 
> > > > On Thu 18-08-16 16:26:16, Michal Hocko wrote:
> > > > > 
> > > > > b) doesn't it try to be overly clever when doing that in the caller
> > > > > doesn't cost all that much? Sure you can save few bytes in the spaces
> > > > > but then I would just argue to use \t rather than fixed string length.
> > > > ohh, I misread the code. It tries to emulate the width formater. But is
> > > > this really necessary? Do we know about any tools doing a fixed string
> > > > parsing?
> > > I don't, but it's proc and all the output formatting
> > > shouldn't be changed.
> > > 
> > > Appended to is generally OK, but whitespace changed is
> > > not good.
> > OK fair enough, I will
> > -       seq_write(m, s, 16);
> > +       seq_puts(m, s);
> > 
> > because smaps needs more than 16 chars and export it in
> > fs/proc/internal.h
> > 
> > will retest and repost.
> 
> The shift in the meminfo case uses PAGE_SHIFT too.

OK, I have missed that part as well. So I have to do turn all the values
into page units from bytes just to let the function turn them into kB.
Sigh...

But anyway, I have done basically a copy of your show_val_kb and run
on top of the current linux-next and while the base is giving me the
comparable results to my mmomt based testing:
        Command being timed: "awk /^Rss/{rss+=$2} /^Pss/{pss+=$2} END {printf "rss:%d pss:%d\n", rss, pss} /proc/3021/smaps"
        User time (seconds): 0.00
        System time (seconds): 0.44
        Percent of CPU this job got: 99%
        Elapsed (wall clock) time (h:mm:ss or m:ss): 0:00.45

The patch on top (below) is eating actually more system time which is
more than unexpected to me:
        Command being timed: "awk /^Rss/{rss+=$2} /^Pss/{pss+=$2} END {printf "rss:%d pss:%d\n", rss, pss} /proc/3048/smaps"
        User time (seconds): 0.00
        System time (seconds): 0.50
        Percent of CPU this job got: 99%
        Elapsed (wall clock) time (h:mm:ss or m:ss): 0:00.50

and perf says
    21.65%  awk      [kernel.kallsyms]  [k] seq_puts
     8.41%  awk      [kernel.kallsyms]  [k] seq_write
     4.64%  awk      [kernel.kallsyms]  [k] vsnprintf
     4.20%  awk      [kernel.kallsyms]  [k] format_decode
     3.37%  awk      [kernel.kallsyms]  [k] show_smap
     2.15%  awk      [kernel.kallsyms]  [k] lock_acquire
     2.05%  awk      [kernel.kallsyms]  [k] num_to_str
     2.05%  awk      [kernel.kallsyms]  [k] print_name_value_kb
     1.76%  awk      [kernel.kallsyms]  [k] shmem_mapping
     1.61%  awk      [kernel.kallsyms]  [k] number

The results were slightly better when I dropped the alignment thingy
and returned back to seq_put_decimal_ull but it was still sys in range
0.46-0.48. So I though I just made some mistake in my previous measuring
but getting back to my testing kernel based on the mmotm tree it all
gets back to sys 0.40-0.41 while the base mmotm was 0.44-0.48.

I didn't get to compare perf profiles closely but I do not see anything
really outstanding there at the first glance. I will probably not pursue
this anymore as I do not have enough time to debug this any further
and the results do not seem so convincing with the linux-next anymore.
Maybe measuring this on the bare metal will lead to different results
(I was using kvm virt. machine). Or maybe I just made a stupid mistake
somewhere...
---
diff --git a/fs/proc/task_mmu.c b/fs/proc/task_mmu.c
index 187d84ef9de9..eebebbc12c67 100644
--- a/fs/proc/task_mmu.c
+++ b/fs/proc/task_mmu.c
@@ -721,6 +721,23 @@ void __weak arch_show_smap(struct seq_file *m, struct vm_area_struct *vma)
 {
 }
 
+static void print_name_value_kb(struct seq_file *m, const char *name, unsigned long val)
+{
+	static const char blanks[7] = {' ', ' ', ' ', ' ',' ', ' ', ' '};
+	char v[32];
+	int len;
+
+	seq_puts(m, name);
+	len = num_to_str(v, sizeof(v), val >> 10);
+	if (len > 0) {
+		if (len < 8)
+			seq_write(m, blanks, 8 - len);
+
+		seq_write(m, v, len);
+	}
+	seq_puts(m, " kB\n");
+}
+
 static int show_smap(struct seq_file *m, void *v, int is_pid)
 {
 	struct vm_area_struct *vma = v;
@@ -765,45 +782,25 @@ static int show_smap(struct seq_file *m, void *v, int is_pid)
 
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
+	print_name_value_kb(m, "Size:           ", vma->vm_end - vma->vm_start);
+	print_name_value_kb(m, "Rss:            ", mss.resident);
+	print_name_value_kb(m, "Pss:            ", (unsigned long)(mss.pss >> PSS_SHIFT));
+	print_name_value_kb(m, "Shared_Clean:   ", mss.shared_clean);
+	print_name_value_kb(m, "Shared_Dirty:   ", mss.shared_dirty);
+	print_name_value_kb(m, "Private_Clean:  ", mss.private_clean);
+	print_name_value_kb(m, "Private_Dirty:  ", mss.private_dirty);
+	print_name_value_kb(m, "Referenced:     ", mss.referenced);
+	print_name_value_kb(m, "Anonymous:      ", mss.anonymous);
+	print_name_value_kb(m, "AnonHugePages:  ", mss.anonymous_thp);
+	print_name_value_kb(m, "ShmemPmdMapped: ", mss.shmem_thp);
+	print_name_value_kb(m, "Shared_Hugetlb: ", mss.shared_hugetlb);
+	print_name_value_kb(m, "Private_Hugetlb: ", mss.private_hugetlb);
+	print_name_value_kb(m, "Swap:           ", mss.swap);
+	print_name_value_kb(m, "SwapPss:        ", (unsigned long)(mss.swap_pss >> PSS_SHIFT));
+	print_name_value_kb(m, "KernelPageSize: ", vma_kernel_pagesize(vma));
+	print_name_value_kb(m, "MMUPageSize:    ", vma_mmu_pagesize(vma));
+	print_name_value_kb(m, "Locked:         ", (vma->vm_flags & VM_LOCKED) ?
+			(unsigned long)(mss.pss >> PSS_SHIFT) : 0);
 	arch_show_smap(m, vma);
 	show_smap_vma_flags(m, vma);
 	m_cache_vma(m, vma);
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

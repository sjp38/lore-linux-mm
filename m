Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f178.google.com (mail-ig0-f178.google.com [209.85.213.178])
	by kanga.kvack.org (Postfix) with ESMTP id C09BF6B0184
	for <linux-mm@kvack.org>; Tue,  6 Jan 2015 16:58:57 -0500 (EST)
Received: by mail-ig0-f178.google.com with SMTP id b16so320187igk.17
        for <linux-mm@kvack.org>; Tue, 06 Jan 2015 13:58:57 -0800 (PST)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id d17si167445icm.9.2015.01.06.13.58.55
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 06 Jan 2015 13:58:56 -0800 (PST)
Date: Tue, 6 Jan 2015 13:58:54 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [cgroup:review-cgroup-writeback-20150106 86/265]
 fs/proc/task_mmu.c:858:2: warning: ISO C90 forbids mixed declarations and
 code
Message-Id: <20150106135854.519dbf3c5cfbdb75ff4dfe4e@linux-foundation.org>
In-Reply-To: <201501070338.SBIfROhh%fengguang.wu@intel.com>
References: <201501070338.SBIfROhh%fengguang.wu@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: kbuild test robot <fengguang.wu@intel.com>
Cc: Petr Cermak <petrcermak@chromium.org>, kbuild-all@01.org, Johannes Weiner <hannes@cmpxchg.org>, Linux Memory Management List <linux-mm@kvack.org>

On Wed, 7 Jan 2015 03:30:42 +0800 kbuild test robot <fengguang.wu@intel.com> wrote:

> tree:   git://git.kernel.org/pub/scm/linux/kernel/git/tj/cgroup.git review-cgroup-writeback-20150106
> head:   393b71c00e25227a020f9dbf8ffdddebac4fdf1e
> commit: d3ef989a8ce459778acbb511fc03d0d85f11d4cc [86/265] fs/proc/task_mmu.c: reduce excessive indentation in clear_refs_write
> config: parisc-c3000_defconfig (attached as .config)
> reproduce:
>   wget https://git.kernel.org/cgit/linux/kernel/git/wfg/lkp-tests.git/plain/sbin/make.cross -O ~/bin/make.cross
>   chmod +x ~/bin/make.cross
>   git checkout d3ef989a8ce459778acbb511fc03d0d85f11d4cc
>   # save the attached .config to linux build tree
>   make.cross ARCH=parisc 
> 
> All warnings:
> 
>    fs/proc/task_mmu.c: In function 'clear_refs_write':
> >> fs/proc/task_mmu.c:858:2: warning: ISO C90 forbids mixed declarations and code [-Wdeclaration-after-statement]
>      struct clear_refs_private cp = {
>      ^

I wasn't able to find a way of fixing this which I liked, so I dropped it.

task_mmu-add-user-space-support-for-resetting-mm-hiwater_rss-peak-rss.patch
needed rework.  Peter, please check carefully:

From: Petr Cermak <petrcermak@chromium.org>
Subject: fs/proc/task_mmu.c: add user-space support for resetting mm->hiwater_rss (peak RSS)

Peak resident size of a process can be reset back to the process's current
rss value by writing "5" to /proc/pid/clear_refs.  The driving use-case
for this would be getting the peak RSS value, which can be retrieved from
the VmHWM field in /proc/pid/status, per benchmark iteration or test
scenario.

[akpm@linux-foundation.org: clarify behaviour in documentation]
Signed-off-by: Petr Cermak <petrcermak@chromium.org>
Cc: Bjorn Helgaas <bhelgaas@google.com>
Cc: Primiano Tucci <primiano@chromium.org>
Cc: Petr Cermak <petrcermak@chromium.org>
Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
---

 Documentation/filesystems/proc.txt |    4 ++++
 fs/proc/task_mmu.c                 |   14 ++++++++++++++
 include/linux/mm.h                 |    5 +++++
 3 files changed, 23 insertions(+)

diff -puN Documentation/filesystems/proc.txt~task_mmu-add-user-space-support-for-resetting-mm-hiwater_rss-peak-rss Documentation/filesystems/proc.txt
--- a/Documentation/filesystems/proc.txt~task_mmu-add-user-space-support-for-resetting-mm-hiwater_rss-peak-rss
+++ a/Documentation/filesystems/proc.txt
@@ -488,6 +488,10 @@ To clear the bits for the file mapped pa
 To clear the soft-dirty bit
     > echo 4 > /proc/PID/clear_refs
 
+To reset the peak resident set size ("high water mark") to the process's
+current value:
+    > echo 5 > /proc/PID/clear_refs
+
 Any other value written to /proc/PID/clear_refs will have no effect.
 
 The /proc/pid/pagemap gives the PFN, which can be used to find the pageflags
diff -puN fs/proc/task_mmu.c~task_mmu-add-user-space-support-for-resetting-mm-hiwater_rss-peak-rss fs/proc/task_mmu.c
--- a/fs/proc/task_mmu.c~task_mmu-add-user-space-support-for-resetting-mm-hiwater_rss-peak-rss
+++ a/fs/proc/task_mmu.c
@@ -747,6 +747,7 @@ enum clear_refs_types {
 	CLEAR_REFS_ANON,
 	CLEAR_REFS_MAPPED,
 	CLEAR_REFS_SOFT_DIRTY,
+	CLEAR_REFS_MM_HIWATER_RSS,
 	CLEAR_REFS_LAST,
 };
 
@@ -861,6 +862,18 @@ static ssize_t clear_refs_write(struct f
 			.mm = mm,
 			.private = &cp,
 		};
+
+		if (type == CLEAR_REFS_MM_HIWATER_RSS) {
+			/*
+			 * Writing 5 to /proc/pid/clear_refs resets the peak
+			 * resident set size to this mm's current rss value.
+			 */
+			down_write(&mm->mmap_sem);
+			reset_mm_hiwater_rss(mm);
+			up_write(&mm->mmap_sem);
+			goto out_mm;
+		}
+	
 		down_read(&mm->mmap_sem);
 		if (type == CLEAR_REFS_SOFT_DIRTY) {
 			for (vma = mm->mmap; vma; vma = vma->vm_next) {
@@ -903,6 +916,7 @@ static ssize_t clear_refs_write(struct f
 			mmu_notifier_invalidate_range_end(mm, 0, -1);
 		flush_tlb_mm(mm);
 		up_read(&mm->mmap_sem);
+out_mm:
 		mmput(mm);
 	}
 	put_task_struct(task);
diff -puN include/linux/mm.h~task_mmu-add-user-space-support-for-resetting-mm-hiwater_rss-peak-rss include/linux/mm.h
--- a/include/linux/mm.h~task_mmu-add-user-space-support-for-resetting-mm-hiwater_rss-peak-rss
+++ a/include/linux/mm.h
@@ -1366,6 +1366,11 @@ static inline void update_hiwater_vm(str
 		mm->hiwater_vm = mm->total_vm;
 }
 
+static inline void reset_mm_hiwater_rss(struct mm_struct *mm)
+{
+	mm->hiwater_rss = get_mm_rss(mm);
+}
+
 static inline void setmax_mm_hiwater_rss(unsigned long *maxrss,
 					 struct mm_struct *mm)
 {
_

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

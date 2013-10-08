Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f172.google.com (mail-pd0-f172.google.com [209.85.192.172])
	by kanga.kvack.org (Postfix) with ESMTP id 79D786B0039
	for <linux-mm@kvack.org>; Mon,  7 Oct 2013 22:55:00 -0400 (EDT)
Received: by mail-pd0-f172.google.com with SMTP id z10so7992245pdj.17
        for <linux-mm@kvack.org>; Mon, 07 Oct 2013 19:55:00 -0700 (PDT)
Date: Mon, 07 Oct 2013 22:54:54 -0400
From: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Message-ID: <1381200894-g4p1jfd3-mutt-n-horiguchi@ah.jp.nec.com>
In-Reply-To: <20131007175125.7bb300853d37b6a64eba248d@linux-foundation.org>
References: <1380913335-17466-1-git-send-email-n-horiguchi@ah.jp.nec.com>
 <5252B56C.8030903@parallels.com>
 <1381155304-2ro6e10t-mutt-n-horiguchi@ah.jp.nec.com>
 <20131007175125.7bb300853d37b6a64eba248d@linux-foundation.org>
Subject: Re: [PATCH 1/2 v2] smaps: show VM_SOFTDIRTY flag in VmFlags line
Mime-Version: 1.0
Content-Type: text/plain;
 charset=iso-2022-jp
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Pavel Emelyanov <xemul@parallels.com>, linux-mm@kvack.org, Wu Fengguang <fengguang.wu@intel.com>, linux-kernel@vger.kernel.org

On Mon, Oct 07, 2013 at 05:51:25PM -0700, Andrew Morton wrote:
> On Mon, 07 Oct 2013 10:15:04 -0400 Naoya Horiguchi <n-horiguchi@ah.jp.nec.com> wrote:
> 
> > From: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
> > Date: Fri, 4 Oct 2013 13:42:13 -0400
> > Subject: [PATCH] smaps: show VM_SOFTDIRTY flag in VmFlags line
> > 
> > This flag shows that the VMA is "newly created" and thus represents
> > "dirty" in the task's VM.
> > You can clear it by "echo 4 > /proc/pid/clear_refs."
> > 
> > Signed-off-by: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
> > ---
> >  fs/proc/task_mmu.c | 3 +++
> >  1 file changed, 3 insertions(+)
> > 
> > diff --git a/fs/proc/task_mmu.c b/fs/proc/task_mmu.c
> > index 7366e9d..c591928 100644
> > --- a/fs/proc/task_mmu.c
> > +++ b/fs/proc/task_mmu.c
> > @@ -561,6 +561,9 @@ static void show_smap_vma_flags(struct seq_file *m, struct vm_area_struct *vma)
> >  		[ilog2(VM_NONLINEAR)]	= "nl",
> >  		[ilog2(VM_ARCH_1)]	= "ar",
> >  		[ilog2(VM_DONTDUMP)]	= "dd",
> > +#ifdef CONFIG_MEM_SOFT_DIRTY
> > +		[ilog2(VM_SOFTDIRTY)]	= "sd",
> > +#endif
> >  		[ilog2(VM_MIXEDMAP)]	= "mm",
> >  		[ilog2(VM_HUGEPAGE)]	= "hg",
> >  		[ilog2(VM_NOHUGEPAGE)]	= "nh",
> 
> Documentation/filesystems/proc.txt needs updating, please.

OK. Here's the revised one.
---
From: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Date: Mon, 7 Oct 2013 22:52:00 -0400
Subject: [PATCH] smaps: show VM_SOFTDIRTY flag in VmFlags line

This flag shows that the VMA is "newly created" and thus represents
"dirty" in the task's VM.
You can clear it by "echo 4 > /proc/pid/clear_refs."

Signed-off-by: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Acked-by: Cyrill Gorcunov <gorcunov@openvz.org>
---
 Documentation/filesystems/proc.txt | 1 +
 fs/proc/task_mmu.c                 | 3 +++
 2 files changed, 4 insertions(+)

diff --git a/Documentation/filesystems/proc.txt b/Documentation/filesystems/proc.txt
index 823c95f..22d89aa3 100644
--- a/Documentation/filesystems/proc.txt
+++ b/Documentation/filesystems/proc.txt
@@ -460,6 +460,7 @@ flags associated with the particular virtual memory area in two letter encoded
     nl  - non-linear mapping
     ar  - architecture specific flag
     dd  - do not include area into core dump
+    sd  - soft-dirty flag
     mm  - mixed map area
     hg  - huge page advise flag
     nh  - no-huge page advise flag
diff --git a/fs/proc/task_mmu.c b/fs/proc/task_mmu.c
index 7366e9d..c591928 100644
--- a/fs/proc/task_mmu.c
+++ b/fs/proc/task_mmu.c
@@ -561,6 +561,9 @@ static void show_smap_vma_flags(struct seq_file *m, struct vm_area_struct *vma)
 		[ilog2(VM_NONLINEAR)]	= "nl",
 		[ilog2(VM_ARCH_1)]	= "ar",
 		[ilog2(VM_DONTDUMP)]	= "dd",
+#ifdef CONFIG_MEM_SOFT_DIRTY
+		[ilog2(VM_SOFTDIRTY)]	= "sd",
+#endif
 		[ilog2(VM_MIXEDMAP)]	= "mm",
 		[ilog2(VM_HUGEPAGE)]	= "hg",
 		[ilog2(VM_NOHUGEPAGE)]	= "nh",
-- 
1.8.3.1





--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

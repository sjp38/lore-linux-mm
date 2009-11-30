Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id F2BE2600309
	for <linux-mm@kvack.org>; Mon, 30 Nov 2009 06:40:50 -0500 (EST)
Date: Mon, 30 Nov 2009 11:40:48 +0000 (GMT)
From: Hugh Dickins <hugh.dickins@tiscali.co.uk>
Subject: Re: [PATCH 6/9] ksm: mem cgroup charge swapin copy
In-Reply-To: <20091130091316.b804a75c.kamezawa.hiroyu@jp.fujitsu.com>
Message-ID: <Pine.LNX.4.64.0911301119060.20054@sister.anvils>
References: <Pine.LNX.4.64.0911241634170.24427@sister.anvils>
 <Pine.LNX.4.64.0911241648520.25288@sister.anvils>
 <20091130091316.b804a75c.kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Izik Eidus <ieidus@redhat.com>, Andrea Arcangeli <aarcange@redhat.com>, Chris Wright <chrisw@redhat.com>, Balbir Singh <balbir@linux.vnet.ibm.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, 30 Nov 2009, KAMEZAWA Hiroyuki wrote:
> 
> Ok. Maybe commit_charge will work enough. (I hope so.)

                                             Me too.
> 
> Acked-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
> 
> BTW, I'm happy if you adds "How to test" documenation to
> Documentation/vm/ksm.txt or to share some test programs.
> 
> 1. Map anonymous pages + madvise(MADV_MERGEABLE)
> 2. "echo 1 > /sys/kernel/mm/ksm/run"

Those are the main points, yes.

Though in testing for races, I do think the default
/sys/kernel/mm/ksm/sleep_millisecs 20 is probably too relaxed
to find issues quickly enough, so I usually change that to 0,
and also raise pages_to_scan from its default of 100 (though
that should matter less).  In testing for races, something I've
not done but probably should, is raise the priority of ksmd: we
have it niced down, but that may leave some nasties unobserved.

As to adding Documentation on testing: whilst my primary reason
for not doing so is certainly laziness (or an interest in moving
on to somewhere else), a secondary reason is that I'd much rather
that if someone does have an interest in testing this, that they
follow their own ideas, rather than copying what's already done.

But here's something I'll share with you, please don't show it
to anyone else ;)  Writing test programs using MADV_MERGEABLE is
good for testing specific issues, but can't give much coverage,
so I tend to run with this hack below: boot option "allksm" makes
as much as it can MADV_MERGEABLE.  (If you wonder why I squashed it
up, it was to avoid changing the line numbering as much as possible.)

Hugh

--- mmotm/mm/mmap.c	2009-11-25 09:28:50.000000000 +0000
+++ allksm/mm/mmap.c	2009-11-25 11:19:13.000000000 +0000
@@ -902,9 +902,9 @@ void vm_stat_account(struct mm_struct *m
 #endif /* CONFIG_PROC_FS */
 
 /*
- * The caller must hold down_write(&current->mm->mmap_sem).
- */
-
+ * The caller must hold down_write(&current->mm->mmap_sem). */
+#include <linux/ksm.h>
+unsigned long vm_mergeable;
 unsigned long do_mmap_pgoff(struct file *file, unsigned long addr,
 			unsigned long len, unsigned long prot,
 			unsigned long flags, unsigned long pgoff)
@@ -1050,7 +1050,7 @@ unsigned long do_mmap_pgoff(struct file
 			/*
 			 * Set pgoff according to addr for anon_vma.
 			 */
-			pgoff = addr >> PAGE_SHIFT;
+			vm_flags |= vm_mergeable; pgoff = addr >> PAGE_SHIFT;
 			break;
 		default:
 			return -EINVAL;
@@ -1201,10 +1201,10 @@ munmap_back:
 		vma->vm_file = file;
 		get_file(file);
 		error = file->f_op->mmap(file, vma);
-		if (error)
-			goto unmap_and_free_vma;
-		if (vm_flags & VM_EXECUTABLE)
-			added_exe_file_vma(mm);
+		if (error) goto unmap_and_free_vma;
+		if (vm_flags & VM_EXECUTABLE) added_exe_file_vma(mm);
+		if (vm_mergeable)
+			ksm_madvise(vma, 0, 0, MADV_MERGEABLE,&vma->vm_flags);
 
 		/* Can addr have changed??
 		 *
@@ -2030,7 +2030,7 @@ unsigned long do_brk(unsigned long addr,
 		return error;
 
 	flags = VM_DATA_DEFAULT_FLAGS | VM_ACCOUNT | mm->def_flags;
-
+	flags |= vm_mergeable;
 	error = arch_mmap_check(addr, len, flags);
 	if (error)
 		return error;
@@ -2179,7 +2179,7 @@ int insert_vm_struct(struct mm_struct *
 	if (!vma->vm_file) {
 		BUG_ON(vma->anon_vma);
 		vma->vm_pgoff = vma->vm_start >> PAGE_SHIFT;
-	}
+		vma->vm_flags |= vm_mergeable;	}
 	__vma = find_vma_prepare(mm,vma->vm_start,&prev,&rb_link,&rb_parent);
 	if (__vma && __vma->vm_start < vma->vm_end)
 		return -ENOMEM;
@@ -2518,3 +2518,10 @@ void __init mmap_init(void)
 	ret = percpu_counter_init(&vm_committed_as, 0);
 	VM_BUG_ON(ret);
 }
+static int __init allksm(char *s)
+{
+	randomize_va_space = 0;
+	vm_mergeable = VM_MERGEABLE;
+	return 1;
+}
+__setup("allksm", allksm);

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

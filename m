Date: Tue, 8 Apr 2003 07:08:11 -0700
From: William Lee Irwin III <wli@holomorphy.com>
Subject: Re: 2.5.67-mm1
Message-ID: <20030408140811.GT993@holomorphy.com>
References: <20030408042239.053e1d23.akpm@digeo.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20030408042239.053e1d23.akpm@digeo.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@digeo.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Apr 08, 2003 at 04:22:39AM -0700, Andrew Morton wrote:
> http://www.zip.com.au/~akpm/linux/patches/2.5/2.5.67-mm1.gz
>   Will appear sometime at
> ftp://ftp.kernel.org/pub/linux/kernel/people/akpm/patches/2.5/2.5.67/2.5.67-mm1/
> . sparc64 is now using gcc-3.x, so there is a patch here to make gcc-2.95
>   the minimum required version.
> . A few rmap-speedup patches reduce the rmap CPU tax by 25-30% on a P4
> . Various other cleaups, speedups and fixups.

task_vsize() mysteriously appeared on my profiles. This should remove
it from them by using the already in-use elsewhere for rlimit checks
mm->total_vm for the benefit of O(1) cachelines touched.


--- virgin-2.5.67/fs/proc/task_mmu.c	Wed Jan 15 08:46:04 2003
+++ wli-2.5.67-1/fs/proc/task_mmu.c	Tue Apr  8 06:57:27 2003
@@ -45,13 +45,7 @@
 
 unsigned long task_vsize(struct mm_struct *mm)
 {
-	struct vm_area_struct *vma;
-	unsigned long vsize = 0;
-
-	for (vma = mm->mmap; vma; vma = vma->vm_next)
-		vsize += vma->vm_end - vma->vm_start;
-
-	return vsize;
+	return PAGE_SIZE * mm->total_vm;
 }
 
 int task_statm(struct mm_struct *mm, int *shared, int *text,
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org">aart@kvack.org</a>

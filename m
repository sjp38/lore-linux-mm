Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id 5556D6B004F
	for <linux-mm@kvack.org>; Mon, 12 Jan 2009 18:00:33 -0500 (EST)
Date: Mon, 12 Jan 2009 14:59:39 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH]Fix: 32bit binary has 64bit address of stack vma
Message-Id: <20090112145939.5ae28ada.akpm@linux-foundation.org>
In-Reply-To: <604427e00901051539x52ab85bcua94cd8036e5b619a@mail.gmail.com>
References: <604427e00901051539x52ab85bcua94cd8036e5b619a@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Ying Han <yinghan@google.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, mikew@google.com, rohitseth@google.com
List-ID: <linux-mm.kvack.org>

On Mon, 5 Jan 2009 15:39:07 -0800
Ying Han <yinghan@google.com> wrote:

> From: Ying Han <yinghan@google.com>
> 
> Fix 32bit binary get 64bit stack vma offset.
> 
> 32bit binary running on 64bit system, the /proc/pid/maps shows for the
> vma represents stack get a 64bit adress:
> ff96c000-ff981000 rwxp 7ffffffea000 00:00 0 [stack]
> 
> Signed-off-by:	Ying Han <yinghan@google.com>
> 
> fs/exec.c                     |    5 +-
> 
> diff --git a/fs/exec.c b/fs/exec.c
> index 4e834f1..8c3eff4 100644
> --- a/fs/exec.c
> +++ b/fs/exec.c
> @@ -517,6 +517,7 @@ static int shift_arg_pages(struct vm_area_struct *vma, uns
>  	unsigned long length = old_end - old_start;
>  	unsigned long new_start = old_start - shift;
>  	unsigned long new_end = old_end - shift;
> +	unsigned long new_pgoff = new_start >> PAGE_SHIFT;
>  	struct mmu_gather *tlb;
> 
>  	BUG_ON(new_start > new_end);
> @@ -531,7 +532,7 @@ static int shift_arg_pages(struct vm_area_struct *vma, uns
>  	/*
>  	 * cover the whole range: [new_start, old_end)
>  	 */
> -	vma_adjust(vma, new_start, old_end, vma->vm_pgoff, NULL);
> +	vma_adjust(vma, new_start, old_end, new_pgoff, NULL);
> 
>  	/*
>  	 * move the page tables downwards, on failure we rely on
> @@ -564,7 +565,7 @@ static int shift_arg_pages(struct vm_area_struct *vma, uns
>  	/*
>  	 * shrink the vma to just the new range.
>  	 */
> -	vma_adjust(vma, new_start, new_end, vma->vm_pgoff, NULL);
> +	vma_adjust(vma, new_start, new_end, new_pgoff, NULL);
> 
>  	return 0;

I rewrote the chagnelog as below.  Please confirm that it makes sense?


Subject: fs/exec.c: fix value of vma->vm_pgoff for the stack VMA of 32-bit processes
From: Ying Han <yinghan@google.com>

With a 32 bit binary running on a 64 bit system, the /proc/pid/maps for
the [stack] VMA displays a 64-bit address:

ff96c000-ff981000 rwxp 7ffffffea000 00:00 0 [stack]

This is because vma->vm_pgoff for that VMA is incorrectly being stored in
units of offset-in-bytes.  It should be stored in units of offset-in-pages.

Signed-off-by: Ying Han <yinghan@google.com>
Cc: Mike Waychison <mikew@google.com>
Cc: Hugh Dickins <hugh@veritas.com>
Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
---

 fs/exec.c |    5 +++--
 1 file changed, 3 insertions(+), 2 deletions(-)

diff -puN fs/exec.c~fs-execc-fix-value-of-vma-vm_pgoff-for-the-stack-vma-of-32-bit-processes fs/exec.c
--- a/fs/exec.c~fs-execc-fix-value-of-vma-vm_pgoff-for-the-stack-vma-of-32-bit-processes
+++ a/fs/exec.c
@@ -509,6 +509,7 @@ static int shift_arg_pages(struct vm_are
 	unsigned long length = old_end - old_start;
 	unsigned long new_start = old_start - shift;
 	unsigned long new_end = old_end - shift;
+	unsigned long new_pgoff = new_start >> PAGE_SHIFT;
 	struct mmu_gather *tlb;
 
 	BUG_ON(new_start > new_end);
@@ -523,7 +524,7 @@ static int shift_arg_pages(struct vm_are
 	/*
 	 * cover the whole range: [new_start, old_end)
 	 */
-	vma_adjust(vma, new_start, old_end, vma->vm_pgoff, NULL);
+	vma_adjust(vma, new_start, old_end, new_pgoff, NULL);
 
 	/*
 	 * move the page tables downwards, on failure we rely on
@@ -556,7 +557,7 @@ static int shift_arg_pages(struct vm_are
 	/*
 	 * shrink the vma to just the new range.
 	 */
-	vma_adjust(vma, new_start, new_end, vma->vm_pgoff, NULL);
+	vma_adjust(vma, new_start, new_end, new_pgoff, NULL);
 
 	return 0;
 }
_

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

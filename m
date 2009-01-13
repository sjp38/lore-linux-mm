Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id 782356B004F
	for <linux-mm@kvack.org>; Tue, 13 Jan 2009 12:59:28 -0500 (EST)
Date: Tue, 13 Jan 2009 17:59:24 +0000 (GMT)
From: Hugh Dickins <hugh@veritas.com>
Subject: Re: [PATCH]Fix: 32bit binary has 64bit address of stack vma
In-Reply-To: <20090112151029.9e810ade.akpm@linux-foundation.org>
Message-ID: <Pine.LNX.4.64.0901131728340.32621@blonde.anvils>
References: <604427e00901051539x52ab85bcua94cd8036e5b619a@mail.gmail.com>
 <20090112145939.5ae28ada.akpm@linux-foundation.org> <496BCCCF.70202@google.com>
 <20090112151029.9e810ade.akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Mike Waychison <mikew@google.com>, yinghan@google.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, rohitseth@google.com
List-ID: <linux-mm.kvack.org>

On Mon, 12 Jan 2009, Andrew Morton wrote:
> On Mon, 12 Jan 2009 15:05:51 -0800
> Mike Waychison <mikew@google.com> wrote:
> 
> > > Subject: fs/exec.c: fix value of vma->vm_pgoff for the stack VMA of 32-bit processes
> > > From: Ying Han <yinghan@google.com>
> > > 
> > > With a 32 bit binary running on a 64 bit system, the /proc/pid/maps for
> > > the [stack] VMA displays a 64-bit address:
> > > 
> > > ff96c000-ff981000 rwxp 7ffffffea000 00:00 0 [stack]
> > > 
> > > This is because vma->vm_pgoff for that VMA is incorrectly being stored in
> > > units of offset-in-bytes.  It should be stored in units of offset-in-pages.
> > > 
> > 
> > The problem is that the offset was stored without taking into account 
> > the shift.
> 
> Sigh.  Is it efficient to have me sitting here reverse-engineering the
> code, writing your changelog?
> 
> 
> 
> From: Ying Han <yinghan@google.com>
> 
> With a 32 bit binary running on a 64 bit system, the /proc/pid/maps for
> the [stack] VMA displays a 64-bit address:
> 
> ff96c000-ff981000 rwxp 7ffffffea000 00:00 0 [stack]
> 
> This is because vma->vm_pgoff for that VMA is not being updated for the
> shift of the stack VMA.
> 
> Signed-off-by: Ying Han <yinghan@google.com>
> Cc: Mike Waychison <mikew@google.com>
> Cc: Hugh Dickins <hugh@veritas.com>
> Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
> ---

Sorry for all the waste of your time, but
I'm afraid this is entirely bogus, as Kamezawa-san has kindly
discovered for us (in: Re: mmotm 2009-01-12-16-53 uploaded thread).

The code was correct before, there was no shifting issue, and you
cannot muck around with the vm_pgoff of a vma like this patch does.
Thank Nick for the CONFIG_DEBUG_VM BUG_ON which warns that this
patch has inadvertently made these stack pages unreclaimable
(because their indexes no longer match up with vm_pgoff).

All there is here is a cosmetic issue: we're used to seeing 8-hex-
digit offsets in the /proc/pid/maps of a 32-bit process.  Though it
could perfectly well mmap() a large file from a very high offset and
show more hex digits there, couldn't it?

Because this 32-bit process has been started by a 64-bit kernel, it
started off working with the 64-bit stack position before moving into
place, and that happens to get reflected in the final vm_pgoff.

You prefer only to see 8-hex-digit offsets for anonymous vmas of 32-bit
processes?  If so, then perhaps Ying Han could supply a cosmetic patch
for /proc/pid/maps to mask off the upper bits in that case.

Hugh

> 
>  fs/exec.c |    5 +++--
>  1 file changed, 3 insertions(+), 2 deletions(-)
> 
> diff -puN fs/exec.c~fs-execc-fix-value-of-vma-vm_pgoff-for-the-stack-vma-of-32-bit-processes fs/exec.c
> --- a/fs/exec.c~fs-execc-fix-value-of-vma-vm_pgoff-for-the-stack-vma-of-32-bit-processes
> +++ a/fs/exec.c
> @@ -509,6 +509,7 @@ static int shift_arg_pages(struct vm_are
>  	unsigned long length = old_end - old_start;
>  	unsigned long new_start = old_start - shift;
>  	unsigned long new_end = old_end - shift;
> +	unsigned long new_pgoff = new_start >> PAGE_SHIFT;
>  	struct mmu_gather *tlb;
>  
>  	BUG_ON(new_start > new_end);
> @@ -523,7 +524,7 @@ static int shift_arg_pages(struct vm_are
>  	/*
>  	 * cover the whole range: [new_start, old_end)
>  	 */
> -	vma_adjust(vma, new_start, old_end, vma->vm_pgoff, NULL);
> +	vma_adjust(vma, new_start, old_end, new_pgoff, NULL);
>  
>  	/*
>  	 * move the page tables downwards, on failure we rely on
> @@ -556,7 +557,7 @@ static int shift_arg_pages(struct vm_are
>  	/*
>  	 * shrink the vma to just the new range.
>  	 */
> -	vma_adjust(vma, new_start, new_end, vma->vm_pgoff, NULL);
> +	vma_adjust(vma, new_start, new_end, new_pgoff, NULL);
>  
>  	return 0;
>  }
> _

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

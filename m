From: Nick Piggin <nickpiggin@yahoo.com.au>
Subject: Re: [PATCH] remap_file_pages: kernel-doc corrections
Date: Mon, 8 Oct 2007 18:44:42 +1000
References: <20071008170320.eb123276.randy.dunlap@oracle.com>
In-Reply-To: <20071008170320.eb123276.randy.dunlap@oracle.com>
MIME-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Message-Id: <200710081844.42501.nickpiggin@yahoo.com.au>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Randy Dunlap <randy.dunlap@oracle.com>
Cc: linux-mm@kvack.org, akpm <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

On Tuesday 09 October 2007 10:03, Randy Dunlap wrote:
> From: Randy Dunlap <randy.dunlap@oracle.com>
>
> Fix kernel-doc for sys_remap_file_pages() and add info to the __prot NOTE.

Why not just get rid of the double underscore, I wonder?

Pity that prot always has to be PROT_NONE on most architectures (rather
than the current vma's prot)... but that's something which had to have been
picked up years ago.

>
> Signed-off-by: Randy Dunlap <randy.dunlap@oracle.com>
> ---
>  mm/fremap.c |   20 +++++++++++---------
>  1 file changed, 11 insertions(+), 9 deletions(-)
>
> --- linux-2.6.23-rc9-git3.orig/mm/fremap.c
> +++ linux-2.6.23-rc9-git3/mm/fremap.c
> @@ -97,23 +97,25 @@ static int populate_range(struct mm_stru
>
>  }
>
> -/***
> - * sys_remap_file_pages - remap arbitrary pages of a shared backing store
> - *                        file within an existing vma.
> +/**
> + * sys_remap_file_pages - remap arbitrary pages of a shared backing store

I think the "vma" part is kind of important, and probably not emphasised
enough in the original, and "shared backing store file" is a bit vague. It's
actually a VM_SHARED _vma_.

(which is a bit funny eg. it must be a PROT_WRITE && MAP_SHARED vma
-- doesn't seem to be documented in the man page, and odd that you aren't
allowed to have readonly nonlinear mappings, but it's not mine to wonder
why).

Otherwise, looks OK.

> file * @start: start of the remapped virtual memory range
>   * @size: size of the remapped virtual memory range
> - * @prot: new protection bits of the range
> - * @pgoff: to be mapped page of the backing store file
> + * @__prot: new protection bits of the range (see NOTE)
> + * @pgoff: to-be-mapped page of the backing store file
>   * @flags: 0 or MAP_NONBLOCKED - the later will cause no IO.
>   *
> - * this syscall works purely via pagetables, so it's the most efficient
> + * sys_remap_file_pages remaps arbitrary pages of a shared backing store
> file + * within an existing vma.
> + *
> + * This syscall works purely via pagetables, so it's the most efficient
>   * way to map the same (large) file into a given virtual window. Unlike
>   * mmap()/mremap() it does not create any new vmas. The new mappings are
>   * also safe across swapout.
>   *
> - * NOTE: the 'prot' parameter right now is ignored, and the vma's default
> - * protection is used. Arbitrary protections might be implemented in the
> - * future.
> + * NOTE: the '__prot' parameter right now is ignored (but must be zero),
> + * and the vma's default protection is used. Arbitrary protections
> + * might be implemented in the future.
>   */
>  asmlinkage long sys_remap_file_pages(unsigned long start, unsigned long
> size, unsigned long __prot, unsigned long pgoff, unsigned long flags)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

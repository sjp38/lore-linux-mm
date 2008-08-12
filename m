Subject: Re: [rfc][patch] mm: dirty page accounting hole
From: Peter Zijlstra <peterz@infradead.org>
In-Reply-To: <200808121558.40130.nickpiggin@yahoo.com.au>
References: <200808121558.40130.nickpiggin@yahoo.com.au>
Content-Type: text/plain
Date: Tue, 12 Aug 2008 08:50:40 +0200
Message-Id: <1218523840.10800.129.camel@twins>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nick Piggin <nickpiggin@yahoo.com.au>
Cc: linux-mm@kvack.org, "Dickins, Hugh" <hugh@veritas.com>
List-ID: <linux-mm.kvack.org>

On Tue, 2008-08-12 at 15:58 +1000, Nick Piggin wrote:
> 
> Hi,
> 
> I think I'm running into a hole in dirty page accounting...
> 
> What seems to be happening is that a page gets written to via a
> VM_SHARED vma. We then set the pte dirty, then mark the page dirty.
> Next, mprotect changes the vma so it is no longer writeable so it
> is no longer VM_SHARED. The pte is still dirty.
> 
> Then clear_page_dirty_for_io is called and leaves that pte dirty
> and cleans the page. It never gets cleaned until munmap, so msync
> and writeout accounting are broken.
> 
> I have a fix which just scans VM_SHARED to VM_MAYSHARE. The other
> way I tried is to clear the dirty and write bits and set the page
> dirty in mprotect. The problem with that for me is that I'm trying
> to rework the vm/fs layer so we never have to allocate data to
> write out dirty pages (using page_mkwrite and dirty accounting),

Ooh, nice!

> and so this still leaves me with a window where the vma flags are
> changed but before the pte is marked clean, in which time the page
> is still dirty but it may have its metadata freed because it
> doesn't look dirty.
> 
> There are several other problems I've also run into, including a
> fundamentally indadequate page_mkwrite locking scheme, which was
> naturally ignored when I brought it up during reviewing those
> patches. I digress...

Yes, I remember you bringing that up, and later too when you did those
fault patches. I assumed you were 'working' on it.

> Anyway, here's a patch to fix this first particular issue...

Looks good.
> 
> Index: linux-2.6/mm/rmap.c
> ===================================================================
> --- linux-2.6.orig/mm/rmap.c
> +++ linux-2.6/mm/rmap.c
> @@ -481,7 +481,7 @@ static int page_mkclean_file(struct addr
>  
>         spin_lock(&mapping->i_mmap_lock);
>         vma_prio_tree_foreach(vma, &iter, &mapping->i_mmap, pgoff, pgoff) {
> -               if (vma->vm_flags & VM_SHARED)
> +               if (vma->vm_flags & VM_MAYSHARE)
>                         ret += page_mkclean_one(page, vma);
>         }
>         spin_unlock(&mapping->i_mmap_lock);

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

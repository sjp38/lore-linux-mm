Date: Tue, 1 May 2007 18:06:20 +0100 (BST)
From: Hugh Dickins <hugh@veritas.com>
Subject: Re: 2.6.22 -mm merge plans: mm-detach_vmas_to_be_unmapped-fix
In-Reply-To: <20070430162007.ad46e153.akpm@linux-foundation.org>
Message-ID: <Pine.LNX.4.64.0705011715070.1619@blonde.wat.veritas.com>
References: <20070430162007.ad46e153.akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: akuster@mvista.com, Ken Chen <kenchen@google.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, 30 Apr 2007, Andrew Morton wrote:
> ...
>  mm-detach_vmas_to_be_unmapped-fix.patch
> ...
> Misc MM things.  Will merge.

No, I think that one is just drifting like flotsam towards mainline,
because nobody at all has yet found time to look at it.  And Mr Akuster
appears not to have signed off on it yet.  I've given it a quick look
now, and it seems to be based on misdescription and misconception.

> From: <akuster@mvista.com>
> 
> Wolfgang Wander submitted a fix to address a mmap fragmentation issue.  The
> git patch ( 1363c3cd8603a913a27e2995dccbd70d5312d8e6 ) is somewhat different
> and yields different results when running Wolfgang's test case leakme.c.

Ken did a lot of the work on that I believe: I certainly wouldn't
want to see this patch go in without his Ack.  (I've never done
any work on unmapped area heuristics, but detach_vmas_to_be_unmapped
always catches my eye.)

> 
> IMHO, the vm start and end address are swapped in arch_unmap_area and
> arch_unmap_area_topdown functions.

I disagree.

> 
> Prior to this patch arch_unmap_area() used area->vm_start and
> arch_unmap_area_topdown used area->vm_end

Yes (where area is the vma being unmapped).

> in the git patch the following change showed up.
> 
> if (mm->unmap_area == arch_unmap_area)
>      addr = prev ? prev->vm_start : mm->mmap_base;
> else
>      addr = vma ?  vma->vm_end : mm->mmap_base;

No, that's not what showed up in the git patch: that's what the
patch below is trying to change it to.  The git patch said
	addr = prev ? prev->vm_end : mm->mmap_base
for the bottomup case i.e. setting the unmapped area to the
end of the vma below; and
	addr = vma ? vma->vm_start: mm->mmap_base;
for the topdown case i.e. setting the unmapped area to the
beginning of the vma above.

That seems to me consistent with what was done before, but pushing
the bounds out across any hole, for presumably better behaviour.

> 
> Using Wolfgang Wander's leakme.c test, I get the same results seen with his
> original "Avoiding mmap fragmentation" patch as I do after swapping the start
> & end address in the above code segment.  The patch I submitted addresses this
> typo issue.

I'm pretty sure it is not a typo.  I did a very hasty test with two
aLLocator .c progs Wolfgang posted (one unnamed, one named leakme4.c),
on x86_64, and got apparently the same successful result with and
without the patch below.  In my case, it's probably just slightly
slowing down the algorithm, by demanding an additional find_vma()
because it mispositions mm->free_area_cache to an occupied area.
I don't see how it could ever be an improvement, but I've not
spent long enough checking out that code.

I bet there's improvements that could be made there, but
this patch looks wrong - please don't rush it into 2.6.22
(personally I'd say drop it, but I'd rather Ken takes a look).

Hugh

> 
> 
> Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
> ---
> 
>  mm/mmap.c |    4 ++--
>  1 file changed, 2 insertions(+), 2 deletions(-)
> 
> diff -puN mm/mmap.c~mm-detach_vmas_to_be_unmapped-fix mm/mmap.c
> --- a/mm/mmap.c~mm-detach_vmas_to_be_unmapped-fix
> +++ a/mm/mmap.c
> @@ -1723,9 +1723,9 @@ detach_vmas_to_be_unmapped(struct mm_str
>  	*insertion_point = vma;
>  	tail_vma->vm_next = NULL;
>  	if (mm->unmap_area == arch_unmap_area)
> -		addr = prev ? prev->vm_end : mm->mmap_base;
> +		addr = prev ? prev->vm_start : mm->mmap_base;
>  	else
> -		addr = vma ?  vma->vm_start : mm->mmap_base;
> +		addr = vma ?  vma->vm_end : mm->mmap_base;
>  	mm->unmap_area(mm, addr);
>  	mm->mmap_cache = NULL;		/* Kill the cache. */
>  }

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

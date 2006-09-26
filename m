Date: Tue, 26 Sep 2006 19:10:41 +0100 (BST)
From: Hugh Dickins <hugh@veritas.com>
Subject: Re: [RFC/PATCH mmap2: better determine overflow
In-Reply-To: <20060926103504.82bd9409.rdunlap@xenotime.net>
Message-ID: <Pine.LNX.4.64.0609261902150.1641@blonde.wat.veritas.com>
References: <20060926103504.82bd9409.rdunlap@xenotime.net>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Randy Dunlap <rdunlap@xenotime.net>
Cc: linux-mm@kvack.org, akpm <akpm@osdl.org>
List-ID: <linux-mm.kvack.org>

On Tue, 26 Sep 2006, Randy Dunlap wrote:
> From: Randy Dunlap <rdunlap@xenotime.net>
> 
> mm/mmap.c::do_mmap_pgoff() checks for overflow like:
> 
> 	/* offset overflow? */
> 	if ((pgoff + (len >> PAGE_SHIFT)) < pgoff)
>                return -EOVERFLOW;
> 
> However, using pgoff (page indexes) to determine address range
> overflow doesn't overflow.  Change to use byte offsets instead,
> so that overflow can actually happen and be noticed.

I think you're mistaken there.  Thinking in particular of 32-bit
arches, isn't the check precisely about allowing an mmap at a high
offset of a file >4GB in length; but not at so high an offset that
pgoff (page index) wraps back to 0?  Whereas you're changing it
now to fail at 4GB.

> Also return EOVERFLOW instead of ENOMEM when PAGE_ALIGN(len)
> is 0.

Which standard mandates that change?

Hugh

> 
> Tested on i686 and x86_64.
> 
> Test program is at:  http://www.xenotime.net/linux/src/mmap-test.c
> 
> Signed-off-by: Randy Dunlap <rdunlap@xenotime.net>
> ---
>  mm/mmap.c |    9 ++++++---
>  1 file changed, 6 insertions(+), 3 deletions(-)
> 
> --- linux-2618-work.orig/mm/mmap.c
> +++ linux-2618-work/mm/mmap.c
> @@ -923,13 +923,16 @@ unsigned long do_mmap_pgoff(struct file 
>  
>  	/* Careful about overflows.. */
>  	len = PAGE_ALIGN(len);
> -	if (!len || len > TASK_SIZE)
> -		return -ENOMEM;
> +	if (!len)
> +		return -EOVERFLOW;
>  
>  	/* offset overflow? */
> -	if ((pgoff + (len >> PAGE_SHIFT)) < pgoff)
> +	if (((pgoff << PAGE_SHIFT) + len) < (pgoff << PAGE_SHIFT))
>                 return -EOVERFLOW;
>  
> +	if (len > TASK_SIZE)
> +		return -ENOMEM;
> +
>  	/* Too many mappings? */
>  	if (mm->map_count > sysctl_max_map_count)
>  		return -ENOMEM;
> 
> ---

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

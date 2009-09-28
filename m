Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id 9932F6B008C
	for <linux-mm@kvack.org>; Mon, 28 Sep 2009 11:57:29 -0400 (EDT)
Date: Mon, 28 Sep 2009 12:51:31 +0800
From: Wu Fengguang <fengguang.wu@intel.com>
Subject: Re: No more bits in vm_area_struct's vm_flags.
Message-ID: <20090928045131.GA15149@localhost>
References: <4AB9A0D6.1090004@crca.org.au> <20090924100518.78df6b93.kamezawa.hiroyu@jp.fujitsu.com> <4ABC80B0.5010100@crca.org.au> <20090925174009.79778649.kamezawa.hiroyu@jp.fujitsu.com> <4AC0234F.2080808@crca.org.au> <20090928120450.c2d8a4e2.kamezawa.hiroyu@jp.fujitsu.com> <20090928033624.GA11191@localhost> <20090928125705.6656e8c5.kamezawa.hiroyu@jp.fujitsu.com> <4AC03D9C.3020907@crca.org.au>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <4AC03D9C.3020907@crca.org.au>
Sender: owner-linux-mm@kvack.org
To: Nigel Cunningham <ncunningham@crca.org.au>
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, LKML <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Mon, Sep 28, 2009 at 12:37:48PM +0800, Nigel Cunningham wrote:
> Hi.
> 
> KAMEZAWA Hiroyuki wrote:
> > Then, Nigel, you have 2 choices I think.
> > 
> > (1) don't merge if vm_hints is set  or (2) pass vm_hints to all
> > __merge() functions.
> > 
> > One of above will be accesptable for stakeholders... I personally
> > like (1) but just trying (2) may be accepted.
> > 
> > What I dislike is making vm_flags to be long long ;)
> 
> Okay. I've gone for option 1 for now. Here's what I
> currently have (compile testing as I write)...
> 
> 
> 
> vm_flags in struct vm_area_struct is full. Move some of the less commonly
> used flags to a new variable so that other flags that need to be in vm_flags
> (because, for example, they need to be in variables that are passed around)
> can be added.

Looks good to me with some minor suggestions.

Reviewed-by: Wu Fengguang <fengguang.wu@intel.com>

> Signed-off-by: Nigel Cunningham <nigel@tuxonice.net>
> ---
>  include/linux/mm.h       |   16 ++++++++--------
>  include/linux/mm_types.h |    1 +
>  mm/madvise.c             |   28 ++++++++++++++++++----------
>  mm/mmap.c                |    2 ++
>  4 files changed, 29 insertions(+), 18 deletions(-)
> 
> diff --git a/include/linux/mm.h b/include/linux/mm.h
> index 24c3956..040d0ce 100644
> --- a/include/linux/mm.h
> +++ b/include/linux/mm.h
> @@ -85,10 +85,6 @@ extern unsigned int kobjsize(const void *objp);
>  #define VM_LOCKED	0x00002000
>  #define VM_IO           0x00004000	/* Memory mapped I/O or similar */
>  
> -					/* Used by sys_madvise() */
> -#define VM_SEQ_READ	0x00008000	/* App will access data sequentially */
> -#define VM_RAND_READ	0x00010000	/* App will not benefit from clustered reads */
> -
>  #define VM_DONTCOPY	0x00020000      /* Do not copy this vma on fork */
>  #define VM_DONTEXPAND	0x00040000	/* Cannot expand with mremap() */
>  #define VM_RESERVED	0x00080000	/* Count as reserved_vm like IO */
> @@ -116,11 +112,15 @@ extern unsigned int kobjsize(const void *objp);
>  #define VM_STACK_FLAGS	(VM_GROWSDOWN | VM_STACK_DEFAULT_FLAGS | VM_ACCOUNT)
>  #endif


Maybe add this comment for less confusion?
 
/*
 * vm_hints in vm_area_struct, see mm_types.h.
 */

> +					/* Used by sys_madvise() */
> +#define VM_SEQ_READ	0x00000001	/* App will access data sequentially */
> +#define VM_RAND_READ	0x00000002	/* App will not benefit from clustered reads */
> +
>  #define VM_READHINTMASK			(VM_SEQ_READ | VM_RAND_READ)
> -#define VM_ClearReadHint(v)		(v)->vm_flags &= ~VM_READHINTMASK
> -#define VM_NormalReadHint(v)		(!((v)->vm_flags & VM_READHINTMASK))
> -#define VM_SequentialReadHint(v)	((v)->vm_flags & VM_SEQ_READ)
> -#define VM_RandomReadHint(v)		((v)->vm_flags & VM_RAND_READ)
> +#define VM_ClearReadHint(v)		(v)->vm_hints &= ~VM_READHINTMASK
> +#define VM_NormalReadHint(v)		(!((v)->vm_hints & VM_READHINTMASK))
> +#define VM_SequentialReadHint(v)	((v)->vm_hints & VM_SEQ_READ)
> +#define VM_RandomReadHint(v)		((v)->vm_hints & VM_RAND_READ)
>  
>  /*
>   * special vmas that are non-mergable, non-mlock()able
> diff --git a/include/linux/mm_types.h b/include/linux/mm_types.h
> index 84a524a..5c66e3a 100644
> --- a/include/linux/mm_types.h
> +++ b/include/linux/mm_types.h
> @@ -178,6 +178,7 @@ struct vm_area_struct {
>  					   units, *not* PAGE_CACHE_SIZE */
>  	struct file * vm_file;		/* File we map to (can be NULL). */
>  	void * vm_private_data;		/* was vm_pte (shared mem) */
> +	unsigned long vm_hints;		/* Hints, see mm.h. */
>  	unsigned long vm_truncate_count;/* truncate_count or restart_addr */
>  
>  #ifndef CONFIG_MMU
> diff --git a/mm/madvise.c b/mm/madvise.c
> index 35b1479..59a93d3 100644
> --- a/mm/madvise.c
> +++ b/mm/madvise.c
> @@ -40,19 +40,22 @@ static long madvise_behavior(struct vm_area_struct * vma,
>  		     unsigned long start, unsigned long end, int behavior)
>  {
>  	struct mm_struct * mm = vma->vm_mm;
> -	int error = 0;
> +	int error = 0, skip_merge = 0;
>  	pgoff_t pgoff;
> -	unsigned long new_flags = vma->vm_flags;
> +	unsigned long new_flags = vma->vm_flags, new_hints = vma->vm_hints;

It would be nicer to add standalone lines for skip_merge and new_hints.

Thanks,
Fengguang

>  
>  	switch (behavior) {
>  	case MADV_NORMAL:
> -		new_flags = new_flags & ~VM_RAND_READ & ~VM_SEQ_READ;
> +		new_hints = new_hints & ~VM_RAND_READ & ~VM_SEQ_READ;
> +		skip_merge = 1;
>  		break;
>  	case MADV_SEQUENTIAL:
> -		new_flags = (new_flags & ~VM_RAND_READ) | VM_SEQ_READ;
> +		new_hints = (new_hints & ~VM_RAND_READ) | VM_SEQ_READ;
> +		skip_merge = 1;
>  		break;
>  	case MADV_RANDOM:
> -		new_flags = (new_flags & ~VM_SEQ_READ) | VM_RAND_READ;
> +		new_hints = (new_hints & ~VM_SEQ_READ) | VM_RAND_READ;
> +		skip_merge = 1;
>  		break;
>  	case MADV_DONTFORK:
>  		new_flags |= VM_DONTCOPY;
> @@ -78,11 +81,15 @@ static long madvise_behavior(struct vm_area_struct * vma,
>  	}
>  
>  	pgoff = vma->vm_pgoff + ((start - vma->vm_start) >> PAGE_SHIFT);
> -	*prev = vma_merge(mm, *prev, start, end, new_flags, vma->anon_vma,
> -				vma->vm_file, pgoff, vma_policy(vma));
> -	if (*prev) {
> -		vma = *prev;
> -		goto success;
> +
> +	if (!skip_merge) {
> +		*prev = vma_merge(mm, *prev, start, end, new_flags,
> +				vma->anon_vma, vma->vm_file, pgoff,
> +				vma_policy(vma));
> +		if (*prev) {
> +			vma = *prev;
> +			goto success;
> +		}
>  	}
>  
>  	*prev = vma;
> @@ -104,6 +111,7 @@ success:
>  	 * vm_flags is protected by the mmap_sem held in write mode.
>  	 */
>  	vma->vm_flags = new_flags;
> +	vma->vm_hints = new_hints;
>  
>  out:
>  	if (error == -ENOMEM)
> diff --git a/mm/mmap.c b/mm/mmap.c
> index 73f5e4b..fb4bf98 100644
> --- a/mm/mmap.c
> +++ b/mm/mmap.c
> @@ -670,6 +670,8 @@ static inline int is_mergeable_vma(struct vm_area_struct *vma,
>  		return 0;
>  	if (vma->vm_ops && vma->vm_ops->close)
>  		return 0;
> +	if (vma->vm_hints)
> +		return 0;
>  	return 1;
>  }
>  
> -- 
> 1.6.3.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

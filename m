Subject: Re: [RFC PATCH for -mm 3/5] kill unnecessary locked_vm adjustment
From: Lee Schermerhorn <Lee.Schermerhorn@hp.com>
In-Reply-To: <20080811160542.945F.KOSAKI.MOTOHIRO@jp.fujitsu.com>
References: <20080811151313.9456.KOSAKI.MOTOHIRO@jp.fujitsu.com>
	 <20080811160542.945F.KOSAKI.MOTOHIRO@jp.fujitsu.com>
Content-Type: text/plain
Date: Tue, 12 Aug 2008 15:55:10 -0400
Message-Id: <1218570910.6360.120.camel@lts-notebook>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: linux-mm <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>
List-ID: <linux-mm.kvack.org>

On Mon, 2008-08-11 at 16:06 +0900, KOSAKI Motohiro wrote:
> Now, __mlock_vma_pages_range never return positive value.
> So, locked_vm adjustment code is unnecessary.

True, __mlock_vma_pages_range() does not return a positive value.  [It
didn't before this patch series, right?]  However, you are now counting
mlocked hugetlb pages and user mapped kernel pages against locked_vm--at
least in the mmap(MAP_LOCKED) path--even tho' we don't actually mlock().
Note that mlock[all]() will still avoid counting these pages in
mlock_fixup(), as I think it should.

Huge shm pages are already counted against user->locked_shm.  This patch
counts them against mm->locked_vm, as well, if one mlock()s them.  But,
since locked_vm and locked_shm are compared to the memlock rlimit
independently, so we won't be double counting the huge pages against
either limit.  However,  mlock()ed [not SHMLOCKed] hugetlb pages will
now be counted against locked_vm limit and will reduce the amount of
non-shm memory that the task can lock [maybe not such a bad thing?].
Also, mlock()ed hugetlb pages will be included in the /proc/<pid>/status
"VmLck" element, even tho' they're not really mlocked and they don't
show up in the /proc/meminfo "Mlocked" count.

Similarly, mlock()ing a vm range backed by kernel pages--e.g.,
VM_RESERVED|VM_DONTEXPAND vmas--will show up in the VmLck status
element, but won't actually be mlocked nor counted in Mlocked meminfo
field.  They will be counted against the task's locked vm limit.

So, I don't know whether to Ack or Nack this.  I guess it's no further
from reality than the current code.  But, I don't think you need this
one.  The code already differentiates between negative values as error
codes and non-negative values as an adjustment to locked_vm, so you
should be able to meet the standards mandated error returns without this
patch.  

Still thinking about this...
Lee

> 
> also, related comment fixed.
> 
> 
> Signed-off-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
> 
> ---
>  mm/mlock.c |   18 +++++-------------
>  mm/mmap.c  |   10 +++++-----
>  2 files changed, 10 insertions(+), 18 deletions(-)
> 
> Index: b/mm/mlock.c
> ===================================================================
> --- a/mm/mlock.c
> +++ b/mm/mlock.c
> @@ -276,7 +276,7 @@ int mlock_vma_pages_range(struct vm_area
>  			unsigned long start, unsigned long end)
>  {
>  	struct mm_struct *mm = vma->vm_mm;
> -	int nr_pages = (end - start) / PAGE_SIZE;
> +	int error = 0;
>  	BUG_ON(!(vma->vm_flags & VM_LOCKED));
>  
>  	/*
> @@ -289,8 +289,7 @@ int mlock_vma_pages_range(struct vm_area
>  			is_vm_hugetlb_page(vma) ||
>  			vma == get_gate_vma(current))) {
>  		downgrade_write(&mm->mmap_sem);
> -		nr_pages = __mlock_vma_pages_range(vma, start, end, 1);
> -
> +		error = __mlock_vma_pages_range(vma, start, end, 1);
>  		up_read(&mm->mmap_sem);
>  		/* vma can change or disappear */
>  		down_write(&mm->mmap_sem);
> @@ -298,22 +297,19 @@ int mlock_vma_pages_range(struct vm_area
>  		/* non-NULL vma must contain @start, but need to check @end */
>  		if (!vma ||  end > vma->vm_end)
>  			return -EAGAIN;
> -		return nr_pages;
> +		return error;
>  	}
>  
>  	/*
>  	 * User mapped kernel pages or huge pages:
>  	 * make these pages present to populate the ptes, but
> -	 * fall thru' to reset VM_LOCKED--no need to unlock, and
> -	 * return nr_pages so these don't get counted against task's
> -	 * locked limit.  huge pages are already counted against
> -	 * locked vm limit.
> +	 * fall thru' to reset VM_LOCKED--no need to unlock.
>  	 */
>  	make_pages_present(start, end);
>  
>  no_mlock:
>  	vma->vm_flags &= ~VM_LOCKED;	/* and don't come back! */
> -	return nr_pages;		/* pages NOT mlocked */
> +	return error;			/* pages NOT mlocked */
>  }
>  
> 
> @@ -402,10 +398,6 @@ success:
>  		downgrade_write(&mm->mmap_sem);
>  
>  		ret = __mlock_vma_pages_range(vma, start, end, 1);
> -		if (ret > 0) {
> -			mm->locked_vm -= ret;
> -			ret = 0;
> -		}
>  		/*
>  		 * Need to reacquire mmap sem in write mode, as our callers
>  		 * expect this.  We have no support for atomically upgrading
> Index: b/mm/mmap.c
> ===================================================================
> --- a/mm/mmap.c
> +++ b/mm/mmap.c
> @@ -1229,10 +1229,10 @@ out:
>  		/*
>  		 * makes pages present; downgrades, drops, reacquires mmap_sem
>  		 */
> -		int nr_pages = mlock_vma_pages_range(vma, addr, addr + len);
> -		if (nr_pages < 0)
> -			return nr_pages;	/* vma gone! */
> -		mm->locked_vm += (len >> PAGE_SHIFT) - nr_pages;
> +		int error = mlock_vma_pages_range(vma, addr, addr + len);
> +		if (error < 0)
> +			return error;	/* vma gone! */
> +		mm->locked_vm += (len >> PAGE_SHIFT);
>  	} else if ((flags & MAP_POPULATE) && !(flags & MAP_NONBLOCK))
>  		make_pages_present(addr, addr + len);
>  	return addr;
> @@ -2087,7 +2087,7 @@ out:
>  	if (flags & VM_LOCKED) {
>  		int nr_pages = mlock_vma_pages_range(vma, addr, addr + len);
>  		if (nr_pages >= 0)
> -			mm->locked_vm += (len >> PAGE_SHIFT) - nr_pages;
> +			mm->locked_vm += (len >> PAGE_SHIFT);
>  	}
>  	return addr;
>  undo_charge:
> 
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

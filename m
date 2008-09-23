Date: Tue, 23 Sep 2008 14:53:42 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: mlock: Make the mlock system call interruptible by fatal
 signals.
Message-Id: <20080923145342.7a14fb4f.akpm@linux-foundation.org>
In-Reply-To: <20080923213811.GA24086@google.com>
References: <20080923213811.GA24086@google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Salman Qazi <sqazi@google.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Tue, 23 Sep 2008 14:38:11 -0700
sqazi@google.com (Salman Qazi) wrote:

> 
> Make the mlock system call interruptible by fatal signals, so that programs
> that are mlocking a large number of pages terminate quickly when killed.
> 
> Signed-off-by: Salman Qazi <sqazi@google.com>
> ---
> 
> diff --git a/include/linux/mm.h b/include/linux/mm.h
> index 72a15dc..a2531e6 100644
> --- a/include/linux/mm.h
> +++ b/include/linux/mm.h
> @@ -807,7 +807,8 @@ static inline int handle_mm_fault(struct mm_struct *mm,
>  }
>  #endif
>  
> -extern int make_pages_present(unsigned long addr, unsigned long end);
> +extern int make_pages_present(unsigned long addr, unsigned long end,
> +			int interruptible);
>  extern int access_process_vm(struct task_struct *tsk, unsigned long addr, void *buf, int len, int write);
>  
>  int get_user_pages(struct task_struct *tsk, struct mm_struct *mm, unsigned long start,
> diff --git a/mm/fremap.c b/mm/fremap.c
> index 7881638..f5eff74 100644
> --- a/mm/fremap.c
> +++ b/mm/fremap.c
> @@ -223,7 +223,7 @@ asmlinkage long sys_remap_file_pages(unsigned long start, unsigned long size,
>  			downgrade_write(&mm->mmap_sem);
>  			has_write_lock = 0;
>  		}
> -		make_pages_present(start, start+size);
> +		make_pages_present(start, start+size, 0);
>  	}
>  
>  	/*
> diff --git a/mm/memory.c b/mm/memory.c
> index 1002f47..4088fd0 100644
> --- a/mm/memory.c
> +++ b/mm/memory.c
> @@ -1129,9 +1129,10 @@ static inline int use_zero_page(struct vm_area_struct *vma)
>  	return !vma->vm_ops || !vma->vm_ops->fault;
>  }
>  
> -int get_user_pages(struct task_struct *tsk, struct mm_struct *mm,
> -		unsigned long start, int len, int write, int force,
> -		struct page **pages, struct vm_area_struct **vmas)
> +static int __get_user_pages(struct task_struct *tsk, struct mm_struct *mm,
> +			unsigned long start, int len, int write, int force,
> +			struct page **pages, struct vm_area_struct **vmas,
> +			int interruptible)
>  {
>  	int i;
>  	unsigned int vm_flags;
> @@ -1223,6 +1224,8 @@ int get_user_pages(struct task_struct *tsk, struct mm_struct *mm,
>  			cond_resched();
>  			while (!(page = follow_page(vma, start, foll_flags))) {
>  				int ret;
> +				if (interruptible && fatal_signal_pending(tsk))
> +					return -EINTR;

This isn't a terribly good interface.  Someone could now call
__get_user_pages() with pages!=NULL and interruptible=1 and they would
get a return value of -EINTR, even though some page*'s were placed in
their pages array.

That caller now has no way of knowing how many pages need to be
released to clean up.

Can we do

	return i ? i : -EINTR;

in the usual fashion?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

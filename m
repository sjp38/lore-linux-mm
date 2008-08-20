Date: Wed, 20 Aug 2008 17:35:57 +0900
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [PATCH 6/6] Mlock:  make mlock error return Posixly Correct
In-Reply-To: <20080819210545.27199.5276.sendpatchset@lts-notebook>
References: <20080819210509.27199.6626.sendpatchset@lts-notebook> <20080819210545.27199.5276.sendpatchset@lts-notebook>
Message-Id: <20080820163559.12D9.KOSAKI.MOTOHIRO@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Lee Schermerhorn <lee.schermerhorn@hp.com>
Cc: kosaki.motohiro@jp.fujitsu.com, akpm@linux-foundation.org, riel@redhat.com, linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

> From:  KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
> 
> Against:  2.6.27-rc3-mmotm-080816-0202
> 
> Rework Posix error return for mlock().
> 
> Translate get_user_pages() error to posix specified error codes.
> 
> Signed-off-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
> Signed-off-by: Lee Schermerhorn <lee.schermerhorn@hp.com>
> 
>  mm/memory.c |    2 +-
>  mm/mlock.c  |   27 ++++++++++++++++++++++++---
>  2 files changed, 25 insertions(+), 4 deletions(-)
> 
> Index: linux-2.6.27-rc3-mmotm/mm/mlock.c
> ===================================================================
> --- linux-2.6.27-rc3-mmotm.orig/mm/mlock.c	2008-08-18 15:57:11.000000000 -0400
> +++ linux-2.6.27-rc3-mmotm/mm/mlock.c	2008-08-18 15:57:39.000000000 -0400
> @@ -143,6 +143,18 @@ static void munlock_vma_page(struct page
>  	}
>  }
>  
> +/*
> + * convert get_user_pages() return value to posix mlock() error
> + */
> +static int __mlock_posix_error_return(long retval)
> +{
> +	if (retval == -EFAULT)
> +		retval = -ENOMEM;
> +	else if (retval == -ENOMEM)
> +		retval = -EAGAIN;
> +	return retval;
> +}
> +
>  /**
>   * __mlock_vma_pages_range() -  mlock/munlock a range of pages in the vma.
>   * @vma:   target vma
> @@ -209,8 +221,13 @@ static long __mlock_vma_pages_range(stru
>  		 * or for addresses that map beyond end of a file.
>  		 * We'll mlock the the pages if/when they get faulted in.
>  		 */
> -		if (ret < 0)
> +		if (ret < 0) {
> +			if (vma->vm_flags & VM_NONLINEAR)
> +				ret = 0;
> +			else
> +				ret = __mlock_posix_error_return(ret);
>  			break;
> +		}
>  		if (ret == 0) {
>  			/*
>  			 * We know the vma is there, so the only time

__mlock_vma_pages_range is used by mmap() and mlock().

mlock case 

	sys_mlock
		do_mlock
			mlock_fixup
				__mlock_vma_pages_range

mmap case

	do_mmap_pgoff
		mmap_region
			mlock_vma_pages_range
				__mlock_vma_pages_range


mlock() need error code if vma permission failure happend.
but mmap() (and remap_pages_range(), etc..) should ignore it.

So, mlock_vma_pages_range() should ignore __mlock_vma_pages_range()'s error code.



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

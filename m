Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f180.google.com (mail-pd0-f180.google.com [209.85.192.180])
	by kanga.kvack.org (Postfix) with ESMTP id AB9C36B00DC
	for <linux-mm@kvack.org>; Wed, 23 Oct 2013 14:30:46 -0400 (EDT)
Received: by mail-pd0-f180.google.com with SMTP id p10so1240850pdj.39
        for <linux-mm@kvack.org>; Wed, 23 Oct 2013 11:30:46 -0700 (PDT)
Received: from psmtp.com ([74.125.245.199])
        by mx.google.com with SMTP id if1si16189641pad.88.2013.10.23.11.30.42
        for <linux-mm@kvack.org>;
        Wed, 23 Oct 2013 11:30:43 -0700 (PDT)
Date: Wed, 23 Oct 2013 14:30:20 -0400
From: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Message-ID: <1382553020-bqbnnzwq-mutt-n-horiguchi@ah.jp.nec.com>
In-Reply-To: <20131023164447.B20D.38390934@jp.panasonic.com>
References: <20131023145303.B205.38390934@jp.panasonic.com>
 <1382511049-gd4rydjg-mutt-n-horiguchi@ah.jp.nec.com>
 <20131023164447.B20D.38390934@jp.panasonic.com>
Subject: Re: [PATCH v2] mm: Ensure get_unmapped_area() returns higher
 addressthan mmap_min_addr
Mime-Version: 1.0
Content-Type: text/plain;
 charset=iso-2022-jp
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Akira Takeuchi <takeuchi.akr@jp.panasonic.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>

Cc:ed Andrew,

On Wed, Oct 23, 2013 at 04:44:47PM +0900, Akira Takeuchi wrote:
> This patch fixes the problem that get_unmapped_area() can return illegal
> address and result in failing mmap(2) etc.
> 
> In case that the address higher than PAGE_SIZE is set to
> /proc/sys/vm/mmap_min_addr, the address lower than mmap_min_addr can be
> returned by get_unmapped_area(), even if you do not pass any virtual address
> hint (i.e. the second argument).
> 
> This is because the current get_unmapped_area() code does not take into
> account mmap_min_addr.
> 
> This leads to two actual problems as follows:
> 
> 1. mmap(2) can fail with EPERM on the process without CAP_SYS_RAWIO,
>    although any illegal parameter is not passed.
> 
> 2. The bottom-up search path after the top-down search might not work in
>    arch_get_unmapped_area_topdown().
> 
> Note: The first and third chunk of my patch, which changes "len" check,
> are for more precise check using mmap_min_addr, and not for solving the
> above problem.
> 
> [How to reproduce]
> 
> 	--- test.c -------------------------------------------------
> 	#include <stdio.h>
> 	#include <unistd.h>
> 	#include <sys/mman.h>
> 	#include <sys/errno.h>
> 
> 	int main(int argc, char *argv[])
> 	{
> 		void *ret = NULL, *last_map;
> 		size_t pagesize = sysconf(_SC_PAGESIZE);
> 
> 		do {
> 			last_map = ret;
> 			ret = mmap(0, pagesize, PROT_NONE,
> 				MAP_PRIVATE|MAP_ANONYMOUS, -1, 0);
> 	//		printf("ret=%p\n", ret);
> 		} while (ret != MAP_FAILED);
> 
> 		if (errno != ENOMEM) {
> 			printf("ERR: unexpected errno: %d (last map=%p)\n",
> 			errno, last_map);
> 		}
> 
> 		return 0;
> 	}
> 	---------------------------------------------------------------
> 
> 	$ gcc -m32 -o test test.c
> 	$ sudo sysctl -w vm.mmap_min_addr=65536
> 	vm.mmap_min_addr = 65536
> 	$ ./test  (run as non-priviledge user)
> 	ERR: unexpected errno: 1 (last map=0x10000)
> 
> Signed-off-by: Akira Takeuchi <takeuchi.akr@jp.panasonic.com>
> Signed-off-by: Kiyoshi Owada <owada.kiyoshi@jp.panasonic.com>
> Reviewed-by: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>

BTW, this bug seems to be very old, so I think this patch is worth
going into all of currently living stable trees.

Thanks,
Naoya Horiguchi

> ---
>  mm/mmap.c |   10 +++++-----
>  1 files changed, 5 insertions(+), 5 deletions(-)
> 
> diff --git a/mm/mmap.c b/mm/mmap.c
> index 9d54851..362e5f1 100644
> --- a/mm/mmap.c
> +++ b/mm/mmap.c
> @@ -1856,7 +1856,7 @@ arch_get_unmapped_area(struct file *filp, unsigned long addr,
>  	struct vm_area_struct *vma;
>  	struct vm_unmapped_area_info info;
>  
> -	if (len > TASK_SIZE)
> +	if (len > TASK_SIZE - mmap_min_addr)
>  		return -ENOMEM;
>  
>  	if (flags & MAP_FIXED)
> @@ -1865,7 +1865,7 @@ arch_get_unmapped_area(struct file *filp, unsigned long addr,
>  	if (addr) {
>  		addr = PAGE_ALIGN(addr);
>  		vma = find_vma(mm, addr);
> -		if (TASK_SIZE - len >= addr &&
> +		if (TASK_SIZE - len >= addr && addr >= mmap_min_addr &&
>  		    (!vma || addr + len <= vma->vm_start))
>  			return addr;
>  	}
> @@ -1895,7 +1895,7 @@ arch_get_unmapped_area_topdown(struct file *filp, const unsigned long addr0,
>  	struct vm_unmapped_area_info info;
>  
>  	/* requested length too big for entire address space */
> -	if (len > TASK_SIZE)
> +	if (len > TASK_SIZE - mmap_min_addr)
>  		return -ENOMEM;
>  
>  	if (flags & MAP_FIXED)
> @@ -1905,14 +1905,14 @@ arch_get_unmapped_area_topdown(struct file *filp, const unsigned long addr0,
>  	if (addr) {
>  		addr = PAGE_ALIGN(addr);
>  		vma = find_vma(mm, addr);
> -		if (TASK_SIZE - len >= addr &&
> +		if (TASK_SIZE - len >= addr && addr >= mmap_min_addr &&
>  				(!vma || addr + len <= vma->vm_start))
>  			return addr;
>  	}
>  
>  	info.flags = VM_UNMAPPED_AREA_TOPDOWN;
>  	info.length = len;
> -	info.low_limit = PAGE_SIZE;
> +	info.low_limit = max(PAGE_SIZE, mmap_min_addr);
>  	info.high_limit = mm->mmap_base;
>  	info.align_mask = 0;
>  	addr = vm_unmapped_area(&info);
> -- 
> 1.7.0.4
> 
> 
> -- 
> Akira Takeuchi <takeuchi.akr@jp.panasonic.com>
> 
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

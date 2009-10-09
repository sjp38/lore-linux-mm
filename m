Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id 35FF16B005D
	for <linux-mm@kvack.org>; Fri,  9 Oct 2009 05:28:36 -0400 (EDT)
Date: Fri, 9 Oct 2009 10:28:18 +0100 (BST)
From: Hugh Dickins <hugh.dickins@tiscali.co.uk>
Subject: Re: [PATCH] munmap() don't check sysctl_max_mapcount
In-Reply-To: <20091002180533.5F77.A69D9226@jp.fujitsu.com>
Message-ID: <Pine.LNX.4.64.0910091007010.17240@sister.anvils>
References: <20091002180533.5F77.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, Hugh Dickins <hugh.dickins@tiscali.co.uk>
List-ID: <linux-mm.kvack.org>

On Fri, 2 Oct 2009, KOSAKI Motohiro wrote:

> Hi everyone,
> 
> Is this good idea?

Sorry, I overlooked this earlier.

Correct me if I'm wrong, but from the look of your patch,
I believe anyone could increase their mapcount arbitrarily far beyond
sysctl_max_map_count, just by taking little bites out of a large mmap.

In which case there's not much point in having sysctl_max_map_count
at all.  Perhaps there isn't much point to it anyway, and the answer
is just to raise it to where it catches runaways but interferes with
nobody else?

If you change your patch so that do_munmap() cannot increase the final
number vmas beyond sysctl_max_map_count, that would seem reasonable.
But would that satisfy your testcase?  And does the testcase really
matter in practice?  It doesn't seem to have upset anyone before.

Hugh

> 
> 
> ====================================================================
> From 0b9de3b65158847d376e2786840f932361d00e08 Mon Sep 17 00:00:00 2001
> From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
> Date: Fri, 18 Sep 2009 13:22:06 +0900
> Subject: [PATCH] munmap() don't check sysctl_max_mapcount
> 
> On ia64, the following test program exit abnormally, because
> glibc thread library called abort().
> 
>  ========================================================
>  (gdb) bt
>  #0  0xa000000000010620 in __kernel_syscall_via_break ()
>  #1  0x20000000003208e0 in raise () from /lib/libc.so.6.1
>  #2  0x2000000000324090 in abort () from /lib/libc.so.6.1
>  #3  0x200000000027c3e0 in __deallocate_stack () from /lib/libpthread.so.0
>  #4  0x200000000027f7c0 in start_thread () from /lib/libpthread.so.0
>  #5  0x200000000047ef60 in __clone2 () from /lib/libc.so.6.1
>  ========================================================
> 
> The fact is, glibc call munmap() when thread exitng time for freeing stack, and
> it assume munlock() never fail. However, munmap() often make vma splitting
> and it with many mapcount make -ENOMEM.
> 
> Oh well, stack unfreeing is not reasonable option. Also munlock() via free()
> shouldn't failed.
> 
> Thus, munmap() shoudn't check max-mapcount. This patch does it.
> 
>  test_max_mapcount.c
>  ==================================================================
>   #include<stdio.h>
>   #include<stdlib.h>
>   #include<string.h>
>   #include<pthread.h>
>   #include<errno.h>
>   #include<unistd.h>
>  
>   #define THREAD_NUM 30000
>   #define MAL_SIZE (100*1024)
>  
>  void *wait_thread(void *args)
>  {
>  	void *addr;
>  
>  	addr = malloc(MAL_SIZE);
>  	if(addr)
>  		memset(addr, 1, MAL_SIZE);
>  	sleep(1);
>  
>  	return NULL;
>  }
>  
>  void *wait_thread2(void *args)
>  {
>  	sleep(60);
>  
>  	return NULL;
>  }
>  
>  int main(int argc, char *argv[])
>  {
>  	int i;
>  	pthread_t thread[THREAD_NUM], th;
>  	int ret, count = 0;
>  	pthread_attr_t attr;
>  
>  	ret = pthread_attr_init(&attr);
>  	if(ret) {
>  		perror("pthread_attr_init");
>  	}
>  
>  	ret = pthread_attr_setdetachstate(&attr, PTHREAD_CREATE_DETACHED);
>  	if(ret) {
>  		perror("pthread_attr_setdetachstate");
>  	}
>  
>  	for (i = 0; i < THREAD_NUM; i++) {
>  		ret = pthread_create(&th, &attr, wait_thread, NULL);
>  		if(ret) {
>  			fprintf(stderr, "[%d] ", count);
>  			perror("pthread_create");
>  		} else {
>  			printf("[%d] create OK.\n", count);
>  		}
>  		count++;
>  
>  		ret = pthread_create(&thread[i], &attr, wait_thread2, NULL);
>  		if(ret) {
>  			fprintf(stderr, "[%d] ", count);
>  			perror("pthread_create");
>  		} else {
>  			printf("[%d] create OK.\n", count);
>  		}
>  		count++;
>  	}
>  
>  	sleep(3600);
>  	return 0;
>  }
>  ==================================================================
> 
> 
> 
> Signed-off-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
> ---
>  mm/mmap.c |   18 ++++++++++++------
>  1 file changed, 12 insertions(+), 6 deletions(-)
> 
> Index: b/mm/mmap.c
> ===================================================================
> --- a/mm/mmap.c
> +++ b/mm/mmap.c
> @@ -1832,7 +1832,7 @@ detach_vmas_to_be_unmapped(struct mm_str
>   * Split a vma into two pieces at address 'addr', a new vma is allocated
>   * either for the first part or the tail.
>   */
> -int split_vma(struct mm_struct * mm, struct vm_area_struct * vma,
> +static int __split_vma(struct mm_struct * mm, struct vm_area_struct * vma,
>  	      unsigned long addr, int new_below)
>  {
>  	struct mempolicy *pol;
> @@ -1842,9 +1842,6 @@ int split_vma(struct mm_struct * mm, str
>  					~(huge_page_mask(hstate_vma(vma)))))
>  		return -EINVAL;
>  
> -	if (mm->map_count >= sysctl_max_map_count)
> -		return -ENOMEM;
> -
>  	new = kmem_cache_alloc(vm_area_cachep, GFP_KERNEL);
>  	if (!new)
>  		return -ENOMEM;
> @@ -1884,6 +1881,15 @@ int split_vma(struct mm_struct * mm, str
>  	return 0;
>  }
>  
> +int split_vma(struct mm_struct * mm, struct vm_area_struct * vma,
> +	      unsigned long addr, int new_below)
> +{
> +	if (mm->map_count >= sysctl_max_map_count)
> +		return -ENOMEM;
> +
> +	return __split_vma(mm, vma, addr, new_below);
> +}
> +
>  /* Munmap is split into 2 main parts -- this part which finds
>   * what needs doing, and the areas themselves, which do the
>   * work.  This now handles partial unmappings.
> @@ -1919,7 +1925,7 @@ int do_munmap(struct mm_struct *mm, unsi
>  	 * places tmp vma above, and higher split_vma places tmp vma below.
>  	 */
>  	if (start > vma->vm_start) {
> -		int error = split_vma(mm, vma, start, 0);
> +		int error = __split_vma(mm, vma, start, 0);
>  		if (error)
>  			return error;
>  		prev = vma;
> @@ -1928,7 +1934,7 @@ int do_munmap(struct mm_struct *mm, unsi
>  	/* Does it split the last one? */
>  	last = find_vma(mm, end);
>  	if (last && end > last->vm_start) {
> -		int error = split_vma(mm, last, end, 1);
> +		int error = __split_vma(mm, last, end, 1);
>  		if (error)
>  			return error;
>  	}

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

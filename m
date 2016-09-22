Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f72.google.com (mail-pa0-f72.google.com [209.85.220.72])
	by kanga.kvack.org (Postfix) with ESMTP id 22F7F280256
	for <linux-mm@kvack.org>; Thu, 22 Sep 2016 12:24:42 -0400 (EDT)
Received: by mail-pa0-f72.google.com with SMTP id mi5so158080933pab.2
        for <linux-mm@kvack.org>; Thu, 22 Sep 2016 09:24:42 -0700 (PDT)
Received: from mail-pa0-x242.google.com (mail-pa0-x242.google.com. [2607:f8b0:400e:c03::242])
        by mx.google.com with ESMTPS id p64si2724145pfg.111.2016.09.22.09.24.40
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 22 Sep 2016 09:24:40 -0700 (PDT)
Received: by mail-pa0-x242.google.com with SMTP id hi10so3850703pac.2
        for <linux-mm@kvack.org>; Thu, 22 Sep 2016 09:24:40 -0700 (PDT)
Message-ID: <1474561478.23058.127.camel@edumazet-glaptop3.roam.corp.google.com>
Subject: Re: [PATCH] fs/select: add vmalloc fallback for select(2)
From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Thu, 22 Sep 2016 09:24:38 -0700
In-Reply-To: <20160922152831.24165-1-vbabka@suse.cz>
References: <20160922152831.24165-1-vbabka@suse.cz>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: Alexander Viro <viro@zeniv.linux.org.uk>, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Michal Hocko <mhocko@kernel.org>, netdev@vger.kernel.org

On Thu, 2016-09-22 at 17:28 +0200, Vlastimil Babka wrote:
> The select(2) syscall performs a kmalloc(size, GFP_KERNEL) where size grows
> with the number of fds passed. We had a customer report page allocation
> failures of order-4 for this allocation. This is a costly order, so it might
> easily fail, as the VM expects such allocation to have a lower-order fallback.
> 
> Such trivial fallback is vmalloc(), as the memory doesn't have to be
> physically contiguous. Also the allocation is temporary for the duration of the
> syscall, so it's unlikely to stress vmalloc too much.
> 
> Note that the poll(2) syscall seems to use a linked list of order-0 pages, so
> it doesn't need this kind of fallback.
> 
> Signed-off-by: Vlastimil Babka <vbabka@suse.cz>
> ---
>  fs/select.c | 15 +++++++++++----
>  1 file changed, 11 insertions(+), 4 deletions(-)
> 
> diff --git a/fs/select.c b/fs/select.c
> index 8ed9da50896a..8fe5bddbe99b 100644
> --- a/fs/select.c
> +++ b/fs/select.c
> @@ -29,6 +29,7 @@
>  #include <linux/sched/rt.h>
>  #include <linux/freezer.h>
>  #include <net/busy_poll.h>
> +#include <linux/vmalloc.h>
>  
>  #include <asm/uaccess.h>
>  
> @@ -558,6 +559,7 @@ int core_sys_select(int n, fd_set __user *inp, fd_set __user *outp,
>  	struct fdtable *fdt;
>  	/* Allocate small arguments on the stack to save memory and be faster */
>  	long stack_fds[SELECT_STACK_ALLOC/sizeof(long)];
> +	unsigned long alloc_size;
>  
>  	ret = -EINVAL;
>  	if (n < 0)
> @@ -580,10 +582,15 @@ int core_sys_select(int n, fd_set __user *inp, fd_set __user *outp,
>  	bits = stack_fds;
>  	if (size > sizeof(stack_fds) / 6) {
>  		/* Not enough space in on-stack array; must use kmalloc */
> +		alloc_size = 6 * size;
>  		ret = -ENOMEM;
> -		bits = kmalloc(6 * size, GFP_KERNEL);
> -		if (!bits)
> -			goto out_nofds;
> +		bits = kmalloc(alloc_size, GFP_KERNEL|__GFP_NOWARN);
> +		if (!bits && alloc_size > PAGE_SIZE) {
> +			bits = vmalloc(alloc_size);
> +
> +			if (!bits)
> +				goto out_nofds;

Test should happen if alloc_size <= PAGE_SIZE

> +		}

if (!bits && alloc_size > PAGE_SIZE)
    bits = vmalloc(alloc_size);

if (!bits)
      goto out_nofds;



>  	}
>  	fds.in      = bits;
>  	fds.out     = bits +   size;
> @@ -618,7 +625,7 @@ int core_sys_select(int n, fd_set __user *inp, fd_set __user *outp,
>  
>  out:
>  	if (bits != stack_fds)
> -		kfree(bits);
> +		kvfree(bits);
>  out_nofds:
>  	return ret;
>  }


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

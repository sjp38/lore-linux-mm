Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f70.google.com (mail-pa0-f70.google.com [209.85.220.70])
	by kanga.kvack.org (Postfix) with ESMTP id ED61F280261
	for <linux-mm@kvack.org>; Fri, 23 Sep 2016 02:43:09 -0400 (EDT)
Received: by mail-pa0-f70.google.com with SMTP id mi5so188934053pab.2
        for <linux-mm@kvack.org>; Thu, 22 Sep 2016 23:43:09 -0700 (PDT)
Received: from out4441.biz.mail.alibaba.com (out4441.biz.mail.alibaba.com. [47.88.44.41])
        by mx.google.com with ESMTP id g20si6317770pfg.127.2016.09.22.23.43.07
        for <linux-mm@kvack.org>;
        Thu, 22 Sep 2016 23:43:09 -0700 (PDT)
Reply-To: "Hillf Danton" <hillf.zj@alibaba-inc.com>
From: "Hillf Danton" <hillf.zj@alibaba-inc.com>
References: <20160922152831.24165-1-vbabka@suse.cz>
In-Reply-To: <20160922152831.24165-1-vbabka@suse.cz>
Subject: Re: [PATCH] fs/select: add vmalloc fallback for select(2)
Date: Fri, 23 Sep 2016 14:42:53 +0800
Message-ID: <006101d21565$b60a8a70$221f9f50$@alibaba-inc.com>
MIME-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 7bit
Content-Language: zh-cn
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: 'Vlastimil Babka' <vbabka@suse.cz>, 'Alexander Viro' <viro@zeniv.linux.org.uk>
Cc: linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, 'Michal Hocko' <mhocko@kernel.org>, netdev@vger.kernel.org

> 
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
> +		}

Looks like we also have to bail out if kmalloc fails with 
alloc_size less than PAGE_SIZE.

thanks
Hillf
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
> --
> 2.10.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

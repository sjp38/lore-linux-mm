Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f70.google.com (mail-pa0-f70.google.com [209.85.220.70])
	by kanga.kvack.org (Postfix) with ESMTP id 9381B28024E
	for <linux-mm@kvack.org>; Mon, 26 Sep 2016 20:01:07 -0400 (EDT)
Received: by mail-pa0-f70.google.com with SMTP id cg13so378902865pac.1
        for <linux-mm@kvack.org>; Mon, 26 Sep 2016 17:01:07 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id 82si27190508pfs.145.2016.09.26.17.01.06
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 26 Sep 2016 17:01:06 -0700 (PDT)
Date: Mon, 26 Sep 2016 17:01:05 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH v2] fs/select: add vmalloc fallback for select(2)
Message-Id: <20160926170105.517f74cd67ecdd5ef73e1865@linux-foundation.org>
In-Reply-To: <20160922164359.9035-1-vbabka@suse.cz>
References: <20160922164359.9035-1-vbabka@suse.cz>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: Alexander Viro <viro@zeniv.linux.org.uk>, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Michal Hocko <mhocko@kernel.org>, netdev@vger.kernel.org, Eric Dumazet <eric.dumazet@gmail.com>

On Thu, 22 Sep 2016 18:43:59 +0200 Vlastimil Babka <vbabka@suse.cz> wrote:

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
> ...
>
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
> @@ -580,8 +582,12 @@ int core_sys_select(int n, fd_set __user *inp, fd_set __user *outp,
>  	bits = stack_fds;
>  	if (size > sizeof(stack_fds) / 6) {
>  		/* Not enough space in on-stack array; must use kmalloc */
> +		alloc_size = 6 * size;

Well.  `size' is `unsigned'.  The multiplication will be done as 32-bit
so there was no point in making `alloc_size' unsigned long.

So can we tighten up the types in this function?  size_t might make
sense, but vmalloc() takes a ulong.

>  		ret = -ENOMEM;
> -		bits = kmalloc(6 * size, GFP_KERNEL);
> +		bits = kmalloc(alloc_size, GFP_KERNEL|__GFP_NOWARN);
> +		if (!bits && alloc_size > PAGE_SIZE)
> +			bits = vmalloc(alloc_size);

I don't share Eric's concerns about performance here.  If the vmalloc()
is called, we're about to write to that quite large amount of memory
which we just allocated, and the vmalloc() overhead will be relatively
low.

>  		if (!bits)
>  			goto out_nofds;
>  	}
> @@ -618,7 +624,7 @@ int core_sys_select(int n, fd_set __user *inp, fd_set __user *outp,
>  
>  out:
>  	if (bits != stack_fds)
> -		kfree(bits);
> +		kvfree(bits);
>  out_nofds:
>  	return ret;

It otherwise looks OK to me.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

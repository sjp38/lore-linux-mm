Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lb0-f197.google.com (mail-lb0-f197.google.com [209.85.217.197])
	by kanga.kvack.org (Postfix) with ESMTP id 057B16B007E
	for <linux-mm@kvack.org>; Wed, 18 May 2016 04:45:46 -0400 (EDT)
Received: by mail-lb0-f197.google.com with SMTP id zv4so1859951lbb.3
        for <linux-mm@kvack.org>; Wed, 18 May 2016 01:45:45 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id p141si31929182wmb.69.2016.05.18.01.45.43
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 18 May 2016 01:45:43 -0700 (PDT)
Subject: Re: why the kmalloc return fail when there is free physical address
 but return success after dropping page caches
References: <D64A3952-53D8-4B9D-98A1-C99D7E231D42@gmail.com>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <573C2BB6.6070801@suse.cz>
Date: Wed, 18 May 2016 10:45:42 +0200
MIME-Version: 1.0
In-Reply-To: <D64A3952-53D8-4B9D-98A1-C99D7E231D42@gmail.com>
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: baotiao <baotiao@gmail.com>
Cc: linux-mm@kvack.org, Dave Chinner <david@fromorbit.com>

[+CC Dave]

On 05/18/2016 04:38 AM, baotiao wrote:
> Hello every, I meet an interesting kernel memory problem. Can anyone
> help me explain what happen under the kernel

Which kernel version is that?

> The machine's status is describe as blow:
>
> the machine has 96 physical memory. And the real use memory is about
> 64G, and the page cache use about 32G. we also use the swap area, at
> that time we have about 10G(we set the swap max size to 32G). At that
> moment, we find xfs report
>
> |Apr 29 21:54:31 w-openstack86 kernel: XFS: possible memory allocation
> deadlock in kmem_alloc (mode:0x250) |

Just once, or many times?

> after reading the source code. This message is display from this line
>
> |ptr = kmalloc(size, lflags); if (ptr || (flags &
> (KM_MAYFAIL|KM_NOSLEEP))) return ptr; if (!(++retries % 100))
> xfs_err(NULL, "possible memory allocation deadlock in %s (mode:0x%x)",
> __func__, lflags); congestion_wait(BLK_RW_ASYNC, HZ/50); |

Any indication what is the size used here?

> The error is cause by the kmalloc() function, there is not enough memory
> in the system. But there is still 32G page cache.
>
> So I run
>
> |echo 3 > /proc/sys/vm/drop_caches |
>
> to drop the page cache.
>
> Then the system is fine.

Are you saying that the error message was repeated infinitely until you 
did the drop_caches?

> But I really don't know the reason. Why after I
> run drop_caches operation the kmalloc() function will success? I think
> even we use whole physical memory, but we only use 64 real momory, the
> 32G memory are page cache, further we have enough swap space. So why the
> kernel don't flush the page cache or the swap to reserved the kmalloc
> operation.
>
>
> ----------------------------------------
> Github: https://github.com/baotiao
> Blog: http://baotiao.github.io/
> Stackoverflow: http://stackoverflow.com/users/634415/baotiao
> Linkedin: http://www.linkedin.com/profile/view?id=145231990
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

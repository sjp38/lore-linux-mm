Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ob0-f171.google.com (mail-ob0-f171.google.com [209.85.214.171])
	by kanga.kvack.org (Postfix) with ESMTP id 9B314828E2
	for <linux-mm@kvack.org>; Thu, 18 Feb 2016 05:23:43 -0500 (EST)
Received: by mail-ob0-f171.google.com with SMTP id jq7so59392560obb.0
        for <linux-mm@kvack.org>; Thu, 18 Feb 2016 02:23:43 -0800 (PST)
Received: from szxga01-in.huawei.com (szxga01-in.huawei.com. [58.251.152.64])
        by mx.google.com with ESMTPS id qe9si8429338obc.23.2016.02.18.02.23.41
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 18 Feb 2016 02:23:43 -0800 (PST)
Message-ID: <56C59B39.30102@huawei.com>
Date: Thu, 18 Feb 2016 18:21:45 +0800
From: Xishi Qiu <qiuxishi@huawei.com>
MIME-Version: 1.0
Subject: Re: [PATCH] mm: add MM_SWAPENTS and page table when calculate tasksize
 in lowmem_scan()
References: <56C2EDC1.2090509@huawei.com> <20160216173849.GA10487@kroah.com> <alpine.DEB.2.10.1602161629560.19997@chino.kir.corp.google.com> <CAF7GXvqr2dmc7CUcs_OmfYnEA9jE_Db4kGGG1HJyYYLhC6Bgew@mail.gmail.com>
In-Reply-To: <CAF7GXvqr2dmc7CUcs_OmfYnEA9jE_Db4kGGG1HJyYYLhC6Bgew@mail.gmail.com>
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Figo.zhang" <figo1802@gmail.com>, David Rientjes <rientjes@google.com>
Cc: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, arve@android.com, riandrews@android.com, devel@driverdev.osuosl.org, zhong jiang <zhongjiang@huawei.com>, LKML <linux-kernel@vger.kernel.org>, Linux MM <linux-mm@kvack.org>

On 2016/2/18 15:55, Figo.zhang wrote:

> 
> 
> 2016-02-17 8:35 GMT+08:00 David Rientjes <rientjes@google.com <mailto:rientjes@google.com>>:
> 
>     On Tue, 16 Feb 2016, Greg Kroah-Hartman wrote:
> 
>     > On Tue, Feb 16, 2016 at 05:37:05PM +0800, Xishi Qiu wrote:
>     > > Currently tasksize in lowmem_scan() only calculate rss, and not include swap.
>     > > But usually smart phones enable zram, so swap space actually use ram.
>     >
>     > Yes, but does that matter for this type of calculation?  I need an ack
>     > from the android team before I could ever take such a core change to
>     > this code...
>     >
> 
>     The calculation proposed in this patch is the same as the generic oom
>     killer, it's an estimate of the amount of memory that will be freed if it
>     is killed and can exit.  This is better than simply get_mm_rss().
> 
>     However, I think we seriously need to re-consider the implementation of
>     the lowmem killer entirely.  It currently abuses the use of TIF_MEMDIE,
>     which should ideally only be set for one thread on the system since it
>     allows unbounded access to global memory reserves.
> 
> 
> 
> i don't understand why it need wait 1 second:
> 

Hi David,

How about kill more processes at one time?

Usually loading camera will alloc 300-500M memory immediately, so call lmk
repeatedly is a waste of time.

And can we reclaim memory at one time instead of reclaim-alloc-reclaim-alloc...
in this situation? e.g. use try_to_free_pages(), set nr_to_reclaim=300M

Thanks,
Xishi Qiu

> if (test_tsk_thread_flag(p, TIF_MEMDIE) &&
>    time_before_eq(jiffies, lowmem_deathpending_timeout)) {
> task_unlock(p);
> rcu_read_unlock();
> return 0;                             <= why return rather than continue?
> }
> 
> and it will retry and wait many CPU times if one task holding the TIF_MEMDI.
>    shrink_slab_node()   
>        while()
>            shrinker->scan_objects();
>                      lowmem_scan()
>                                  if (test_tsk_thread_flag(p, TIF_MEMDIE) &&
>                                        time_before_eq(jiffies, lowmem_deathpending_timeout)) 
> 
>  
> 
> 


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

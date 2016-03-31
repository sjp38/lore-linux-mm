Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f176.google.com (mail-pf0-f176.google.com [209.85.192.176])
	by kanga.kvack.org (Postfix) with ESMTP id 1F2676B007E
	for <linux-mm@kvack.org>; Thu, 31 Mar 2016 17:47:00 -0400 (EDT)
Received: by mail-pf0-f176.google.com with SMTP id 4so78356830pfd.0
        for <linux-mm@kvack.org>; Thu, 31 Mar 2016 14:47:00 -0700 (PDT)
Received: from mail-pa0-x22e.google.com (mail-pa0-x22e.google.com. [2607:f8b0:400e:c03::22e])
        by mx.google.com with ESMTPS id f86si16534408pfd.122.2016.03.31.14.46.58
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 31 Mar 2016 14:46:59 -0700 (PDT)
Received: by mail-pa0-x22e.google.com with SMTP id td3so74392716pab.2
        for <linux-mm@kvack.org>; Thu, 31 Mar 2016 14:46:58 -0700 (PDT)
Date: Thu, 31 Mar 2016 14:46:45 -0700
From: Yu Zhao <yuzhao@google.com>
Subject: Re: [PATCH] zsmalloc: use workqueue to destroy pool in zpool callback
Message-ID: <20160331214645.GA31294@google.com>
References: <1459288977-25562-1-git-send-email-yuzhao@google.com>
 <20160329235950.GA19927@bbox>
 <20160331084639.GB3343@swordfish>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20160331084639.GB3343@swordfish>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>
Cc: Minchan Kim <minchan@kernel.org>, Nitin Gupta <ngupta@vflare.org>, linux-mm@kvack.org, Dan Streetman <ddstreet@ieee.org>, Seth Jennings <sjenning@redhat.com>, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org

On Thu, Mar 31, 2016 at 05:46:39PM +0900, Sergey Senozhatsky wrote:
> On (03/30/16 08:59), Minchan Kim wrote:
> > On Tue, Mar 29, 2016 at 03:02:57PM -0700, Yu Zhao wrote:
> > > zs_destroy_pool() might sleep so it shouldn't be used in zpool
> > > destroy callback which can be invoked in softirq context when
> > > zsmalloc is configured to work with zswap.
> > 
> > I think it's a limitation of zswap design, not zsmalloc.
> > Could you handle it in zswap?
> 
> agree. hm, looking at this backtrace
> 
> >   [<ffffffffaea0224b>] mutex_lock+0x1b/0x2f
> >   [<ffffffffaebca4f0>] kmem_cache_destroy+0x50/0x130
> >   [<ffffffffaec10405>] zs_destroy_pool+0x85/0xe0
> >   [<ffffffffaec1046e>] zs_zpool_destroy+0xe/0x10
> >   [<ffffffffaec101a4>] zpool_destroy_pool+0x54/0x70
> >   [<ffffffffaebedac2>] __zswap_pool_release+0x62/0x90
> >   [<ffffffffaeb1037e>] rcu_process_callbacks+0x22e/0x640
> >   [<ffffffffaeb15a3e>] ? run_timer_softirq+0x3e/0x280
> >   [<ffffffffaeabe13b>] __do_softirq+0xcb/0x250
> >   [<ffffffffaeabe4dc>] irq_exit+0x9c/0xb0
> >   [<ffffffffaea03e7a>] smp_apic_timer_interrupt+0x6a/0x80
> >   [<ffffffffaf0a394f>] apic_timer_interrupt+0x7f/0x90
> 
> it also can hit the following path
> 
> 	rcu_process_callbacks()
> 		__zswap_pool_release()
> 			zswap_pool_destroy()
> 				zswap_cpu_comp_destroy()
> 					cpu_notifier_register_begin()
> 						mutex_lock(&cpu_add_remove_lock);  <<<
> 
> can't it?
> 
> 	-ss

Thanks, Sergey. Now I'm convinced the problem should be fixed in
zswap. Since the rcu callback is already executed asynchronously,
using workqueue to defer the callback further more doesn't seem
to cause additional race condition at least.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

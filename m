Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f173.google.com (mail-pf0-f173.google.com [209.85.192.173])
	by kanga.kvack.org (Postfix) with ESMTP id 6CEB16B007E
	for <linux-mm@kvack.org>; Thu, 31 Mar 2016 04:45:17 -0400 (EDT)
Received: by mail-pf0-f173.google.com with SMTP id x3so64612562pfb.1
        for <linux-mm@kvack.org>; Thu, 31 Mar 2016 01:45:17 -0700 (PDT)
Received: from mail-pf0-x22c.google.com (mail-pf0-x22c.google.com. [2607:f8b0:400e:c00::22c])
        by mx.google.com with ESMTPS id ao8si12658326pad.241.2016.03.31.01.45.16
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 31 Mar 2016 01:45:16 -0700 (PDT)
Received: by mail-pf0-x22c.google.com with SMTP id n5so64607257pfn.2
        for <linux-mm@kvack.org>; Thu, 31 Mar 2016 01:45:16 -0700 (PDT)
Date: Thu, 31 Mar 2016 17:46:39 +0900
From: Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>
Subject: Re: [PATCH] zsmalloc: use workqueue to destroy pool in zpool callback
Message-ID: <20160331084639.GB3343@swordfish>
References: <1459288977-25562-1-git-send-email-yuzhao@google.com>
 <20160329235950.GA19927@bbox>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20160329235950.GA19927@bbox>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Yu Zhao <yuzhao@google.com>
Cc: Minchan Kim <minchan@kernel.org>, Nitin Gupta <ngupta@vflare.org>, Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>, linux-mm@kvack.org, Dan Streetman <ddstreet@ieee.org>, Seth Jennings <sjenning@redhat.com>, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org

On (03/30/16 08:59), Minchan Kim wrote:
> On Tue, Mar 29, 2016 at 03:02:57PM -0700, Yu Zhao wrote:
> > zs_destroy_pool() might sleep so it shouldn't be used in zpool
> > destroy callback which can be invoked in softirq context when
> > zsmalloc is configured to work with zswap.
> 
> I think it's a limitation of zswap design, not zsmalloc.
> Could you handle it in zswap?

agree. hm, looking at this backtrace

>   [<ffffffffaea0224b>] mutex_lock+0x1b/0x2f
>   [<ffffffffaebca4f0>] kmem_cache_destroy+0x50/0x130
>   [<ffffffffaec10405>] zs_destroy_pool+0x85/0xe0
>   [<ffffffffaec1046e>] zs_zpool_destroy+0xe/0x10
>   [<ffffffffaec101a4>] zpool_destroy_pool+0x54/0x70
>   [<ffffffffaebedac2>] __zswap_pool_release+0x62/0x90
>   [<ffffffffaeb1037e>] rcu_process_callbacks+0x22e/0x640
>   [<ffffffffaeb15a3e>] ? run_timer_softirq+0x3e/0x280
>   [<ffffffffaeabe13b>] __do_softirq+0xcb/0x250
>   [<ffffffffaeabe4dc>] irq_exit+0x9c/0xb0
>   [<ffffffffaea03e7a>] smp_apic_timer_interrupt+0x6a/0x80
>   [<ffffffffaf0a394f>] apic_timer_interrupt+0x7f/0x90

it also can hit the following path

	rcu_process_callbacks()
		__zswap_pool_release()
			zswap_pool_destroy()
				zswap_cpu_comp_destroy()
					cpu_notifier_register_begin()
						mutex_lock(&cpu_add_remove_lock);  <<<

can't it?

	-ss

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

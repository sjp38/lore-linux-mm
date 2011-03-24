Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id A2F2D8D0040
	for <linux-mm@kvack.org>; Thu, 24 Mar 2011 12:03:24 -0400 (EDT)
Date: Thu, 24 Mar 2011 17:03:10 +0100
From: Ingo Molnar <mingo@elte.hu>
Subject: Re: [GIT PULL] SLAB changes for v2.6.39-rc1
Message-ID: <20110324160310.GA27127@elte.hu>
References: <alpine.DEB.2.00.1103221635400.4521@tiger>
 <20110324142146.GA11682@elte.hu>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20110324142146.GA11682@elte.hu>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Pekka Enberg <penberg@kernel.org>
Cc: torvalds@linux-foundation.org, cl@linux-foundation.org, akpm@linux-foundation.org, tj@kernel.org, npiggin@kernel.dk, rientjes@google.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org


* Ingo Molnar <mingo@elte.hu> wrote:

> FYI, some sort of boot crash has snuck upstream in the last 24 hours:
> 
>  BUG: unable to handle kernel paging request at ffff87ffc147e020                               
>  IP: [<ffffffff811aa762>] this_cpu_cmpxchg16b_emu+0x2/0x1c           
> 
>      [<ffffffff810d9cbc>] ? kmem_cache_alloc+0x4c/0x110                                           
>      [<ffffffff8151cf06>] kmem_cache_init+0xeb/0x2b0                                              
>      [<ffffffff81504a06>] start_kernel+0x1de/0x49b                                                
>      [<ffffffff8150432b>] x86_64_start_reservations+0x132/0x136                                   
>      [<ffffffff81504140>] ? early_idt_handlers+0x140/0x140         
> 
> And the SLAB changes are one of the suspects. It triggers in about 5% of all 
> randconfigs. I'm bisecting it currently.

Caused by:

| 8a5ec0ba42c4919e2d8f4c3138cc8b987fdb0b79 is the first bad commit
| commit 8a5ec0ba42c4919e2d8f4c3138cc8b987fdb0b79
| Author: Christoph Lameter <cl@linux.com>
| Date:   Fri Feb 25 11:38:54 2011 -0600
|
|    Lockless (and preemptless) fastpaths for slub

I'll try to revert these:

 2fd66c517d5e: slub: Add missing irq restore for the OOM path
 a24c5a0ea902: slub: Dont define useless label in the !CONFIG_CMPXCHG_LOCAL case
 8a5ec0ba42c4: Lockless (and preemptless) fastpaths for slub

Thanks,

	Ingo

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

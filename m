Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pb0-f43.google.com (mail-pb0-f43.google.com [209.85.160.43])
	by kanga.kvack.org (Postfix) with ESMTP id 515A76B0039
	for <linux-mm@kvack.org>; Wed,  9 Oct 2013 13:08:46 -0400 (EDT)
Received: by mail-pb0-f43.google.com with SMTP id md4so1186514pbc.2
        for <linux-mm@kvack.org>; Wed, 09 Oct 2013 10:08:45 -0700 (PDT)
Date: Wed, 9 Oct 2013 19:08:37 +0200
From: Peter Zijlstra <peterz@infradead.org>
Subject: Re: [PATCH 0/63] Basic scheduler support for automatic NUMA
 balancing V9
Message-ID: <20131009170837.GF13848@laptop.programming.kicks-ass.net>
References: <1381141781-10992-1-git-send-email-mgorman@suse.de>
 <20131009162801.GA10452@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20131009162801.GA10452@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ingo Molnar <mingo@kernel.org>
Cc: Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, Srikar Dronamraju <srikar@linux.vnet.ibm.com>, Andrea Arcangeli <aarcange@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On Wed, Oct 09, 2013 at 06:28:01PM +0200, Ingo Molnar wrote:
> 
> Hm, so I'm seeing boot crashes with the config attached:
> 
>  INIT: version 2.86 booting 
>  BUG: unable to handle kernel BUG: unable to handle kernel paging 
>  requestpaging request at eaf10f40 
>   at eaf10f40 
>  IP:IP: [<b103e0ef>] task_work_run+0x52/0x87 
>   [<b103e0ef>] task_work_run+0x52/0x87 
>  *pde = 3fbf9067 *pde = 3fbf9067 *pte = 3af10060 *pte = 3af10060  
>  
>  Oops: 0000 [#1] Oops: 0000 [#1] DEBUG_PAGEALLOCDEBUG_PAGEALLOC 
>  
>  CPU: 0 PID: 171 Comm: hostname Tainted: G        W    
>  3.12.0-rc4-01668-gfd71a04-dirty #229484 
>  CPU: 0 PID: 171 Comm: hostname Tainted: G        W    
>  3.12.0-rc4-01668-gfd71a04-dirty #229484 
>  task: eaf157a0 ti: eacf2000 task.ti: eacf2000 
> 
> Note that the config does not have NUMA_BALANCING enabled. With another 
> config I also had a failed bootup due to the OOM killer kicking in. That 
> didn't have NUMA_BALANCING enabled either.
> 
> Yet this all started today, after merging the NUMA patches.
> 
> Any ideas?

> CONFIG_MGEODE_LX=y

It looks like -march=geode generates similar borkage to the
-march=winchip2 like we found earlier today.

Must be randconfig luck to only hit it now.

Very easy to see if you build kernel/task_work.s, the bitops jc label
path fails to initialize the return value.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

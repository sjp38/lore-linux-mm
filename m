Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f51.google.com (mail-pa0-f51.google.com [209.85.220.51])
	by kanga.kvack.org (Postfix) with ESMTP id 152BA6B0036
	for <linux-mm@kvack.org>; Thu, 21 Nov 2013 17:58:19 -0500 (EST)
Received: by mail-pa0-f51.google.com with SMTP id fa1so424530pad.38
        for <linux-mm@kvack.org>; Thu, 21 Nov 2013 14:58:18 -0800 (PST)
Received: from mga02.intel.com (mga02.intel.com. [134.134.136.20])
        by mx.google.com with ESMTP id bl1si2262995pad.103.2013.11.21.14.58.16
        for <linux-mm@kvack.org>;
        Thu, 21 Nov 2013 14:58:17 -0800 (PST)
Message-ID: <528E8FCE.1000707@intel.com>
Date: Thu, 21 Nov 2013 14:57:18 -0800
From: Dave Hansen <dave.hansen@intel.com>
MIME-Version: 1.0
Subject: NUMA? bisected performance regression 3.11->3.12
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>, Linus Torvalds <torvalds@linux-foundation.org>
Cc: Linux-MM <linux-mm@kvack.org>, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, Kevin Hilman <khilman@linaro.org>, Andrea Arcangeli <aarcange@redhat.com>, Paul Bolle <paul.bollee@gmail.com>, Zlatko Calusic <zcalusic@bitsync.net>, Andrew Morton <akpm@linux-foundation.org>, Tim Chen <tim.c.chen@linux.intel.com>, Andi Kleen <ak@linux.intel.com>

Hey Johannes,

I'm running an open/close microbenchmark from the will-it-scale set:
> https://github.com/antonblanchard/will-it-scale/blob/master/tests/open1.c

I was seeing some weird symptoms on 3.12 vs 3.11.  The throughput in
that test was going from down from 50 million to 35 million.

The profiles show an increase in cpu time in _raw_spin_lock_irq.  The
profiles pointed to slub code that hasn't been touched in quite a while.
 I bisected it down to:

81c0a2bb515fd4daae8cab64352877480792b515 is the first bad commit
commit 81c0a2bb515fd4daae8cab64352877480792b515
Author: Johannes Weiner <hannes@cmpxchg.org>
Date:   Wed Sep 11 14:20:47 2013 -0700

Which also seems a bit weird, but I've tested with this and its
preceding commit enough times to be fairly sure that I did it right.

__slab_free() and free_one_page() both seem to be spending more time
spinning on their respective spinlocks, even though the throughput went
down and we should have been doing fewer actual allocations/frees.  The
best explanation for this would be if CPUs are tending to go after and
contending for remote cachelines more often once this patch is applied.

Any ideas?

It's a 8-socket/160-thread (one NUMA node per socket) system that is not
under memory pressure during the test.  The latencies are also such that
vm.zone_reclaim_mode=0.

Raw perf profiles and .config are in here:
http://www.sr71.net/~dave/intel/201311-wisregress0/

Here's a chunk of the 'perf diff':
>     17.65%   +3.47%  [kernel.kallsyms]  [k] _raw_spin_lock_irqsave           
>     13.80%   -0.31%  [kernel.kallsyms]  [k] _raw_spin_lock                   
>      7.21%   -0.51%  [unknown]          [.] 0x00007f7849058640               
>      3.43%   +0.15%  [kernel.kallsyms]  [k] setup_object                     
>      2.99%   -0.31%  [kernel.kallsyms]  [k] file_free_rcu                    
>      2.71%   -0.13%  [kernel.kallsyms]  [k] rcu_process_callbacks            
>      2.26%   -0.09%  [kernel.kallsyms]  [k] get_empty_filp                   
>      2.06%   -0.09%  [kernel.kallsyms]  [k] kmem_cache_alloc                 
>      1.65%   -0.08%  [kernel.kallsyms]  [k] link_path_walk                   
>      1.53%   -0.08%  [kernel.kallsyms]  [k] memset                           
>      1.46%   -0.09%  [kernel.kallsyms]  [k] do_dentry_open                   
>      1.44%   -0.04%  [kernel.kallsyms]  [k] __d_lookup_rcu                   
>      1.27%   -0.04%  [kernel.kallsyms]  [k] do_last                          
>      1.18%   -0.04%  [kernel.kallsyms]  [k] ext4_release_file                
>      1.16%   -0.04%  [kernel.kallsyms]  [k] __call_rcu.constprop.11          

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

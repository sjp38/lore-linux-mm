Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f175.google.com (mail-wi0-f175.google.com [209.85.212.175])
	by kanga.kvack.org (Postfix) with ESMTP id 4A9036B012B
	for <linux-mm@kvack.org>; Wed, 20 May 2015 11:29:41 -0400 (EDT)
Received: by wicmx19 with SMTP id mx19so159268889wic.0
        for <linux-mm@kvack.org>; Wed, 20 May 2015 08:29:40 -0700 (PDT)
Received: from gum.cmpxchg.org (gum.cmpxchg.org. [85.214.110.215])
        by mx.google.com with ESMTPS id kb7si29969275wjc.13.2015.05.20.08.29.38
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 20 May 2015 08:29:39 -0700 (PDT)
Date: Wed, 20 May 2015 11:29:23 -0400
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [PATCH 1/2] mm, memcg: Try charging a page before setting page
 up to date
Message-ID: <20150520152923.GA2874@cmpxchg.org>
References: <1432126245-10908-1-git-send-email-mgorman@suse.de>
 <1432126245-10908-2-git-send-email-mgorman@suse.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1432126245-10908-2-git-send-email-mgorman@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: Michal Hocko <mhocko@suse.cz>, Andrew Morton <akpm@linux-foundation.org>, Tejun Heo <tj@kernel.org>, Linux-CGroups <cgroups@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On Wed, May 20, 2015 at 01:50:44PM +0100, Mel Gorman wrote:
> Historically memcg overhead was high even if memcg was unused. This has
> improved a lot but it still showed up in a profile summary as being a
> problem.
> 
> /usr/src/linux-4.0-vanilla/mm/memcontrol.c                           6.6441   395842
>   mem_cgroup_try_charge                                                        2.950%   175781
>   __mem_cgroup_count_vm_event                                                  1.431%    85239
>   mem_cgroup_page_lruvec                                                       0.456%    27156
>   mem_cgroup_commit_charge                                                     0.392%    23342
>   uncharge_list                                                                0.323%    19256
>   mem_cgroup_update_lru_size                                                   0.278%    16538
>   memcg_check_events                                                           0.216%    12858
>   mem_cgroup_charge_statistics.isra.22                                         0.188%    11172
>   try_charge                                                                   0.150%     8928
>   commit_charge                                                                0.141%     8388
>   get_mem_cgroup_from_mm                                                       0.121%     7184
> 
> That is showing that 6.64% of system CPU cycles were in memcontrol.c and
> dominated by mem_cgroup_try_charge. The annotation shows that the bulk of
> the cost was checking PageSwapCache which is expected to be cache hot but is
> very expensive. The problem appears to be that __SetPageUptodate is called
> just before the check which is a write barrier. It is required to make sure
> struct page and page data is written before the PTE is updated and the data
> visible to userspace. memcg charging does not require or need the barrier
> but gets unfairly hit with the cost so this patch attempts the charging
> before the barrier.  Aside from the accidental cost to memcg there is the
> added benefit that the barrier is avoided if the page cannot be charged.
> When applied the relevant profile summary is as follows.
> 
> /usr/src/linux-4.0-chargefirst-v2r1/mm/memcontrol.c                  3.7907   223277
>   __mem_cgroup_count_vm_event                                                  1.143%    67312

Out of curiosity, I'm still consistently reading this function at
around 0.7%.  Are you profiling this single-threadedly or for the
entire run?  For profiling 80 single-threaded iterations, I get:

+    1.31%     0.59%              pft  [kernel.kallsyms]            [k] mem_cgroup_try_charge
+    0.72%     0.44%              pft  [kernel.kallsyms]            [k] mem_cgroup_commit_charge
+    0.67%     0.67%              pft  [kernel.kallsyms]            [k] __mem_cgroup_count_vm_event
+    0.57%     0.57%              pft  [kernel.kallsyms]            [k] get_mem_cgroup_from_mm
+    0.32%     0.01%              pft  [kernel.kallsyms]            [k] mem_cgroup_uncharge_list
+    0.42%     0.42%              pft  [kernel.kallsyms]            [k] mem_cgroup_page_lruvec
+    0.31%     0.30%              pft  [kernel.kallsyms]            [k] uncharge_list
+    0.28%     0.28%              pft  [kernel.kallsyms]            [k] try_charge
+    0.21%     0.21%              pft  [kernel.kallsyms]            [k] mem_cgroup_charge_statistics.isra.26
+    0.20%     0.20%              pft  [kernel.kallsyms]            [k] mem_cgroup_update_lru_size
+    0.13%     0.13%              pft  [kernel.kallsyms]            [k] commit_charge
+    0.10%     0.09%              pft  [kernel.kallsyms]            [k] memcg_check_events

Adding up the recursive profile (first column) for the entry functions
(try_charge, commit, pgfault accounting, uncharge), this yields 3.02%.

>   mem_cgroup_page_lruvec                                                       0.465%    27403
>   mem_cgroup_commit_charge                                                     0.381%    22452
>   uncharge_list                                                                0.332%    19543
>   mem_cgroup_update_lru_size                                                   0.284%    16704
>   get_mem_cgroup_from_mm                                                       0.271%    15952
>   mem_cgroup_try_charge                                                        0.237%    13982
>   memcg_check_events                                                           0.222%    13058
>   mem_cgroup_charge_statistics.isra.22                                         0.185%    10920
>   commit_charge                                                                0.140%     8235
>   try_charge                                                                   0.131%     7716
> 
> That brings the overhead down to 3.79% and leaves the memcg fault accounting
> to the root cgroup but it's an improvement. The difference in headline
> performance of the page fault microbench is marginal as memcg is such a
> small component of it.
> 
> pft faults
>                                        4.0.0                  4.0.0
>                                      vanilla            chargefirst
> Hmean    faults/cpu-1 1443258.1051 (  0.00%) 1509075.7561 (  4.56%)
> Hmean    faults/cpu-3 1340385.9270 (  0.00%) 1339160.7113 ( -0.09%)
> Hmean    faults/cpu-5  875599.0222 (  0.00%)  874174.1255 ( -0.16%)
> Hmean    faults/cpu-7  601146.6726 (  0.00%)  601370.9977 (  0.04%)
> Hmean    faults/cpu-8  510728.2754 (  0.00%)  510598.8214 ( -0.03%)
> Hmean    faults/sec-1 1432084.7845 (  0.00%) 1497935.5274 (  4.60%)
> Hmean    faults/sec-3 3943818.1437 (  0.00%) 3941920.1520 ( -0.05%)
> Hmean    faults/sec-5 3877573.5867 (  0.00%) 3869385.7553 ( -0.21%)
> Hmean    faults/sec-7 3991832.0418 (  0.00%) 3992181.4189 (  0.01%)
> Hmean    faults/sec-8 3987189.8167 (  0.00%) 3986452.2204 ( -0.02%)
> 
> It's only visible at single threaded. The overhead is there for higher
> threads but other factors dominate.
> 
> Signed-off-by: Mel Gorman <mgorman@suse.de>

Awesome analysis, thank you Mel.

Acked-by: Johannes Weiner <hannes@cmpxchg.org>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

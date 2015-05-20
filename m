Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f41.google.com (mail-wg0-f41.google.com [74.125.82.41])
	by kanga.kvack.org (Postfix) with ESMTP id D8D636B0131
	for <linux-mm@kvack.org>; Wed, 20 May 2015 12:24:36 -0400 (EDT)
Received: by wgbgq6 with SMTP id gq6so58537550wgb.3
        for <linux-mm@kvack.org>; Wed, 20 May 2015 09:24:36 -0700 (PDT)
Received: from gum.cmpxchg.org (gum.cmpxchg.org. [85.214.110.215])
        by mx.google.com with ESMTPS id ey9si4672922wid.37.2015.05.20.09.24.34
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 20 May 2015 09:24:34 -0700 (PDT)
Date: Wed, 20 May 2015 12:24:21 -0400
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [PATCH 2/2] mm, memcg: Optionally disable memcg by default using
 Kconfig
Message-ID: <20150520162421.GB2874@cmpxchg.org>
References: <1432126245-10908-1-git-send-email-mgorman@suse.de>
 <1432126245-10908-3-git-send-email-mgorman@suse.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1432126245-10908-3-git-send-email-mgorman@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: Michal Hocko <mhocko@suse.cz>, Andrew Morton <akpm@linux-foundation.org>, Tejun Heo <tj@kernel.org>, Linux-CGroups <cgroups@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On Wed, May 20, 2015 at 01:50:45PM +0100, Mel Gorman wrote:
> memcg was reported years ago to have significant overhead when unused. It
> has improved but it's still the case that users that have no knowledge of
> memcg pay a small performance penalty.
>
> This patch adds a Kconfig that controls whether memcg is enabled by default
> and a kernel parameter cgroup_enable= to enable it if desired. Anyone using
> oldconfig will get the historical behaviour. It is not an option for most
> distributions to simply disable MEMCG as there are users that require it
> but they should also be knowledgable enough to use cgroup_enable=.
>
> This was evaluated using aim9, a page fault microbenchmark and ebizzy
> but I'll focus on the page fault microbenchmark. It can be reproduced
> using pft from mmtests (https://github.com/gormanm/mmtests).  Edit
> configs/config-global-dhp__pagealloc-performance and update MMTESTS to
> only contain pft. This is the relevant part of the profile summary
> 
> /usr/src/linux-4.0-chargefirst-v2r1/mm/memcontrol.c                  3.7907   223277
>   __mem_cgroup_count_vm_event                                                  1.143%    67312
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
> It's showing 3.79% overhead in memcontrol.c when no memcgs are in
> use. Applying the patch and disabling memcg reduces this to 0.51%
> 
> /usr/src/linux-4.0-disable-v2r1/mm/memcontrol.c                      0.5100    29304
>   mem_cgroup_page_lruvec                                                       0.161%     9267
>   mem_cgroup_update_lru_size                                                   0.154%     8872
>   mem_cgroup_try_charge                                                        0.153%     8768
>   mem_cgroup_commit_charge                                                     0.042%     2397
> 
> pft faults
>                                        4.0.0                  4.0.0
>                                  chargefirst                disable
> Hmean    faults/cpu-1 1509075.7561 (  0.00%) 1508934.4568 ( -0.01%)
> Hmean    faults/cpu-3 1339160.7113 (  0.00%) 1379512.0698 (  3.01%)
> Hmean    faults/cpu-5  874174.1255 (  0.00%)  875741.7674 (  0.18%)
> Hmean    faults/cpu-7  601370.9977 (  0.00%)  599938.2026 ( -0.24%)
> Hmean    faults/cpu-8  510598.8214 (  0.00%)  510663.5402 (  0.01%)
> Hmean    faults/sec-1 1497935.5274 (  0.00%) 1496585.7400 ( -0.09%)
> Hmean    faults/sec-3 3941920.1520 (  0.00%) 4050811.9259 (  2.76%)
> Hmean    faults/sec-5 3869385.7553 (  0.00%) 3922299.6112 (  1.37%)
> Hmean    faults/sec-7 3992181.4189 (  0.00%) 3988511.0065 ( -0.09%)
> Hmean    faults/sec-8 3986452.2204 (  0.00%) 3977706.7883 ( -0.22%)
> 
> Low thread counts get a small boost but it's within noise as memcg overhead
> does not dominate. It's not obvious at all at higher thread counts as other
> factors cause more problems. The overall breakdown of CPU usage looks like
> 
>                4.0.0       4.0.0
>         chargefirst-v2r1disable-v2r1
> User           41.81       41.45
> System        407.64      405.50
> Elapsed       128.17      127.06

This is a worst case microbenchmark doing nothing but anonymous page
faults (with THP disabled), and yet the performance difference is in
the noise.  I don't see why we should burden the user with making a
decision that doesn't matter in theory, let alone in practice.

We have CONFIG_MEMCG and cgroup_disable=memory, that should be plenty
for users that obsess about fluctuation in the noise.  There is no
reason to complicate the world further for everybody else.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

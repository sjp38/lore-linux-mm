Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ee0-f52.google.com (mail-ee0-f52.google.com [74.125.83.52])
	by kanga.kvack.org (Postfix) with ESMTP id A1F626B0035
	for <linux-mm@kvack.org>; Wed, 30 Apr 2014 16:25:54 -0400 (EDT)
Received: by mail-ee0-f52.google.com with SMTP id e53so1696409eek.25
        for <linux-mm@kvack.org>; Wed, 30 Apr 2014 13:25:54 -0700 (PDT)
Received: from zene.cmpxchg.org (zene.cmpxchg.org. [2a01:238:4224:fa00:ca1f:9ef3:caee:a2bd])
        by mx.google.com with ESMTPS id x44si32028712eep.150.2014.04.30.13.25.52
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Wed, 30 Apr 2014 13:25:53 -0700 (PDT)
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: [patch 0/9] mm: memcontrol: naturalize charge lifetime
Date: Wed, 30 Apr 2014 16:25:34 -0400
Message-Id: <1398889543-23671-1-git-send-email-hannes@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: Michal Hocko <mhocko@suse.cz>, Hugh Dickins <hughd@google.com>, Tejun Heo <tj@kernel.org>, cgroups@vger.kernel.org, linux-kernel@vger.kernel.org

Hi,

these patches rework memcg charge lifetime to integrate more naturally
with the lifetime of user pages.  This drastically simplifies the code
and reduces charging and uncharging overhead.  The most expensive part
of charging and uncharging is the page_cgroup bit spinlock, which is
removed entirely after this series.

Here are the top-10 profile entries of a stress test that reads a 128G
sparse file on a freshly booted box, without a dedicated cgroup
(i.e. executing in the root memcg).  Before:

    15.36%              cat  [kernel.kallsyms]   [k] copy_user_generic_string                  
    13.31%              cat  [kernel.kallsyms]   [k] memset                                    
    11.48%              cat  [kernel.kallsyms]   [k] do_mpage_readpage                         
     4.23%              cat  [kernel.kallsyms]   [k] get_page_from_freelist                    
     2.38%              cat  [kernel.kallsyms]   [k] put_page                                  
     2.32%              cat  [kernel.kallsyms]   [k] __mem_cgroup_commit_charge                
     2.18%          kswapd0  [kernel.kallsyms]   [k] __mem_cgroup_uncharge_common              
     1.92%          kswapd0  [kernel.kallsyms]   [k] shrink_page_list                          
     1.86%              cat  [kernel.kallsyms]   [k] __radix_tree_lookup                       
     1.62%              cat  [kernel.kallsyms]   [k] __pagevec_lru_add_fn                      

And after:

    15.67%           cat  [kernel.kallsyms]   [k] copy_user_generic_string                  
    13.48%           cat  [kernel.kallsyms]   [k] memset                                    
    11.42%           cat  [kernel.kallsyms]   [k] do_mpage_readpage                         
     3.98%           cat  [kernel.kallsyms]   [k] get_page_from_freelist                    
     2.46%           cat  [kernel.kallsyms]   [k] put_page                                  
     2.13%       kswapd0  [kernel.kallsyms]   [k] shrink_page_list                          
     1.88%           cat  [kernel.kallsyms]   [k] __radix_tree_lookup                       
     1.67%           cat  [kernel.kallsyms]   [k] __pagevec_lru_add_fn                      
     1.39%       kswapd0  [kernel.kallsyms]   [k] free_pcppages_bulk                        
     1.30%           cat  [kernel.kallsyms]   [k] kfree                                     

The code also survived some prolonged stress testing with a swapping
workload being moved continuously between memcgs.

My apologies in advance for the reviewability.  I tried to split out
the rewrite into more steps, but had to declare the current code as
unsalvagaeble after it took me more than a day to convince myself how
the swap accounting works.  It's probably easiest to read this as
newly written code.

 Documentation/cgroups/memcg_test.txt |  160 +--
 include/linux/memcontrol.h           |   94 +-
 include/linux/page_cgroup.h          |   43 +-
 include/linux/swap.h                 |   15 +-
 kernel/events/uprobes.c              |    1 +
 mm/filemap.c                         |   13 +-
 mm/huge_memory.c                     |   51 +-
 mm/memcontrol.c                      | 1724 ++++++++++++--------------------
 mm/memory.c                          |   41 +-
 mm/migrate.c                         |   46 +-
 mm/rmap.c                            |    6 -
 mm/shmem.c                           |   28 +-
 mm/swap.c                            |   22 +
 mm/swap_state.c                      |    8 +-
 mm/swapfile.c                        |   21 +-
 mm/truncate.c                        |    1 -
 mm/vmscan.c                          |    9 +-
 mm/zswap.c                           |    2 +-
 18 files changed, 833 insertions(+), 1452 deletions(-)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

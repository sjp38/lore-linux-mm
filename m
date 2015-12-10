Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f48.google.com (mail-wm0-f48.google.com [74.125.82.48])
	by kanga.kvack.org (Postfix) with ESMTP id 114DC6B0258
	for <linux-mm@kvack.org>; Thu, 10 Dec 2015 10:16:37 -0500 (EST)
Received: by mail-wm0-f48.google.com with SMTP id c201so38029374wme.0
        for <linux-mm@kvack.org>; Thu, 10 Dec 2015 07:16:37 -0800 (PST)
Received: from gum.cmpxchg.org (gum.cmpxchg.org. [85.214.110.215])
        by mx.google.com with ESMTPS id r7si20151553wmg.47.2015.12.10.07.16.35
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 10 Dec 2015 07:16:35 -0800 (PST)
Date: Thu, 10 Dec 2015 10:16:27 -0500
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [PATCH 7/8] mm: memcontrol: account "kmem" consumers in cgroup2
 memory controller
Message-ID: <20151210151627.GB1431@cmpxchg.org>
References: <1449599665-18047-1-git-send-email-hannes@cmpxchg.org>
 <1449599665-18047-8-git-send-email-hannes@cmpxchg.org>
 <20151209113037.GS11488@esperanza>
 <20151210132833.GM19496@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20151210132833.GM19496@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Vladimir Davydov <vdavydov@virtuozzo.com>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, cgroups@vger.kernel.org, linux-kernel@vger.kernel.org, kernel-team@fb.com

On Thu, Dec 10, 2015 at 02:28:33PM +0100, Michal Hocko wrote:
> On Wed 09-12-15 14:30:38, Vladimir Davydov wrote:
> > From: Vladimir Davydov <vdavydov@virtuozzo.com>
> > Subject: [PATCH] mm: memcontrol: allow to disable kmem accounting for cgroup2
> > 
> > Kmem accounting might incur overhead that some users can't put up with.
> > Besides, the implementation is still considered unstable. So let's
> > provide a way to disable it for those users who aren't happy with it.
> 
> Yes there will be users who do not want to pay an additional overhead
> and still accoplish what they need.
> I haven't measured the overhead lately - especially after the opt-out ->
> opt-in change so it might be much lower than my previous ~5% for kbuild
> load.

I think switching from accounting *all* slab allocations to accounting
a list of, what, less than 20 select slabs, counts as a change
significant enough to entirely invalidate those measurements and never
bring up that number again in the context of kmem cost, don't you think?

There isn't that much that the kmem is doing, but for posterity I ran
kbuild test inside a cgroup2, with and without cgroup.memory=nokmem,
and these are the results:

default:
 Performance counter stats for 'make -j16 -s clean bzImage' (3 runs):

     715823.047005      task-clock (msec)         #    3.794 CPUs utilized          
           252,538      context-switches          #    0.353 K/sec                  
            32,018      cpu-migrations            #    0.045 K/sec                  
        16,678,202      page-faults               #    0.023 M/sec                  
 1,783,804,914,980      cycles                    #    2.492 GHz                    
   <not supported>      stalled-cycles-frontend  
   <not supported>      stalled-cycles-backend   
 1,346,424,021,728      instructions              #    0.75  insns per cycle        
   298,744,956,474      branches                  #  417.363 M/sec                  
    10,207,872,737      branch-misses             #    3.42% of all branches        

     188.667608149 seconds time elapsed                                          ( +-  0.66% )

cgroup.memory=nokmem
 Performance counter stats for 'make -j16 -s clean bzImage' (3 runs):

     729028.322760      task-clock (msec)         #    3.805 CPUs utilized          
           258,775      context-switches          #    0.356 K/sec                  
            32,241      cpu-migrations            #    0.044 K/sec                  
        16,647,817      page-faults               #    0.023 M/sec                  
 1,816,827,061,194      cycles                    #    2.497 GHz                    
   <not supported>      stalled-cycles-frontend  
   <not supported>      stalled-cycles-backend   
 1,345,446,962,095      instructions              #    0.74  insns per cycle        
   298,461,034,326      branches                  #  410.277 M/sec                  
    10,215,145,963      branch-misses             #    3.42% of all branches        

     191.583957742 seconds time elapsed                                          ( +-  0.57% )

I would say the difference is solidly in the noise.

I also profiled a silly find | xargs stat pipe to excercise the dentry
and inode accounting, and this was the highest kmem-specific entry:

     0.27%     0.27%  find             [kernel.kallsyms]        [k] __memcg_kmem_get_cache                    
                       |
                       ---__memcg_kmem_get_cache
                          __kmalloc
                          ext4_htree_store_dirent
                          htree_dirblock_to_tree
                          ext4_htree_fill_tree
                          ext4_readdir
                          iterate_dir
                          sys_getdents
                          entry_SYSCALL_64_fastpath
                          __getdents64

So can we *please* lay this whole "unreasonable burden to legacy and
power users" line of argument to rest and get on with our work? And
then tackle scalability problems as they show up in real workloads?

Thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

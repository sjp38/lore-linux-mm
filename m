Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f72.google.com (mail-ed1-f72.google.com [209.85.208.72])
	by kanga.kvack.org (Postfix) with ESMTP id E8B768E0072
	for <linux-mm@kvack.org>; Tue, 25 Sep 2018 08:31:00 -0400 (EDT)
Received: by mail-ed1-f72.google.com with SMTP id c25-v6so10608480edb.12
        for <linux-mm@kvack.org>; Tue, 25 Sep 2018 05:31:00 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id e3-v6si4076483edi.191.2018.09.25.05.30.59
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 25 Sep 2018 05:30:59 -0700 (PDT)
Date: Tue, 25 Sep 2018 14:30:56 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH 1/2] mm: thp:  relax __GFP_THISNODE for MADV_HUGEPAGE
 mappings
Message-ID: <20180925123056.GV18685@dhcp22.suse.cz>
References: <20180925120326.24392-1-mhocko@kernel.org>
 <20180925120326.24392-2-mhocko@kernel.org>
 <20180925122008.GJ1750@suse.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180925122008.GJ1750@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: Andrew Morton <akpm@linux-foundation.org>, Vlastimil Babka <vbabka@suse.cz>, David Rientjes <rientjes@google.com>, Andrea Argangeli <andrea@kernel.org>, Zi Yan <zi.yan@cs.rutgers.edu>, Stefan Priebe - Profihost AG <s.priebe@profihost.ag>, "Kirill A. Shutemov" <kirill@shutemov.name>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>, Andrea Arcangeli <aarcange@redhat.com>, Stable tree <stable@vger.kernel.org>

On Tue 25-09-18 13:20:08, Mel Gorman wrote:
> On Tue, Sep 25, 2018 at 02:03:25PM +0200, Michal Hocko wrote:
> > From: Andrea Arcangeli <aarcange@redhat.com>
> > 
> > THP allocation might be really disruptive when allocated on NUMA system
> > with the local node full or hard to reclaim. Stefan has posted an
> > allocation stall report on 4.12 based SLES kernel which suggests the
> > same issue:
> > 
> > [245513.362669] kvm: page allocation stalls for 194572ms, order:9, mode:0x4740ca(__GFP_HIGHMEM|__GFP_IO|__GFP_FS|__GFP_COMP|__GFP_NOMEMALLOC|__GFP_HARDWALL|__GFP_THISNODE|__GFP_MOVABLE|__GFP_DIRECT_RECLAIM), nodemask=(null)
> > [245513.363983] kvm cpuset=/ mems_allowed=0-1
> > [245513.364604] CPU: 10 PID: 84752 Comm: kvm Tainted: G        W 4.12.0+98-ph <a href="/view.php?id=1" title="[geschlossen] Integration Ramdisk" class="resolved">0000001</a> SLE15 (unreleased)
> > [245513.365258] Hardware name: Supermicro SYS-1029P-WTRT/X11DDW-NT, BIOS 2.0 12/05/2017
> > [245513.365905] Call Trace:
> > [245513.366535]  dump_stack+0x5c/0x84
> > [245513.367148]  warn_alloc+0xe0/0x180
> > [245513.367769]  __alloc_pages_slowpath+0x820/0xc90
> > [245513.368406]  ? __slab_free+0xa9/0x2f0
> > [245513.369048]  ? __slab_free+0xa9/0x2f0
> > [245513.369671]  __alloc_pages_nodemask+0x1cc/0x210
> > [245513.370300]  alloc_pages_vma+0x1e5/0x280
> > [245513.370921]  do_huge_pmd_wp_page+0x83f/0xf00
> > [245513.371554]  ? set_huge_zero_page.isra.52.part.53+0x9b/0xb0
> > [245513.372184]  ? do_huge_pmd_anonymous_page+0x631/0x6d0
> > [245513.372812]  __handle_mm_fault+0x93d/0x1060
> > [245513.373439]  handle_mm_fault+0xc6/0x1b0
> > [245513.374042]  __do_page_fault+0x230/0x430
> > [245513.374679]  ? get_vtime_delta+0x13/0xb0
> > [245513.375411]  do_page_fault+0x2a/0x70
> > [245513.376145]  ? page_fault+0x65/0x80
> > [245513.376882]  page_fault+0x7b/0x80
> > [...]
> > [245513.382056] Mem-Info:
> > [245513.382634] active_anon:126315487 inactive_anon:1612476 isolated_anon:5
> >                  active_file:60183 inactive_file:245285 isolated_file:0
> >                  unevictable:15657 dirty:286 writeback:1 unstable:0
> >                  slab_reclaimable:75543 slab_unreclaimable:2509111
> >                  mapped:81814 shmem:31764 pagetables:370616 bounce:0
> >                  free:32294031 free_pcp:6233 free_cma:0
> > [245513.386615] Node 0 active_anon:254680388kB inactive_anon:1112760kB active_file:240648kB inactive_file:981168kB unevictable:13368kB isolated(anon):0kB isolated(file):0kB mapped:280240kB dirty:1144kB writeback:0kB shmem:95832kB shmem_thp: 0kB shmem_pmdmapped: 0kB anon_thp: 81225728kB writeback_tmp:0kB unstable:0kB all_unreclaimable? no
> > [245513.388650] Node 1 active_anon:250583072kB inactive_anon:5337144kB active_file:84kB inactive_file:0kB unevictable:49260kB isolated(anon):20kB isolated(file):0kB mapped:47016kB dirty:0kB writeback:4kB shmem:31224kB shmem_thp: 0kB shmem_pmdmapped: 0kB anon_thp: 31897600kB writeback_tmp:0kB unstable:0kB all_unreclaimable? no
> > 
> > The defrag mode is "madvise" and from the above report it is clear that
> > the THP has been allocated for MADV_HUGEPAGA vma.
> > 
> > Andrea has identified that the main source of the problem is
> > __GFP_THISNODE usage:
> > 
> > : The problem is that direct compaction combined with the NUMA
> > : __GFP_THISNODE logic in mempolicy.c is telling reclaim to swap very
> > : hard the local node, instead of failing the allocation if there's no
> > : THP available in the local node.
> > :
> > : Such logic was ok until __GFP_THISNODE was added to the THP allocation
> > : path even with MPOL_DEFAULT.
> > :
> > : The idea behind the __GFP_THISNODE addition, is that it is better to
> > : provide local memory in PAGE_SIZE units than to use remote NUMA THP
> > : backed memory. That largely depends on the remote latency though, on
> > : threadrippers for example the overhead is relatively low in my
> > : experience.
> > :
> > : The combination of __GFP_THISNODE and __GFP_DIRECT_RECLAIM results in
> > : extremely slow qemu startup with vfio, if the VM is larger than the
> > : size of one host NUMA node. This is because it will try very hard to
> > : unsuccessfully swapout get_user_pages pinned pages as result of the
> > : __GFP_THISNODE being set, instead of falling back to PAGE_SIZE
> > : allocations and instead of trying to allocate THP on other nodes (it
> > : would be even worse without vfio type1 GUP pins of course, except it'd
> > : be swapping heavily instead).
> > 
> > Fix this by removing __GFP_THISNODE for THP requests which are
> > requesting the direct reclaim. This effectivelly reverts 5265047ac301 on
> > the grounds that the zone/node reclaim was known to be disruptive due
> > to premature reclaim when there was memory free. While it made sense at
> > the time for HPC workloads without NUMA awareness on rare machines, it
> > was ultimately harmful in the majority of cases. The existing behaviour
> > is similiar, if not as widespare as it applies to a corner case but
> > crucially, it cannot be tuned around like zone_reclaim_mode can. The
> > default behaviour should always be to cause the least harm for the
> > common case.
> > 
> > If there are specialised use cases out there that want zone_reclaim_mode
> > in specific cases, then it can be built on top. Longterm we should
> > consider a memory policy which allows for the node reclaim like behavior
> > for the specific memory ranges which would allow a
> > 
> > [1] http://lkml.kernel.org/r/20180820032204.9591-1-aarcange@redhat.com
> > 
> > [mhocko@suse.com: rewrote the changelog based on the one from Andrea]
> > Fixes: 5265047ac301 ("mm, thp: really limit transparent hugepage allocation to local node")
> > Cc: Zi Yan <zi.yan@cs.rutgers.edu>
> > Cc: stable # 4.1+
> > Reported-by: Stefan Priebe <s.priebe@profihost.ag>
> > Debugged-by: Andrea Arcangeli <aarcange@redhat.com>
> > Reported-by: Alex Williamson <alex.williamson@redhat.com>
> > Signed-off-by: Andrea Arcangeli <aarcange@redhat.com>
> > Signed-off-by: Michal Hocko <mhocko@suse.com>
> 
> Reviewed-by: Mel Gorman <mgorman@techsingularity.net>
> 
> Both patches look correct to me but I'm responding to this one because
> it's the fix. The change makes sense and moves further away from the
> severe stalling behaviour we used to see with both THP and zone reclaim
> mode.
> 
> I put together a basic experiment with usemem configured to reference a
> buffer multiple times that is 80% the size of main memory on a 2-socket box
> with symmetric node sizes and defrag set to "always".  The defrag setting
> is not the default but it would be functionally similar to accessing a
> buffer with madvise(MADV_HUGEPAGE). Usemem is configured to reference
> the buffer multiple times and while it's not an interesting workload,
> it would be expected to complete reasonably quickly as it fits within
> memory. The results were;
> 
> usemem
>                                   vanilla           noreclaim-v1
> Amean     Elapsd-1       42.78 (   0.00%)       26.87 (  37.18%)
> Amean     Elapsd-3       27.55 (   0.00%)        7.44 (  73.00%)
> Amean     Elapsd-4        5.72 (   0.00%)        5.69 (   0.45%)
> 
> This shows the elapsed time in seconds for 1 thread, 3 threads and 4 threads
> referencing buffers 80% the size of memory. With the patches applied, it's
> 37.18% faster for the single thread and 73% faster with two threads. Note
> that 4 threads showing little difference does not indicate the problem is
> related to thread counts. It's simply the case that 4 threads gets spread
> so their workload mostly fits in one node.
> 
> The overall view from /proc/vmstats is more startling
> 
>                          4.19.0-rc1  4.19.0-rc1
>                             vanillanoreclaim-v1r1
> Minor Faults               35593425      708164
> Major Faults                 484088          36
> Swap Ins                    3772837           0
> Swap Outs                   3932295           0
> 
> Massive amounts of swap in/out without the patch
> 
> Direct pages scanned        6013214           0
> Kswapd pages scanned              0           0
> Kswapd pages reclaimed            0           0
> Direct pages reclaimed      4033009           0
> 
> Lots of reclaim activity without the patch
> 
> Kswapd efficiency              100%        100%
> Kswapd velocity               0.000       0.000
> Direct efficiency               67%        100%
> Direct velocity           11191.956       0.000
> 
> Mostly from direct reclaim context as you'd expect without the patch.
> 
> Page writes by reclaim  3932314.000       0.000
> Page writes file                 19           0
> Page writes anon            3932295           0
> Page reclaim immediate        42336           0
> 
> Writes from reclaim context is never good but the patch eliminates it.
> 
> We should never have default behaviour to thrash the system for such a
> basic workload. If zone reclaim mode behaviour is ever desired but on a
> single task instead of a global basis then the sensible option is to build
> a mempolicy that enforces that behaviour.

Thanks a lot for numbers Mel!
-- 
Michal Hocko
SUSE Labs

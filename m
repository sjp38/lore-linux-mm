Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f69.google.com (mail-wm0-f69.google.com [74.125.82.69])
	by kanga.kvack.org (Postfix) with ESMTP id 4368D8E0001
	for <linux-mm@kvack.org>; Sat,  8 Sep 2018 14:52:40 -0400 (EDT)
Received: by mail-wm0-f69.google.com with SMTP id f10-v6so11600622wmb.9
        for <linux-mm@kvack.org>; Sat, 08 Sep 2018 11:52:40 -0700 (PDT)
Received: from cloud1-vm154.de-nserver.de (cloud1-vm154.de-nserver.de. [178.250.10.56])
        by mx.google.com with ESMTPS id x17-v6si11798561wrm.46.2018.09.08.11.52.37
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Sat, 08 Sep 2018 11:52:37 -0700 (PDT)
Subject: Re: [PATCH] mm, thp: relax __GFP_THISNODE for MADV_HUGEPAGE mappings
References: <20180907130550.11885-1-mhocko@kernel.org>
From: Stefan Priebe - Profihost AG <s.priebe@profihost.ag>
Message-ID: <f7ed71c1-d599-5257-fd8f-041eb24d9f29@profihost.ag>
Date: Sat, 8 Sep 2018 20:52:35 +0200
MIME-Version: 1.0
In-Reply-To: <20180907130550.11885-1-mhocko@kernel.org>
Content-Type: text/plain; charset=utf-8
Content-Language: de-DE
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>, Andrew Morton <akpm@linux-foundation.org>
Cc: Andrea Arcangeli <aarcange@redhat.com>, David Rientjes <rientjes@google.com>, Zi Yan <zi.yan@cs.rutgers.edu>, "Kirill A. Shutemov" <kirill@shutemov.name>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>, Michal Hocko <mhocko@suse.com>

Hello,

whlie using this path i got another stall - which i never saw under
kernel 4.4. Here is the trace:
[305111.932698] INFO: task ksmtuned:1399 blocked for more than 120 seconds.
[305111.933612]       Tainted: G                   4.12.0+105-ph #1
[305111.934456] "echo 0 > /proc/sys/kernel/hung_task_timeout_secs"
disables this message.
[305111.935323] ksmtuned        D    0  1399      1 0x00080000
[305111.936207] Call Trace:
[305111.937118]  ? __schedule+0x3bc/0x830
[305111.937991]  schedule+0x32/0x80
[305111.938837]  schedule_preempt_disabled+0xa/0x10
[305111.939687]  __mutex_lock.isra.4+0x287/0x4c0
[305111.940550]  ? run_store+0x47/0x2b0
[305111.941416]  run_store+0x47/0x2b0
[305111.942284]  ? __kmalloc+0x157/0x1d0
[305111.943138]  kernfs_fop_write+0x102/0x180
[305111.943988]  __vfs_write+0x26/0x140
[305111.944827]  ? __alloc_fd+0x44/0x170
[305111.945669]  ? set_close_on_exec+0x30/0x60
[305111.946519]  vfs_write+0xb1/0x1e0
[305111.947359]  SyS_write+0x42/0x90
[305111.948193]  do_syscall_64+0x74/0x150
[305111.949014]  entry_SYSCALL_64_after_hwframe+0x3d/0xa2
[305111.949854] RIP: 0033:0x7fe7cde93730
[305111.950678] RSP: 002b:00007fffab0d5e88 EFLAGS: 00000246 ORIG_RAX:
0000000000000001
[305111.951525] RAX: ffffffffffffffda RBX: 0000000000000002 RCX:
00007fe7cde93730
[305111.952358] RDX: 0000000000000002 RSI: 00000000011b1c08 RDI:
0000000000000001
[305111.953170] RBP: 00000000011b1c08 R08: 00007fe7ce153760 R09:
00007fe7ce797b40
[305111.953979] R10: 0000000000000073 R11: 0000000000000246 R12:
0000000000000002
[305111.954790] R13: 0000000000000001 R14: 00007fe7ce152600 R15:
0000000000000002
[305146.987742] khugepaged: page allocation stalls for 224236ms,
order:9,
mode:0x4740ca(__GFP_HIGHMEM|__GFP_IO|__GFP_FS|__GFP_COMP|__GFP_NOMEMALLOC|__GFP_HARDWALL|__GFP_THISNODE|__GFP_MOVABLE|__GFP_DIRECT_RECLAIM),
nodemask=(null)
[305146.989652] khugepaged cpuset=/ mems_allowed=0-1
[305146.990582] CPU: 1 PID: 405 Comm: khugepaged Tainted: G
     4.12.0+105-ph #1 SLE15 (unreleased)
[305146.991536] Hardware name: Supermicro
X9DRW-3LN4F+/X9DRW-3TF+/X9DRW-3LN4F+/X9DRW-3TF+, BIOS 3.00 07/05/2013
[305146.992524] Call Trace:
[305146.993493]  dump_stack+0x5c/0x84
[305146.994499]  warn_alloc+0xe0/0x180
[305146.995469]  __alloc_pages_slowpath+0x820/0xc90
[305146.996456]  ? get_vtime_delta+0x13/0xb0
[305146.997424]  ? sched_clock+0x5/0x10
[305146.998394]  ? del_timer_sync+0x35/0x40
[305146.999370]  __alloc_pages_nodemask+0x1cc/0x210
[305147.000369]  khugepaged_alloc_page+0x39/0x70
[305147.001326]  khugepaged+0xc0c/0x20c0
[305147.002214]  ? remove_wait_queue+0x60/0x60
[305147.003226]  kthread+0xff/0x130
[305147.004219]  ? collapse_shmem+0xba0/0xba0
[305147.005131]  ? kthread_create_on_node+0x40/0x40
[305147.005971]  ret_from_fork+0x35/0x40
[305147.006835] Mem-Info:
[305147.007681] active_anon:51674768 inactive_anon:69112 isolated_anon:21
                 active_file:47818 inactive_file:51708 isolated_file:0
                 unevictable:15710 dirty:187 writeback:0 unstable:0
                 slab_reclaimable:62499 slab_unreclaimable:1284920
                 mapped:66765 shmem:47623 pagetables:185294 bounce:0
                 free:44265934 free_pcp:23646 free_cma:0
[305147.012664] Node 0 active_anon:116919912kB inactive_anon:238824kB
active_file:157296kB inactive_file:112820kB unevictable:58364kB
isolated(anon):80kB isolated(file):0kB mapped:221548kB dirty:548kB
writeback:0kB shmem:153196kB shmem_thp: 0kB shmem_pmdmapped: 0kB
anon_thp: 14430208kB writeback_tmp:0kB unstable:0kB all_unreclaimable? no
[305147.015437] Node 1 active_anon:89781496kB inactive_anon:37624kB
active_file:33976kB inactive_file:94012kB unevictable:4476kB
isolated(anon):4kB isolated(file):0kB mapped:45512kB dirty:200kB
writeback:0kB shmem:37296kB shmem_thp: 0kB shmem_pmdmapped: 0kB
anon_thp: 9279488kB writeback_tmp:0kB unstable:0kB all_unreclaimable? no
[305147.018550] Node 0 DMA free:15816kB min:12kB low:24kB high:36kB
active_anon:0kB inactive_anon:0kB active_file:0kB inactive_file:0kB
unevictable:0kB writepending:0kB present:15988kB managed:15816kB
mlocked:0kB slab_reclaimable:0kB slab_unreclaimable:0kB kernel_stack:0kB
pagetables:0kB bounce:0kB free_pcp:0kB local_pcp:0kB free_cma:0kB
[305147.022085] lowmem_reserve[]: 0 1922 193381 193381 193381
[305147.023208] Node 0 DMA32 free:769020kB min:1964kB low:3944kB
high:5924kB active_anon:1204144kB inactive_anon:0kB active_file:4kB
inactive_file:0kB unevictable:0kB writepending:0kB present:2046368kB
managed:1980800kB mlocked:0kB slab_reclaimable:32kB
slab_unreclaimable:5376kB kernel_stack:0kB pagetables:1560kB bounce:0kB
free_pcp:0kB local_pcp:0kB free_cma:0kB
[305147.026768] lowmem_reserve[]: 0 0 191458 191458 191458
[305147.028044] Node 0 Normal free:71769584kB min:194564kB low:390620kB
high:586676kB active_anon:115715084kB inactive_anon:238824kB
active_file:157292kB inactive_file:112820kB unevictable:58364kB
writepending:548kB present:199229440kB managed:196058772kB
mlocked:58364kB slab_reclaimable:146536kB slab_unreclaimable:2697676kB
kernel_stack:12488kB pagetables:669756kB bounce:0kB free_pcp:42284kB
local_pcp:284kB free_cma:0kB
[305147.033356] lowmem_reserve[]: 0 0 0 0 0
[305147.034754] Node 1 Normal free:104504180kB min:196664kB low:394836kB
high:593008kB active_anon:89783256kB inactive_anon:37624kB
active_file:33976kB inactive_file:94012kB unevictable:4476kB
writepending:200kB present:201326592kB managed:198175320kB
mlocked:4476kB slab_reclaimable:103428kB slab_unreclaimable:2436628kB
kernel_stack:14232kB pagetables:69860kB bounce:0kB free_pcp:51764kB
local_pcp:936kB free_cma:0kB
[305147.040667] lowmem_reserve[]: 0 0 0 0 0
[305147.042180] Node 0 DMA: 0*4kB 1*8kB (U) 0*16kB 0*32kB 1*64kB (U)
1*128kB (U) 1*256kB (U) 0*512kB 1*1024kB (U) 1*2048kB (M) 3*4096kB (M) =
15816kB
[305147.045054] Node 0 DMA32: 6363*4kB (UM) 3686*8kB (UM) 2106*16kB (UM)
1102*32kB (UME) 608*64kB (UME) 304*128kB (UME) 146*256kB (UME) 59*512kB
(UME) 32*1024kB (UME) 4*2048kB (UME) 112*4096kB (M) = 769020kB
[305147.048041] Node 0 Normal: 29891*4kB (UME) 367874*8kB (UME)
978139*16kB (UME) 481963*32kB (UME) 173612*64kB (UME) 65480*128kB (UME)
28019*256kB (UME) 10993*512kB (UME) 5217*1024kB (UM) 0*2048kB 0*4096kB =
71771692kB
[305147.051291] Node 1 Normal: 396333*4kB (UME) 257656*8kB (UME)
276637*16kB (UME) 190234*32kB (ME) 101344*64kB (ME) 39168*128kB (UME)
19207*256kB (UME) 8599*512kB (UME) 3065*1024kB (UM) 2*2048kB (UM)
16206*4096kB (M) = 104501892kB
[305147.054836] Node 0 hugepages_total=0 hugepages_free=0
hugepages_surp=0 hugepages_size=1048576kB
[305147.056555] Node 0 hugepages_total=0 hugepages_free=0
hugepages_surp=0 hugepages_size=2048kB
[305147.058160] Node 1 hugepages_total=0 hugepages_free=0
hugepages_surp=0 hugepages_size=1048576kB
[305147.059817] Node 1 hugepages_total=0 hugepages_free=0
hugepages_surp=0 hugepages_size=2048kB
[305147.061429] 149901 total pagecache pages
[305147.063124] 2 pages in swap cache
[305147.064908] Swap cache stats: add 7, delete 5, find 0/0
[305147.066676] Free swap  = 3905020kB
[305147.068268] Total swap = 3905532kB
[305147.069955] 100654597 pages RAM
[305147.071569] 0 pages HighMem/MovableOnly
[305147.073176] 1596920 pages reserved
[305147.074946] 0 pages hwpoisoned
[326258.236694] INFO: task ksmtuned:1399 blocked for more than 120 seconds.
[326258.237723]       Tainted: G                   4.12.0+105-ph #1
[326258.238718] "echo 0 > /proc/sys/kernel/hung_task_timeout_secs"
disables this message.
[326258.239679] ksmtuned        D    0  1399      1 0x00080000
[326258.240651] Call Trace:
[326258.241602]  ? __schedule+0x3bc/0x830
[326258.242557]  schedule+0x32/0x80
[326258.243462]  schedule_preempt_disabled+0xa/0x10
[326258.244336]  __mutex_lock.isra.4+0x287/0x4c0
[326258.245205]  ? run_store+0x47/0x2b0
[326258.246064]  run_store+0x47/0x2b0
[326258.246890]  ? __kmalloc+0x157/0x1d0
[326258.247716]  kernfs_fop_write+0x102/0x180
[326258.248514]  __vfs_write+0x26/0x140
[326258.249284]  ? __alloc_fd+0x44/0x170
[326258.250062]  ? set_close_on_exec+0x30/0x60
[326258.250812]  vfs_write+0xb1/0x1e0
[326258.251548]  SyS_write+0x42/0x90
[326258.252237]  do_syscall_64+0x74/0x150
[326258.252920]  entry_SYSCALL_64_after_hwframe+0x3d/0xa2
[326258.253577] RIP: 0033:0x7fe7cde93730
[326258.254263] RSP: 002b:00007fffab0d5e88 EFLAGS: 00000246 ORIG_RAX:
0000000000000001
[326258.254916] RAX: ffffffffffffffda RBX: 0000000000000002 RCX:
00007fe7cde93730
[326258.255564] RDX: 0000000000000002 RSI: 00000000011b1c08 RDI:
0000000000000001
[326258.256187] RBP: 00000000011b1c08 R08: 00007fe7ce153760 R09:
00007fe7ce797b40
[326258.256801] R10: 0000000000000073 R11: 0000000000000246 R12:
0000000000000002
[326258.257406] R13: 0000000000000001 R14: 00007fe7ce152600 R15:
0000000000000002

Greets,
Stefan
Am 07.09.2018 um 15:05 schrieb Michal Hocko:
> From: Michal Hocko <mhocko@suse.com>
> 
> Andrea has noticed [1] that a THP allocation might be really disruptive
> when allocated on NUMA system with the local node full or hard to
> reclaim. Stefan has posted an allocation stall report on 4.12 based
> SLES kernel which suggests the same issue:
> [245513.362669] kvm: page allocation stalls for 194572ms, order:9, mode:0x4740ca(__GFP_HIGHMEM|__GFP_IO|__GFP_FS|__GFP_COMP|__GFP_NOMEMALLOC|__GFP_HARDWALL|__GFP_THISNODE|__GFP_MOVABLE|__GFP_DIRECT_RECLAIM), nodemask=(null)
> [245513.363983] kvm cpuset=/ mems_allowed=0-1
> [245513.364604] CPU: 10 PID: 84752 Comm: kvm Tainted: G        W 4.12.0+98-ph <a href="/view.php?id=1" title="[geschlossen] Integration Ramdisk" class="resolved">0000001</a> SLE15 (unreleased)
> [245513.365258] Hardware name: Supermicro SYS-1029P-WTRT/X11DDW-NT, BIOS 2.0 12/05/2017
> [245513.365905] Call Trace:
> [245513.366535]  dump_stack+0x5c/0x84
> [245513.367148]  warn_alloc+0xe0/0x180
> [245513.367769]  __alloc_pages_slowpath+0x820/0xc90
> [245513.368406]  ? __slab_free+0xa9/0x2f0
> [245513.369048]  ? __slab_free+0xa9/0x2f0
> [245513.369671]  __alloc_pages_nodemask+0x1cc/0x210
> [245513.370300]  alloc_pages_vma+0x1e5/0x280
> [245513.370921]  do_huge_pmd_wp_page+0x83f/0xf00
> [245513.371554]  ? set_huge_zero_page.isra.52.part.53+0x9b/0xb0
> [245513.372184]  ? do_huge_pmd_anonymous_page+0x631/0x6d0
> [245513.372812]  __handle_mm_fault+0x93d/0x1060
> [245513.373439]  handle_mm_fault+0xc6/0x1b0
> [245513.374042]  __do_page_fault+0x230/0x430
> [245513.374679]  ? get_vtime_delta+0x13/0xb0
> [245513.375411]  do_page_fault+0x2a/0x70
> [245513.376145]  ? page_fault+0x65/0x80
> [245513.376882]  page_fault+0x7b/0x80
> [...]
> [245513.382056] Mem-Info:
> [245513.382634] active_anon:126315487 inactive_anon:1612476 isolated_anon:5
>                  active_file:60183 inactive_file:245285 isolated_file:0
>                  unevictable:15657 dirty:286 writeback:1 unstable:0
>                  slab_reclaimable:75543 slab_unreclaimable:2509111
>                  mapped:81814 shmem:31764 pagetables:370616 bounce:0
>                  free:32294031 free_pcp:6233 free_cma:0
> [245513.386615] Node 0 active_anon:254680388kB inactive_anon:1112760kB active_file:240648kB inactive_file:981168kB unevictable:13368kB isolated(anon):0kB isolated(file):0kB mapped:280240kB dirty:1144kB writeback:0kB shmem:95832kB shmem_thp: 0kB shmem_pmdmapped: 0kB anon_thp: 81225728kB writeback_tmp:0kB unstable:0kB all_unreclaimable? no
> [245513.388650] Node 1 active_anon:250583072kB inactive_anon:5337144kB active_file:84kB inactive_file:0kB unevictable:49260kB isolated(anon):20kB isolated(file):0kB mapped:47016kB dirty:0kB writeback:4kB shmem:31224kB shmem_thp: 0kB shmem_pmdmapped: 0kB anon_thp: 31897600kB writeback_tmp:0kB unstable:0kB all_unreclaimable? no
> 
> The defrag mode is "madvise" and from the above report it is clear that
> the THP has been allocated for MADV_HUGEPAGA vma.
> 
> Andrea has identified that the main source of the problem is
> __GFP_THISNODE usage:
> 
> : The problem is that direct compaction combined with the NUMA
> : __GFP_THISNODE logic in mempolicy.c is telling reclaim to swap very
> : hard the local node, instead of failing the allocation if there's no
> : THP available in the local node.
> :
> : Such logic was ok until __GFP_THISNODE was added to the THP allocation
> : path even with MPOL_DEFAULT.
> :
> : The idea behind the __GFP_THISNODE addition, is that it is better to
> : provide local memory in PAGE_SIZE units than to use remote NUMA THP
> : backed memory. That largely depends on the remote latency though, on
> : threadrippers for example the overhead is relatively low in my
> : experience.
> :
> : The combination of __GFP_THISNODE and __GFP_DIRECT_RECLAIM results in
> : extremely slow qemu startup with vfio, if the VM is larger than the
> : size of one host NUMA node. This is because it will try very hard to
> : unsuccessfully swapout get_user_pages pinned pages as result of the
> : __GFP_THISNODE being set, instead of falling back to PAGE_SIZE
> : allocations and instead of trying to allocate THP on other nodes (it
> : would be even worse without vfio type1 GUP pins of course, except it'd
> : be swapping heavily instead).
> 
> Fix this by removing __GFP_THISNODE handling from alloc_pages_vma where
> it doesn't belong and move it to alloc_hugepage_direct_gfpmask where we
> juggle gfp flags for different allocation modes. The rationale is that
> __GFP_THISNODE is helpful in relaxed defrag modes because falling back
> to a different node might be more harmful than the benefit of a large page.
> If the user really requires THP (e.g. by MADV_HUGEPAGE) then the THP has
> a higher priority than local NUMA placement.
> 
> Be careful when the vma has an explicit numa binding though, because
> __GFP_THISNODE is not playing well with it. We want to follow the
> explicit numa policy rather than enforce a node which happens to be
> local to the cpu we are running on.
> 
> [1] http://lkml.kernel.org/r/20180820032204.9591-1-aarcange@redhat.com
> 
> Fixes: 5265047ac301 ("mm, thp: really limit transparent hugepage allocation to local node")
> Reported-by: Stefan Priebe <s.priebe@profihost.ag>
> Debugged-by: Andrea Arcangeli <aarcange@redhat.com>
> Tested-by: Stefan Priebe <s.priebe@profihost.ag>
> Tested-by: Zi Yan <zi.yan@cs.rutgers.edu>
> Signed-off-by: Michal Hocko <mhocko@suse.com>
> ---
> 
> Hi,
> this is a follow up for [1]. Anrea has proposed two approaches to solve
> the regression. This is an alternative implementation of the second
> approach [2]. The reason for an alternative approach is that I strongly
> believe that all the subtle THP gfp manipulation should be at a single
> place (alloc_hugepage_direct_gfpmask) rather than spread in multiple
> places with additional fixup. There is one notable difference to [2]
> and that is defrag=allways behavior where I am preserving the original
> behavior. The reason for that is that defrag=always has always had
> tendency to stall and reclaim and we have addressed that by defining a
> new default defrag mode. We can discuss this behavior later but I
> believe the default mode and a regression noticed by multiple users
> should be closed regardless. Hence this patch.
> 
> [2] http://lkml.kernel.org/r/20180820032640.9896-2-aarcange@redhat.com
> 
>  include/linux/mempolicy.h |  2 ++
>  mm/huge_memory.c          | 26 ++++++++++++++++++--------
>  mm/mempolicy.c            | 28 +---------------------------
>  3 files changed, 21 insertions(+), 35 deletions(-)
> 
> diff --git a/include/linux/mempolicy.h b/include/linux/mempolicy.h
> index 5228c62af416..bac395f1d00a 100644
> --- a/include/linux/mempolicy.h
> +++ b/include/linux/mempolicy.h
> @@ -139,6 +139,8 @@ struct mempolicy *mpol_shared_policy_lookup(struct shared_policy *sp,
>  struct mempolicy *get_task_policy(struct task_struct *p);
>  struct mempolicy *__get_vma_policy(struct vm_area_struct *vma,
>  		unsigned long addr);
> +struct mempolicy *get_vma_policy(struct vm_area_struct *vma,
> +						unsigned long addr);
>  bool vma_policy_mof(struct vm_area_struct *vma);
>  
>  extern void numa_default_policy(void);
> diff --git a/mm/huge_memory.c b/mm/huge_memory.c
> index c3bc7e9c9a2a..56c9aac4dc86 100644
> --- a/mm/huge_memory.c
> +++ b/mm/huge_memory.c
> @@ -629,21 +629,31 @@ static vm_fault_t __do_huge_pmd_anonymous_page(struct vm_fault *vmf,
>   *	    available
>   * never: never stall for any thp allocation
>   */
> -static inline gfp_t alloc_hugepage_direct_gfpmask(struct vm_area_struct *vma)
> +static inline gfp_t alloc_hugepage_direct_gfpmask(struct vm_area_struct *vma, unsigned long addr)
>  {
>  	const bool vma_madvised = !!(vma->vm_flags & VM_HUGEPAGE);
> +	gfp_t this_node = 0;
> +	struct mempolicy *pol;
> +
> +#ifdef CONFIG_NUMA
> +	/* __GFP_THISNODE makes sense only if there is no explicit binding */
> +	pol = get_vma_policy(vma, addr);
> +	if (pol->mode != MPOL_BIND)
> +		this_node = __GFP_THISNODE;
> +	mpol_cond_put(pol);
> +#endif
>  
>  	if (test_bit(TRANSPARENT_HUGEPAGE_DEFRAG_DIRECT_FLAG, &transparent_hugepage_flags))
> -		return GFP_TRANSHUGE | (vma_madvised ? 0 : __GFP_NORETRY);
> +		return GFP_TRANSHUGE | (vma_madvised ? 0 : __GFP_NORETRY | this_node);
>  	if (test_bit(TRANSPARENT_HUGEPAGE_DEFRAG_KSWAPD_FLAG, &transparent_hugepage_flags))
> -		return GFP_TRANSHUGE_LIGHT | __GFP_KSWAPD_RECLAIM;
> +		return GFP_TRANSHUGE_LIGHT | __GFP_KSWAPD_RECLAIM | this_node;
>  	if (test_bit(TRANSPARENT_HUGEPAGE_DEFRAG_KSWAPD_OR_MADV_FLAG, &transparent_hugepage_flags))
>  		return GFP_TRANSHUGE_LIGHT | (vma_madvised ? __GFP_DIRECT_RECLAIM :
> -							     __GFP_KSWAPD_RECLAIM);
> +							     __GFP_KSWAPD_RECLAIM | this_node);
>  	if (test_bit(TRANSPARENT_HUGEPAGE_DEFRAG_REQ_MADV_FLAG, &transparent_hugepage_flags))
>  		return GFP_TRANSHUGE_LIGHT | (vma_madvised ? __GFP_DIRECT_RECLAIM :
> -							     0);
> -	return GFP_TRANSHUGE_LIGHT;
> +							     this_node);
> +	return GFP_TRANSHUGE_LIGHT | this_node;
>  }
>  
>  /* Caller must hold page table lock. */
> @@ -715,7 +725,7 @@ vm_fault_t do_huge_pmd_anonymous_page(struct vm_fault *vmf)
>  			pte_free(vma->vm_mm, pgtable);
>  		return ret;
>  	}
> -	gfp = alloc_hugepage_direct_gfpmask(vma);
> +	gfp = alloc_hugepage_direct_gfpmask(vma, haddr);
>  	page = alloc_hugepage_vma(gfp, vma, haddr, HPAGE_PMD_ORDER);
>  	if (unlikely(!page)) {
>  		count_vm_event(THP_FAULT_FALLBACK);
> @@ -1290,7 +1300,7 @@ vm_fault_t do_huge_pmd_wp_page(struct vm_fault *vmf, pmd_t orig_pmd)
>  alloc:
>  	if (transparent_hugepage_enabled(vma) &&
>  	    !transparent_hugepage_debug_cow()) {
> -		huge_gfp = alloc_hugepage_direct_gfpmask(vma);
> +		huge_gfp = alloc_hugepage_direct_gfpmask(vma, haddr);
>  		new_page = alloc_hugepage_vma(huge_gfp, vma, haddr, HPAGE_PMD_ORDER);
>  	} else
>  		new_page = NULL;
> diff --git a/mm/mempolicy.c b/mm/mempolicy.c
> index da858f794eb6..75bbfc3d6233 100644
> --- a/mm/mempolicy.c
> +++ b/mm/mempolicy.c
> @@ -1648,7 +1648,7 @@ struct mempolicy *__get_vma_policy(struct vm_area_struct *vma,
>   * freeing by another task.  It is the caller's responsibility to free the
>   * extra reference for shared policies.
>   */
> -static struct mempolicy *get_vma_policy(struct vm_area_struct *vma,
> +struct mempolicy *get_vma_policy(struct vm_area_struct *vma,
>  						unsigned long addr)
>  {
>  	struct mempolicy *pol = __get_vma_policy(vma, addr);
> @@ -2026,32 +2026,6 @@ alloc_pages_vma(gfp_t gfp, int order, struct vm_area_struct *vma,
>  		goto out;
>  	}
>  
> -	if (unlikely(IS_ENABLED(CONFIG_TRANSPARENT_HUGEPAGE) && hugepage)) {
> -		int hpage_node = node;
> -
> -		/*
> -		 * For hugepage allocation and non-interleave policy which
> -		 * allows the current node (or other explicitly preferred
> -		 * node) we only try to allocate from the current/preferred
> -		 * node and don't fall back to other nodes, as the cost of
> -		 * remote accesses would likely offset THP benefits.
> -		 *
> -		 * If the policy is interleave, or does not allow the current
> -		 * node in its nodemask, we allocate the standard way.
> -		 */
> -		if (pol->mode == MPOL_PREFERRED &&
> -						!(pol->flags & MPOL_F_LOCAL))
> -			hpage_node = pol->v.preferred_node;
> -
> -		nmask = policy_nodemask(gfp, pol);
> -		if (!nmask || node_isset(hpage_node, *nmask)) {
> -			mpol_cond_put(pol);
> -			page = __alloc_pages_node(hpage_node,
> -						gfp | __GFP_THISNODE, order);
> -			goto out;
> -		}
> -	}
> -
>  	nmask = policy_nodemask(gfp, pol);
>  	preferred_nid = policy_node(gfp, pol, node);
>  	page = __alloc_pages_nodemask(gfp, order, preferred_nid, nmask);
> 

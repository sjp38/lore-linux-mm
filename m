Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr1-f71.google.com (mail-wr1-f71.google.com [209.85.221.71])
	by kanga.kvack.org (Postfix) with ESMTP id 60EBC6B4B5E
	for <linux-mm@kvack.org>; Wed, 29 Aug 2018 07:11:18 -0400 (EDT)
Received: by mail-wr1-f71.google.com with SMTP id d10-v6so3241722wrw.6
        for <linux-mm@kvack.org>; Wed, 29 Aug 2018 04:11:18 -0700 (PDT)
Received: from cloud1-vm154.de-nserver.de (cloud1-vm154.de-nserver.de. [178.250.10.56])
        by mx.google.com with ESMTPS id 197-v6si3255201wmi.183.2018.08.29.04.11.15
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Wed, 29 Aug 2018 04:11:16 -0700 (PDT)
Subject: Re: [PATCH 2/2] mm: thp: fix transparent_hugepage/defrag = madvise ||
 always
From: Stefan Priebe - Profihost AG <s.priebe@profihost.ag>
References: <20180820032204.9591-1-aarcange@redhat.com>
 <20180820032204.9591-3-aarcange@redhat.com>
 <20180821115057.GY29735@dhcp22.suse.cz> <20180821214049.GG13047@redhat.com>
 <20180822090214.GF29735@dhcp22.suse.cz> <20180822155250.GP13047@redhat.com>
 <20180823105253.GB29735@dhcp22.suse.cz>
 <20180828075321.GD10223@dhcp22.suse.cz>
 <20180828081837.GG10223@dhcp22.suse.cz>
 <bd080399-cfc5-510e-4f4c-f2bac027ed97@profihost.ag>
Message-ID: <ff5778a4-b33e-77d0-be66-513716ef04eb@profihost.ag>
Date: Wed, 29 Aug 2018 13:11:15 +0200
MIME-Version: 1.0
In-Reply-To: <bd080399-cfc5-510e-4f4c-f2bac027ed97@profihost.ag>
Content-Type: text/plain; charset=utf-8
Content-Language: de-DE
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.com>, Andrea Arcangeli <aarcange@redhat.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, Alex Williamson <alex.williamson@redhat.com>, David Rientjes <rientjes@google.com>, Vlastimil Babka <vbabka@suse.cz>


Am 28.08.2018 um 10:54 schrieb Stefan Priebe - Profihost AG:
> 
> Am 28.08.2018 um 10:18 schrieb Michal Hocko:
>> [CC Stefan Priebe who has reported the same/similar issue on openSUSE
>>  mailing list recently - the thread starts http://lkml.kernel.org/r/20180820032204.9591-1-aarcange@redhat.com]
>>
>> On Tue 28-08-18 09:53:21, Michal Hocko wrote:
>>> On Thu 23-08-18 12:52:53, Michal Hocko wrote:
>>>> On Wed 22-08-18 11:52:50, Andrea Arcangeli wrote:
>>>>> On Wed, Aug 22, 2018 at 11:02:14AM +0200, Michal Hocko wrote:
>>>> [...]
>>>>>> I still have to digest the __GFP_THISNODE thing but I _think_ that the
>>>>>> alloc_pages_vma code is just trying to be overly clever and
>>>>>> __GFP_THISNODE is not a good fit for it. 
>>>>>
>>>>> My option 2 did just that, it removed __GFP_THISNODE but only for
>>>>> MADV_HUGEPAGE and in general whenever reclaim was activated by
>>>>> __GFP_DIRECT_RECLAIM. That is also signal that the user really wants
>>>>> THP so then it's less bad to prefer THP over NUMA locality.
>>>>>
>>>>> For the default which is tuned for short lived allocation, preferring
>>>>> local memory is most certainly better win for short lived allocation
>>>>> where THP can't help much, this is why I didn't remove __GFP_THISNODE
>>>>> from the default defrag policy.
>>>>
>>>> Yes I agree.
>>>
>>> I finally got back to this again. I have checked your patch and I am
>>> really wondering whether alloc_pages_vma is really the proper place to
>>> play these tricks. We already have that mind blowing alloc_hugepage_direct_gfpmask
>>> and it should be the proper place to handle this special casing. So what
>>> do you think about the following. It should be essentially the same
>>> thing. Aka use __GFP_THIS_NODE only when we are doing an optimistic THP
>>> allocation. Madvise signalizes you know what you are doing and THP has
>>> the top priority. If you care enough about the numa placement then you
>>> should better use mempolicy.
>>
>> Now the patch is still untested but it compiles at least.
> 
> Great - i recompiled the SLES15 kernel with that one applied and will
> test if it helps.

It seems to work fine. At least i was not able to reproduce the issue.

Greets,
Stefan

>> ---
>> From 88e0ca4c9c403c6046f1c47d5ee17548f9dc841a Mon Sep 17 00:00:00 2001
>> From: Michal Hocko <mhocko@suse.com>
>> Date: Tue, 28 Aug 2018 09:59:19 +0200
>> Subject: [PATCH] mm, thp: relax __GFP_THISNODE for MADV_HUGEPAGE mappings
>>
>> Andrea has noticed [1] that a THP allocation might be really disruptive
>> when allocated on NUMA system with the local node full or hard to
>> reclaim. Stefan has posted an allocation stall report on 4.12 based
>> SLES kernel which suggests the same issue:
>> [245513.362669] kvm: page allocation stalls for 194572ms, order:9, mode:0x4740ca(__GFP_HIGHMEM|__GFP_IO|__GFP_FS|__GFP_COMP|__GFP_NOMEMALLOC|__GFP_HARDWALL|__GFP_THISNODE|__GFP_MOVABLE|__GFP_DIRECT_RECLAIM), nodemask=(null)
>> [245513.363983] kvm cpuset=/ mems_allowed=0-1
>> [245513.364604] CPU: 10 PID: 84752 Comm: kvm Tainted: G        W 4.12.0+98-phSLE15 (unreleased)
>> [245513.365258] Hardware name: Supermicro SYS-1029P-WTRT/X11DDW-NT, BIOS 2.0 12/05/2017
>> [245513.365905] Call Trace:
>> [245513.366535]  dump_stack+0x5c/0x84
>> [245513.367148]  warn_alloc+0xe0/0x180
>> [245513.367769]  __alloc_pages_slowpath+0x820/0xc90
>> [245513.368406]  ? __slab_free+0xa9/0x2f0
>> [245513.369048]  ? __slab_free+0xa9/0x2f0
>> [245513.369671]  __alloc_pages_nodemask+0x1cc/0x210
>> [245513.370300]  alloc_pages_vma+0x1e5/0x280
>> [245513.370921]  do_huge_pmd_wp_page+0x83f/0xf00
>> [245513.371554]  ? set_huge_zero_page.isra.52.part.53+0x9b/0xb0
>> [245513.372184]  ? do_huge_pmd_anonymous_page+0x631/0x6d0
>> [245513.372812]  __handle_mm_fault+0x93d/0x1060
>> [245513.373439]  handle_mm_fault+0xc6/0x1b0
>> [245513.374042]  __do_page_fault+0x230/0x430
>> [245513.374679]  ? get_vtime_delta+0x13/0xb0
>> [245513.375411]  do_page_fault+0x2a/0x70
>> [245513.376145]  ? page_fault+0x65/0x80
>> [245513.376882]  page_fault+0x7b/0x80
>> [...]
>> [245513.382056] Mem-Info:
>> [245513.382634] active_anon:126315487 inactive_anon:1612476 isolated_anon:5
>>                  active_file:60183 inactive_file:245285 isolated_file:0
>>                  unevictable:15657 dirty:286 writeback:1 unstable:0
>>                  slab_reclaimable:75543 slab_unreclaimable:2509111
>>                  mapped:81814 shmem:31764 pagetables:370616 bounce:0
>>                  free:32294031 free_pcp:6233 free_cma:0
>> [245513.386615] Node 0 active_anon:254680388kB inactive_anon:1112760kB active_file:240648kB inactive_file:981168kB unevictable:13368kB isolated(anon):0kB isolated(file):0kB mapped:280240kB dirty:1144kB writeback:0kB shmem:95832kB shmem_thp: 0kB shmem_pmdmapped: 0kB anon_thp: 81225728kB writeback_tmp:0kB unstable:0kB all_unreclaimable? no
>> [245513.388650] Node 1 active_anon:250583072kB inactive_anon:5337144kB active_file:84kB inactive_file:0kB unevictable:49260kB isolated(anon):20kB isolated(file):0kB mapped:47016kB dirty:0kB writeback:4kB shmem:31224kB shmem_thp: 0kB shmem_pmdmapped: 0kB anon_thp: 31897600kB writeback_tmp:0kB unstable:0kB all_unreclaimable? no
>>
>> The defrag mode is "madvise" and from the above report it is clear that
>> the THP has been allocated for MADV_HUGEPAGA vma.
>>
>> Andrea has identified that the main source of the problem is
>> __GFP_THISNODE usage:
>>
>> : The problem is that direct compaction combined with the NUMA
>> : __GFP_THISNODE logic in mempolicy.c is telling reclaim to swap very
>> : hard the local node, instead of failing the allocation if there's no
>> : THP available in the local node.
>> :
>> : Such logic was ok until __GFP_THISNODE was added to the THP allocation
>> : path even with MPOL_DEFAULT.
>> :
>> : The idea behind the __GFP_THISNODE addition, is that it is better to
>> : provide local memory in PAGE_SIZE units than to use remote NUMA THP
>> : backed memory. That largely depends on the remote latency though, on
>> : threadrippers for example the overhead is relatively low in my
>> : experience.
>> :
>> : The combination of __GFP_THISNODE and __GFP_DIRECT_RECLAIM results in
>> : extremely slow qemu startup with vfio, if the VM is larger than the
>> : size of one host NUMA node. This is because it will try very hard to
>> : unsuccessfully swapout get_user_pages pinned pages as result of the
>> : __GFP_THISNODE being set, instead of falling back to PAGE_SIZE
>> : allocations and instead of trying to allocate THP on other nodes (it
>> : would be even worse without vfio type1 GUP pins of course, except it'd
>> : be swapping heavily instead).
>>
>> Fix this by removing __GFP_THISNODE handling from alloc_pages_vma where
>> it doesn't belong and move it to alloc_hugepage_direct_gfpmask where we
>> juggle gfp flags for different allocation modes. The rationale is that
>> __GFP_THISNODE is helpful in relaxed defrag modes because falling back
>> to a different node might be more harmful than the benefit of a large page.
>> If the user really requires THP (e.g. by MADV_HUGEPAGE) then the THP has
>> a higher priority than local NUMA placement. The later might be controlled
>> via NUMA policies to be more fine grained.
>>
>> [1] http://lkml.kernel.org/r/20180820032204.9591-1-aarcange@redhat.com
>>
>> Fixes: 5265047ac301 ("mm, thp: really limit transparent hugepage allocation to local node")
>> Reported-by: Stefan Priebe <s.priebe@profihost.ag>
>> Debugged-by: Andrea Arcangeli <aarcange@redhat.com>
>> Signed-off-by: Michal Hocko <mhocko@suse.com>
>> ---
>>  mm/huge_memory.c | 10 +++++-----
>>  mm/mempolicy.c   | 26 --------------------------
>>  2 files changed, 5 insertions(+), 31 deletions(-)
>>
>> diff --git a/mm/huge_memory.c b/mm/huge_memory.c
>> index c3bc7e9c9a2a..a703c23f8bab 100644
>> --- a/mm/huge_memory.c
>> +++ b/mm/huge_memory.c
>> @@ -634,16 +634,16 @@ static inline gfp_t alloc_hugepage_direct_gfpmask(struct vm_area_struct *vma)
>>  	const bool vma_madvised = !!(vma->vm_flags & VM_HUGEPAGE);
>>  
>>  	if (test_bit(TRANSPARENT_HUGEPAGE_DEFRAG_DIRECT_FLAG, &transparent_hugepage_flags))
>> -		return GFP_TRANSHUGE | (vma_madvised ? 0 : __GFP_NORETRY);
>> +		return GFP_TRANSHUGE | (vma_madvised ? 0 : __GFP_NORETRY | __GFP_THISNODE);
>>  	if (test_bit(TRANSPARENT_HUGEPAGE_DEFRAG_KSWAPD_FLAG, &transparent_hugepage_flags))
>> -		return GFP_TRANSHUGE_LIGHT | __GFP_KSWAPD_RECLAIM;
>> +		return GFP_TRANSHUGE_LIGHT | __GFP_KSWAPD_RECLAIM | __GFP_THISNODE;
>>  	if (test_bit(TRANSPARENT_HUGEPAGE_DEFRAG_KSWAPD_OR_MADV_FLAG, &transparent_hugepage_flags))
>>  		return GFP_TRANSHUGE_LIGHT | (vma_madvised ? __GFP_DIRECT_RECLAIM :
>> -							     __GFP_KSWAPD_RECLAIM);
>> +							     __GFP_KSWAPD_RECLAIM | __GFP_THISNODE);
>>  	if (test_bit(TRANSPARENT_HUGEPAGE_DEFRAG_REQ_MADV_FLAG, &transparent_hugepage_flags))
>>  		return GFP_TRANSHUGE_LIGHT | (vma_madvised ? __GFP_DIRECT_RECLAIM :
>> -							     0);
>> -	return GFP_TRANSHUGE_LIGHT;
>> +							     __GFP_THISNODE);
>> +	return GFP_TRANSHUGE_LIGHT | __GFP_THISNODE;
>>  }
>>  
>>  /* Caller must hold page table lock. */
>> diff --git a/mm/mempolicy.c b/mm/mempolicy.c
>> index da858f794eb6..9f0800885613 100644
>> --- a/mm/mempolicy.c
>> +++ b/mm/mempolicy.c
>> @@ -2026,32 +2026,6 @@ alloc_pages_vma(gfp_t gfp, int order, struct vm_area_struct *vma,
>>  		goto out;
>>  	}
>>  
>> -	if (unlikely(IS_ENABLED(CONFIG_TRANSPARENT_HUGEPAGE) && hugepage)) {
>> -		int hpage_node = node;
>> -
>> -		/*
>> -		 * For hugepage allocation and non-interleave policy which
>> -		 * allows the current node (or other explicitly preferred
>> -		 * node) we only try to allocate from the current/preferred
>> -		 * node and don't fall back to other nodes, as the cost of
>> -		 * remote accesses would likely offset THP benefits.
>> -		 *
>> -		 * If the policy is interleave, or does not allow the current
>> -		 * node in its nodemask, we allocate the standard way.
>> -		 */
>> -		if (pol->mode == MPOL_PREFERRED &&
>> -						!(pol->flags & MPOL_F_LOCAL))
>> -			hpage_node = pol->v.preferred_node;
>> -
>> -		nmask = policy_nodemask(gfp, pol);
>> -		if (!nmask || node_isset(hpage_node, *nmask)) {
>> -			mpol_cond_put(pol);
>> -			page = __alloc_pages_node(hpage_node,
>> -						gfp | __GFP_THISNODE, order);
>> -			goto out;
>> -		}
>> -	}
>> -
>>  	nmask = policy_nodemask(gfp, pol);
>>  	preferred_nid = policy_node(gfp, pol, node);
>>  	page = __alloc_pages_nodemask(gfp, order, preferred_nid, nmask);
>>

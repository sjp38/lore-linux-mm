Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr1-f72.google.com (mail-wr1-f72.google.com [209.85.221.72])
	by kanga.kvack.org (Postfix) with ESMTP id E6F2F8E0001
	for <linux-mm@kvack.org>; Mon, 10 Sep 2018 16:22:12 -0400 (EDT)
Received: by mail-wr1-f72.google.com with SMTP id z77-v6so20111031wrb.20
        for <linux-mm@kvack.org>; Mon, 10 Sep 2018 13:22:12 -0700 (PDT)
Received: from cloud1-vm154.de-nserver.de (cloud1-vm154.de-nserver.de. [178.250.10.56])
        by mx.google.com with ESMTPS id z8-v6si15794195wrv.127.2018.09.10.13.22.10
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Mon, 10 Sep 2018 13:22:11 -0700 (PDT)
Subject: Re: [PATCH] mm, thp: relax __GFP_THISNODE for MADV_HUGEPAGE mappings
References: <20180907130550.11885-1-mhocko@kernel.org>
 <alpine.DEB.2.21.1809101253080.177111@chino.kir.corp.google.com>
From: Stefan Priebe - Profihost AG <s.priebe@profihost.ag>
Message-ID: <d7389d81-f4df-f879-f646-3284189f3b7c@profihost.ag>
Date: Mon, 10 Sep 2018 22:22:08 +0200
MIME-Version: 1.0
In-Reply-To: <alpine.DEB.2.21.1809101253080.177111@chino.kir.corp.google.com>
Content-Type: text/plain; charset=utf-8
Content-Language: de-DE
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>, Michal Hocko <mhocko@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>, Zi Yan <zi.yan@cs.rutgers.edu>, "Kirill A. Shutemov" <kirill@shutemov.name>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>, Michal Hocko <mhocko@suse.com>

Am 10.09.2018 um 22:08 schrieb David Rientjes:
> On Fri, 7 Sep 2018, Michal Hocko wrote:
> 
>> From: Michal Hocko <mhocko@suse.com>
>>
>> Andrea has noticed [1] that a THP allocation might be really disruptive
>> when allocated on NUMA system with the local node full or hard to
>> reclaim. Stefan has posted an allocation stall report on 4.12 based
>> SLES kernel which suggests the same issue:
>> [245513.362669] kvm: page allocation stalls for 194572ms, order:9, mode:0x4740ca(__GFP_HIGHMEM|__GFP_IO|__GFP_FS|__GFP_COMP|__GFP_NOMEMALLOC|__GFP_HARDWALL|__GFP_THISNODE|__GFP_MOVABLE|__GFP_DIRECT_RECLAIM), nodemask=(null)
>> [245513.363983] kvm cpuset=/ mems_allowed=0-1
>> [245513.364604] CPU: 10 PID: 84752 Comm: kvm Tainted: G        W 4.12.0+98-ph <a href="/view.php?id=1" title="[geschlossen] Integration Ramdisk" class="resolved">0000001</a> SLE15 (unreleased)
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
> 
> Since we don't have __GFP_REPEAT, this suggests that 
> __alloc_pages_direct_compact() took >100s to complete.  The memory 
> capacity of the system isn't shown, but I assume it's around 768GB?  This 
> should be with COMPACT_PRIO_ASYNC, and MIGRATE_ASYNC compaction certainly 
> should abort much earlier.

Yes it's 768GB.

Greets,
Stefan

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
>> a higher priority than local NUMA placement.
>>
> 
> That's not entirely true, the remote access latency for remote thp on all 
> of our platforms is greater than local small pages, this is especially 
> true for remote thp that is allocated intersocket and must be accessed 
> through the interconnect.
> 
> Our users of MADV_HUGEPAGE are ok with assuming the burden of increased 
> allocation latency, but certainly not remote access latency.  There are 
> users who remap their text segment onto transparent hugepages are fine 
> with startup delay if they are access all of their text from local thp.  
> Remote thp would be a significant performance degradation.
> 
> When Andrea brought this up, I suggested that the full solution would be a 
> MPOL_F_HUGEPAGE flag that could define thp allocation policy -- the added 
> benefit is that we could replace the thp "defrag" mode default by setting 
> this as part of default_policy.  Right now, MADV_HUGEPAGE users are 
> concerned about (1) getting thp when system-wide it is not default and (2) 
> additional fault latency when direct compaction is not default.  They are 
> not anticipating the degradation of remote access latency, so overloading 
> the meaning of the mode is probably not a good idea.
> 

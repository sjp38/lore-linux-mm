Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id 66AFB6B0038
	for <linux-mm@kvack.org>; Tue, 28 Feb 2017 15:34:48 -0500 (EST)
Received: by mail-pf0-f199.google.com with SMTP id u62so25940043pfk.1
        for <linux-mm@kvack.org>; Tue, 28 Feb 2017 12:34:48 -0800 (PST)
Received: from mail-pg0-x242.google.com (mail-pg0-x242.google.com. [2607:f8b0:400e:c05::242])
        by mx.google.com with ESMTPS id c21si2684854pgi.128.2017.02.28.12.34.47
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 28 Feb 2017 12:34:47 -0800 (PST)
Received: by mail-pg0-x242.google.com with SMTP id x17so2866924pgi.0
        for <linux-mm@kvack.org>; Tue, 28 Feb 2017 12:34:47 -0800 (PST)
Subject: Re: [LSF/MM TOPIC] cpuset vs mempolicy related issues
References: <4c44a589-5fd8-08d0-892c-e893bb525b71@suse.cz>
From: Balbir Singh <bsingharora@gmail.com>
Message-ID: <d2e2c672-8f56-49a6-79d1-c5d2276db4a3@gmail.com>
Date: Wed, 1 Mar 2017 07:34:24 +1100
MIME-Version: 1.0
In-Reply-To: <4c44a589-5fd8-08d0-892c-e893bb525b71@suse.cz>
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>, lsf-pc@lists.linux-foundation.org, "linux-mm@kvack.org" <linux-mm@kvack.org>
Cc: Li Zefan <lizefan@huawei.com>, cgroups@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>, Michal Hocko <mhocko@kernel.org>, David Rientjes <rientjes@google.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Anshuman Khandual <khandual@linux.vnet.ibm.com>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, Mel Gorman <mgorman@techsingularity.net>



On 03/02/17 20:17, Vlastimil Babka wrote:
> Hi,
> 
> this mail tries to summarize the problems with current cpusets implementation
> wrt memory restrictions, especially when used together with mempolicies.
> The issues were initially discovered when working on the series fixing recent
> premature OOM regressions [1] and then there was more staring at the code and
> git archeology.
> 
> Possible spurious OOMs
> 
> Spurious OOM kills can happen due to updating cpuset's mems (or reattaching
> task to different cpuset) racing with page allocation for a vma with mempolicy.
> This probably originates with commit 19770b32609b ("mm: filter based on a
> nodemask as well as a gfp_mask") or 58568d2a8215 ("cpuset,mm: update tasks'
> mems_allowed in time"). Before the former commit, mempolicy node restrictions
> were reflected with a custom zonelist, which was replaced by a simple pointer
> swap when updated due to cpuset changes. After the commit, the nodemask used
> by allocation is concurrently updated. Before the latter commit,
> task->mems_allowed was protected by a generation counter and updated
> synchronously. After the commit, it's updated concurrently.
> These concurrent updates may cause page allocation to see all nodes as not
> available due to mempolicy and cpusets, and lead to OOM.
> 
> This has already happened in the past and commit 708c1bbc9d0c ("mempolicy:
> restructure rebinding-mempolicy functions") was fixing this by more complex
> update protocol, which was then adjusted to use a seq-lock with cc9a6c877661
> ("cpuset: mm: reduce large amounts of memory barrier related damage v3").
> However this only protects the task->mems_allowed updated and per-task
> mempolicy updates. Per-vma mempolicy updates happen outside these protections
> and the possibility of OOM was verified by testing [2].
> 
> Code complexity
> 
> As mentioned above, concurrent updates to task->mems_allowed and mempolicy are
> rather complexi, see e.g. mpol_rebind_policy() and
> cpuset_change_task_nodemask(). Fixing the spurious OOM problem with the current
> approach [3] will introduce even more subtlety. This all comes from the
> parallel updates. Originally, task->mems_allowed was a snapshot updated
> synchronously.  For mempolicy nodemask updates, we probably should not take an
> on-stack snapshot of the nodemask in allocation path. But we can look at how
> mbind() itself updates existing mempolicies, which is done by swapping in an
> updated copy. One obvious idea is also to not touch mempolicy nodemask from
> cpuset, because we check __cpuset_node_allowed() explicitly anyway (see next
> point). That however doesn't seem feasible for all mempolicies because of the
> relative nodes semantics (see also the semantics discussion).
> 
> Code efficiency
> 
> The get_page_from_freelist() function gets the nodemask parameter, which is
> typically obtained from a task or vma mempolicy. Additionally, it will check
> __cpuset_node_allowed when cpusets are enabled. This additional check is
> wasteful when the cpuset restrictions were already applied to the mempolicy's
> nodemask.
> 

I suspect the allocator has those checks for kernel allocations and policies control
user mode pages faulted in. I've been playing around with coherent memory and find
that cpusets/mempolicies/zonelists are so tightly bound that they are difficult
to extend for other purposes.


> Issues with semantics
> 
> The __cpuset_node_allowed() function is not a simple check for
> current->mems_allowed. It allows any node in interrupt, TIF_MEMDIE, PF_EXITING
> or cpuset ancestors (without __GFP_HARDWALL).

I think this is how cpusets that are hardwalled, control allocations and allow
them to come from an ancestor in the hierarchy

 This works as intended if there
> is no mempolicy, but once there is a nodemask from a mempolicy, the cpuset
> restrictions are already applied to it, so the for_next_zone_zonelist_nodemask()
> loop already filters the nodes and the __cpuset_node_allowed() decisions cannot
> apply.

Again I think the difference is the mempolicy is for user space fault handling
and the allocator is for common allocation.

 It's true that allocations with mempolicies are typically user-space
> pagefaults, thus __GFP_HARDWALL, not in interrupt, etc, but it's subtle. And
> there is a number of driver allocations using alloc_pages() that implicitly use
> tasks's mempolicy and thus can be affected by this discrepancy.
> 
> A related question is why we allow an allocation to escape cpuset restrictions,
> but not also mempolicy restrictions. This includes allocations where we allow
> dipping into memory reserves by ALLOC_NO_WATERMARKS, because
> gfp_pfmemalloc_allowed(). It seems wrong to keep restricting such critical
> allocations due to current task's mempolicy. We could set ac->nodemask to NULL
> in such situations, but can we distinguish nodemasks coming from mempolicies
> from nodemasks coming from e.g. HW restrictions on the memory placement?
> 

I think that is a real good question. The only time I've seen a nodemask come
from a mempolicy is when the policy is MPOL_BIND, IIRC. That like you said
is already filtered with cpusets

> Possible fix approach
> 
> Cpuset updates will rebind nodemasks only of those mempolicies that need it wrt
> their relative nodes semantics (those are either created with the flag
> MPOL_F_RELATIVE_NODES, or with neither RELATIVE nor STATIC flag). The others
> (created with the STATIC flag) we can leave untouched. For mempolicies that we
> keep rebinding, adopt the approach of mbind() that swaps an updated copy
> instead of in-place changes. We can leave get_page_from_freelist() as it is and
> nodes will be filtered orthogonally with mempolicy nodemask and cpuset check.
> 
> This will give us stable nodemask throughout the whole allocation without a
> need for an on-stack copy. The next question is what to do with
> current->mems_allowed. Do we keep the parallel modifications with seqlock
> protection or e.g. try to go back to the synchronous copy approach?
> 
> Related to that is a remaining corner case with alloc_pages_vma() which has its
> own seqlock-protected scope. There it calls policy_nodemask() which might
> detect that there's no intersection between the mempolicy and cpuset and return
> NULL nodemask. However, __alloc_pages_slowpath() has own seqlock scope, so if a
> modification to mems_allowed (resulting in no intersection with mempolicy)
> happens between the check in policy_nodemask() and reaching
> __alloc_pages_slowpath(), the latter won't detect the modification and invoke
> OOM before it can return with a failed allocation to alloc_pages_vma() and let
> it detect a seqlock update and retry. One solution as shown in the RFC patch [3]
> is to add another check for the cpuset/nodemask intersection before OOM. That
> works, but it's a bit hacky and still produces an allocation failure warning.
> 
> On the other hand, we might also want to make things more robust in general and
> prevent spurious OOMs due to no nodes being eligible for also any other reason,
> such as buggy driver passing a wrong nodemask (which doesn't necessarily come
> from a mempolicy).
> 
> [1] https://lkml.kernel.org/r/20170120103843.24587-1-vbabka@suse.cz
> [2] https://lkml.kernel.org/r/a3bc44cd-3c81-c20e-aecb-525eb73b9bfe@suse.cz
> [3] https://lkml.kernel.org/r/7c459f26-13a6-a817-e508-b65b903a8378@suse.cz
> 
Thanks for looking into this. I suspect cpuset is quite static in nature today
(setup and use) and most applications are happy to live with it and cpusets.
But you are right that this needs fixing.

Balbir

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

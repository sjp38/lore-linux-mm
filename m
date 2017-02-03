Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wj0-f199.google.com (mail-wj0-f199.google.com [209.85.210.199])
	by kanga.kvack.org (Postfix) with ESMTP id 20A1F6B0038
	for <linux-mm@kvack.org>; Fri,  3 Feb 2017 04:17:23 -0500 (EST)
Received: by mail-wj0-f199.google.com with SMTP id gt1so3253201wjc.0
        for <linux-mm@kvack.org>; Fri, 03 Feb 2017 01:17:23 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id 7si1552374wms.86.2017.02.03.01.17.21
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Fri, 03 Feb 2017 01:17:21 -0800 (PST)
From: Vlastimil Babka <vbabka@suse.cz>
Subject: [LSF/MM TOPIC] cpuset vs mempolicy related issues
Message-ID: <4c44a589-5fd8-08d0-892c-e893bb525b71@suse.cz>
Date: Fri, 3 Feb 2017 10:17:15 +0100
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: lsf-pc@lists.linux-foundation.org, "linux-mm@kvack.org" <linux-mm@kvack.org>
Cc: Li Zefan <lizefan@huawei.com>, cgroups@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>, Michal Hocko <mhocko@kernel.org>, David Rientjes <rientjes@google.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Anshuman Khandual <khandual@linux.vnet.ibm.com>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, Mel Gorman <mgorman@techsingularity.net>

Hi,

this mail tries to summarize the problems with current cpusets implementation
wrt memory restrictions, especially when used together with mempolicies.
The issues were initially discovered when working on the series fixing recent
premature OOM regressions [1] and then there was more staring at the code and
git archeology.

Possible spurious OOMs

Spurious OOM kills can happen due to updating cpuset's mems (or reattaching
task to different cpuset) racing with page allocation for a vma with mempolicy.
This probably originates with commit 19770b32609b ("mm: filter based on a
nodemask as well as a gfp_mask") or 58568d2a8215 ("cpuset,mm: update tasks'
mems_allowed in time"). Before the former commit, mempolicy node restrictions
were reflected with a custom zonelist, which was replaced by a simple pointer
swap when updated due to cpuset changes. After the commit, the nodemask used
by allocation is concurrently updated. Before the latter commit,
task->mems_allowed was protected by a generation counter and updated
synchronously. After the commit, it's updated concurrently.
These concurrent updates may cause page allocation to see all nodes as not
available due to mempolicy and cpusets, and lead to OOM.

This has already happened in the past and commit 708c1bbc9d0c ("mempolicy:
restructure rebinding-mempolicy functions") was fixing this by more complex
update protocol, which was then adjusted to use a seq-lock with cc9a6c877661
("cpuset: mm: reduce large amounts of memory barrier related damage v3").
However this only protects the task->mems_allowed updated and per-task
mempolicy updates. Per-vma mempolicy updates happen outside these protections
and the possibility of OOM was verified by testing [2].

Code complexity

As mentioned above, concurrent updates to task->mems_allowed and mempolicy are
rather complexi, see e.g. mpol_rebind_policy() and
cpuset_change_task_nodemask(). Fixing the spurious OOM problem with the current
approach [3] will introduce even more subtlety. This all comes from the
parallel updates. Originally, task->mems_allowed was a snapshot updated
synchronously.  For mempolicy nodemask updates, we probably should not take an
on-stack snapshot of the nodemask in allocation path. But we can look at how
mbind() itself updates existing mempolicies, which is done by swapping in an
updated copy. One obvious idea is also to not touch mempolicy nodemask from
cpuset, because we check __cpuset_node_allowed() explicitly anyway (see next
point). That however doesn't seem feasible for all mempolicies because of the
relative nodes semantics (see also the semantics discussion).

Code efficiency

The get_page_from_freelist() function gets the nodemask parameter, which is
typically obtained from a task or vma mempolicy. Additionally, it will check
__cpuset_node_allowed when cpusets are enabled. This additional check is
wasteful when the cpuset restrictions were already applied to the mempolicy's
nodemask.

Issues with semantics

The __cpuset_node_allowed() function is not a simple check for
current->mems_allowed. It allows any node in interrupt, TIF_MEMDIE, PF_EXITING
or cpuset ancestors (without __GFP_HARDWALL). This works as intended if there
is no mempolicy, but once there is a nodemask from a mempolicy, the cpuset
restrictions are already applied to it, so the for_next_zone_zonelist_nodemask()
loop already filters the nodes and the __cpuset_node_allowed() decisions cannot
apply. It's true that allocations with mempolicies are typically user-space
pagefaults, thus __GFP_HARDWALL, not in interrupt, etc, but it's subtle. And
there is a number of driver allocations using alloc_pages() that implicitly use
tasks's mempolicy and thus can be affected by this discrepancy.

A related question is why we allow an allocation to escape cpuset restrictions,
but not also mempolicy restrictions. This includes allocations where we allow
dipping into memory reserves by ALLOC_NO_WATERMARKS, because
gfp_pfmemalloc_allowed(). It seems wrong to keep restricting such critical
allocations due to current task's mempolicy. We could set ac->nodemask to NULL
in such situations, but can we distinguish nodemasks coming from mempolicies
from nodemasks coming from e.g. HW restrictions on the memory placement?

Possible fix approach

Cpuset updates will rebind nodemasks only of those mempolicies that need it wrt
their relative nodes semantics (those are either created with the flag
MPOL_F_RELATIVE_NODES, or with neither RELATIVE nor STATIC flag). The others
(created with the STATIC flag) we can leave untouched. For mempolicies that we
keep rebinding, adopt the approach of mbind() that swaps an updated copy
instead of in-place changes. We can leave get_page_from_freelist() as it is and
nodes will be filtered orthogonally with mempolicy nodemask and cpuset check.

This will give us stable nodemask throughout the whole allocation without a
need for an on-stack copy. The next question is what to do with
current->mems_allowed. Do we keep the parallel modifications with seqlock
protection or e.g. try to go back to the synchronous copy approach?

Related to that is a remaining corner case with alloc_pages_vma() which has its
own seqlock-protected scope. There it calls policy_nodemask() which might
detect that there's no intersection between the mempolicy and cpuset and return
NULL nodemask. However, __alloc_pages_slowpath() has own seqlock scope, so if a
modification to mems_allowed (resulting in no intersection with mempolicy)
happens between the check in policy_nodemask() and reaching
__alloc_pages_slowpath(), the latter won't detect the modification and invoke
OOM before it can return with a failed allocation to alloc_pages_vma() and let
it detect a seqlock update and retry. One solution as shown in the RFC patch [3]
is to add another check for the cpuset/nodemask intersection before OOM. That
works, but it's a bit hacky and still produces an allocation failure warning.

On the other hand, we might also want to make things more robust in general and
prevent spurious OOMs due to no nodes being eligible for also any other reason,
such as buggy driver passing a wrong nodemask (which doesn't necessarily come
from a mempolicy).

[1] https://lkml.kernel.org/r/20170120103843.24587-1-vbabka@suse.cz
[2] https://lkml.kernel.org/r/a3bc44cd-3c81-c20e-aecb-525eb73b9bfe@suse.cz
[3] https://lkml.kernel.org/r/7c459f26-13a6-a817-e508-b65b903a8378@suse.cz

=====

Git archeology notes:

initial git commit 1da177e4c3f
- cpuset_zone_allowed checks current->mems_allowed
- there's no __GFP_HARDWALL and associated games, everything is thus effectively 
HARDWALL
- mempolicies implemented by zonelist only, no nodemasks
- mempolicies not touched by cpuset updates
- updates of current->mems_allowed done synchronously using generation counter

2.6.14 (2005)
f90b1d2f1aaa ("[PATCH] cpusets: new __GFP_HARDWALL flag")
- still checking current->mems_allowed
- also checking ancestors for non-hardwall allocations

2.6.15
68860ec10bcc ("[PATCH] cpusets: automatic numa mempolicy rebinding")
- started rebinding task's mempolicies
   - until then they behaved as static?
- mempolicies still zonelist based, so updates are simple zonelist pointer swap, 
should be safe?

2.6.16 (2006)
4225399a66b3 ("[PATCH] cpuset: rebind vma mempolicies fix")
- introduced per-vma rebinding
   - still ok, because simple zonelist pointer swap?

2.6.26 (2008)
19770b32609b ("mm: filter based on a nodemask as well as a gfp_mask")
- filtering by nodemask
- rebinds no longer a simple zonelist swap
f5b087b52f17 ("mempolicy: add MPOL_F_STATIC_NODES flag")
4c50bc0116cf ("mempolicy: add MPOL_F_RELATIVE_NODES flag")
- Documentation/vm/numa_memory_policy.txt has most details

2.6.30 (2009)
3b6766fe668b ("cpuset: rewrite update_tasks_nodemask()")
- just cleanup?

2.6.31 (2009)
58568d2a8215 ("cpuset,mm: update tasks' mems_allowed in time")
- remove cpuset_mems_generation, update concurrently
- apparently a bug fix for allocation on not allowed node due to rotor

2010:
708c1bbc9d0c ("mempolicy: restructure rebinding-mempolicy functions")
- the elaborate 2-step update protocol

2012:
cc9a6c877661 ("cpuset: mm: reduce large amounts of memory barrier related damage 
v3")
- seqlock protection

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

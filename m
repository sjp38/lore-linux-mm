Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f200.google.com (mail-wr0-f200.google.com [209.85.128.200])
	by kanga.kvack.org (Postfix) with ESMTP id F05BD6B0390
	for <linux-mm@kvack.org>; Thu, 13 Apr 2017 02:24:03 -0400 (EDT)
Received: by mail-wr0-f200.google.com with SMTP id b78so5220798wrd.18
        for <linux-mm@kvack.org>; Wed, 12 Apr 2017 23:24:03 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id 35si34623979wrj.58.2017.04.12.23.24.02
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 12 Apr 2017 23:24:02 -0700 (PDT)
Subject: Re: [RFC 1/6] mm, page_alloc: fix more premature OOM due to race with
 cpuset update
References: <20170411140609.3787-1-vbabka@suse.cz>
 <20170411140609.3787-2-vbabka@suse.cz>
 <alpine.DEB.2.20.1704111152170.25069@east.gentwo.org>
 <a86ae57a-3efc-6ae5-ddf0-fd64c53c20fa@suse.cz>
 <alpine.DEB.2.20.1704121617040.28335@east.gentwo.org>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <cf9628e9-20ed-68b0-6cbd-48af5133138c@suse.cz>
Date: Thu, 13 Apr 2017 08:24:00 +0200
MIME-Version: 1.0
In-Reply-To: <alpine.DEB.2.20.1704121617040.28335@east.gentwo.org>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@linux.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, cgroups@vger.kernel.org, Li Zefan <lizefan@huawei.com>, Michal Hocko <mhocko@kernel.org>, Mel Gorman <mgorman@techsingularity.net>, David Rientjes <rientjes@google.com>, Hugh Dickins <hughd@google.com>, Andrea Arcangeli <aarcange@redhat.com>, Anshuman Khandual <khandual@linux.vnet.ibm.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, linux-api@vger.kernel.org

On 04/12/2017 11:25 PM, Christoph Lameter wrote:
> On Tue, 11 Apr 2017, Vlastimil Babka wrote:
> 
>>> The fallback was only intended for a cpuset on which boundaries are not enforced
>>> in critical conditions (softwall). A hardwall cpuset (CS_MEM_HARDWALL)
>>> should fail the allocation.
>>
>> Hmm just to clarify - I'm talking about ignoring the *mempolicy's* nodemask on
>> the basis of cpuset having higher priority, while you seem to be talking about
>> ignoring a (softwall) cpuset nodemask, right? man set_mempolicy says "... if
>> required nodemask contains no nodes that are allowed by the process's current
>> cpuset context, the memory  policy reverts to local allocation" which does come
>> down to ignoring mempolicy's nodemask.
> 
> I am talking of allocating outside of the current allowed nodes
> (determined by mempolicy -- MPOL_BIND is the only concern as far as I can
> tell -- as well as the current cpuset). One can violate the cpuset if its not
> a hardwall but  the MPOL_MBIND node restriction cannot be violated.
> 
> Those allocations are also not allowed if the allocation was for a user
> space page even if this is a softwall cpuset.
> 
>>>> This patch fixes the issue by having __alloc_pages_slowpath() check for empty
>>>> intersection of cpuset and ac->nodemask before OOM or allocation failure. If
>>>> it's indeed empty, the nodemask is ignored and allocation retried, which mimics
>>>> node_zonelist(). This works fine, because almost all callers of
>>>
>>> Well that would need to be subject to the hardwall flag. Allocation needs
>>> to fail for a hardwall cpuset.
>>
>> They still do, if no hardwall cpuset node can satisfy the allocation with
>> mempolicy ignored.
> 
> If the memory policy is MPOL_MBIND then allocations outside of the given
> nodes should fail. They can violate the cpuset boundaries only if they are
> kernel allocations and we are not in a hardwall cpuset.
> 
> That was at least my understand when working on this code years ago.

Hmm, I see policy_nodemask() (I wrongly mentioned node_zonelist()
before) ignores BIND mempolicy nodemask when it doesn't overlap with
cpuset allowed nodes since initial git commit 1da177e4c3f4 (back then it
was zonelist_policy()). But AFAIU this couldn't actually happen (outside
of races), because 1) one is not allowed to create such effectively
empty BIND mempolicy in the first place and 2) an existing mempolicy is
rebound on cpuset changes to maintain the overlap.

The point 2) does not apply to MPOL_F_STATIC_NODES mempolicies
introduced in 2008 by DavidR, but it's documented in
Documentation/vm/numa_memory_policy.txt and manpages that when they
don't overlap with cpuset allowed nodes, the default mempolicy is used
instead.

I doubt we can change that now, because that can break existing
programs. It also makes some sense at least to me, because a task can
control its own mempolicy (for performance reasons), but cpuset changes
are admin decisions that the task cannot even anticipate. I think it's
better to continue working with suboptimal performance than start
failing allocations?

> 
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

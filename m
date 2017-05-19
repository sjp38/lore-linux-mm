Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f72.google.com (mail-wm0-f72.google.com [74.125.82.72])
	by kanga.kvack.org (Postfix) with ESMTP id 54AA428041F
	for <linux-mm@kvack.org>; Fri, 19 May 2017 07:28:01 -0400 (EDT)
Received: by mail-wm0-f72.google.com with SMTP id 204so14113608wmy.1
        for <linux-mm@kvack.org>; Fri, 19 May 2017 04:28:01 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id c40si7564494edb.70.2017.05.19.04.27.59
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Fri, 19 May 2017 04:28:00 -0700 (PDT)
Subject: Re: [RFC 1/6] mm, page_alloc: fix more premature OOM due to race with
 cpuset update
References: <20170411140609.3787-2-vbabka@suse.cz>
 <alpine.DEB.2.20.1704111152170.25069@east.gentwo.org>
 <a86ae57a-3efc-6ae5-ddf0-fd64c53c20fa@suse.cz>
 <alpine.DEB.2.20.1704121617040.28335@east.gentwo.org>
 <cf9628e9-20ed-68b0-6cbd-48af5133138c@suse.cz>
 <alpine.DEB.2.20.1704141526260.17435@east.gentwo.org>
 <fda99ddc-94f5-456e-6560-d4991da452a6@suse.cz>
 <alpine.DEB.2.20.1704301628460.21533@east.gentwo.org>
 <20170517092042.GH18247@dhcp22.suse.cz>
 <alpine.DEB.2.20.1705170855430.7925@east.gentwo.org>
 <20170517140501.GM18247@dhcp22.suse.cz>
 <alpine.DEB.2.20.1705170943090.8714@east.gentwo.org>
 <8889d67a-adab-91e1-c320-d8bd88d7e1e0@suse.cz>
 <alpine.DEB.2.20.1705181158250.27641@east.gentwo.org>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <4bdfa99a-d241-131e-40a3-67b030803b0e@suse.cz>
Date: Fri, 19 May 2017 13:27:56 +0200
MIME-Version: 1.0
In-Reply-To: <alpine.DEB.2.20.1705181158250.27641@east.gentwo.org>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@linux.com>
Cc: Michal Hocko <mhocko@kernel.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, cgroups@vger.kernel.org, Li Zefan <lizefan@huawei.com>, Mel Gorman <mgorman@techsingularity.net>, David Rientjes <rientjes@google.com>, Hugh Dickins <hughd@google.com>, Andrea Arcangeli <aarcange@redhat.com>, Anshuman Khandual <khandual@linux.vnet.ibm.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, linux-api@vger.kernel.org

On 05/18/2017 07:07 PM, Christoph Lameter wrote:
> On Thu, 18 May 2017, Vlastimil Babka wrote:
> 
>>> The race is where? If you expand the node set during the move of the
>>> application then you are safe in terms of the legacy apps that did not
>>> include static bindings.
>>
>> No, that expand/shrink by itself doesn't work against parallel
> 
> Parallel? I think we are clear that ithis is inherently racy against the
> app changing policies etc etc? There is a huge issue there already. The
> app needs to be well behaved in some heretofore undefined way in order to
> make moves clean.

The code is safe against mbind() changing a vma's mempolicy parallel to
another thread page faulting within that vma, because mbind() takes
mmap_sem for write, and page faults take it for read. The per-task
mempolicy can be changed by set_mempolicy() call which means the task
itself doesn't allocate stuff in parallel.
So, the application never needed to be "well behaved" wrt changing its
own mempolicies.

Now with mempolicy rebinding due to cpuset migrations, the application
cannot be "well behaved" as it has no way to learn about being under a
cpuset, or cpuset change. Any application can be put in a cpuset and we
can't really expect that all would be adapted, even if the necessary
interfaces existed. Thus, the rebinding implementation in the kernel
itself has to be robust against parallel allocations.

>> get_page_from_freelist going through a zonelist. Moving from node 0 to
>> 1, with zonelist containing nodes 1 and 0 in that order:
>>
>> - mempolicy mask is 0
>> - zonelist iteration checks node 1, it's not allowed, skip
> 
> There is an allocation from node 1?

Sorry, I missed to mention the full scenario. Let's say the allocation
is on cpu local to node 1, so it gets zonelist from node 1, which
contains nodes 1 and 0 in that order.

> This is not allowed before the move.
> So it should fail. Not skipping to another node.
> 
>> - mempolicy mask is 0,1 (expand)
>> - mempolicy mask is 1 (shrink)
>> - zonelist iteration checks node 0, it's not allowed, skip
>> - OOM
> 
> Are you talking about a race here between zonelist scanning and the
> moving? That has been there forever.

As far as I can tell from my git archeology in [1] there was always some
kind of protection against the race (generation counters, two-step
protocol, seqlock...), which however had some corner cases. This patch
is merely plugging the last known one.

> And frankly there are gazillions of these races.

I don't know about any other existing race that we don't handle after
this patch.

> The best thing to do is
> to get the cpuset moving logic out of the kernel and into user space.
> 
> Understand that this is a heuristic and maybe come up with a list of
> restrictions that make an app safe. An safe app that can be moved must f.e
> 
> 1. Not allocate new memory while its being moved
> 2. Not change memory policies after its initialization and while its being
> moved.

As I explainer eariler in this mail, changing mempolicy by app itself is
safe, the problem was always due to cpuset-triggered rebinding.

> 3. Not save memory policy state in some variable (because the logic to
> translate the memory policies for the new context cannot find it).
> 
> ...
> 
> Again cpuset process migration  is a huge mess that you do not want to
> have in the kernel and AFAICT this is a corner case with difficult
> semantics. Better have that in user space...

Moving this out of kernel etc is changing the current semantics and
breaking existing userspace, this patch is a fix within the existing one.

[1] https://marc.info/?l=linux-mm&m=148611344511408&w=2


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

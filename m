Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f197.google.com (mail-io0-f197.google.com [209.85.223.197])
	by kanga.kvack.org (Postfix) with ESMTP id 55B566B0038
	for <linux-mm@kvack.org>; Wed, 26 Apr 2017 04:07:39 -0400 (EDT)
Received: by mail-io0-f197.google.com with SMTP id 28so246225568iod.14
        for <linux-mm@kvack.org>; Wed, 26 Apr 2017 01:07:39 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id v13si7996284ite.43.2017.04.26.01.07.36
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 26 Apr 2017 01:07:36 -0700 (PDT)
Subject: Re: [RFC 1/6] mm, page_alloc: fix more premature OOM due to race with
 cpuset update
References: <20170411140609.3787-1-vbabka@suse.cz>
 <20170411140609.3787-2-vbabka@suse.cz>
 <alpine.DEB.2.20.1704111152170.25069@east.gentwo.org>
 <a86ae57a-3efc-6ae5-ddf0-fd64c53c20fa@suse.cz>
 <alpine.DEB.2.20.1704121617040.28335@east.gentwo.org>
 <cf9628e9-20ed-68b0-6cbd-48af5133138c@suse.cz>
 <alpine.DEB.2.20.1704141526260.17435@east.gentwo.org>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <fda99ddc-94f5-456e-6560-d4991da452a6@suse.cz>
Date: Wed, 26 Apr 2017 10:07:32 +0200
MIME-Version: 1.0
In-Reply-To: <alpine.DEB.2.20.1704141526260.17435@east.gentwo.org>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@linux.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, cgroups@vger.kernel.org, Li Zefan <lizefan@huawei.com>, Michal Hocko <mhocko@kernel.org>, Mel Gorman <mgorman@techsingularity.net>, David Rientjes <rientjes@google.com>, Hugh Dickins <hughd@google.com>, Andrea Arcangeli <aarcange@redhat.com>, Anshuman Khandual <khandual@linux.vnet.ibm.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, linux-api@vger.kernel.org

On 04/14/2017 10:37 PM, Christoph Lameter wrote:
> On Thu, 13 Apr 2017, Vlastimil Babka wrote:
> 
>>
>> I doubt we can change that now, because that can break existing
>> programs. It also makes some sense at least to me, because a task can
>> control its own mempolicy (for performance reasons), but cpuset changes
>> are admin decisions that the task cannot even anticipate. I think it's
>> better to continue working with suboptimal performance than start
>> failing allocations?
> 
> If the expected semantics (hardwall) are that allocations should fail then
> lets be consistent and do so.

It's not "expected" right now. The documented semantics is that (static,
as the others are rebound) mempolicy is ignored when it's not compatible
with cpuset. I'm just reusing the same existing semantic for race
situations. We can discuss whether we can change the semantics now, but
I don't think it should block this fix.

> Adding more and more exceptions gets this convoluted mess into an even
> worse shape.

Again, it's not a new exception semantics-wise, but I agree that the
code of __alloc_pages_slowpath() is even more subtle. But I don't see
any other easy fix.

> Adding the static binding of nodes was already a screwball
> if used within a cpuset because now one has to anticipate how a user would
> move the nodes of a cpuset and how the static bindings would work in such
> a context.

On the other hand, static mempolicy is the only one that does not need
rebinding, and removing the other modes would allow much simpler
implementation. I thought the outcome of LSF/MM session was that we
should try to go that way.

> The admin basically needs to know how the application has used memory
> policies if one still wants to move the applications within a cpuset with
> the fixed bindings.
> 
> Maybe the best way to handle this is to give up on cpuset migration of
> live applications? After all this can be done with a script in the same
> way as the kernel is doing:
> 
> 1. Extend the cpuset to include the new nodes.
> 
> 2. Loop over the processes and use the migrate_pages() to move the apps
> one by one.
> 
> 3. Remove the nodes no longer to be used.
> 
> Then forget about translating memory policies. If an application that is
> supposed to run in a cpuset and supposed to be moveable has fixed bindings
> then the application should be aware of that and be equipped with
> some logic to rebind its memory on its own.
> 
> Such an application typically already has such logic and executes a
> binding after discovering its numa node configuration on startup. It would
> have to be modified to redo that action when it gets some sort of a signal
> from the script telling it that the node config would be changed.
> 
> Having this logic in the application instead of the kernel avoids all the
> kernel messes that we keep on trying to deal with and IMHO is much
> cleaner.

That would be much simpler for us indeed. But we still IMHO can't
abruptly start denying page fault allocations for existing applications
that don't have the necessary awareness.


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

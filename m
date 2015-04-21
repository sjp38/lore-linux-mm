Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f54.google.com (mail-pa0-f54.google.com [209.85.220.54])
	by kanga.kvack.org (Postfix) with ESMTP id B6E076B0032
	for <linux-mm@kvack.org>; Tue, 21 Apr 2015 03:33:04 -0400 (EDT)
Received: by pabsx10 with SMTP id sx10so233035836pab.3
        for <linux-mm@kvack.org>; Tue, 21 Apr 2015 00:33:04 -0700 (PDT)
Received: from e23smtp06.au.ibm.com (e23smtp06.au.ibm.com. [202.81.31.148])
        by mx.google.com with ESMTPS id nx16si1691241pdb.158.2015.04.21.00.33.01
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Tue, 21 Apr 2015 00:33:03 -0700 (PDT)
Received: from /spool/local
	by e23smtp06.au.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <aneesh.kumar@linux.vnet.ibm.com>;
	Tue, 21 Apr 2015 17:32:57 +1000
Received: from d23relay10.au.ibm.com (d23relay10.au.ibm.com [9.190.26.77])
	by d23dlp01.au.ibm.com (Postfix) with ESMTP id 9D21F2CE804E
	for <linux-mm@kvack.org>; Tue, 21 Apr 2015 17:32:55 +1000 (EST)
Received: from d23av04.au.ibm.com (d23av04.au.ibm.com [9.190.235.139])
	by d23relay10.au.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id t3L7WkF532309314
	for <linux-mm@kvack.org>; Tue, 21 Apr 2015 17:32:55 +1000
Received: from d23av04.au.ibm.com (localhost [127.0.0.1])
	by d23av04.au.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id t3L7WKSU027761
	for <linux-mm@kvack.org>; Tue, 21 Apr 2015 17:32:20 +1000
From: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
Subject: Re: [patch v2 for-4.0] mm, thp: really limit transparent hugepage allocation to local node
In-Reply-To: <54EE60FC.7000909@suse.cz>
References: <alpine.DEB.2.10.1502241422370.11324@chino.kir.corp.google.com> <alpine.DEB.2.10.1502241522590.9480@chino.kir.corp.google.com> <54EDA96C.4000609@suse.cz> <alpine.DEB.2.10.1502251311360.18097@chino.kir.corp.google.com> <54EE60FC.7000909@suse.cz>
Date: Tue, 21 Apr 2015 13:01:47 +0530
Message-ID: <87k2x6q6n0.fsf@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>, David Rientjes <rientjes@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Greg Thelen <gthelen@google.com>, Linus Torvalds <torvalds@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

Vlastimil Babka <vbabka@suse.cz> writes:

> On 25.2.2015 22:24, David Rientjes wrote:
>>
>>> alloc_pages_preferred_node() variant, change the exact_node() variant to pass
>>> __GFP_THISNODE, and audit and adjust all callers accordingly.
>>>
>> Sounds like that should be done as part of a cleanup after the 4.0 issues
>> are addressed.  alloc_pages_exact_node() does seem to suggest that we want
>> exactly that node, implying __GFP_THISNODE behavior already, so it would
>> be good to avoid having this come up again in the future.
>
> Oh lovely, just found out that there's alloc_pages_node which should be the
> preferred-only version, but in fact does not differ from 
> alloc_pages_exact_node
> in any relevant way. I agree we should do some larger cleanup for next 
> version.
>
>>> Also, you pass __GFP_NOWARN but that should be covered by GFP_TRANSHUGE
>>> already. Of course, nothing guarantees that hugepage == true implies that gfp
>>> == GFP_TRANSHUGE... but current in-tree callers conform to that.
>>>
>> Ah, good point, and it includes __GFP_NORETRY as well which means that
>> this patch is busted.  It won't try compaction or direct reclaim in the
>> page allocator slowpath because of this:
>>
>> 	/*
>> 	 * GFP_THISNODE (meaning __GFP_THISNODE, __GFP_NORETRY and
>> 	 * __GFP_NOWARN set) should not cause reclaim since the subsystem
>> 	 * (f.e. slab) using GFP_THISNODE may choose to trigger reclaim
>> 	 * using a larger set of nodes after it has established that the
>> 	 * allowed per node queues are empty and that nodes are
>> 	 * over allocated.
>> 	 */
>> 	if (IS_ENABLED(CONFIG_NUMA) &&
>> 	    (gfp_mask & GFP_THISNODE) == GFP_THISNODE)
>> 		goto nopage;
>>
>> Hmm.  It would be disappointing to have to pass the nodemask of the exact
>> node that we want to allocate from into the page allocator to avoid using
>> __GFP_THISNODE.
>
> Yeah.
>
>>
>> There's a sneaky way around it by just removing __GFP_NORETRY from
>> GFP_TRANSHUGE so the condition above fails and since the page allocator
>> won't retry for such a high-order allocation, but that probably just
>> papers over this stuff too much already.  I think what we want to do is
>
> Alternatively alloc_pages_exact_node() adds __GFP_THISNODE just to
> node_zonelist() call and not to __alloc_pages() gfp_mask proper? Unless 
> __GFP_THISNODE
> was given *also* in the incoming gfp_mask, this should give us the right 
> combination?
> But it's also subtle....
>
>> cause the slab allocators to not use __GFP_WAIT if they want to avoid
>> reclaim.
>
> Yes, the fewer subtle heuristics we have that include combinations of 
> flags (*cough*
> GFP_TRANSHUGE *cough*), the better.
>
>> This is probably going to be a much more invasive patch than originally
>> thought.
>
> Right, we might be changing behavior not just for slab allocators, but 
> also others using such
> combination of flags.

Any update on this ? Did we reach a conclusion on how to go forward here
?

-aneesh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

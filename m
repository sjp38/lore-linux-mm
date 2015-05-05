Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f48.google.com (mail-wg0-f48.google.com [74.125.82.48])
	by kanga.kvack.org (Postfix) with ESMTP id AC20A6B0038
	for <linux-mm@kvack.org>; Tue,  5 May 2015 05:12:55 -0400 (EDT)
Received: by wgyo15 with SMTP id o15so175573597wgy.2
        for <linux-mm@kvack.org>; Tue, 05 May 2015 02:12:55 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id el3si1515038wib.24.2015.05.05.02.12.53
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Tue, 05 May 2015 02:12:54 -0700 (PDT)
Message-ID: <55488994.8010303@suse.cz>
Date: Tue, 05 May 2015 11:12:52 +0200
From: Vlastimil Babka <vbabka@suse.cz>
MIME-Version: 1.0
Subject: Re: [patch v2 for-4.0] mm, thp: really limit transparent hugepage
 allocation to local node
References: <alpine.DEB.2.10.1502241422370.11324@chino.kir.corp.google.com> <alpine.DEB.2.10.1502241522590.9480@chino.kir.corp.google.com> <54EDA96C.4000609@suse.cz> <alpine.DEB.2.10.1502251311360.18097@chino.kir.corp.google.com> <54EE60FC.7000909@suse.cz> <87k2x6q6n0.fsf@linux.vnet.ibm.com>
In-Reply-To: <87k2x6q6n0.fsf@linux.vnet.ibm.com>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, David Rientjes <rientjes@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Greg Thelen <gthelen@google.com>, Linus Torvalds <torvalds@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On 04/21/2015 09:31 AM, Aneesh Kumar K.V wrote:
> Vlastimil Babka <vbabka@suse.cz> writes:
>
>> On 25.2.2015 22:24, David Rientjes wrote:
>>>
>>>> alloc_pages_preferred_node() variant, change the exact_node() variant to pass
>>>> __GFP_THISNODE, and audit and adjust all callers accordingly.
>>>>
>>> Sounds like that should be done as part of a cleanup after the 4.0 issues
>>> are addressed.  alloc_pages_exact_node() does seem to suggest that we want
>>> exactly that node, implying __GFP_THISNODE behavior already, so it would
>>> be good to avoid having this come up again in the future.
>>
>> Oh lovely, just found out that there's alloc_pages_node which should be the
>> preferred-only version, but in fact does not differ from
>> alloc_pages_exact_node
>> in any relevant way. I agree we should do some larger cleanup for next
>> version.
>>
>>>> Also, you pass __GFP_NOWARN but that should be covered by GFP_TRANSHUGE
>>>> already. Of course, nothing guarantees that hugepage == true implies that gfp
>>>> == GFP_TRANSHUGE... but current in-tree callers conform to that.
>>>>
>>> Ah, good point, and it includes __GFP_NORETRY as well which means that
>>> this patch is busted.  It won't try compaction or direct reclaim in the
>>> page allocator slowpath because of this:
>>>
>>> 	/*
>>> 	 * GFP_THISNODE (meaning __GFP_THISNODE, __GFP_NORETRY and
>>> 	 * __GFP_NOWARN set) should not cause reclaim since the subsystem
>>> 	 * (f.e. slab) using GFP_THISNODE may choose to trigger reclaim
>>> 	 * using a larger set of nodes after it has established that the
>>> 	 * allowed per node queues are empty and that nodes are
>>> 	 * over allocated.
>>> 	 */
>>> 	if (IS_ENABLED(CONFIG_NUMA) &&
>>> 	    (gfp_mask & GFP_THISNODE) == GFP_THISNODE)
>>> 		goto nopage;
>>>
>>> Hmm.  It would be disappointing to have to pass the nodemask of the exact
>>> node that we want to allocate from into the page allocator to avoid using
>>> __GFP_THISNODE.
>>
>> Yeah.
>>
>>>
>>> There's a sneaky way around it by just removing __GFP_NORETRY from
>>> GFP_TRANSHUGE so the condition above fails and since the page allocator
>>> won't retry for such a high-order allocation, but that probably just
>>> papers over this stuff too much already.  I think what we want to do is
>>
>> Alternatively alloc_pages_exact_node() adds __GFP_THISNODE just to
>> node_zonelist() call and not to __alloc_pages() gfp_mask proper? Unless
>> __GFP_THISNODE
>> was given *also* in the incoming gfp_mask, this should give us the right
>> combination?
>> But it's also subtle....
>>
>>> cause the slab allocators to not use __GFP_WAIT if they want to avoid
>>> reclaim.
>>
>> Yes, the fewer subtle heuristics we have that include combinations of
>> flags (*cough*
>> GFP_TRANSHUGE *cough*), the better.
>>
>>> This is probably going to be a much more invasive patch than originally
>>> thought.
>>
>> Right, we might be changing behavior not just for slab allocators, but
>> also others using such
>> combination of flags.
>
> Any update on this ? Did we reach a conclusion on how to go forward here
> ?

I believe David's later version was merged already. Or what exactly are 
you asking about?

> -aneesh
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

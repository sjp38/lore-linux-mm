Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f50.google.com (mail-wg0-f50.google.com [74.125.82.50])
	by kanga.kvack.org (Postfix) with ESMTP id 7D92A6B0032
	for <linux-mm@kvack.org>; Wed, 25 Feb 2015 18:55:41 -0500 (EST)
Received: by wghk14 with SMTP id k14so6881782wgh.3
        for <linux-mm@kvack.org>; Wed, 25 Feb 2015 15:55:40 -0800 (PST)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id c8si75818672wjw.102.2015.02.25.15.55.39
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Wed, 25 Feb 2015 15:55:39 -0800 (PST)
Message-ID: <54EE60FC.7000909@suse.cz>
Date: Thu, 26 Feb 2015 00:55:40 +0100
From: Vlastimil Babka <vbabka@suse.cz>
MIME-Version: 1.0
Subject: Re: [patch v2 for-4.0] mm, thp: really limit transparent hugepage
 allocation to local node
References: <alpine.DEB.2.10.1502241422370.11324@chino.kir.corp.google.com> <alpine.DEB.2.10.1502241522590.9480@chino.kir.corp.google.com> <54EDA96C.4000609@suse.cz> <alpine.DEB.2.10.1502251311360.18097@chino.kir.corp.google.com>
In-Reply-To: <alpine.DEB.2.10.1502251311360.18097@chino.kir.corp.google.com>
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Greg Thelen <gthelen@google.com>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, Linus Torvalds <torvalds@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On 25.2.2015 22:24, David Rientjes wrote:
>
>> alloc_pages_preferred_node() variant, change the exact_node() variant to pass
>> __GFP_THISNODE, and audit and adjust all callers accordingly.
>>
> Sounds like that should be done as part of a cleanup after the 4.0 issues
> are addressed.  alloc_pages_exact_node() does seem to suggest that we want
> exactly that node, implying __GFP_THISNODE behavior already, so it would
> be good to avoid having this come up again in the future.

Oh lovely, just found out that there's alloc_pages_node which should be the
preferred-only version, but in fact does not differ from 
alloc_pages_exact_node
in any relevant way. I agree we should do some larger cleanup for next 
version.

>> Also, you pass __GFP_NOWARN but that should be covered by GFP_TRANSHUGE
>> already. Of course, nothing guarantees that hugepage == true implies that gfp
>> == GFP_TRANSHUGE... but current in-tree callers conform to that.
>>
> Ah, good point, and it includes __GFP_NORETRY as well which means that
> this patch is busted.  It won't try compaction or direct reclaim in the
> page allocator slowpath because of this:
>
> 	/*
> 	 * GFP_THISNODE (meaning __GFP_THISNODE, __GFP_NORETRY and
> 	 * __GFP_NOWARN set) should not cause reclaim since the subsystem
> 	 * (f.e. slab) using GFP_THISNODE may choose to trigger reclaim
> 	 * using a larger set of nodes after it has established that the
> 	 * allowed per node queues are empty and that nodes are
> 	 * over allocated.
> 	 */
> 	if (IS_ENABLED(CONFIG_NUMA) &&
> 	    (gfp_mask & GFP_THISNODE) == GFP_THISNODE)
> 		goto nopage;
>
> Hmm.  It would be disappointing to have to pass the nodemask of the exact
> node that we want to allocate from into the page allocator to avoid using
> __GFP_THISNODE.

Yeah.

>
> There's a sneaky way around it by just removing __GFP_NORETRY from
> GFP_TRANSHUGE so the condition above fails and since the page allocator
> won't retry for such a high-order allocation, but that probably just
> papers over this stuff too much already.  I think what we want to do is

Alternatively alloc_pages_exact_node() adds __GFP_THISNODE just to
node_zonelist() call and not to __alloc_pages() gfp_mask proper? Unless 
__GFP_THISNODE
was given *also* in the incoming gfp_mask, this should give us the right 
combination?
But it's also subtle....

> cause the slab allocators to not use __GFP_WAIT if they want to avoid
> reclaim.

Yes, the fewer subtle heuristics we have that include combinations of 
flags (*cough*
GFP_TRANSHUGE *cough*), the better.

> This is probably going to be a much more invasive patch than originally
> thought.

Right, we might be changing behavior not just for slab allocators, but 
also others using such
combination of flags.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

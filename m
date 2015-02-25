Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ie0-f169.google.com (mail-ie0-f169.google.com [209.85.223.169])
	by kanga.kvack.org (Postfix) with ESMTP id 34F296B0032
	for <linux-mm@kvack.org>; Wed, 25 Feb 2015 16:24:31 -0500 (EST)
Received: by iecar1 with SMTP id ar1so8779952iec.0
        for <linux-mm@kvack.org>; Wed, 25 Feb 2015 13:24:31 -0800 (PST)
Received: from mail-ig0-x233.google.com (mail-ig0-x233.google.com. [2607:f8b0:4001:c05::233])
        by mx.google.com with ESMTPS id yz3si6030029icb.10.2015.02.25.13.24.30
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 25 Feb 2015 13:24:30 -0800 (PST)
Received: by mail-ig0-f179.google.com with SMTP id l13so9526934iga.0
        for <linux-mm@kvack.org>; Wed, 25 Feb 2015 13:24:30 -0800 (PST)
Date: Wed, 25 Feb 2015 13:24:28 -0800 (PST)
From: David Rientjes <rientjes@google.com>
Subject: Re: [patch v2 for-4.0] mm, thp: really limit transparent hugepage
 allocation to local node
In-Reply-To: <54EDA96C.4000609@suse.cz>
Message-ID: <alpine.DEB.2.10.1502251311360.18097@chino.kir.corp.google.com>
References: <alpine.DEB.2.10.1502241422370.11324@chino.kir.corp.google.com> <alpine.DEB.2.10.1502241522590.9480@chino.kir.corp.google.com> <54EDA96C.4000609@suse.cz>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: Andrew Morton <akpm@linux-foundation.org>, Greg Thelen <gthelen@google.com>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, Linus Torvalds <torvalds@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Wed, 25 Feb 2015, Vlastimil Babka wrote:

> > Commit 077fcf116c8c ("mm/thp: allocate transparent hugepages on local
> > node") restructured alloc_hugepage_vma() with the intent of only
> > allocating transparent hugepages locally when there was not an effective
> > interleave mempolicy.
> > 
> > alloc_pages_exact_node() does not limit the allocation to the single
> > node, however, but rather prefers it.  This is because __GFP_THISNODE is
> > not set which would cause the node-local nodemask to be passed.  Without
> > it, only a nodemask that prefers the local node is passed.
> 
> Oops, good catch.
> But I believe we have the same problem with khugepaged_alloc_page(), rendering
> the recent node determination and zone_reclaim strictness patches partially
> useless.
> 

Indeed.

> Then I start to wonder about other alloc_pages_exact_node() users. Some do
> pass __GFP_THISNODE, others not - are they also mistaken? I guess the function
> is a misnomer - when I see "exact_node", I expect the __GFP_THISNODE behavior.
> 

I looked through these yesterday as well and could only find the 
do_migrate_pages() case for page migration where __GFP_THISNODE was 
missing.  I proposed that separately as 
http://marc.info/?l=linux-mm&m=142481989722497 -- I couldn't find any 
other users that looked wrong.

 > I think to avoid such hidden catches, we should create
> alloc_pages_preferred_node() variant, change the exact_node() variant to pass
> __GFP_THISNODE, and audit and adjust all callers accordingly.
> 

Sounds like that should be done as part of a cleanup after the 4.0 issues 
are addressed.  alloc_pages_exact_node() does seem to suggest that we want 
exactly that node, implying __GFP_THISNODE behavior already, so it would 
be good to avoid having this come up again in the future.

> Also, you pass __GFP_NOWARN but that should be covered by GFP_TRANSHUGE
> already. Of course, nothing guarantees that hugepage == true implies that gfp
> == GFP_TRANSHUGE... but current in-tree callers conform to that.
> 

Ah, good point, and it includes __GFP_NORETRY as well which means that 
this patch is busted.  It won't try compaction or direct reclaim in the 
page allocator slowpath because of this:

	/*
	 * GFP_THISNODE (meaning __GFP_THISNODE, __GFP_NORETRY and
	 * __GFP_NOWARN set) should not cause reclaim since the subsystem
	 * (f.e. slab) using GFP_THISNODE may choose to trigger reclaim
	 * using a larger set of nodes after it has established that the
	 * allowed per node queues are empty and that nodes are
	 * over allocated.
	 */
	if (IS_ENABLED(CONFIG_NUMA) &&
	    (gfp_mask & GFP_THISNODE) == GFP_THISNODE)
		goto nopage;

Hmm.  It would be disappointing to have to pass the nodemask of the exact 
node that we want to allocate from into the page allocator to avoid using 
__GFP_THISNODE.

There's a sneaky way around it by just removing __GFP_NORETRY from 
GFP_TRANSHUGE so the condition above fails and since the page allocator 
won't retry for such a high-order allocation, but that probably just 
papers over this stuff too much already.  I think what we want to do is 
cause the slab allocators to not use __GFP_WAIT if they want to avoid 
reclaim.

This is probably going to be a much more invasive patch than originally 
thought.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

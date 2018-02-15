Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f197.google.com (mail-io0-f197.google.com [209.85.223.197])
	by kanga.kvack.org (Postfix) with ESMTP id ACE0D6B0009
	for <linux-mm@kvack.org>; Thu, 15 Feb 2018 15:47:41 -0500 (EST)
Received: by mail-io0-f197.google.com with SMTP id q4so1354301ioh.4
        for <linux-mm@kvack.org>; Thu, 15 Feb 2018 12:47:41 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id d67sor3309923iof.241.2018.02.15.12.47.40
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 15 Feb 2018 12:47:40 -0800 (PST)
Date: Thu, 15 Feb 2018 12:47:37 -0800 (PST)
From: David Rientjes <rientjes@google.com>
Subject: Re: [patch 1/2] mm, page_alloc: extend kernelcore and movablecore
 for percent
In-Reply-To: <20180215144525.GG7275@dhcp22.suse.cz>
Message-ID: <alpine.DEB.2.10.1802151239470.217103@chino.kir.corp.google.com>
References: <alpine.DEB.2.10.1802121622470.179479@chino.kir.corp.google.com> <20180214095911.GB28460@dhcp22.suse.cz> <alpine.DEB.2.10.1802140225290.261065@chino.kir.corp.google.com> <20180215144525.GG7275@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Jonathan Corbet <corbet@lwn.net>, Vlastimil Babka <vbabka@suse.cz>, Mel Gorman <mgorman@suse.de>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-doc@vger.kernel.org

On Thu, 15 Feb 2018, Michal Hocko wrote:

> > When the amount of kernel 
> > memory is well bounded for certain systems, it is better to aggressively 
> > reclaim from existing MIGRATE_UNMOVABLE pageblocks rather than eagerly 
> > fallback to others.
> > 
> > We have additional patches that help with this fragmentation if you're 
> > interested, specifically kcompactd compaction of MIGRATE_UNMOVABLE 
> > pageblocks triggered by fallback of non-__GFP_MOVABLE allocations and 
> > draining of pcp lists back to the zone free area to prevent stranding.
> 
> Yes, I think we need a proper fix. (Ab)using zone_movable for this
> usecase is just sad.
> 

It's a hard balance to achieve between a fast page allocator with per-cpu 
pagesets, reducing fragmentation of unmovable memory, and the performance 
impact of any fix to reduce that fragmentation for users currently 
unaffected.  Our patches to kick kcompactd for MIGRATE_UNMOVABLE 
pageblocks on fallback would be a waste unless you have a ton of anonymous 
memory you want backed by thp.

If hugepages is the main motivation for reducing the fragmentation, 
hugetlbfs could be suggested because it would give us more runtime control 
and we could leave surplus pages sitting in the free pool unless reclaimed 
under memory pressure.  That works fine in dedicated environments where we 
know how much hugetlb to reserve; if we give it back under memory pressure 
it becomes hard to reallocate the high number of hugepages we want (>95% 
of system memory).  It's much more sloppy in shared environments where the 
amount of hugepages are unknown.

And of course this doesn't address when a pin prevents memory from being 
migrated during memory compaction that is __GFP_MOVABLE at allocation but 
later pinned in place, which can still be a problem with ZONE_MOVABLE.  It 
would nice to have a solution where this memory can be annotated to want 
to come from a non-MIGRATE_MOVABLE pageblock, if possible.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

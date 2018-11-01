Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf1-f198.google.com (mail-pf1-f198.google.com [209.85.210.198])
	by kanga.kvack.org (Postfix) with ESMTP id E12C96B0006
	for <linux-mm@kvack.org>; Thu,  1 Nov 2018 12:55:24 -0400 (EDT)
Received: by mail-pf1-f198.google.com with SMTP id 87-v6so16904401pfq.8
        for <linux-mm@kvack.org>; Thu, 01 Nov 2018 09:55:24 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id s22-v6si43605238pfs.13.2018.11.01.09.55.23
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 01 Nov 2018 09:55:23 -0700 (PDT)
Date: Thu, 1 Nov 2018 17:55:19 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH 2] mm/kvmalloc: do not call kmalloc for size >
 KMALLOC_MAX_SIZE
Message-ID: <20181101165519.GM23921@dhcp22.suse.cz>
References: <154106356066.887821.4649178319705436373.stgit@buzz>
 <154106695670.898059.5301435081426064314.stgit@buzz>
 <20181101102405.GE23921@dhcp22.suse.cz>
 <cd2a55be-17f1-5da9-1154-8e291fe958cd@yandex-team.ru>
 <20181101125543.GH23921@dhcp22.suse.cz>
 <ae51e16b-459c-7d59-6277-b1a197dbf5ff@yandex-team.ru>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <ae51e16b-459c-7d59-6277-b1a197dbf5ff@yandex-team.ru>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Konstantin Khlebnikov <khlebnikov@yandex-team.ru>
Cc: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org

On Thu 01-11-18 19:42:48, Konstantin Khlebnikov wrote:
> On 01.11.2018 15:55, Michal Hocko wrote:
> > On Thu 01-11-18 13:48:17, Konstantin Khlebnikov wrote:
> > > 
> > > 
> > > On 01.11.2018 13:24, Michal Hocko wrote:
> > > > On Thu 01-11-18 13:09:16, Konstantin Khlebnikov wrote:
> > > > > Allocations over KMALLOC_MAX_SIZE could be served only by vmalloc.
> > > > 
> > > > I would go on and say that allocations with sizes too large can actually
> > > > trigger a warning (once you have posted in the previous version outside
> > > > of the changelog area) because that might be interesting to people -
> > > > there are deployments to panic on warning and then a warning is much
> > > > more important.
> > > 
> > > It seems that warning isn't completely valid.
> > > 
> > > 
> > > __alloc_pages_slowpath() handles this more gracefully:
> > > 
> > > 	/*
> > > 	 * In the slowpath, we sanity check order to avoid ever trying to
> > > 	 * reclaim >= MAX_ORDER areas which will never succeed. Callers may
> > > 	 * be using allocators in order of preference for an area that is
> > > 	 * too large.
> > > 	 */
> > > 	if (order >= MAX_ORDER) {
> > > 		WARN_ON_ONCE(!(gfp_mask & __GFP_NOWARN));
> > > 		return NULL;
> > > 	}
> > > 
> > > 
> > > Fast path is ready for order >= MAX_ORDER
> > > 
> > > 
> > > Problem is in node_reclaim() which is called earlier than __alloc_pages_slowpath()
> > > from surprising place - get_page_from_freelist()
> > > 
> > > 
> > > Probably node_reclaim() simply needs something like this:
> > > 
> > > 	if (order >= MAX_ORDER)
> > > 		return NODE_RECLAIM_NOSCAN;
> > 
> > Maybe but the point is that triggering this warning is possible. Even if
> > the warning is bogus it doesn't really make much sense to even try
> > kmalloc if the size is not supported by the allocator.
> > 
> 
> But __GFP_NOWARN allocation (like in this case) should just fail silently
> without warnings regardless of reason because caller can deal with that.

__GFP_NOWARN is not about no warning to be triggered from the allocation
context. It is more about not complaining about the allocation failure.
I do not think we want to check the gfp mask in all possible paths
triggered from the allocator/reclaim.

I have just looked at the original warning you have hit and it came from
88d6ac40c1c6 ("mm/vmstat: fix divide error at __fragmentation_index"). I
would argue that the warning is a bit of an over-reaction. Regardless of
the gfp_mask.
-- 
Michal Hocko
SUSE Labs

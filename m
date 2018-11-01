Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f71.google.com (mail-ed1-f71.google.com [209.85.208.71])
	by kanga.kvack.org (Postfix) with ESMTP id 7286D6B0005
	for <linux-mm@kvack.org>; Thu,  1 Nov 2018 08:55:47 -0400 (EDT)
Received: by mail-ed1-f71.google.com with SMTP id q10-v6so12228501edd.20
        for <linux-mm@kvack.org>; Thu, 01 Nov 2018 05:55:47 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id u17-v6si15866322edi.62.2018.11.01.05.55.45
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 01 Nov 2018 05:55:45 -0700 (PDT)
Date: Thu, 1 Nov 2018 13:55:43 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH 2] mm/kvmalloc: do not call kmalloc for size >
 KMALLOC_MAX_SIZE
Message-ID: <20181101125543.GH23921@dhcp22.suse.cz>
References: <154106356066.887821.4649178319705436373.stgit@buzz>
 <154106695670.898059.5301435081426064314.stgit@buzz>
 <20181101102405.GE23921@dhcp22.suse.cz>
 <cd2a55be-17f1-5da9-1154-8e291fe958cd@yandex-team.ru>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <cd2a55be-17f1-5da9-1154-8e291fe958cd@yandex-team.ru>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Konstantin Khlebnikov <khlebnikov@yandex-team.ru>
Cc: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org

On Thu 01-11-18 13:48:17, Konstantin Khlebnikov wrote:
> 
> 
> On 01.11.2018 13:24, Michal Hocko wrote:
> > On Thu 01-11-18 13:09:16, Konstantin Khlebnikov wrote:
> > > Allocations over KMALLOC_MAX_SIZE could be served only by vmalloc.
> > 
> > I would go on and say that allocations with sizes too large can actually
> > trigger a warning (once you have posted in the previous version outside
> > of the changelog area) because that might be interesting to people -
> > there are deployments to panic on warning and then a warning is much
> > more important.
> 
> It seems that warning isn't completely valid.
> 
> 
> __alloc_pages_slowpath() handles this more gracefully:
> 
> 	/*
> 	 * In the slowpath, we sanity check order to avoid ever trying to
> 	 * reclaim >= MAX_ORDER areas which will never succeed. Callers may
> 	 * be using allocators in order of preference for an area that is
> 	 * too large.
> 	 */
> 	if (order >= MAX_ORDER) {
> 		WARN_ON_ONCE(!(gfp_mask & __GFP_NOWARN));
> 		return NULL;
> 	}
> 
> 
> Fast path is ready for order >= MAX_ORDER
> 
> 
> Problem is in node_reclaim() which is called earlier than __alloc_pages_slowpath()
> from surprising place - get_page_from_freelist()
> 
> 
> Probably node_reclaim() simply needs something like this:
> 
> 	if (order >= MAX_ORDER)
> 		return NODE_RECLAIM_NOSCAN;

Maybe but the point is that triggering this warning is possible. Even if
the warning is bogus it doesn't really make much sense to even try
kmalloc if the size is not supported by the allocator.

-- 
Michal Hocko
SUSE Labs

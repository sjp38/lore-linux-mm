Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ea0-f181.google.com (mail-ea0-f181.google.com [209.85.215.181])
	by kanga.kvack.org (Postfix) with ESMTP id B44676B003B
	for <linux-mm@kvack.org>; Tue, 17 Dec 2013 11:06:09 -0500 (EST)
Received: by mail-ea0-f181.google.com with SMTP id m10so2969573eaj.26
        for <linux-mm@kvack.org>; Tue, 17 Dec 2013 08:06:09 -0800 (PST)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id e48si5303636eeh.218.2013.12.17.08.06.08
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Tue, 17 Dec 2013 08:06:08 -0800 (PST)
Date: Tue, 17 Dec 2013 16:06:06 +0000
From: Mel Gorman <mgorman@suse.de>
Subject: Re: [PATCH 6/7] mm: page_alloc: Only account batch allocations
 requests that are eligible
Message-ID: <20131217160606.GE11295@suse.de>
References: <1386943807-29601-1-git-send-email-mgorman@suse.de>
 <1386943807-29601-7-git-send-email-mgorman@suse.de>
 <20131216205237.GB21724@cmpxchg.org>
 <20131217112007.GA11295@suse.de>
 <20131217154351.GD21724@cmpxchg.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20131217154351.GD21724@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Dave Hansen <dave.hansen@intel.com>, Rik van Riel <riel@redhat.com>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On Tue, Dec 17, 2013 at 10:43:51AM -0500, Johannes Weiner wrote:
> On Tue, Dec 17, 2013 at 11:20:07AM +0000, Mel Gorman wrote:
> > On Mon, Dec 16, 2013 at 03:52:37PM -0500, Johannes Weiner wrote:
> > > On Fri, Dec 13, 2013 at 02:10:06PM +0000, Mel Gorman wrote:
> > > > Not signed off. Johannes, was the intent really to decrement the batch
> > > > counts regardless of whether the policy was being enforced or not?
> > > 
> > > Yes.  Bursts of allocations for which the policy does not get enforced
> > > will still create memory pressure and affect cache aging on a given
> > > node.  So even if we only distribute page cache, we want to distribute
> > > it in a way that all allocations on the eligible zones equal out.
> > 
> > This means that allocations for page table pages affects the distribution of
> > page cache pages. An adverse workload could time when it faults anonymous
> > pages (to allocate anon and page table pages) in batch sequences and then
> > access files to force page cache pages to be allocated from a single node.
> > 
> > I think I know what your response will be. It will be that the utilisation of
> > the zone for page table pages and anon pages means that you want more page
> > cache pages to be allocated from the other zones so the reclaim pressure
> > is still more or less even. If this is the case or there is another reason
> > then it could have done with a comment because it's a subtle detail.
> 
> Yes, that was the idea, that the cache placement compensates for pages
> that still are always allocated on the preferred zone first, so that
> the end result is approximately as if round-robin had been applied to
> everybody.
> 

Ok, understood. I wanted to be sure that was the thinking behind it.

> This should be documented as part of the patch that first diverges
> between the allocations that are counted and the allocations that are
> round-robined:
> 
>   mm: page_alloc: exclude unreclaimable allocations from zone fairness policy
> 
> I'm updating my tree.

I'll leave it alone in mine then. We'll figure out how to sync up later.

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

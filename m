Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-bk0-f54.google.com (mail-bk0-f54.google.com [209.85.214.54])
	by kanga.kvack.org (Postfix) with ESMTP id CCED96B003D
	for <linux-mm@kvack.org>; Tue, 17 Dec 2013 10:43:59 -0500 (EST)
Received: by mail-bk0-f54.google.com with SMTP id v16so2925306bkz.27
        for <linux-mm@kvack.org>; Tue, 17 Dec 2013 07:43:59 -0800 (PST)
Received: from zene.cmpxchg.org (zene.cmpxchg.org. [2a01:238:4224:fa00:ca1f:9ef3:caee:a2bd])
        by mx.google.com with ESMTPS id dg6si5497007bkc.330.2013.12.17.07.43.58
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Tue, 17 Dec 2013 07:43:58 -0800 (PST)
Date: Tue, 17 Dec 2013 10:43:51 -0500
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [PATCH 6/7] mm: page_alloc: Only account batch allocations
 requests that are eligible
Message-ID: <20131217154351.GD21724@cmpxchg.org>
References: <1386943807-29601-1-git-send-email-mgorman@suse.de>
 <1386943807-29601-7-git-send-email-mgorman@suse.de>
 <20131216205237.GB21724@cmpxchg.org>
 <20131217112007.GA11295@suse.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20131217112007.GA11295@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: Andrew Morton <akpm@linux-foundation.org>, Dave Hansen <dave.hansen@intel.com>, Rik van Riel <riel@redhat.com>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On Tue, Dec 17, 2013 at 11:20:07AM +0000, Mel Gorman wrote:
> On Mon, Dec 16, 2013 at 03:52:37PM -0500, Johannes Weiner wrote:
> > On Fri, Dec 13, 2013 at 02:10:06PM +0000, Mel Gorman wrote:
> > > Not signed off. Johannes, was the intent really to decrement the batch
> > > counts regardless of whether the policy was being enforced or not?
> > 
> > Yes.  Bursts of allocations for which the policy does not get enforced
> > will still create memory pressure and affect cache aging on a given
> > node.  So even if we only distribute page cache, we want to distribute
> > it in a way that all allocations on the eligible zones equal out.
> 
> This means that allocations for page table pages affects the distribution of
> page cache pages. An adverse workload could time when it faults anonymous
> pages (to allocate anon and page table pages) in batch sequences and then
> access files to force page cache pages to be allocated from a single node.
> 
> I think I know what your response will be. It will be that the utilisation of
> the zone for page table pages and anon pages means that you want more page
> cache pages to be allocated from the other zones so the reclaim pressure
> is still more or less even. If this is the case or there is another reason
> then it could have done with a comment because it's a subtle detail.

Yes, that was the idea, that the cache placement compensates for pages
that still are always allocated on the preferred zone first, so that
the end result is approximately as if round-robin had been applied to
everybody.

This should be documented as part of the patch that first diverges
between the allocations that are counted and the allocations that are
round-robined:

  mm: page_alloc: exclude unreclaimable allocations from zone fairness policy

I'm updating my tree.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

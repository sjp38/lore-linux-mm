Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg1-f200.google.com (mail-pg1-f200.google.com [209.85.215.200])
	by kanga.kvack.org (Postfix) with ESMTP id 961E66B0367
	for <linux-mm@kvack.org>; Mon, 29 Oct 2018 05:43:01 -0400 (EDT)
Received: by mail-pg1-f200.google.com with SMTP id q26-v6so2996864pgk.19
        for <linux-mm@kvack.org>; Mon, 29 Oct 2018 02:43:01 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id j32-v6sor17758425pgj.16.2018.10.29.02.43.00
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 29 Oct 2018 02:43:00 -0700 (PDT)
Date: Mon, 29 Oct 2018 20:42:53 +1100
From: Balbir Singh <bsingharora@gmail.com>
Subject: Re: [PATCH 1/2] mm: thp:  relax __GFP_THISNODE for MADV_HUGEPAGE
 mappings
Message-ID: <20181029094253.GC16399@350D>
References: <20180925120326.24392-1-mhocko@kernel.org>
 <20180925120326.24392-2-mhocko@kernel.org>
 <20181029051752.GB16399@350D>
 <20181029090035.GE32673@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20181029090035.GE32673@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, Vlastimil Babka <vbabka@suse.cz>, David Rientjes <rientjes@google.com>, Andrea Argangeli <andrea@kernel.org>, Zi Yan <zi.yan@cs.rutgers.edu>, Stefan Priebe - Profihost AG <s.priebe@profihost.ag>, "Kirill A. Shutemov" <kirill@shutemov.name>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>, Andrea Arcangeli <aarcange@redhat.com>, Stable tree <stable@vger.kernel.org>

On Mon, Oct 29, 2018 at 10:00:35AM +0100, Michal Hocko wrote:
> On Mon 29-10-18 16:17:52, Balbir Singh wrote:
> [...]
> > I wonder if alloc_pool_huge_page() should also trim out it's logic
> > of __GFP_THISNODE for the same reasons as mentioned here. I like
> > that we round robin to alloc the pool pages, but __GFP_THISNODE
> > might be an overkill for that case as well.
> 
> alloc_pool_huge_page uses __GFP_THISNODE for a different reason than
> THP. We really do want to allocated for a per-node pool. THP can
> fallback or use a different node.
> 

Not really

static int alloc_pool_huge_page(struct hstate *h, nodemask_t *nodes_allowed)
...
        gfp_t gfp_mask = htlb_alloc_mask(h) | __GFP_THISNODE;
...
        for_each_node_mask_to_alloc(h, nr_nodes, node, nodes_allowed) {
                page = alloc_fresh_huge_page(h, gfp_mask, node, nodes_allowed);
                if (page)
                        break;
        }


The code just tries to distribute the pool

> These hugetlb allocations might be disruptive and that is an expected
> behavior because this is an explicit requirement from an admin to
> pre-allocate large pages for the future use. __GFP_RETRY_MAYFAIL just
> underlines that requirement.

Yes, but in the absence of a particular node, for example via sysctl
(as the compaction does), I don't think it is a hard requirement to get
a page from a particular node. I agree we need __GFP_RETRY_FAIL, in any
case the real root cause for me is should_reclaim_continue() which keeps
the task looping without making forward progress.

The __GFP_THISNODE was again an example of mis-leading the allocator
in this case, IMHO.

> 
> Maybe the compaction logic could be improved and that might be a shared
> goal with future changes though.

I'll also send my RFC once my testing is done, assuming I get it to reproduce
with a desired frequency.

Balbir Singh.

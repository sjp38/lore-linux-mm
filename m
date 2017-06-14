Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f199.google.com (mail-wr0-f199.google.com [209.85.128.199])
	by kanga.kvack.org (Postfix) with ESMTP id AE4776B0279
	for <linux-mm@kvack.org>; Wed, 14 Jun 2017 11:28:18 -0400 (EDT)
Received: by mail-wr0-f199.google.com with SMTP id q97so1058478wrb.14
        for <linux-mm@kvack.org>; Wed, 14 Jun 2017 08:28:18 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id u48si335081wrc.243.2017.06.14.08.28.16
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 14 Jun 2017 08:28:16 -0700 (PDT)
Date: Wed, 14 Jun 2017 17:28:14 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [RFC PATCH 1/4] mm, hugetlb: unclutter hugetlb allocation layers
Message-ID: <20170614152813.GR6045@dhcp22.suse.cz>
References: <20170613090039.14393-1-mhocko@kernel.org>
 <20170613090039.14393-2-mhocko@kernel.org>
 <1babcd50-a90e-a3e4-c45c-85b1b8b93171@suse.cz>
 <20170614134258.GP6045@dhcp22.suse.cz>
 <115a973d-6ede-7fcf-d1c6-8a62194cff59@suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <115a973d-6ede-7fcf-d1c6-8a62194cff59@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: linux-mm@kvack.org, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Mike Kravetz <mike.kravetz@oracle.com>, Mel Gorman <mgorman@suse.de>, Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>

On Wed 14-06-17 17:06:47, Vlastimil Babka wrote:
> On 06/14/2017 03:42 PM, Michal Hocko wrote:
> > On Wed 14-06-17 15:18:26, Vlastimil Babka wrote:
> >> On 06/13/2017 11:00 AM, Michal Hocko wrote:
> > [...]
> >>> @@ -1717,13 +1640,22 @@ struct page *alloc_huge_page_node(struct hstate *h, int nid)
> >>>  		page = dequeue_huge_page_node(h, nid);
> >>>  	spin_unlock(&hugetlb_lock);
> >>>  
> >>> -	if (!page)
> >>> -		page = __alloc_buddy_huge_page_no_mpol(h, nid);
> >>> +	if (!page) {
> >>> +		nodemask_t nmask;
> >>> +
> >>> +		if (nid != NUMA_NO_NODE) {
> >>> +			nmask = NODE_MASK_NONE;
> >>> +			node_set(nid, nmask);
> >>
> >> TBH I don't like this hack too much, and would rather see __GFP_THISNODE
> >> involved, which picks a different (short) zonelist. Also it's allocating
> >> nodemask on stack, which we generally avoid? Although the callers
> >> currently seem to be shallow.
> > 
> > Fair enough. That would require pulling gfp mask handling up the call
> > chain. This on top of this patch + refreshes for other patches later in
> > the series as they will conflict now?
> 
> For the orig patch + fold (squashed locally from your mmotm/... branch)
> 
> Acked-by: Vlastimil Babka <vbabka@suse.cz>

Thanks!

> Please update the commit description which still mentions the nodemask
> emulation of __GFP_THISNODE.

yes I will do that when squashing them.

> Also I noticed that the goal of patch 2 is already partially achieved
> here, because alloc_huge_page_nodemask() will now allocate using
> zonelist. It won't dequeue that way yet, though.

well, the primary point if the later is to allow for the preferred node.
I didn't find a proper way to split the two things and still have a
reasonably comprehensible diff. So I've focused on the real allocation
here and pools in the other patch. Hope that makes some sense.
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

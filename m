Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f49.google.com (mail-pa0-f49.google.com [209.85.220.49])
	by kanga.kvack.org (Postfix) with ESMTP id 0ACA39003C7
	for <linux-mm@kvack.org>; Fri, 24 Jul 2015 01:28:54 -0400 (EDT)
Received: by pachj5 with SMTP id hj5so8274962pac.3
        for <linux-mm@kvack.org>; Thu, 23 Jul 2015 22:28:53 -0700 (PDT)
Received: from lgeamrelo01.lge.com (lgeamrelo01.lge.com. [156.147.1.125])
        by mx.google.com with ESMTP id bd3si3195816pdb.117.2015.07.23.22.28.51
        for <linux-mm@kvack.org>;
        Thu, 23 Jul 2015 22:28:52 -0700 (PDT)
Date: Fri, 24 Jul 2015 14:33:19 +0900
From: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Subject: Re: [RFC 1/4] mm, compaction: introduce kcompactd
Message-ID: <20150724053319.GA11135@js1304-P5Q-DELUXE>
References: <1435826795-13777-1-git-send-email-vbabka@suse.cz>
 <1435826795-13777-2-git-send-email-vbabka@suse.cz>
 <alpine.DEB.2.10.1507091439100.17177@chino.kir.corp.google.com>
 <20150723060348.GF4449@js1304-P5Q-DELUXE>
 <alpine.DEB.2.10.1507231353400.31024@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.10.1507231353400.31024@chino.kir.corp.google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: Vlastimil Babka <vbabka@suse.cz>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Hugh Dickins <hughd@google.com>, Andrea Arcangeli <aarcange@redhat.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Rik van Riel <riel@redhat.com>, Mel Gorman <mgorman@suse.de>

On Thu, Jul 23, 2015 at 01:58:20PM -0700, David Rientjes wrote:
> On Thu, 23 Jul 2015, Joonsoo Kim wrote:
> 
> > > The slub allocator does try to allocate its high-order memory with 
> > > __GFP_WAIT before falling back to lower orders if possible.  I would think 
> > > that this would be the greatest sign of on-demand memory compaction being 
> > > a problem, especially since CONFIG_SLUB is the default, but I haven't seen 
> > > such reports.
> > 
> > In fact, some of our product had trouble with slub's high order
> > allocation 5 months ago. At that time, compaction didn't make high order
> > page and compaction attempts are frequently deferred. It also causes many
> > reclaim to make high order page so I suggested masking out __GFP_WAIT
> > and adding __GFP_NO_KSWAPD when trying slub's high order allocation to
> > reduce reclaim/compaction overhead. Although using high order page in slub
> > has some gains that reducing internal fragmentation and reducing management
> > overhead, benefit is marginal compared to the cost at making high order
> > page. This solution improves system response time for our case. I planned
> > to submit the patch but it is delayed due to my laziness. :)
> > 
> 
> Hi Joonsoo,

Hello David.

> 
> On a fragmented machine I can certainly understand that the overhead 
> involved in allocating the high-order page outweighs the benefit later and 
> it's better to fallback more quickly to page orders if the cache allows 
> it.
> 
> I believe that this would be improved by the suggestion of doing 
> background synchronous compaction.  So regardless of whether __GFP_WAIT is 
> set, if the allocation fails then we can kick off background compaction 
> that will hopefully defragment memory for future callers.  That should 
> make high-order atomic allocations more successful as well.

Yep! I also think __GFP_NO_KSWAPD isn't appropriate for general case.
Reason I suggested __GFP_NO_KSWAPD to our system is that reclaim/compaction
continually fails to make high order page so we don't want to invoke
reclaim/compaction even though it works in background. But, on almost of
other system, reclaim/compaction could succeed so adding __GFP_NO_KSWAPD
doens't make sense for general case.

Thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

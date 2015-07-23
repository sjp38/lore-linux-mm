Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f173.google.com (mail-pd0-f173.google.com [209.85.192.173])
	by kanga.kvack.org (Postfix) with ESMTP id F2D7C6B025C
	for <linux-mm@kvack.org>; Thu, 23 Jul 2015 16:58:23 -0400 (EDT)
Received: by pdrg1 with SMTP id g1so1894248pdr.2
        for <linux-mm@kvack.org>; Thu, 23 Jul 2015 13:58:23 -0700 (PDT)
Received: from mail-pd0-x22d.google.com (mail-pd0-x22d.google.com. [2607:f8b0:400e:c02::22d])
        by mx.google.com with ESMTPS id t6si14818596pdm.24.2015.07.23.13.58.22
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 23 Jul 2015 13:58:23 -0700 (PDT)
Received: by pdbnt7 with SMTP id nt7so1927010pdb.0
        for <linux-mm@kvack.org>; Thu, 23 Jul 2015 13:58:22 -0700 (PDT)
Date: Thu, 23 Jul 2015 13:58:20 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [RFC 1/4] mm, compaction: introduce kcompactd
In-Reply-To: <20150723060348.GF4449@js1304-P5Q-DELUXE>
Message-ID: <alpine.DEB.2.10.1507231353400.31024@chino.kir.corp.google.com>
References: <1435826795-13777-1-git-send-email-vbabka@suse.cz> <1435826795-13777-2-git-send-email-vbabka@suse.cz> <alpine.DEB.2.10.1507091439100.17177@chino.kir.corp.google.com> <20150723060348.GF4449@js1304-P5Q-DELUXE>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Cc: Vlastimil Babka <vbabka@suse.cz>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Hugh Dickins <hughd@google.com>, Andrea Arcangeli <aarcange@redhat.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Rik van Riel <riel@redhat.com>, Mel Gorman <mgorman@suse.de>

On Thu, 23 Jul 2015, Joonsoo Kim wrote:

> > The slub allocator does try to allocate its high-order memory with 
> > __GFP_WAIT before falling back to lower orders if possible.  I would think 
> > that this would be the greatest sign of on-demand memory compaction being 
> > a problem, especially since CONFIG_SLUB is the default, but I haven't seen 
> > such reports.
> 
> In fact, some of our product had trouble with slub's high order
> allocation 5 months ago. At that time, compaction didn't make high order
> page and compaction attempts are frequently deferred. It also causes many
> reclaim to make high order page so I suggested masking out __GFP_WAIT
> and adding __GFP_NO_KSWAPD when trying slub's high order allocation to
> reduce reclaim/compaction overhead. Although using high order page in slub
> has some gains that reducing internal fragmentation and reducing management
> overhead, benefit is marginal compared to the cost at making high order
> page. This solution improves system response time for our case. I planned
> to submit the patch but it is delayed due to my laziness. :)
> 

Hi Joonsoo,

On a fragmented machine I can certainly understand that the overhead 
involved in allocating the high-order page outweighs the benefit later and 
it's better to fallback more quickly to page orders if the cache allows 
it.

I believe that this would be improved by the suggestion of doing 
background synchronous compaction.  So regardless of whether __GFP_WAIT is 
set, if the allocation fails then we can kick off background compaction 
that will hopefully defragment memory for future callers.  That should 
make high-order atomic allocations more successful as well.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f71.google.com (mail-pl0-f71.google.com [209.85.160.71])
	by kanga.kvack.org (Postfix) with ESMTP id D7D2D6B0009
	for <linux-mm@kvack.org>; Mon, 12 Mar 2018 23:34:16 -0400 (EDT)
Received: by mail-pl0-f71.google.com with SMTP id o61-v6so9578194pld.5
        for <linux-mm@kvack.org>; Mon, 12 Mar 2018 20:34:16 -0700 (PDT)
Received: from mga02.intel.com (mga02.intel.com. [134.134.136.20])
        by mx.google.com with ESMTPS id k17si6554549pff.157.2018.03.12.20.34.15
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 12 Mar 2018 20:34:15 -0700 (PDT)
Date: Tue, 13 Mar 2018 11:35:19 +0800
From: Aaron Lu <aaron.lu@intel.com>
Subject: Re: [PATCH v4 3/3 update] mm/free_pcppages_bulk: prefetch buddy
 while not holding lock
Message-ID: <20180313033519.GC13782@intel.com>
References: <20180301062845.26038-1-aaron.lu@intel.com>
 <20180301062845.26038-4-aaron.lu@intel.com>
 <20180301160950.b561d6b8b561217bad511229@linux-foundation.org>
 <20180302082756.GC6356@intel.com>
 <20180309082431.GB30868@intel.com>
 <988ce376-bdc4-0989-5133-612bfa3f7c45@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <988ce376-bdc4-0989-5133-612bfa3f7c45@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave.hansen@intel.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Huang Ying <ying.huang@intel.com>, Kemi Wang <kemi.wang@intel.com>, Tim Chen <tim.c.chen@linux.intel.com>, Andi Kleen <ak@linux.intel.com>, Michal Hocko <mhocko@suse.com>, Vlastimil Babka <vbabka@suse.cz>, Mel Gorman <mgorman@techsingularity.net>, Matthew Wilcox <willy@infradead.org>, David Rientjes <rientjes@google.com>

On Mon, Mar 12, 2018 at 10:32:32AM -0700, Dave Hansen wrote:
> On 03/09/2018 12:24 AM, Aaron Lu wrote:
> > +			/*
> > +			 * We are going to put the page back to the global
> > +			 * pool, prefetch its buddy to speed up later access
> > +			 * under zone->lock. It is believed the overhead of
> > +			 * an additional test and calculating buddy_pfn here
> > +			 * can be offset by reduced memory latency later. To
> > +			 * avoid excessive prefetching due to large count, only
> > +			 * prefetch buddy for the last pcp->batch nr of pages.
> > +			 */
> > +			if (count > pcp->batch)
> > +				continue;
> > +			pfn = page_to_pfn(page);
> > +			buddy_pfn = __find_buddy_pfn(pfn, 0);
> > +			buddy = page + (buddy_pfn - pfn);
> > +			prefetch(buddy);
> 
> FWIW, I think this needs to go into a helper function.  Is that possible?

I'll give it a try.

> 
> There's too much logic happening here.  Also, 'count' going from
> batch_size->0 is totally non-obvious from the patch context.  It makes
> this hunk look totally wrong by itself.

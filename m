Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f69.google.com (mail-pl0-f69.google.com [209.85.160.69])
	by kanga.kvack.org (Postfix) with ESMTP id 318C26B000E
	for <linux-mm@kvack.org>; Mon, 12 Mar 2018 13:32:40 -0400 (EDT)
Received: by mail-pl0-f69.google.com with SMTP id b4-v6so2676263plx.20
        for <linux-mm@kvack.org>; Mon, 12 Mar 2018 10:32:40 -0700 (PDT)
Received: from mga09.intel.com (mga09.intel.com. [134.134.136.24])
        by mx.google.com with ESMTPS id h2-v6si6437747pls.270.2018.03.12.10.32.38
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 12 Mar 2018 10:32:38 -0700 (PDT)
Subject: Re: [PATCH v4 3/3 update] mm/free_pcppages_bulk: prefetch buddy while
 not holding lock
References: <20180301062845.26038-1-aaron.lu@intel.com>
 <20180301062845.26038-4-aaron.lu@intel.com>
 <20180301160950.b561d6b8b561217bad511229@linux-foundation.org>
 <20180302082756.GC6356@intel.com> <20180309082431.GB30868@intel.com>
From: Dave Hansen <dave.hansen@intel.com>
Message-ID: <988ce376-bdc4-0989-5133-612bfa3f7c45@intel.com>
Date: Mon, 12 Mar 2018 10:32:32 -0700
MIME-Version: 1.0
In-Reply-To: <20180309082431.GB30868@intel.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Aaron Lu <aaron.lu@intel.com>, Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Huang Ying <ying.huang@intel.com>, Kemi Wang <kemi.wang@intel.com>, Tim Chen <tim.c.chen@linux.intel.com>, Andi Kleen <ak@linux.intel.com>, Michal Hocko <mhocko@suse.com>, Vlastimil Babka <vbabka@suse.cz>, Mel Gorman <mgorman@techsingularity.net>, Matthew Wilcox <willy@infradead.org>, David Rientjes <rientjes@google.com>

On 03/09/2018 12:24 AM, Aaron Lu wrote:
> +			/*
> +			 * We are going to put the page back to the global
> +			 * pool, prefetch its buddy to speed up later access
> +			 * under zone->lock. It is believed the overhead of
> +			 * an additional test and calculating buddy_pfn here
> +			 * can be offset by reduced memory latency later. To
> +			 * avoid excessive prefetching due to large count, only
> +			 * prefetch buddy for the last pcp->batch nr of pages.
> +			 */
> +			if (count > pcp->batch)
> +				continue;
> +			pfn = page_to_pfn(page);
> +			buddy_pfn = __find_buddy_pfn(pfn, 0);
> +			buddy = page + (buddy_pfn - pfn);
> +			prefetch(buddy);

FWIW, I think this needs to go into a helper function.  Is that possible?

There's too much logic happening here.  Also, 'count' going from
batch_size->0 is totally non-obvious from the patch context.  It makes
this hunk look totally wrong by itself.

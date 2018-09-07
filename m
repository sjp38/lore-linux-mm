Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f72.google.com (mail-ed1-f72.google.com [209.85.208.72])
	by kanga.kvack.org (Postfix) with ESMTP id 693806B7E33
	for <linux-mm@kvack.org>; Fri,  7 Sep 2018 08:16:19 -0400 (EDT)
Received: by mail-ed1-f72.google.com with SMTP id c25-v6so4642894edb.12
        for <linux-mm@kvack.org>; Fri, 07 Sep 2018 05:16:19 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id 7-v6si1278970edm.229.2018.09.07.05.16.17
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 07 Sep 2018 05:16:18 -0700 (PDT)
Subject: Re: [RFC PATCH] mm, page_alloc: drop should_suppress_show_mem
References: <20180907114334.7088-1-mhocko@kernel.org>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <188ef8c6-262c-cead-6f78-ebda0978cce6@suse.cz>
Date: Fri, 7 Sep 2018 14:16:16 +0200
MIME-Version: 1.0
In-Reply-To: <20180907114334.7088-1-mhocko@kernel.org>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>, linux-mm@kvack.org
Cc: Andrew Morton <akpm@linux-foundation.org>, David Rientjes <rientjes@google.com>, Mel Gorman <mgorman@suse.de>, LKML <linux-kernel@vger.kernel.org>, Michal Hocko <mhocko@suse.com>

On 09/07/2018 01:43 PM, Michal Hocko wrote:
> From: Michal Hocko <mhocko@suse.com>
> 
> should_suppress_show_mem has been introduced to reduce the overhead of
> show_mem on large NUMA systems. Things have changed since then though.
> Namely c78e93630d15 ("mm: do not walk all of system memory during
> show_mem") has reduced the overhead considerably.
> 
> Moreover warn_alloc_show_mem clears SHOW_MEM_FILTER_NODES when called
> from the IRQ context already so we are not printing per node stats.
> 
> Remove should_suppress_show_mem because we are losing potentially
> interesting information about allocation failures. We have seen a bug
> report where system gets unresponsive under memory pressure and there
> is only
> kernel: [2032243.696888] qlge 0000:8b:00.1 ql1: Could not get a page chunk, i=8, clean_idx =200 .
> kernel: [2032243.710725] swapper/7: page allocation failure: order:1, mode:0x1084120(GFP_ATOMIC|__GFP_COLD|__GFP_COMP)
> 
> without an additional information for debugging. It would be great to
> see the state of the page allocator at the moment.
> 
> Signed-off-by: Michal Hocko <mhocko@suse.com>

Acked-by: Vlastimil Babka <vbabka@suse.cz>

The dependency on build-time constant instead of real system size is
also unfortunate. Maybe the time was depending on *possible* nodes in
the past, but I don't think it's the case today.

Thanks.

Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f69.google.com (mail-pa0-f69.google.com [209.85.220.69])
	by kanga.kvack.org (Postfix) with ESMTP id 5BE086B0005
	for <linux-mm@kvack.org>; Tue, 19 Jul 2016 19:10:39 -0400 (EDT)
Received: by mail-pa0-f69.google.com with SMTP id ez1so54990080pab.0
        for <linux-mm@kvack.org>; Tue, 19 Jul 2016 16:10:39 -0700 (PDT)
Received: from mail-pa0-x229.google.com (mail-pa0-x229.google.com. [2607:f8b0:400e:c03::229])
        by mx.google.com with ESMTPS id jj1si34980464pac.71.2016.07.19.16.10.38
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 19 Jul 2016 16:10:38 -0700 (PDT)
Received: by mail-pa0-x229.google.com with SMTP id fi15so11418013pac.1
        for <linux-mm@kvack.org>; Tue, 19 Jul 2016 16:10:38 -0700 (PDT)
Date: Tue, 19 Jul 2016 16:10:31 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH 5/8] mm, page_alloc: make THP-specific decisions more
 generic
In-Reply-To: <20160718112302.27381-6-vbabka@suse.cz>
Message-ID: <alpine.DEB.2.10.1607191608550.19940@chino.kir.corp.google.com>
References: <20160718112302.27381-1-vbabka@suse.cz> <20160718112302.27381-6-vbabka@suse.cz>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Michal Hocko <mhocko@kernel.org>, Mel Gorman <mgorman@techsingularity.net>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Rik van Riel <riel@redhat.com>

On Mon, 18 Jul 2016, Vlastimil Babka wrote:

> Since THP allocations during page faults can be costly, extra decisions are
> employed for them to avoid excessive reclaim and compaction, if the initial
> compaction doesn't look promising. The detection has never been perfect as
> there is no gfp flag specific to THP allocations. At this moment it checks the
> whole combination of flags that makes up GFP_TRANSHUGE, and hopes that no other
> users of such combination exist, or would mind being treated the same way.
> Extra care is also taken to separate allocations from khugepaged, where latency
> doesn't matter that much.
> 
> It is however possible to distinguish these allocations in a simpler and more
> reliable way. The key observation is that after the initial compaction followed
> by the first iteration of "standard" reclaim/compaction, both __GFP_NORETRY
> allocations and costly allocations without __GFP_REPEAT are declared as
> failures:
> 
>         /* Do not loop if specifically requested */
>         if (gfp_mask & __GFP_NORETRY)
>                 goto nopage;
> 
>         /*
>          * Do not retry costly high order allocations unless they are
>          * __GFP_REPEAT
>          */
>         if (order > PAGE_ALLOC_COSTLY_ORDER && !(gfp_mask & __GFP_REPEAT))
>                 goto nopage;
> 
> This means we can further distinguish allocations that are costly order *and*
> additionally include the __GFP_NORETRY flag. As it happens, GFP_TRANSHUGE
> allocations do already fall into this category. This will also allow other
> costly allocations with similar high-order benefit vs latency considerations to
> use this semantic. Furthermore, we can distinguish THP allocations that should
> try a bit harder (such as from khugepageed) by removing __GFP_NORETRY, as will
> be done in the next patch.
> 
> Signed-off-by: Vlastimil Babka <vbabka@suse.cz>
> Acked-by: Michal Hocko <mhocko@suse.com>

I think this is fine, but I would hope that we could check 
gfp_pfmemalloc_allowed() before compacting and failing even for costly 
orders when otherwise the first get_page_from_freelist() in the slowpath 
may have succeeded due to watermarks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

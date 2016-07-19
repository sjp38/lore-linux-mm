Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f72.google.com (mail-pa0-f72.google.com [209.85.220.72])
	by kanga.kvack.org (Postfix) with ESMTP id 0480D6B0005
	for <linux-mm@kvack.org>; Tue, 19 Jul 2016 18:28:24 -0400 (EDT)
Received: by mail-pa0-f72.google.com with SMTP id ez1so53464563pab.0
        for <linux-mm@kvack.org>; Tue, 19 Jul 2016 15:28:23 -0700 (PDT)
Received: from mail-pa0-x231.google.com (mail-pa0-x231.google.com. [2607:f8b0:400e:c03::231])
        by mx.google.com with ESMTPS id i1si11536538pfj.61.2016.07.19.15.28.23
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 19 Jul 2016 15:28:23 -0700 (PDT)
Received: by mail-pa0-x231.google.com with SMTP id ks6so11134369pab.0
        for <linux-mm@kvack.org>; Tue, 19 Jul 2016 15:28:23 -0700 (PDT)
Date: Tue, 19 Jul 2016 15:28:16 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH 2/8] mm, page_alloc: set alloc_flags only once in
 slowpath
In-Reply-To: <20160718112302.27381-3-vbabka@suse.cz>
Message-ID: <alpine.DEB.2.10.1607191527400.19940@chino.kir.corp.google.com>
References: <20160718112302.27381-1-vbabka@suse.cz> <20160718112302.27381-3-vbabka@suse.cz>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Michal Hocko <mhocko@kernel.org>, Mel Gorman <mgorman@techsingularity.net>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Rik van Riel <riel@redhat.com>

On Mon, 18 Jul 2016, Vlastimil Babka wrote:

> In __alloc_pages_slowpath(), alloc_flags doesn't change after it's initialized,
> so move the initialization above the retry: label. Also make the comment above
> the initialization more descriptive.
> 
> The only exception in the alloc_flags being constant is ALLOC_NO_WATERMARKS,
> which may change due to TIF_MEMDIE being set on the allocating thread. We can
> fix this, and make the code simpler and a bit more effective at the same time,
> by moving the part that determines ALLOC_NO_WATERMARKS from
> gfp_to_alloc_flags() to gfp_pfmemalloc_allowed(). This means we don't have to
> mask out ALLOC_NO_WATERMARKS in numerous places in __alloc_pages_slowpath()
> anymore. The only two tests for the flag can instead call
> gfp_pfmemalloc_allowed().
> 
> Signed-off-by: Vlastimil Babka <vbabka@suse.cz>

Acked-by: David Rientjes <rientjes@google.com>

Looks good, although maybe a new name for gfp_pfmemalloc_allowed() would 
be in order.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-la0-f47.google.com (mail-la0-f47.google.com [209.85.215.47])
	by kanga.kvack.org (Postfix) with ESMTP id C93D96B0037
	for <linux-mm@kvack.org>; Tue,  2 Sep 2014 09:51:36 -0400 (EDT)
Received: by mail-la0-f47.google.com with SMTP id s18so7930741lam.34
        for <linux-mm@kvack.org>; Tue, 02 Sep 2014 06:51:36 -0700 (PDT)
Received: from zene.cmpxchg.org (zene.cmpxchg.org. [2a01:238:4224:fa00:ca1f:9ef3:caee:a2bd])
        by mx.google.com with ESMTPS id cq5si4967484lad.126.2014.09.02.06.51.34
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Tue, 02 Sep 2014 06:51:34 -0700 (PDT)
Date: Tue, 2 Sep 2014 09:51:20 -0400
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [PATCH] mm: page_alloc: Default to node-ordering on 64-bit NUMA
 machines
Message-ID: <20140902135120.GC29501@cmpxchg.org>
References: <20140901125551.GI12424@suse.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20140901125551.GI12424@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>, David Rientjes <rientjes@google.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Fengguang Wu <fengguang.wu@intel.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Mon, Sep 01, 2014 at 01:55:51PM +0100, Mel Gorman wrote:
> Zones are allocated by the page allocator in either node or zone order.
> Node ordering is preferred in terms of locality and is applied automatically
> in one of three cases.
> 
>   1. If a node has only low memory
> 
>   2. If DMA/DMA32 is a high percentage of memory
> 
>   3. If low memory on a single node is greater than 70% of the node size
> 
> Otherwise zone ordering is used to preserve low memory. Unfortunately
> a consequence of this is that a machine with balanced NUMA nodes will
> experience different performance characteristics depending on which node
> they happen to start from.
> 
> The point of zone ordering is to protect lower nodes for devices that require
> DMA/DMA32 memory. When NUMA was first introduced, this was critical as 32-bit
> NUMA machines commonly suffered from low memory exhaustion problems. On
> 64-bit machines the primary concern is devices that are 32-bit only which
> is less severe than the low memory exhaustion problem on 32-bit NUMA. It
> seems there are really few devices that depends on it.
> 
> AGP -- I assume this is getting more rare but even then I think the allocations
> 	happen early in boot time where lowmem pressure is less of a problem
> 
> DRM -- If the device is 32-bit only then there may be low pressure. I didn't
> 	evaluate these in detail but it looks like some of these are mobile
> 	graphics card. Not many NUMA laptops out there. DRM folk should know
> 	better though.
> 
> Some TV cards -- Much demand for 32-bit capable TV cards on NUMA machines?
> 
> B43 wireless card -- again not really a NUMA thing.
> 
> I cannot find a good reason to incur a performance penalty on all 64-bit NUMA
> machines in case someone throws a brain damanged TV or graphics card in there.
> This patch defaults to node-ordering on 64-bit NUMA machines. I was tempted
> to make it default everywhere but I understand that some embedded arches may
> be using 32-bit NUMA where I cannot predict the consequences.

This patch is a step in the right direction, but I'm not too fond of
further fragmenting this code and where it applies, while leaving all
the complexity from the heuristics and the zonelist building in, just
on spec.  Could we at least remove the heuristics too?  If anybody is
affected by this, they can always override the default on the cmdline.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

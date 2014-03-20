Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f46.google.com (mail-wg0-f46.google.com [74.125.82.46])
	by kanga.kvack.org (Postfix) with ESMTP id 3D8536B0256
	for <linux-mm@kvack.org>; Thu, 20 Mar 2014 17:16:24 -0400 (EDT)
Received: by mail-wg0-f46.google.com with SMTP id b13so1043469wgh.5
        for <linux-mm@kvack.org>; Thu, 20 Mar 2014 14:16:23 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTP id c7si2300490wjw.133.2014.03.20.14.16.21
        for <linux-mm@kvack.org>;
        Thu, 20 Mar 2014 14:16:22 -0700 (PDT)
Message-ID: <532B5A39.7050309@redhat.com>
Date: Thu, 20 Mar 2014 17:14:33 -0400
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: [patch] mm: page_alloc: spill to remote nodes before waking kswapd
References: <1395348816-4733-1-git-send-email-hannes@cmpxchg.org>
In-Reply-To: <1395348816-4733-1-git-send-email-hannes@cmpxchg.org>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>, Andrew Morton <akpm@linux-foundation.org>
Cc: Mel Gorman <mgorman@suse.de>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On 03/20/2014 04:53 PM, Johannes Weiner wrote:
> On NUMA systems, a node may start thrashing cache or even swap
> anonymous pages while there are still free pages on remote nodes.
>
> This is a result of 81c0a2bb515f ("mm: page_alloc: fair zone allocator
> policy") and fff4068cba48 ("mm: page_alloc: revert NUMA aspect of fair
> allocation policy").  Before those changes, the allocator would first
> try all allowed zones, including those on remote nodes, before waking
> any kswapds.  But now, the allocator fastpath doubles as the fairness
> pass, which in turn can only consider the local node to prevent remote
> spilling based on exhausted fairness batches alone.  Remote nodes are
> only considered in the slowpath, after the kswapds are woken up.  But
> if remote nodes still have free memory, kswapd should not be woken to
> rebalance the local node or it may thrash cash or swap prematurely.
>
> Fix this by adding one more unfair pass over the zonelist that is
> allowed to spill to remote nodes after the local fairness pass fails
> but before entering the slowpath and waking the kswapds.
>
> This also gets rid of the GFP_THISNODE exemption from the fairness
> protocol because the unfair pass is no longer tied to kswapd, which
> GFP_THISNODE is not allowed to wake up.
>
> However, because remote spills can be more frequent now - we prefer
> them over local kswapd reclaim - the allocation batches on remote
> nodes could underflow more heavily.  When resetting the batches, use
> atomic_long_read() directly instead of zone_page_state() to calculate
> the delta as the latter filters negative counter values.
>
> Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>
> Cc: <stable@kernel.org> [3.12+]

Acked-by: Rik van Riel <riel@redhat.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

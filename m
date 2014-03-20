Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pb0-f45.google.com (mail-pb0-f45.google.com [209.85.160.45])
	by kanga.kvack.org (Postfix) with ESMTP id 7E0786B025A
	for <linux-mm@kvack.org>; Thu, 20 Mar 2014 18:12:36 -0400 (EDT)
Received: by mail-pb0-f45.google.com with SMTP id uo5so1566550pbc.32
        for <linux-mm@kvack.org>; Thu, 20 Mar 2014 15:12:36 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTP id ys6si1602377pab.377.2014.03.20.15.12.01
        for <linux-mm@kvack.org>;
        Thu, 20 Mar 2014 15:12:31 -0700 (PDT)
Date: Thu, 20 Mar 2014 15:11:58 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [patch] mm: page_alloc: spill to remote nodes before waking
 kswapd
Message-Id: <20140320151158.e5cec93960cd0cd00f5b3790@linux-foundation.org>
In-Reply-To: <1395348816-4733-1-git-send-email-hannes@cmpxchg.org>
References: <1395348816-4733-1-git-send-email-hannes@cmpxchg.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Rik van Riel <riel@redhat.com>, Mel Gorman <mgorman@suse.de>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Thu, 20 Mar 2014 16:53:36 -0400 Johannes Weiner <hannes@cmpxchg.org> wrote:

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

I queued this for 3.15-rc1 so it should get backported into 3.14.1 and
earlier.

It doesn't come close to applying to 3.13 or 3.12 so please check into
what needs doing when Greg comes calling.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-we0-f182.google.com (mail-we0-f182.google.com [74.125.82.182])
	by kanga.kvack.org (Postfix) with ESMTP id 5E1DD6B0035
	for <linux-mm@kvack.org>; Fri, 29 Aug 2014 09:09:41 -0400 (EDT)
Received: by mail-we0-f182.google.com with SMTP id w62so2168139wes.13
        for <linux-mm@kvack.org>; Fri, 29 Aug 2014 06:09:40 -0700 (PDT)
Received: from zene.cmpxchg.org (zene.cmpxchg.org. [2a01:238:4224:fa00:ca1f:9ef3:caee:a2bd])
        by mx.google.com with ESMTPS id g2si121349wjw.13.2014.08.29.06.09.38
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Fri, 29 Aug 2014 06:09:39 -0700 (PDT)
Date: Fri, 29 Aug 2014 09:09:25 -0400
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [PATCH] mm: page_alloc: avoid wakeup kswapd on the unintended
 node
Message-ID: <20140829130925.GA9900@cmpxchg.org>
References: <000001cfc357$74db64a0$5e922de0$%yang@samsung.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <000001cfc357$74db64a0$5e922de0$%yang@samsung.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Weijie Yang <weijie.yang@samsung.com>
Cc: 'Mel Gorman' <mgorman@suse.de>, 'Andrew Morton' <akpm@linux-foundation.org>, 'Rik van Riel' <riel@redhat.com>, rientjes@google.com, 'Weijie Yang' <weijie.yang.kh@gmail.com>, 'linux-kernel' <linux-kernel@vger.kernel.org>, 'Linux-MM' <linux-mm@kvack.org>

On Fri, Aug 29, 2014 at 03:03:19PM +0800, Weijie Yang wrote:
> When enter page_alloc slowpath, we wakeup kswapd on every pgdat
> according to the zonelist and high_zoneidx. However, this doesn't
> take nodemask into account, and could prematurely wakeup kswapd on
> some unintended nodes.
> 
> This patch uses for_each_zone_zonelist_nodemask() instead of
> for_each_zone_zonelist() in wake_all_kswapds() to avoid the above situation.
> 
> Signed-off-by: Weijie Yang <weijie.yang@samsung.com>

Wow, we have never respected nodemask when waking kswapd, but your
change does make sense to me.

As far as impact go, this has the chance of reducing reclaim/swapping
for certain configurations.  Higher-order wakeups on an ineligible
zone are more obviously undesirable, but even order-0 rebalancing is
not necessarily a future investment for other allocations on that
node, as other allocations may have access to the free pages of a
third node and overall demand might drop before these are exhausted.
This reminds me of the issue fixed in 3a025760fc15 ("mm: page_alloc:
spill to remote nodes before waking kswapd"), where accidental eager
order-0 rebalancing turned out to be a true waste.

Acked-by: Johannes Weiner <hannes@cmpxchg.org>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

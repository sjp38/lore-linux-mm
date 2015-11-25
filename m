Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f46.google.com (mail-pa0-f46.google.com [209.85.220.46])
	by kanga.kvack.org (Postfix) with ESMTP id 357BB6B0255
	for <linux-mm@kvack.org>; Wed, 25 Nov 2015 11:28:14 -0500 (EST)
Received: by pacej9 with SMTP id ej9so61840289pac.2
        for <linux-mm@kvack.org>; Wed, 25 Nov 2015 08:28:14 -0800 (PST)
Received: from shards.monkeyblade.net (shards.monkeyblade.net. [2001:4f8:3:36:211:85ff:fe63:a549])
        by mx.google.com with ESMTP id 10si35165278pfk.32.2015.11.25.08.28.13
        for <linux-mm@kvack.org>;
        Wed, 25 Nov 2015 08:28:13 -0800 (PST)
Date: Wed, 25 Nov 2015 11:28:11 -0500 (EST)
Message-Id: <20151125.112811.22762794078922115.davem@davemloft.net>
Subject: Re: [PATCH 07/13] net: tcp_memcontrol: sanitize tcp memory
 accounting callbacks
From: David Miller <davem@davemloft.net>
In-Reply-To: <1448401925-22501-8-git-send-email-hannes@cmpxchg.org>
References: <1448401925-22501-1-git-send-email-hannes@cmpxchg.org>
	<1448401925-22501-8-git-send-email-hannes@cmpxchg.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: hannes@cmpxchg.org
Cc: akpm@linux-foundation.org, vdavydov@virtuozzo.com, mhocko@suse.cz, tj@kernel.org, eric.dumazet@gmail.com, netdev@vger.kernel.org, linux-mm@kvack.org, cgroups@vger.kernel.org, linux-kernel@vger.kernel.org, kernel-team@fb.com

From: Johannes Weiner <hannes@cmpxchg.org>
Date: Tue, 24 Nov 2015 16:51:59 -0500

> There won't be a tcp control soft limit, so integrating the memcg code
> into the global skmem limiting scheme complicates things
> unnecessarily. Replace this with simple and clear charge and uncharge
> calls--hidden behind a jump label--to account skb memory.
> 
> Note that this is not purely aesthetic: as a result of shoehorning the
> per-memcg code into the same memory accounting functions that handle
> the global level, the old code would compare the per-memcg consumption
> against the smaller of the per-memcg limit and the global limit. This
> allowed the total consumption of multiple sockets to exceed the global
> limit, as long as the individual sockets stayed within bounds. After
> this change, the code will always compare the per-memcg consumption to
> the per-memcg limit, and the global consumption to the global limit,
> and thus close this loophole.
> 
> Without a soft limit, the per-memcg memory pressure state in sockets
> is generally questionable. However, we did it until now, so we
> continue to enter it when the hard limit is hit, and packets are
> dropped, to let other sockets in the cgroup know that they shouldn't
> grow their transmit windows, either. However, keep it simple in the
> new callback model and leave memory pressure lazily when the next
> packet is accepted (as opposed to doing it synchroneously when packets
> are processed). When packets are dropped, network performance will
> already be in the toilet, so that should be a reasonable trade-off.
> 
> As described above, consumption is now checked on the per-memcg level
> and the global level separately. Likewise, memory pressure states are
> maintained on both the per-memcg level and the global level, and a
> socket is considered under pressure when either level asserts as much.
> 
> Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>
> Reviewed-by: Vladimir Davydov <vdavydov@virtuozzo.com>

Acked-by: David S. Miller <davem@davemloft.net>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

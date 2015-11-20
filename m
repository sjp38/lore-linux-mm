Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f50.google.com (mail-pa0-f50.google.com [209.85.220.50])
	by kanga.kvack.org (Postfix) with ESMTP id 2E6686B0253
	for <linux-mm@kvack.org>; Fri, 20 Nov 2015 05:59:15 -0500 (EST)
Received: by pacdm15 with SMTP id dm15so113741623pac.3
        for <linux-mm@kvack.org>; Fri, 20 Nov 2015 02:59:14 -0800 (PST)
Received: from mx2.parallels.com (mx2.parallels.com. [199.115.105.18])
        by mx.google.com with ESMTPS id hq4si18990330pbb.89.2015.11.20.02.59.14
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 20 Nov 2015 02:59:14 -0800 (PST)
Date: Fri, 20 Nov 2015 13:58:57 +0300
From: Vladimir Davydov <vdavydov@virtuozzo.com>
Subject: Re: [PATCH 08/14] net: tcp_memcontrol: sanitize tcp memory
 accounting callbacks
Message-ID: <20151120105857.GB31308@esperanza>
References: <1447371693-25143-1-git-send-email-hannes@cmpxchg.org>
 <1447371693-25143-9-git-send-email-hannes@cmpxchg.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Disposition: inline
In-Reply-To: <1447371693-25143-9-git-send-email-hannes@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: David Miller <davem@davemloft.net>, Andrew Morton <akpm@linux-foundation.org>, Tejun Heo <tj@kernel.org>, Michal Hocko <mhocko@suse.cz>, netdev@vger.kernel.org, linux-mm@kvack.org, cgroups@vger.kernel.org, linux-kernel@vger.kernel.org, kernel-team@fb.com

On Thu, Nov 12, 2015 at 06:41:27PM -0500, Johannes Weiner wrote:
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

It leaves the legacy functionality intact, while making the code look
much better.

Reviewed-by: Vladimir Davydov <vdavydov@virtuozzo.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

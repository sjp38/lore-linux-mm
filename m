Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lb0-f172.google.com (mail-lb0-f172.google.com [209.85.217.172])
	by kanga.kvack.org (Postfix) with ESMTP id 537836B0255
	for <linux-mm@kvack.org>; Sun, 15 Nov 2015 08:55:18 -0500 (EST)
Received: by lbbcs9 with SMTP id cs9so75379479lbb.1
        for <linux-mm@kvack.org>; Sun, 15 Nov 2015 05:55:17 -0800 (PST)
Received: from relay.parallels.com (relay.parallels.com. [195.214.232.42])
        by mx.google.com with ESMTPS id e78si22273273lfg.162.2015.11.15.05.55.16
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 15 Nov 2015 05:55:16 -0800 (PST)
Date: Sun, 15 Nov 2015 16:54:57 +0300
From: Vladimir Davydov <vdavydov@virtuozzo.com>
Subject: Re: [PATCH 14/14] mm: memcontrol: hook up vmpressure to socket
 pressure
Message-ID: <20151115135457.GM31308@esperanza>
References: <1447371693-25143-1-git-send-email-hannes@cmpxchg.org>
 <1447371693-25143-15-git-send-email-hannes@cmpxchg.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Disposition: inline
In-Reply-To: <1447371693-25143-15-git-send-email-hannes@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: David Miller <davem@davemloft.net>, Andrew Morton <akpm@linux-foundation.org>, Tejun Heo <tj@kernel.org>, Michal Hocko <mhocko@suse.cz>, netdev@vger.kernel.org, linux-mm@kvack.org, cgroups@vger.kernel.org, linux-kernel@vger.kernel.org, kernel-team@fb.com

On Thu, Nov 12, 2015 at 06:41:33PM -0500, Johannes Weiner wrote:
> Let the networking stack know when a memcg is under reclaim pressure
> so that it can clamp its transmit windows accordingly.
> 
> Whenever the reclaim efficiency of a cgroup's LRU lists drops low
> enough for a MEDIUM or HIGH vmpressure event to occur, assert a
> pressure state in the socket and tcp memory code that tells it to curb
> consumption growth from sockets associated with said control group.
> 
> vmpressure events are naturally edge triggered, so for hysteresis
> assert socket pressure for a second to allow for subsequent vmpressure
> events to occur before letting the socket code return to normal.

AFAICS, in contrast to v1, now you don't modify vmpressure behavior,
which means socket_pressure will only be set when cgroup hits its
high/hard limit. On tightly packed system, this is unlikely IMO -
cgroups will mostly experience pressure due to memory shortage at the
global level and/or their low limit configuration, in which case no
vmpressure events will be triggered and therefore tcp window won't be
clamped accordingly.

May be, we could use a per memcg slab shrinker to detect memory
pressure? This looks like abusing shrinkers API though.

Thanks,
Vladimir

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

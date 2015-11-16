Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f41.google.com (mail-wm0-f41.google.com [74.125.82.41])
	by kanga.kvack.org (Postfix) with ESMTP id 882946B0260
	for <linux-mm@kvack.org>; Mon, 16 Nov 2015 13:53:30 -0500 (EST)
Received: by wmec201 with SMTP id c201so192233047wme.0
        for <linux-mm@kvack.org>; Mon, 16 Nov 2015 10:53:30 -0800 (PST)
Received: from gum.cmpxchg.org (gum.cmpxchg.org. [85.214.110.215])
        by mx.google.com with ESMTPS id l75si22641964wmd.47.2015.11.16.10.53.29
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 16 Nov 2015 10:53:29 -0800 (PST)
Date: Mon, 16 Nov 2015 13:53:16 -0500
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [PATCH 14/14] mm: memcontrol: hook up vmpressure to socket
 pressure
Message-ID: <20151116185316.GC32544@cmpxchg.org>
References: <1447371693-25143-1-git-send-email-hannes@cmpxchg.org>
 <1447371693-25143-15-git-send-email-hannes@cmpxchg.org>
 <20151115135457.GM31308@esperanza>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20151115135457.GM31308@esperanza>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vladimir Davydov <vdavydov@virtuozzo.com>
Cc: David Miller <davem@davemloft.net>, Andrew Morton <akpm@linux-foundation.org>, Tejun Heo <tj@kernel.org>, Michal Hocko <mhocko@suse.cz>, netdev@vger.kernel.org, linux-mm@kvack.org, cgroups@vger.kernel.org, linux-kernel@vger.kernel.org, kernel-team@fb.com

On Sun, Nov 15, 2015 at 04:54:57PM +0300, Vladimir Davydov wrote:
> On Thu, Nov 12, 2015 at 06:41:33PM -0500, Johannes Weiner wrote:
> > Let the networking stack know when a memcg is under reclaim pressure
> > so that it can clamp its transmit windows accordingly.
> > 
> > Whenever the reclaim efficiency of a cgroup's LRU lists drops low
> > enough for a MEDIUM or HIGH vmpressure event to occur, assert a
> > pressure state in the socket and tcp memory code that tells it to curb
> > consumption growth from sockets associated with said control group.
> > 
> > vmpressure events are naturally edge triggered, so for hysteresis
> > assert socket pressure for a second to allow for subsequent vmpressure
> > events to occur before letting the socket code return to normal.
> 
> AFAICS, in contrast to v1, now you don't modify vmpressure behavior,
> which means socket_pressure will only be set when cgroup hits its
> high/hard limit. On tightly packed system, this is unlikely IMO -
> cgroups will mostly experience pressure due to memory shortage at the
> global level and/or their low limit configuration, in which case no
> vmpressure events will be triggered and therefore tcp window won't be
> clamped accordingly.

Yeah, this is an inherent problem in the vmpressure design and it
makes the feature significantly less useful than it could be IMO.

But you guys were wary about the patch that changed it, and this
series has kicked up enough dust already, so I backed it out.

But this will still be useful. Yes, it won't help in rebalancing an
regularly working system, which would be cool, but it'll still help
contain a worklad that is growing beyond expectations, which is the
scenario that kickstarted this work.

> May be, we could use a per memcg slab shrinker to detect memory
> pressure? This looks like abusing shrinkers API though.

Actually, I thought about doing this long-term.

Shrinkers are a nice way to export VM pressure to auxiliary allocators
and caches. But currently, the only metric we export is LRU scan rate,
whose application is limited to ageable caches: it doesn't make sense
to cause auxiliary workingsets to shrink when the VM is merely picking
up the drop-behind pages of a one-off page cache stream. I think it
would make sense for shrinkers to include reclaim efficiency so that
they can be used by caches that don't have 'accessed' bits and object
rotation, but are able to shrink based on the cost they're imposing.

But a change like this is beyond the scope of this series, IMO.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

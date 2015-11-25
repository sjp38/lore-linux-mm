Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f43.google.com (mail-pa0-f43.google.com [209.85.220.43])
	by kanga.kvack.org (Postfix) with ESMTP id 8FD5E6B025A
	for <linux-mm@kvack.org>; Wed, 25 Nov 2015 11:30:52 -0500 (EST)
Received: by padhx2 with SMTP id hx2so62019021pad.1
        for <linux-mm@kvack.org>; Wed, 25 Nov 2015 08:30:52 -0800 (PST)
Received: from shards.monkeyblade.net (shards.monkeyblade.net. [2001:4f8:3:36:211:85ff:fe63:a549])
        by mx.google.com with ESMTP id pu2si2037188pac.80.2015.11.25.08.30.50
        for <linux-mm@kvack.org>;
        Wed, 25 Nov 2015 08:30:51 -0800 (PST)
Date: Wed, 25 Nov 2015 11:30:48 -0500 (EST)
Message-Id: <20151125.113048.45218641761530031.davem@davemloft.net>
Subject: Re: [PATCH 13/13] mm: memcontrol: hook up vmpressure to socket
 pressure
From: David Miller <davem@davemloft.net>
In-Reply-To: <20151124215940.GB1373@cmpxchg.org>
References: <1448401925-22501-1-git-send-email-hannes@cmpxchg.org>
	<20151124215940.GB1373@cmpxchg.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: hannes@cmpxchg.org
Cc: akpm@linux-foundation.org, vdavydov@virtuozzo.com, mhocko@suse.cz, tj@kernel.org, eric.dumazet@gmail.com, netdev@vger.kernel.org, linux-mm@kvack.org, cgroups@vger.kernel.org, linux-kernel@vger.kernel.org, kernel-team@fb.com

From: Johannes Weiner <hannes@cmpxchg.org>
Date: Tue, 24 Nov 2015 16:59:40 -0500

> Let the networking stack know when a memcg is under reclaim pressure
> so that it can clamp its transmit windows accordingly.
> 
> Whenever the reclaim efficiency of a cgroup's LRU lists drops low
> enough for a MEDIUM or HIGH vmpressure event to occur, assert a
> pressure state in the socket and tcp memory code that tells it to curb
> consumption growth from sockets associated with said control group.
> 
> Traditionally, vmpressure reports for the entire subtree of a memcg
> under pressure, which drops useful information on the individual
> groups reclaimed. However, it's too late to change the userinterface,
> so add a second reporting mode that reports on the level of reclaim
> instead of at the level of pressure, and use that report for sockets.
> 
> vmpressure events are naturally edge triggered, so for hysteresis
> assert socket pressure for a second to allow for subsequent vmpressure
> events to occur before letting the socket code return to normal.
> 
> This will likely need finetuning for a wider variety of workloads, but
> for now stick to the vmpressure presets and keep hysteresis simple.
> 
> Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>

Acked-by: David S. Miller <davem@davemloft.net>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f179.google.com (mail-io0-f179.google.com [209.85.223.179])
	by kanga.kvack.org (Postfix) with ESMTP id 311F182F64
	for <linux-mm@kvack.org>; Fri, 23 Oct 2015 06:36:40 -0400 (EDT)
Received: by iodv82 with SMTP id v82so119385309iod.0
        for <linux-mm@kvack.org>; Fri, 23 Oct 2015 03:36:40 -0700 (PDT)
Received: from mail-pa0-x233.google.com (mail-pa0-x233.google.com. [2607:f8b0:400e:c03::233])
        by mx.google.com with ESMTPS id l4si2641771igx.52.2015.10.23.03.36.39
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 23 Oct 2015 03:36:39 -0700 (PDT)
Received: by padhk11 with SMTP id hk11so115485998pad.1
        for <linux-mm@kvack.org>; Fri, 23 Oct 2015 03:36:39 -0700 (PDT)
Date: Fri, 23 Oct 2015 19:36:30 +0900
From: Tejun Heo <htejun@gmail.com>
Subject: Re: [PATCH] mm,vmscan: Use accurate values for zone_reclaimable()
 checks
Message-ID: <20151023103630.GA4170@mtj.duckdns.org>
References: <201510222037.ACH86458.OFOLFtQFOHJSVM@I-love.SAKURA.ne.jp>
 <alpine.DEB.2.20.1510220836430.18486@east.gentwo.org>
 <20151022140944.GA30579@mtj.duckdns.org>
 <20151022150623.GE26854@dhcp22.suse.cz>
 <20151022151528.GG30579@mtj.duckdns.org>
 <20151022153559.GF26854@dhcp22.suse.cz>
 <20151022153703.GA3899@mtj.duckdns.org>
 <20151022154922.GG26854@dhcp22.suse.cz>
 <20151022184226.GA19289@mtj.duckdns.org>
 <20151023083316.GB2410@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20151023083316.GB2410@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Christoph Lameter <cl@linux.com>, Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, torvalds@linux-foundation.org, David Rientjes <rientjes@google.com>, oleg@redhat.com, kwalker@redhat.com, akpm@linux-foundation.org, hannes@cmpxchg.org, vdavydov@parallels.com, skozina@redhat.com, mgorman@suse.de, riel@redhat.com

Hello, Michal.

On Fri, Oct 23, 2015 at 10:33:16AM +0200, Michal Hocko wrote:
> Ohh, OK I can see wq_worker_sleeping now. I've missed your point in
> other email, sorry about that. But now I am wondering whether this
> is an intended behavior. The documentation says:

This is.

>   WQ_MEM_RECLAIM
> 
>         All wq which might be used in the memory reclaim paths _MUST_
>         have this flag set.  The wq is guaranteed to have at least one
>         execution context regardless of memory pressure.
> 
> Which doesn't seem to be true currently, right? Now I can see your patch

It is true.

> to introduce WQ_IMMEDIATE but I am wondering which WQ_MEM_RECLAIM users
> could do without WQ_IMMEDIATE? I mean all current workers might be
> looping in the page allocator and it seems possible that WQ_MEM_RECLAIM
> work items might be waiting behind them so they cannot help to relieve
> the memory pressure. This doesn't sound right to me. Or I am completely
> confused and still fail to understand what is WQ_MEM_RECLAIM supposed to
> be used for.

It guarantees that there always is enough execution resource to
execute a work item from that workqueue.  The problem here is not lack
of execution resource but concurrency management misunderstanding the
situation.  This also can be fixed by teaching concurrency management
to be a bit smarter - e.g. if a work item is burning a lot of CPU
cycles continuously or pool hasn't finished a work item over a certain
amount of time, automatically ignore the in-flight work item for the
purpose of concurrency management; however, this sort of inter-work
item busy waits are so extremely rare and undesirable that I'm not
sure the added complexity would be worthwhile.

Thanks.

-- 
tejun

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

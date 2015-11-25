Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f41.google.com (mail-pa0-f41.google.com [209.85.220.41])
	by kanga.kvack.org (Postfix) with ESMTP id B0A146B0259
	for <linux-mm@kvack.org>; Tue, 24 Nov 2015 21:44:15 -0500 (EST)
Received: by pacej9 with SMTP id ej9so41478002pac.2
        for <linux-mm@kvack.org>; Tue, 24 Nov 2015 18:44:15 -0800 (PST)
Received: from lgeamrelo13.lge.com (LGEAMRELO13.lge.com. [156.147.23.53])
        by mx.google.com with ESMTPS id xq4si30604966pab.229.2015.11.24.18.44.13
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Tue, 24 Nov 2015 18:44:14 -0800 (PST)
Date: Wed, 25 Nov 2015 11:44:36 +0900
From: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Subject: Re: [PATCH] mm, vmstat: Allow WQ concurrency to discover memory
 reclaim doesn't make any progress
Message-ID: <20151125024435.GB9563@js1304-P5Q-DELUXE>
References: <1447936253-18134-1-git-send-email-mhocko@kernel.org>
 <20151124154448.ac124e62528db313279224ef@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20151124154448.ac124e62528db313279224ef@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Michal Hocko <mhocko@kernel.org>, Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, Tejun Heo <tj@kernel.org>, Cristopher Lameter <clameter@sgi.com>, Arkadiusz =?utf-8?Q?Mi=C5=9Bkiewicz?= <arekm@maven.pl>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>, Michal Hocko <mhocko@suse.com>, Christoph Lameter <cl@linux.com>

On Tue, Nov 24, 2015 at 03:44:48PM -0800, Andrew Morton wrote:
> On Thu, 19 Nov 2015 13:30:53 +0100 Michal Hocko <mhocko@kernel.org> wrote:
> 
> > From: Michal Hocko <mhocko@suse.com>
> > 
> > Tetsuo Handa has reported that the system might basically livelock in OOM
> > condition without triggering the OOM killer. The issue is caused by
> > internal dependency of the direct reclaim on vmstat counter updates (via
> > zone_reclaimable) which are performed from the workqueue context.
> > If all the current workers get assigned to an allocation request,
> > though, they will be looping inside the allocator trying to reclaim
> > memory but zone_reclaimable can see stalled numbers so it will consider
> > a zone reclaimable even though it has been scanned way too much. WQ
> > concurrency logic will not consider this situation as a congested workqueue
> > because it relies that worker would have to sleep in such a situation.
> > This also means that it doesn't try to spawn new workers or invoke
> > the rescuer thread if the one is assigned to the queue.
> > 
> > In order to fix this issue we need to do two things. First we have to
> > let wq concurrency code know that we are in trouble so we have to do
> > a short sleep. In order to prevent from issues handled by 0e093d99763e
> > ("writeback: do not sleep on the congestion queue if there are no
> > congested BDIs or if significant congestion is not being encountered in
> > the current zone") we limit the sleep only to worker threads which are
> > the ones of the interest anyway.
> > 
> > The second thing to do is to create a dedicated workqueue for vmstat and
> > mark it WQ_MEM_RECLAIM to note it participates in the reclaim and to
> > have a spare worker thread for it.
> 
> This vmstat update thing is being a problem.  Please see Joonsoo's
> "mm/vmstat: retrieve more accurate vmstat value".
> 
> Joonsoo, might this patch help with that issue?

That issue cannot be solved by this patch. This patch solves blocking
vmstat updator problem but that issue is caused by long update delay
(not blocking). In there, update happens every 1 sec as usuall.

Thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

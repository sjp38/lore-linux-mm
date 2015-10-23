Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f170.google.com (mail-wi0-f170.google.com [209.85.212.170])
	by kanga.kvack.org (Postfix) with ESMTP id A7E386B0038
	for <linux-mm@kvack.org>; Fri, 23 Oct 2015 04:33:19 -0400 (EDT)
Received: by wicll6 with SMTP id ll6so21028339wic.0
        for <linux-mm@kvack.org>; Fri, 23 Oct 2015 01:33:19 -0700 (PDT)
Received: from mail-wi0-f174.google.com (mail-wi0-f174.google.com. [209.85.212.174])
        by mx.google.com with ESMTPS id k4si178002wjz.8.2015.10.23.01.33.18
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 23 Oct 2015 01:33:18 -0700 (PDT)
Received: by wicfx6 with SMTP id fx6so20974804wic.1
        for <linux-mm@kvack.org>; Fri, 23 Oct 2015 01:33:18 -0700 (PDT)
Date: Fri, 23 Oct 2015 10:33:16 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH] mm,vmscan: Use accurate values for zone_reclaimable()
 checks
Message-ID: <20151023083316.GB2410@dhcp22.suse.cz>
References: <alpine.DEB.2.20.1510211214480.10364@east.gentwo.org>
 <201510222037.ACH86458.OFOLFtQFOHJSVM@I-love.SAKURA.ne.jp>
 <alpine.DEB.2.20.1510220836430.18486@east.gentwo.org>
 <20151022140944.GA30579@mtj.duckdns.org>
 <20151022150623.GE26854@dhcp22.suse.cz>
 <20151022151528.GG30579@mtj.duckdns.org>
 <20151022153559.GF26854@dhcp22.suse.cz>
 <20151022153703.GA3899@mtj.duckdns.org>
 <20151022154922.GG26854@dhcp22.suse.cz>
 <20151022184226.GA19289@mtj.duckdns.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20151022184226.GA19289@mtj.duckdns.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tejun Heo <htejun@gmail.com>
Cc: Christoph Lameter <cl@linux.com>, Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, torvalds@linux-foundation.org, David Rientjes <rientjes@google.com>, oleg@redhat.com, kwalker@redhat.com, akpm@linux-foundation.org, hannes@cmpxchg.org, vdavydov@parallels.com, skozina@redhat.com, mgorman@suse.de, riel@redhat.com

On Fri 23-10-15 03:42:26, Tejun Heo wrote:
> On Thu, Oct 22, 2015 at 05:49:22PM +0200, Michal Hocko wrote:
> > I am confused. What makes rescuer to not run? Nothing seems to be
> > hogging CPUs, we are just out of workers which are loopin in the
> > allocator but that is preemptible context.
> 
> It's concurrency management.  Workqueue thinks that the pool is making
> positive forward progress and doesn't schedule anything else for
> execution while that work item is burning cpu cycles.

Ohh, OK I can see wq_worker_sleeping now. I've missed your point in
other email, sorry about that. But now I am wondering whether this
is an intended behavior. The documentation says:
  WQ_MEM_RECLAIM

        All wq which might be used in the memory reclaim paths _MUST_
        have this flag set.  The wq is guaranteed to have at least one
        execution context regardless of memory pressure.

Which doesn't seem to be true currently, right? Now I can see your patch
to introduce WQ_IMMEDIATE but I am wondering which WQ_MEM_RECLAIM users
could do without WQ_IMMEDIATE? I mean all current workers might be
looping in the page allocator and it seems possible that WQ_MEM_RECLAIM
work items might be waiting behind them so they cannot help to relieve
the memory pressure. This doesn't sound right to me. Or I am completely
confused and still fail to understand what is WQ_MEM_RECLAIM supposed to
be used for.
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

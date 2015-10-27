Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f169.google.com (mail-wi0-f169.google.com [209.85.212.169])
	by kanga.kvack.org (Postfix) with ESMTP id 0E44F6B0038
	for <linux-mm@kvack.org>; Tue, 27 Oct 2015 05:16:07 -0400 (EDT)
Received: by wicll6 with SMTP id ll6so150377190wic.1
        for <linux-mm@kvack.org>; Tue, 27 Oct 2015 02:16:06 -0700 (PDT)
Received: from mail-wi0-f169.google.com (mail-wi0-f169.google.com. [209.85.212.169])
        by mx.google.com with ESMTPS id pk5si26950251wjb.102.2015.10.27.02.16.05
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 27 Oct 2015 02:16:05 -0700 (PDT)
Received: by wicfx6 with SMTP id fx6so149645726wic.1
        for <linux-mm@kvack.org>; Tue, 27 Oct 2015 02:16:05 -0700 (PDT)
Date: Tue, 27 Oct 2015 10:16:03 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH] mm,vmscan: Use accurate values for zone_reclaimable()
 checks
Message-ID: <20151027091603.GB9891@dhcp22.suse.cz>
References: <20151022150623.GE26854@dhcp22.suse.cz>
 <20151022151528.GG30579@mtj.duckdns.org>
 <20151022153559.GF26854@dhcp22.suse.cz>
 <20151022153703.GA3899@mtj.duckdns.org>
 <20151022154922.GG26854@dhcp22.suse.cz>
 <20151022184226.GA19289@mtj.duckdns.org>
 <20151023083316.GB2410@dhcp22.suse.cz>
 <20151023103630.GA4170@mtj.duckdns.org>
 <20151023111145.GH2410@dhcp22.suse.cz>
 <20151023182109.GA14610@mtj.duckdns.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20151023182109.GA14610@mtj.duckdns.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tejun Heo <htejun@gmail.com>
Cc: Christoph Lameter <cl@linux.com>, Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, torvalds@linux-foundation.org, David Rientjes <rientjes@google.com>, oleg@redhat.com, kwalker@redhat.com, akpm@linux-foundation.org, hannes@cmpxchg.org, vdavydov@parallels.com, skozina@redhat.com, mgorman@suse.de, riel@redhat.com

On Sat 24-10-15 03:21:09, Tejun Heo wrote:
> Hello,
> 
> On Fri, Oct 23, 2015 at 01:11:45PM +0200, Michal Hocko wrote:
> > > The problem here is not lack
> > > of execution resource but concurrency management misunderstanding the
> > > situation. 
> > 
> > And this sounds like a bug to me.
> 
> I don't know.  I can be argued either way, the other direction being a
> kernel thread going RUNNING non-stop is buggy.  Given how this has
> been a complete non-issue for all the years, I'm not sure how useful
> plugging this is.

Well, I guess we haven't noticed because this is a pathological case. It
also triggers OOM livelocks which were not reported in the past either.
You do not reach this state normally unless you rely _want_ to kill your
machine

And vmstat is not the only instance. E.g. sysrq oom trigger is known
to stay behind in similar cases. It should be changed to a dedicated
WQ_MEM_RECLAIM wq and it would require runnable item guarantee as well.

> > Don't we have some IO related paths which would suffer from the same
> > problem. I haven't checked all the WQ_MEM_RECLAIM users but from the
> > name I would expect they _do_ participate in the reclaim and so they
> > should be able to make a progress. Now if your new IMMEDIATE flag will
> 
> Seriously, nobody goes full-on RUNNING.

Looping with cond_resched seems like general pattern in the kernel when
there is no clear source to wait for. We have io_schedule when we know
we should wait for IO (in case of congestion) but this is not necessarily
the case - as you can see here. What should we wait for? A short nap
without actually waiting on anything sounds like a dirty workaround to
me.

> > guarantee that then I would argue that it should be implicit for
> > WQ_MEM_RECLAIM otherwise we always risk a similar situation. What would
> > be a counter argument for doing that?
> 
> Not serving any actual purpose and degrading execution behavior.

I dunno, I am not familiar with WQ internals to see the risks but to me
it sounds like WQ_MEM_RECLAIM gives an incorrect impression of safety
wrt. memory pressure and as demonstrated it doesn't do that. Even if you
consider cond_resched behavior of the page allocator as bug we should be
able to handle this gracefully.
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

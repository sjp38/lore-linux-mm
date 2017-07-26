Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f69.google.com (mail-wm0-f69.google.com [74.125.82.69])
	by kanga.kvack.org (Postfix) with ESMTP id 4B9CE6B0311
	for <linux-mm@kvack.org>; Wed, 26 Jul 2017 07:46:46 -0400 (EDT)
Received: by mail-wm0-f69.google.com with SMTP id 184so16132648wmo.7
        for <linux-mm@kvack.org>; Wed, 26 Jul 2017 04:46:46 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id q23si17058456wrc.56.2017.07.26.04.46.44
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 26 Jul 2017 04:46:45 -0700 (PDT)
Date: Wed, 26 Jul 2017 13:46:39 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH] oom_reaper: close race without using oom_lock
Message-ID: <20170726114638.GL2981@dhcp22.suse.cz>
References: <20170721150002.GF5944@dhcp22.suse.cz>
 <201707220018.DAE21384.JQFLVMFHSFtOOO@I-love.SAKURA.ne.jp>
 <20170721153353.GG5944@dhcp22.suse.cz>
 <201707230941.BFG30203.OFHSJtFFVQLOMO@I-love.SAKURA.ne.jp>
 <20170724063844.GA25221@dhcp22.suse.cz>
 <201707262033.JGE65600.MOtQFFLOJOSFVH@I-love.SAKURA.ne.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <201707262033.JGE65600.MOtQFFLOJOSFVH@I-love.SAKURA.ne.jp>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Cc: linux-mm@kvack.org, hannes@cmpxchg.org, rientjes@google.com, linux-kernel@vger.kernel.org

On Wed 26-07-17 20:33:21, Tetsuo Handa wrote:
> Michal Hocko wrote:
> > On Sun 23-07-17 09:41:50, Tetsuo Handa wrote:
> > > So, how can we verify the above race a real problem?
> > 
> > Try to simulate a _real_ workload and see whether we kill more tasks
> > than necessary. 
> 
> Whether it is a _real_ workload or not cannot become an answer.
> 
> If somebody is trying to allocate hundreds/thousands of pages after memory of
> an OOM victim was reaped, avoiding this race window makes no sense; next OOM
> victim will be selected anyway. But if somebody is trying to allocate only one
> page and then is planning to release a lot of memory, avoiding this race window
> can save somebody from being OOM-killed needlessly. This race window depends on
> what the threads are about to do, not whether the workload is natural or
> artificial.

And with a desparate lack of crystal ball we cannot do much about that
really.

> My question is, how can users know it if somebody was OOM-killed needlessly
> by allowing MMF_OOM_SKIP to race.

Is it really important to know that the race is due to MMF_OOM_SKIP?
Isn't it sufficient to see that we kill too many tasks and then debug it
further once something hits that?

[...]
> Is it guaranteed that __node_reclaim() never (even indirectly) waits for
> __GFP_DIRECT_RECLAIM && !__GFP_NORETRY memory allocation?

this is a direct reclaim which can go down to slab shrinkers with all
the usual fun...

> >                                      Such races are unfortunate but
> > unavoidable unless we synchronize oom kill with any memory freeing which
> > smells like a no-go to me. We can try a last allocation attempt right
> > before we go and kill something (which still wouldn't be race free) but
> > that might cause other issues - e.g. prolonged trashing without ever
> > killing something - but I haven't evaluated those to be honest.
> 
> Yes, postpone last get_page_from_freelist() attempt till oom_kill_process()
> will be what we would afford at best.

as I've said this would have to be evaluated very carefully and a strong
usecase would have to be shown.
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

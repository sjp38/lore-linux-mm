Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f197.google.com (mail-wr0-f197.google.com [209.85.128.197])
	by kanga.kvack.org (Postfix) with ESMTP id C5F726B025F
	for <linux-mm@kvack.org>; Mon,  7 Aug 2017 02:02:47 -0400 (EDT)
Received: by mail-wr0-f197.google.com with SMTP id k71so13445175wrc.15
        for <linux-mm@kvack.org>; Sun, 06 Aug 2017 23:02:47 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id 59si7919796wrd.166.2017.08.06.23.02.46
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Sun, 06 Aug 2017 23:02:46 -0700 (PDT)
Date: Mon, 7 Aug 2017 08:02:43 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH] oom_reaper: close race without using oom_lock
Message-ID: <20170807060243.GA32434@dhcp22.suse.cz>
References: <20170721153353.GG5944@dhcp22.suse.cz>
 <201707230941.BFG30203.OFHSJtFFVQLOMO@I-love.SAKURA.ne.jp>
 <20170724063844.GA25221@dhcp22.suse.cz>
 <201707262033.JGE65600.MOtQFFLOJOSFVH@I-love.SAKURA.ne.jp>
 <20170726114638.GL2981@dhcp22.suse.cz>
 <201708051002.FGG87553.QtFFFMVJOSOOHL@I-love.SAKURA.ne.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <201708051002.FGG87553.QtFFFMVJOSOOHL@I-love.SAKURA.ne.jp>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Cc: linux-mm@kvack.org, hannes@cmpxchg.org, rientjes@google.com, linux-kernel@vger.kernel.org

On Sat 05-08-17 10:02:55, Tetsuo Handa wrote:
> Michal Hocko wrote:
> > On Wed 26-07-17 20:33:21, Tetsuo Handa wrote:
> > > Michal Hocko wrote:
> > > > On Sun 23-07-17 09:41:50, Tetsuo Handa wrote:
> > > > > So, how can we verify the above race a real problem?
> > > > 
> > > > Try to simulate a _real_ workload and see whether we kill more tasks
> > > > than necessary. 
> > > 
> > > Whether it is a _real_ workload or not cannot become an answer.
> > > 
> > > If somebody is trying to allocate hundreds/thousands of pages after memory of
> > > an OOM victim was reaped, avoiding this race window makes no sense; next OOM
> > > victim will be selected anyway. But if somebody is trying to allocate only one
> > > page and then is planning to release a lot of memory, avoiding this race window
> > > can save somebody from being OOM-killed needlessly. This race window depends on
> > > what the threads are about to do, not whether the workload is natural or
> > > artificial.
> > 
> > And with a desparate lack of crystal ball we cannot do much about that
> > really.
> > 
> > > My question is, how can users know it if somebody was OOM-killed needlessly
> > > by allowing MMF_OOM_SKIP to race.
> > 
> > Is it really important to know that the race is due to MMF_OOM_SKIP?
> 
> Yes, it is really important. Needlessly selecting even one OOM victim is
> a pain which is difficult to explain to and persuade some of customers.

How is this any different from a race with a task exiting an releasing
some memory after we have crossed the point of no return and will kill
something?

> > Isn't it sufficient to see that we kill too many tasks and then debug it
> > further once something hits that?
> 
> It is not sufficient.
> 
> > 
> > [...]
> > > Is it guaranteed that __node_reclaim() never (even indirectly) waits for
> > > __GFP_DIRECT_RECLAIM && !__GFP_NORETRY memory allocation?
> > 
> > this is a direct reclaim which can go down to slab shrinkers with all
> > the usual fun...
> 
> Excuse me, but does that mean "Yes, it is" ?
> 
> As far as I checked, most shrinkers use non-scheduling operations other than
> cond_resched(). But some shrinkers use lock_page()/down_write() etc. I worry
> that such shrinkers might wait for __GFP_DIRECT_RECLAIM && !__GFP_NORETRY
> memory allocation (i.e. "No, it isn't").

Yes that is possible. Once you are in the shrinker land then you have to
count with everything. And if you want to imply that
get_page_from_freelist inside __alloc_pages_may_oom may lockup while
holding the oom_lock then you might be right but I haven't checked that
too deeply. It might be very well possible that the node reclaim bails
out early when we are under OOM.

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f71.google.com (mail-pg0-f71.google.com [74.125.83.71])
	by kanga.kvack.org (Postfix) with ESMTP id 6877D280396
	for <linux-mm@kvack.org>; Fri,  4 Aug 2017 21:03:10 -0400 (EDT)
Received: by mail-pg0-f71.google.com with SMTP id 16so34508621pgg.8
        for <linux-mm@kvack.org>; Fri, 04 Aug 2017 18:03:10 -0700 (PDT)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [2001:e42:101:1:202:181:97:72])
        by mx.google.com with ESMTPS id 63si1864618plb.684.2017.08.04.18.03.08
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Fri, 04 Aug 2017 18:03:09 -0700 (PDT)
Subject: Re: [PATCH] oom_reaper: close race without using oom_lock
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
References: <20170721153353.GG5944@dhcp22.suse.cz>
	<201707230941.BFG30203.OFHSJtFFVQLOMO@I-love.SAKURA.ne.jp>
	<20170724063844.GA25221@dhcp22.suse.cz>
	<201707262033.JGE65600.MOtQFFLOJOSFVH@I-love.SAKURA.ne.jp>
	<20170726114638.GL2981@dhcp22.suse.cz>
In-Reply-To: <20170726114638.GL2981@dhcp22.suse.cz>
Message-Id: <201708051002.FGG87553.QtFFFMVJOSOOHL@I-love.SAKURA.ne.jp>
Date: Sat, 5 Aug 2017 10:02:55 +0900
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: mhocko@kernel.org
Cc: linux-mm@kvack.org, hannes@cmpxchg.org, rientjes@google.com, linux-kernel@vger.kernel.org

Michal Hocko wrote:
> On Wed 26-07-17 20:33:21, Tetsuo Handa wrote:
> > Michal Hocko wrote:
> > > On Sun 23-07-17 09:41:50, Tetsuo Handa wrote:
> > > > So, how can we verify the above race a real problem?
> > > 
> > > Try to simulate a _real_ workload and see whether we kill more tasks
> > > than necessary. 
> > 
> > Whether it is a _real_ workload or not cannot become an answer.
> > 
> > If somebody is trying to allocate hundreds/thousands of pages after memory of
> > an OOM victim was reaped, avoiding this race window makes no sense; next OOM
> > victim will be selected anyway. But if somebody is trying to allocate only one
> > page and then is planning to release a lot of memory, avoiding this race window
> > can save somebody from being OOM-killed needlessly. This race window depends on
> > what the threads are about to do, not whether the workload is natural or
> > artificial.
> 
> And with a desparate lack of crystal ball we cannot do much about that
> really.
> 
> > My question is, how can users know it if somebody was OOM-killed needlessly
> > by allowing MMF_OOM_SKIP to race.
> 
> Is it really important to know that the race is due to MMF_OOM_SKIP?

Yes, it is really important. Needlessly selecting even one OOM victim is
a pain which is difficult to explain to and persuade some of customers.

> Isn't it sufficient to see that we kill too many tasks and then debug it
> further once something hits that?

It is not sufficient.

> 
> [...]
> > Is it guaranteed that __node_reclaim() never (even indirectly) waits for
> > __GFP_DIRECT_RECLAIM && !__GFP_NORETRY memory allocation?
> 
> this is a direct reclaim which can go down to slab shrinkers with all
> the usual fun...

Excuse me, but does that mean "Yes, it is" ?

As far as I checked, most shrinkers use non-scheduling operations other than
cond_resched(). But some shrinkers use lock_page()/down_write() etc. I worry
that such shrinkers might wait for __GFP_DIRECT_RECLAIM && !__GFP_NORETRY
memory allocation (i.e. "No, it isn't").

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f197.google.com (mail-wr0-f197.google.com [209.85.128.197])
	by kanga.kvack.org (Postfix) with ESMTP id 430806B0292
	for <linux-mm@kvack.org>; Mon, 24 Jul 2017 02:38:50 -0400 (EDT)
Received: by mail-wr0-f197.google.com with SMTP id w63so23532134wrc.5
        for <linux-mm@kvack.org>; Sun, 23 Jul 2017 23:38:50 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id y197si5111646wmc.123.2017.07.23.23.38.48
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Sun, 23 Jul 2017 23:38:48 -0700 (PDT)
Date: Mon, 24 Jul 2017 08:38:45 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH] oom_reaper: close race without using oom_lock
Message-ID: <20170724063844.GA25221@dhcp22.suse.cz>
References: <20170720141138.GJ9058@dhcp22.suse.cz>
 <201707210647.BDH57894.MQOtFFOJHLSOFV@I-love.SAKURA.ne.jp>
 <20170721150002.GF5944@dhcp22.suse.cz>
 <201707220018.DAE21384.JQFLVMFHSFtOOO@I-love.SAKURA.ne.jp>
 <20170721153353.GG5944@dhcp22.suse.cz>
 <201707230941.BFG30203.OFHSJtFFVQLOMO@I-love.SAKURA.ne.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <201707230941.BFG30203.OFHSJtFFVQLOMO@I-love.SAKURA.ne.jp>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Cc: linux-mm@kvack.org, hannes@cmpxchg.org, rientjes@google.com, linux-kernel@vger.kernel.org

On Sun 23-07-17 09:41:50, Tetsuo Handa wrote:
> Michal Hocko wrote:
> > On Sat 22-07-17 00:18:48, Tetsuo Handa wrote:
> > > Michal Hocko wrote:
> > > > OK, so let's say you have another task just about to jump into
> > > > out_of_memory and ... end up in the same situation.
> > > 
> > > Right.
> > > 
> > > > 
> > > >                                                     This race is just
> > > > unavoidable.
> > > 
> > > There is no perfect way (always timing dependent). But
> > 
> > I would rather not add a code which _pretends_ it solves something. If
> > we see the above race a real problem in out there then we should think
> > about how to fix it. I definitely do not want to add more hack into an
> > already complicated code base.
> 
> So, how can we verify the above race a real problem?

Try to simulate a _real_ workload and see whether we kill more tasks
than necessary. 

> I consider that
> it is impossible. The " free:%lukB" field by show_free_areas() is too
> random/inaccurate/racy/outdated for evaluating this race window.
> 
> Only actually calling alloc_page_from_freelist() immediately after
> MMF_OOM_SKIP test (like Patch1 shown below) can evaluate this race window,
> but I know that you won't allow me to add such code to the OOM killer layer.

Sigh. It is not about _me_ allowing you something or not. It is about
what makes sense and under which circumstances and usual cost benefit
evaluation. In other words, any patch has to be _justified_. I am really
tired of repeating this simple thing over and over again.

Anyway, the change you are proposing is wrong for two reasons. First,
you are in non-preemptible context in oom_evaluate_task so you cannot
call into get_page_from_freelist (node_reclaim) and secondly it is a
very specific hack while there is a whole category of possible races
where someone frees memory (e.g. and exiting task which smells like what
you see in your testing) while we are selecting an oom victim which
can be quite an expensive operation. Such races are unfortunate but
unavoidable unless we synchronize oom kill with any memory freeing which
smells like a no-go to me. We can try a last allocation attempt right
before we go and kill something (which still wouldn't be race free) but
that might cause other issues - e.g. prolonged trashing without ever
killing something - but I haven't evaluated those to be honest.

[...]

> The result shows that this race is highly timing dependent, but it
> at least shows that it is not rare case that get_page_from_freelist()
> can succeed after we checked that victim's mm already has MMF_OOM_SKIP.

It might be not rare for the extreme test case you are using. Do not
forget you spawn many tasks and them exiting might race with the oom
selection. I am really skeptical this reflects a real usecase.

> So, how can we check the above race a real problem? I consider that
> it is impossible.

And so I would be rather reluctant to add more hacks^Wheuristics...

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

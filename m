Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id BD5246B025F
	for <linux-mm@kvack.org>; Wed, 26 Jul 2017 07:33:35 -0400 (EDT)
Received: by mail-pf0-f198.google.com with SMTP id 72so104284242pfl.12
        for <linux-mm@kvack.org>; Wed, 26 Jul 2017 04:33:35 -0700 (PDT)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [2001:e42:101:1:202:181:97:72])
        by mx.google.com with ESMTPS id r1si1747043pgs.195.2017.07.26.04.33.34
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 26 Jul 2017 04:33:34 -0700 (PDT)
Subject: Re: [PATCH] oom_reaper: close race without using oom_lock
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
References: <20170721150002.GF5944@dhcp22.suse.cz>
	<201707220018.DAE21384.JQFLVMFHSFtOOO@I-love.SAKURA.ne.jp>
	<20170721153353.GG5944@dhcp22.suse.cz>
	<201707230941.BFG30203.OFHSJtFFVQLOMO@I-love.SAKURA.ne.jp>
	<20170724063844.GA25221@dhcp22.suse.cz>
In-Reply-To: <20170724063844.GA25221@dhcp22.suse.cz>
Message-Id: <201707262033.JGE65600.MOtQFFLOJOSFVH@I-love.SAKURA.ne.jp>
Date: Wed, 26 Jul 2017 20:33:21 +0900
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: mhocko@kernel.org
Cc: linux-mm@kvack.org, hannes@cmpxchg.org, rientjes@google.com, linux-kernel@vger.kernel.org

Michal Hocko wrote:
> On Sun 23-07-17 09:41:50, Tetsuo Handa wrote:
> > So, how can we verify the above race a real problem?
> 
> Try to simulate a _real_ workload and see whether we kill more tasks
> than necessary. 

Whether it is a _real_ workload or not cannot become an answer.

If somebody is trying to allocate hundreds/thousands of pages after memory of
an OOM victim was reaped, avoiding this race window makes no sense; next OOM
victim will be selected anyway. But if somebody is trying to allocate only one
page and then is planning to release a lot of memory, avoiding this race window
can save somebody from being OOM-killed needlessly. This race window depends on
what the threads are about to do, not whether the workload is natural or
artificial.

My question is, how can users know it if somebody was OOM-killed needlessly
by allowing MMF_OOM_SKIP to race.

> Anyway, the change you are proposing is wrong for two reasons. First,
> you are in non-preemptible context in oom_evaluate_task so you cannot
> call into get_page_from_freelist (node_reclaim) and secondly it is a
> very specific hack while there is a whole category of possible races
> where someone frees memory (e.g. and exiting task which smells like what
> you see in your testing) while we are selecting an oom victim which
> can be quite an expensive operation.

Oh, I didn't know that get_page_from_freelist() might sleep.
I was assuming that get_page_from_freelist() never sleeps because it is
called from !can_direct_reclaim context. But looking into that function,
it is gfpflags_allow_blocking() from node_reclaim() from
get_page_from_freelist() that prevents !can_direct_reclaim context from
sleeping.

OK. I have to either mask __GFP_DIRECT_RECLAIM or postpone till
oom_kill_process(). Well, I came to worry about get_page_from_freelist()
at __alloc_pages_may_oom() which is called after oom_lock is taken.

Is it guaranteed that __node_reclaim() never (even indirectly) waits for
__GFP_DIRECT_RECLAIM && !__GFP_NORETRY memory allocation? If it is not
guaranteed, calling __alloc_pages_may_oom(__GFP_DIRECT_RECLAIM) with oom_lock
taken can prevent __GFP_DIRECT_RECLAIM && !__GFP_NORETRY memory allocation from
completing (because did_some_progress will be forever set to 1 due to oom_lock
already taken). A possible location of OOM lockup unless it is guaranteed.

>                                      Such races are unfortunate but
> unavoidable unless we synchronize oom kill with any memory freeing which
> smells like a no-go to me. We can try a last allocation attempt right
> before we go and kill something (which still wouldn't be race free) but
> that might cause other issues - e.g. prolonged trashing without ever
> killing something - but I haven't evaluated those to be honest.

Yes, postpone last get_page_from_freelist() attempt till oom_kill_process()
will be what we would afford at best.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

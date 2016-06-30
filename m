Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ob0-f200.google.com (mail-ob0-f200.google.com [209.85.214.200])
	by kanga.kvack.org (Postfix) with ESMTP id 153D86B0005
	for <linux-mm@kvack.org>; Thu, 30 Jun 2016 06:52:04 -0400 (EDT)
Received: by mail-ob0-f200.google.com with SMTP id fq2so162939628obb.2
        for <linux-mm@kvack.org>; Thu, 30 Jun 2016 03:52:04 -0700 (PDT)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [2001:e42:101:1:202:181:97:72])
        by mx.google.com with ESMTPS id 19si812170iti.21.2016.06.30.03.52.02
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 30 Jun 2016 03:52:03 -0700 (PDT)
Subject: Re: [PATCH] mm,oom: use per signal_struct flag rather than clear TIF_MEMDIE
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
References: <20160628101956.GA510@dhcp22.suse.cz>
	<20160629001353.GA9377@redhat.com>
	<20160629083314.GA27153@dhcp22.suse.cz>
	<20160629200108.GA19253@redhat.com>
	<20160630075904.GC18783@dhcp22.suse.cz>
In-Reply-To: <20160630075904.GC18783@dhcp22.suse.cz>
Message-Id: <201606301951.AAB26052.OtOOQMLHVFJSFF@I-love.SAKURA.ne.jp>
Date: Thu, 30 Jun 2016 19:51:53 +0900
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: mhocko@kernel.org, oleg@redhat.com
Cc: linux-mm@kvack.org, vdavydov@virtuozzo.com, rientjes@google.com

Michal Hocko wrote:
> On Wed 29-06-16 22:01:08, Oleg Nesterov wrote:
> > On 06/29, Michal Hocko wrote:
> > >
> > > > > +void mark_oom_victim(struct task_struct *tsk, struct mm_struct *mm)
> > > > >  {
> > > > >  	WARN_ON(oom_killer_disabled);
> > > > >  	/* OOM killer might race with memcg OOM */
> > > > >  	if (test_and_set_tsk_thread_flag(tsk, TIF_MEMDIE))
> > > > >  		return;
> > > > > +
> > > > >  	atomic_inc(&tsk->signal->oom_victims);
> > > > > +
> > > > > +	/* oom_mm is bound to the signal struct life time */
> > > > > +	if (!tsk->signal->oom_mm) {
> > > > > +		atomic_inc(&mm->mm_count);
> > > > > +		tsk->signal->oom_mm = mm;
> > > >
> > > > Looks racy, but it is not because we rely on oom_lock? Perhaps a comment
> > > > makes sense.
> > >
> > > mark_oom_victim will be called only for the current or under the
> > > task_lock so it should be stable. Except for...
> > 
> > I meant that the code looks racy because 2 threads can see ->oom_mm == NULL
> > at the same time and in this case we have the extra atomic_inc(mm_count).
> > But I guess oom_lock saves us, so the code is correct but not clear.
> 
> I have changed that to cmpxchg because lowmemory killer is called
> outside of oom_lock.

Android's lowmemory killer is no longer using mark_oom_victim().

> > Btw, do we still need this list_for_each_entry(child, &t->children, sibling)
> > loop in oom_kill_process() ?
> 
> Well, to be honest, I don't know. This is a heuristic we have been doing
> for a long time. I do not know how many times it really matters. It can
> even be harmful in loads where children are created in the same pace OOM
> killer is killing them. Not sure how likely is that though...
> Let me think whether we can do something about that.

I'm using that behavior in order to test almost OOM situation. ;)



By the way, are you going to fix use_mm() race? Currently, we don't wake up
OOM reaper if some kernel thread is holding a reference to that mm via
use_mm(). But currently we can hit

  (1) OOM killer fails to find use_mm() users using for_each_process() in
      oom_kill_process() and wakes up OOM reaper.

  (2) Some kernel thread calls use_mm().

  (3) OOM reaper ignores use_mm() users and reaps that mm.

race. I think we need to make use_mm() fail after mark_oom_victim() is called.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

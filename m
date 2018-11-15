Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f69.google.com (mail-ed1-f69.google.com [209.85.208.69])
	by kanga.kvack.org (Postfix) with ESMTP id 8F3806B02A0
	for <linux-mm@kvack.org>; Thu, 15 Nov 2018 06:36:57 -0500 (EST)
Received: by mail-ed1-f69.google.com with SMTP id m45-v6so9912377edc.2
        for <linux-mm@kvack.org>; Thu, 15 Nov 2018 03:36:57 -0800 (PST)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id s28-v6si5932735edd.159.2018.11.15.03.36.55
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 15 Nov 2018 03:36:55 -0800 (PST)
Date: Thu, 15 Nov 2018 12:36:53 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [RFC PATCH v2 0/3] oom: rework oom_reaper vs. exit_mmap handoff
Message-ID: <20181115113653.GO23831@dhcp22.suse.cz>
References: <20181025082403.3806-1-mhocko@kernel.org>
 <20181108093224.GS27423@dhcp22.suse.cz>
 <9dfd5c87-ae48-8ffb-fbc6-706d627658ff@i-love.sakura.ne.jp>
 <20181114101604.GM23419@dhcp22.suse.cz>
 <0648083a-3112-97ff-edd7-1444c1be529a@i-love.sakura.ne.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <0648083a-3112-97ff-edd7-1444c1be529a@i-love.sakura.ne.jp>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>
Cc: David Rientjes <rientjes@google.com>, Roman Gushchin <guro@fb.com>, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>, Linus Torvalds <torvalds@linux-foundation.org>

On Thu 15-11-18 18:54:15, Tetsuo Handa wrote:
> On 2018/11/14 19:16, Michal Hocko wrote:
> > On Wed 14-11-18 18:46:13, Tetsuo Handa wrote:
> > [...]
> > > There is always an invisible lock called "scheduling priority". You can't
> > > leave the MMF_OOM_SKIP to the exit path. Your approach is not ready for
> > > handling the worst case.
> > 
> > And that problem is all over the memory reclaim. You can get starved
> > to death and block other resources. And the memory reclaim is not the
> > only one.
> 
> I think that it is a manner for kernel developers that no thread keeps
> consuming CPU resources forever. In the kernel world, doing
> 
>   while (1);
> 
> is not permitted. Likewise, doing
> 
>   for (i = 0; i < very_large_value; i++)
>       do_something_which_does_not_yield_CPU_to_others();

There is nothing like that proposed in this series.

> has to be avoided, in order to avoid lockup problems. We are required to
> yield CPU to others when we are waiting for somebody else to make progress.
> It is the page allocator who is refusing to yield CPU to those who need CPU.

And we do that in the reclaim path.

> Since the OOM reaper kernel thread "has normal priority" and "can run on any
> CPU", the possibility of failing to run is lower than an OOM victim thread
> which "has idle priority" and "can run on only limited CPU". You are trying
> to add a dependency on such thread, and I'm saying that adding a dependency
> on such thread increases possibility of lockup.

Sigh. No, this is not the case. All this patch series does is that we
hand over to the exiting task once it doesn't block on any locks
anymore. If the thread is low priority then it is quite likely that the
oom reaper is done by the time the victim even reaches the exit path.

> Yes, even the OOM reaper kernel thread might fail to run if all CPUs were
> busy with realtime threads waiting for the OOM reaper kernel thread to make
> progress. In that case, we had better stop relying on asynchronous memory
> reclaim, and switch to direct OOM reaping by allocating threads.
> 
> But what I demonstrated is that
> 
>         /*
>          * the exit path is guaranteed to finish the memory tear down
>          * without any unbound blocking at this stage so make it clear
>          * to the oom_reaper
>          */
> 
> becomes a lie even when only one CPU was busy with realtime threads waiting
> for an idle thread to make progress. If the page allocator stops telling a
> lie that "an OOM victim is making progress on behalf of me", we can avoid
> the lockup.

OK, I stopped reading right here. This discussion is pointless. Once you
busy loop all CPUs you are screwed. Are you going to blame a filesystem
that no progress can be made if a code path holding an important lock
is preemempted by high priority stuff a no further progress can be
made? This is just ridiculous. What you are arguing here is not fixable
with the current upstream kernel. Even your so beloved timeout based
solution doesn't cope with that because oom reaper can be preempted for
unbound amount of time. Your argument just doens't make much sense in
the context of the current kernel. Full stop.
-- 
Michal Hocko
SUSE Labs

Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f197.google.com (mail-wr0-f197.google.com [209.85.128.197])
	by kanga.kvack.org (Postfix) with ESMTP id 46B0C6B0038
	for <linux-mm@kvack.org>; Tue, 24 Oct 2017 07:41:08 -0400 (EDT)
Received: by mail-wr0-f197.google.com with SMTP id o88so8517394wrb.18
        for <linux-mm@kvack.org>; Tue, 24 Oct 2017 04:41:08 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id o16si64007wra.403.2017.10.24.04.41.06
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 24 Oct 2017 04:41:06 -0700 (PDT)
Date: Tue, 24 Oct 2017 13:41:04 +0200
From: Michal Hocko <mhocko@suse.com>
Subject: Re: [RFC PATCH 2/2] mm,oom: Try last second allocation after
 selecting an OOM victim.
Message-ID: <20171024114104.twg73jvyjevovkjm@dhcp22.suse.cz>
References: <201709090955.HFA57316.QFOSVMtFOJLFOH@I-love.SAKURA.ne.jp>
 <201710172204.AGG30740.tVHJFFOQLMSFOO@I-love.SAKURA.ne.jp>
 <20171020124009.joie5neol3gbdmxe@dhcp22.suse.cz>
 <201710202318.IJE26050.SFVFMOLHQJOOtF@I-love.SAKURA.ne.jp>
 <20171023113057.bdfte7ihtklhjbdy@dhcp22.suse.cz>
 <201710242024.EDH13579.VQLFtFFMOOHSOJ@I-love.SAKURA.ne.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <201710242024.EDH13579.VQLFtFFMOOHSOJ@I-love.SAKURA.ne.jp>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Cc: aarcange@redhat.com, hannes@cmpxchg.org, akpm@linux-foundation.org, linux-mm@kvack.org, rientjes@google.com, mjaggi@caviumnetworks.com, mgorman@suse.de, oleg@redhat.com, vdavydov.dev@gmail.com, vbabka@suse.cz

On Tue 24-10-17 20:24:46, Tetsuo Handa wrote:
> Michal Hocko wrote:
[...]
> > > So, I think that worrying about high priority threads preventing the low
> > > priority thread with oom_lock held is too much. Preventing high priority
> > > threads waiting for oom_lock from disturbing the low priority thread with
> > > oom_lock held by wasting CPU resource will be sufficient.
> > 
> > In other words this is just to paper over an overloaded allocation path
> > close to OOM. Your changelog is really misleading in that direction
> > IMHO. I have to think some more about using the full lock rather than
> > the trylock, because taking the try lock is somehow easier.
> 
> Somehow easier to what? Please don't omit.

To back off on the oom races.

> I consider that the OOM killer is a safety mechanism in case a system got
> overloaded. Therefore, I really hate your comments like "Your system is already
> DOSed". It is stupid thing that safety mechanism drives the overloaded system
> worse and defunctional when it should rescue.

The OOM killer is the last hand break. At the time you hit the OOM
condition your system is usually hard to use anyway. And that is why I
do care to make this path deadlock free. I have mentioned multiple times
that I find real life triggers much more important than artificial DoS
like workloads which make your system unsuable long before you hit OOM
killer.

> Current code is somehow easier to OOM lockup due to printk() versus oom_lock
> dependency, and I'm proposing a patch for mitigating printk() versus oom_lock
> dependency using oom_printk_lock because I can hardly examine OOM related
> problems since linux-4.9, and your response was "Hell no!".

Because you are repeatedly proposing a paper over rather than to attempt
something resembling a solution. And this is highly annoying. I've
already said that I am willing to sacrifice the stall warning rather
than fiddle with random locks put here and there.

> > > If you don't like it, the only way will be to offload to a dedicated
> > > kernel thread (like the OOM reaper) so that allocating threads are
> > > no longer blocked by oom_lock. That's a big change.
> > 
> > This doesn't solve anything as all the tasks would have to somehow wait
> > for the kernel thread to do its stuff.
> 
> Which direction are you looking at?

I am sorry but I would only repeat something that has been said many
times already. You keep hammering this particular issue like it was the
number one problem in the MM code. We have many much more important
issues to deal with. While it is interesting to make kernel more robust
under OOM conditions it doesn't make much sense to overcomplicate the
code for unrealistic workloads. If we have problems with real life
scenarios then let's fix them, by all means.
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f69.google.com (mail-ed1-f69.google.com [209.85.208.69])
	by kanga.kvack.org (Postfix) with ESMTP id 1E7F96B1EF1
	for <linux-mm@kvack.org>; Tue, 21 Aug 2018 10:06:17 -0400 (EDT)
Received: by mail-ed1-f69.google.com with SMTP id d47-v6so2776902edb.3
        for <linux-mm@kvack.org>; Tue, 21 Aug 2018 07:06:17 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id d4-v6si8896982edl.365.2018.08.21.07.06.15
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 21 Aug 2018 07:06:15 -0700 (PDT)
Date: Tue, 21 Aug 2018 16:06:12 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH 2/2] memcg, oom: emit oom report when there is no
 eligible task
Message-ID: <20180821140612.GD16611@dhcp22.suse.cz>
References: <20180808064414.GA27972@dhcp22.suse.cz>
 <20180808071301.12478-1-mhocko@kernel.org>
 <20180808071301.12478-3-mhocko@kernel.org>
 <20180808144515.GA9276@cmpxchg.org>
 <20180808161737.GQ27972@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180808161737.GQ27972@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Vladimir Davydov <vdavydov.dev@gmail.com>, Greg Thelen <gthelen@google.com>, Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, Dmitry Vyukov <dvyukov@google.com>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>

Do you plan to repost these two? They are quite deep in the email thread
so they can easily fall through cracks.

On Wed 08-08-18 18:17:37, Michal Hocko wrote:
> On Wed 08-08-18 10:45:15, Johannes Weiner wrote:
[...]
> > >From bba01122f739b05a689dbf1eeeb4f0e07affd4e7 Mon Sep 17 00:00:00 2001
> > From: Johannes Weiner <hannes@cmpxchg.org>
> > Date: Wed, 8 Aug 2018 09:59:40 -0400
> > Subject: [PATCH] mm: memcontrol: print proper OOM header when no eligible
> >  victim left
> > 
> > When the memcg OOM killer runs out of killable tasks, it currently
> > prints a WARN with no further OOM context. This has caused some user
> > confusion.
> > 
> > Warnings indicate a kernel problem. In a reported case, however, the
> > situation was triggered by a non-sensical memcg configuration (hard
> > limit set to 0). But without any VM context this wasn't obvious from
> > the report, and it took some back and forth on the mailing list to
> > identify what is actually a trivial issue.
> > 
> > Handle this OOM condition like we handle it in the global OOM killer:
> > dump the full OOM context and tell the user we ran out of tasks.
> > 
> > This way the user can identify misconfigurations easily by themselves
> > and rectify the problem - without having to go through the hassle of
> > running into an obscure but unsettling warning, finding the
> > appropriate kernel mailing list and waiting for a kernel developer to
> > remote-analyze that the memcg configuration caused this.
> > 
> > If users cannot make sense of why the OOM killer was triggered or why
> > it failed, they will still report it to the mailing list, we know that
> > from experience. So in case there is an actual kernel bug causing
> > this, kernel developers will very likely hear about it.
> > 
> > Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>
> 
> Yes this works as well. We would get a dump even for the race we have
> seen but I do not think this is something to lose sleep over. And if it
> triggers too often to be disturbing we can add
> tsk_is_oom_victim(current) check there.
> 
> Acked-by: Michal Hocko <mhocko@suse.com>
> 
> > ---
> >  mm/memcontrol.c |  2 --
> >  mm/oom_kill.c   | 13 ++++++++++---
> >  2 files changed, 10 insertions(+), 5 deletions(-)
> > 
> > diff --git a/mm/memcontrol.c b/mm/memcontrol.c
> > index 4e3c1315b1de..29d9d1a69b36 100644
> > --- a/mm/memcontrol.c
> > +++ b/mm/memcontrol.c
> > @@ -1701,8 +1701,6 @@ static enum oom_status mem_cgroup_oom(struct mem_cgroup *memcg, gfp_t mask, int
> >  	if (mem_cgroup_out_of_memory(memcg, mask, order))
> >  		return OOM_SUCCESS;
> >  
> > -	WARN(1,"Memory cgroup charge failed because of no reclaimable memory! "
> > -		"This looks like a misconfiguration or a kernel bug.");
> >  	return OOM_FAILED;
> >  }
> >  
> > diff --git a/mm/oom_kill.c b/mm/oom_kill.c
> > index 0e10b864e074..07ae222d7830 100644
> > --- a/mm/oom_kill.c
> > +++ b/mm/oom_kill.c
> > @@ -1103,10 +1103,17 @@ bool out_of_memory(struct oom_control *oc)
> >  	}
> >  
> >  	select_bad_process(oc);
> > -	/* Found nothing?!?! Either we hang forever, or we panic. */
> > -	if (!oc->chosen && !is_sysrq_oom(oc) && !is_memcg_oom(oc)) {
> > +	/* Found nothing?!?! */
> > +	if (!oc->chosen) {
> >  		dump_header(oc, NULL);
> > -		panic("Out of memory and no killable processes...\n");
> > +		pr_warn("Out of memory and no killable processes...\n");
> > +		/*
> > +		 * If we got here due to an actual allocation at the
> > +		 * system level, we cannot survive this and will enter
> > +		 * an endless loop in the allocator. Bail out now.
> > +		 */
> > +		if (!is_sysrq_oom(oc) && !is_memcg_oom(oc))
> > +			panic("System is deadlocked on memory\n");
> >  	}
> >  	if (oc->chosen && oc->chosen != (void *)-1UL)
> >  		oom_kill_process(oc, !is_memcg_oom(oc) ? "Out of memory" :
> > -- 
> > 2.18.0
> > 
> 
> -- 
> Michal Hocko
> SUSE Labs

-- 
Michal Hocko
SUSE Labs

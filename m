Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f69.google.com (mail-wm0-f69.google.com [74.125.82.69])
	by kanga.kvack.org (Postfix) with ESMTP id 6989E6B02F4
	for <linux-mm@kvack.org>; Mon, 26 Jun 2017 07:55:35 -0400 (EDT)
Received: by mail-wm0-f69.google.com with SMTP id b184so637437wme.14
        for <linux-mm@kvack.org>; Mon, 26 Jun 2017 04:55:35 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id p46si11587216wrc.128.2017.06.26.04.55.33
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Mon, 26 Jun 2017 04:55:34 -0700 (PDT)
Date: Mon, 26 Jun 2017 13:55:31 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [RFC PATCH v2 0/7] cgroup-aware OOM killer
Message-ID: <20170626115531.GI11534@dhcp22.suse.cz>
References: <1496342115-3974-1-git-send-email-guro@fb.com>
 <20170609163022.GA9332@dhcp22.suse.cz>
 <20170622171003.GB30035@castle>
 <20170623134323.GB5314@dhcp22.suse.cz>
 <20170623183946.GA24014@castle>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170623183946.GA24014@castle>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Roman Gushchin <guro@fb.com>
Cc: linux-mm@kvack.org

On Fri 23-06-17 19:39:46, Roman Gushchin wrote:
> On Fri, Jun 23, 2017 at 03:43:24PM +0200, Michal Hocko wrote:
> > On Thu 22-06-17 18:10:03, Roman Gushchin wrote:
> > > Hi, Michal!
> > > 
> > > Thank you very much for the review. I've tried to address your
> > > comments in v3 (sent yesterday), so that is why it took some time to reply.
> > 
> > I will try to look at it sometimes next week hopefully
> 
> Thanks!
> 
> > > > - You seem to completely ignore per task oom_score_adj and override it
> > > >   by the memcg value. This makes some sense but it can lead to an
> > > >   unexpected behavior when somebody relies on the original behavior.
> > > >   E.g. a workload that would corrupt data when killed unexpectedly and
> > > >   so it is protected by OOM_SCORE_ADJ_MIN. Now this assumption will
> > > >   break when running inside a container. I do not have a good answer
> > > >   what is the desirable behavior and maybe there is no universal answer.
> > > >   Maybe you just do not to kill those tasks? But then you have to be
> > > >   careful when selecting a memcg victim. Hairy...
> > > 
> > > I do not ignore it completely, but it matters only for root cgroup tasks
> > > and inside a cgroup when oom_kill_all_tasks is off.
> > > 
> > > I believe, that cgroup v2 requirement is a good enough. I mean you can't
> > > move from v1 to v2 without changing cgroup settings, and if we will provide
> > > per-cgroup oom_score_adj, it will be enough to reproduce the old behavior.
> > > 
> > > Also, if you think it's necessary, I can add a sysctl to turn the cgroup-aware
> > > oom killer off completely and provide compatibility mode.
> > > We can't really save the old system-wide behavior of per-process oom_score_adj,
> > > it makes no sense in the containerized environment.
> > 
> > So what you are going to do with those applications that simply cannot
> > be killed and which set OOM_SCORE_ADJ_MIN explicitly. Are they
> > unsupported? How does a user find out? One way around this could be to
> > simply to not kill tasks with OOM_SCORE_ADJ_MIN.
> 
> They won't be killed by cgroup OOM, but under some circumstances can be killed
> by the global OOM (e.g. there are no other tasks in the selected cgroup,
> cgroup v2 is used, and per-cgroup oom score adjustment is not set).

Hmm, mem_cgroup_select_oom_victim will happily select a memcg which
contains OOM_SCORE_ADJ_MIN tasks because it ignores per-task score adj.
So memcg OOM killer can kill those tasks AFAICS. But that is not all
that important. Becasuse...

> I believe, that per-process oom_score_adj should not play any role outside
> of the containing cgroup, it's violation of isolation.
> 
> Right now if tasks with oom_score_adj=-1000 eating all memory in a cgroup,
> they will be looping forever, OOM killer can't fix this.

... Yes and that is a price we have to pay for the hard requirement
that oom killer never kills OOM_SCORE_ADJ_MIN task. It is hard to
change that without breaking any existing userspace which relies on the
configuration to protect from an unexpected SIGKILL.

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

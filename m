Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f198.google.com (mail-wr0-f198.google.com [209.85.128.198])
	by kanga.kvack.org (Postfix) with ESMTP id 88CCC6B0292
	for <linux-mm@kvack.org>; Fri, 23 Jun 2017 14:40:08 -0400 (EDT)
Received: by mail-wr0-f198.google.com with SMTP id v60so14966061wrc.7
        for <linux-mm@kvack.org>; Fri, 23 Jun 2017 11:40:08 -0700 (PDT)
Received: from mx0b-00082601.pphosted.com (mx0b-00082601.pphosted.com. [67.231.153.30])
        by mx.google.com with ESMTPS id u13si4997646wrc.318.2017.06.23.11.40.06
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 23 Jun 2017 11:40:06 -0700 (PDT)
Date: Fri, 23 Jun 2017 19:39:46 +0100
From: Roman Gushchin <guro@fb.com>
Subject: Re: [RFC PATCH v2 0/7] cgroup-aware OOM killer
Message-ID: <20170623183946.GA24014@castle>
References: <1496342115-3974-1-git-send-email-guro@fb.com>
 <20170609163022.GA9332@dhcp22.suse.cz>
 <20170622171003.GB30035@castle>
 <20170623134323.GB5314@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Disposition: inline
In-Reply-To: <20170623134323.GB5314@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: linux-mm@kvack.org

On Fri, Jun 23, 2017 at 03:43:24PM +0200, Michal Hocko wrote:
> On Thu 22-06-17 18:10:03, Roman Gushchin wrote:
> > Hi, Michal!
> > 
> > Thank you very much for the review. I've tried to address your
> > comments in v3 (sent yesterday), so that is why it took some time to reply.
> 
> I will try to look at it sometimes next week hopefully

Thanks!

> > > - You seem to completely ignore per task oom_score_adj and override it
> > >   by the memcg value. This makes some sense but it can lead to an
> > >   unexpected behavior when somebody relies on the original behavior.
> > >   E.g. a workload that would corrupt data when killed unexpectedly and
> > >   so it is protected by OOM_SCORE_ADJ_MIN. Now this assumption will
> > >   break when running inside a container. I do not have a good answer
> > >   what is the desirable behavior and maybe there is no universal answer.
> > >   Maybe you just do not to kill those tasks? But then you have to be
> > >   careful when selecting a memcg victim. Hairy...
> > 
> > I do not ignore it completely, but it matters only for root cgroup tasks
> > and inside a cgroup when oom_kill_all_tasks is off.
> > 
> > I believe, that cgroup v2 requirement is a good enough. I mean you can't
> > move from v1 to v2 without changing cgroup settings, and if we will provide
> > per-cgroup oom_score_adj, it will be enough to reproduce the old behavior.
> > 
> > Also, if you think it's necessary, I can add a sysctl to turn the cgroup-aware
> > oom killer off completely and provide compatibility mode.
> > We can't really save the old system-wide behavior of per-process oom_score_adj,
> > it makes no sense in the containerized environment.
> 
> So what you are going to do with those applications that simply cannot
> be killed and which set OOM_SCORE_ADJ_MIN explicitly. Are they
> unsupported? How does a user find out? One way around this could be to
> simply to not kill tasks with OOM_SCORE_ADJ_MIN.

They won't be killed by cgroup OOM, but under some circumstances can be killed
by the global OOM (e.g. there are no other tasks in the selected cgroup,
cgroup v2 is used, and per-cgroup oom score adjustment is not set).

I believe, that per-process oom_score_adj should not play any role outside
of the containing cgroup, it's violation of isolation.

Right now if tasks with oom_score_adj=-1000 eating all memory in a cgroup,
they will be looping forever, OOM killer can't fix this.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

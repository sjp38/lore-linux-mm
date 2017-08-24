Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f197.google.com (mail-wr0-f197.google.com [209.85.128.197])
	by kanga.kvack.org (Postfix) with ESMTP id D3D2F440846
	for <linux-mm@kvack.org>; Thu, 24 Aug 2017 10:58:30 -0400 (EDT)
Received: by mail-wr0-f197.google.com with SMTP id a110so1285412wrc.1
        for <linux-mm@kvack.org>; Thu, 24 Aug 2017 07:58:30 -0700 (PDT)
Received: from mx0b-00082601.pphosted.com (mx0b-00082601.pphosted.com. [67.231.153.30])
        by mx.google.com with ESMTPS id p19si3685924wrc.553.2017.08.24.07.58.28
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 24 Aug 2017 07:58:29 -0700 (PDT)
Date: Thu, 24 Aug 2017 15:58:01 +0100
From: Roman Gushchin <guro@fb.com>
Subject: Re: [v6 2/4] mm, oom: cgroup-aware OOM killer
Message-ID: <20170824145801.GA23457@castle.DHCP.thefacebook.com>
References: <20170823165201.24086-1-guro@fb.com>
 <20170823165201.24086-3-guro@fb.com>
 <20170824114706.GG5943@dhcp22.suse.cz>
 <20170824122846.GA15916@castle.DHCP.thefacebook.com>
 <20170824125811.GK5943@dhcp22.suse.cz>
 <20170824135842.GA21167@castle.DHCP.thefacebook.com>
 <20170824141336.GP5943@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Disposition: inline
In-Reply-To: <20170824141336.GP5943@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: linux-mm@kvack.org, Vladimir Davydov <vdavydov.dev@gmail.com>, Johannes Weiner <hannes@cmpxchg.org>, Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, David Rientjes <rientjes@google.com>, Tejun Heo <tj@kernel.org>, kernel-team@fb.com, cgroups@vger.kernel.org, linux-doc@vger.kernel.org, linux-kernel@vger.kernel.org

On Thu, Aug 24, 2017 at 04:13:37PM +0200, Michal Hocko wrote:
> On Thu 24-08-17 14:58:42, Roman Gushchin wrote:
> > On Thu, Aug 24, 2017 at 02:58:11PM +0200, Michal Hocko wrote:
> > > On Thu 24-08-17 13:28:46, Roman Gushchin wrote:
> > > > Hi Michal!
> > > > 
> > > There is nothing like a "better victim". We are pretty much in a
> > > catastrophic situation when we try to survive by killing a userspace.
> > 
> > Not necessary, it can be a cgroup OOM.
> 
> memcg OOM is no different. The catastrophic is scoped to the specific
> hierarchy but tasks in that hierarchy still fail to make a further
> progress.
> 
> > > We try to kill the largest because that assumes that we return the
> > > most memory from it. Now I do understand that you want to treat the
> > > memcg as a single killable entity but I find it really questionable
> > > to do a per-memcg metric and then do not treat it like that and kill
> > > only a single task. Just imagine a single memcg with zillions of taks
> > > each very small and you select it as the largest while a small taks
> > > itself doesn't help to help to get us out of the OOM.
> > 
> > I don't think it's different from a non-containerized state: if you
> > have a zillion of small tasks in the system, you'll meet the same issues.
> 
> Yes this is possible but usually you are comparing apples to apples so
> you will kill the largest offender and then go on. To be honest I really
> do hate how we try to kill a children rather than the selected victim
> for the same reason.

I do hate it too.

> 
> > > > > I guess I have asked already and we haven't reached any consensus. I do
> > > > > not like how you treat memcgs and tasks differently. Why cannot we have
> > > > > a memcg score a sum of all its tasks?
> > > > 
> > > > It sounds like a more expensive way to get almost the same with less accuracy.
> > > > Why it's better?
> > > 
> > > because then you are comparing apples to apples?
> > 
> > Well, I can say that I compare some number of pages against some other number
> > of pages. And the relation between a page and memcg is more obvious, than a
> > relation between a page and a process.
> 
> But you are comparing different accounting systems.
>  
> > Both ways are not ideal, and sum of the processes is not ideal too.
> > Especially, if you take oom_score_adj into account. Will you respect it?
> 
> Yes, and I do not see any reason why we shouldn't.

It makes things even more complicated.
Right now task's oom_score can be in (~ -total_memory, ~ +2*total_memory) range,
and it you're starting summing it, it can be multiplied by number of tasks...
Weird.
It also will be different in case of system and memcg-wide OOM.

> 
> > I've started actually with such approach, but then found it weird.
> > 
> > > Besides that you have
> > > to check each task for over-killing anyway. So I do not see any
> > > performance merits here.
> > 
> > It's an implementation detail, and we can hopefully get rid of it at some point.
> 
> Well, we might do some estimations and ignore oom scopes but I that
> sounds really complicated and error prone. Unless we have anything like
> that then I would start from tasks and build up the necessary to make a
> decision at the higher level.

Seriously speaking, do you have an example, when summing per-process
oom_score will work better?

Especially, if we're talking about customizing oom_score calculation,
it makes no sence to me. How you will sum process timestamps?

>  
> > > > > How do you want to compare memcg score with tasks score?
> > > > 
> > > > I have to do it for tasks in root cgroups, but it shouldn't be a common case.
> > > 
> > > How come? I can easily imagine a setup where only some memcgs which
> > > really do need a kill-all semantic while all others can live with single
> > > task killed perfectly fine.
> > 
> > I mean taking a unified cgroup hierarchy into an account, there should not
> > be lot of tasks in the root cgroup, if any.
> 
> Is that really the case? I would assume that memory controller would be
> enabled only in those subtrees which really use the functionality and
> the rest will be sitting in the root memcg. It might be the case if you
> are running only containers but I am not really sure this is true in
> general.

Agree.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

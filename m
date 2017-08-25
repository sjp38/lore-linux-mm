Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f200.google.com (mail-wr0-f200.google.com [209.85.128.200])
	by kanga.kvack.org (Postfix) with ESMTP id 094F66B03C1
	for <linux-mm@kvack.org>; Fri, 25 Aug 2017 04:14:08 -0400 (EDT)
Received: by mail-wr0-f200.google.com with SMTP id z91so2319033wrc.1
        for <linux-mm@kvack.org>; Fri, 25 Aug 2017 01:14:07 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id s6si822645wma.226.2017.08.25.01.14.06
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Fri, 25 Aug 2017 01:14:06 -0700 (PDT)
Date: Fri, 25 Aug 2017 10:14:03 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [v6 2/4] mm, oom: cgroup-aware OOM killer
Message-ID: <20170825081402.GG25498@dhcp22.suse.cz>
References: <20170823165201.24086-1-guro@fb.com>
 <20170823165201.24086-3-guro@fb.com>
 <20170824114706.GG5943@dhcp22.suse.cz>
 <20170824122846.GA15916@castle.DHCP.thefacebook.com>
 <20170824125811.GK5943@dhcp22.suse.cz>
 <20170824135842.GA21167@castle.DHCP.thefacebook.com>
 <20170824141336.GP5943@dhcp22.suse.cz>
 <20170824145801.GA23457@castle.DHCP.thefacebook.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170824145801.GA23457@castle.DHCP.thefacebook.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Roman Gushchin <guro@fb.com>
Cc: linux-mm@kvack.org, Vladimir Davydov <vdavydov.dev@gmail.com>, Johannes Weiner <hannes@cmpxchg.org>, Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, David Rientjes <rientjes@google.com>, Tejun Heo <tj@kernel.org>, kernel-team@fb.com, cgroups@vger.kernel.org, linux-doc@vger.kernel.org, linux-kernel@vger.kernel.org

On Thu 24-08-17 15:58:01, Roman Gushchin wrote:
> On Thu, Aug 24, 2017 at 04:13:37PM +0200, Michal Hocko wrote:
> > On Thu 24-08-17 14:58:42, Roman Gushchin wrote:
[...]
> > > Both ways are not ideal, and sum of the processes is not ideal too.
> > > Especially, if you take oom_score_adj into account. Will you respect it?
> > 
> > Yes, and I do not see any reason why we shouldn't.
> 
> It makes things even more complicated.
> Right now task's oom_score can be in (~ -total_memory, ~ +2*total_memory) range,
> and it you're starting summing it, it can be multiplied by number of tasks...
> Weird.

oom_score_adj is just a normalized bias so if tasks inside oom will use
it the whole memcg will get accumulated bias from all such tasks so it
is not completely off. I agree that the more tasks use the bias the more
biased the whole memcg will be. This might or might not be a problem.
As you are trying to reimplement the existing oom killer implementation
I do not think we cannot simply ignore API which people are used to.

If this was a configurable oom policy then I could see how ignoring
oom_score_adj is acceptable because it would be an explicit opt-in.

> It also will be different in case of system and memcg-wide OOM.

Why, we do honor oom_score_adj for the memcg OOM now and in fact the
kernel memcg OOM killer shouldn't be very much different from the global
one except for the tasks scope.

> > > I've started actually with such approach, but then found it weird.
> > > 
> > > > Besides that you have
> > > > to check each task for over-killing anyway. So I do not see any
> > > > performance merits here.
> > > 
> > > It's an implementation detail, and we can hopefully get rid of it at some point.
> > 
> > Well, we might do some estimations and ignore oom scopes but I that
> > sounds really complicated and error prone. Unless we have anything like
> > that then I would start from tasks and build up the necessary to make a
> > decision at the higher level.
> 
> Seriously speaking, do you have an example, when summing per-process
> oom_score will work better?

The primary reason I am pushing for this is to have the common iterator
code path (which we have since Vladimir has unified memcg and global oom
paths) and only parametrize the value calculation and victim selection.

> Especially, if we're talking about customizing oom_score calculation,
> it makes no sence to me. How you will sum process timestamps?

Well, I meant you could sum oom_badness for your particular
implementation. If we need some other policy then this wouldn't work and
that's why I've said that I would like to preserve the current common
code and only parametrize value calculation and victim selection...
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

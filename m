Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f199.google.com (mail-wr0-f199.google.com [209.85.128.199])
	by kanga.kvack.org (Postfix) with ESMTP id 5291F800D8
	for <linux-mm@kvack.org>; Tue, 23 Jan 2018 10:13:05 -0500 (EST)
Received: by mail-wr0-f199.google.com with SMTP id 31so438639wri.9
        for <linux-mm@kvack.org>; Tue, 23 Jan 2018 07:13:05 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id a18si418733wrg.175.2018.01.23.07.13.03
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 23 Jan 2018 07:13:03 -0800 (PST)
Date: Tue, 23 Jan 2018 16:13:00 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [patch -mm 3/4] mm, memcg: replace memory.oom_group with policy
 tunable
Message-ID: <20180123151300.GP1526@dhcp22.suse.cz>
References: <alpine.DEB.2.10.1801161812550.28198@chino.kir.corp.google.com>
 <alpine.DEB.2.10.1801161814130.28198@chino.kir.corp.google.com>
 <20180117154155.GU3460072@devbig577.frc2.facebook.com>
 <20180117160004.GH2900@dhcp22.suse.cz>
 <alpine.DEB.2.10.1801171415200.86895@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.10.1801171415200.86895@chino.kir.corp.google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: Tejun Heo <tj@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Roman Gushchin <guro@fb.com>, Vladimir Davydov <vdavydov.dev@gmail.com>, Johannes Weiner <hannes@cmpxchg.org>, Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>, kernel-team@fb.com, cgroups@vger.kernel.org, linux-doc@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Wed 17-01-18 14:18:33, David Rientjes wrote:
> On Wed, 17 Jan 2018, Michal Hocko wrote:
> 
> > Absolutely agreed! And moreover, there are not all that many ways what
> > to do as an action. You just kill a logical entity - be it a process or
> > a logical group of processes. But you have way too many policies how
> > to select that entity. Do you want to chose the youngest process/group
> > because all the older ones have been computing real stuff and you would
> > lose days of your cpu time? Or should those who pay more should be
> > protected (aka give them static priorities), or you name it...
> > 
> 
> That's an argument for making the interface extensible, yes.

And there is no interface to control the selection yet so we can develop
one on top.
 
> > I am sorry, I still didn't grasp the full semantic of the proposed
> > soluton but the mere fact it is starting by conflating selection and the
> > action is a no go and a wrong API. This is why I've said that what you
> > (David) outlined yesterday is probably going to suffer from a much
> > longer discussion and most likely to be not acceptable. Your patchset
> > proves me correct...
> 
> I'm very happy to change the API if there are better suggestions.  That 
> may end up just being an memory.oom_policy file, as this implements, and 
> separating out a new memory.oom_action that isn't a boolean value to 
> either do a full group kill or only a single process.  Or it could be what 
> I suggested in my mail to Tejun, such as "hierarchy killall" written to
> memory.oom_policy, which would specify a single policy and then an 
> optional mechanism.  With my proposed patchset, there would then be three 
> policies: "none", "cgroup", and "tree" and one possible optional 
> mechanism: "killall".

You haven't convinced me at all. This all sounds more like "what if"
than a really thought through interface. I've tried to point out that
having a real policy driven victim selection is a _hard_ thing to do
_right_.

On the other hand oom_group makes semantic sense. It controls the
killable entity and there are usecases which want to consider the full
memcg as a single killable entity. No matter what selection policy we
chose on top. It is just a natural API.

Now you keep arguing about the victim selection and different strategies
to implement it. We will not move forward as long as you keep conflating
the two things, I am afraid.
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

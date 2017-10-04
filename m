Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f72.google.com (mail-wm0-f72.google.com [74.125.82.72])
	by kanga.kvack.org (Postfix) with ESMTP id 4A6236B0038
	for <linux-mm@kvack.org>; Wed,  4 Oct 2017 05:29:43 -0400 (EDT)
Received: by mail-wm0-f72.google.com with SMTP id b189so8731461wmd.5
        for <linux-mm@kvack.org>; Wed, 04 Oct 2017 02:29:43 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id r13si12302701wrg.462.2017.10.04.02.29.41
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 04 Oct 2017 02:29:42 -0700 (PDT)
Date: Wed, 4 Oct 2017 11:29:38 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [v9 3/5] mm, oom: cgroup-aware OOM killer
Message-ID: <20171004092938.nipd6mtywyy4im44@dhcp22.suse.cz>
References: <20170927130936.8601-1-guro@fb.com>
 <20170927130936.8601-4-guro@fb.com>
 <20171003114848.gstdawonla2gmfio@dhcp22.suse.cz>
 <20171003123721.GA27919@castle.dhcp.TheFacebook.com>
 <20171003133623.hoskmd3fsh4t2phf@dhcp22.suse.cz>
 <20171003140841.GA29624@castle.DHCP.thefacebook.com>
 <20171003142246.xactdt7xddqdhvtu@dhcp22.suse.cz>
 <20171003143559.GJ3301751@devbig577.frc2.facebook.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20171003143559.GJ3301751@devbig577.frc2.facebook.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tejun Heo <tj@kernel.org>
Cc: Roman Gushchin <guro@fb.com>, linux-mm@kvack.org, Vladimir Davydov <vdavydov.dev@gmail.com>, Johannes Weiner <hannes@cmpxchg.org>, Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, David Rientjes <rientjes@google.com>, Andrew Morton <akpm@linux-foundation.org>, kernel-team@fb.com, cgroups@vger.kernel.org, linux-doc@vger.kernel.org, linux-kernel@vger.kernel.org

On Tue 03-10-17 07:35:59, Tejun Heo wrote:
> Hello, Michal.
> 
> On Tue, Oct 03, 2017 at 04:22:46PM +0200, Michal Hocko wrote:
> > On Tue 03-10-17 15:08:41, Roman Gushchin wrote:
> > > On Tue, Oct 03, 2017 at 03:36:23PM +0200, Michal Hocko wrote:
> > [...]
> > > > I guess we want to inherit the value on the memcg creation but I agree
> > > > that enforcing parent setting is weird. I will think about it some more
> > > > but I agree that it is saner to only enforce per memcg value.
> > > 
> > > I'm not against, but we should come up with a good explanation, why we're
> > > inheriting it; or not inherit.
> > 
> > Inheriting sounds like a less surprising behavior. Once you opt in for
> > oom_group you can expect that descendants are going to assume the same
> > unless they explicitly state otherwise.
> 
> Here's a counter example.
> 
> Let's say there's a container which hosts one main application, and
> the container shares its host with other containers.
> 
> * Let's say the container is a regular containerized OS instance and
>   can't really guarantee system integrity if one its processes gets
>   randomly killed.
> 
> * However, the application that it's running inside an isolated cgroup
>   is more intelligent and composed of multiple interchangeable
>   processes and can treat killing of a random process as partial
>   capacity loss.
> 
> When the host is setting up the outer container, it doesn't
> necessarily know whether the containerized environment would be able
> to handle partial OOM kills or not.  It's akin to panic_on_oom setting
> at system level - it's the containerized instance itself which knows
> whether it can handle partial OOM kills or not.  This is why this knob
> should be delegatable.
> 
> Now, the container itself has group OOM set and the isolated main
> application is starting up.  It obviously wants partial OOM kills
> rather than group killing.  This is the same principle.  The
> application which is being contained in the cgroup is the one which
> knows how it can handle OOM conditions, not the outer environment, so
> it obviously needs to be able to set the configuration it wants.

Yes this makes a lot of sense. On the other hand we used to copy other
reclaim specific atributes like swappiness and oom_kill_disable.

I guess we should be OK with "non-hierarchical" behavior when it is
documented properly so that there are surpasses.

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

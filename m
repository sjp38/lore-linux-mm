Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f200.google.com (mail-wr0-f200.google.com [209.85.128.200])
	by kanga.kvack.org (Postfix) with ESMTP id 96A286B0033
	for <linux-mm@kvack.org>; Wed,  1 Nov 2017 03:38:05 -0400 (EDT)
Received: by mail-wr0-f200.google.com with SMTP id c42so828607wrc.13
        for <linux-mm@kvack.org>; Wed, 01 Nov 2017 00:38:05 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id f13si265991edm.534.2017.11.01.00.38.00
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 01 Nov 2017 00:38:01 -0700 (PDT)
Date: Wed, 1 Nov 2017 08:37:58 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [RESEND v12 0/6] cgroup-aware OOM killer
Message-ID: <20171101073758.femijh7clfbwmqeg@dhcp22.suse.cz>
References: <20171019185218.12663-1-guro@fb.com>
 <20171019194534.GA5502@cmpxchg.org>
 <alpine.DEB.2.10.1710221715010.70210@chino.kir.corp.google.com>
 <20171026142445.GA21147@cmpxchg.org>
 <alpine.DEB.2.10.1710261359550.75887@chino.kir.corp.google.com>
 <20171027093107.GA29492@castle.dhcp.TheFacebook.com>
 <alpine.DEB.2.10.1710301430170.105449@chino.kir.corp.google.com>
 <20171031075408.67au22uk6dkpu7vv@dhcp22.suse.cz>
 <alpine.DEB.2.10.1710311513590.123444@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.10.1710311513590.123444@chino.kir.corp.google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: Roman Gushchin <guro@fb.com>, Johannes Weiner <hannes@cmpxchg.org>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, Vladimir Davydov <vdavydov.dev@gmail.com>, Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>, Tejun Heo <tj@kernel.org>, kernel-team@fb.com, cgroups@vger.kernel.org, linux-doc@vger.kernel.org, linux-kernel@vger.kernel.org

On Tue 31-10-17 15:21:23, David Rientjes wrote:
> On Tue, 31 Oct 2017, Michal Hocko wrote:
> 
> > > I'm not ignoring them, I have stated that we need the ability to protect 
> > > important cgroups on the system without oom disabling all attached 
> > > processes.  If that is implemented as a memory.oom_score_adj with the same 
> > > semantics as /proc/pid/oom_score_adj, i.e. a proportion of available 
> > > memory (the limit), it can also address the issues pointed out with the 
> > > hierarchical approach in v8.
> > 
> > No it cannot and it would be a terrible interface to have as well. You
> > do not want to permanently tune oom_score_adj to compensate for
> > structural restrictions on the hierarchy.
> > 
> 
> memory.oom_score_adj would never need to be permanently tuned, just as 
> /proc/pid/oom_score_adj need never be permanently tuned.  My response was 
> an answer to Roman's concern that "v8 has it's own limitations," but I 
> haven't seen a concrete example where the oom killer is forced to kill 
> from the non-preferred cgroup while the user has power of biasing against 
> certain cgroups with memory.oom_score_adj.  Do you have such a concrete 
> example that we can work with?

Yes, the one with structural requirements due to other controllers or
due to general organizational purposes where hierarchical (sibling
oriented) comparison just doesn't work. Take the students, teachers,
admins example. You definitely do not want to kill from students
subgroups by default just because this is the largest entity type.
Tuning memory.oom_score_adj doesn't work for that usecase as soon as
new subgroups come and go.

> > I believe, and Roman has pointed that out as well already, that further
> > improvements can be implemented without changing user visible behavior
> > as and add-on. If you disagree then you better come with a solid proof
> > that all of us wrong and reasonable semantic cannot be achieved that
> > way.
> 
> We simply cannot determine if improvements can be implemented in the 
> future without user-visible changes if those improvements are unknown or 
> undecided at this time.

Come on. There have been at least two examples on how this could be
achieved. One priority based which would use cumulative memory
consumption if set on intermediate nodes which would allow you to
compare siblings. And another one was to add a new knob which would make
an intermediate node an aggregate for accounting purposes.

> It may require hierarchical accounting when 
> making a choice between siblings, as suggested with oom_score_adj.  The 
> only thing that we need to agree on is that userspace needs to have some 
> kind of influence over victim selection: the oom killer killing an 
> important user process is an extremely sensitive thing.

And I am pretty sure we have already agreed that something like this is
useful for some usecases and nobody objected this would get merged in
future. All we are saying now is that this is not in scope of _this_
patchseries because the vast majority of usecases simply do not care
about influencing the oom selection. They only do care about having per
cgroup behavior and/or kill all semantic. I really do not understand
what is hard about that.

> If the patchset 
> lacks the ability to have that influence, and such an ability would impact 
> the heuristic overall, it's better to introduce that together as a 
> complete patchset rather than merging an incomplete feature when it's 
> known the user needs some control, asking the user to workaround it by 
> setting all processes to oom disabled in a preferred mem cgroup, and then 
> changing the heuristic again.

I believe we can introduce new knobs without influencing those who do
not set them and I haven't heard any argument which would say otherwise.

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

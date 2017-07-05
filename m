Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f200.google.com (mail-wr0-f200.google.com [209.85.128.200])
	by kanga.kvack.org (Postfix) with ESMTP id 28FA06B02C3
	for <linux-mm@kvack.org>; Wed,  5 Jul 2017 04:20:02 -0400 (EDT)
Received: by mail-wr0-f200.google.com with SMTP id 77so47131106wrb.11
        for <linux-mm@kvack.org>; Wed, 05 Jul 2017 01:20:02 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id o184si15010384wma.37.2017.07.05.01.20.00
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 05 Jul 2017 01:20:00 -0700 (PDT)
Date: Wed, 5 Jul 2017 10:19:57 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH] mm, vmscan: do not loop on too_many_isolated for ever
Message-ID: <20170705081956.GA14538@dhcp22.suse.cz>
References: <201703102044.DBJ04626.FLVMFOQOJtOFHS@I-love.SAKURA.ne.jp>
 <201706300914.CEH95859.FMQOLVFHJFtOOS@I-love.SAKURA.ne.jp>
 <20170630133236.GM22917@dhcp22.suse.cz>
 <201707010059.EAE43714.FOVOMOSLFHJFQt@I-love.SAKURA.ne.jp>
 <20170630161907.GC9714@dhcp22.suse.cz>
 <201707012043.BBE32181.JOFtOFVHQMLOFS@I-love.SAKURA.ne.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <201707012043.BBE32181.JOFtOFVHQMLOFS@I-love.SAKURA.ne.jp>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Cc: hannes@cmpxchg.org, riel@redhat.com, akpm@linux-foundation.org, mgorman@suse.de, vbabka@suse.cz, linux-mm@kvack.org, linux-kernel@vger.kernel.org

[this is getting tangent again and I will not respond any further if
this turn into yet another flame]

On Sat 01-07-17 20:43:56, Tetsuo Handa wrote:
> Michal Hocko wrote:
> > I really do appreciate your testing because it uncovers corner cases
> > most people do not test for and we can actually make the code better in
> > the end.
> 
> That statement does not get to my heart at all. Collision between your
> approach and my approach is wasting both your time and my time.
> 
> I've reported this too_many_isolated() trap three years ago at
> http://lkml.kernel.org/r/201407022140.BFJ13092.QVOSJtFMFHLOFO@I-love.SAKURA.ne.jp .
> Do you know that we already wasted 3 years without any attention?

And how many real bugs have we seen in those three years? Well, zero
AFAIR, except for your corner case testing. So while I never dismissed
the problem I've been saing this is not that trivial to fix. As my
attempt to address this and the review feedback I've received shows.

> You are rejecting serialization under OOM without giving a chance to test
> side effects of serialization under OOM at linux-next.git. I call such attitude
> "speculation" which you never accept.

No I am rejecting abusing the lock for purpose it is not aimed for.

> Look at mem_cgroup_out_of_memory(). Memcg OOM does use serialization.
> In the first place, if the system is under global OOM (which is more
> serious situation than memcg OOM), delay caused by serialization will not
> matter. Rather, I consider that making sure that the system does not get
> locked up is more important. I'm reporting that serialization helps
> facilitating the OOM killer/reaper operations, avoiding lockups, and
> solving global OOM situation smoothly. But you are refusing my report without
> giving a chance to test what side effects will pop up at linux-next.git.

You are mixing oranges with apples here. We do synchronize memcg oom
killer the same way as the global one.

> Knowledge about OOM situation is hardly shared among Linux developers and users,
> and is far from object of concern. Like shown by cgroup-aware OOM killer proposal,
> what will happen if we restrict 0 <= oom_victims <= 1 is not shared among developers.
> 
> How many developers joined to my OOM watchdog proposal? Every time and ever it is
> confrontation between you and me. You, as effectively the only participant, are
> showing negative attitude is effectively Nacked-by: response without alternative
> proposal.

This is something all of us have to fight with. There are only so many
MM developers. You have to justify your changes in order to attract other
developers/users. You are basing your changes on speculations and what-ifs
for workloads that most developers consider borderline and
misconfigurations already.
 
> Not everybody can afford testing with absolutely latest upstream kernels.
> Not prepared to obtain information for analysis using distributor kernels makes
> it impossible to compare whether user's problems are already fixed in upstream
> kernels, makes it impossible to identify patches which needs to be backported to
> distributor kernels, and is bad for customers using distributor kernels. Of course,
> it is possible that distributors decide not to allow users to obtain information
> for analysis, but such decision cannot become a reason we can not prepare to obtain
> information for analysis at upstream kernels.

If you have to work with distribution kernels then talk to distribution
people. It is that simple. You are surely not using those systems just
because of a fancy logo...
 
[...]

> > this way of pushing your patch is really annoying. Please do realize
> > that repeating the same thing all around will not make a patch more
> > likely to merge. You have proposed something, nobody has nacked it
> > so it waits for people to actually find it important enough to justify
> > the additional code. So please stop this.
> 
> When will people find time to judge it? We already wasted three years, and
> knowledge about OOM situation is hardly shared among Linux developers and users,
> and will unlikely be object of concern. How many years (or decades) will we waste
> more? MM subsystem will change meanwhile and we will just ignore old kernels.
> 
> If you do want me to stop bringing watchdog here and there, please do show
> alternative approach which I can tolerate. If you cannot afford it, please allow
> me to involve people (e.g. you make calls for joining to my proposals because
> you are asking me to wait until people find time to judge it).
> Please do realize that just repeatedly saying "wait patiently" helps nothing.

You really have to realize that there will hardly be more interest in
your reports when they do not reflect real life situations. I have said
(several times) that those issues should be addressed eventually but
there are more pressing issues which do trigger in the real life and
they have precedence.

Should we add a lot of code for something that doesn't bother many
users? I do not think so. As explained earlier (several times) this code
will have a maintenance cost and also can lead to other problems (false
positives etc. just consider how easily it is to get a false positive
lockup splats - I am facing reports for those very often on our
distribution kernels on large boxes).

I said I appreciate your testing regardless because I really mean it. We
really want to have a more robust out of memory handling long term. And
as you have surely noticed quite some changes have been made in that
direction last few years. There are still many unaddressed ones, no
question about that. We do not have to jump into the first approach we
come up with for those, though. Cost/benefit evaluation has to be done
everytime for each proposal. I am really not sure what is so hard to
understand about this.

[...]
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

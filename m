Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f70.google.com (mail-it0-f70.google.com [209.85.214.70])
	by kanga.kvack.org (Postfix) with ESMTP id BF7FC6B0279
	for <linux-mm@kvack.org>; Sat,  1 Jul 2017 07:44:20 -0400 (EDT)
Received: by mail-it0-f70.google.com with SMTP id p135so55220937ita.11
        for <linux-mm@kvack.org>; Sat, 01 Jul 2017 04:44:20 -0700 (PDT)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [2001:e42:101:1:202:181:97:72])
        by mx.google.com with ESMTPS id 78si13069727itb.63.2017.07.01.04.44.18
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Sat, 01 Jul 2017 04:44:19 -0700 (PDT)
Subject: Re: [PATCH] mm, vmscan: do not loop on too_many_isolated for ever
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
References: <201703102044.DBJ04626.FLVMFOQOJtOFHS@I-love.SAKURA.ne.jp>
	<201706300914.CEH95859.FMQOLVFHJFtOOS@I-love.SAKURA.ne.jp>
	<20170630133236.GM22917@dhcp22.suse.cz>
	<201707010059.EAE43714.FOVOMOSLFHJFQt@I-love.SAKURA.ne.jp>
	<20170630161907.GC9714@dhcp22.suse.cz>
In-Reply-To: <20170630161907.GC9714@dhcp22.suse.cz>
Message-Id: <201707012043.BBE32181.JOFtOFVHQMLOFS@I-love.SAKURA.ne.jp>
Date: Sat, 1 Jul 2017 20:43:56 +0900
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: mhocko@kernel.org
Cc: hannes@cmpxchg.org, riel@redhat.com, akpm@linux-foundation.org, mgorman@suse.de, vbabka@suse.cz, linux-mm@kvack.org, linux-kernel@vger.kernel.org

Michal Hocko wrote:
> I really do appreciate your testing because it uncovers corner cases
> most people do not test for and we can actually make the code better in
> the end.

That statement does not get to my heart at all. Collision between your
approach and my approach is wasting both your time and my time.

I've reported this too_many_isolated() trap three years ago at
http://lkml.kernel.org/r/201407022140.BFJ13092.QVOSJtFMFHLOFO@I-love.SAKURA.ne.jp .
Do you know that we already wasted 3 years without any attention?

You are rejecting serialization under OOM without giving a chance to test
side effects of serialization under OOM at linux-next.git. I call such attitude
"speculation" which you never accept.

Look at mem_cgroup_out_of_memory(). Memcg OOM does use serialization.
In the first place, if the system is under global OOM (which is more
serious situation than memcg OOM), delay caused by serialization will not
matter. Rather, I consider that making sure that the system does not get
locked up is more important. I'm reporting that serialization helps
facilitating the OOM killer/reaper operations, avoiding lockups, and
solving global OOM situation smoothly. But you are refusing my report without
giving a chance to test what side effects will pop up at linux-next.git.

Knowledge about OOM situation is hardly shared among Linux developers and users,
and is far from object of concern. Like shown by cgroup-aware OOM killer proposal,
what will happen if we restrict 0 <= oom_victims <= 1 is not shared among developers.

How many developers joined to my OOM watchdog proposal? Every time and ever it is
confrontation between you and me. You, as effectively the only participant, are
showing negative attitude is effectively Nacked-by: response without alternative
proposal.

Not everybody can afford testing with absolutely latest upstream kernels.
Not prepared to obtain information for analysis using distributor kernels makes
it impossible to compare whether user's problems are already fixed in upstream
kernels, makes it impossible to identify patches which needs to be backported to
distributor kernels, and is bad for customers using distributor kernels. Of course,
it is possible that distributors decide not to allow users to obtain information
for analysis, but such decision cannot become a reason we can not prepare to obtain
information for analysis at upstream kernels.

Suppose I take a step back and tolerate the burden of sitting in front of console
24 hours a day, every day of the year so that users can press SysRq when something
went wrong, how nice it will be if all in-flight allocation requests were printed
upon SysRq. show_workqueue_state() is called upon SysRq-t is to some degree useful.

In fact, my proposal was such approach before I serialize using a kernel thread
(e.g. http://lkml.kernel.org/r/201411231351.HJA17065.VHQSFOJFtLFOMO@I-love.SAKURA.ne.jp
which I proposed two years and a half ago). Though, while my proposal was left ignored,
I learned that showing only current thread is not sufficient and updated my watchdog
to show other threads (e.g. kswapd) using serialization.

A patch at http://lkml.kernel.org/r/201505232339.DAB00557.VFFLHMSOJFOOtQ@I-love.SAKURA.ne.jp
which I posted two years ago also includes a proposal for handling infinite
shrink_inactive_list() problem. After all, this shrink_inactive_list() problem was
ignored for three years without getting a chance to even test at linux-next.git.
Sigh...

I know my proposals might not be best. But you cannot afford showing alternative proposals
because you are putting higher priority to other problems. And other developers cannot afford
participating because they are not interested in or they do not share knowledge of this problem.

My proposals do not constrain future kernels. We can revert my proposals when my proposals
became no longer needed. My proposals is meaningful as interim approach, but you never accept
approaches which do not match your will (or desire). Even without giving people a chance to
test what side effects will crop up, how can your "I really do appreciate your testing"
statement get to my heart?

My watchdog allows detecting problems which are previously overlooked unless putting
unrealistic burden (e.g. stand by 24 hours a day, every day of the year). You ask people
to prove that it is a MM problem. But I am dissatisfied that you are letting proposals
which helps judging whether it is a MM problem alone.

> this way of pushing your patch is really annoying. Please do realize
> that repeating the same thing all around will not make a patch more
> likely to merge. You have proposed something, nobody has nacked it
> so it waits for people to actually find it important enough to justify
> the additional code. So please stop this.

When will people find time to judge it? We already wasted three years, and
knowledge about OOM situation is hardly shared among Linux developers and users,
and will unlikely be object of concern. How many years (or decades) will we waste
more? MM subsystem will change meanwhile and we will just ignore old kernels.

If you do want me to stop bringing watchdog here and there, please do show
alternative approach which I can tolerate. If you cannot afford it, please allow
me to involve people (e.g. you make calls for joining to my proposals because
you are asking me to wait until people find time to judge it).
Please do realize that just repeatedly saying "wait patiently" helps nothing.

> It is really hard to pursue this half solution when there is no clear
> indication it helps in your testing. So could you try to test with only
> this patch on top of the current linux-next tree (or Linus tree) and see
> if you can reproduce the problem?

With this patch on top of next-20170630, I no longer hit this problem.
(Of course, this is because this patch eliminates the infinite loop.)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

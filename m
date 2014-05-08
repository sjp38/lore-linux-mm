Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f180.google.com (mail-wi0-f180.google.com [209.85.212.180])
	by kanga.kvack.org (Postfix) with ESMTP id DF1806B00F1
	for <linux-mm@kvack.org>; Thu,  8 May 2014 11:25:43 -0400 (EDT)
Received: by mail-wi0-f180.google.com with SMTP id hi2so3304252wib.1
        for <linux-mm@kvack.org>; Thu, 08 May 2014 08:25:43 -0700 (PDT)
Received: from alpha.arachsys.com (alpha.arachsys.com. [2001:9d8:200a:0:9f:9fff:fe90:dbe3])
        by mx.google.com with ESMTPS id m10si1027873wic.35.2014.05.08.08.25.42
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Thu, 08 May 2014 08:25:42 -0700 (PDT)
Date: Thu, 8 May 2014 16:25:18 +0100
From: Richard Davies <richard@arachsys.com>
Subject: Re: Protection against container fork bombs [WAS: Re: memcg with
 kmem limit doesn't recover after disk i/o causes limit to be hit]
Message-ID: <20140508152518.GA1091@alpha.arachsys.com>
References: <20140418155939.GE4523@dhcp22.suse.cz>
 <5351679F.5040908@parallels.com>
 <20140420142830.GC22077@alpha.arachsys.com>
 <20140422143943.20609800@oracle.com>
 <20140422200531.GA19334@alpha.arachsys.com>
 <535758A0.5000500@yuhu.biz>
 <20140423084942.560ae837@oracle.com>
 <5368CA47.7030007@yuhu.biz>
 <20140507131514.43716518@oracle.com>
 <536AB626.9070005@1h.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <536AB626.9070005@1h.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Marian Marinov <mm@1h.com>
Cc: Dwight Engen <dwight.engen@oracle.com>, Marian Marinov <mm@yuhu.biz>, Vladimir Davydov <vdavydov@parallels.com>, Daniel Walsh <dwalsh@redhat.com>, Max Kellermann <mk@cm4all.com>, Tim Hockin <thockin@hockin.org>, Frederic Weisbecker <fweisbec@gmail.com>, containers@lists.linux-foundation.org, Johannes Weiner <hannes@cmpxchg.org>, Glauber Costa <glommer@parallels.com>, Michal Hocko <mhocko@suse.cz>, linux-mm@kvack.org, William Dauchy <wdauchy@gmail.com>, David Rientjes <rientjes@google.com>, Tejun Heo <tj@kernel.org>, cgroups@vger.kernel.org

Marian Marinov wrote:
> On 05/07/2014 08:15 PM, Dwight Engen wrote:
> >On Tue, 06 May 2014 14:40:55 +0300
> >Marian Marinov <mm@yuhu.biz> wrote:
> >
> >>On 04/23/2014 03:49 PM, Dwight Engen wrote:
> >>>On Wed, 23 Apr 2014 09:07:28 +0300
> >>>Marian Marinov <mm@yuhu.biz> wrote:
> >>>
> >>>>On 04/22/2014 11:05 PM, Richard Davies wrote:
> >>>>>Dwight Engen wrote:
> >>>>>>Richard Davies wrote:
> >>>>>>>Vladimir Davydov wrote:
> >>>>>>>>In short, kmem limiting for memory cgroups is currently broken.
> >>>>>>>>Do not use it. We are working on making it usable though.
> >>>>>...
> >>>>>>>What is the best mechanism available today, until kmem limits
> >>>>>>>mature?
> >>>>>>>
> >>>>>>>RLIMIT_NPROC exists but is per-user, not per-container.
> >>>>>>>
> >>>>>>>Perhaps there is an up-to-date task counter patchset or similar?
> >>>>>>
> >>>>>>I updated Frederic's task counter patches and included Max
> >>>>>>Kellermann's fork limiter here:
> >>>>>>
> >>>>>>http://thread.gmane.org/gmane.linux.kernel.containers/27212
> >>>>>>
> >>>>>>I can send you a more recent patchset (against 3.13.10) if you
> >>>>>>would find it useful.
> >>>>>
> >>>>>Yes please, I would be interested in that. Ideally even against
> >>>>>3.14.1 if you have that too.
> >>>>
> >>>>Dwight, do you have these patches in any public repo?
> >>>>
> >>>>I would like to test them also.
> >>>
> >>>Hi Marian, I put the patches against 3.13.11 and 3.14.1 up at:
> >>>
> >>>git://github.com/dwengen/linux.git cpuacct-task-limit-3.13
> >>>git://github.com/dwengen/linux.git cpuacct-task-limit-3.14
> >>>
> >>Guys I tested the patches with 3.12.16. However I see a problem with
> >>them.
> >>
> >>Trying to set the limit to a cgroup which already have processes in
> >>it does not work:
> >
> >This is a similar check/limitation to the one for kmem in memcg, and is
> >done here to keep the res_counters consistent and from going negative.
> >It could probably be relaxed slightly by using res_counter_set_limit()
> >instead, but you would still need to initially set a limit before
> >adding tasks to the group.
> 
> I have removed the check entirely and still receive the EBUSY... I
> just don't understand what is returning it. If you have any
> pointers, I would be happy to take a look.
> 
> I'll look at set_limit(), thanks for pointing that one.
> 
> What I'm proposing is the following checks:
> 
>     if (val > RES_COUNTER_MAX || val < 0)
>         return -EBUSY;
>     if (val != 0 && val <= cgroup_task_count(cgrp))
>         return -EBUSY;
> 
>     res_counter_write_u64(&ca->task_limit, type, val);
> 
> This way we ensure that val is within the limits > 0 and <
> RES_COUNTER_MAX. And also allow only values of 0 or greater then the
> current task count.

I have also noticed that I can't change many different cgroup limits while
there are tasks running in the cgroup - not just cpuacct.task_limit, but
also kmem and even normal memory.limit_in_bytes

I would like to be able to change all of these limits, as long as the new
limit is greater than the actual current use.

Could a method like this be used for all of the others too?

Richard.

> >>[root@sp2 lxc]# echo 50 > cpuacct.task_limit
> >>-bash: echo: write error: Device or resource busy
> >>[root@sp2 lxc]# echo 0 > cpuacct.task_limit
> >>-bash: echo: write error: Device or resource busy
> >>[root@sp2 lxc]#
> >>
> >>I have even tried to remove this check:
> >>+               if (cgroup_task_count(cgrp)
> >>|| !list_empty(&cgrp->children))
> >>+                       return -EBUSY;
> >>But still give me 'Device or resource busy'.
> >>
> >>Any pointers of why is this happening ?
> >>
> >>Marian

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

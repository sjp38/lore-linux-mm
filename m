Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f72.google.com (mail-pg0-f72.google.com [74.125.83.72])
	by kanga.kvack.org (Postfix) with ESMTP id 4D3616B04BD
	for <linux-mm@kvack.org>; Sun, 20 Aug 2017 20:50:31 -0400 (EDT)
Received: by mail-pg0-f72.google.com with SMTP id b8so20159032pgn.10
        for <linux-mm@kvack.org>; Sun, 20 Aug 2017 17:50:31 -0700 (PDT)
Received: from mail-pg0-x232.google.com (mail-pg0-x232.google.com. [2607:f8b0:400e:c05::232])
        by mx.google.com with ESMTPS id m2si5020151pgt.892.2017.08.20.17.50.29
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 20 Aug 2017 17:50:29 -0700 (PDT)
Received: by mail-pg0-x232.google.com with SMTP id y129so89567076pgy.4
        for <linux-mm@kvack.org>; Sun, 20 Aug 2017 17:50:29 -0700 (PDT)
Date: Sun, 20 Aug 2017 17:50:27 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [v5 2/4] mm, oom: cgroup-aware OOM killer
In-Reply-To: <20170816154325.GB29131@castle.DHCP.thefacebook.com>
Message-ID: <alpine.DEB.2.10.1708201741330.117182@chino.kir.corp.google.com>
References: <20170814183213.12319-1-guro@fb.com> <20170814183213.12319-3-guro@fb.com> <alpine.DEB.2.10.1708141532300.63207@chino.kir.corp.google.com> <20170815121558.GA15892@castle.dhcp.TheFacebook.com> <alpine.DEB.2.10.1708151435290.104516@chino.kir.corp.google.com>
 <20170816154325.GB29131@castle.DHCP.thefacebook.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Roman Gushchin <guro@fb.com>
Cc: linux-mm@kvack.org, Michal Hocko <mhocko@kernel.org>, Vladimir Davydov <vdavydov.dev@gmail.com>, Johannes Weiner <hannes@cmpxchg.org>, Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>, Tejun Heo <tj@kernel.org>, kernel-team@fb.com, cgroups@vger.kernel.org, linux-doc@vger.kernel.org, linux-kernel@vger.kernel.org

On Wed, 16 Aug 2017, Roman Gushchin wrote:

> It's natural to expect that inside a container there are their own sshd,
> "activity manager" or some other stuff, which can play with oom_score_adj.
> If it can override the upper cgroup-level settings, the whole delegation model
> is broken.
> 

I don't think any delegation model related to core cgroups or memory 
cgroup is broken, I think it's based on how memory.oom_kill_all_tasks is 
defined.  It could very well behave as memory.oom_kill_all_eligible_tasks 
when enacted upon.

> You can think about the oom_kill_all_tasks like the panic_on_oom,
> but on a cgroup level. It should _guarantee_, that in case of oom
> the whole cgroup will be destroyed completely, and will not remain
> in a non-consistent state.
> 

Only CAP_SYS_ADMIN has this ability to set /proc/pid/oom_score_adj to 
OOM_SCORE_ADJ_MIN, so it preserves the ability to change that setting, if 
needed, when it sets memory.oom_kill_all_tasks.  If a user gains 
permissions to change memory.oom_kill_all_tasks, I disagree it should 
override the CAP_SYS_ADMIN setting of /proc/pid/oom_score_adj.

I would prefer not to exclude oom disabled processes to their own sibling 
cgroups because they would require their own reservation with cgroup v2 
and it makes the single hierarchy model much more difficult to arrange 
alongside cpusets, for example.

> The model you're describing is based on a trust given to these oom-unkillable
> processes on system level. But we can't really trust some unknown processes
> inside a cgroup that they will be able to do some useful work and finish
> in a reasonable time; especially in case of a global memory shortage.

Yes, we prefer to panic instead of sshd, for example, being oom killed.  
We trust that sshd, as well as our own activity manager and security 
daemons are trusted to do useful work and that we never want the kernel to 
do this.  I'm not sure why you are describing processes that CAP_SYS_ADMIN 
has set to be oom disabled as unknown processes.

I'd be interested in hearing the opinions of others related to a per-memcg 
knob being allowed to override the setting of the sysadmin.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

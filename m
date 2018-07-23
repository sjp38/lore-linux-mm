Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f71.google.com (mail-ed1-f71.google.com [209.85.208.71])
	by kanga.kvack.org (Postfix) with ESMTP id B6B806B0269
	for <linux-mm@kvack.org>; Mon, 23 Jul 2018 10:17:51 -0400 (EDT)
Received: by mail-ed1-f71.google.com with SMTP id s18-v6so489332edr.15
        for <linux-mm@kvack.org>; Mon, 23 Jul 2018 07:17:51 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id f12-v6si6537039eds.462.2018.07.23.07.17.50
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 23 Jul 2018 07:17:50 -0700 (PDT)
Date: Mon, 23 Jul 2018 16:17:48 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: cgroup-aware OOM killer, how to move forward
Message-ID: <20180723141748.GH31229@dhcp22.suse.cz>
References: <alpine.DEB.2.21.1807131608530.218060@chino.kir.corp.google.com>
 <20180713231630.GB17467@castle.DHCP.thefacebook.com>
 <alpine.DEB.2.21.1807162115180.157949@chino.kir.corp.google.com>
 <20180717173844.GB14909@castle.DHCP.thefacebook.com>
 <20180717194945.GM7193@dhcp22.suse.cz>
 <20180717200641.GB18762@castle.DHCP.thefacebook.com>
 <20180718081230.GP7193@dhcp22.suse.cz>
 <20180718152846.GA6840@castle.DHCP.thefacebook.com>
 <20180719073843.GL7193@dhcp22.suse.cz>
 <20180719170543.GA21770@castle.DHCP.thefacebook.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180719170543.GA21770@castle.DHCP.thefacebook.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Roman Gushchin <guro@fb.com>, hannes@cmpxchg.org, tj@kernel.org
Cc: David Rientjes <rientjes@google.com>, linux-mm@kvack.org, akpm@linux-foundation.org, gthelen@google.com

On Thu 19-07-18 10:05:47, Roman Gushchin wrote:
> On Thu, Jul 19, 2018 at 09:38:43AM +0200, Michal Hocko wrote:
> > On Wed 18-07-18 08:28:50, Roman Gushchin wrote:
> > > On Wed, Jul 18, 2018 at 10:12:30AM +0200, Michal Hocko wrote:
> > > > On Tue 17-07-18 13:06:42, Roman Gushchin wrote:
> > > > > On Tue, Jul 17, 2018 at 09:49:46PM +0200, Michal Hocko wrote:
> > > > > > On Tue 17-07-18 10:38:45, Roman Gushchin wrote:
> > > > > > [...]
> > > > > > > Let me show my proposal on examples. Let's say we have the following hierarchy,
> > > > > > > and the biggest process (or the process with highest oom_score_adj) is in D.
> > > > > > > 
> > > > > > >   /
> > > > > > >   |
> > > > > > >   A
> > > > > > >   |
> > > > > > >   B
> > > > > > >  / \
> > > > > > > C   D
> > > > > > > 
> > > > > > > Let's look at different examples and intended behavior:
> > > > > > > 1) system-wide OOM
> > > > > > >   - default settings: the biggest process is killed
> > > > > > >   - D/memory.group_oom=1: all processes in D are killed
> > > > > > >   - A/memory.group_oom=1: all processes in A are killed
> > > > > > > 2) memcg oom in B
> > > > > > >   - default settings: the biggest process is killed
> > > > > > >   - A/memory.group_oom=1: the biggest process is killed
> > > > > > 
> > > > > > Huh? Why would you even consider A here when the oom is below it?
> > > > > > /me confused
> > > > > 
> > > > > I do not.
> > > > > This is exactly a counter-example: A's memory.group_oom
> > > > > is not considered at all in this case,
> > > > > because A is above ooming cgroup.
> > > > 
> > > > OK, it confused me.
> > > > 
> > > > > > 
> > > > > > >   - B/memory.group_oom=1: all processes in B are killed
> > > > > > 
> > > > > >     - B/memory.group_oom=0 &&
> > > > > > >   - D/memory.group_oom=1: all processes in D are killed
> > > > > > 
> > > > > > What about?
> > > > > >     - B/memory.group_oom=1 && D/memory.group_oom=0
> > > > > 
> > > > > All tasks in B are killed.
> > > > 
> > > > so essentially find a task, traverse the memcg hierarchy from the
> > > > victim's memcg up to the oom root as long as memcg.group_oom = 1?
> > > > If the resulting memcg.group_oom == 1 then kill the whole sub tree.
> > > > Right?
> > > 
> > > Yes.
> > > 
> > > > 
> > > > > Group_oom set to 1 means that the workload can't tolerate
> > > > > killing of a random process, so in this case it's better
> > > > > to guarantee consistency for B.
> > > > 
> > > > OK, but then if D itself is OOM then we do not care about consistency
> > > > all of the sudden? I have hard time to think about a sensible usecase.
> > > 
> > > I mean if traversing the hierarchy up to the oom root we meet
> > > a memcg with group_oom set to 0, we shouldn't stop traversing.
> > 
> > Well, I am still fighting with the semantic of group, no-group, group
> > configuration. Why does it make any sense? In other words when can we
> > consider a cgroup to be a indivisible workload for one oom context while
> > it is fine to lose head or arm from another?
> 
> Hm, so the question is should we traverse up to the OOMing cgroup,
> or up to the first cgroup with memory.group_oom=0?
> 
> I looked at an example, and it *might* be the latter is better,
> especially if we'll make the default value inheritable.
> 
> Let's say we have a sub-tree with a workload and some control stuff.
> Workload is tolerable to OOM's (we can handle it in userspace, for
> example), but the control stuff is not.
> Then it probably makes no sense to kill the entire sub-tree,
> if a task in C has to be killed. But makes perfect sense if we
> have to kill a task in B.
> 
>   /
>   |
>   A, delegated sub-tree, group_oom=1
>  / \
> B   C, workload, group_oom=0
> ^
> some control stuff here, group_oom=1
> 
> Does this makes sense?

I am not sure. If you are going to delegate then you are basically
losing control of the group_oom at A-level. Is this good? What if I
_want_ to tear down the whole thing if it starts misbehaving because I
do not trust it?

The more I think about it the more I am concluding that we should start
with a more contrained model and require that once parent is
group_oom == 1 then children have to as well. If we ever find a usecase
to require a different scheme we can weaker it later. We cannot do that
other way around.

Tejun, Johannes what do you think about that?
-- 
Michal Hocko
SUSE Labs

Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f69.google.com (mail-pl0-f69.google.com [209.85.160.69])
	by kanga.kvack.org (Postfix) with ESMTP id 0DA4B6B0003
	for <linux-mm@kvack.org>; Tue, 17 Jul 2018 16:41:37 -0400 (EDT)
Received: by mail-pl0-f69.google.com with SMTP id 39-v6so1191541ple.6
        for <linux-mm@kvack.org>; Tue, 17 Jul 2018 13:41:37 -0700 (PDT)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id l123-v6sor468857pfl.87.2018.07.17.13.41.35
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 17 Jul 2018 13:41:35 -0700 (PDT)
Date: Tue, 17 Jul 2018 13:41:33 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: cgroup-aware OOM killer, how to move forward
In-Reply-To: <20180717200641.GB18762@castle.DHCP.thefacebook.com>
Message-ID: <alpine.DEB.2.21.1807171329200.12251@chino.kir.corp.google.com>
References: <20180711223959.GA13981@castle.DHCP.thefacebook.com> <alpine.DEB.2.21.1807131423230.194789@chino.kir.corp.google.com> <20180713221602.GA15005@castle.DHCP.thefacebook.com> <alpine.DEB.2.21.1807131535420.202408@chino.kir.corp.google.com>
 <20180713230545.GA17467@castle.DHCP.thefacebook.com> <alpine.DEB.2.21.1807131608530.218060@chino.kir.corp.google.com> <20180713231630.GB17467@castle.DHCP.thefacebook.com> <alpine.DEB.2.21.1807162115180.157949@chino.kir.corp.google.com>
 <20180717173844.GB14909@castle.DHCP.thefacebook.com> <20180717194945.GM7193@dhcp22.suse.cz> <20180717200641.GB18762@castle.DHCP.thefacebook.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Roman Gushchin <guro@fb.com>
Cc: Michal Hocko <mhocko@kernel.org>, linux-mm@kvack.org, akpm@linux-foundation.org, hannes@cmpxchg.org, tj@kernel.org, gthelen@google.com

On Tue, 17 Jul 2018, Roman Gushchin wrote:

> > > Let me show my proposal on examples. Let's say we have the following hierarchy,
> > > and the biggest process (or the process with highest oom_score_adj) is in D.
> > > 
> > >   /
> > >   |
> > >   A
> > >   |
> > >   B
> > >  / \
> > > C   D
> > > 
> > > Let's look at different examples and intended behavior:
> > > 1) system-wide OOM
> > >   - default settings: the biggest process is killed
> > >   - D/memory.group_oom=1: all processes in D are killed
> > >   - A/memory.group_oom=1: all processes in A are killed
> > > 2) memcg oom in B
> > >   - default settings: the biggest process is killed
> > >   - A/memory.group_oom=1: the biggest process is killed
> > 
> > Huh? Why would you even consider A here when the oom is below it?
> > /me confused
> 
> I do not.
> This is exactly a counter-example: A's memory.group_oom
> is not considered at all in this case,
> because A is above ooming cgroup.
> 

I think the confusion is that this says A/memory.group_oom=1 and then the 
biggest process is killed, which doesn't seem like it matches the 
description you want to give memory.group_oom.

> > >   - B/memory.group_oom=1: all processes in B are killed
> > 
> >     - B/memory.group_oom=0 &&
> > >   - D/memory.group_oom=1: all processes in D are killed
> > 
> > What about?
> >     - B/memory.group_oom=1 && D/memory.group_oom=0
> 
> All tasks in B are killed.
> 
> Group_oom set to 1 means that the workload can't tolerate
> killing of a random process, so in this case it's better
> to guarantee consistency for B.
> 

This example is missing the usecase that I was referring to, i.e. killing 
all processes attached to a subtree because the limit on a common ancestor 
has been reached.

In your example, I would think that the memory.group_oom setting of /A and 
/A/B are meaningless because there are no processes attached to them.

IIUC, your proposal is to select the victim by whatever means, check the 
memory.group_oom setting of that victim, and then either kill the victim 
or all processes attached to that local mem cgroup depending on the 
setting.

However, if C and D here are only limited by a common ancestor, /A or 
/A/B, there is no way to specify that the subtree itself should be oom 
killed.  That was where I thought a tristate value would be helpful such 
that you can define all processes attached to the subtree should be oom 
killed when a mem cgroup has reached memory.max.

I was purposefully overloading memory.group_oom because the actual value 
of memory.group_oom given your semantics here is not relevant for /A or 
/A/B.  I think an additional memory.group_oom_tree or whatever it would be 
called would lead to unnecessary confusion because then we have a model 
where one tunable means something based on the value of the other.

Given the no internal process constraint of cgroup v2, my suggestion was a 
value, "tree", that could specify that a mem cgroup reaching its limit 
could cause all processes attached to its subtree to be killed.  This is 
required only because the single unified hierarchy of cgroup v2 such that 
we want to bind a subset of processes to be controlled by another 
controller separately but still want all processes oom killed when 
reaching the limit of a common ancestor.

Thus, the semantic would be: if oom mem cgroup is "tree", kill all 
processes in subtree; otherwise, it can be "cgroup" or "process" to 
determine what is oom killed depending on the victim selection.

Having the "tree" behavior could definitely be implemented as a separate 
tunable; but then then value of /A/memory.group_oom and 
/A/B/memory.group_oom are irrelevant and, to me, seems like it would be 
more confusing.

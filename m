Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f72.google.com (mail-pl0-f72.google.com [209.85.160.72])
	by kanga.kvack.org (Postfix) with ESMTP id 9B93B6B000D
	for <linux-mm@kvack.org>; Mon, 23 Jul 2018 19:06:47 -0400 (EDT)
Received: by mail-pl0-f72.google.com with SMTP id w1-v6so1376473plq.8
        for <linux-mm@kvack.org>; Mon, 23 Jul 2018 16:06:47 -0700 (PDT)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id y5-v6sor1064491plt.37.2018.07.23.16.06.46
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 23 Jul 2018 16:06:46 -0700 (PDT)
Date: Mon, 23 Jul 2018 16:06:43 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: cgroup-aware OOM killer, how to move forward
In-Reply-To: <20180720204746.GA23478@castle.DHCP.thefacebook.com>
Message-ID: <alpine.DEB.2.21.1807231555550.196032@chino.kir.corp.google.com>
References: <20180713231630.GB17467@castle.DHCP.thefacebook.com> <alpine.DEB.2.21.1807162115180.157949@chino.kir.corp.google.com> <20180717173844.GB14909@castle.DHCP.thefacebook.com> <20180717194945.GM7193@dhcp22.suse.cz> <20180717200641.GB18762@castle.DHCP.thefacebook.com>
 <alpine.DEB.2.21.1807171329200.12251@chino.kir.corp.google.com> <20180717205221.GA19862@castle.DHCP.thefacebook.com> <alpine.DEB.2.21.1807200126540.119737@chino.kir.corp.google.com> <20180720112131.GX72677@devbig577.frc2.facebook.com>
 <alpine.DEB.2.21.1807201321040.231119@chino.kir.corp.google.com> <20180720204746.GA23478@castle.DHCP.thefacebook.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Roman Gushchin <guro@fb.com>
Cc: Tejun Heo <tj@kernel.org>, Michal Hocko <mhocko@kernel.org>, linux-mm@kvack.org, akpm@linux-foundation.org, hannes@cmpxchg.org, gthelen@google.com

On Fri, 20 Jul 2018, Roman Gushchin wrote:

> > > > process chosen for oom kill.  I know that you care about the latter.  My 
> > > > *only* suggestion was for the tunable to take a string instead of a 
> > > > boolean so it is extensible for future use.  This seems like something so 
> > > > trivial.
> > > 
> > > So, I'd much prefer it as boolean.  It's a fundamentally binary
> > > property, either handle the cgroup as a unit when chosen as oom victim
> > > or not, nothing more.
> > 
> > With the single hierarchy mandate of cgroup v2, the need arises to 
> > separate processes from a single job into subcontainers for use with 
> > controllers other than mem cgroup.  In that case, we have no functionality 
> > to oom kill all processes in the subtree.
> > 
> > A boolean can kill all processes attached to the victim's mem cgroup, but 
> > cannot kill all processes in a subtree if the limit of a common ancestor 
> > is reached.
> 
> Why so?
> 
> Once again my proposal:
> as soon as the OOM killer selected a victim task,
> we'll look at the victim task's memory cgroup.
> If memory.oom.group is not set, we're done.
> Otherwise let's traverse the memory cgroup tree up to
> the OOMing cgroup (or root) as long as memory.oom.group is set.
> Kill the last cgroup entirely (including all children).
> 

I know this is your proposal, I'm suggesting a context-based extension 
based on which mem cgroup is oom: the common ancestor or the leaf.

Consider /A, /A/b, and /A/c, and memory.oom_group is 1 for all of them.  
When /A, /A/b, or /A/c is oom, all processes attached to /A and its 
subtree are oom killed per your semantic.  That occurs when any of the 
three mem cgroups are oom.

I'm suggesting that it may become useful to kill an entire subtree when 
the common ancestor, /A, is oom, but not when /A/b or /A/c is oom.  There 
is no way to specify this with the proposal and trees where the limits of
/A/b + /A/c > /A exist.  We want all processes killed in /A/b or /A/c if 
they reach their individual limits.  We want all processes killed in /A's 
subtree if /A reaches its limit.

I am not asking for that support to be implemented immediately if you do 
not have a need for it.  But I am asking that your interface to do so is 
extensible so that we may implement it.  Given the no internal process 
constraint of cgroup v2, defining this as two separate tunables would 
always have one be effective and the other be irrelevant, so I suggest it 
is overloaded.

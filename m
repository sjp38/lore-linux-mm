Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg1-f199.google.com (mail-pg1-f199.google.com [209.85.215.199])
	by kanga.kvack.org (Postfix) with ESMTP id 14CCA6B000D
	for <linux-mm@kvack.org>; Fri, 20 Jul 2018 04:32:31 -0400 (EDT)
Received: by mail-pg1-f199.google.com with SMTP id q12-v6so5508880pgp.6
        for <linux-mm@kvack.org>; Fri, 20 Jul 2018 01:32:31 -0700 (PDT)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id 59-v6sor408754plp.6.2018.07.20.01.32.30
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 20 Jul 2018 01:32:30 -0700 (PDT)
Date: Fri, 20 Jul 2018 01:32:28 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: cgroup-aware OOM killer, how to move forward
In-Reply-To: <20180719170543.GA21770@castle.DHCP.thefacebook.com>
Message-ID: <alpine.DEB.2.21.1807200130230.119737@chino.kir.corp.google.com>
References: <20180713230545.GA17467@castle.DHCP.thefacebook.com> <alpine.DEB.2.21.1807131608530.218060@chino.kir.corp.google.com> <20180713231630.GB17467@castle.DHCP.thefacebook.com> <alpine.DEB.2.21.1807162115180.157949@chino.kir.corp.google.com>
 <20180717173844.GB14909@castle.DHCP.thefacebook.com> <20180717194945.GM7193@dhcp22.suse.cz> <20180717200641.GB18762@castle.DHCP.thefacebook.com> <20180718081230.GP7193@dhcp22.suse.cz> <20180718152846.GA6840@castle.DHCP.thefacebook.com> <20180719073843.GL7193@dhcp22.suse.cz>
 <20180719170543.GA21770@castle.DHCP.thefacebook.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Roman Gushchin <guro@fb.com>
Cc: Michal Hocko <mhocko@kernel.org>, linux-mm@kvack.org, akpm@linux-foundation.org, hannes@cmpxchg.org, tj@kernel.org, gthelen@google.com

On Thu, 19 Jul 2018, Roman Gushchin wrote:

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
> 

The *only* suggestion here was that memory.group_oom take a string instead 
of a boolean value so that it can be extended later, especially if 
introducing another tunable is problematic because it clashes with 
semantics of the this one.  This is *so* trivial to do.  Anything that is 
going to care about setting up cgroup oom killing will have no problems 
writing a string instead of an integer.  I'm asking that you don't back 
the interface into a corner where extending it later is problematic.

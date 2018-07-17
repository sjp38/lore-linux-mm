Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id 949AA6B0269
	for <linux-mm@kvack.org>; Tue, 17 Jul 2018 00:19:21 -0400 (EDT)
Received: by mail-pf0-f199.google.com with SMTP id j25-v6so26434203pfi.20
        for <linux-mm@kvack.org>; Mon, 16 Jul 2018 21:19:21 -0700 (PDT)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id m24-v6sor8986277pgd.251.2018.07.16.21.19.20
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 16 Jul 2018 21:19:20 -0700 (PDT)
Date: Mon, 16 Jul 2018 21:19:18 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: cgroup-aware OOM killer, how to move forward
In-Reply-To: <20180713231630.GB17467@castle.DHCP.thefacebook.com>
Message-ID: <alpine.DEB.2.21.1807162115180.157949@chino.kir.corp.google.com>
References: <20180711223959.GA13981@castle.DHCP.thefacebook.com> <alpine.DEB.2.21.1807131423230.194789@chino.kir.corp.google.com> <20180713221602.GA15005@castle.DHCP.thefacebook.com> <alpine.DEB.2.21.1807131535420.202408@chino.kir.corp.google.com>
 <20180713230545.GA17467@castle.DHCP.thefacebook.com> <alpine.DEB.2.21.1807131608530.218060@chino.kir.corp.google.com> <20180713231630.GB17467@castle.DHCP.thefacebook.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Roman Gushchin <guro@fb.com>
Cc: linux-mm@kvack.org, akpm@linux-foundation.org, mhocko@kernel.org, hannes@cmpxchg.org, tj@kernel.org, gthelen@google.com

On Fri, 13 Jul 2018, Roman Gushchin wrote:

> > > > All cgroup v2 files do not need to be boolean and the only way you can add 
> > > > a subtree oom kill is to introduce yet another file later.  Please make it 
> > > > tristate so that you can define a mechanism of default (process only), 
> > > > local cgroup, or subtree, and so we can avoid adding another option later 
> > > > that conflicts with the proposed one.  This should be easy.
> > > 
> > > David, we're adding a cgroup v2 knob, and in cgroup v2 a memory cgroup
> > > either has a sub-tree, either attached processes. So, there is no difference
> > > between local cgroup and subtree.
> > > 
> > 
> > Uhm, what?  We're talking about a common ancestor reaching its limit, so 
> > it's oom, and it has multiple immediate children with their own processes 
> > attached.  The difference is killing all processes attached to the 
> > victim's cgroup or all processes under the oom mem cgroup's subtree.
> > 
> 
> But it's a binary decision, no?
> If memory.group_oom set, the whole sub-tree will be killed. Otherwise not.
> 

No, if memory.max is reached and memory.group_oom is set, my understanding 
of your proposal is that a process is chosen and all eligible processes 
attached to its mem cgroup are oom killed.  My desire for a tristate is so 
that it can be specified that all processes attached to the *subtree* are 
oom killed.  With single unified hierarchy mandated by cgroup v2, we can 
separate descendant cgroups for use with other controllers and enforce 
memory.max by an ancestor.

Making this a boolean value is only preventing it from becoming 
extensible.  If memory.group_oom only is effective for the victim's mem 
cgroup, it becomes impossible to specify that all processes in the subtree 
should be oom killed as a result of the ancestor limit without adding yet 
another tunable.
